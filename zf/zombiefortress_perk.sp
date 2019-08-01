////////////////////////////////////////////////////////////////////////////////
//
//  Z O M B I E - F O R T R E S S - [TF2]
//
//  This is a rewrite of the original ZF mod.
//
//  Author: dirtyminuth
//
//  Credits: Sirot, original author of ZF.
//
////////////////////////////////////////////////////////////////////////////////

// FEATURES
// Survivors / zombies not changing teams on round restart should not get classes switched.
// + On joinClass, set sur/zom class
// + On roundStart, spawn with sur/zom class
// Improve menus (organize, add screen for current state (enabled / disabled / team roles / author / version)

// BUGS
// pl_goldrush, second stage, last survivor (BLU) dies, crash. Why?
// + Not in event_playerDeath, about 4-6 after
// + Not in handle_winCondition, crash occurs soon (within ~1s) of death
// + Nothing in timer_main. Maybe it's the spectator issue?

// WORK
// (Round Start Respawn)    [ZF] event_PlayerSpawn 1 6
//                          [ZF] Grace period begun. Survivors can change classes.
// (Round Start Spawn)      [ZF] spawnClient 1 6
// (Spawn from spawnClient) [ZF] event_PlayerSpawn 1 5
// (Postspawn from spawn 1) [ZF] timer_postSpawn 1 5
// (Postspawn from spawn 2) [ZF] timer_postSpawn 1 5

#pragma semicolon 1

//
// Includes
//
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <tf2_stocks>

#include "zf_util_base.inc"
#include "zf_util_pref.inc"
#include "zf_perk.inc"

//
// Plugin Information
//
#define PLUGIN_VERSION "4.2.0.16"
public Plugin:myinfo = 
{
  name          = "Zombie Fortress",
  author        = "dirtyminuth (Recode), Sirot (Original)",
  description   = "Pits a team of survivors aganist an endless onslaught of zombies.",
  version       = PLUGIN_VERSION,
  url           = "http://forums.alliedmods.net/showthread.php?p=1227078"
}

//
// Defines
//
#define ZF_SPAWNSTATE_REST    0
#define ZF_SPAWNSTATE_HUNGER  1
#define ZF_SPAWNSTATE_FRENZY  2

#define PLAYERBUILTOBJECT_ID_DISPENSER  0
#define PLAYERBUILTOBJECT_ID_TELENT     1
#define PLAYERBUILTOBJECT_ID_TELEXIT    2
#define PLAYERBUILTOBJECT_ID_SENTRY     3

//
// State
//   

// Global State
new zf_bEnabled;
new zf_bNewRound;
new zf_spawnState;
new zf_spawnRestCounter;
new zf_spawnSurvivorsKilledCounter;
new zf_spawnZombiesKilledCounter;

// Global Timer Handles
new Handle:zf_tMain;
new Handle:zf_tMainSlow;

// Cvar Handles
new Handle:zf_cvForceOn;
new Handle:zf_cvRatio;
new Handle:zf_cvAllowTeamPref;
new Handle:zf_cvSwapOnPayload;
new Handle:zf_cvSwapOnAttdef;

