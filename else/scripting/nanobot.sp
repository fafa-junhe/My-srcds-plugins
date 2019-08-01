/* ===================================
*				Heading
* ==================================== */
#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tf2>
#undef REQUIRE_PLUGIN
#include <updater>
#include <juggernaut>

#define UPDATE_URL "https://gitlab.com/nanochip/nanobot/raw/master/updatefile.txt"

/* ===================================
*			Initialize Variables
* ==================================== */

#define ResizeType_Generic  0
#define ResizeType_Head     1
#define ResizeType_Torso    2
#define ResizeType_Hands     3
#define ResizeTypes         4

// cvars
new Handle:cvarEnable, Handle:cvarBarrier, Handle:cvarBotName, Handle:cvarVictoryDeflects, Handle:cvarModel, Handle:cvarGodMode, Handle:cvarVoteMode, Handle:cvarVoteTime, Handle:cvarVoteTimeDelay, Handle:cvarVotePercentage, Handle:cvarVictorySpeed, Handle:cvarMinPlayers, Handle:cvarMaxPlayers, Handle:cvarBotSize, Handle:cvarHandSize, Handle:cvarTorsoSize, Handle:cvarHeadSize, Handle:cvarBotSpeech;

// plugin logic
new bool:NanobotEnabled = false; // check if the mode is actually enabled
new bool:allowed[MAXPLAYERS+1] = {false, ...}; // aka autoreflect
new bool:MapChanged; // check if the map changed
new bool:commandEnable; // check if we can use the nanobot command
new bool:commandDisable; // ^
new bool:canSlap[MAXPLAYERS+1] = {true, ...};
new bool:canMsg[MAXPLAYERS+1] = {true,...};

// pvb vote settings
new nVoters = 0; // see how many players can vote
new nVotes = 0; // how many votes we have recieved
new nVotesNeeded = 0; // how many votes we need
new bool:bVoted[MAXPLAYERS+1] = {false, ...}; // check which players have voted
new bool:AllowedVote; // check if we can vote

new victoryType = 0;
new bool:canTrackSpeed = false;
new rocketDeflects = 0;
new rocketSpeed = 0; // speed of the rocket
new String:botName[MAX_NAME_LENGTH]; // name of the bot
new Handle:speechPlayerDeathArray = INVALID_HANDLE;
new Handle:speechBotDeathArray = INVALID_HANDLE;
new String:speechBotDeathPath[PLATFORM_MAX_PATH];
new String:speechPlayerDeathPath[PLATFORM_MAX_PATH];

new Float:botSize;
new Float:headSize;
new Float:torsoSize;
new Float:handSize;
new bool:g_bHitboxAvailable = false;
new Float:g_fClientCurrentScale[ResizeTypes][MAXPLAYERS+1];
new bool:botSpeech;
bool juggernaut = false;
bool JuggernautRound = false;

/* ===================================
*			Plugin Information
* ==================================== */
#define PLUGIN_VERSION	"2.0"

public Plugin:myinfo = {
	name		= "Nanobot (Dodgeball Bot)",
	author		= "Nanochip",
	description= "Play dodgeball against a bot!",
	version	= PLUGIN_VERSION,
	url			= "https://forums.alliedmods.net/showthread.php?p=2286346"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("NB_NanobotEnabled", Native_NanobotEnabled);
	RegPluginLibrary("nanobot");
	
	return APLRes_Success;
}

public int Native_NanobotEnabled(Handle plugin, int numParams)
{
	return NanobotEnabled;
}

