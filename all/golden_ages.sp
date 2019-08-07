#pragma semicolon 1

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2attributes>
#undef REQUIRE_EXTENSIONS
#include <steamtools>
#define REQUIRE_EXTENSIONS
#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN

#define PLUGIN_VERSION		"1.0.2"

#define UPDATE_URL "http://shadowmario.github.io/goldenages/updater.txt"

// Player Vars
bool demoCharging[MAXPLAYERS+1] = false;
bool colaEffect[MAXPLAYERS+1] = false;
bool hypeActivated[MAXPLAYERS+1] = false;
bool icicleEffect[MAXPLAYERS+1] = false;
bool weaponChanges[MAXPLAYERS+1][5];

int airDashes[MAXPLAYERS+1] = 0;
int lastButtons[MAXPLAYERS+1] = 0;
int icicleTime[MAXPLAYERS+1] = 0;

float lastHype[MAXPLAYERS+1] = 0.0;

Handle chargeTimer[MAXPLAYERS+1] = null;
Handle conchTimer[MAXPLAYERS+1] = null;
Handle colaTimer[MAXPLAYERS+1] = null;
Handle icicleTimer[MAXPLAYERS+1] = null;

// Server Vars
Handle cvarEnabled = null;
Handle cvarGameDesc = null;
Handle cvarUpdater = null;
Handle icicleHUD = null;

char icicleMelt[255] = "weapons/icicle_melt_01.wav";
char itemRecharged[255] = "player/recharged.wav";

#pragma newdecls required

public Plugin myinfo =
{
	name = "[TF2] Golden Ages",
	author = "ShadowMarioBR",
	description = "Play with a weapon's best older stats!",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2631488"
}

////////////////////////////////////////////////////
/////////////////EVENTS & FUNCTIONS/////////////////
////////////////////////////////////////////////////

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char gameFolder[8];
	GetGameFolderName(gameFolder, sizeof(gameFolder));

	if(StrContains(gameFolder, "tf") < 0)
	{
		strcopy(error, err_max, "This plugin can only run on Team Fortress 2.");
		return APLRes_Failure;
	}
	
	#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
	#endif
	
	#if defined _updater_included
	MarkNativeAsOptional("Updater_AddPlugin");
	#endif
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("sm_ga_version", PLUGIN_VERSION, "Golden Ages version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	cvarEnabled = CreateConVar("sm_ga_enabled", "1", "Toggle Golden Ages. 0 = disable, 1 = enable.", _, true, 0.0, true, 1.0);
	cvarGameDesc = CreateConVar("sm_ga_gamedesc", "1", "Toggle setting game description. 0 = disable, 1 = enable.", _, true, 0.0, true, 1.0); //All Gamedesc stuff was taken from TF2x10
	cvarUpdater = CreateConVar("sm_ga_updater", "1", "Toggle Auto-Updating on the plugin. 0 = disable, 1 = enable.", _, true, 0.0, true, 1.0); //All Updater stuff was taken from Freak Fortress 2
	
	HookConVarChange(cvarEnabled, OnConVarChanged);
	HookConVarChange(cvarUpdater, OnConVarChanged);
	
	RegAdminCmd("sm_ga_disable", Command_Disable, ADMFLAG_CONVARS);
	RegAdminCmd("sm_ga_enable", Command_Enable, ADMFLAG_CONVARS);
	
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsValidClient(client))
		{
			CreateTimer(0.1, Timer_StartHook, GetClientOfUserId(client));
			ResetVars(client);
		}
	}
	
	HookEvent("player_death", OnPlayerDeath, EventHookMode_Post);
	HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Post);
	HookEvent("player_changeclass", OnPlayerDeath, EventHookMode_Post);
	HookEvent("post_inventory_application", PostInvApp, EventHookMode_Post);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("arena_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("mvm_begin_wave", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("teamplay_round_start", OnRoundStart, EventHookMode_PostNoCopy);
	
	RegConsoleCmd("sm_checkstats", Command_CheckStats);
	
	AutoExecConfig(true, "goldenages");
	LoadTranslations("golden_ages.phrases");
	
	icicleHUD = CreateHudSynchronizer();
	
	CreateTimer(480.0, Timer_NoticeCommand, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnPluginEnd()
{
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsValidClient(client)) SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnLibraryAdded(const char[] name)
{
	#if defined _updater_included && !defined DEV_REVISION
	if(StrEqual(name, "updater") && GetConVarBool(cvarUpdater))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
}

public void OnLibraryRemoved(const char[] name)
{
	#if defined _updater_included
	if(StrEqual(name, "updater"))
	{
		Updater_RemovePlugin();
	}
	#endif
}

public void OnConfigsExecuted()
{
	#if defined _updater_included && !defined DEV_REVISION
	if(LibraryExists("updater") && GetConVarBool(cvarUpdater))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && IsPlayerAlive(i))
		{
			ResetVars(i);
		}
	}
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if(GetConVarBool(cvarEnabled))
	{
		for(int client = 1; client <= MaxClients; client++)
		{
			ResetVars(client);
		}
	}
	return Plugin_Continue;
}

public Action PostInvApp(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!GetConVarBool(cvarEnabled) || !IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	if(colaTimer[client] != null)
	{
		KillTimer(colaTimer[client]);
		colaTimer[client] = null;
		TF2Attrib_SetByName(client, "move speed penalty", 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
	
	if(icicleTimer[client] != null)
	{
		KillTimer(icicleTimer[client]);
		icicleTimer[client] = null;
	}
	
	if(icicleTime[client] >= GetTime()) EmitSoundToClient(client, itemRecharged);
	
	TF2Attrib_SetByName(client, "dmg taken from fire reduced", 1.0);
	icicleEffect[client] = false;
	icicleTime[client] = 0;
	return Plugin_Continue;
}

public Action OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!GetConVarBool(cvarEnabled) || !IsValidClient(client))
	{
		return Plugin_Continue;
	}
	
	ResetVars(client);
	return Plugin_Continue;
}

public Action OnPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	if(!GetConVarBool(cvarEnabled))
	{
		return Plugin_Continue;
	}
	
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidEntity(attacker) && IsValidEntity(victim))
	{
		int damagecustom = GetEventInt(event, "custom");
		int damage = GetEventInt(event, "damageamount");
		int weapon = IsValidClient(attacker) ? GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon") : -1;
		int primary = IsValidClient(attacker) ? GetPlayerWeaponSlot(attacker, TFWeaponSlot_Primary) : -1;
		int index = IsValidEntity(weapon) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
		if(IsValidEntity(primary) && GetEntProp(primary, Prop_Send, "m_iItemDefinitionIndex") == 594 && victim != attacker) //Phlog stuff
		{
			if(damagecustom == TF_CUSTOM_BURNING || (IsValidEntity(weapon) && IsValidEntity(index) && index == 594))
			{
				float rage = GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter");
				if (rage < 100.0)
				{
					rage += damage * 0.125;
					SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", rage);
				}
				else if(rage > 100.0)
				{
					SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", 100.0);
				}
			}
		}
	}
	return Plugin_Continue;
}