////////////////////////////////////////////////////////////
//
// Sourcemod Callbacks
//
////////////////////////////////////////////////////////////
public OnPluginStart()
{
// TODO Doesn't register as true at this point. Where else can it be called?
//   // Check for necessary extensions
//   if(LibraryExists("sdkhooks"))
//     SetFailState("SDK Hooks is not loaded.");
    
  // Add server tag.
  AddServerTag("zf");
  
  // Initialize global state
  zf_bEnabled = false;
  zf_bNewRound = true;
  setRoundState(RoundInit1);
  
  // Initialize timer handles
  zf_tMain = INVALID_HANDLE;
  zf_tMainSlow = INVALID_HANDLE;

  // Initialize other packages  
  utilBaseInit();
  utilPrefInit();
  utilFxInit();
  perkInit();

  // Register cvars
  CreateConVar("sm_zf_version", PLUGIN_VERSION, "目前 Zombie Fortress Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY); 
  zf_cvForceOn = CreateConVar("sm_zf_force_on", "1", "<0/1> Activate ZF for non-ZF maps.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
  zf_cvRatio = CreateConVar("sm_zf_ratio", "0.65", "<0.01-1.00> Percentage of players that start as survivors.", FCVAR_PLUGIN, true, 0.01, true, 1.0);
  zf_cvAllowTeamPref = CreateConVar("sm_zf_allowteampref", "1", "<0/1> Allow use of team preference criteria.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
  zf_cvSwapOnPayload = CreateConVar("sm_zf_swaponpayload", "1", "<0/1> Swap teams on non-ZF payload maps.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
  zf_cvSwapOnAttdef = CreateConVar("sm_zf_swaponattdef", "1", "<0/1> Swap teams on non-ZF attack/defend maps.", FCVAR_PLUGIN, true, 0.0, true, 1.0); 
    
  // Hook events
  HookEvent("teamplay_round_start",    event_RoundStart);
  HookEvent("teamplay_setup_finished", event_SetupEnd);
  HookEvent("teamplay_round_win",      event_RoundEnd);
  HookEvent("player_spawn",            event_PlayerSpawn);  
  HookEvent("player_death",            event_PlayerDeath);
  HookEvent("player_builtobject",      event_PlayerBuiltObject);
  
  // DEBUG
//   HookEvent("player_death",            event_PlayerDeathPre, EventHookMode_Pre);  
  
  // Hook entity outputs
  HookEntityOutput("item_healthkit_small",  "OnPlayerTouch", event_MedpackPickup);
  HookEntityOutput("item_healthkit_medium", "OnPlayerTouch", event_MedpackPickup);
  HookEntityOutput("item_healthkit_full",   "OnPlayerTouch", event_MedpackPickup);  
  HookEntityOutput("item_ammopack_small",   "OnPlayerTouch", event_AmmopackPickup);
  HookEntityOutput("item_ammopack_medium",  "OnPlayerTouch", event_AmmopackPickup);
  HookEntityOutput("item_ammopack_full",    "OnPlayerTouch", event_AmmopackPickup);
  
  // Register Admin Commands
  RegAdminCmd("sm_zf_enable", command_zfEnable, ADMFLAG_GENERIC, "Activates the Zombie Fortress plugin.");
  RegAdminCmd("sm_zf_disable", command_zfDisable, ADMFLAG_GENERIC, "Deactivates the Zombie Fortress plugin.");
  RegAdminCmd("sm_zf_swapteams", command_zfSwapTeams, ADMFLAG_GENERIC, "Swaps current team roles.");
   
  // Hook Client Commands
  AddCommandListener(hook_JoinTeam,   "jointeam");
  AddCommandListener(hook_JoinClass,  "joinclass");
  AddCommandListener(hook_VoiceMenu,  "voicemenu");
  // Hook Client Console Commands  
  AddCommandListener(hook_zfTeamPref, "zf_teampref");
  // Hook Client Chat / Console Commands
  RegConsoleCmd("zf", cmd_zfMenu);
  RegConsoleCmd("zf_menu", cmd_zfMenu);
  RegConsoleCmd("zf_perk", cmd_zfMenu);
}

public OnConfigsExecuted()
{
  // Determine whether to enable ZF.
  // + Enable ZF for "zf_" maps or if sm_zf_force_on is set.
  // + Disable ZF otherwise.
  if(mapIsZF() || GetConVarBool(zf_cvForceOn))
  {
    zfEnable();
  }
  else
  {
    zfDisable();
  } 
  
  setRoundState(RoundInit1);
    
  perk_OnMapStart();
  
//   // DEBUG
//   decl String:name[128];
//   new Handle:cvar, bool:isCommand, flags;
//   
//   cvar = FindFirstConCommand(name, sizeof(name), isCommand, flags);  
//   if(cvar != INVALID_HANDLE)
//   {
//     do
//     {
//       if (isCommand || !(flags & 0x2) || !StrContains(name, "bot"))
//       {
//         continue;
//       }
//     
//       LogMessage("Locked ConVar: %s", name);
//     } while (FindNextConCommand(cvar, name, sizeof(name), isCommand, flags));
//   }
//   
//   CloseHandle(cvar);
//   // DEBUG  
}  

public OnMapEnd()
{
  // Close timer handles
  if(zf_tMain != INVALID_HANDLE)
  {      
    CloseHandle(zf_tMain);
    zf_tMain = INVALID_HANDLE;
  } 
  if(zf_tMainSlow != INVALID_HANDLE)
  {
    CloseHandle(zf_tMainSlow);
    zf_tMainSlow = INVALID_HANDLE;
  }
  
  setRoundState(RoundPost);
  
  perk_OnMapEnd();
}

public OnClientPostAdminCheck(client)
{
  if(!zf_bEnabled) return;  
     
  CreateTimer(10.0, timer_initialHelp, client, TIMER_FLAG_NO_MAPCHANGE);    
  
  SDKHook(client, SDKHook_Touch, OnTouch);  
  SDKHook(client, SDKHook_PreThinkPost, OnPreThinkPost);
  SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
  SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
  
  pref_OnClientConnect(client);    
  perk_OnClientConnect(client);
}

public OnClientDisconnect(client)
{
  if(!zf_bEnabled) return;
  
  pref_OnClientDisconnect(client);
  perk_OnClientDisconnect(client);
}

public OnGameFrame()
{
  if(!zf_bEnabled) return;  
  
  handle_gameFrameLogic();
  perk_OnGameFrame();
}

public OnEntityCreated(entity, const String:classname[])
{
  if(!zf_bEnabled) return;
  
  perk_OnEntityCreated(entity, classname);
}

////////////////////////////////////////////////////////////
//
// SDKHooks Callbacks
//
////////////////////////////////////////////////////////////
public Action:OnGetGameDescription(String:gameDesc[64])
{
  if(!zf_bEnabled) return Plugin_Continue;    
  Format(gameDesc, sizeof(gameDesc), "Zombie Fortress (%s)", PLUGIN_VERSION);
  return Plugin_Changed;
}

public OnTouch(entity, other)
{
  if(!zf_bEnabled) return;
  
  perk_OnTouch(entity, other);
}

public OnPreThinkPost(client)
{ 
  if(!zf_bEnabled) return;
     
  //
  // Handle speed bonuses.
  //
  if(validLivingClient(client) && !isSlowed(client) && !isDazed(client) && !isCharging(client))
  {
    new Float:speed = clientBaseSpeed(client) + clientBonusSpeed(client) + getStat(client, ZFStatSpeed);
    setClientSpeed(client, speed);
  }  
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{  
  if(!zf_bEnabled) return Plugin_Continue;
  
  return perk_OnTakeDamage(victim, attacker, inflictor, damage, damagetype);
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype)
{  
  if(!zf_bEnabled) return;
  
  perk_OnTakeDamagePost(victim, attacker, inflictor, damage, damagetype);
}

////////////////////////////////////////////////////////////
//
// Admin Console Command Handlers
//
////////////////////////////////////////////////////////////
public Action:command_zfEnable (client, args)
{ 
  if(zf_bEnabled) return Plugin_Continue;
  
  zfEnable();
  ServerCommand("mp_restartgame 10");
  PrintToChatAll("\x05[ZF]\x01 ZF 初始化中~");

  return Plugin_Continue;
}

public Action:command_zfDisable (client, args)
{
  if(!zf_bEnabled) return Plugin_Continue;
  
  zfDisable();
  ServerCommand("mp_restartgame 10");  
  PrintToChatAll("\x05[ZF]\x01 ZF 卸载中~");
  
  return Plugin_Continue;
}

public Action:command_zfSwapTeams(client, args)
{
  if(!zf_bEnabled) return Plugin_Continue;

  zfSwapTeams();
  ServerCommand("mp_restartgame 10");
  PrintToChatAll("\x05[ZF]\x01 Team roles swapped. Restarting Round...");

  zf_bNewRound = true;      
  setRoundState(RoundInit2);
      
  return Plugin_Continue;
}

////////////////////////////////////////////////////////////
//
// Client Console / Chat Command Handlers
//
////////////////////////////////////////////////////////////
public Action:hook_JoinTeam(client, const String:command[], argc)
{  
  decl String:cmd1[32];
  decl String:sSurTeam[16];  
  decl String:sZomTeam[16];
  decl String:sZomVgui[16];
  
  if(!zf_bEnabled) return Plugin_Continue;  
  if(argc < 1) return Plugin_Handled;
   
  GetCmdArg(1, cmd1, sizeof(cmd1));
  
  if(roundState() >= RoundGrace)
  {
    // Assign team-specific strings
    if(zomTeam() == _:TFTeam_Blue)
    {
      sSurTeam = "red";
      sZomTeam = "blue";
      sZomVgui = "class_blue";
    }
    else
    {
      sSurTeam = "blue";
      sZomTeam = "red";
      sZomVgui = "class_red";      
    }
      
    // If client tries to join the survivor team or a random team
    // during grace period or active round, place them on the zombie
    // team and present them with the zombie class select screen.
    if(StrEqual(cmd1, sSurTeam, false) || StrEqual(cmd1, "auto", false))
    {
      ChangeClientTeam(client, zomTeam());
      ShowVGUIPanel(client, sZomVgui);
      return Plugin_Handled;
    }
    // If client tries to join the zombie team or spectator
    // during grace period or active round, let them do so.
    else if(StrEqual(cmd1, sZomTeam, false) || StrEqual(cmd1, "spectate", false))
    {
      return Plugin_Continue;
    }
    // Prevent joining any other team.
    else
    {
      return Plugin_Handled;
    }
  }

  return Plugin_Continue;
}

public Action:hook_JoinClass(client, const String:command[], argc)
{
  decl String:cmd1[32];
  
  if(!zf_bEnabled) return Plugin_Continue;
  if(argc < 1) return Plugin_Handled;

  GetCmdArg(1, cmd1, sizeof(cmd1));
  
//   // DEBUG
//   PrintToChat(client, "[ZF] hook_JoinClass %d %s", client, cmd1);
  
  if(isZom(client))   
  {
    // If an invalid zombie class is selected, print a message and
    // accept joinclass command. ZF spawn logic will correct this
    // issue when the player spawns.
    if(!(StrEqual(cmd1, "scout", false) ||
         StrEqual(cmd1, "spy", false)  || 
         StrEqual(cmd1, "heavyweapons", false)))
    {
      PrintToChat(client, "\x05[ZF]\x01 僵尸可用的兵种: Scout, Heavy, Spy.");
    }
  }

  else if(isSur(client))
  {
    // Prevent survivors from switching classes during the round.
    if(roundState() == RoundActive)
    {
      PrintToChat(client, "\x05[ZF]\x01幸存者无法在回合开始后切换兵种!");
      return Plugin_Handled;          
    }
    // If an invalid survivor class is selected, print a message
    // and accept the joincalss command. ZF spawn logic will
    // correct this issue when the player spawns.
    else if(!(StrEqual(cmd1, "soldier", false) || 
              StrEqual(cmd1, "pyro", false) || 
              StrEqual(cmd1, "demoman", false) || 
              StrEqual(cmd1, "engineer", false) || 
              StrEqual(cmd1, "medic", false) || 
              StrEqual(cmd1, "sniper", false)))
    {
      PrintToChat(client, "\x05[ZF]\x01 幸存者可用的兵种: Soldier, Pyro, Demo, Engineer, Medic, Sniper.");
    }       
  }
    
  return Plugin_Continue;
}

public Action:hook_VoiceMenu(client, const String:command[], argc)
{
  decl String:cmd1[32], String:cmd2[32];
  
  if(!zf_bEnabled) return Plugin_Continue;  
  if(argc < 2) return Plugin_Handled;
  
  GetCmdArg(1, cmd1, sizeof(cmd1));
  GetCmdArg(2, cmd2, sizeof(cmd2));
  
  // Capture call for medic commands (represented by "voicemenu 0 0").
  if(StrEqual(cmd1, "0") && StrEqual(cmd2, "0"))
  {   
    return perk_OnCallForMedic(client);
  }
  
  return Plugin_Continue;
}

public Action:hook_zfTeamPref(client, const String:command[], argc)
{
  decl String:cmd[32];
  
  if(!zf_bEnabled) return Plugin_Continue;
     
  // Get team preference
  if(argc == 0)
  {
    if(prefGet(client, TeamPref) == ZF_TEAMPREF_SUR)
      ReplyToCommand(client, "Survivors");
    else if(prefGet(client, TeamPref) == ZF_TEAMPREF_ZOM)
      ReplyToCommand(client, "Zombies");
    else if(prefGet(client, TeamPref) == ZF_TEAMPREF_NONE)
      ReplyToCommand(client, "None");
    return Plugin_Handled;
  }
  
  GetCmdArg(1, cmd, sizeof(cmd));
  
  // Set team preference
  if(StrEqual(cmd, "sur", false))
    prefSet(client, TeamPref, ZF_TEAMPREF_SUR);
  else if(StrEqual(cmd, "zom", false))
    prefSet(client, TeamPref, ZF_TEAMPREF_ZOM);
  else if(StrEqual(cmd, "none", false))
    prefSet(client, TeamPref, ZF_TEAMPREF_NONE);
  else
  {
    // Error in command format, display usage
    GetCmdArg(0, cmd, sizeof(cmd));
    ReplyToCommand(client, "Usage: %s [sur|zom|none]", cmd);    
  }

  return Plugin_Handled;
} 

public Action:cmd_zfMenu(client, args)
{
  if(!zf_bEnabled) return Plugin_Continue; 
  panel_PrintMain(client);
  
  return Plugin_Handled;    
}

////////////////////////////////////////////////////////////
//
// TF2 Gameplay Event Handlers
//
////////////////////////////////////////////////////////////
public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{    
  if(!zf_bEnabled) return Plugin_Continue;
  
  perk_OnCalcIsAttackCritical(client);
  
  // Handle special cases.
  // + Being kritzed overrides other crit calculations.
  if(isKritzed(client))
    return Plugin_Continue;  
  
  // Handle crit penalty.
  // + Always prevent crits with negative crit bonuses.
  if(getStat(client, ZFStatCrit) < 0)
  {
    result = false;    
    return Plugin_Changed;  
  }
  
  // Handle crit bonuses.
  // + Survivors: Crit result is combination of perk and standard crit calulations.
  // + Zombies: Crit result is based solely on perk calculation. 
  if(isSur(client))
  {
    if(getStat(client, ZFStatCrit) > GetRandomInt(0,99))
    {
      result = true;
      return Plugin_Changed;
    }
  }
  else
  {
    result = (getStat(client, ZFStatCrit) > GetRandomInt(0,99));
    return Plugin_Changed;
  }
  
  return Plugin_Continue;
}

//
// Round Start Event
//
public Action:event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
  decl players[MAXPLAYERS];
  decl playerCount;
  decl surCount;
 
  if(!zf_bEnabled) return Plugin_Continue;
  
  //
  // Handle round state.
  // + "teamplay_round_start" event is fired twice on new map loads.
  //
  if(roundState() == RoundInit1) 
  {
    setRoundState(RoundInit2);
    return Plugin_Continue;
  }
  else
  {
    setRoundState(RoundGrace);
    PrintToChatAll("\x05[ZF]\x01 准备时间开始(幸存者可切换兵种和技能).");  
  }

  //
  // Assign players to zombie and survivor teams.
  //
  if(zf_bNewRound)
  {
    // Find all active players.
    playerCount = 0;
    for(new i = 1; i <= MaxClients; i++)
    {
      if(IsClientInGame(i) && (GetClientTeam(i) > 1))
      {
        players[playerCount++] = i;  
      }
    }
  
    // Randomize, sort players 
    SortIntegers(players, playerCount, Sort_Random);
    // NOTE: As of SM 1.3.1, SortIntegers w/ Sort_Random doesn't 
    //       sort the first element of the array. Temp fix below.  
    new idx = GetRandomInt(0,playerCount-1);
    new temp = players[idx];
    players[idx] = players[0];
    players[0] = temp;    
    
    // Sort players using team preference criteria
    if(GetConVarBool(zf_cvAllowTeamPref)) 
    {
      SortCustom1D(players, playerCount, SortFunc1D:Sort_Preference);
    }
    
    // Calculate team counts. At least one survivor must exist.   
    surCount = RoundToFloor(playerCount*GetConVarFloat(zf_cvRatio));
    if((surCount == 0) && (playerCount > 0))
    {
      surCount = 1;
    }  
      
    // Assign active players to survivor and zombie teams.
    for(new i = 0; i < surCount; i++)
      spawnClient(players[i], surTeam());   
    for(new i = surCount; i < playerCount; i++)
      spawnClient(players[i], zomTeam());
  }
          
  // Handle zombie spawn state.  
  zf_spawnState = ZF_SPAWNSTATE_HUNGER;
  zf_spawnSurvivorsKilledCounter = 1;
  setTeamRespawnTime(zomTeam(), 8.0);

  // Handle grace period timers.
  CreateTimer(0.5, timer_graceStartPost, TIMER_FLAG_NO_MAPCHANGE); 
  CreateTimer(45.0, timer_graceEnd, TIMER_FLAG_NO_MAPCHANGE);  

  perk_OnRoundStart();
    
  return Plugin_Continue;
}

//
// Setup End Event
//
public Action:event_SetupEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
  if(!zf_bEnabled) return Plugin_Continue;

  if(roundState() != RoundActive)
  {
    setRoundState(RoundActive);
    PrintToChatAll("\x05[ZF]\x01 准备时间结束");

    perk_OnGraceEnd();
  }
  
  return Plugin_Continue;
}

//
// Round End Event
//
public Action:event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
  if(!zf_bEnabled) return Plugin_Continue;

  //
  // Prepare for a completely new round, if
  // + Round was a full round (full_round flag is set), OR
  // + Zombies are the winning team.
  //
  zf_bNewRound = GetEventBool(event, "full_round") || (GetEventInt(event, "team") == zomTeam());
  setRoundState(RoundPost);
      
  perk_OnRoundEnd();
  
  return Plugin_Continue;
}

//
// Player Spawn Event
//
public Action:event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{   
  if(!zf_bEnabled) return Plugin_Continue;  
      
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  new TFClassType:clientClass = TF2_GetPlayerClass(client);
      
//   // DEBUG
//   PrintToChat(client, "[ZF] event_PlayerSpawn %d %d", client, _:TF2_GetPlayerClass(client));
  
   // 1. Prevent players spawning on survivors if round has started.
   //    Prevent players spawning on survivors as an invalid class.
   //    Prevent players spawning on zombies as an invalid class.
  if(isSur(client))
  {
    if(roundState() == RoundActive)
    {
      spawnClient(client, zomTeam());
      //return Plugin_Continue;
      return Plugin_Handled;
    }
    if(!validSurvivor(clientClass))
    {
      spawnClient(client, surTeam()); 
      //return Plugin_Continue;
      return Plugin_Handled;
    }      
  }
  else if(isZom(client))
  {
    if(!validZombie(clientClass))
    {
      spawnClient(client, zomTeam()); 
      //return Plugin_Continue;
      return Plugin_Handled;
    }
  }   

  // 2. Handle valid, post spawn logic
  CreateTimer(0.1, timer_postSpawn, client, TIMER_FLAG_NO_MAPCHANGE); 
         
  return Plugin_Continue;  
}

// //
// // Player Death Pre Event
// // TODO : Use to change kill icons.
// //
// public Action:event_PlayerDeathPre(Handle:event, const String:name[], bool:dontBroadcast)
// {
//   // DEBUG
//   //SetEventString(event, "weapon_logclassname", "goomba");
//   //SetEventString(event, "weapon", "taunt_scout");
//   //SetEventInt(event, "customkill", 0);
//     
//   // SELFLESS explode on death     "[ZF DEBUG] Vic 9, Klr 1, Ast 0, Inf 1, DTp 40"   // "world"
//   // COMBUSTIBLE explode on death  "[ZF DEBUG] Vic 9, Klr 1, Ast 0, Inf 1, DTp 40"   // "world"
//   // SCORCHING fire damage         "[ZF DEBUG] Vic 10, Klr 1, Ast 0, Inf 1, DTp 808" // "flamethrower"
//   // SICK acid patch               "[ZF DEBUG] Vic 11, Klr 1, Ast 0, Inf 1, DTp 40"  // currently held weapon
//   // TARRED oil patch              "[ZF DEBUG] Vic 11, Klr 1, Ast 0, Inf 1, DTp 40"  // currently held weapon
//   // TOXIC active poison           "[ZF DEBUG] Vic 13, Klr 1, Ast 0, Inf 293, DTp 80000000" // "point_hurt"
//   // TOXIC passive poison          "[ZF DEBUG] Vic 6, Klr 1, Ast 0, Inf 475, DTp 80000000"  // "point_hurt"
//   
//   return Plugin_Continue;
// }

//
// Player Death Event
//
public Action:event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
  if(!zf_bEnabled) return Plugin_Continue;
  
  new victim = GetClientOfUserId(GetEventInt(event, "userid"));
  new killer = GetClientOfUserId(GetEventInt(event, "attacker")); 
  new assist = GetClientOfUserId(GetEventInt(event, "assister"));       
  new inflictor = GetEventInt(event, "inflictor_entindex");
  new damagetype = GetEventInt(event, "damagebits");
  
  // Handle zombie death logic, all round states.
  if(validZom(victim))
  {
    // Remove dropped ammopacks from zombies.
    new index = -1; 
    while ((index = FindEntityByClassname(index, "tf_ammo_pack")) != -1)
    {
      if(GetEntPropEnt(index, Prop_Send, "m_hOwnerEntity") == victim)
        AcceptEntityInput(index, "Kill");
    }    
  }  
    
  perk_OnPlayerDeath(victim, killer, assist, inflictor, damagetype);
    
  if(roundState() != RoundActive) return Plugin_Continue;    
    
  // Handle survivor death logic, active round only.
  if(validSur(victim))
  {
    if(validZom(killer)) zf_spawnSurvivorsKilledCounter--;
  
    // Transfer player to zombie team.
    CreateTimer(6.0, timer_zombify, victim, TIMER_FLAG_NO_MAPCHANGE);
  }
  
  // Handle zombie death logic, active round only.
  else if(validZom(victim))
  {    
    if(validSur(killer)) zf_spawnZombiesKilledCounter--;
  }
    
  return Plugin_Continue;
}

//
// Object Built Event
//
public Action:event_PlayerBuiltObject(Handle:event, const String:name[], bool:dontBroadcast)
{
  if(!zf_bEnabled) return Plugin_Continue;

  new index = GetEventInt(event, "index");
  new object = GetEventInt(event, "object");

  // 1. Handle dispenser rules.
  //    Disable dispensers when they begin construction.
  //    Increase max health to 250 (default level 1 is 150).      
  if(object == PLAYERBUILTOBJECT_ID_DISPENSER)
  {
    SetEntProp(index, Prop_Send, "m_bDisabled", 1);
    SetEntProp(index, Prop_Send, "m_iMaxHealth", 250);
  }

  return Plugin_Continue;     
}

public event_AmmopackPickup(const String:output[], caller, activator, Float:delay)
{ 
  if(!zf_bEnabled) return; 
  perk_OnAmmoPickup(activator, caller); 
}

public event_MedpackPickup(const String:output[], caller, activator, Float:delay)
{ 
  if(!zf_bEnabled) return;
  perk_OnMedPickup(activator, caller); 
}

////////////////////////////////////////////////////////////
//
// Periodic Timer Callbacks
//
////////////////////////////////////////////////////////////
public Action:timer_main(Handle:timer) // 1Hz
{
  if(!zf_bEnabled) return Plugin_Continue;

  handle_survivorAbilities();
  handle_zombieAbilities();        
  perk_OnPeriodic();
  
  if(roundState() == RoundActive)
  {
    handle_winCondition();
    handle_spawnState();
  }
  
  return Plugin_Continue;
}

public Action:timer_mainSlow(Handle:timer) // 4 min
{ 
  if(!zf_bEnabled) return Plugin_Continue;  
  help_printZFInfoChat(0);
  
  return Plugin_Continue;
}

////////////////////////////////////////////////////////////
//
// Aperiodic Timer Callbacks
//
////////////////////////////////////////////////////////////
public Action:timer_graceStartPost(Handle:timer)
{  
  // Disable all resupply cabinets.
  new index = -1;
  while((index = FindEntityByClassname(index, "func_regenerate")) != -1)
    AcceptEntityInput(index, "Disable");
    
  // Remove all dropped ammopacks.
  index = -1;
  while ((index = FindEntityByClassname(index, "tf_ammo_pack")) != -1)      
    AcceptEntityInput(index, "Kill");
  
  // Remove all ragdolls.
  index = -1;
  while ((index = FindEntityByClassname(index, "tf_ragdoll")) != -1)
    AcceptEntityInput(index, "Kill");

  // Disable all payload cart dispensers.
  index = -1;
  while((index = FindEntityByClassname(index, "mapobj_cart_dispenser")) != -1)
    SetEntProp(index, Prop_Send, "m_bDisabled", 1);

  // Disable all respawn room visualizers (non-ZF maps only)
  if(!mapIsZF())
  {
    index = -1;
    while((index = FindEntityByClassname(index, "func_respawnroomvisualizer")) != -1)
      AcceptEntityInput(index, "Disable");
  }
        
  return Plugin_Continue; 
}

public Action:timer_graceEnd(Handle:timer)
{
  if(roundState() != RoundActive)
  {
    setRoundState(RoundActive);
    PrintToChatAll("\x05[ZF]\x01 准备时间开始(幸存者可切换兵种和技能).");
    
    perk_OnGraceEnd();
  }
  
  return Plugin_Continue;  
}

public Action:timer_initialHelp(Handle:timer, any:client)
{    
  // Wait until client is in game before printing initial help text.
  if(IsClientInGame(client))
  {
    help_printZFInfoChat(client);
  }
  else
  {
    CreateTimer(10.0, timer_initialHelp, client, TIMER_FLAG_NO_MAPCHANGE);  
  }
  
  return Plugin_Continue; 
}

public Action:timer_postSpawn(Handle:timer, any:client)
{
//   // DEBUG
//   PrintToChat(client, "[ZF] timer_postSpawn %d %d", client, _:TF2_GetPlayerClass(client));
    
  if(IsClientInGame(client) && IsPlayerAlive(client))
  {
    // Handle zombie spawn logic.
    if(isZom(client)) 
      stripWeapons(client);

    perk_OnPlayerSpawn(client);   
  }  
  
  return Plugin_Continue; 
}

public Action:timer_zombify(Handle:timer, any:client)
{   
  if(validClient(client))
  {
    PrintToChat(client, "\x05[ZF]\x01 你被感染了....");
    spawnClient(client, zomTeam());
  }
  
  return Plugin_Continue; 
}

////////////////////////////////////////////////////////////
//
// Handling Functionality
//
////////////////////////////////////////////////////////////
handle_gameFrameLogic()
{
  // 1. Limit spy cloak to 80% of max.
  for(new i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i) && isZom(i))
    {
      if(getCloak(i) > 80.0) 
        setCloak(i, 80.0);
    }
  }
}
   