/* ===================================
*			Start the Awesomeness
* ==================================== */
public OnPluginStart()
{
	// check if the server has updater
	if (LibraryExists("updater")) Updater_AddPlugin(UPDATE_URL);
	
	// generic translations
	LoadTranslations("common.phrases");
	
	// Create some server console variables for the plugin
	CreateConVar("sm_nanobot_version", PLUGIN_VERSION, "Nanobot Version", FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvarEnable = CreateConVar("sm_nanobot_enable", "1", "Enable the plugin? 1 = Yes, 0 = No.", 0, true, 0.0, true, 1.0);
	cvarBarrier = CreateConVar("sm_nanobot_push", "2", "Barrier for the bot. 0 = No barrier, 1 = The bot will airblast players away from it, 2 = Slap player away from the bot (deducting 20 health each slap).", 0, true, 0.0, true, 2.0);
	cvarBotName = CreateConVar("sm_nanobot_name", "Nanobot", "What should the name of the bot be?", 0);
	cvarModel = CreateConVar("sm_nanobot_model", "models/bots/pyro/bot_pyro.mdl", "What model should the bot have? Default: Pyro Robot (models/bots/pyro/bot_pyro.mdl). Leave this CVAR blank if you do not want a custom model.", 0);
	cvarVoteMode = CreateConVar("sm_nanobot_vote_mode", "3", "Player vs Bot voting. 0 = No voting, 1 = Generic chat vote, 2 = Menu vote, 3 = Both (Generic chat first, then Menu vote).", 0, true, 0.0, true, 3.0);
	cvarVoteTime = CreateConVar("sm_nanobot_vote_time", "25.0", "Time in seconds the vote menu should last.", 0);
	cvarVoteTimeDelay = CreateConVar("sm_nanobot_vote_delay", "60.0", "Time in seconds before players can initiate another PvB vote.", 0);
	cvarVotePercentage = CreateConVar("sm_nanobot_vote_percentage", "0.60", "How many players are required for the vote to pass? 0.60 = 60%.", 0, true, 0.05, true, 1.0);
	cvarMinPlayers = CreateConVar("sm_nanobot_minplayers", "1", "When there are a minimum of X amount of players or less, enable Nanobot. 0 = No Enable, 1 = Enables at 1 player... 10 = Enables at 10 players.", 0);
	cvarMaxPlayers = CreateConVar("sm_nanobot_maxplayers", "2", "When there are a maximum of X amount of players or more, Nanobot will disable. 0 = No disable, 2 = Disables at 2 players... 10 = Disables at 10 players.", 0);
	cvarVictorySpeed = CreateConVar("sm_nanobot_victory_speed", "450", "When the rocket reaches greater than or equal to this speed, in MPH, Nanobot will not deflect the rocket and the other team wins. Put this value to 0 if you do not want Nanobot to lose (unbeatable...ish).", 0);
	cvarVictoryDeflects = CreateConVar("sm_nanobot_victory_deflects", "60", "When the total number of deflects reaches greater than or equal to this number, Nanobot will not deflect the rocket and the other team wins. Put this value to 0 if you do not want Nanobot to lose (unbeatable...ish).", 0);
	cvarBotSize = CreateConVar("sm_nanobot_size", "1.0", "What should be the model size of the bot? 1.0 = Normal size, 2.0 = 2x the normal size, 0.5 = Half the normal size.", 0, true, 0.01);
	botSize = GetConVarFloat(cvarBotSize);
	cvarHandSize = CreateConVar("sm_nanobot_size_hand", "1.0", "What should be the size of the bot's hands? 1.0 = Normal size, 2.0 = 2x the normal size, 0.5 = Half the normal size.", 0, true, 0.01);
	handSize = GetConVarFloat(cvarHandSize);
	cvarTorsoSize = CreateConVar("sm_nanobot_size_torso", "1.0", "What should be the size of the bot's torso? 1.0 = Normal size, 2.0 = 2x the normal size, 0.5 = Half the normal size.", 0, true, 0.01);
	torsoSize = GetConVarFloat(cvarTorsoSize);
	cvarHeadSize = CreateConVar("sm_nanobot_size_head", "1.0", "What should be the size of the bot's head? 1.0 = Normal size, 2.0 = 2x the normal size, 0.5 = Half the normal size.", 0, true, 0.01);
	headSize = GetConVarFloat(cvarHeadSize);
	cvarBotSpeech = CreateConVar("sm_nanobot_speech", "1", "Should Nanobot antagonize the players when they die? 1 = Yes, 0 = No", 0, true, 0.0, true, 1.0);
	if (GetConVarInt(cvarBotSpeech) == 1) botSpeech = true;
	else botSpeech = false;
	cvarGodMode = CreateConVar("sm_nanobot_godmode", "0", "Should Nanobot have godmode? Note that godmode will be revoked when victory speed is reached causing Nanobot to die. 0 = No, 1 = Yes.", 0, true, 0.0, true, 1.0);
	
	// add some commands for admins and users
	RegAdminCmd("sm_nanobot", Nanobot_Cmd, ADMFLAG_RCON, "Force enable/disable PvB.");
	RegAdminCmd("sm_pvb", Nanobot_Cmd, ADMFLAG_RCON, "Force enable/disable PvB.");
	RegAdminCmd("sm_autoreflect", AutoReflect_Cmd, ADMFLAG_CHEATS, "Assign auto reflect on a player.");
	RegAdminCmd("sm_reloadspeech", ReloadSpeech_Cmd, ADMFLAG_CONFIG, "Reload the speeches.");
	RegConsoleCmd("sm_votepvb", VotePvB_Cmd, "Vote to enable/disable PvB");
	
	// create the nanobot config (tf/cfg/sourcemod/Nanobot.cfg)
	AutoExecConfig(true, "Nanobot");
	
	// hook some game events
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	// hook cvar changes
	HookConVarChange(cvarBotName, CvarChanged_BotName);
	HookConVarChange(cvarBotSize, CvarChanged_BotSize);
	HookConVarChange(cvarHeadSize, CvarChanged_HeadSize);
	HookConVarChange(cvarHandSize, CvarChanged_HandSize);
	HookConVarChange(cvarTorsoSize, CvarChanged_TorsoSize);
	HookConVarChange(cvarBotSpeech, CvarChanged_BotSpeech);
	
	// set the bot's name
	GetConVarString(cvarBotName, botName, sizeof(botName));
	
	// Set the hitbox info
	g_bHitboxAvailable = ((FindSendPropOffs("CBasePlayer", "m_vecSpecifiedSurroundingMins") != -1) && FindSendPropOffs("CBasePlayer", "m_vecSpecifiedSurroundingMaxs") != -1);
	
	// Set player scales
	for (new i = 0; i < sizeof(g_fClientCurrentScale); i++)
	{
		for (new j = 0; j < sizeof(g_fClientCurrentScale[]); j++)
		{
			g_fClientCurrentScale[i][j] = 1.0;
		}
	}
	
	speechBotDeathArray = CreateArray(256);
	speechPlayerDeathArray = CreateArray(256);
	BuildPath(Path_SM, speechBotDeathPath, sizeof(speechBotDeathPath), "configs/speech_botdeath.txt");
	BuildPath(Path_SM, speechPlayerDeathPath, sizeof(speechPlayerDeathPath), "configs/speech_playerdeath.txt");
	if (!FileExists(speechBotDeathPath)) LogError("[Nanobot] ERROR! speech_botdeath.txt does not exist in %s!", speechBotDeathPath);
	if (!FileExists(speechPlayerDeathPath)) LogError("[Nanobot] ERROR! speech_playerdeath.txt does not exist in %s!", speechPlayerDeathPath);
	LoadSpeeches();
}

LoadSpeeches()
{
	decl String:lineBuf[1024];
	new Handle:speechBotDeath = OpenFile(speechBotDeathPath, "r");
	ClearArray(speechBotDeathArray);
	while(ReadFileLine(speechBotDeath, lineBuf, sizeof(lineBuf)))
	{
		ReplaceString(lineBuf, sizeof(lineBuf), "\n", "", false);
		PushArrayString(speechBotDeathArray, lineBuf);
	}
	CloseHandle(speechBotDeath);
	
	new Handle:speechPlayerDeath = OpenFile(speechPlayerDeathPath, "r");
	ClearArray(speechPlayerDeathArray);
	while(ReadFileLine(speechPlayerDeath, lineBuf, sizeof(lineBuf)))
	{
		ReplaceString(lineBuf, sizeof(lineBuf), "\n", "", false);
		PushArrayString(speechPlayerDeathArray, lineBuf);
	}
	CloseHandle(speechPlayerDeath);
}

public OnLibraryAdded(const String:name[])
{
	if (StrEqual(name, "updater")) Updater_AddPlugin(UPDATE_URL);
	if (StrEqual(name, "juggernaut"))
	{
		LogAction(0, -1, "Detected Juggernaut");
		juggernaut = true;
	}
}

public OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "juggernaut")) juggernaut = false;
}

