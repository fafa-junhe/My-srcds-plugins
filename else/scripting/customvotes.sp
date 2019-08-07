#pragma semicolon 1

// ====[ INCLUDES ]============================================================
#include <sourcemod>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <sourcebanspp>
#tryinclude <kztimer>
#include <afk_manager>
// ====[ DEFINES ]=============================================================
#define PLUGIN_NAME "Custom Votes"
#define PLUGIN_VERSION "1.16.4U-dev"
#define MAX_VOTE_TYPES 32
#define MAX_VOTE_MAPS 1024
#define MAX_VOTE_OPTIONS 32

// ====[ HANDLES ]=============================================================
new Handle:g_hArrayVotePlayerSteamID[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new Handle:g_hArrayVotePlayerIP[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new Handle:g_hArrayVoteOptionName[MAX_VOTE_TYPES];
new Handle:g_hArrayVoteOptionResult[MAX_VOTE_TYPES];
new Handle:g_hArrayVoteMapList[MAX_VOTE_TYPES];
new Handle:g_hArrayRecentMaps;

// ====[ VARIABLES ]===========================================================
new g_iMapTime;
new g_iVoteCount;
new g_iCurrentVoteIndex;
new g_iCurrentVoteTarget;
new g_iCurrentVoteMap;
new g_iCurrentVoteOption;
new iAfkTime;
new g_iVoteType[MAX_VOTE_TYPES];
new g_iVoteDelay[MAX_VOTE_TYPES];
new g_iVoteCooldown[MAX_VOTE_TYPES];
new g_iVoteMinimum[MAX_VOTE_TYPES];
new g_iVoteImmunity[MAX_VOTE_TYPES];
new g_iVoteMaxCalls[MAX_VOTE_TYPES];
new g_iVotePasses[MAX_VOTE_TYPES];
new g_iVoteMaxPasses[MAX_VOTE_TYPES];
new g_iVoteMapRecent[MAX_VOTE_TYPES];
new g_iVoteCurrent[MAXPLAYERS + 1];
new g_iVoteRemaining[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new g_iVoteLast[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new g_iVoteAllLast[MAX_VOTE_TYPES]; // same as g_iVoteLast but applies to all players
new g_iVoteAllCooldown[MAX_VOTE_TYPES]; // cooldown between votes for ALL players
new bool:g_bVoteCallVote[MAX_VOTE_TYPES];
new bool:g_bVotePlayersBots[MAX_VOTE_TYPES];
new bool:g_bVotePlayersTeam[MAX_VOTE_TYPES];
new bool:g_bVoteMapCurrent[MAX_VOTE_TYPES];
new bool:g_bVoteMultiple[MAX_VOTE_TYPES];
new bool:g_bVoteForTarget[MAXPLAYERS + 1][MAX_VOTE_TYPES][MAXPLAYERS + 1];
new bool:g_bVoteForMap[MAXPLAYERS + 1][MAX_VOTE_TYPES][MAX_VOTE_MAPS];
new bool:g_bVoteForOption[MAXPLAYERS + 1][MAX_VOTE_TYPES][MAX_VOTE_OPTIONS];
new bool:g_bVoteForSimple[MAXPLAYERS + 1][MAX_VOTE_TYPES];
new bool:g_bKzTimer = false;
new bool:g_bSourceBans = false;
new bool:g_bAfkManager = false;
//new bool:g_bMapEnded = false;
new Float:g_flVoteRatio[MAX_VOTE_TYPES];
new String:g_strVoteName[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteConVar[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteOverride[MAX_VOTE_TYPES][MAX_NAME_LENGTH];
new String:g_strVoteCommand[MAX_VOTE_TYPES][255];
new String:g_strVoteChatTrigger[MAX_VOTE_TYPES][255];
new String:g_strVoteStartNotify[MAX_VOTE_TYPES][255];
new String:g_strVoteCallNotify[MAX_VOTE_TYPES][255];
new String:g_strVotePassNotify[MAX_VOTE_TYPES][255];
new String:g_strVoteFailNotify[MAX_VOTE_TYPES][255];
new String:g_strVoteTargetIndex[255];
new String:g_strVoteTargetId[255];
new String:g_strVoteTargetAuth[255];
new String:g_strVoteTargetName[255];
new String:g_strConfigFile[PLATFORM_MAX_PATH];
new String:g_sLogPath[PLATFORM_MAX_PATH];
// extras
new Handle:CvarDebugMode;
new Handle:CvarResetOnWaveFailed;
new Handle:CvarAutoBanEnabled;
new Handle:CvarAutoBanWarning;
new Handle:CvarAutoBanDuration;
new Handle:CvarAutoBanType;
new Handle:CvarAfkTime;
new Handle:CvarAfkManager;
new Handle:CvarCancelVoteGameEnd;
new bool:bDebugMode;
new bool:bResetOnWaveFailed;
new bool:bAutoBanEnabled;
new bool:bAutoBanWarning;
new bool:bAutoBanType;
new bool:bAfkManagerEnable;
new bool:bCancelVoteGameEnd;
new iAutoBanDuration;
new bool:IsTF2 = false;
new bool:IsCSGO = false;
enum
{
	VoteType_Players = 0,
	VoteType_Map,
	VoteType_List,
	VoteType_Simple,
}

// ====[ PLUGIN ]==============================================================
public Plugin:myinfo =
{
	name = PLUGIN_NAME,
	author = "ReFlexPoison,Anonymous Player",
	description = PLUGIN_NAME,
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
	/* Special thanks to afk manager ( https://forums.alliedmods.net/showthread.php?p=708265 ) and sourcecmod anti-cheat developers.
	I looked at their's plugin in order to learn how to add file logging. */
	// Special thanks for those who contributed on github
	// sneak-it ( https://github.com/caxanga334/cvreduxmodified/pulls?utf8=%E2%9C%93&q=is%3Apr+user%3Asneak-it )
}

// ====[ FUNCTIONS ]===========================================================
public OnPluginStart()
{
	CreateConVar("sm_customvotes_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	CvarResetOnWaveFailed = CreateConVar("sm_cv_tf2_reset_wavefailed", "0", "Reset maxpasses on wave failed?", FCVAR_NONE, true, 0.0, true, 1.0); // reset max passes on wave failed
	HookConVarChange( CvarResetOnWaveFailed, OnConVarChanged );
	CvarAutoBanEnabled = CreateConVar("sm_cv_autoban", "0", "Should the plugin automatically ban players who evade votes?", FCVAR_NONE, true, 0.0, true, 1.0); // ban players evading votes?
	HookConVarChange( CvarAutoBanEnabled, OnConVarChanged );
	CvarAutoBanWarning = CreateConVar("sm_cv_autoban_warning", "1", "Should the plugin warn targeted players if they will be banned upon disconnecting? Requires sm_cv_autoban 1.", FCVAR_NONE, true, 0.0, true, 1.0); // warn players about ban evasion enforcement?
	HookConVarChange( CvarAutoBanWarning, OnConVarChanged );
	CvarAutoBanType = CreateConVar("sm_cv_bantype", "0", "Ban type to be used for vote evasion bans? 0 - Local | 1 - MySQL (SourceBans)", FCVAR_NONE, true, 0.0, true, 1.0); // should we use mysql banning?
	HookConVarChange( CvarAutoBanType, OnConVarChanged );
	CvarAutoBanDuration = CreateConVar("sm_cv_banduration", "15", "How long (in minutes) should the plugin ban someone for evading votes?", FCVAR_NONE, true, 0.0, true, 525600.0); // the ban duration
	HookConVarChange( CvarAutoBanDuration, OnConVarChanged );
	CvarCancelVoteGameEnd = CreateConVar("sm_cv_cancelvote", "1", "Cancel pending votes on round end?", FCVAR_NONE, true, 0.0, true, 1.0); // Cancel votes using events, default enabled due to OnMapEnd being fired after OnClientDisconnect
	HookConVarChange( CvarCancelVoteGameEnd, OnConVarChanged );
	CvarDebugMode = CreateConVar("sm_cv_debug", "0", "Enable debug mode?", FCVAR_NONE, true, 0.0, true, 1.0); // Debug mode
	HookConVarChange( CvarDebugMode, OnConVarChanged );
	CvarAfkManager = CreateConVar("sm_cv_afkenable", "0", "Enable Afk players are no longer counted in the total?", FCVAR_NONE, true, 0.0, true, 1.0); //Enable Afk players are no longer counted in the total?
	HookConVarChange( CvarAfkManager, OnConVarChanged );
	CvarAfkTime = CreateConVar("sm_cv_afktime", "10", "How long (Seconds) Afk players are no longer counted in the total?", FCVAR_NONE, true, 0.0, true, 1000.0); //How long Afk players are no longer counted in the total?
	HookConVarChange( CvarAfkTime, OnConVarChanged );
	
	RegAdminCmd("sm_customvotes_reload", Command_Reload, ADMFLAG_ROOT, "Reloads the configuration file (Clears all votes)");
	RegAdminCmd("sm_votemenu", Command_ChooseVote, 0, "Opens the vote menu");

	LoadTranslations("core.phrases");
	LoadTranslations("common.phrases");
	LoadTranslations("customvotes.phrases");

	BuildPath(Path_SM, g_strConfigFile, sizeof(g_strConfigFile), "configs/customvotes.cfg");

	AddCommandListener(OnClientSayCmd, "say");
	AddCommandListener(OnClientSayCmd, "say_team");

	g_bKzTimer = LibraryExists("KZTimer");

	if(g_hArrayRecentMaps == INVALID_HANDLE)
		g_hArrayRecentMaps = CreateArray(MAX_NAME_LENGTH);
		
	DetectGame();
	
	// hook required for resetting total passes when the wave is lost (MVM)
	// TF2 only
	if(IsTF2 == true)
	{
		HookEvent("mvm_wave_failed", TF_WaveFailed);
		HookEvent("teamplay_win_panel", TF_TeamPlayWinPanel);
		HookEvent("arena_win_panel", TF_ArenaWinPanel);
		HookEvent("pve_win_panel", TF_MVMWinPanel);
	}
	if(IsCSGO == true)
	{
		HookEvent("cs_win_panel_match", CSGO_MapEnd);
	}
	
	CreateLogFile();
	AutoExecConfig(true, "sm_customvotes_redux");
}

public OnMapStart()
{
	g_iMapTime = 0;
	//g_bMapEnded = false; // map started, set it to false

	decl String:strMap[MAX_NAME_LENGTH];
	GetCurrentMap(strMap, sizeof(strMap));

	if(GetArraySize(g_hArrayRecentMaps) <= 0)
		PushArrayString(g_hArrayRecentMaps, strMap);
	else
	{
		ShiftArrayUp(g_hArrayRecentMaps, 0);
		SetArrayString(g_hArrayRecentMaps, 0, strMap);
	}

	Config_Load();
	CreateTimer(1.0, Timer_Second, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	CreateLogFile();
}

public OnMapEnd()
{
/* 	if(!g_bMapEnded)
	{
		g_bMapEnded = true;
	} */
	
	if((!IsCSGO || !IsTF2) && !bCancelVoteGameEnd)
	{
		if(IsVoteInProgress()) // is vote in progress?
		{
			CancelVote(); // cancel any running votes on map end.
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Map end while a vote was in progress, canceling vote.");
		}
	}
}

public OnConVarChanged( Handle:hConVar, const String:strOldValue[], const String:strNewValue[] )
{
	bResetOnWaveFailed = GetConVarBool( CvarResetOnWaveFailed );
	bAutoBanEnabled = GetConVarBool( CvarAutoBanEnabled );
	bAutoBanWarning = GetConVarBool( CvarAutoBanWarning );
	bAutoBanType = GetConVarBool( CvarAutoBanType );
	iAutoBanDuration = GetConVarInt( CvarAutoBanDuration );
	bCancelVoteGameEnd = GetConVarBool( CvarCancelVoteGameEnd );
	bDebugMode = GetConVarBool( CvarDebugMode );
	bAfkManagerEnable = GetConVarBool( CvarAfkManager );
	iAfkTime = GetConVarBool( CvarAfkTime );
}

stock DetectGame()
{
	char game_mod[32];
	GetGameFolderName(game_mod, sizeof(game_mod));
	
	if (strcmp(game_mod, "tf", false) == 0)
	{
		IsTF2 = true;
		LogMessage("Game Detected: Team Fortress 2.");
	}
	else if (strcmp(game_mod, "csgo", false) == 0)
	{
		IsCSGO = true;
		LogMessage("Game Detected: Counter-Strike: Global Offensive.");
	}
	else
	{
		LogMessage("Game Detected: Other.");
	}
}

public OnLibraryAdded(const String:szName[])
{
	if (StrEqual(szName, "KZTimer"))
	{
		g_bKzTimer = true;
	}
	
	if (StrEqual(szName, "sourcebans++"))
	{
		g_bSourceBans = true;
	}
	if (StrEqual(szName, "afkmanager"))
	{
		g_bAfkManager = true;
	}
}

public OnLibraryRemoved(const String:szName[])
{
	if (StrEqual(szName, "KZTimer"))
	{
		g_bKzTimer = false;
	}
	
	if (StrEqual(szName, "sourcebans++"))
	{
		g_bSourceBans = false;
	}
	if (StrEqual(szName, "afkmanager"))
	{
		g_bAfkManager = false;
	}
}

public OnClientConnected(iTarget)
{
	g_iVoteCurrent[iTarget] = -1;
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		g_iVoteRemaining[iTarget][iVote] = g_iVoteMaxCalls[iVote];
		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		{
			g_bVoteForTarget[iVoter][iVote][iTarget] = false;
			g_bVoteForTarget[iTarget][iVote][iVoter] = false;
		}

		for(new iMap = 0; iMap < MAX_VOTE_MAPS; iMap++)
			g_bVoteForMap[iTarget][iVote][iMap] = false;

		for(new iOption = 0; iOption < MAX_VOTE_OPTIONS; iOption++)
			g_bVoteForOption[iTarget][iVote][iOption] = false;

		g_bVoteForSimple[iTarget][iVote] = false;

		if(g_hArrayVotePlayerSteamID[iTarget][iVote] != INVALID_HANDLE)
			ClearArray(g_hArrayVotePlayerSteamID[iTarget][iVote]);

		if(g_hArrayVotePlayerIP[iTarget][iVote] != INVALID_HANDLE)
			ClearArray(g_hArrayVotePlayerIP[iTarget][iVote]);
	}

	decl String:strClientIP[MAX_NAME_LENGTH];
	if(!GetClientIP(iTarget, strClientIP, sizeof(strClientIP)))
		return;

	decl String:strSavedIP[MAX_NAME_LENGTH];
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		{
			if(g_bVoteForTarget[iVoter][iVote][iTarget])
				break;

			if(g_hArrayVotePlayerIP[iVoter][iVote] == INVALID_HANDLE)
				continue;

			for(new iIP = 0; iIP < GetArraySize(g_hArrayVotePlayerIP[iVoter][iVote]); iIP++)
			{
				GetArrayString(g_hArrayVotePlayerIP[iVoter][iVote], iIP, strSavedIP, sizeof(strSavedIP));
				if(StrEqual(strSavedIP, strClientIP))
				{
					g_bVoteForTarget[iVoter][iTarget] = true;
					break;
				}
			}
		}
	}

	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		CheckVotesForTarget(iVote, iTarget);
}

public OnClientAuthorized(iTarget, const String:strTargetSteamId[])
{
	decl String:strClientAuth[MAX_NAME_LENGTH];
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		{
			if(g_bVoteForTarget[iVoter][iVote][iTarget])
				break;

			if(g_hArrayVotePlayerSteamID[iVoter][iVote] == INVALID_HANDLE)
				continue;

			for(new iSteamId = 1; iSteamId < GetArraySize(g_hArrayVotePlayerSteamID[iVoter][iVote]); iSteamId++)
			{
				GetArrayString(g_hArrayVotePlayerSteamID[iVoter][iVote], iSteamId, strClientAuth, sizeof(strClientAuth));
				if(StrEqual(strTargetSteamId, strClientAuth))
				{
					g_bVoteForTarget[iVoter][iTarget] = true;
					break;
				}
			}
		}
	}

	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
		CheckVotesForTarget(iVote, iTarget);
}

public OnClientDisconnect(iTarget)
{
	g_iVoteCurrent[iTarget] = -1;
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		g_iVoteRemaining[iTarget][iVote] = g_iVoteMaxCalls[iVote];
		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		{
			g_bVoteForTarget[iVoter][iVote][iTarget] = false;
			g_bVoteForTarget[iTarget][iVote][iVoter] = false;
		}

		for(new iMap = 0; iMap < MAX_VOTE_MAPS; iMap++)
			g_bVoteForMap[iTarget][iVote][iMap] = false;

		for(new iOption = 0; iOption < MAX_VOTE_OPTIONS; iOption++)
			g_bVoteForOption[iTarget][iVote][iOption] = false;

		g_bVoteForSimple[iTarget][iVote] = false;

		if(g_hArrayVotePlayerSteamID[iTarget][iVote] != INVALID_HANDLE)
			ClearArray(g_hArrayVotePlayerSteamID[iTarget][iVote]);

		if(g_hArrayVotePlayerIP[iTarget][iVote] != INVALID_HANDLE)
			ClearArray(g_hArrayVotePlayerIP[iTarget][iVote]);
	}

	for(new iVote = 0; iVote < MAX_VOTE_TYPES; iVote++)
	{
		switch(g_iVoteType[iVote])
		{
			case VoteType_Players:
			{
				for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
					CheckVotesForTarget(iVote, iVoter);
			}
			case VoteType_Map:
			{
				for(new iMap = 0; iMap < MAX_VOTE_MAPS; iMap++)
					CheckVotesForMap(iVote, iMap);
			}
			case VoteType_List:
			{
				for(new iOption = 0; iOption < MAX_VOTE_OPTIONS; iOption++)
					CheckVotesForOption(iVote, iOption);
			}
			case VoteType_Simple:
			{
				for(new iSimple = 0; iSimple < MAX_VOTE_TYPES; iSimple++)
					CheckVotesForSimple(iVote);
			}
		}
	}
	// Experimental vote evasion logging
	if(g_iCurrentVoteTarget >= 1 && IsVoteInProgress()) // Do we have a target and the vote is in progress
	{
		if(iTarget == g_iCurrentVoteTarget) // the id of the player who just disconnected matches the vote target id.
		{
			// get target's name
			decl String:LogstrTargetName[MAX_NAME_LENGTH];
			GetClientName(iTarget, LogstrTargetName, sizeof(LogstrTargetName));
			
			// get target's SteamID
			decl String:LstrTargetAuth[MAX_NAME_LENGTH];
			GetClientAuthId(iTarget, AuthId_Steam2, LstrTargetAuth, sizeof(LstrTargetAuth));
			
			// Logging Vote
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Vote target disconnected while vote was in progress! The target was: %s ( %s ).",
				LogstrTargetName,
				LstrTargetAuth);
				
			if(bAutoBanEnabled)
			{
				if(g_bSourceBans && bAutoBanType) // SourceBans is available and the plugin is told to use it
				{
					SBPP_BanPlayer(0, iTarget, iAutoBanDuration, "Vote Evasion");
				}
				else
				{
					BanClient(iTarget, iAutoBanDuration, BANFLAG_AUTO, "Vote Evasion", "Vote Evasion", "CVR");
				}
				
				if(!g_bSourceBans && bAutoBanType) // Plugin is told to use sourcebans but sourcebans is not available
				{
					LogError("Unable to ban using SourceBans++.");
				}
			}
		}
	}
}

void CreateLogFile() // creates the log file in the system
{
	char cTime[64];
	FormatTime(cTime, sizeof(cTime), "%Y%m%d"); // add date to file name
	// Path used for logging.
	BuildPath(Path_SM, g_sLogPath, sizeof(g_sLogPath), "logs/customvotes_%s.log", cTime);
}

// ====[ COMMANDS ]============================================================
public Action:Command_Reload(iClient, iArgs)
{
	Config_Load();
	return Plugin_Handled;
}

public Action:Command_ChooseVote(iClient, iArgs)
{
	if(!IsValidClient(iClient))
		return Plugin_Continue;

	if(IsVoteInProgress())
	{
		CReplyToCommand(iClient, "[SM] %t", "Vote in Progress");
		return Plugin_Handled;
	}

	Menu_ChooseVote(iClient);
	return Plugin_Handled;
}

public Action:OnClientSayCmd(iVoter, const String:strCmd[], iArgc)
{
	if(!IsValidClient(iVoter))
		return Plugin_Continue;

	decl String:strText[255];
	GetCmdArgString(strText, sizeof(strText));
	StripQuotes(strText);

	ReplaceString(strText, sizeof(strText), "!", "");
	ReplaceString(strText, sizeof(strText), "/", "");

	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		if(StrEqual(g_strVoteChatTrigger[iVote], strText))
		{
			g_iVoteCurrent[iVoter] = iVote;
			switch(g_iVoteType[iVote])
			{
				case VoteType_Players: Menu_PlayersVote(iVote, iVoter);
				case VoteType_Map: Menu_MapVote(iVote, iVoter);
				case VoteType_List: Menu_ListVote(iVote, iVoter);
				case VoteType_Simple: CastSimpleVote(iVote, iVoter);
			}
			break;
		}
	}

	return Plugin_Continue;
}

// ====[ MENUS ]===============================================================
public Menu_ChooseVote(iVoter)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Vote);
	SetMenuTitle(hMenu, "Vote Menu:");

	decl String:strIndex[4];
	new iTime = GetTime();
	for(new iVote = 0; iVote < g_iVoteCount; iVote++)
	{
		new iFlags;

		// Admin access
		if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
			iFlags = ITEMDRAW_DISABLED;

		// Max votes
		else if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
			iFlags = ITEMDRAW_DISABLED;

		// Max passes
		else if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
			iFlags = ITEMDRAW_DISABLED;

		// Cooldown
		else if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
			iFlags = ITEMDRAW_DISABLED;
			
		// Cooldown (All Players)
		else if(iTime - g_iVoteAllLast[iVote] < g_iVoteAllCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
			iFlags = ITEMDRAW_DISABLED;

		IntToString(iVote, strIndex, sizeof(strIndex));

		decl String:strName[56];
		strcopy(strName, sizeof(strName), g_strVoteName[iVote]);

		if(g_iVoteType[iVote] == VoteType_Simple)
		{
			if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
			{
				ReplaceString(strName, sizeof(strName), "{On|Off}", "Off", true);
				ReplaceString(strName, sizeof(strName), "{on|off}", "off", true);
			}
			else
			{
				ReplaceString(strName, sizeof(strName), "{On|Off}", "On", true);
				ReplaceString(strName, sizeof(strName), "{on|off}", "on", true);
			}

			if(!g_bVoteCallVote[iVote])
				Format(strName, sizeof(strName), "%s [%i/%i]", strName, GetVotesForSimple(iVote), GetRequiredVotes(iVote));
		}

		AddMenuItem(hMenu, strIndex, strName, iFlags);
	}

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && g_bKzTimer)
		{
			KZTimer_StopUpdatingOfClimbersMenu(i);
		}
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_Vote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[8];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = StringToInt(strBuffer);
		g_iVoteCurrent[iVoter] = iVote;

		switch(g_iVoteType[iVote])
		{
			case VoteType_Players: Menu_PlayersVote(iVote, iVoter);
			case VoteType_Map: Menu_MapVote(iVote, iVoter);
			case VoteType_List: Menu_ListVote(iVote, iVoter);
			case VoteType_Simple: CastSimpleVote(iVote, iVoter);
		}
	}
}