handle_winCondition()
{
  // 1. Check for any survivors that are still alive.
  new bool:anySurvivorAlive = false;
  for(new i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i) && isSur(i))
    {
      anySurvivorAlive = true;
      break;
    }
  }

  // 2. If no survivors are alive and at least 1 zombie is playing,
  //    end round with zombie win.
  if(!anySurvivorAlive && (GetTeamClientCount(zomTeam()) > 0))
  {    
    endRound(zomTeam());
  }
}

handle_spawnState()
{
  // 1. Handle zombie spawn times. Zombie spawn times can have one of three
  //    states: Rest (long spawn times), Hunger (medium spawn times), and
  //    Frenzy (short spawn times).
  switch(zf_spawnState)
  {
    // 1a. Rest state (long spawn times). Transition to Hunger
    //     state after rest timer reaches zero.
    case ZF_SPAWNSTATE_REST:    
    {
      zf_spawnRestCounter--;
      if(zf_spawnRestCounter <= 0)
      {
        zf_spawnState = ZF_SPAWNSTATE_HUNGER;
        zf_spawnSurvivorsKilledCounter = 1;        
//         PrintToChatAll("\x05[ZF SPAWN]\x01 僵尸饿了..."); 
        setTeamRespawnTime(zomTeam(), 8.0);                
      }
    }
    
    // 1b. Hunger state (medium spawn times). Transition to Frenzy
    //     state after one survivor is killed.
    case ZF_SPAWNSTATE_HUNGER:
    {
      if(zf_spawnSurvivorsKilledCounter <= 0)
      {
        zf_spawnState = ZF_SPAWNSTATE_FRENZY;
        zf_spawnZombiesKilledCounter = (2 * GetTeamClientCount(zomTeam()));
//        PrintToChatAll("\x05[ZF SPAWN]\x01 Zombies are Frenzied!"); 
        setTeamRespawnTime(zomTeam(), 0.0);        
      }
    }
    
    // 1c. Frenzy state (short spawn times). Transition to Rest
    //     state after a given number of zombies are killed.
    case ZF_SPAWNSTATE_FRENZY:
    {
      if(zf_spawnZombiesKilledCounter <= 0)
      {
        zf_spawnState = ZF_SPAWNSTATE_REST;
        zf_spawnRestCounter = min(45, (3 * GetTeamClientCount(zomTeam())));
//        PrintToChatAll("\x05[ZF SPAWN]\x01 Zombies are Resting..."); 
        setTeamRespawnTime(zomTeam(), 16.0);        
      }
    }
  } 
}