public Updater_OnPluginUpdated()
{
	PrintToServer("[Nanobot] Successfully updated. This is a sexy update, I swear.");
	ReloadPlugin();
}

/* ===================================
*			ConVar Changes
* ==================================== */
public CvarChanged_BotName(Handle:convar, const String:oldValue[], const String:newValue[])
{
	Format(botName, sizeof(botName), "%s", newValue);
}

public CvarChanged_BotSize(Handle:convar, const String:oldValue[], const String:newValue[])
{
	botSize = StringToFloat(newValue);
}

public CvarChanged_HeadSize(Handle:convar, const String:oldValue[], const String:newValue[])
{
	headSize = StringToFloat(newValue);
}

public CvarChanged_HandSize(Handle:convar, const String:oldValue[], const String:newValue[])
{
	handSize = StringToFloat(newValue);
}

public CvarChanged_TorsoSize(Handle:convar, const String:oldValue[], const String:newValue[])
{
	torsoSize = StringToFloat(newValue);
}

public CvarChanged_BotSpeech(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (StrEqual(newValue, "1")) botSpeech = true;
	else botSpeech = false;
}

/* ===================================
*				Commands
* ==================================== */
public Action:ReloadSpeech_Cmd(client, args)
{
	LoadSpeeches();
	ReplyToCommand(client, "[SM] Bot speeches have been reloaded.");
	return Plugin_Handled;
}

public Action:VotePvB_Cmd(client, args)
{
	if (!GetConVarBool(cvarEnable) || GetConVarInt(cvarVoteMode) == 0) return Plugin_Handled;
	//check which vote mode we can do
	if (GetConVarInt(cvarVoteMode) != 2) AttemptPvBVotes(client);
	else
	{
		PvBVoteMenu();
	}
	return Plugin_Handled;
}

// this adds the ability to use commands without ! or /
public OnClientSayCommand_Post(client, const String:command[], const String:sArgs[])
{
	if (!GetConVarBool(cvarEnable) || GetConVarInt(cvarVoteMode) == 0) return;
	if (strcmp(sArgs, "votepvb", false) == 0 || strcmp(sArgs, "vpvb", false) == 0)
	{
		new ReplySource:old = SetCmdReplySource(SM_REPLY_TO_CHAT);
		
		
		if (GetConVarInt(cvarVoteMode) != 2) AttemptPvBVotes(client);
		else
		{
			PvBVoteMenu();
		}
		
		SetCmdReplySource(old);
	}
}