public Menu_PlayersVote(iVote, iVoter)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}
	
	if(iTime - g_iVoteAllLast[iVote] < g_iVoteAllCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteAllCooldown[iVote] - (iTime - g_iVoteAllLast[iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_PlayersVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	new iCount;
	decl String:strUserId[8];
	decl String:strName[MAX_NAME_LENGTH + 12];

	new iVoterTeam = GetClientTeam(iVoter);
	for(new iTarget = 1; iTarget <= MaxClients; iTarget++) if(IsClientInGame(iTarget))
	{
		if(!g_bVotePlayersBots[iVote] && IsFakeClient(iTarget))
			continue;

		if(g_bVotePlayersTeam[iVote] && GetClientTeam(iTarget) != iVoterTeam)
			continue;

		new iFlags;
		if(iTarget == iVoter)
			iFlags = ITEMDRAW_DISABLED;

		new AdminId:idAdmin = GetUserAdmin(iTarget);
		if(idAdmin != INVALID_ADMIN_ID)
		{
			if(GetAdminImmunityLevel(idAdmin) >= g_iVoteImmunity[iVote])
				iFlags = ITEMDRAW_DISABLED;
		}

		IntToString(GetClientUserId(iTarget), strUserId, sizeof(strUserId));

		if(g_bVoteCallVote[iVote])
			GetClientName(iTarget, strName, sizeof(strName));
		else
			Format(strName, sizeof(strName), "%N [%i/%i]", iTarget, GetVotesForTarget(iVote, iTarget), GetRequiredVotes(iVote));

		if(GetVotesForTarget(iVote, iTarget) > 0)
			InsertMenuItem(hMenu, 0, strUserId, strName, iFlags);
		else
			AddMenuItem(hMenu, strUserId, strName, iFlags);
		iCount++;
	}

	if(iCount <= 0)
	{
		CPrintToChat(iVoter, "%t", "No Valid Clients");
		return;
	}

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && g_bKzTimer)
		{
			KZTimer_StopUpdatingOfClimbersMenu(i);
		}
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_PlayersVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[8];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
			return;

		if(IsVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		new iTarget = GetClientOfUserId(StringToInt(strBuffer));
		if(!IsValidClient(iTarget))
		{
			CPrintToChat(iVoter, "%t", "Player no longer available");
			Menu_ChooseVote(iVoter);
			return;
		}

		if(g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
		{
			g_iVoteRemaining[iVoter][iVote]--;
			CPrintToChat(iVoter, "%t", "Votes Remaining", g_iVoteRemaining[iVoter][iVote]);
		}

		g_iVoteLast[iVoter][iVote] = GetTime();
		g_iVoteAllLast[iVote] = GetTime();
		if(g_bVoteCallVote[iVote])
		{
			Vote_Players(iVote, iVoter, iTarget);
			return;
		}

		g_bVoteForTarget[iVoter][iVote][iTarget] = true;
		if(!g_bVoteMultiple[iVote])
		{
			for(new iClient = 0; iClient <= MaxClients; iClient++)
			{
				if(iClient != iTarget)
					g_bVoteForTarget[iVoter][iVote][iClient] = false;
			}
		}

		if(g_strVoteCallNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[iVote]);

			FormatVoteString(iVote, iTarget, strNotification, sizeof(strNotification));
			FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
			FormatTargetString(iVote, iTarget, strNotification, sizeof(strNotification));

			ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
			ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

			CPrintToChatAll("%s", strNotification);
		}

		if(!IsFakeClient(iTarget) && IsClientAuthorized(iTarget))
		{
			decl String:strAuth[MAX_NAME_LENGTH];
			GetClientAuthId(iVoter, AuthId_Steam2, strAuth, sizeof(strAuth));
			PushArrayString(g_hArrayVotePlayerSteamID[iVoter][iVote], strAuth);
		}

		decl String:strIP[MAX_NAME_LENGTH];
		if(GetClientIP(iTarget, strIP, sizeof(strIP)))
			PushArrayString(g_hArrayVotePlayerIP[iVoter][iVote], strIP);

		CheckVotesForTarget(iVote, iTarget);
		Menu_ChooseVote(iVoter);
	}
}

public Vote_Players(iVote, iVoter, iTarget)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	new iPlayers[MAXPLAYERS + 1];
	new iTotal;
	if (bAfkManagerEnable && g_bAfkManager)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForTarget[i][iVote][iTarget] = false;
			if(IsClientInGame(i) && !IsFakeClient(i) && i != iTarget && !IsAFKClient(i))
			{
				if(g_bVotePlayersTeam[iVote])
				{
					if(GetClientTeam(i) == GetClientTeam(iVoter))
					iPlayers[iTotal++] = i;
				}
				else
					iPlayers[iTotal++] = i;
			}
		}
	}
	else
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForTarget[i][iVote][iTarget] = false;
			if(IsClientInGame(i) && !IsFakeClient(i) && i != iTarget)
			{
				if(g_bVotePlayersTeam[iVote])
				{
					if(GetClientTeam(i) == GetClientTeam(iVoter))
					iPlayers[iTotal++] = i;
				}
				else
					iPlayers[iTotal++] = i;
			}
		}
	}
	if(g_iVoteMinimum[iVote] > iTotal || iTotal <= 0)
	{
		CPrintToChat(iVoter, "%t", "Not Enough Valid Clients");
		return;
	}
	if(g_strVoteStartNotify[iVote][0]) // Vote Start Notify
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteStartNotify[iVote]);

		FormatVoteString(iVote, iTarget, strNotification, sizeof(strNotification));
		FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
		FormatTargetString(iVote, iTarget, strNotification, sizeof(strNotification));

		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
		}

		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

		CPrintToChatAll("%s", strNotification);
		
		// get vote name
		decl String:LogstrName[56];
		strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
		
		// get voter's name
		decl String:LogstrVoterName[MAX_NAME_LENGTH];
		GetClientName(iVoter, LogstrVoterName, sizeof(LogstrVoterName));
		
		// get voter's SteamID
		decl String:LstrVoterAuth[MAX_NAME_LENGTH];
		GetClientAuthId(iVoter, AuthId_Steam2, LstrVoterAuth, sizeof(LstrVoterAuth));
		
		// get target's name
		decl String:LogstrTargetName[MAX_NAME_LENGTH];
		GetClientName(iTarget, LogstrTargetName, sizeof(LogstrTargetName));
		
		// get target's SteamID
		decl String:LstrTargetAuth[MAX_NAME_LENGTH];
		GetClientAuthId(iTarget, AuthId_Steam2, LstrTargetAuth, sizeof(LstrTargetAuth));
		
		// Logging Vote
		LogToFileEx(g_sLogPath,
			"[Custom Votes] Vote %s started by %s ( %s ) targeting %s ( %s ).",
			LogstrName,
			LogstrVoterName,
			LstrVoterAuth,
			LogstrTargetName,
			LstrTargetAuth);
	}

	new Handle:hMenu = CreateMenu(VoteHandler_Players);

	decl String:strTarget[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];

	GetClientName(iTarget, strTarget, sizeof(strTarget));
	Format(strBuffer, sizeof(strBuffer), "%s (%s)", g_strVoteName[iVote], strTarget);

	SetMenuTitle(hMenu, "%s", strBuffer);
	SetMenuExitButton(hMenu, false);

	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	
	if(GetRandomInt(1, 2) == 1)
	{
		AddMenuItem(hMenu, "Yes", "Yes");
		AddMenuItem(hMenu, "No", "No");
	}
	else
	{
	AddMenuItem(hMenu, "No", "No");
	AddMenuItem(hMenu, "Yes", "Yes");
	}
	g_iCurrentVoteIndex = iVote;
	g_iCurrentVoteTarget = iTarget;

	IntToString(iTarget, g_strVoteTargetIndex, sizeof(g_strVoteTargetIndex));
	IntToString(GetClientUserId(iTarget), g_strVoteTargetId, sizeof(g_strVoteTargetId));
	GetClientAuthId(iTarget, AuthId_Steam2, g_strVoteTargetAuth, sizeof(g_strVoteTargetAuth));
	strcopy(g_strVoteTargetName, sizeof(g_strVoteTargetName), strTarget);
	
	if(bAutoBanEnabled && bAutoBanWarning)
	{
		CPrintToChat(iTarget, "%t", "Ban Warning");
	}

	VoteMenu(hMenu, iPlayers, iTotal, 30);
}