public void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == cvarEnabled)
	{
		if(GetConVarBool(cvarEnabled))
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client))
				{
					SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
				}
			}
		}
		else
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if(IsValidClient(client))
				{
					ResetVars(client);
					SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
				}
			}
		}
		SetGameDescription();
	}
	else if(convar == cvarUpdater)
	{
		#if defined _updater_included && !defined DEV_REVISION
		GetConVarInt(cvarUpdater) ? Updater_AddPlugin(UPDATE_URL) : Updater_RemovePlugin();
		#endif
	}
}

public Action Command_Enable(int client, int args)
{
	if(!GetConVarBool(cvarEnabled))
	{
		ServerCommand("sm_ga_enabled 1");
		ReplyToCommand(client, "[GA] Golden Ages plugin is now enabled.");
	}
	else
	{
		ReplyToCommand(client, "[GA] Golden Ages plugin is already enabled.");
	}
	return Plugin_Handled;
}

public Action Command_Disable(int client, int args)
{
	if(GetConVarBool(cvarEnabled))
	{
		ServerCommand("sm_ga_enabled 0");
		ReplyToCommand(client, "[GA] Golden Ages plugin is now disabled.");
	}
	else
	{
		ReplyToCommand(client, "[GA] Golden Ages plugin is already disabled.");
	}
	return Plugin_Handled;
}

public void OnMapStart()
{
	if(GetConVarBool(cvarEnabled))
	{
		SetGameDescription();
		PrecacheSound(icicleMelt, true);
		PrecacheSound(itemRecharged, true);
	}
}

public void OnMapEnd()
{
	char description[16];
	GetGameDescription(description, sizeof(description));

	if(GetConVarBool(cvarEnabled) && GetConVarBool(cvarGameDesc) && StrContains(description, "Golden Ages ") != -1)
	{
		Steam_SetGameDescription("Team Fortress");
	}
}

public void OnClientPutInServer(int client)
{
	if(GetConVarBool(cvarEnabled))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	ResetVars(client);
}

public void OnClientDisconnect(int client)
{
	if(GetConVarBool(cvarEnabled))
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	if(chargeTimer[client] != null)
	{
		KillTimer(chargeTimer[client]);
		chargeTimer[client] = null;
	}
	if(conchTimer[client] != null)
	{
		KillTimer(conchTimer[client]);
		conchTimer[client] = null;
	}
	if(colaTimer[client] != null)
	{
		KillTimer(colaTimer[client]);
		colaTimer[client] = null;
	}
	demoCharging[client] = false;
	hypeActivated[client] = false;
	colaEffect[client] = false;
	icicleEffect[client] = false;
	icicleTime[client] = 0;
	airDashes[client] = 0;
	lastHype[client] = 0.0;
	lastButtons[client] &= ~IN_JUMP;
	weaponChanges[client][0] = false;
	weaponChanges[client][1] = false;
	weaponChanges[client][2] = false;
	weaponChanges[client][3] = false;
	weaponChanges[client][4] = false;
}