// auto reflect :D
public Action:AutoReflect_Cmd(client, args)
{
	if (!GetConVarBool(cvarEnable)) return Plugin_Handled;
	if (args < 1)
	{		
		if (!allowed[client]) 
		{
			allowed[client] = true;
			ReplyToCommand(client, "\x01[\x03%s\x01]\x04 Enabled auto reflect on yourself.", botName);
		} else {
			allowed[client] = false;
			ReplyToCommand(client, "\x01[\x03%s\x01]\x04 Disabled auto reflect on yourself.", botName);
		}
		return Plugin_Handled;
	}
	
	new String:tempName[MAX_NAME_LENGTH], String:name[MAX_NAME_LENGTH];
	GetCmdArg(1, tempName, sizeof(tempName));
	
	new target = FindTarget(client, tempName, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	GetClientName(target, name, sizeof(name));
	
	if (!allowed[target])
	{
		allowed[target] = true;
		ReplyToCommand(client, "\x01[\x03%s\x01]\x04 Enabled auto reflect on %s.", botName, name);
	} else {
		ReplyToCommand(client, "\x01[\x03%s\x01]\x04 Disabled auto reflect on %s.", botName, name);
		allowed[target] = false;
	}
	return Plugin_Handled;
}

public Action:Nanobot_Cmd(client, args)
{
	if (!GetConVarBool(cvarEnable)) return Plugin_Handled;
	if (!NanobotEnabled) 
	{
		if (juggernaut && JuggernautRound)
		{
			ReplyToCommand(client, "[SM] Sorry, you may not force Player vs. Bot mode while it's a juggernaut round.");
			return Plugin_Handled;
		}
		EnableNanobot();
		commandEnable = true;
		commandDisable = false;
	}
	else 
	{
		DisableNanobot();
		ServerCommand("mp_scrambleteams");
		commandDisable = true;
		commandEnable = false;
	}
	return Plugin_Handled;
}

EnableNanobot()
{
	ServerCommand("mp_autoteambalance 0");
	ServerCommand("tf_bot_add 1 Pyro blue easy \"%s\"", botName);
	ServerCommand("tf_bot_difficulty 0");
	ServerCommand("tf_bot_keep_class_after_death 1");
	ServerCommand("tf_bot_taunt_victim_chance 0");
	ServerCommand("tf_bot_join_after_player 0");
	/*ServerCommand("sv_cheats 1");
	ServerCommand("bot -team blue -class Pyro -name \"%s\"", botName);
	ServerCommand("bot_dontmove 1");
	ServerCommand("sm_cvar tf_dropped_weapon_lifetime 0");
	ServerCommand("sv_cheats 0");
	ServerCommand("sm_cvar tf_flamethrower_burstammo 0");*/
	PrintToChatAll("\x01[\x03%s\x01]\x04 PvB Enabled.", botName);
	NanobotEnabled = true;
}

DisableNanobot(bool autobalance = true)
{
	if (autobalance) ServerCommand("mp_autoteambalance 1");
	ServerCommand("tf_bot_kick all");
	/*ServerCommand("sv_cheats 1");
	ServerCommand("bot_kick all");
	ServerCommand("sv_cheats 0");
	ServerCommand("sm_cvar tf_dropped_weapon_lifetime 0");
	ServerCommand("sm_cvar tf_flamethrower_burstammo 0");*/
	PrintToChatAll("\x01[\x03%s\x01]\x04 PvB Disabled.", botName);
	NanobotEnabled = false;
}

/* ===================================
*				Events
* ==================================== */
public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvarEnable)) return;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (IsClientBot(client)) ForceRedWin();
	if (IsClientBot(client) && attacker > 0 && attacker != client)
	{
		if (victoryType == 1)
		{
			PrintToChatAll("\x01[\x03%s\x01]\x04 %N has beaten %s by getting up to %d deflects!", botName, attacker, botName, rocketDeflects);
			victoryType = 0;
		}
		if (victoryType == 2)
		{
			PrintToChatAll("\x01[\x03%s\x01]\x04 %N has beaten %s by getting up to %d MPH!", botName, attacker, botName, rocketSpeed);
			victoryType = 0;
		}
		
		if (botSpeech)
		{
			new rand = GetRandomInt(0, GetArraySize(speechBotDeathArray)-1);
			char speech[1024];
			GetArrayString(speechBotDeathArray, rand, speech, sizeof(speech));
			char deflects[5];
			IntToString(rocketDeflects, deflects, sizeof(deflects));
			ReplaceString(speech, sizeof(speech), "#deflects", deflects);
			char playerName[32];
			GetClientName(attacker, playerName, sizeof(playerName));
			ReplaceString(speech, sizeof(speech), "#playername", playerName);
			Format(speech, sizeof(speech), "say \"%s\"", speech);
			FakeClientCommandEx(client, speech);
		}
	}
	if (botSpeech && IsClientBot(attacker) && attacker != client)
	{
		if (GetRandomInt(1, 2) == 1) return;
		new rand = GetRandomInt(0, GetArraySize(speechPlayerDeathArray)-1);
		char speech[1024];
		GetArrayString(speechPlayerDeathArray, rand, speech, sizeof(speech));
		char deflects[5];
		IntToString(rocketDeflects, deflects, sizeof(deflects));
		ReplaceString(speech, sizeof(speech), "#deflects", deflects);
		char playerName[32];
		GetClientName(client, playerName, sizeof(playerName));
		ReplaceString(speech, sizeof(speech), "#playername", playerName);
		Format(speech, sizeof(speech), "say \"%s\"", speech);
		FakeClientCommandEx(attacker, speech);
	}
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvarEnable)) return;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsClientBot(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", botSize);
		if (g_bHitboxAvailable) UpdatePlayerHitbox(client);
		
		//Godmode
		if (GetConVarBool(cvarGodMode)) SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	}
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(cvarEnable)) return;
	
	if (JuggernautRound)
	{
		JuggernautRound = false;
		PrintToChatAll("\x01[\x03%s\x01]\x04 Juggernaut round over, re-enabling Player vs. Bot mode...", botName);
		EnableNanobot();
	}
	
	if (juggernaut && NanobotEnabled)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (GetJuggernautUserId(i) != -1)
			{
				PrintToChatAll("\x01[\x03%s\x01]\x04 Detected Juggernaut round, disabling Player vs. Bot...", botName);
				JuggernautRound = true;
				DisableNanobot(false);
			}
		}
	}
}
public OnMapEnd()
{
	if (!GetConVarBool(cvarEnable)) return;
	MapChanged = true;
	JuggernautRound = false;
}