public VoteHandler_Players(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
	}
	if(iAction == MenuAction_Select)
	{
		decl String:strInfo[16];
		GetMenuItem(hMenu, iParam2, strInfo, sizeof(strInfo));

		if(StrEqual(strInfo, "Yes", false))
		{
			g_bVoteForTarget[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteTarget] = true;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatTargetString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
		else if(StrEqual(strInfo, "No", false))
		{
			g_bVoteForTarget[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteTarget] = false;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatTargetString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "No", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "no", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
	}
	else if(iAction == MenuAction_VoteEnd)
	{
		if(!CheckVotesForTarget(g_iCurrentVoteIndex, g_iCurrentVoteTarget) && g_strVoteFailNotify[g_iCurrentVoteIndex][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteFailNotify[g_iCurrentVoteIndex]);

			FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));
			FormatTargetString(g_iCurrentVoteIndex, g_iCurrentVoteTarget, strNotification, sizeof(strNotification));

			CPrintToChatAll("%s", strNotification);
		}

		g_iCurrentVoteTarget = -1;
		g_iCurrentVoteIndex = -1;

		strcopy(g_strVoteTargetIndex, sizeof(g_strVoteTargetIndex), "");
		strcopy(g_strVoteTargetId, sizeof(g_strVoteTargetId), "");
		strcopy(g_strVoteTargetAuth, sizeof(g_strVoteTargetAuth), "");
		strcopy(g_strVoteTargetName, sizeof(g_strVoteTargetName), "");
	}
}