handle_survivorAbilities()
{
  decl clipAmmo;
  decl resAmmo;
  decl ammoAdj;
    
  for(new i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i) && isSur(i))
    {      
      // 1. Handle survivor weapon rules.
      //    SMG doesn't have to reload. 
      //    Syringe gun / blutsauger don't have to reload. 
      //    Flamethrower / backburner ammo limited to 125.
      switch(TF2_GetPlayerClass(i))
      {
        case TFClass_Sniper:
        {
          if(isEquipped(i, ZFWEAP_SMG))
          {
            clipAmmo = getClipAmmo(i, 1);
            resAmmo = getResAmmo(i, 1);            
            ammoAdj = min((25 - clipAmmo), resAmmo);
            if(ammoAdj > 0)
            {
              setClipAmmo(i, 1, (clipAmmo + ammoAdj));
              setResAmmo(i, 1, (resAmmo - ammoAdj));
            }
          }
        }
        
        case TFClass_Medic: 
        {
          if(isEquipped(i, ZFWEAP_SYRINGEGUN) || isEquipped(i, ZFWEAP_BLUTSAUGER))
          {
            clipAmmo = getClipAmmo(i, 0);
            resAmmo = getResAmmo(i, 0);
            ammoAdj = min((40 - clipAmmo), resAmmo);
            if(ammoAdj > 0)
            {
              setClipAmmo(i, 0, (clipAmmo + ammoAdj));
              setResAmmo(i, 0, (resAmmo - ammoAdj));
            }
          }           
        }
        
        case TFClass_Pyro:
        {
          resAmmo = getResAmmo(i, 0);
          if(resAmmo > 125)
          {
            ammoAdj = max((resAmmo - 10),125);
            setResAmmo(i, 0, ammoAdj);
          }    
        }          
      } //switch          
    } //if
  } //for
  
  // 3. Handle sentry rules.
  //    + Norm sentry starts with 60 ammo and decays to 10.
  //    + Mini sentry starts with 60 ammo and decays to 0, then self destructs.
  //    + No sentry can be upgraded.
  new index = -1;
  while ((index = FindEntityByClassname(index, "obj_sentrygun")) != -1)
  {    
    new bool:sentBuilding = GetEntProp(index, Prop_Send, "m_bBuilding") == 1;
    new bool:sentPlacing = GetEntProp(index, Prop_Send, "m_bPlacing") == 1;
    new bool:sentCarried = GetEntProp(index, Prop_Send, "m_bCarried") == 1;
    new bool:sentIsMini = GetEntProp(index, Prop_Send, "m_bMiniBuilding") == 1;
    if(!sentBuilding && !sentPlacing && !sentCarried)
    {  
      new sentAmmo = GetEntProp(index, Prop_Send, "m_iAmmoShells");
      if(sentAmmo > 0)
      {
        if(sentIsMini || (sentAmmo > 10))
        {
          sentAmmo = min(60, (sentAmmo - 1));
          SetEntProp(index, Prop_Send, "m_iAmmoShells", sentAmmo);          
        }
      }
      else
      {
        SetVariantInt(GetEntProp(index, Prop_Send, "m_iMaxHealth"));
        AcceptEntityInput(index, "RemoveHealth");
      }
    }
    
    new sentLevel = GetEntProp(index, Prop_Send, "m_iHighestUpgradeLevel");
    if(sentLevel > 1)
    {
      SetVariantInt(GetEntProp(index, Prop_Send, "m_iMaxHealth"));
      AcceptEntityInput(index, "RemoveHealth");    
    }
  }    
}