public OnClientConnected(client)
{
	if (!GetConVarBool(cvarEnable)) return;
	if (IsFakeClient(client)) return;
	
	bVoted[client] = false;
	nVoters++;
	nVotesNeeded = RoundToFloor(float(nVoters) * GetConVarFloat(cvarVotePercentage));
}

public OnClientDisconnect(client)
{
	if (!GetConVarBool(cvarEnable)) return;
	if (IsFakeClient(client)) return;
	if (allowed[client]) allowed[client] = false;
	
	if (bVoted[client]) nVotes--;
	nVoters--;
	nVotesNeeded = RoundToFloor(float(nVoters) * GetConVarFloat(cvarVotePercentage));
	for (int i = 0; i < MAXPLAYERS + 1; i++)
	{
		canSlap[i] = true;
		canMsg[i] = true;
	}
}

AttemptPvBVotes(client)
{
	if (!GetConVarBool(cvarEnable)) return;
	
	if (!AllowedVote)
	{
		ReplyToCommand(client, "\x01[\x03%s\x01]\x04 Sorry, voting for Player vs Bot is currently on cool-down.", botName);
		return;
	}
	
	if (juggernaut && JuggernautRound)
	{
		ReplyToCommand(client, "[SM] Sorry, you may not vote for Player vs. Bot mode while it's a juggernaut round.");
		return;
	}
	
	if (bVoted[client])
	{
		ReplyToCommand(client, "\x01[\x03%s\x01]\x04 You have already voted.", botName);
		return;
	}
	
	new String:name[MAX_NAME_LENGTH];
	GetClientName(client, name, sizeof(name));
	
	nVotes++;
	bVoted[client] = true;
	if (!NanobotEnabled)
	{
		PrintToChatAll("\x01[\x03%s\x01]\x04 %s wants to enable Player vs Bot. (%d votes, %d required)", botName, name, nVotes, nVotesNeeded);
	} else {
		PrintToChatAll("\x01[\x03%s\x01]\x04 %s wants to disable Player vs Bot. (%d votes, %d required)", botName, name, nVotes, nVotesNeeded);
	}
	
	if (nVotes >= nVotesNeeded)
	{
		StartPvBVotes();
	}
}