public Menu_MapVote(iVote, iVoter)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}
	
	if(iTime - g_iVoteAllLast[iVote] < g_iVoteAllCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteAllCooldown[iVote] - (iTime - g_iVoteAllLast[iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_MapVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	decl String:strMap[MAX_NAME_LENGTH];
	decl String:strCurrentMap[MAX_NAME_LENGTH];
	decl String:strRecentMap[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];

	new iLastMapCount = GetArraySize(g_hArrayRecentMaps);
	if(iLastMapCount > g_iVoteMapRecent[iVote])
		iLastMapCount = g_iVoteMapRecent[iVote];

	new iMapCount = GetArraySize(g_hArrayVoteMapList[iVote]);
	if(iMapCount > MAX_VOTE_MAPS)
		iMapCount = MAX_VOTE_MAPS;

	for(new iMap = 0; iMap < iMapCount; iMap++)
	{
		new iFlags;
		if(g_bVoteMapCurrent[iVote])
		{
			GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));
			GetCurrentMap(strCurrentMap, sizeof(strCurrentMap));

			if(StrEqual(strMap, strRecentMap))
				iFlags = ITEMDRAW_DISABLED;
		}

		if(iLastMapCount > 0)
		{
			for(new iLastMap = 0; iLastMap < iLastMapCount; iLastMap++)
			{
				GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));
				GetArrayString(g_hArrayRecentMaps, iLastMap, strRecentMap, sizeof(strRecentMap));

				if(StrEqual(strMap, strRecentMap))
				{
					iFlags = ITEMDRAW_DISABLED;
					break;
				}
			}
		}

		if(g_bVoteCallVote[iVote])
			Format(strBuffer, sizeof(strBuffer), "%s", strMap);
		else
			Format(strBuffer, sizeof(strBuffer), "%s [%i/%i]", strMap, GetVotesForMap(iVote, iMap), GetRequiredVotes(iVote));

		if(GetVotesForMap(iVote, iMap) > 0)
			InsertMenuItem(hMenu, 0, strMap, strBuffer, iFlags);
		else
			AddMenuItem(hMenu, strMap, strBuffer, iFlags);
	}

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && g_bKzTimer)
		{
			KZTimer_StopUpdatingOfClimbersMenu(i);
		}
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_MapVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[MAX_NAME_LENGTH];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
			return;

		if(IsVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		if(g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
		{
			g_iVoteRemaining[iVoter][iVote]--;
			CPrintToChat(iVoter, "%t", "Votes Remaining", g_iVoteRemaining[iVoter][iVote]);
		}

		new iMap = -1;
		decl String:strMapName[MAX_NAME_LENGTH];
		for(new iMapList = 0; iMapList < GetArraySize(g_hArrayVoteMapList[iVote]); iMapList++)
		{
			GetArrayString(g_hArrayVoteMapList[iVote], iMapList, strMapName, sizeof(strMapName));
			if(StrEqual(strMapName, strBuffer))
			{
				iMap = iMapList;
				break;
			}
		}

		if(iMap == -1)
		{
			Menu_ChooseVote(iVoter);
			return;
		}

		if(g_bVoteCallVote[iVote])
		{
			Vote_Map(iVote, iVoter, iMap);
			return;
		}

		if(g_bVoteForMap[iVoter][iVote][iMap])
		{
			CPrintToChat(iVoter, "%t", "Already Voted");
			Menu_ChooseVote(iVoter);
			return;
		}

		g_bVoteForMap[iVoter][iVote][iMap] = true;
		if(!g_bVoteMultiple[iVote])
		{
			for(new iSavedMap = 0; iSavedMap < GetArraySize(g_hArrayVoteMapList[iVote]); iSavedMap++)
			{
				if(iSavedMap != iMap)
					g_bVoteForMap[iVoter][iVote][iSavedMap] = false;
			}
		}

		if(g_strVoteCallNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[iVote]);

			FormatVoteString(iVote, iMap, strNotification, sizeof(strNotification));
			FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
			FormatMapString(iVote, iMap, strNotification, sizeof(strNotification));

			ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
			ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

			CPrintToChatAll("%s", strNotification);
		}

		g_iVoteLast[iVoter][iVote] = GetTime();
		g_iVoteAllLast[iVote] = GetTime();
		CheckVotesForMap(iVote, iMap);
		Menu_ChooseVote(iVoter);
	}
}

public Vote_Map(iVote, iVoter, iMap)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	new iPlayers[MAXPLAYERS + 1];
	new iTotal;
	if (bAfkManagerEnable && g_bAfkManager)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForMap[i][iVote][iMap] = false;
			if(IsClientInGame(i) && !IsFakeClient(i) && !IsAFKClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	else
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForMap[i][iVote][iMap] = false;
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	if(g_iVoteMinimum[iVote] > iTotal || iTotal <= 0)
	{
		CPrintToChat(iVoter, "%t", "Not Enough Valid Clients");
		return;
	}

	if(g_strVoteStartNotify[iVote][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteStartNotify[iVote]);

		FormatVoteString(iVote, iMap, strNotification, sizeof(strNotification));
		FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
		FormatMapString(iVote, iMap, strNotification, sizeof(strNotification));

		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
		}

		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

		CPrintToChatAll("%s", strNotification);
		
		// get vote name
		decl String:LogstrName[56];
		strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
		
		// get voter's name
		decl String:LogstrVoterName[MAX_NAME_LENGTH];
		GetClientName(iVoter, LogstrVoterName, sizeof(LogstrVoterName));
		
		// get voter's SteamID
		decl String:LstrVoterAuth[MAX_NAME_LENGTH];
		GetClientAuthId(iVoter, AuthId_Steam2, LstrVoterAuth, sizeof(LstrVoterAuth));
		
		// get current map name
		decl String:LogstrCurrentMap[MAX_NAME_LENGTH];
		GetCurrentMap(LogstrCurrentMap, sizeof(LogstrCurrentMap));
		
		// get target map name
		decl String:LogstrMap[MAX_NAME_LENGTH];
		GetArrayString(g_hArrayVoteMapList[iVote], iMap, LogstrMap, sizeof(LogstrMap));
		
		// Logging Vote
		LogToFileEx(g_sLogPath,
			"[Custom Votes] Vote %s started by %s ( %s ). To change map from %s to %s.",
			LogstrName,
			LogstrVoterName,
			LstrVoterAuth,
			LogstrCurrentMap,
			LogstrMap);
	}

	new Handle:hMenu = CreateMenu(VoteHandler_Map);

	decl String:strMap[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];

	GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));
	Format(strBuffer, sizeof(strBuffer), "%s (%s)", g_strVoteName[iVote], strMap);

	SetMenuTitle(hMenu, "%s", strBuffer);
	SetMenuExitButton(hMenu, false);

	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	if(GetRandomInt(1, 2) == 1)
	{
		AddMenuItem(hMenu, "Yes", "Yes");
		AddMenuItem(hMenu, "No", "No");
	}
	else
	{
	AddMenuItem(hMenu, "No", "No");
	AddMenuItem(hMenu, "Yes", "Yes");
	}

	g_iCurrentVoteIndex = iVote;
	g_iCurrentVoteMap = iMap;
	VoteMenu(hMenu, iPlayers, iTotal, 30);
}

public VoteHandler_Map(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strInfo[16];
		GetMenuItem(hMenu, iParam2, strInfo, sizeof(strInfo));

		if(StrEqual(strInfo, "Yes"))
		{
			g_bVoteForMap[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteMap] = true;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatMapString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
		else if(StrEqual(strInfo, "No"))
		{
			g_bVoteForMap[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteMap] = false;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatMapString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "No", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "no", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
	}
	else if(iAction == MenuAction_VoteEnd)
	{
		if(!CheckVotesForMap(g_iCurrentVoteIndex, g_iCurrentVoteMap) && g_strVoteFailNotify[g_iCurrentVoteIndex][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteFailNotify[g_iCurrentVoteIndex]);

			FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));
			FormatMapString(g_iCurrentVoteIndex, g_iCurrentVoteMap, strNotification, sizeof(strNotification));

			CPrintToChatAll("%s", strNotification);
		}
		g_iCurrentVoteMap = -1;
		g_iCurrentVoteIndex = -1;
	}
}

public Menu_ListVote(iVote, iVoter)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}
	
	if(iTime - g_iVoteAllLast[iVote] < g_iVoteAllCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteAllCooldown[iVote] - (iTime - g_iVoteAllLast[iVote]));
		return;
	}

	new Handle:hMenu = CreateMenu(MenuHandler_ListVote);
	SetMenuTitle(hMenu, "%s:", g_strVoteName[iVote]);
	SetMenuExitBackButton(hMenu, true);

	decl String:strIndex[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];
	decl String:strOptionName[MAX_NAME_LENGTH];
	for(new iOption = 0; iOption < GetArraySize(g_hArrayVoteOptionName[iVote]); iOption++)
	{
		GetArrayString(g_hArrayVoteOptionName[iVote], iOption, strOptionName, sizeof(strOptionName));
		if(g_bVoteCallVote[iVote])
			Format(strBuffer, sizeof(strBuffer), "%s", strOptionName, GetVotesForOption(iVote, iOption), GetRequiredVotes(iVote));
		else
			Format(strBuffer, sizeof(strBuffer), "%s [%i/%i]", strOptionName, GetVotesForOption(iVote, iOption), GetRequiredVotes(iVote));

		IntToString(iOption, strIndex, sizeof(strIndex));

		if(GetVotesForOption(iVote, iOption) > 0)
			InsertMenuItem(hMenu, 0, strIndex, strBuffer);
		else
			AddMenuItem(hMenu, strIndex, strBuffer);
	}

	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && g_bKzTimer)
		{
			KZTimer_StopUpdatingOfClimbersMenu(i);
		}
	}

	DisplayMenu(hMenu, iVoter, 30);
}