handle_zombieAbilities()
{
  decl TFClassType:clientClass;
  decl curH;
  decl maxH;
  decl bonus;
  
  for(new i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i) && isZom(i))
    {   
      clientClass = TF2_GetPlayerClass(i);
      curH = GetClientHealth(i);
      maxH = GetEntProp(i, Prop_Data, "m_iMaxHealth");
      
      // 1. Handle zombie regeneration.
      //    Zombies regenerate health based on class. 
      //    Zombies decay health when overhealed.
      bonus = 0;
      if(curH < maxH)
      {
        switch(clientClass)
        {
          case TFClass_Scout: bonus = 2;
          case TFClass_Heavy: bonus = 4;
          case TFClass_Spy:   bonus = 2;
        }    
        curH += bonus;
        curH = min(curH, maxH);
        SetEntityHealth(i, curH);
      }
      else if(curH > maxH)
      {
        switch(clientClass)
        {
          case TFClass_Scout: bonus = -3;
          case TFClass_Heavy: bonus = -7;
          case TFClass_Spy:   bonus = -3;
        }        
        curH += bonus;
        curH = max(curH, maxH); 
        SetEntityHealth(i, curH);
      }
    } //if
  } //for
}

////////////////////////////////////////////////////////////
//
// ZF Logic Functionality
//
////////////////////////////////////////////////////////////
zfEnable()
{     
  zf_bEnabled = true;
  zf_bNewRound = true;
  setRoundState(RoundInit2);

  zfSetTeams();
      
  // Adjust gameplay CVars.
  SetConVarInt(FindConVar("mp_autoteambalance"), 0);
  SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);
  // Engineer
  SetConVarInt(FindConVar("tf_obj_upgrade_per_hit"), 0);
  SetConVarInt(FindConVar("tf_sentrygun_metal_per_shell"), 201);
  // Medic
  SetConVarInt(FindConVar("weapon_medigun_charge_rate"), 30);       // Time (in 2s) of non-damaged healing for 100% uber.
  SetConVarInt(FindConVar("weapon_medigun_chargerelease_rate"), 6); // Duration (in s) of uber.
  SetConVarFloat(FindConVar("tf_max_health_boost"), 1.25);          // Percentage of full HP that is max overheal HP.
  SetConVarInt(FindConVar("tf_boost_drain_time"), 3600);            // Time (in s) of max overheal HP decay to normal health.
  // Spy
  SetConVarFloat(FindConVar("tf_spy_invis_time"), 0.5);             // Time (in s) between cloak command actual cloak.
  SetConVarFloat(FindConVar("tf_spy_invis_unstealth_time"), 0.75);  // Time (in s) between decloak command and actual decloak.
  SetConVarFloat(FindConVar("tf_spy_cloak_no_attack_time"), 1.0);   // Time (in s) between decloak and first attack.
    
  // [Re]Enable periodic timers.
  if(zf_tMain != INVALID_HANDLE)    
    CloseHandle(zf_tMain);
  zf_tMain = CreateTimer(1.0, timer_main, _, TIMER_REPEAT); 
 
  if(zf_tMainSlow != INVALID_HANDLE)
    CloseHandle(zf_tMainSlow);    
  zf_tMainSlow = CreateTimer(240.0, timer_mainSlow, _, TIMER_REPEAT); 
}