StartPvBVotes()
{
	if (GetConVarInt(cvarVoteMode) == 1)
	{
		if (!NanobotEnabled)
		{
			PrintToChatAll("\x01[\x03%s\x01]\x04 Enabling Player vs Bot...", botName);
			EnableNanobot();
			commandEnable = true;
			commandDisable = false;
		} else {
			PrintToChatAll("\x01[\x03%s\x01]\x04 Disabling Player vs Bot...", botName);
			DisableNanobot();
			commandDisable = true;
			commandEnable = false;
			ServerCommand("mp_scrambleteams");
		}
	}
	if (GetConVarInt(cvarVoteMode) == 3)
	{
		PvBVoteMenu();
	}
	ResetPvBVotes();
	AllowedVote = false;
	CreateTimer(GetConVarFloat(cvarVoteTimeDelay), Timer_Delay, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_Delay(Handle:timer)
{
	AllowedVote = true;
}

PvBVoteMenu()
{
	if (IsVoteInProgress()) return;
	if (GetConVarInt(cvarVoteMode) == 2)
	{
		AllowedVote = false;
		CreateTimer(GetConVarFloat(cvarVoteTimeDelay), Timer_Delay, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	new Handle:vm = CreateMenu(PvBVoteMenuHandler, MenuAction:MENU_ACTIONS_ALL);
	SetVoteResultCallback(vm, Handle_VoteResults);
	if (!NanobotEnabled)
	{
		SetMenuTitle(vm, "Enable Player vs Bot?");
		AddMenuItem(vm, "yes", "Yes");
		AddMenuItem(vm, "no", "No");
	} else {
		SetMenuTitle(vm, "Disable Player vs Bot?");
		AddMenuItem(vm, "yes", "Yes");
		AddMenuItem(vm, "no", "No");
	}
	SetMenuExitButton(vm, false);
	VoteMenuToAll(vm, GetConVarInt(cvarVoteTime));
}

public Handle_VoteResults(Handle:menu, num_votes, num_clients, const client_info[][2], num_items, const item_info[][2])
{
	new winner = 0;
	if (num_items > 1
	    && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
	{
		winner = GetRandomInt(0, 1);
	}
	
	new String:winInfo[32];
	GetMenuItem(menu, item_info[winner][VOTEINFO_ITEM_INDEX], winInfo, sizeof(winInfo));
	
	if (!NanobotEnabled)
	{
		if (StrEqual(winInfo, "yes"))
		{
			PrintToChatAll("\x01[\x03%s\x01]\x04 Majority voted \"Yes\", enabling Player vs Bot...", botName);
			EnableNanobot();
			commandEnable = true;
			commandDisable = false;
		} else {
			PrintToChatAll("\x01[\x03%s\x01]\x04 Majority voted \"No\", aborted operation.", botName);
		}
	} else {
		if (StrEqual(winInfo, "yes"))
		{
			PrintToChatAll("\x01[\x03%s\x01]\x04 Majority voted \"Yes\", disabling Player vs Bot...", botName);
			DisableNanobot();
			commandDisable = true;
			commandEnable = false;
			ServerCommand("mp_scrambleteams");
		} else {
			PrintToChatAll("\x01[\x03%s\x01]\x04 Majority voted \"No\", aborted operation.", botName);
		}
	}
	
}

public PvBVoteMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_End) CloseHandle(menu);
}

ResetPvBVotes()
{
	nVotes = 0;
	for (new i = 1; i <= MAXPLAYERS; i++) bVoted[i] = false;
}

public OnMapStart()
{
	if (!GetConVarBool(cvarEnable)) return;
	
	nVoters = 0;
	nVotesNeeded = 0;
	nVotes = 0;
	AllowedVote = true;
	commandEnable = false;
	commandDisable = false;
	
	decl String:mdl[PLATFORM_MAX_PATH];
	GetConVarString(cvarModel, mdl, sizeof(mdl));
	if (!StrEqual(mdl, ""))
	{
		PrecacheModel(mdl, true);
		AddFileToDownloadsTable(mdl);
	}
	
	CreateTimer(5.0, Timer_MapStart);
}

public Action:Timer_MapStart(Handle:timer)
{
	MapChanged = false;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!GetConVarBool(cvarEnable) || !IsPlayerAlive(client)) return Plugin_Continue;
	
	if ((NanobotEnabled && IsClientBot(client)) || allowed[client])
	{
		new rocket = INVALID_ENT_REFERENCE;
		//new ent = INVALID_ENT_REFERENCE;
		
		decl Float:fClientEyePosition[3];
		GetClientEyePosition(client, fClientEyePosition);
		new iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (!IsValidEntity(iWeapon)) return Plugin_Continue;
		
		// Rocket handling.
		while ((rocket = FindEntityByClassname(rocket, "tf_projectile_*")) != INVALID_ENT_REFERENCE)
		{
			decl Float:entityLocation[3];
			GetEntPropVector(rocket, Prop_Data,"m_vecOrigin",entityLocation);
			
			// Rocket speed var.
			if (GetConVarInt(cvarVictorySpeed) != 0 && rocketSpeed >= GetConVarInt(cvarVictorySpeed) && !allowed[client])
			{
				if (GetConVarBool(cvarGodMode)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				victoryType = 2;
				return Plugin_Continue;
			}
			
			if (GetConVarInt(cvarVictoryDeflects) != 0 && rocketDeflects >= GetConVarInt(cvarVictoryDeflects) && !allowed[client])
			{
				if (GetConVarBool(cvarGodMode)) SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				victoryType = 1;
				return Plugin_Continue;
			}
			
			decl Float:pos[3];
			GetClientAbsOrigin(client, pos);
			decl Float:angle[3];
			angle[0] = 0.0 - RadToDeg(ArcTangent((entityLocation[2] - fClientEyePosition[2]) / (FloatAbs(SquareRoot(Pow(fClientEyePosition[0] - entityLocation[0], 2.0) + Pow(entityLocation[1] - fClientEyePosition[1], 2.0))))));
			angle[1] = GetAngle(fClientEyePosition, entityLocation);
			
			
			TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);
			
			if (GetVectorDistance(pos, entityLocation) < 250.0)
			{
				ModRateOfFire(iWeapon);
				buttons |= IN_ATTACK2;
			}
			
			// Airblast or slap near players away from the bot.
			if (GetConVarInt(cvarBarrier) > 0 && !allowed[client])
			{
				for (new i = 1 ; i <= MaxClients ;i++)
				{
					if (IsClientInGame(i) && IsClientConnected(i) && !IsClientObserver(i) && GetClientTeam(i) != GetClientTeam(client))
					{
						decl Float:fClientLocation[3];
						GetClientAbsOrigin(i, fClientLocation);
						
						fClientLocation[2] += 90;
						
						decl Float:fDistance[3];
						MakeVectorFromPoints(fClientLocation, fClientEyePosition, fDistance);
						
						decl Float:aAngle[3];
						GetVectorAngles(fDistance, aAngle);
						aAngle[0] *= -1.0;
						aAngle[1] += 180.0;
						
						if (GetConVarInt(cvarBarrier) == 1 && GetVectorLength(fDistance) < 190.0)
						{
							TeleportEntity(client, NULL_VECTOR, aAngle, NULL_VECTOR);
							buttons |= IN_ATTACK2;
						}
						
						float dist = GetVectorLength(fDistance);
						
						if (GetConVarInt(cvarBarrier) == 2)
						{
							if (canSlap[i])
							{
								if (dist < 500.0)
								{
									SlapPlayer(i, 0);
									if (canMsg[i])
									{
										PrintToChat(i, "\x07c0392bGetting any closer to the bot will result in a slay!");
										canMsg[i] = false;
										CreateTimer(5.0, Timer_MsgDelay, i, TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								if (dist < 400.0 && dist > 300.0)
								{
									SlapPlayer(i, 20);
								}
								if (dist < 300.0 && dist > 200.0)
								{
									SlapPlayer(i, 30);
								}
								if (dist < 200)
								{
									ForcePlayerSuicide(i);
								}
								canSlap[i] = false;
								CreateTimer(0.5, Timer_SlapDelay, i, TIMER_FLAG_NO_MAPCHANGE);
							}
						}
					}
				}
			}
		}
		
		// Projectile Handling such as flares.
		/*while ((ent = FindEntityByClassname(ent, "tf_projectile_*")) != INVALID_ENT_REFERENCE)
		{
			if (GetEntProp(ent, Prop_Send, "m_iTeamNum") != GetClientTeam(client))
			{
				
				decl Float:fEntityLocation[3];
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", fEntityLocation);
				
				decl Float:fVector[3];
				MakeVectorFromPoints(fEntityLocation, fClientEyePosition, fVector);
				
				decl Float:angle[3];
				GetVectorAngles(fVector, angle);
				angle[0] *= -1.0;
				angle[1] += 180.0;
				
				if(GetVectorLength(fVector) < 190.0)
				{
					TeleportEntity(client, NULL_VECTOR, angle, NULL_VECTOR);
					buttons |= IN_ATTACK2;
				}
			}
		}*/
	}
	return Plugin_Continue;
}

public Action:Timer_SlapDelay(Handle:timer, any:data)
{
	canSlap[data] = true;
}

public Action:Timer_MsgDelay(Handle:timer, any:data)
{
	canMsg[data] = true;
}

public OnEntityCreated(int entity, const char[] classname)
{
	if (StrEqual(classname, "tf_projectile_rocket"))
	{
		rocketDeflects = 0;
		canTrackSpeed = true;
	}
}

public OnGameFrame()
{
	if (!GetConVarBool(cvarEnable)) return;
	if (NanobotEnabled)
	{
		ChangePlayerTeam();
		SetupNanobot();
	}
	new onlineClients = GetRealClientCount(false);
	
	new rocket = FindEntityByClassname(-1, "tf_projectile_rocket");
	if (IsValidEntity(rocket))
	{
		if (canTrackSpeed)
		{
			canTrackSpeed = false;
			decl Float:entityVelocity[3];
			GetEntPropVector(rocket, Prop_Data, "m_vecAbsVelocity", entityVelocity);
			rocketSpeed = RoundFloat(GetVectorLength(entityVelocity) * (15.0/352.0)); //Convert to MPH by multiplying by (15/352)
			
			//debug
			/*char derp[32];
			IntToString(rocketSpeed, derp, sizeof(derp));
			PrintToChatAll(derp);*/
		}
		
		new rDeflects  = GetEntProp(rocket, Prop_Send, "m_iDeflected") - 1;
		if (rDeflects > rocketDeflects)
		{
			rocketDeflects++;
			canTrackSpeed = true;
			
			//debug
			/*char derp[32];
			IntToString(rocketDeflects, derp, sizeof(derp));
			PrintToChatAll(derp);*/
		}
	}
	
	// If there is more than one bot on the server, kick them and disable Nanobot. (Rare)
	if (GetFakeClientCount(false) > 1) DisableNanobot();
	
	// If there are no players on the server and Nanobot is enabled, disable Nanobot.
	if (onlineClients == 0 && NanobotEnabled) 
	{
		DisableNanobot();
		if (commandEnable) commandEnable = false;
		if (commandDisable) commandDisable = false;
	}
	// If the map changed and nanobot is enabled, disable nanobot. Not even sure if this is needed, but I was encountering issues where there were 2 bots.
	if (MapChanged && NanobotEnabled) DisableNanobot();
	
	new min = GetConVarInt(cvarMinPlayers);
	new max = GetConVarInt(cvarMaxPlayers);
	if (min >= max)
	{
		PrintToServer("[Nanobot] ERROR! There's an issue with your min & max player cvars, make sure minplayers is less than maxplayers.");
		return;
	}
	// Handle min players cvar
	if (min != 0 && onlineClients != 0 && onlineClients <= min && !NanobotEnabled && !commandDisable && !MapChanged)
	{
		PrintToChatAll("\x01[\x03%s\x01]\x04 There is a minimum of %d players, enabling Player vs. Bot...", botName, onlineClients);
		EnableNanobot();
		commandEnable = false;
	}
	
	// Handle max players cvar
	if (max != 0 && onlineClients != 0 && onlineClients >= max && NanobotEnabled && !commandEnable && !MapChanged)
	{
		PrintToChatAll("\x01[\x03%s\x01]\x04 There is a maximum of %d players, disabling Player vs. Bot...", botName, onlineClients);
		DisableNanobot();
		commandDisable = false;
	}
}

/* ===================================
*				Stocks
* ==================================== */
stock SetupNanobot()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientBot(i))
		{
			// Change Nanobot's name.
			SetClientInfo(i, "name", botName);
			
			// Change Nanobot's player model.
			decl String:mdl[PLATFORM_MAX_PATH];
			GetConVarString(cvarModel, mdl, sizeof(mdl));
			if (!StrEqual(mdl, ""))
			{
				SetVariantString(mdl);
				AcceptEntityInput(i, "SetCustomModel");
				SetEntProp(i, Prop_Send, "m_bUseClassAnimations", 1);
			}
			
			// Change Nanobot's team
			if (GetClientTeam(i) != 3)
			{
				ChangeClientTeam(i, 3);
				TF2_RespawnPlayer(i);
			}
			
			// Handle bot head size
			if (headSize != 1.0) SetEntPropFloat(i, Prop_Send, "m_flHeadScale", headSize);
				
			//Handle bot torso size
			if (torsoSize != 1.0) SetEntPropFloat(i, Prop_Send, "m_flTorsoScale", torsoSize);
				
			//Handle bot hand size
			if (handSize != 1.0) SetEntPropFloat(i, Prop_Send, "m_flHandScale", handSize);
		}
	}
}

stock ChangePlayerTeam()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && !IsClientObserver(i) && NanobotEnabled && GetClientTeam(i) != 2)
		{
			ChangeClientTeam(i, 2);
			TF2_RespawnPlayer(i);
		}
	}
}