public MenuHandler_ListVote(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Cancel && iParam2 == MenuCancel_ExitBack)
	{
		Menu_ChooseVote(iVoter);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strBuffer[MAX_NAME_LENGTH];
		GetMenuItem(hMenu, iParam2, strBuffer, sizeof(strBuffer));

		new iVote = g_iVoteCurrent[iVoter];
		if(iVote == -1)
			return;

		if(IsVoteInProgress())
		{
			CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
			return;
		}

		if(g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
		{
			g_iVoteRemaining[iVoter][iVote]--;
			CPrintToChat(iVoter, "%t", "Votes Remaining", g_iVoteRemaining[iVoter][iVote]);
		}

		new iOption = StringToInt(strBuffer);
		if(g_bVoteCallVote[iVote])
		{
			Vote_List(iVote, iVoter, iOption);
			return;
		}

		if(g_bVoteForOption[iVoter][iVote][iOption])
		{
			CPrintToChat(iVoter, "%t", "Already Voted");
			Menu_ChooseVote(iVoter);
			return;
		}

		g_bVoteForOption[iVoter][iVote][iOption] = true;
		if(!g_bVoteMultiple[iVote])
		{
			for(new iOptionList = 0; iOptionList < GetArraySize(g_hArrayVoteOptionName[iVote]); iOptionList++)
			{
				if(iOptionList != iOption)
					g_bVoteForOption[iVoter][iVote][iOptionList] = false;
			}
		}

		if(g_strVoteCallNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[iVote]);

			FormatVoteString(iVote, iOption, strNotification, sizeof(strNotification));
			FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
			FormatOptionString(iVote, iOption, strNotification, sizeof(strNotification));

			ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
			ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

			CPrintToChatAll("%s", strNotification);
		}

		g_iVoteLast[iVoter][iVote] = GetTime();
		g_iVoteAllLast[iVote] = GetTime();
		CheckVotesForOption(iVote, iOption);
		Menu_ChooseVote(iVoter);
	}
}

public Vote_List(iVote, iVoter, iOption)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	new iPlayers[MAXPLAYERS + 1];
	new iTotal;

	if (bAfkManagerEnable && g_bAfkManager)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForOption[i][iVote][iOption] = false;
			if(IsClientInGame(i) && !IsFakeClient(i) && !IsAFKClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	else
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForOption[i][iVote][iOption] = false;
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	if(g_iVoteMinimum[iVote] > iTotal || iTotal <= 0)
	{
		CPrintToChat(iVoter, "%t", "Not Enough Valid Clients");
		return;
	}

	if(g_strVoteStartNotify[iVote][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteStartNotify[iVote]);

		FormatVoteString(iVote, iOption, strNotification, sizeof(strNotification));
		FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));
		FormatOptionString(iVote, iOption, strNotification, sizeof(strNotification));

		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
		}

		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

		CPrintToChatAll("%s", strNotification);

		// get vote name
		decl String:LogstrName[56];
		strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
		
		// get voter's name
		decl String:LogstrVoterName[MAX_NAME_LENGTH];
		GetClientName(iVoter, LogstrVoterName, sizeof(LogstrVoterName));
		
		// get voter's SteamID
		decl String:LstrVoterAuth[MAX_NAME_LENGTH];
		GetClientAuthId(iVoter, AuthId_Steam2, LstrVoterAuth, sizeof(LstrVoterAuth));
		
		// get vote option
		decl String:LstrOptionResult[MAX_NAME_LENGTH];
		GetArrayString(g_hArrayVoteOptionResult[iVote], iOption, LstrOptionResult, sizeof(LstrOptionResult));
		
		// Logging Vote
		LogToFileEx(g_sLogPath,
			"[Custom Votes] Vote %s started by %s ( %s ). Selected Option: %s",
			LogstrName,
			LogstrVoterName,
			LstrVoterAuth,
			LstrOptionResult);
	}

	new Handle:hMenu = CreateMenu(VoteHandler_List);

	decl String:strOption[MAX_NAME_LENGTH];
	decl String:strBuffer[MAX_NAME_LENGTH + 12];

	GetArrayString(g_hArrayVoteOptionName[iVote], iOption, strOption, sizeof(strOption));
	Format(strBuffer, sizeof(strBuffer), "%s (%s)", g_strVoteName[iVote], strOption);

	SetMenuTitle(hMenu, "%s", strBuffer);
	SetMenuExitButton(hMenu, false);

	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	if(GetRandomInt(1, 2) == 1)
	{
		AddMenuItem(hMenu, "Yes", "Yes");
		AddMenuItem(hMenu, "No", "No");
	}
	else
	{
	AddMenuItem(hMenu, "No", "No");
	AddMenuItem(hMenu, "Yes", "Yes");
	}

	g_iCurrentVoteIndex = iVote;
	g_iCurrentVoteOption = iOption;
	VoteMenu(hMenu, iPlayers, iTotal, 30);
}

public VoteHandler_List(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strInfo[16];
		GetMenuItem(hMenu, iParam2, strInfo, sizeof(strInfo));

		if(StrEqual(strInfo, "Yes"))
		{
			g_bVoteForOption[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteOption] = true;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatOptionString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
		else if(StrEqual(strInfo, "No"))
		{
			g_bVoteForOption[iVoter][g_iCurrentVoteIndex][g_iCurrentVoteOption] = false;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				FormatOptionString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));

				ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "No", true);
				ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "no", true);

				CPrintToChatAll("%s", strNotification);
			}
		}
	}
	else if(iAction == MenuAction_VoteEnd)
	{
		if(!CheckVotesForOption(g_iCurrentVoteIndex, g_iCurrentVoteOption) && g_strVoteFailNotify[g_iCurrentVoteIndex][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteFailNotify[g_iCurrentVoteIndex]);

			FormatVoteString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));
			FormatOptionString(g_iCurrentVoteIndex, g_iCurrentVoteOption, strNotification, sizeof(strNotification));

			CPrintToChatAll("%s", strNotification);
		}
		g_iCurrentVoteOption = -1;
		g_iCurrentVoteIndex = -1;
	}
}

public CastSimpleVote(iVote, iVoter)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	if(g_strVoteOverride[iVote][0] && !CheckCommandAccess(iVoter, g_strVoteOverride[iVote], 0))
	{
		CPrintToChat(iVoter, "[SM] %t", "No Access");
		return;
	}

	if(g_iVoteRemaining[iVoter][iVote] <= 0 && g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "No Votes Remaining");
		return;
	}

	if(g_iVotePasses[iVote] >= g_iVoteMaxPasses[iVote] && g_iVoteMaxPasses[iVote] > 0)
	{
		CPrintToChat(iVoter, "%t", "Voting No Longer Available");
		return;
	}

	if(g_iMapTime < g_iVoteDelay[iVote])
	{
		CPrintToChat(iVoter, "%t", "Vote Delay", g_iVoteDelay[iVote] - g_iMapTime);
		return;
	}

	new iTime = GetTime();
	if(iTime - g_iVoteLast[iVoter][iVote] < g_iVoteCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteCooldown[iVote] - (iTime - g_iVoteLast[iVoter][iVote]));
		return;
	}
	
	if(iTime - g_iVoteAllLast[iVote] < g_iVoteAllCooldown[iVote] && !CheckCommandAccess(iVoter, "customvotes_cooldown", ADMFLAG_GENERIC))
	{
		CPrintToChat(iVoter, "%t", "Vote Cooldown", g_iVoteAllCooldown[iVote] - (iTime - g_iVoteAllLast[iVote]));
		return;
	}

	if(g_iVoteMaxCalls[iVote] > 0 && !CheckCommandAccess(iVoter, "customvotes_maxvotes", ADMFLAG_GENERIC))
	{
		g_iVoteRemaining[iVoter][iVote]--;
		CPrintToChat(iVoter, "%t", "Votes Remaining", g_iVoteRemaining[iVoter][iVote]);
	}

	g_iVoteLast[iVoter][iVote] = iTime;
	g_iVoteAllLast[iVote] = iTime;
	if(g_bVoteCallVote[iVote])
	{
		Vote_Simple(iVote, iVoter);
		return;
	}

	g_bVoteForSimple[iVoter][iVote] = true;
	if(g_strVoteCallNotify[iVote][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[iVote]);

		FormatVoteString(iVote, _, strNotification, sizeof(strNotification));
		FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));

		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
		}

		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

		CPrintToChatAll("%s", strNotification);
	}

	CheckVotesForSimple(iVote);
	Menu_ChooseVote(iVoter);
}

public Vote_Simple(iVote, iVoter)
{
	if(IsVoteInProgress())
	{
		CPrintToChat(iVoter, "[SM] %t", "Vote in Progress");
		return;
	}

	new iPlayers[MAXPLAYERS + 1];
	new iTotal;
	
	if (bAfkManagerEnable && g_bAfkManager)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForSimple[i][iVote] = false;
			if(IsClientInGame(i) && !IsFakeClient(i) && !IsAFKClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	else
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			g_bVoteForSimple[i][iVote] = false;	
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				iPlayers[iTotal++] = i;
			}
		}
	}
	if(g_iVoteMinimum[iVote] > iTotal || iTotal <= 0)
	{
		CPrintToChat(iVoter, "%t", "Not Enough Valid Clients");
		return;
	}

	if(g_strVoteStartNotify[iVote][0])
	{
		decl String:strNotification[255];
		strcopy(strNotification, sizeof(strNotification), g_strVoteStartNotify[iVote]);

		FormatVoteString(iVote, _, strNotification, sizeof(strNotification));
		FormatVoterString(iVote, iVoter, strNotification, sizeof(strNotification));

		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
			ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
		}

		ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
		ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

		CPrintToChatAll("%s", strNotification);
		
		// get vote name
		decl String:LogstrName[56];
		strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
		
		// get voter's name
		decl String:LogstrVoterName[MAX_NAME_LENGTH];
		GetClientName(iVoter, LogstrVoterName, sizeof(LogstrVoterName));
		
		// get voter's SteamID
		decl String:LstrVoterAuth[MAX_NAME_LENGTH];
		GetClientAuthId(iVoter, AuthId_Steam2, LstrVoterAuth, sizeof(LstrVoterAuth));
		
		// Logging Vote
		LogToFileEx(g_sLogPath,
			"[Custom Votes] Vote %s started by %s ( %s ).",
			LogstrName,
			LogstrVoterName,
			LstrVoterAuth);
	}

	new Handle:hMenu = CreateMenu(VoteHandler_Simple);

	decl String:strName[56];
	strcopy(strName, sizeof(strName), g_strVoteName[iVote]);

	if(g_iVoteType[iVote] == VoteType_Simple)
	{
		if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
		{
			ReplaceString(strName, sizeof(strName), "{On|Off}", "Off", true);
			ReplaceString(strName, sizeof(strName), "{on|off}", "off", true);
		}
		else
		{
			ReplaceString(strName, sizeof(strName), "{On|Off}", "On", true);
			ReplaceString(strName, sizeof(strName), "{on|off}", "on", true);
		}
	}

	SetMenuTitle(hMenu, "%s", strName);
	SetMenuExitButton(hMenu, false);

	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	AddMenuItem(hMenu, "", " ", ITEMDRAW_NOTEXT);
	if(GetRandomInt(1, 2) == 1)
	{
		AddMenuItem(hMenu, "Yes", "Yes");
		AddMenuItem(hMenu, "No", "No");
	}
	else
	{
	AddMenuItem(hMenu, "No", "No");
	AddMenuItem(hMenu, "Yes", "Yes");
	}

	g_iCurrentVoteIndex = iVote;
	VoteMenu(hMenu, iPlayers, iTotal, 30);
}