zfDisable()
{  
  zf_bEnabled = false;
  zf_bNewRound = true;
  setRoundState(RoundInit2);
    
  // Adjust gameplay CVars.
  SetConVarInt(FindConVar("mp_autoteambalance"), 1);
  SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 1);
  // Engineer
  SetConVarInt(FindConVar("tf_obj_upgrade_per_hit"), 25);
  SetConVarInt(FindConVar("tf_sentrygun_metal_per_shell"), 1);
  // Medic
  SetConVarInt(FindConVar("weapon_medigun_charge_rate"), 40);
  SetConVarInt(FindConVar("weapon_medigun_chargerelease_rate"), 8);
  SetConVarFloat(FindConVar("tf_max_health_boost"), 1.5);
  SetConVarInt(FindConVar("tf_boost_drain_time"), 15);
  // Spy
  SetConVarFloat(FindConVar("tf_spy_invis_time"), 1.0);
  SetConVarFloat(FindConVar("tf_spy_invis_unstealth_time"), 2.0);
  SetConVarFloat(FindConVar("tf_spy_cloak_no_attack_time"), 2.0);
      
  // Disable periodic timers.
  if(zf_tMain != INVALID_HANDLE)
  {      
    CloseHandle(zf_tMain);
    zf_tMain = INVALID_HANDLE;
  }
  if(zf_tMainSlow != INVALID_HANDLE)
  {
    CloseHandle(zf_tMainSlow);
    zf_tMainSlow = INVALID_HANDLE;
  }

  // Enable resupply lockers.
  new index = -1;
  while((index = FindEntityByClassname(index, "func_regenerate")) != -1)
    AcceptEntityInput(index, "Enable");
}