stock bool:IsClientBot(client)
{
	return client != 0 && IsClientInGame(client) && IsFakeClient(client) && !IsClientReplay(client) && !IsClientSourceTV(client);
}

stock Float:GetAngle(const Float:coords1[3], const Float:coords2[3])
{
	new Float:angle = RadToDeg(ArcTangent((coords2[1] - coords1[1]) / (coords2[0] - coords1[0])));
	if (coords2[0] < coords1[0])
	{
		if (angle > 0.0) angle -= 180.0;
		else angle += 180.0;
	}
	return angle;
}

stock int GetRealClientCount( bool:inGameOnly = true ) 
{
	new clients = 0;
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) && !IsFakeClient(i) && !IsClientReplay(i) && !IsClientSourceTV(i)) 
		{
			clients++;
		}
	}
	return clients;
}

stock GetFakeClientCount(bool:inGameOnly = true)
{
	new clients = 0;
	for (new i = 1; i <= MaxClients; i++) 
	{
		if (((inGameOnly) ? IsClientInGame(i) : IsClientConnected(i)) && IsFakeClient(i) && !IsClientReplay(i) && !IsClientSourceTV(i)) 
		{
			clients++;
		}
	}
	return clients;
}

stock ModRateOfFire(weapon)
{
	new Float:m_flNextPrimaryAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack");
	new Float:m_flNextSecondaryAttack = GetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack");
	SetEntPropFloat(weapon, Prop_Send, "m_flPlaybackRate", 10.0);

	new Float:fGameTime = GetGameTime();
	new Float:fPrimaryTime = ((m_flNextPrimaryAttack - fGameTime) - 0.99);
	new Float:fSecondaryTime = ((m_flNextSecondaryAttack - fGameTime) - 0.99);

	SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", fPrimaryTime + fGameTime);
	SetEntPropFloat(weapon, Prop_Send, "m_flNextSecondaryAttack", fSecondaryTime + fGameTime);
}