public VoteHandler_Simple(Handle:hMenu, MenuAction:iAction, iVoter, iParam2)
{
	if(iAction == MenuAction_End)
	{
		CloseHandle(hMenu);
		return;
	}

	if(iAction == MenuAction_Select)
	{
		decl String:strInfo[16];
		GetMenuItem(hMenu, iParam2, strInfo, sizeof(strInfo));

		if(StrEqual(strInfo, "Yes"))
		{
			g_bVoteForSimple[iVoter][g_iCurrentVoteIndex] = true;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, _, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				
				// prevents GetConVarBool if we don't have a convar
				if(!StrEqual(g_strVoteConVar[g_iCurrentVoteIndex],""))
				{

					if(GetConVarBool(FindConVar(g_strVoteConVar[g_iCurrentVoteIndex])))
					{
						ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
						ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
					}
					else
					{
						ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
						ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
					}
				
				}
				else
				{

					ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "Yes", true);
					ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "yes", true);

					CPrintToChatAll("%s", strNotification);
				
				}
			}
		}
		else if(StrEqual(strInfo, "No"))
		{
			g_bVoteForSimple[iVoter][g_iCurrentVoteIndex] = false;
			if(g_strVoteCallNotify[g_iCurrentVoteIndex][0])
			{
				decl String:strNotification[255];
				strcopy(strNotification, sizeof(strNotification), g_strVoteCallNotify[g_iCurrentVoteIndex]);

				FormatVoteString(g_iCurrentVoteIndex, _, strNotification, sizeof(strNotification));
				FormatVoterString(g_iCurrentVoteIndex, iVoter, strNotification, sizeof(strNotification));
				
				if(!StrEqual(g_strVoteConVar[g_iCurrentVoteIndex],""))
				{

					if(GetConVarBool(FindConVar(g_strVoteConVar[g_iCurrentVoteIndex])))
					{
						ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
						ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
					}
					else
					{
						ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
						ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
					}
				
				}
				else
				{

					ReplaceString(strNotification, sizeof(strNotification), "{Yes|No}", "No", true);
					ReplaceString(strNotification, sizeof(strNotification), "{yes|no}", "no", true);

					CPrintToChatAll("%s", strNotification);
				
				}
			}
		}
	}
	else if(iAction == MenuAction_VoteEnd)
	{
		if(!CheckVotesForSimple(g_iCurrentVoteIndex) && g_strVoteFailNotify[g_iCurrentVoteIndex][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVoteFailNotify[g_iCurrentVoteIndex]);

			FormatVoteString(g_iCurrentVoteIndex, _, strNotification, sizeof(strNotification));

			CPrintToChatAll("%s", strNotification);
		}
		g_iCurrentVoteIndex = -1;
	}
}

// Reset vote at wave failure.
public Action:TF_WaveFailed(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(bResetOnWaveFailed)
	{
		for(new iVote = 0; iVote < MAX_VOTE_TYPES; iVote++)
		{
			g_iVotePasses[iVote] = 0;
		}
	}
	
	if(bDebugMode) // If debug is enabled, log events
	{
		LogToFileEx(g_sLogPath,
			"[Custom Votes] DEBUG: Event TF_WaveFailed.");
	}
}
// Cancel votes on Game Over (TF2)
public Action:TF_TeamPlayWinPanel(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(bCancelVoteGameEnd)
	{
		//g_bMapEnded = true;
		if(IsVoteInProgress()) // is vote in progress?
		{
			CancelVote(); // cancel any running votes on map end.
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Map end while a vote was in progress, canceling vote.");
		}
	}
	
	if(bDebugMode) // If debug is enabled, log events
	{
		LogToFileEx(g_sLogPath,
			"[Custom Votes] DEBUG: Event TF_TeamPlayWinPanel. bCancelVoteGameEnd: %d IsVoteInProgress: %d", bCancelVoteGameEnd, IsVoteInProgress());
	}
}
public Action:TF_ArenaWinPanel(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(bCancelVoteGameEnd)
	{
		//g_bMapEnded = true;
		if(IsVoteInProgress()) // is vote in progress?
		{
			CancelVote(); // cancel any running votes on map end.
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Map end while a vote was in progress, canceling vote.");
		}
	}
	
	if(bDebugMode) // If debug is enabled, log events
	{
		LogToFileEx(g_sLogPath,
			"[Custom Votes] DEBUG: Event TF_ArenaWinPanel. bCancelVoteGameEnd: %d IsVoteInProgress: %d", bCancelVoteGameEnd, IsVoteInProgress());
	}
}
public Action:TF_MVMWinPanel(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(bCancelVoteGameEnd)
	{
		//g_bMapEnded = true;
		if(IsVoteInProgress()) // is vote in progress?
		{
			CancelVote(); // cancel any running votes on map end.
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Map end while a vote was in progress, canceling vote.");
		}
	}
	
	if(bDebugMode) // If debug is enabled, log events
	{
		LogToFileEx(g_sLogPath,
			"[Custom Votes] DEBUG: Event TF_MVMWinPanel. bCancelVoteGameEnd: %d IsVoteInProgress: %d", bCancelVoteGameEnd, IsVoteInProgress());
	}
}
// Cancel votes on round end (CSGO)
public Action:CSGO_MapEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(bCancelVoteGameEnd)
	{
		//g_bMapEnded = true;
		if(IsVoteInProgress()) // is vote in progress?
		{
			CancelVote(); // cancel any running votes on map end.
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Map end while a vote was in progress, canceling vote.");
		}
	}
	
	if(bDebugMode) // If debug is enabled, log events
	{
		LogToFileEx(g_sLogPath,
			"[Custom Votes] DEBUG: Event CSGO_MapEnd. bCancelVoteGameEnd: %d IsVoteInProgress: %d", bCancelVoteGameEnd, IsVoteInProgress());
	}
}

public Action:OnLogAction(Handle:source, Identity:ident, client, target, const String:message[])
{
	if((StrContains(message, "changed map to") != -1) && bCancelVoteGameEnd && IsVoteInProgress())
	{
		//g_bMapEnded = true;
		CancelVote(); // cancel any running votes on map end.
		LogToFileEx(g_sLogPath,
			"[Custom Votes] Map manually changed while a vote was in progress, canceling vote.");
	}
}