zfSetTeams()
{
  //
  // Determine team roles.
  // + By default, survivors are RED and zombies are BLU.
  //
  new survivorTeam = _:TFTeam_Red;
  new zombieTeam = _:TFTeam_Blue;
  
  //
  // Determine whether to swap teams on payload maps.
  // + For "pl_" prefixed maps, swap teams if sm_zf_swaponpayload is set.
  //
  if(mapIsPL())
  {
    if(GetConVarBool(zf_cvSwapOnPayload)) 
    {      
      survivorTeam = _:TFTeam_Blue;
      zombieTeam = _:TFTeam_Red;
    }
  }
  
  //
  // Determine whether to swap teams on attack / defend maps.
  // + For "cp_" prefixed maps with all RED control points, swap teams if sm_zf_swaponattdef is set.
  //
  else if(mapIsCP())
  {
    if(GetConVarBool(zf_cvSwapOnAttdef))
    {
      new bool:isAttdef = true;
      new index = -1;
      while((index = FindEntityByClassname(index, "team_control_point")) != -1)
      {
        if(GetEntProp(index, Prop_Send, "m_iTeamNum") != _:TFTeam_Red)
        {
          isAttdef = false;
          break;
        }
      }
      
      if(isAttdef)
      {
        survivorTeam = _:TFTeam_Blue;
        zombieTeam = _:TFTeam_Red;
      }
    }
  }
  
  // Set team roles.
  setSurTeam(survivorTeam);
  setZomTeam(zombieTeam);
}

zfSwapTeams()
{
  new survivorTeam = surTeam();
  new zombieTeam = zomTeam();
  
  // Swap team roles.
  setSurTeam(zombieTeam);
  setZomTeam(survivorTeam);
}

////////////////////////////////////////////////////////////
//
// Utility Functionality
//
////////////////////////////////////////////////////////////
public Sort_Preference(client1, client2, const array[], Handle:hndl)
{  
  // Used during round start to sort using client team preference.
  new prefCli1 = IsFakeClient(client1) ? ZF_TEAMPREF_NONE : prefGet(client1, TeamPref);
  new prefCli2 = IsFakeClient(client2) ? ZF_TEAMPREF_NONE : prefGet(client2, TeamPref);  
  return (prefCli1 < prefCli2) ? -1 : (prefCli1 > prefCli2) ? 1 : 0;
}

////////////////////////////////////////////////////////////
//
// Help Functionality
//
////////////////////////////////////////////////////////////
public help_printZFInfoChat(client)
{
  if(client == 0)
  {
    PrintToChatAll("\x05[ZF]\x01 输入 \"!zf\" 打开菜单!");
  }
  else
  {
    PrintToChatAll("\x05[ZF]\x01 输入 \"!zf\" 打开菜单!");
  }
}

////////////////////////////////////////////////////////////
//
// Main Menu Functionality
//
////////////////////////////////////////////////////////////

//
// Main
//
public panel_PrintMain(client)
{
  new Handle:panel = CreatePanel();
  
  SetPanelTitle(panel, "僵尸菜单", false);
  DrawPanelItem(panel, "选择幸存者技能", 0);
  DrawPanelItem(panel, "选择僵尸技能", 0);
  DrawPanelItem(panel, "更改队伍偏好", 0);
  DrawPanelItem(panel, "僵尸模式帮助", 0); 
  DrawPanelItem(panel, "僵尸模式技能帮助", 0);
  DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleMain, 30);
  CloseHandle(panel);
}

public panel_HandleMain(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: DisplayMenu(zf_menuSurPerkList, param1, MENU_TIME_FOREVER); 
      case 2: DisplayMenu(zf_menuZomPerkList, param1, MENU_TIME_FOREVER); 
      case 3: panel_PrintPrefTeam(param1);   
      case 4: panel_PrintHelp(param1);
      case 5: panel_PrintPerkHelp(param1);      
      default: return;   
    } 
  } 
}

//
// Main.PrefTeam
//
public panel_PrintPrefTeam(client)
{
  new Handle:panel = CreatePanel();
  SetPanelTitle(panel, "更改队伍偏好");
  
  if(prefGet(client, TeamPref) == ZF_TEAMPREF_NONE)
    DrawPanelItem(panel, "(目前) 随机", ITEMDRAW_DISABLED);
  else
    DrawPanelItem(panel, "随机");

  if(prefGet(client, TeamPref) == ZF_TEAMPREF_SUR)
    DrawPanelItem(panel, "(目前) 幸存者", ITEMDRAW_DISABLED);
  else
    DrawPanelItem(panel, "幸存者");
        
  if(prefGet(client, TeamPref) == ZF_TEAMPREF_ZOM)
    DrawPanelItem(panel, "(目前) 僵尸", ITEMDRAW_DISABLED);
  else
    DrawPanelItem(panel, "僵尸");
    
  DrawPanelItem(panel, "关闭菜单");
  SendPanelToClient(panel, client, panel_HandlePrefTeam, 30);
  CloseHandle(panel);
}

public panel_HandlePrefTeam(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: prefSet(param1, TeamPref, ZF_TEAMPREF_NONE);
      case 2: prefSet(param1, TeamPref, ZF_TEAMPREF_SUR);
      case 3: prefSet(param1, TeamPref, ZF_TEAMPREF_ZOM);
      default: return;   
    } 
  }
}

//
// Main.Help
//
public panel_PrintHelp(client)
{
  new Handle:panel = CreatePanel();
  
  SetPanelTitle(panel, "僵尸模式帮助", false);
  DrawPanelItem(panel, "总览", 0);
  DrawPanelItem(panel, "幸存者总览", 0);
  DrawPanelItem(panel, "僵尸总览", 0);
  DrawPanelItem(panel, "职业:幸存者", 0);
  DrawPanelItem(panel, "职业:僵尸", 0);
  DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleHelp, 30);
  CloseHandle(panel);
}

public panel_HandleHelp(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintHelpOverview(param1);
      case 2: panel_PrintHelpTeam(param1, surTeam());
      case 3: panel_PrintHelpTeam(param1, zomTeam());
      case 4: panel_PrintHelpSurClass(param1);
      case 5: panel_PrintHelpZomClass(param1);
      default: return;   
    } 
  } 
}
 
//
// Main.Help.Overview
//
public panel_PrintHelpOverview(client)
{
  new Handle:panel = CreatePanel();
  SetPanelTitle(panel, "总览", false);
  DrawPanelText(panel, "----------------------------------------");
  DrawPanelText(panel, "幸存者必须活着度过这无尽的尸潮.");
  DrawPanelText(panel, "幸存者死后会变为僵尸.");
  DrawPanelText(panel, "----------------------------------------");
  DrawPanelItem(panel, "返回", 0);
  DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleHelpOverview, 30);
  CloseHandle(panel);
}