public int TF2Items_OnGiveNamedItem_Post(int client, char[] classname, int index, int itemlvl, int itemqual, int weapon)
{
	if(!GetConVarBool(cvarEnabled))
	{
		return;
	}
	
	if(index==38 || index==457 || index==1000) //Axetinguisher - First Pyro Update
	{
		TF2Attrib_SetByName(weapon, "axtinguisher properties", 1.0);
		TF2Attrib_SetByName(weapon, "dmg penalty vs nonburning", 0.5);
		TF2Attrib_SetByName(weapon, "attack_minicrits_and_consumes_burning", 0.0);
		TF2Attrib_SetByName(weapon, "damage penalty", 1.0);
		TF2Attrib_SetByName(weapon, "single wep holster time increased", 1.0);
	}
	if(index==41) //Natascha - February 7th, 2014 Patch
	{
		TF2Attrib_SetByName(weapon, "spunup_damage_resistance", 1.0);
		TF2Attrib_SetByName(weapon, "maxammo primary increased", 1.5);
	}
	if(index==59) //Dead Ringer - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "mod_cloak_no_regen_from_items", 0.0);
	}
	if(index==61 || index==1006) //Ambassador - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "crit mod disabled", 1.0);
		TF2Attrib_SetByName(weapon, "crit_dmg_falloff", 0.0);
	}
	if(index==133) //Gunboats - Post Gun Mettle Patch
	{
		TF2Attrib_SetByName(weapon, "rocket jump damage reduction", 0.25);
	}
	if(index==220) //Shortstop - Post Gun Mettle Patch
	{
		TF2Attrib_SetByName(weapon, "health from packs increased", 1.2);
		TF2Attrib_SetByName(weapon, "provide on active", 0.0);
		TF2Attrib_SetByName(weapon, "reload time increased hidden", 1.0);
		TF2Attrib_SetByName(weapon, "damage force increase hidden", 1.4);
		TF2Attrib_SetByName(weapon, "airblast vulnerability multiplier hidden", 1.4);
	}
	if(index==230) //Sydney Sleeper - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "jarate duration", 8.0);
		TF2Attrib_SetByName(weapon, "sniper no headshots", 0.0);
		TF2Attrib_SetByName(weapon, "crit mod disabled", 1.0);
	}
	if(index==239 || index==1084 || index==1184) //GRU - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "mod_maxhealth_drain_rate", 0.0);
		TF2Attrib_SetByName(weapon, "self mark for death", 3.0);
	}
	if(index==307) //Ullapool Caber - Pre Tough Break
	{
		TF2Attrib_SetByName(weapon, "fire rate penalty", 1.0);
		TF2Attrib_SetByName(weapon, "single wep deploy time increased", 1.0);
	}
	if(index==308) //Loch-n-Load - Pre Smissmas 2014
	{
		TF2Attrib_SetByName(weapon, "clip size penalty", 0.5);
		TF2Attrib_SetByName(weapon, "dmg bonus vs buildings", 1.0);
		TF2Attrib_SetByName(weapon, "Blast radius decreased", 1.0);
		TF2Attrib_SetByName(weapon, "damage bonus", 1.2);
		TF2Attrib_SetByName(weapon, "blast dmg to self increased", 1.25);
		SetEntProp(weapon, Prop_Data, "m_iClip1", 2);
	}
	if(index==354) //Concheror - December 20th, 2013 Patch
	{
		TF2Attrib_SetByName(weapon, "health regen", 0.0);
	}
	if(index==405 || index==608) //Ali Baba Wee Booties and Bootlegger - Gun Mettle
	{
		TF2Attrib_SetByName(weapon, "move speed bonus shield required", 1.0);
		TF2Attrib_SetByName(weapon, "move speed bonus", 1.1);
	}
	if(index==426) //Eviction Notice - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "mod_maxhealth_drain_rate", 0.0);
		TF2Attrib_SetByName(weapon, "dmg taken increased", 1.2);
	}
	if(index==448) //Soda Popper - 2012 Patch
	{
		TF2Attrib_SetByName(weapon, "hype on damage", 0.0);
		TF2Attrib_SetByName(weapon, "crit mod disabled", 0.0);
	}
	if(index==450) //Atomizer - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "single wep deploy time increased", 1.0);
		TF2Attrib_SetByName(weapon, "dmg penalty vs players", 0.8);
		TF2Attrib_SetByName(weapon, "fire rate penalty", 1.3);
		TF2Attrib_SetByName(weapon, "air dash count", 0.0);
	}
	if(index==460) //Enforcer - 2012 Patch
	{
		TF2Attrib_SetByName(weapon, "dmg pierces resists absorbs", 0.0);
		TF2Attrib_SetByName(weapon, "damage bonus while disguised", 0.834);
		TF2Attrib_SetByName(weapon, "damage bonus", 1.2);
	}
	if(index==649) //Spy-Cicle - Release
	{
		TF2Attrib_SetByName(weapon, "melts in fire", 0.0);
		TF2Attrib_SetByName(weapon, "become fireproof on hit by fire", 0.0);
		TF2Attrib_SetByName(weapon, "set icicle knife mode", 0.0);
		TF2Attrib_SetByName(weapon, "silent killer", 1.0);
	}
	if(index==730) //Beggar's Bazooka - Pre Tough Break
	{
		TF2Attrib_SetByName(weapon, "Blast radius decreased", 1.0);
	}
	if(index==772) //Baby Face's Blaster - Release
	{
		TF2Attrib_SetByName(weapon, "damage penalty", 0.7);
		TF2Attrib_SetByName(weapon, "weapon spread bonus", 0.6);
		TF2Attrib_SetByName(weapon, "lose hype on take damage", 0.0);
		TF2Attrib_SetByName(weapon, "clip size penalty", 1.0);
		TF2Attrib_SetByName(weapon, "hype resets on jump", 100.0);
		TF2Attrib_SetByName(weapon, "move speed penalty", 1.0);
		SetEntProp(weapon, Prop_Data, "m_iClip1", 6);
	}
	if(index==773) //Pretty Boy's Pocket Pistol - Pyromania Update
	{
		TF2Attrib_SetByName(weapon, "provide on active", 0.0);
		TF2Attrib_SetByName(weapon, "heal on hit for rapidfire", 0.0);
		TF2Attrib_SetByName(weapon, "fire rate bonus", 1.0);
		TF2Attrib_SetByName(weapon, "fire rate penalty", 1.25);
		TF2Attrib_SetByName(weapon, "clip size penalty", 1.0);
		TF2Attrib_SetByName(weapon, "max health additive bonus", 15.0);
		TF2Attrib_SetByName(weapon, "cancel falling damage", 1.0);
		TF2Attrib_SetByName(weapon, "dmg taken from fire increased", 1.5);
		SetEntProp(weapon, Prop_Data, "m_iClip1", 12);
	}
	if(index==812 || index==833) //Flying Guillotine - Pre Jungle Inferno
	{
		TF2Attrib_SetByName(weapon, "crit vs stunned players", 1.0);
	}
	if(index==1099) //Tide Turner - Smissmas 2014
	{
		TF2Attrib_SetByName(weapon, "dmg taken from fire reduced", 0.75);
		TF2Attrib_SetByName(weapon, "dmg taken from blast reduced", 0.75);
	}
	if(index==1153) //Panic Attack - Gun Mettle
	{
		TF2Attrib_SetByName(weapon, "damage penalty", 1.0);
		TF2Attrib_SetByName(weapon, "fire rate bonus", 0.7);
		TF2Attrib_SetByName(weapon, "Reload time decreased", 0.5);
		TF2Attrib_SetByName(weapon, "auto fires full clip", 1.0);
		TF2Attrib_SetByName(weapon, "bullets per shot bonus", 1.0);
		SetEntProp(weapon, Prop_Data, "m_iClip1", 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(!GetConVarBool(cvarEnabled) || !IsValidClient(client) || !IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	
	int activeWep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int primary = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	int hpda = GetPlayerWeaponSlot(client, TFWeaponSlot_Building);
	int wearable = MaxClients+1;
	int health = GetClientHealth(client);
	int maxhealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	float hype = GetEntPropFloat(client, Prop_Send, "m_flHypeMeter");
	
	if(IsValidEntity(primary) && GetEntProp(primary, Prop_Send, "m_iItemDefinitionIndex") > -1)
	{
		int prim = GetEntProp(primary, Prop_Send, "m_iItemDefinitionIndex");
		if(prim == 41 || prim == 61 || prim == 1006 || prim == 220 || prim == 230 || prim == 308 ||
		prim == 448 || prim == 460 || prim == 594 || prim == 730 || prim == 772 || prim == 1153)
			weaponChanges[client][1] = true;
		else weaponChanges[client][1] = false;
		
		if(prim == 772)
		{
			if((buttons & IN_JUMP) && !(lastButtons[client] & IN_JUMP)) //Boost Reset
			{
				int jumps = GetEntProp(client, Prop_Send, "m_iAirDash");
				if(jumps == 0)
				{
					SetEntPropFloat(client, Prop_Send, "m_flHypeMeter", 0.0);
				}
			}
			
			TF2Attrib_SetByName(client, "major move speed bonus", 0.65 + hype / 217.35);
			if (lastHype[client] != hype)
			{
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				if(lastHype[client] < hype) SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 1.0);
				lastHype[client] = hype;
			}
		}
		if(prim != 772 && TF2Attrib_GetByName(client, "major move speed bonus"))
		{
			if(lastHype[client] > 0.0)
			{
				lastHype[client] = 0.0;
			}
			TF2Attrib_RemoveByName(client, "major move speed bonus");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
		
		if(prim == 594) //Phlog HP Restoration
		{
			static bool rageActivated[MAXPLAYERS+1] = false;
			if(GetEntProp(client, Prop_Send, "m_bRageDraining") && !(rageActivated[client]))
			{
				rageActivated[client] = true;
				if(health < maxhealth)
				{
					SetEntityHealth(client, maxhealth);
				}
			}
			if(!(GetEntProp(client, Prop_Send, "m_bRageDraining")) && rageActivated[client])
			{
				rageActivated[client] = false;
			}
		}
		
		if(prim == 448) //Soda Popper's Old Hype
		{
			if(hypeActivated[client])
			{
				if (hype > 0.0 && hypeActivated[client])
				{
					hype -= 0.18732;
					if (hype < 0.0)
					{
						hype = 0.0;
						hypeActivated[client] = false;
					}
					SetEntPropFloat(client, Prop_Send, "m_flHypeMeter", hype);
				}
				TF2_AddCondition(client, TFCond_Buffed, 0.06);
			}
		}
		else
		{
			hypeActivated[client] = false;
		}
	}
	
	if(IsValidEntity(secondary) && GetEntProp(secondary, Prop_Send, "m_iItemDefinitionIndex") > -1)
	{
		int sec = GetEntProp(secondary, Prop_Send, "m_iItemDefinitionIndex");
		if(sec == 46 || sec == 163 || sec == 354 || sec == 773 || sec == 812 || sec == 833 || sec == 1153)
			weaponChanges[client][2] = true;
		else weaponChanges[client][2] = false;
		
		// Concheror and Crit-a-Cola
		if(sec == 354)
		{
			if(maxhealth > health && conchTimer[client] == null)
			{
				conchTimer[client] = CreateTimer(1.0, Timer_ConchHeal, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			
			if(maxhealth <= health && conchTimer[client] != null)
			{
				KillTimer(conchTimer[client]);
				conchTimer[client] = null;
			}
		}
		else
		{
			if(conchTimer[client] != null)
			{
				KillTimer(conchTimer[client]);
				conchTimer[client] = null;
			}
		}
		
		if(sec == 163)
		{
			if(colaEffect[client])
			{
				TF2_AddCondition(client, TFCond_Buffed, 0.06);
			}
		}
		else
		{
			if(colaTimer[client] != null)
			{
				KillTimer(colaTimer[client]);
				colaTimer[client] = null;
				colaEffect[client] = false;
				TF2Attrib_SetByName(client, "move speed penalty", 1.0);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
		}
	}
	
	if(IsValidEntity(melee) && GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") > -1)
	{
		int mel = GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex");
		if(mel == 38 || mel == 457 || mel == 1000 || mel == 44 || mel == 239 || mel == 1084 ||
		mel == 1184 || mel == 307 || mel == 426 || mel == 450 || mel == 649)
			weaponChanges[client][3] = true;
		else weaponChanges[client][3] = false;
		
		if(mel == 450) //Atomizer Triple jump
		{
			if(!(GetEntityFlags(client) & FL_ONGROUND))
			{
				if(!(buttons & IN_JUMP) && (lastButtons[client] & IN_JUMP))
				{
					lastButtons[client] &= ~IN_JUMP;
				}
				else if((buttons & IN_JUMP) && !(lastButtons[client] & IN_JUMP) && airDashes[client] < 3)
				{
					if(airDashes[client] == 2)
					{
						DealDamage(client, 10, client, (1 << 11));
					}
					airDashes[client]++;
					lastButtons[client] |= IN_JUMP;
				}
				
				if(!(buttons & IN_JUMP) && !(lastButtons[client] & IN_JUMP) && airDashes[client] == 0) //Fix for Bhop plugins
				{
					airDashes[client] = 1;
				}
			}
			else if(GetEntityFlags(client) & FL_ONGROUND)
			{
				airDashes[client] = 0;
			}
			
			if(airDashes[client] == 2) SetEntProp(client, Prop_Send, "m_iAirDash", 0);
		}
		
		if(mel == 307) //Caber damage
		{
			int detonated = GetEntProp(melee, Prop_Send, "m_iDetonated");
			if(detonated == 0) TF2Attrib_SetByName(melee, "damage bonus HIDDEN", 1.495);
			else if(detonated == 1) TF2Attrib_SetByName(melee, "damage bonus HIDDEN", 0.64);
		}
		
		if(icicleEffect[client])
		{
			if(TF2_IsPlayerInCondition(client, TFCond_OnFire))
			{
				TF2_RemoveCondition(client, TFCond_OnFire);
			}
		}
		
		if(mel == 649)
		{
			static bool noticed[MAXPLAYERS+1] = false;
			if(icicleTime[client] >= GetTime())
			{
				char text[255];
				Format(text, sizeof(text), "%t: %is", "wep_spycicle", icicleTime[client] - GetTime());
				SetHudTextParams(0.85, 0.84, 0.02, 255, 255, 255, 255);
				ShowSyncHudText(client, icicleHUD, text);
				noticed[client] = false;
			}
			else if(GetTime() > icicleTime[client] && !noticed[client])
			{
				EmitSoundToClient(client, itemRecharged);
				noticed[client] = true;
			}
		}
		if(mel != 649)
		{
			if(icicleTimer[client] != null)
			{
				KillTimer(icicleTimer[client]);
				icicleTimer[client] = null;
				icicleEffect[client] = false;
				TF2_RemoveCondition(client, TFCond_UberFireResist);
			}
			icicleTime[client] = 0;
		}
	}
	
	if(IsValidEntity(hpda) && GetEntProp(hpda, Prop_Send, "m_iItemDefinitionIndex") == 59) weaponChanges[client][4] = true;
	else weaponChanges[client][4] = false;
	
	if(IsValidEntity(activeWep) && (GetEntProp(activeWep, Prop_Send, "m_iItemDefinitionIndex") == 220 || GetEntProp(activeWep, Prop_Send, "m_iItemDefinitionIndex") == 448))
	{
		int index = GetEntProp(activeWep, Prop_Send, "m_iItemDefinitionIndex");
		if(index == 448) //Soda Popper's Old Hype Charging
		{
			if(!hypeActivated[client])
			{
				if(hype < 100.0)
				{
					float lastPosition[MAXPLAYERS + 1][3];
					float velocity[3], position[3];
					GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
					GetClientAbsOrigin(client, position);
					float length = GetVectorLength(velocity);
					SubtractVectors(lastPosition[client], position, lastPosition[client]);
					float lengthPosition = GetVectorLength(lastPosition[client]);
					lastPosition[client][0] = position[0];
					lastPosition[client][1] = position[1];
					lastPosition[client][2] = position[2];
					MoveType movementType = GetEntityMoveType(client);
					if (length > 0 && lengthPosition != 0 && (movementType == MOVETYPE_WALK || movementType == MOVETYPE_ISOMETRIC || movementType == MOVETYPE_LADDER))
					{
						hype += 0.1090916 / 400 * length;
						if (hype > 100.0) hype = 100.0;
						SetEntPropFloat(client, Prop_Send, "m_flHypeMeter", hype);
					}
				}
				else if(hype >= 100.0 && !TF2_IsPlayerInCondition(client, TFCond_Bonked))
				{
					hypeActivated[client] = true;
				}
			}
		}
		else
		{
			hypeActivated[client] = false;
		}
		//Anti-MOUSE2 for Shortstop and Soda Popper 
		SetEntPropFloat(activeWep, Prop_Send, "m_flNextSecondaryAttack", GetGameTime() + 9999.0);
		buttons &= ~IN_ATTACK2;
	}
	
	if(IsValidEntity(activeWep) && GetEntProp(activeWep, Prop_Send, "m_iItemDefinitionIndex") == 649) //Spycicle re-coded stat
	{
		if(icicleTime[client] >= GetTime())
		{
			if(TF2_IsPlayerInCondition(client, TFCond_OnFire)) TF2_RemoveCondition(client, TFCond_OnFire);
			if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") == melee) SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", primary);
		}
		
		if(TF2_IsPlayerInCondition(client, TFCond_OnFire) && GetTime() > icicleTime[client])
		{
			float position[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
			EmitSoundToAll(icicleMelt, client, _, _, _, _, _, client, position);
			icicleEffect[client] = true;
			icicleTimer[client] = CreateTimer(3.0, Timer_IcicleTimer, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			TF2Attrib_SetByName(client, "dmg taken from fire reduced", 0.0);
			TF2_RemoveCondition(client, TFCond_OnFire);
			TF2_AddCondition(client, TFCond_UberFireResist, 3.0);
			icicleTime[client] = GetTime() + 15;
		}
	}
	
	while ((wearable = FindEntityByClassname2(wearable, "tf_wearable")) != -1)
	{
		if(IsValidEntity(wearable) && GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable"))
		{
			if(GetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex") == 223 && IsValidEntity(primary) && GetEntProp(primary, Prop_Send, "m_iItemDefinitionIndex") == 224 && IsValidEntity(melee) && GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") == 225) //Saharan Spy set
			{
				TF2Attrib_SetByName(client, "SET BONUS: custom taunt particle attr", 0.0);
				TF2Attrib_SetByName(client, "SET BONUS: cloak blink time penalty", 0.5);
				TF2Attrib_SetByName(client, "SET BONUS: quiet unstealth", 1.0);
				return Plugin_Continue;
			}
			else
			{
				TF2Attrib_SetByName(client, "SET BONUS: cloak blink time penalty", 0.0);
				TF2Attrib_SetByName(client, "SET BONUS: quiet unstealth", 0.0);
			}
		}
		else
		{
			TF2Attrib_SetByName(client, "SET BONUS: cloak blink time penalty", 0.0);
			TF2Attrib_SetByName(client, "SET BONUS: quiet unstealth", 0.0);
		}
	}
	
	while ((wearable = FindEntityByClassname2(wearable, "tf_wearable_demoshield")) != -1)
	{
		if(IsValidEntity(wearable) && GetEntPropEnt(wearable, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(wearable, Prop_Send, "m_bDisguiseWearable"))
		{
			int wear = GetEntProp(wearable, Prop_Send, "m_iItemDefinitionIndex");
			if(wear == 133 || wear == 405 || wear == 608 || wear == 1099) weaponChanges[client][4] = true;
			else weaponChanges[client][4] = false;
		}
	}
	
	return Plugin_Continue;
}

public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(!GetConVarBool(cvarEnabled))
	{
		return;
	}
	
	if (condition == TFCond_CritHype)
	{
		TF2_RemoveCondition(client, TFCond_CritHype);
	}
	if (condition == TFCond_CritCola)
	{
		int secondary = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if(IsValidEntity(secondary))
		{
			if(GetEntProp(secondary, Prop_Send, "m_iItemDefinitionIndex") == 163)
			{
				float duration = GetConditionDuration(client, TFCond_CritCola);
				TF2_RemoveCondition(client, TFCond_CritCola);
				colaEffect[client] = true;
				colaTimer[client] = CreateTimer(duration, Timer_ColaTimer, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				
				TF2Attrib_SetByName(client, "move speed penalty", 1.25);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
		}
	}
	if (condition == TFCond_CritDemoCharge)
	{
		chargeTimer[client] = CreateTimer(0.5, Timer_ChargeCrit, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void TF2_OnConditionRemoved(int client, TFCond condition)
{
	if(!GetConVarBool(cvarEnabled))
	{
		return;
	}
	
	if (condition == TFCond_CritDemoCharge)
	{
		if(chargeTimer[client] != null)
		{
			KillTimer(chargeTimer[client]);
			chargeTimer[client] = null;
		}
		chargeTimer[client] = CreateTimer(0.4, Timer_DetectCharge, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	if (condition == TFCond_Bonked)
	{
		CreateTimer(0.01, Timer_Bonk, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Command_CheckStats(int client, int args)
{
	if(GetConVarBool(cvarEnabled))
	{
		char weapon[70], weaponname[32], stat1[160], stat2[160], stat3[160], stat4[160], stat5[160], stat6[160];
		
		Handle menu = CreateMenu(CheckStats_Handler, MENU_ACTIONS_ALL);
		SetMenuPagination(menu, 7);
		SetMenuTitle(menu, "%t", "title");
		int hprim = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
		int hsec = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		int hmel = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int hpda = GetPlayerWeaponSlot(client, TFWeaponSlot_Building);
		int hwear = MaxClients+1;
		int primary = IsValidEntity(hprim) ? GetEntProp(hprim, Prop_Send, "m_iItemDefinitionIndex") : -1;
		int secondary = IsValidEntity(hsec) ? GetEntProp(hsec, Prop_Send, "m_iItemDefinitionIndex") : -1;
		int melee = IsValidEntity(hmel) ? GetEntProp(hmel, Prop_Send, "m_iItemDefinitionIndex") : -1;
		int pda = IsValidEntity(hpda) ? GetEntProp(hpda, Prop_Send, "m_iItemDefinitionIndex") : -1;
		if(weaponChanges[client][0] || weaponChanges[client][1] || weaponChanges[client][2] || weaponChanges[client][3] || weaponChanges[client][4])
		{
			if(IsValidEntity(hprim) && primary > -1)
			{
				if(primary == 41)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_natascha");
					Format(weapon, sizeof(weapon), "%t", "removedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "maxammoprimbon");
					Format(stat2, sizeof(stat2), "%t", "nataschastat");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 61 || primary == 1006)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_amby");
					Format(weapon, sizeof(weapon), "%t", "removedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "norandomcrits");
					Format(stat2, sizeof(stat2), "%t", "ambyrange");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 220)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_shortstop");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "healthpackbon", 20);
					Format(stat2, sizeof(stat2), "%t", "knockpen", 40);
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 230)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_sydney");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "jaratetime");
					Format(stat2, sizeof(stat2), "%t", "sydneyhs");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 308)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_loch");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "dmgbon", 20);
					Format(stat2, sizeof(stat2), "%t", "projbon", 25);
					Format(stat3, sizeof(stat3), "%t", "nospin");
					Format(stat4, sizeof(stat4), "%t", "grenshatter");
					Format(stat5, sizeof(stat5), "%t", "blastjumpdmgpen", 25);
					Format(stat6, sizeof(stat6), "%t", "clippen", 50);
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", stat5, _);
					AddMenuItem(menu, "", stat6, _);
				}
				else if(primary == 448)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_sodapopper");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "hypeonrun");
					Format(stat2, sizeof(stat2), "%t", "firebon", 50);
					Format(stat3, sizeof(stat3), "%t", "reloadbon", 25);
					Format(stat4, sizeof(stat4), "%t", "clippen", 66);
					Format(stat5, sizeof(stat5), "%t", "norandomcrits");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", stat5, _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 460)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_enforcer");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "enforcerdmg", 20);
					Format(stat2, sizeof(stat2), "%t", "firepen", 20);
					Format(stat3, sizeof(stat3), "%t", "norandomcrits");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 594)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_phlog");
					Format(weapon, sizeof(weapon), "%t", "changedstatas", weaponname);
					Format(stat1, sizeof(stat1), "%t", "phlog1");
					Format(stat2, sizeof(stat2), "%t", "phlog2");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 730)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_bazooka");
					Format(weapon, sizeof(weapon), "%t", "removedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "blastradiuspen", 20);
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(primary == 772)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_babyface");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "accuracybon", 40);
					Format(stat2, sizeof(stat2), "%t", "boostonhit");
					Format(stat3, sizeof(stat3), "%t", "boostspeed");
					Format(stat4, sizeof(stat4), "%t", "dmgpen", 30);
					Format(stat5, sizeof(stat5), "%t", "movepen", 35);
					Format(stat6, sizeof(stat6), "%t", "boostjump");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", stat5, _);
					AddMenuItem(menu, "", stat6, _);
				}
				else if(primary == 1153)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_panicatk");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "firebon", 30);
					Format(stat2, sizeof(stat2), "%t", "reloadbon", 50);
					Format(stat3, sizeof(stat3), "%t", "autofire");
					Format(stat4, sizeof(stat4), "%t", "dmgvsplayerspen", 20);
					Format(stat5, sizeof(stat5), "%t", "accuracyfell");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", stat5, _);
					AddMenuItem(menu, "", "", _);
				}
			}
			while ((hwear = FindEntityByClassname2(hwear, "tf_wearable")) != -1)
			{
				if(GetEntPropEnt(hwear, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(hwear, Prop_Send, "m_bDisguiseWearable"))
				{
					int index = IsValidEntity(hwear) ? GetEntProp(hwear, Prop_Send, "m_iItemDefinitionIndex") : -1;
					if(index == 133)
					{
						Format(weaponname, sizeof(weaponname), "%t", "wep_gunboats");
						Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
						Format(stat1, sizeof(stat1), "%t", "blastjumpdmgbon", 75);
						AddMenuItem(menu, "", weapon, _);
						AddMenuItem(menu, "", stat1, _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
					}
					else if(index == 405 || index == 608)
					{
						if(index == 405) Format(weaponname, sizeof(weaponname), "%t", "wep_boots1");
						if(index == 608) Format(weaponname, sizeof(weaponname), "%t", "wep_boots2");
						Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
						Format(stat1, sizeof(stat1), "%t", "bootsstat");
						AddMenuItem(menu, "", weapon, _);
						AddMenuItem(menu, "", stat1, _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
					}
				}
			}
			
			while ((hwear = FindEntityByClassname2(hwear, "tf_wearable_demoshield")) != -1)
			{
				if(GetEntPropEnt(hwear, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(hwear, Prop_Send, "m_bDisguiseWearable"))
				{
					int index = IsValidEntity(hwear) ? GetEntProp(hwear, Prop_Send, "m_iItemDefinitionIndex") : -1;
					if(index == 1099)
					{
						Format(weaponname, sizeof(weaponname), "%t", "wep_tideturn");
						Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
						Format(stat1, sizeof(stat1), "%t", "firedmgbon", 25);
						Format(stat2, sizeof(stat2), "%t", "blastdmgbon", 25);
						AddMenuItem(menu, "", weapon, _);
						AddMenuItem(menu, "", stat1, _);
						AddMenuItem(menu, "", stat2, _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
						AddMenuItem(menu, "", "", _);
					}
				}
			}
			
			if(IsValidEntity(hsec) && secondary > -1)
			{
				if(secondary == 46)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_bonk");
					Format(weapon, sizeof(weapon), "%t", "removedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "bonkstat");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(secondary == 163)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_critcola");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "markcolastat");
					Format(stat2, sizeof(stat2), "%t", "speedcolastat");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(secondary == 354)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_conch");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "concheror");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(secondary == 773)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_pbpp");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "maxhealthadd", 15);
					Format(stat2, sizeof(stat2), "%t", "cancelfalldmg");
					Format(stat3, sizeof(stat3), "%t", "firepen", 25);
					Format(stat4, sizeof(stat4), "%t", "firedmgpen", 50);
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(secondary == 812 || secondary == 833)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_cleaver");
					Format(weapon, sizeof(weapon), "%t", "addedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "stuncrits");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(secondary == 1153)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_panicatk");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "firebon", 30);
					Format(stat2, sizeof(stat2), "%t", "reloadbon", 50);
					Format(stat3, sizeof(stat3), "%t", "autofire");
					Format(stat4, sizeof(stat4), "%t", "dmgvsplayerspen", 20);
					Format(stat5, sizeof(stat5), "%t", "accuracyfell");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", stat4, _);
					AddMenuItem(menu, "", stat5, _);
					AddMenuItem(menu, "", "", _);
				}
			}
			if(IsValidEntity(hmel) && melee > -1)
			{
				if(melee == 38 || melee == 457 || melee == 1000)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_axting");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "axtinguisher");
					Format(stat2, sizeof(stat2), "%t", "dmgpenfire", 50);
					Format(stat3, sizeof(stat3), "%t", "norandomcrits");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				if(melee == 44)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_sandman");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "oldstun");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(melee == 239 || melee == 1084 || melee == 1184)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_gru");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "gru");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(melee == 307)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_caber");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "firepenremov");
					Format(stat2, sizeof(stat2), "%t", "switchpenremov");
					Format(stat3, sizeof(stat3), "%t", "caber");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(melee == 426)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_evictnotice");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "evictnotice");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(melee == 450)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_atomizer");
					Format(weapon, sizeof(weapon), "%t", "newstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "atomizer");
					Format(stat2, sizeof(stat2), "%t", "firepen", 30);
					Format(stat3, sizeof(stat3), "%t", "dmgvsplayerspen", 20);
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
				else if(melee == 649)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_spycicle");
					Format(weapon, sizeof(weapon), "%t", "changedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "ciclestat1");
					Format(stat2, sizeof(stat2), "%t", "ciclestat3");
					Format(stat3, sizeof(stat3), "%t", "ciclestat2");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", stat2, _);
					AddMenuItem(menu, "", stat3, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
			}
			if(IsValidEntity(hpda) && hpda > -1)
			{
				if(pda == 59)
				{
					Format(weaponname, sizeof(weaponname), "%t", "wep_deadring");
					Format(weapon, sizeof(weapon), "%t", "removedstats", weaponname);
					Format(stat1, sizeof(stat1), "%t", "deadringermetal");
					AddMenuItem(menu, "", weapon, _);
					AddMenuItem(menu, "", stat1, _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
					AddMenuItem(menu, "", "", _);
				}
			}
			
			SetMenuExitButton(menu, true);
			DisplayMenu(menu, client, 30);
		}
		else CPrintToChat(client, "%t", "nochanges");
	}
	return Plugin_Handled;
}

public int CheckStats_Handler(Handle menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

////////////////////////////////////////////////////
//////////////////////STOCKS////////////////////////
////////////////////////////////////////////////////

void SetGameDescription()
{
	char description[16];
	GetGameDescription(description, sizeof(description));

	if(GetConVarBool(cvarEnabled) && GetConVarBool(cvarGameDesc) && StrEqual(description, "Team Fortress"))
	{
		Format(description, sizeof(description), "Golden Ages v%s", PLUGIN_VERSION);
		Steam_SetGameDescription(description);
	}
	else if((!GetConVarBool(cvarEnabled) || !GetConVarBool(cvarGameDesc)) && StrContains(description, "Golden Ages v") != -1)
	{
		Steam_SetGameDescription("Team Fortress");
	}
}

void ResetVars(int client)
{
	if(chargeTimer[client] != null)
	{
		KillTimer(chargeTimer[client]);
		chargeTimer[client] = null;
	}
	if(conchTimer[client] != null)
	{
		KillTimer(conchTimer[client]);
		conchTimer[client] = null;
	}
	if(colaTimer[client] != null)
	{
		KillTimer(colaTimer[client]);
		colaTimer[client] = null;
		TF2Attrib_SetByName(client, "move speed penalty", 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
	if(icicleTimer[client] != null)
	{
		KillTimer(icicleTimer[client]);
		icicleTimer[client] = null;
	}
	demoCharging[client] = false;
	hypeActivated[client] = false;
	colaEffect[client] = false;
	icicleEffect[client] = false;
	icicleTime[client] = 0;
	TF2Attrib_SetByName(client, "dmg taken from fire reduced", 1.0);
	airDashes[client] = 0;
	lastHype[client] = 0.0;
	lastButtons[client] &= ~IN_JUMP;
}

bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientConnected(client)
	&& !IsFakeClient(client) && IsClientInGame(client)
	&& !GetEntProp(client, Prop_Send, "m_bIsCoaching")
	&& !IsClientSourceTV(client) && !IsClientReplay(client);
}

stock int AttachParticle(int entity, char[] particleType, float offset = 0.0, bool attach = true) //Taken from FF2 default_abilities
{
	char particle = CreateEntityByName("info_particle_system");

	char targetName[128];
	float position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	position[2]+=offset;
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);

	Format(targetName, sizeof(targetName), "target%i", entity);
	DispatchKeyValue(entity, "targetname", targetName);

	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", targetName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(targetName);
	if(attach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", entity);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}

stock Action HealPlayer(int client, int amount)
{
	Handle healevent = CreateEvent("player_healonhit", true);
	SetEventInt(healevent, "entindex", client);
	SetEventInt(healevent, "amount", amount);
	FireEvent(healevent);
}

stock Action DealDamage(int victim, int damage, int attacker=0, int dmg_type, char[] weapon = "")	//Thanks to pimpinjuice
{
	if (IsValidClient(victim) && IsPlayerAlive(victim) && damage > 0)
	{
		char dmg_str[16];
		IntToString(damage, dmg_str, sizeof(dmg_str));
		char dmg_type_str[32];
		IntToString(dmg_type, dmg_type_str, sizeof(dmg_type_str));
		char pointHurt = CreateEntityByName("point_hurt");
		if (IsValidEntity(pointHurt))
		{
			char target[32];
			Format(target, sizeof(target), "pointhurtvictim%d", victim);
			DispatchKeyValue(victim, "targetname", target);
			DispatchKeyValue(pointHurt, "DamageTarget", target);
			DispatchKeyValue(pointHurt, "Damage", dmg_str);
			DispatchKeyValue(pointHurt, "DamageType", dmg_type_str);
			if (!StrEqual(weapon, ""))
			{
				DispatchKeyValue(pointHurt, "classname", weapon);
			}
			DispatchSpawn(pointHurt);
			AcceptEntityInput(pointHurt, "Hurt", (attacker > 0 ? attacker : -1));
			DispatchKeyValue(pointHurt, "classname", "point_hurt");
			DispatchKeyValue(victim, "targetname", "notpointhurtvictim");
			AcceptEntityInput(pointHurt, "Kill");
		}
	}
}

stock float GetConditionDuration(int client, TFCond cond)
{
	int m_Shared = FindSendPropInfo("CTFPlayer", "m_Shared");
	
	Address aCondSource   = view_as< Address >(ReadInt(GetEntityAddress(client) + view_as< Address >(m_Shared + 8)));
	Address aCondDuration = view_as< Address >(view_as< int >(aCondSource) + (view_as< int >(cond) * 20) + (2 * 4));
	
	float flDuration = 0.0;
	if(TF2_IsPlayerInCondition(client, cond))
	{
		flDuration = view_as<float>(ReadInt(aCondDuration));
	}
	
	return flDuration;
}

stock int ReadInt(Address address)
{
	return LoadFromAddress(address, NumberType_Int32);
}

stock int FindEntityByClassname2(int startEnt, const char[] classname)
{
	while(startEnt > -1 && !IsValidEntity(startEnt))
	{
		startEnt--;
	}
	return FindEntityByClassname(startEnt, classname);
}

////////////////////////////////////////////////////
//////////////////////TIMERS////////////////////////
////////////////////////////////////////////////////

public Action Timer_NoticeCommand(Handle hTimer)
{
	if(!GetConVarBool(cvarEnabled))
	{
		return Plugin_Stop;
	}
	SetGameDescription();
	CPrintToChatAll("%t", "advertise");
	return Plugin_Continue;
}

public Action Timer_ColaTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
	{
		colaTimer[client] = null;
		return Plugin_Stop;
	}
	
	colaEffect[client] = false;
	TF2Attrib_SetByName(client, "move speed penalty", 1.0);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
	return Plugin_Continue;
}

public Action Timer_IcicleTimer(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	int melee = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	
	if(!IsValidClient(client) || !IsValidEntity(melee) || GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") != 649)
	{
		icicleTimer[client] = null;
		return Plugin_Stop;
	}
	
	icicleEffect[client] = false;
	TF2Attrib_SetByName(client, "dmg taken from fire reduced", 1.0);
	KillTimer(icicleTimer[client]);
	icicleTimer[client] = null;
	return Plugin_Continue;
}

public Action Timer_Bonk(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !TF2_IsPlayerInCondition(client, TFCond_Dazed))
	{
		return Plugin_Stop;
	}
	
	TF2_RemoveCondition(client, TFCond_Dazed);
	return Plugin_Continue;
}

public Action Timer_ChargeCrit(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !TF2_IsPlayerInCondition(client, TFCond_CritDemoCharge))
	{
		chargeTimer[client] = null;
		demoCharging[client] = false;
		return Plugin_Stop;
	}
	
	demoCharging[client] = true;
	return Plugin_Continue;
}

public Action Timer_ConchHeal(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client))
	{
		conchTimer[client] = null;
		return Plugin_Stop;
	}
	
	int health = GetClientHealth(client);
	int maxhealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	if(health < maxhealth)
	{
		if(health + 2 <= maxhealth)
		{
			SetEntityHealth(client, health + 2);
			HealPlayer(client, 2);
		}
		else
		{
			SetEntityHealth(client, maxhealth);
			HealPlayer(client, 1);
		}
	}
	return Plugin_Continue;
}

public Action Timer_DetectCharge(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client) || !TF2_IsPlayerInCondition(client, TFCond_CritDemoCharge))
	{
		chargeTimer[client] = null;
		demoCharging[client] = false;
		return Plugin_Stop;
	}
	
	demoCharging[client] = false;
	return Plugin_Continue;
}

public Action Timer_StartHook(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if(IsValidClient(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public Action Timer_SandmanTimer(Handle timer, Handle datapack) //Taken from FF2 default_abilities
{
	float distance;
	int client, attacker, damagetype;
	
	ResetPack(datapack);
	distance = ReadPackFloat(datapack);
	client = ReadPackCell(datapack);
	attacker = ReadPackCell(datapack);
	damagetype = ReadPackCell(datapack);
	
	if(distance >= 256.0 && distance < 1792.0)
	{
		if(damagetype & DMG_CRIT)
		{
			TF2_StunPlayer(client, (distance / 256.0) + 2.0, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
			CreateTimer((distance / 256.0) + 2.0, Timer_StarsRemove, EntIndexToEntRef(AttachParticle(client, "conc_stars", 80.0)), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			TF2_StunPlayer(client, distance / 256.0, 0.0, TF_STUNFLAGS_SMALLBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
			CreateTimer(distance / 256.0, Timer_StarsRemove, EntIndexToEntRef(AttachParticle(client, "conc_stars", 80.0)), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if(distance >= 1792.0)
	{
		if(damagetype & DMG_CRIT)
		{
			TF2_StunPlayer(client, 9.0, 0.0, TF_STUNFLAGS_BIGBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
			CreateTimer(9.0, Timer_StarsRemove, EntIndexToEntRef(AttachParticle(client, "conc_stars", 80.0)), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			TF2_StunPlayer(client, 7.0, 0.0, TF_STUNFLAGS_BIGBONK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker);
			CreateTimer(7.0, Timer_StarsRemove, EntIndexToEntRef(AttachParticle(client, "conc_stars", 80.0)), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action Timer_StarsRemove(Handle timer, any entid) //Taken from FF2 default_abilities
{
	int entity = EntRefToEntIndex(entid);
	if(IsValidEntity(entity) && entity > MaxClients)
	{
		AcceptEntityInput(entity, "Kill");
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!GetConVarBool(cvarEnabled) || !IsValidClient(client) || !IsValidClient(attacker))
	{
		return Plugin_Continue;
	}
	
	if(damagecustom == TF_CUSTOM_CLEAVER)
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Dazed))
		{
			damagetype|=DMG_CRIT;
			return Plugin_Changed;
		}
	}
	
	int melee = GetPlayerWeaponSlot(attacker, TFWeaponSlot_Melee);
	if(IsValidEntity(melee) && damagecustom == TF_CUSTOM_BASEBALL && !TF2_IsPlayerInCondition(client, TFCond_Ubercharged) && client != attacker && GetEntProp(melee, Prop_Send, "m_iItemDefinitionIndex") == 44) //Old Sandman Stun
	{
		TF2_RemoveCondition(client, TFCond_Dazed);
		float attackerPosition[3], victimPosition[3];
		GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", attackerPosition);
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", victimPosition);
		float distance = GetVectorDistance(attackerPosition, victimPosition);
		
		
		Handle datapack; 
		CreateDataTimer(0.01, Timer_SandmanTimer, datapack);
		WritePackFloat(datapack, distance);
		WritePackCell(datapack, client);
		WritePackCell(datapack, attacker);
		WritePackCell(datapack, damagetype);
	}
	
	int shield = MaxClients+1;
	while((shield = FindEntityByClassname2(shield, "tf_wearable_demoshield")) != -1)
	{
		int idx = GetEntProp(shield, Prop_Send, "m_iItemDefinitionIndex");
		if (IsValidEntity(melee) && melee > -1 && (idx == 1099) && GetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity") == attacker && !GetEntProp(shield, Prop_Send, "m_bDisguiseWearable") && demoCharging[attacker])
		{
			if(GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon") == melee && damagecustom != TF_CUSTOM_BLEEDING && damagecustom != TF_CUSTOM_BURNING && damagecustom != TF_CUSTOM_BURNING_ARROW && damagecustom != TF_CUSTOM_BURNING_FLARE && damagecustom != TF_CUSTOM_CHARGE_IMPACT)
			{
				damagetype|=DMG_CRIT;
				demoCharging[client] = false;
				return Plugin_Changed;
			}
		}
	}
	
	int activeWep = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(activeWep) && GetEntProp(activeWep, Prop_Send, "m_iItemDefinitionIndex") == 230)
	{
		if((damagetype & DMG_CRIT) && !(TF2_IsPlayerInCondition(attacker, TFCond_Kritzkrieged) ||
		TF2_IsPlayerInCondition(attacker, TFCond_HalloweenCritCandy) ||
		TF2_IsPlayerInCondition(attacker, TFCond_CritCanteen) ||
		TF2_IsPlayerInCondition(attacker, TFCond_CritOnWin) ||
		TF2_IsPlayerInCondition(attacker, TFCond_CritOnFlagCapture) ||
		TF2_IsPlayerInCondition(attacker, TFCond_CritOnKill)))
		{
			damagetype &= ~DMG_CRIT;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}