// ====[ FUNCTIONS ]===========================================================
public Config_Load()
{
	if(!FileExists(g_strConfigFile))
	{
		SetFailState("Configuration file %s not found!", g_strConfigFile);
		return;
	}

	new Handle:hKeyValues = CreateKeyValues("Custom Votes");
	if(!FileToKeyValues(hKeyValues, g_strConfigFile) || !KvGotoFirstSubKey(hKeyValues))
	{
		SetFailState("Improper structure for configuration file %s!", g_strConfigFile);
		return;
	}

	g_iVoteCount = 0;
	g_iCurrentVoteIndex = -1;
	g_iCurrentVoteTarget = -1;
	g_iCurrentVoteMap = -1;
	g_iCurrentVoteOption = -1;

	strcopy(g_strVoteTargetIndex, sizeof(g_strVoteTargetIndex), "");
	strcopy(g_strVoteTargetId, sizeof(g_strVoteTargetId), "");
	strcopy(g_strVoteTargetAuth, sizeof(g_strVoteTargetAuth), "");
	strcopy(g_strVoteTargetName, sizeof(g_strVoteTargetName), "");

	for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		g_iVoteCurrent[iVoter] = -1;

	for(new iVote = 0; iVote < MAX_VOTE_TYPES; iVote++)
	{
		g_iVoteDelay[iVote] = 0;
		g_iVoteMinimum[iVote] = 0;
		g_iVoteImmunity[iVote] = 0;
		g_iVoteMaxCalls[iVote] = 0;
		g_iVotePasses[iVote] = 0;
		g_iVoteMaxPasses[iVote] = 0;
		g_iVoteMapRecent[iVote] = 0;
		g_bVoteCallVote[iVote] = false;
		g_bVotePlayersBots[iVote] = false;
		g_bVotePlayersTeam[iVote] = false;
		g_bVoteMapCurrent[iVote] = false;
		g_bVoteMultiple[iVote] = false;
		g_flVoteRatio[iVote] = 0.0;
		strcopy(g_strVoteName[iVote], sizeof(g_strVoteName[]), "");
		strcopy(g_strVoteConVar[iVote], sizeof(g_strVoteConVar[]), "");
		strcopy(g_strVoteOverride[iVote], sizeof(g_strVoteOverride[]), "");
		strcopy(g_strVoteCommand[iVote], sizeof(g_strVoteCommand[]), "");
		strcopy(g_strVoteChatTrigger[iVote], sizeof(g_strVoteChatTrigger[]), "");
		strcopy(g_strVoteStartNotify[iVote], sizeof(g_strVoteStartNotify[]), "");
		strcopy(g_strVoteCallNotify[iVote], sizeof(g_strVoteCallNotify[]), "");
		strcopy(g_strVotePassNotify[iVote], sizeof(g_strVotePassNotify[]), "");
		strcopy(g_strVoteFailNotify[iVote], sizeof(g_strVoteFailNotify[]), "");

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
		{
			g_iVoteRemaining[iVoter][iVote] = 0;
			g_iVoteLast[iVoter][iVote] = 0;
			g_iVoteAllLast[iVote] = 0;
			for(new iTarget = 1; iTarget <= MaxClients; iTarget++)
			{
				g_bVoteForTarget[iTarget][iVote][iVoter] = false;
				g_bVoteForTarget[iVoter][iVote][iTarget] = false;
			}

			for(new iMap = 0; iMap < MAX_VOTE_MAPS; iMap++)
				g_bVoteForMap[iVoter][iVote][iMap] = false;

			for(new iOption = 0; iOption < MAX_VOTE_OPTIONS; iOption++)
				g_bVoteForOption[iVoter][iVote][iOption] = false;

			g_bVoteForSimple[iVoter][iVote] = false;

			if(g_hArrayVotePlayerSteamID[iVoter][iVote] != INVALID_HANDLE)
			{
				CloseHandle(g_hArrayVotePlayerSteamID[iVoter][iVote]);
				g_hArrayVotePlayerSteamID[iVoter][iVote] = INVALID_HANDLE;
			}

			if(g_hArrayVotePlayerIP[iVoter][iVote] != INVALID_HANDLE)
			{
				CloseHandle(g_hArrayVotePlayerIP[iVoter][iVote]);
				g_hArrayVotePlayerIP[iVoter][iVote] = INVALID_HANDLE;
			}
		}

		if(g_hArrayVoteOptionName[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteOptionName[iVote]);
			g_hArrayVoteOptionName[iVote] = INVALID_HANDLE;
		}

		if(g_hArrayVoteOptionResult[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteOptionResult[iVote]);
			g_hArrayVoteOptionResult[iVote] = INVALID_HANDLE;
		}

		if(g_hArrayVoteMapList[iVote] != INVALID_HANDLE)
		{
			CloseHandle(g_hArrayVoteMapList[iVote]);
			g_hArrayVoteMapList[iVote] = INVALID_HANDLE;
		}
	}

	new iVote;
	do
	{
		// Name of vote
		KvGetSectionName(hKeyValues, g_strVoteName[iVote], sizeof(g_strVoteName[]));

		// Type of vote (Valid types: players, map, list)
		decl String:strType[24];
		KvGetString(hKeyValues, "type", strType, sizeof(strType));

		if(StrEqual(strType, "players"))
			g_iVoteType[iVote] = VoteType_Players;
		else if(StrEqual(strType, "map"))
			g_iVoteType[iVote] = VoteType_Map;
		else if(StrEqual(strType, "list"))
			g_iVoteType[iVote] = VoteType_List;
		else if(StrEqual(strType, "simple"))
			g_iVoteType[iVote] = VoteType_Simple;
		else
		{
			LogError("Invalid vote type for vote %s", g_strVoteName[iVote]);
			continue;
		}

		// Determine if a vote is called to determine the result of the selection, or if each selection is chosen  manually by the players
		g_bVoteCallVote[iVote] = bool:KvGetNum(hKeyValues, "vote");

		// Delay in seconds before players vote after the map has changed
		g_iVoteDelay[iVote] = KvGetNum(hKeyValues, "delay");

		// Delay in seconds before players can vote again after casting a selection
		g_iVoteCooldown[iVote] = KvGetNum(hKeyValues, "cooldown");
		
		// Delay in seconds before all players can vote again after casting a selection
		g_iVoteAllCooldown[iVote] = KvGetNum(hKeyValues, "cooldownall");

		// Minimum votes required for the vote to pass (Overrides ratio)
		g_iVoteMinimum[iVote] = KvGetNum(hKeyValues, "minimum");

		// Admins with equal or higher immunity are removed from the vote
		g_iVoteImmunity[iVote] = KvGetNum(hKeyValues, "immunity");

		// Maximum times a player can vote
		g_iVoteMaxCalls[iVote] = KvGetNum(hKeyValues, "maxcalls");
		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_iVoteRemaining[iVoter][iVote] = g_iVoteMaxCalls[iVote];

		// Maximum times a player can cast a selection
		g_iVoteMaxPasses[iVote] = KvGetNum(hKeyValues, "maxpasses");

		// Allow/disallow players from casting a selection on more than one option
		g_bVoteMultiple[iVote] = bool:KvGetNum(hKeyValues, "multiple");

		// Ratio of players required to cast a selection for the vote to pass
		g_flVoteRatio[iVote] = KvGetFloat(hKeyValues, "ratio");

		// Control variable being changed
		KvGetString(hKeyValues, "cvar", g_strVoteConVar[iVote], sizeof(g_strVoteConVar[]));

		// Admin override (Use this with admin_overrides.cfg to prohibit access from specific players)
		KvGetString(hKeyValues, "override", g_strVoteOverride[iVote], sizeof(g_strVoteOverride[]));

		// Command(s) ran when a vote is passed
		KvGetString(hKeyValues, "command", g_strVoteCommand[iVote], sizeof(g_strVoteCommand[]));

		// Chat trigger to open the vote selections (Do not include ! or / in the trigger)
		KvGetString(hKeyValues, "chattrigger", g_strVoteChatTrigger[iVote], sizeof(g_strVoteChatTrigger[]));

		// Printed to everyone's chat when a player starts a vote
		KvGetString(hKeyValues, "start_notify", g_strVoteStartNotify[iVote], sizeof(g_strVoteStartNotify[]));

		// Printed to everyone's chat when a player casts a selection
		KvGetString(hKeyValues, "call_notify", g_strVoteCallNotify[iVote], sizeof(g_strVoteCallNotify[]));

		// Printed to everyone's chat when the vote passes
		KvGetString(hKeyValues, "pass_notify", g_strVotePassNotify[iVote], sizeof(g_strVotePassNotify[]));

		// Printed to everyone's chat when the vote fails to pass
		KvGetString(hKeyValues, "fail_notify", g_strVoteFailNotify[iVote], sizeof(g_strVoteFailNotify[]));

		switch(g_iVoteType[iVote])
		{
			case VoteType_Players:
			{
				// Allows/disallows casting selections on bots
				g_bVotePlayersBots[iVote] = bool:KvGetNum(hKeyValues, "bots");

				// Restricts players to only casting selections on team members
				g_bVotePlayersTeam[iVote] = bool:KvGetNum(hKeyValues, "team");

				for(new iTarget = 0; iTarget <= MaxClients; iTarget++)
				{
					g_hArrayVotePlayerSteamID[iTarget][iVote] = CreateArray(MAX_NAME_LENGTH);
					g_hArrayVotePlayerIP[iTarget][iVote] = CreateArray(MAX_NAME_LENGTH);
				}
			}
			case VoteType_Map:
			{
				// How many recent maps will be removed from the vote selections
				g_iVoteMapRecent[iVote] = KvGetNum(hKeyValues, "recentmaps");

				// Allows/disallows casting selections on the current map
				g_bVoteMapCurrent[iVote] = bool:KvGetNum(hKeyValues, "currentmap");

				// List of maps to populate the selection list
				decl String:strMapList[24];
				KvGetString(hKeyValues, "maplist", strMapList, sizeof(strMapList), "default");

				g_hArrayVoteMapList[iVote] = CreateArray(MAX_NAME_LENGTH);
				ReadMapList(g_hArrayVoteMapList[iVote], _, strMapList, MAPLIST_FLAG_CLEARARRAY);
			}
			case VoteType_List:
			{
				if(!KvGotoFirstSubKey(hKeyValues, false))
					continue;

				do
				{
					if(!KvGotoFirstSubKey(hKeyValues, false))
						continue;

					g_hArrayVoteOptionName[iVote] = CreateArray(16);
					g_hArrayVoteOptionResult[iVote] = CreateArray(16);
					do
					{
						// Vote option name
						decl String:strOptionName[MAX_NAME_LENGTH];
						KvGetSectionName(hKeyValues, strOptionName, sizeof(strOptionName));
						PushArrayString(g_hArrayVoteOptionName[iVote], strOptionName);

						// Vote option result
						decl String:strOptionResult[MAX_NAME_LENGTH];
						KvGetString(hKeyValues, NULL_STRING, strOptionResult, sizeof(strOptionResult));
						PushArrayString(g_hArrayVoteOptionResult[iVote], strOptionResult);
					}
					while(KvGotoNextKey(hKeyValues, false));
					KvGoBack(hKeyValues);
				}
				while(KvGotoNextKey(hKeyValues, false));
				KvGoBack(hKeyValues);
			}
		}
		iVote++;
	}
	while(KvGotoNextKey(hKeyValues, false));
	CloseHandle(hKeyValues);

	g_iVoteCount = iVote;
	LogMessage("Configuration file %s loaded.", g_strConfigFile);
}

public bool:CheckVotesForTarget(iVote, iTarget)
{

	new iVotes = GetVotesForTarget(iVote, iTarget);
	new iRequired = GetRequiredVotes(iVote);
	
/* 	if(g_bMapEnded) // if the map ended, always return false
	{
		return false;
	} */

	if(iVotes >= iRequired)
	{
		g_iVotePasses[iVote]++;

		if(g_strVoteCommand[iVote][0])
		{
			decl String:strCommand[255];
			strcopy(strCommand, sizeof(strCommand), g_strVoteCommand[iVote]);

			FormatTargetString(iVote, iTarget, strCommand, sizeof(strCommand));
			ServerCommand(strCommand);
		}

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_bVoteForTarget[iVoter][iVote][iTarget] = false;

		if(g_strVotePassNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVotePassNotify[iVote]);

			FormatTargetString(iVote, iTarget, strNotification, sizeof(strNotification));
			CPrintToChatAll("%s", strNotification);
			
			// get vote name
			decl String:LogstrName[56];
			strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
			
			// get target's name
			decl String:LogstrTargetName[MAX_NAME_LENGTH];
			GetClientName(iTarget, LogstrTargetName, sizeof(LogstrTargetName));
			
			// get target's SteamID
			decl String:LstrTargetAuth[MAX_NAME_LENGTH];
			GetClientAuthId(iTarget, AuthId_Steam2, LstrTargetAuth, sizeof(LstrTargetAuth));
			
			// Logging Vote
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Last vote ( %s ) passed. The Target was: %s ( %s ).",
				LogstrName,
				LogstrTargetName,
				LstrTargetAuth);
		}
		return true;
	}
	return false;
}

public bool:CheckVotesForMap(iVote, iMap)
{
	new iVotes = GetVotesForMap(iVote, iMap);
	new iRequired = GetRequiredVotes(iVote);
	
/* 	if(g_bMapEnded) // if the map ended, always return false
	{
		return false;
	} */

	if(iVotes >= iRequired)
	{
		g_iVotePasses[iVote]++;

		if(g_strVoteCommand[iVote][0])
		{
			decl String:strCommand[255];
			strcopy(strCommand, sizeof(strCommand), g_strVoteCommand[iVote]);

			FormatMapString(iVote, iMap, strCommand, sizeof(strCommand));
			ServerCommand(strCommand);
		}

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_bVoteForMap[iVoter][iVote][iMap] = false;

		if(g_strVotePassNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVotePassNotify[iVote]);

			FormatMapString(iVote, iMap, strNotification, sizeof(strNotification));
			CPrintToChatAll("%s", strNotification);
			
			// get vote name
			decl String:LogstrName[56];
			strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
			
			// get current map name
			decl String:LogstrCurrentMap[MAX_NAME_LENGTH];
			GetCurrentMap(LogstrCurrentMap, sizeof(LogstrCurrentMap));
			
			// get target map name
			decl String:LogstrMap[MAX_NAME_LENGTH];
			GetArrayString(g_hArrayVoteMapList[iVote], iMap, LogstrMap, sizeof(LogstrMap));
			
			// Logging Vote
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Last vote ( %s ) passed. Map was changed from %s to %s.",
				LogstrName,
				LogstrCurrentMap,
				LogstrMap);
		}
		return true;
	}
	return false;
}