public panel_HandleHelpOverview(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintHelp(param1);
      default: return;   
    } 
  } 
}
 
//
// Main.Help.Team
//
public panel_PrintHelpTeam(client, team)
{
  new Handle:panel = CreatePanel();
  if(team == surTeam())
  {
    SetPanelTitle(panel, "幸存者队伍", false);
    DrawPanelText(panel, "----------------------------------------");
    DrawPanelText(panel, "幸存者可以使用:士兵, 爆破手,");
    DrawPanelText(panel, "火焰兵, 工程师, 医生, 和狙击手.");
    DrawPanelText(panel, "----------------------------------------");
  }
  else if(team == zomTeam())
  {
			SetPanelTitle(panel, "僵尸队伍", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "僵尸可以使用:侦察兵, 机枪手, 和间谍");
			DrawPanelText(panel, "他们会额外获得生命恢复");
			DrawPanelText(panel, "----------------------------------------");
  }
	DrawPanelItem(panel, "返回", 0);
	DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleHelpTeam, 30);
  CloseHandle(panel);
}

public panel_HandleHelpTeam(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintHelp(param1);
      default: return;   
    } 
  } 
}

//
// Main.Help.Class
//
public panel_PrintHelpSurClass(client)
{
  new Handle:panel = CreatePanel();
  
	SetPanelTitle(panel, "兵种资料", false);
	DrawPanelItem(panel, "士兵", 0);
	DrawPanelItem(panel, "狙击手", 0);
	DrawPanelItem(panel, "医生", 0);
	DrawPanelItem(panel, "爆破手", 0);
	DrawPanelItem(panel, "火焰兵", 0);
	DrawPanelItem(panel, "工程师", 0);
	DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleHelpSurClass, 30);
  CloseHandle(panel);
}

public panel_HandleHelpSurClass(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintClass(param1, TFClass_Soldier);
      case 2: panel_PrintClass(param1, TFClass_Sniper);
      case 3: panel_PrintClass(param1, TFClass_Medic);
      case 4: panel_PrintClass(param1, TFClass_DemoMan);
      case 5: panel_PrintClass(param1, TFClass_Pyro);
      case 6: panel_PrintClass(param1, TFClass_Engineer);
      default: return;   
    } 
  } 
}
      
public panel_PrintHelpZomClass(client)
{
  new Handle:panel = CreatePanel();
  
	SetPanelTitle(panel, "僵尸职业", false);
	DrawPanelItem(panel, "侦察兵", 0);
	DrawPanelItem(panel, "机枪手", 0);
	DrawPanelItem(panel, "间谍", 0);
	DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleHelpZomClass, 30);
  CloseHandle(panel);
}

public panel_HandleHelpZomClass(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintClass(param1, TFClass_Scout);
      case 2: panel_PrintClass(param1, TFClass_Heavy);
      case 3: panel_PrintClass(param1, TFClass_Spy);
      default: return;   
    } 
  } 
}

public panel_PrintClass(client, TFClassType:class)
{
  new Handle:panel = CreatePanel();
  switch(class)
  {
    case TFClass_Soldier:
    {
			SetPanelTitle(panel, "士兵 [幸存者/进攻]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "和原版相同.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Pyro:
    {
			SetPanelTitle(panel, "火焰兵 [幸存者/进攻]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "火焰喷射器/偷袭火焰喷射器 弹药更改为125.");
			DrawPanelText(panel, "移动速度从300改为240.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_DemoMan:
    {
      SetPanelTitle(panel, "Demoman [Survivor/Assault]");
      DrawPanelText(panel, "----------------------------------------");
      DrawPanelText(panel, "No changes."); 
      DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Engineer:
    {
			SetPanelTitle(panel, "工程师 [幸存者/支援]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "建筑物不能升级,但能修复");
			DrawPanelText(panel, "建筑物的子弹只有60发");
			DrawPanelText(panel, "子弹会自行减少,且子弹不能被恢复.");
			DrawPanelText(panel, "当弹药耗尽步哨就会自毁.");
			DrawPanelText(panel, "补给器的血量增加到250.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Medic:
    {
			SetPanelTitle(panel, "医生 [幸存者/支援]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "注射器/吸血注射器不用装弹");
			DrawPanelText(panel, "uber充能速度更快但不持久");
			DrawPanelText(panel, "超量治疗限制在原来血量的125%");
			DrawPanelText(panel, "超量治疗的血量衰减的更慢.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Sniper:
    {
			SetPanelTitle(panel, "狙击手 [幸存者/支援]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "SMG不需要装弹.");
			DrawPanelText(panel, "----------------------------------------");
    }    
    case TFClass_Scout:
    {
			SetPanelTitle(panel, "侦察兵 [僵尸]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "只能用短棍/睡魔/鱼/暴击可乐.");
			DrawPanelText(panel, "移动速度从400改为350.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Heavy:
    {
			SetPanelTitle(panel, "机枪手 [僵尸]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "只能用拳头/暴击拳套/三明治/巧克力.");
			DrawPanelText(panel, "----------------------------------------");
    }
    case TFClass_Spy:
    {
			SetPanelTitle(panel, "间谍 [僵尸]", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "只能用小刀/手表/死铃/袖剑");
			DrawPanelText(panel, "移动速度从300改为280");
			DrawPanelText(panel, "----------------------------------------");    }    
    default:
    {
			SetPanelTitle(panel, "观察者", false);
			DrawPanelText(panel, "----------------------------------------");
			DrawPanelText(panel, "emmmmmmm");
			DrawPanelText(panel, "----------------------------------------");
    }
  }
	DrawPanelItem(panel, "返回", 0);
	DrawPanelItem(panel, "关闭菜单", 0);
  SendPanelToClient(panel, client, panel_HandleClass, 8);
  CloseHandle(panel);
}

public panel_HandleClass(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintHelp(param1);
      default: return;   
    } 
  } 
}

//
// Main.PerkHelp
//
panel_PrintPerkHelp(client)
{
  new Handle:panel = CreatePanel();
  
	SetPanelTitle(panel, "僵尸技能总览", false);
	DrawPanelText(panel, "----------------------------------------");
	DrawPanelText(panel, "每一名玩家都能选择一个生存技能");
	DrawPanelText(panel, "和一个僵尸技能. 技能的挑选");
	DrawPanelText(panel, "只能在一开始");
	DrawPanelText(panel, "或者重生后.");
	DrawPanelText(panel, "----------------------------------------");
	DrawPanelItem(panel, "[返回]", 0);
	DrawPanelItem(panel, "[关闭菜单]", 0);
  SendPanelToClient(panel, client, panel_HandlePerkHelp, 30);
  CloseHandle(panel);  
}

public panel_HandlePerkHelp(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: panel_PrintHelp(param1);       
      default: return;   
    } 
  }  
}