stock UpdatePlayerHitbox(const client)
{
	static const Float:vecTF2PlayerMin[3] = { -24.5, -24.5, 0.0 }, Float:vecTF2PlayerMax[3] = { 24.5,  24.5, 83.0 };
	decl Float:vecScaledPlayerMin[3], Float:vecScaledPlayerMax[3];
	vecScaledPlayerMin = vecTF2PlayerMin;
	vecScaledPlayerMax = vecTF2PlayerMax;
	ScaleVector(vecScaledPlayerMin, g_fClientCurrentScale[ResizeType_Generic][client]);
	ScaleVector(vecScaledPlayerMax, g_fClientCurrentScale[ResizeType_Generic][client]);
	SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMins", vecScaledPlayerMin);
	SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxs", vecScaledPlayerMax);
}

stock ForceRedWin()
{
	new iEnt = -1;
	iEnt = FindEntityByClassname(iEnt, "game_round_win");
	
	if (iEnt < 1)
	{
		iEnt = CreateEntityByName("game_round_win");
		if (IsValidEntity(iEnt))
			DispatchSpawn(iEnt);
		else
		{
			LogError("Unable to find or create a game_round_win entity!");
			return;
		}
	}
	
	SetVariantInt(2);
	AcceptEntityInput(iEnt, "SetTeam");
	AcceptEntityInput(iEnt, "RoundWin");
}