public bool:CheckVotesForOption(iVote, iOption)
{
	new iVotes = GetVotesForOption(iVote, iOption);
	new iRequired = GetRequiredVotes(iVote);
	
/* 	if(g_bMapEnded) // if the map ended, always return false
	{
		return false;
	} */

	if(iVotes >= iRequired)
	{
		g_iVotePasses[iVote]++;

		if(g_strVoteCommand[iVote][0])
		{
			decl String:strCommand[255];
			strcopy(strCommand, sizeof(strCommand), g_strVoteCommand[iVote]);

			FormatOptionString(iVote, iOption, strCommand, sizeof(strCommand));
			ServerCommand(strCommand);
		}

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_bVoteForOption[iVoter][iVote][iOption] = false;

		if(g_strVotePassNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVotePassNotify[iVote]);

			FormatOptionString(iVote, iOption, strNotification, sizeof(strNotification));
			CPrintToChatAll("%s", strNotification);
			
			// get vote name
			decl String:LogstrName[56];
			strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
			
			// get vote option
			decl String:LstrOptionResult[MAX_NAME_LENGTH];
			GetArrayString(g_hArrayVoteOptionResult[iVote], iOption, LstrOptionResult, sizeof(LstrOptionResult));
			
			// Logging Vote
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Last vote ( %s ) passed. ( Option: %s ).",
				LogstrName,
				LstrOptionResult);
		}
		return true;
	}
	return false;
}

public bool:CheckVotesForSimple(iVote)
{
	new iVotes = GetVotesForSimple(iVote);
	new iRequired = GetRequiredVotes(iVote);
	
/* 	if(g_bMapEnded) // if the map ended, always return false
	{
		return false;
	} */

	if(iVotes >= iRequired)
	{
		g_iVotePasses[iVote]++;

		if(g_strVoteCommand[iVote][0])
		{
			decl String:strCommand[255];
			strcopy(strCommand, sizeof(strCommand), g_strVoteCommand[iVote]);

			if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
				ReplaceString(strCommand, sizeof(strCommand), "{On|Off}", "0", false);
			else
				ReplaceString(strCommand, sizeof(strCommand), "{On|Off}", "1", false);

			FormatVoteString(iVote, _, strCommand, sizeof(strCommand));
			ServerCommand(strCommand);
		}

		for(new iVoter = 1; iVoter <= MaxClients; iVoter++)
			g_bVoteForSimple[iVoter][iVote] = false;

		if(g_strVotePassNotify[iVote][0])
		{
			decl String:strNotification[255];
			strcopy(strNotification, sizeof(strNotification), g_strVotePassNotify[iVote]);

			if(g_strVoteConVar[iVote][0] && GetConVarBool(FindConVar(g_strVoteConVar[iVote])))
			{
				ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "Off", true);
				ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "off", true);
			}
			else
			{
				ReplaceString(strNotification, sizeof(strNotification), "{On|Off}", "On", true);
				ReplaceString(strNotification, sizeof(strNotification), "{on|off}", "on", true);
			}

			FormatVoteString(iVote, _, strNotification, sizeof(strNotification));
			CPrintToChatAll("%s", strNotification);

			// get vote name
			decl String:LogstrName[56];
			strcopy(LogstrName, sizeof(LogstrName), g_strVoteName[iVote]);
			
			// Logging Vote
			LogToFileEx(g_sLogPath,
				"[Custom Votes] Last vote ( %s ) passed.",
				LogstrName);
		}
		return true;
	}
	return false;
}

public GetVotesForTarget(iVote, iTarget)
{
	new iCount;
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		if(g_bVoteForTarget[iVoter][iVote][iTarget])
			iCount++;
	}
	return iCount;
}

public GetVotesForMap(iVote, iMap)
{
	new iCount;
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		if(g_bVoteForMap[iVoter][iVote][iMap])
			iCount++;
	}
	return iCount;
}

public GetVotesForOption(iVote, iOption)
{
	new iCount;
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		if(g_bVoteForOption[iVoter][iVote][iOption])
			iCount++;
	}
	return iCount;
}

public GetVotesForSimple(iVote)
{
	new iCount;
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		if(g_bVoteForSimple[iVoter][iVote])
			iCount++;
	}
	return iCount;
}

public GetRequiredVotes(iVote)
{
	new iCount;
	for(new iVoter = 1; iVoter <= MaxClients; iVoter++) if(IsClientInGame(iVoter))
	{
		if(!IsFakeClient(iVoter))
			iCount++;
	}

	new iRequired = RoundToCeil(float(iCount) * g_flVoteRatio[iVote]);
	if(iRequired < g_iVoteMinimum[iVote])
		iRequired = g_iVoteMinimum[iVote];

	if(iRequired < 1)
		iRequired = 1;

	return iRequired;
}

// ====[ TIMERS ]==============================================================
public Action:Timer_Second(Handle:hTimer)
{
	g_iMapTime++;
}

// ====[ STOCKS ]==============================================================
stock bool:IsValidClient(iClient)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient))
		return false;
	return true;
}
stock bool:IsAFKClient(iClient)
{
	if(AFKM_GetClientAFKTime(iClient) >= iAfkTime)
		return true;
	return false;
 }
stock FormatVoterString(iVote, iVoter, String:strBuffer[], iBufferSize)
{
	decl String:strVoter[MAX_NAME_LENGTH];
	IntToString(iVoter, strVoter, sizeof(strVoter));

	ReplaceString(strBuffer, iBufferSize, "{VOTER_INDEX}", strVoter, false);

	decl String:strVoterId[MAX_NAME_LENGTH];
	IntToString(GetClientUserId(iVoter), strVoterId, sizeof(strVoterId));

	ReplaceString(strBuffer, iBufferSize, "{VOTER_ID}", strVoterId, false);

	decl String:strVoterSteamId[MAX_NAME_LENGTH];
	GetClientAuthId(iVoter, AuthId_Steam2, strVoterSteamId, sizeof(strVoterSteamId));

	QuoteString(strVoterSteamId, sizeof(strVoterSteamId));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_STEAMID}", strVoterSteamId, false);

	decl String:strVoterName[MAX_NAME_LENGTH];
	GetClientName(iVoter, strVoterName, sizeof(strVoterName));

	QuoteString(strVoterName, sizeof(strVoterName));
	ReplaceString(strBuffer, iBufferSize, "{VOTER_NAME}", strVoterName, false);
}

stock FormatVoteString(iVote, iChoice = -1, String:strBuffer[], iBufferSize)
{
	decl String:strVoteAmount[MAX_NAME_LENGTH];
	switch(g_iVoteType[iVote])
	{
		case VoteType_Players: IntToString(GetVotesForTarget(iVote, iChoice), strVoteAmount, sizeof(strVoteAmount));
		case VoteType_Map: IntToString(GetVotesForMap(iVote, iChoice), strVoteAmount, sizeof(strVoteAmount));
		case VoteType_List: IntToString(GetVotesForOption(iVote, iChoice), strVoteAmount, sizeof(strVoteAmount));
		case VoteType_Simple: IntToString(GetVotesForSimple(iVote), strVoteAmount, sizeof(strVoteAmount));
	}

	QuoteString(strVoteAmount, sizeof(strVoteAmount));
	ReplaceString(strBuffer, iBufferSize, "{VOTE_AMOUNT}", strVoteAmount, false);

	decl String:strVoteRequired[MAX_NAME_LENGTH];
	IntToString(GetRequiredVotes(iVote), strVoteRequired, sizeof(strVoteRequired));

	QuoteString(strVoteRequired, sizeof(strVoteRequired));
	ReplaceString(strBuffer, iBufferSize, "{VOTE_REQUIRED}", strVoteRequired, false);
}

stock FormatTargetString(iVote, iTarget, String:strBuffer[], iBufferSize)
{
	// Check if target disconnected (Anti-Grief)
	if(!IsValidClient(iTarget))
	{
		decl String:strAntiGrief[255];
		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strVoteTargetIndex);
		ReplaceString(strBuffer, iBufferSize, "{TARGET_INDEX}", g_strVoteTargetIndex, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strVoteTargetId);
		ReplaceString(strBuffer, iBufferSize, "{TARGET_ID}", g_strVoteTargetId, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strVoteTargetAuth);
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_STEAMID}", g_strVoteTargetAuth, false);

		strcopy(strAntiGrief, sizeof(strAntiGrief), g_strVoteTargetName);
		QuoteString(strAntiGrief, sizeof(strAntiGrief));
		ReplaceString(strBuffer, iBufferSize, "{TARGET_NAME}", g_strVoteTargetName, false);
		return;
	}

	decl String:strTarget[MAX_NAME_LENGTH];
	IntToString(iTarget, strTarget, sizeof(strTarget));

	ReplaceString(strBuffer, iBufferSize, "{TARGET_INDEX}", strTarget, false);

	decl String:strTargetId[MAX_NAME_LENGTH];
	IntToString(GetClientUserId(iTarget), strTargetId, sizeof(strTargetId));

	ReplaceString(strBuffer, iBufferSize, "{TARGET_ID}", strTargetId, false);

	decl String:strTargetSteamId[MAX_NAME_LENGTH];
	GetClientAuthId(iTarget, AuthId_Steam2, strTargetSteamId, sizeof(strTargetSteamId));

	QuoteString(strTargetSteamId, sizeof(strTargetSteamId));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_STEAMID}", strTargetSteamId, false);

	decl String:strTargetName[MAX_NAME_LENGTH];
	GetClientName(iTarget, strTargetName, sizeof(strTargetName));

	QuoteString(strTargetName, sizeof(strTargetName));
	ReplaceString(strBuffer, iBufferSize, "{TARGET_NAME}", strTargetName, false);
}

stock FormatMapString(iVote, iMap, String:strBuffer[], iBufferSize)
{
	decl String:strMap[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteMapList[iVote], iMap, strMap, sizeof(strMap));

	QuoteString(strMap, sizeof(strMap));
	ReplaceString(strBuffer, iBufferSize, "{MAP_NAME}", strMap, false);

	decl String:strCurrentMap[MAX_NAME_LENGTH];
	GetCurrentMap(strCurrentMap, sizeof(strCurrentMap));

	QuoteString(strCurrentMap, sizeof(strCurrentMap));
	ReplaceString(strBuffer, iBufferSize, "{CURRENT_MAP_NAME}", strCurrentMap, false);
}

stock FormatOptionString(iVote, iOption, String:strBuffer[], iBufferSize)
{
	decl String:strOptionName[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteOptionName[iVote], iOption, strOptionName, sizeof(strOptionName));

	QuoteString(strOptionName, sizeof(strOptionName));
	ReplaceString(strBuffer, iBufferSize, "{OPTION_NAME}", strOptionName, false);

	decl String:strOptionResult[MAX_NAME_LENGTH];
	GetArrayString(g_hArrayVoteOptionResult[iVote], iOption, strOptionResult, sizeof(strOptionResult));

	QuoteString(strOptionResult, sizeof(strOptionResult));
	ReplaceString(strBuffer, iBufferSize, "{OPTION_RESULT}", strOptionResult, false);
}

stock QuoteString(String:strBuffer[], iBuffersize)
{
	Format(strBuffer, iBuffersize + 4, "\"%s\"", strBuffer);
}
