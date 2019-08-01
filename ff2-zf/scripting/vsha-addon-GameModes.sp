// vsha-addon-BossVsBossGameMode.sp

#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name 			= "Boss Game Modes Fight",
	author 			= "Valve",
	description 		= "Saxton Haaaaaaaaaaaaale",
	version 		= "1.1",
	url 			= "http://wiki.teamfortress.com/wiki/VS_Saxton_Hale_Mode"
}

ConVar ThisEnabled = null;
ConVar GameModeType = null;
ConVar GameModeMusicEnable = null;
ConVar RandomType = null;

int m_OffsetClrRender=-1;

int PreviousBossGame = 0;
int CurrentBossGame = 0;

// Themes
char BossVsBoss1[PATHX];
float BossVsBoss1Time = -1.0;

char DuoBoss1[PATHX];
float DuoBoss1Time = -1.0;

bool ThemeMusicIsPlaying = false;

#define ThisConfigurationFile "configs/vsha/gamemodes.cfg"

#define DuoBossGameMode		1
#define BossVsBossGameMode	2
#define RandomBossGameMode	999
//vsha_gamemode_type 2
public void OnPluginStart()
{
	m_OffsetClrRender=FindSendPropOffs("CBaseAnimating","m_clrRender");
	if(m_OffsetClrRender==-1)
	{
		PrintToServer("[VSHA] Error finding render color offset.");
	}

	ThisEnabled = CreateConVar("vsha_gamemode_enabled", "0", "Enable Game Modes", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	GameModeType = CreateConVar("vsha_gamemode_type", "0", "0 - default, 1 - Duo Boss, 2 - Boss vs Boss, 999 - Random", FCVAR_PLUGIN, true, 0.0, false);
	RandomType = CreateConVar("vsha_random_type", "1", "0 - disabled, 1 - not the same game twice", FCVAR_PLUGIN, true, 0.0, false);
	GameModeMusicEnable = CreateConVar("vsha_gamemode_music_enable", "0", "0 - disabled, 1 - enabled", FCVAR_PLUGIN, true, 0.0, false);
}

public void OnAllPluginsLoaded()
{
	if(!VSHAHookEx(VSHAHook_OnGameMode_BossSetup, OnGameMode_BossSetup))
	{
		LogError("Error loading VSHAHook_OnGameMode_BossSetup forwards for gamemodes.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_WatchGameModeTimer, OnGameMode_WatchGameModeTimer))
	{
		LogError("Error loading VSHAHook_OnGameMode_WatchGameModeTimer forwards for gamemodes.");
	}

	if(!VSHAHookEx(VSHAHook_OnGameMode_ForceBossTeamChange, OnGameMode_ForceBossTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForceBossTeamChange forwards for gamemodes.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameMode_ForcePlayerTeamChange, OnGameMode_ForcePlayerTeamChange))
	{
		LogError("Error loading VSHAHook_OnGameMode_ForcePlayerTeamChange forwards for gamemodes.");
	}

	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Sounds, OnConfiguration_Load_Sounds))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Sounds forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Misc, OnConfiguration_Load_Misc))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Misc forwards for saxton hale.");
	}

	if(!VSHAHookEx(VSHAHook_OnBossSetHP_Pre, OnBossSetHP_Pre))
	{
		LogError("Error loading VSHA_OnBossSetHP_Pre forwards for saxton hale.");
	}
	//if(!VSHAHookEx(VSHAHook_OnBossSetHP_Post, OnBossSetHP_Post))
	//{
		//LogError("Error loading VSHAHook_OnBossSetHP_Post forwards for saxton hale.");
	//}

	if(!VSHAHookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error loading VSHAHook_OnBossTimer forwards for saxton hale.");
	}

	if(!VSHAHookEx(VSHAHook_OnMessageTimer, OnMessageTimer))
	{
		LogError("Error loading VSHAHook_OnMessageTimer forwards for cbs.");
	}

	//if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	//{
		//LogError("Error loading VSHAHook_OnBossWin forwards for gamemodes.");
	//}

	if(!VSHAHookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error loading VSHAHook_OnMusic forwards for gamemodes.");
	}

	if(!VSHAHookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error loading VSHAHook_OnGameOver forwards for saxton hale.");
	}

	VSHAHook(VSHAHook_OnEquipPlayer_Post, OnEquipPlayer_Post);

	VSHA_LoadConfiguration(ThisConfigurationFile);
}

stock int CountBossTeam(int iiBoss)
{
	int iTeamCount = 0;
	LoopIsInTeam( GetClientTeam(iiBoss), iBossTeam)
	{
		iTeamCount++;
	}
}

stock int GetEntityAlpha(int index)
{
	return GetEntData(index,m_OffsetClrRender+3,1);
}

stock int GetPlayerR(int index)
{
	return GetEntData(index,m_OffsetClrRender,1);
}

stock int GetPlayerG(int index)
{
	return GetEntData(index,m_OffsetClrRender+1,1);
}

stock int GetPlayerB(int index)
{
	return GetEntData(index,m_OffsetClrRender+2,1);
}

stock int SetEntityAlpha(int index, int alpha)
{
	char class[32];
	GetEntityNetClass(index, class, sizeof(class) );
	if(FindSendPropOffs(class,"m_nRenderFX")>-1){
		SetEntityRenderMode(index,RENDER_TRANSCOLOR);
		SetEntityRenderColor(index,GetPlayerR(index),GetPlayerG(index),GetPlayerB(index),alpha);
	}
}

stock void SetPlayerRGB(int index, int r, int g, int b)
{
	SetEntityRenderMode(index,RENDER_TRANSCOLOR);
	SetEntityRenderColor(index,r,g,b,GetEntityAlpha(index));
}


public Action OnGameMode_ForceBossTeamChange(VSHA_EVENTS vshaEvent, int iiBoss, int iTeam)
{
	//VSHA_IsBossPlayer(iiBoss)
	if(!ThisEnabled.BoolValue) return Plugin_Continue;
	if(CurrentBossGame == 0) return Plugin_Continue;

	if(CurrentBossGame == DuoBossGameMode)
	{
		switch(vshaEvent)
		{
			case vshaRoundStart:
			{
				ForceTeamChange(iiBoss, TEAM_RED);
			}
			case vshaMakeBoss:
			{
				ForceTeamChange(iiBoss, TEAM_RED);
				TF2_RegeneratePlayer(iiBoss); // correct team colors
			}
			case vshaRoundEnd:
			{
				ForceTeamChange(iiBoss, TEAM_RED);
			}
		}
		return Plugin_Handled;
	}
	else if(CurrentBossGame == BossVsBossGameMode)
	{
		switch(vshaEvent)
		{
			case vshaRoundStart:
			{
				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_RED);
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_BLUE);
				}
			}
			case vshaMakeBoss:
			{
				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_RED);
					TF2_RegeneratePlayer(iiBoss); // correct team colors
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_BLUE);
					TF2_RegeneratePlayer(iiBoss); // correct team colors
				}
			}
			case vshaRoundEnd:
			{
				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_RED);
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iiBoss, TEAM_BLUE);
				}
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action OnGameMode_ForcePlayerTeamChange(VSHA_EVENTS vshaEvent, int iClient, int iTeam)
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;
	if(CurrentBossGame == 0) return Plugin_Continue;

	if(CurrentBossGame == DuoBossGameMode)
	{
		switch(vshaEvent)
		{
			case vshaRoundStart:
			{
				ForceTeamChange(iClient, TEAM_BLUE);
			}
			case vshaEquipPlayers:
			{
				ForceTeamChange(iClient, TEAM_BLUE);
				TF2_RegeneratePlayer(iClient); // correct team colors
			}
			case vshaRoundEnd:
			{
				ForceTeamChange(iClient, TEAM_BLUE);
			}
		}
	}
	else if(CurrentBossGame == BossVsBossGameMode)
	{
		switch(vshaEvent)
		{
			case vshaRoundStart:
			{
				char sClientName[32];
				GetClientName(iClient,STRING(sClientName));
				//LogError("ERROR: Player %s found not marked as boss on BossVsBossGameMode event vshaRoundStart",sClientName);
				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_RED);
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_BLUE);
				}
			}
			case vshaEquipPlayers:
			{
				char sClientName[32];
				GetClientName(iClient,STRING(sClientName));
				//LogError("ERROR: Player %s found not marked as boss on BossVsBossGameMode event vshaEquipPlayers",sClientName);

				int boss = VSHA_AddBoss(iClient);

				//LogError("VSHA_AddBoss vshaEquipPlayers BossVsBossGameMode ForcePlayerTeamChange boss = %d",boss);
				//sm plugins reload vsha-addon-GameModes.smx
				if(boss == -1)
				{
					//LogError("ERROR: Player %s unable to make boss. vshaEquipPlayers BossVsBossGameMode ",sClientName);
					return Plugin_Handled;
				}

				VSHA_BossSelected_Forward(boss);

				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_RED);
					TF2_RegeneratePlayer(iClient); // correct team colors
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_BLUE);
					TF2_RegeneratePlayer(iClient); // correct team colors
				}
			}
			case vshaRoundEnd:
			{
				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_RED);
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(iClient, TEAM_BLUE);
				}
			}
		}
	}
	return Plugin_Handled;
}

public Action OnGameMode_WatchGameModeTimer()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;
	if(CurrentBossGame == 0) return Plugin_Continue;

	if(GameModeType.IntValue > 0 || CurrentBossGame > 0)
	{
		if(VSHA_GetPlayerCount()>1)
		{
			if(GetTeamPlayerCount(TEAM_BLUE)<=0 || GetTeamPlayerCount(TEAM_RED)<=0)
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
					{
						if(GetTeamPlayerCount(TEAM_BLUE)<=0)
						{
							ForceTeamChange(i, TEAM_BLUE);
						}
						else if(GetTeamPlayerCount(TEAM_RED)<=0)
						{
							ForceTeamChange(i, TEAM_RED);
						}
					}
				}
			}
		}

		return Plugin_Handled;
	}

	//if(VSHA_GetPlayerCount()>4)
	//{
	//return Plugin_Handled;
	//}
	//return Plugin_Continue;

	return Plugin_Continue;
}

public Action OnGameMode_BossSetup()
{
	if(!ThisEnabled.BoolValue) return Plugin_Continue;

	int iGameMode = PreviousBossGame;

	if(GameModeType.IntValue == RandomBossGameMode)
	{
		if(RandomType.IntValue == 1)
		{
			// not the same game twice
			while(iGameMode == PreviousBossGame)
			{
				iGameMode = GetRandomInt(0,2);
			}
		}
		else
		{
			iGameMode = GetRandomInt(0,2);
		}
	}
	else
	{
		iGameMode = GameModeType.IntValue;
	}

	CurrentBossGame = iGameMode;
	PreviousBossGame = iGameMode;

	if(CurrentBossGame == 0) return Plugin_Continue;

	if(CurrentBossGame == DuoBossGameMode)
	{
		if(VSHA_GetPlayerCount()<3)
		{
			PrintToServer("%s Unable to play Duo Bosses with less than 3 players!",VSHA_COLOR);
			return Plugin_Continue;
		}
		else
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

		VSHA_SetPlayMusic(false);

		// BOSS 1
		int boss = VSHA_AddBossStock();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		// BOSS 2

		boss = VSHA_AddBossStock();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		for (int i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
			{
				if (VSHA_IsBossPlayer(i))
				{
					ForceTeamChange(i, TEAM_RED);
				}
				else
				{
					ForceTeamChange(i, TEAM_BLUE);
				}
			}
		}

		CPrintToChatAll("%s DUO BOSSES!",VSHA_COLOR);

		// will be adding duo boss theme music sometime soon
		//CreateTimer(9.1, MusicTimerStart);

		return Plugin_Handled;
	}
	else if(CurrentBossGame == BossVsBossGameMode)
	{
		if(VSHA_GetPlayerCount()<2)
		{
			PrintToServer("%s Unable to play Boss Vs Boss with less than 2 players!",VSHA_COLOR);
			CurrentBossGame = 0;
			return Plugin_Continue;
		}

		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

		// This game mode will handle its own sound / health
		VSHA_SetPlayMusic(false);
		VSHA_SetHealthBar(false);
		/*

		// BOSS 1
		int boss = VSHA_AddBoss();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		ForceTeamChange(boss, TEAM_RED);

		// BOSS 2

		boss = VSHA_AddBoss();

		if(boss == -1)
		{
			CPrintToChatAll("%s Unable to play Duo Bosses!  Not enough players.",VSHA_COLOR);
			return Plugin_Continue;
		}

		VSHA_BossSelected_Forward(boss);

		VSHA_SetClientQueuePoints(boss, 0);

		ForceTeamChange(boss, TEAM_BLUE);
		*
		*/

		int boss = -1;

		for (int i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
			{

				boss = VSHA_AddBoss(i);

				//DP("VSHA_AddBoss");
				//sm plugins reload vsha-addon-GameModes.smx
				if(boss == -1)
				{
					LogError("%s Unable to play Boss vs Boss!  Not enough players.",VSHA_COLOR);
					CurrentBossGame = 0;
					return Plugin_Continue;
				}

				VSHA_BossSelected_Forward(boss);
				VSHA_SetClientQueuePoints(boss, 0);

				if(GetTeamPlayerCount(TEAM_BLUE)>GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(boss, TEAM_RED);
					//DP("boss TEAM_RED");
				}
				else if(GetTeamPlayerCount(TEAM_BLUE)<GetTeamPlayerCount(TEAM_RED))
				{
					ForceTeamChange(boss, TEAM_BLUE);
					//DP("boss TEAM_BLUE");
				}
			}
		}

		CPrintToChatAll("%s BOSS VS BOSS!",VSHA_COLOR);

		// will be adding duo boss theme music sometime soon
		//CreateTimer(9.1, MusicTimerStart);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action OnBossSetHP_Pre(int iBossArrayListIndex, int BossEntity, int &BossMaxHealth)
{
	if(CurrentBossGame == BossVsBossGameMode)
	{
		//if(!ValidPlayer(BossEntity)) return;

		//DP("OnBossSetHP_Pre %d",BossEntity);

		BossMaxHealth = 1000;
		//int BossMaxHealth = HealthCalc( 760.8, float( CountBossTeam(BossEntity) ), 1.0, 1.0341, 2046.0 );
		//VSHA_SetBossHealth(BossEntity, BossMaxHealth);
		//VSHA_SetBossMaxHealth(BossEntity, BossMaxHealth);
		//BossMaxHealth = 1000;
		return Plugin_Handled;
	}
	else if(CurrentBossGame == DuoBossGameMode)
	{
		BossMaxHealth = RoundToFloor(float(VSHA_GetBossMaxHealth(BossEntity)) / 3.0);

		//VSHA_SetBossHealth(BossEntity, GBMaxHealth);
		//VSHA_SetBossMaxHealth(BossEntity, GBMaxHealth);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}
/*
public void OnBossSetHP_Post(int iEntity)
{
	if(CurrentBossGame <= 0) return;
	char sBossName[32];
	char sClientName[32];

	if(VSHA_IsBossPlayer(iEntity))
	{
		if(VSHA_GetBossHealth(iEntity)>0)
		{
			if(VSHA_GetBossName(iEntity,STRING(sBossName)))
			{
				GetClientName(iEntity,STRING(sClientName));
				CPrintToChatAll("%s %s became %s starting with %d HP",VSHA_COLOR,sClientName,sBossName,VSHA_GetBossHealth(iEntity));
			}
		}
		else
		{
			if(VSHA_GetBossName(iEntity,STRING(sBossName)))
			{
				GetClientName(iEntity,STRING(sClientName));
				LogError("[VSHA] %s became %s starting with %d HP",sClientName,sBossName,VSHA_GetBossMaxHealth(iEntity));
			}
		}
	}
}*/
public Action OnMessageTimer(int iiBoss)
{
	if(CurrentBossGame <= 0) return Plugin_Continue;
	return Plugin_Handled;
}

/*
public Action MusicTimerStart(Handle timer, int userid)
{
	LoopAlivePlayers(players)
	{
		if(VSHA_IsBossPlayer(players))
		{
			VSHA_CallModelTimer(2.0,GetClientUserId(players));
		}
	}
}*/

// temp health fix for all game modes
public void OnEquipPlayer_Post(int iClient)
{
	if(!ThisEnabled.BoolValue) return;

	if(ValidPlayer(iClient))
	{
		//SetEntProp(i, Prop_Data, "m_iMaxHealth") );
		// Fix Player Health
		SetEntityHealth(iClient, 5);
		TF2_RegeneratePlayer(iClient);
		//TF2_RespawnPlayer(client);

		//SetVariantString("");
		//AcceptEntityInput(iClient, "SetCustomModel");
	}
}

public Action OnMusic(int iBossArrayListIndex, int iiBoss, char BossTheme[PATHX], float &time)
{
	if (iiBoss != -2) return Plugin_Continue;

	if (ThemeMusicIsPlaying)
	{
		return Plugin_Continue;
	}

	if(CurrentBossGame == BossVsBossGameMode)
	{
		ThemeMusicIsPlaying = true;
		if(GameModeMusicEnable.BoolValue)
		{
			BossTheme = BossVsBoss1;
			time = BossVsBoss1Time;
		}

		LoopIngameClients(BossEntity)
		{
			if(VSHA_IsBossPlayer(BossEntity))
			{
				VSHA_SetBossMaxHealth(BossEntity, 1000);
				VSHA_SetBossHealth(BossEntity,1000);
				//SetEntityHealth(BossEntity, 1000);
				//SetEntProp(BossEntity, Prop_Data, "m_iMaxHealth", 1000);
				//SetEntProp(BossEntity, Prop_Data, "m_iHealth", 1000);
				//TF2_RegeneratePlayer(BossEntity);

				char sBossName[32];
				char sClientName[32];
				if(VSHA_GetBossName(BossEntity,STRING(sBossName)))
				{
					GetClientName(BossEntity,STRING(sClientName));
					CPrintToChatAll("%s %s became %s starting with %d HP",VSHA_COLOR,sClientName,sBossName,1000);
				}
			}
			else
			{
				SetEntityHealth(BossEntity, 5);
				TF2_RegeneratePlayer(BossEntity);
			}
		}
	}
	else if(CurrentBossGame == DuoBossGameMode)
	{
		ThemeMusicIsPlaying = true;
		LoopIngamePlayers(BossEntity)
		{
			if(VSHA_IsBossPlayer(BossEntity))
			{
				int GBMaxHealth = RoundToFloor(float(VSHA_GetBossMaxHealth(BossEntity)) / 3.0);

				VSHA_SetBossHealth(BossEntity, GBMaxHealth);
				VSHA_SetBossMaxHealth(BossEntity, GBMaxHealth);

				char sBossName[32];
				char sClientName[32];
				if(VSHA_GetBossName(BossEntity,STRING(sBossName)))
				{
					GetClientName(BossEntity,STRING(sClientName));
					CPrintToChatAll("%s %s became %s starting with %d HP",VSHA_COLOR,sClientName,sBossName,GBMaxHealth);
				}
			}
			else
			{
				SetEntityHealth(BossEntity, 5);
				TF2_RegeneratePlayer(BossEntity);
			}
		}
		if(GameModeMusicEnable.BoolValue)
		{
			BossTheme = DuoBoss1;
			time = DuoBoss1Time;
		}
	}

	return Plugin_Continue;
}

public void OnGameOver() // best play to reset all variables
{
	LoopMaxPLYR(players)
	{
		if(ValidPlayer(players))
		{
			StopSound(players, SNDCHAN_AUTO, BossVsBoss1);
			StopSound(players, SNDCHAN_AUTO, DuoBoss1);
		}
	}
	ThemeMusicIsPlaying = false;
	VSHA_SetPlayMusic(true);
	VSHA_SetHealthBar(true);
	CurrentBossGame = 0;
}



// LOAD CONFIGURATION
public void OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	if(StrEqual(skey, "BossVsBoss1"))
	{
		if(StrEqual(value,"")) return;
		strcopy(STRING(BossVsBoss1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "DuoBoss1"))
	{
		if(StrEqual(value,"")) return;
		strcopy(STRING(DuoBoss1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}

	if(bPreCacheFile || bAddFileToDownloadsTable)
	{
		PrintToChatAll("Loading GAME MODE THEMES %s = %s",skey,value);
	}
}
public void OnConfiguration_Load_Misc(char[] cFile, char[] skey, char[] value)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	if(StrEqual(skey, "BossVsBoss1Time"))
	{
		if(StrEqual(value,"")) return;
		BossVsBoss1Time = StringToFloat(value);
	}
	else if(StrEqual(skey, "DuoBoss1Time"))
	{
		if(StrEqual(value,"")) return;
		DuoBoss1Time = StringToFloat(value);
	}
}
public void OnBossTimer(int iBossArrayListIndex, int iiBoss, int &curHealth, int &curMaxHp, int buttons, Handle hHudSync, Handle hHudSync2)
{
	if(CurrentBossGame != BossVsBossGameMode) return;
	if(ValidPlayer(iiBoss,true))
	{
		if(GetClientTeam(iiBoss)==2)
		{
			SetPlayerRGB(iiBoss,255,0,0);
			SetEntityAlpha(iiBoss,255);
			//new wpn=W3GetCurrentWeaponEnt(client);
			//SetEntityAlpha(wpn,0);
		}
		else if(GetClientTeam(iiBoss)==3)
		{
			SetPlayerRGB(iiBoss,0,0,255);
			SetEntityAlpha(iiBoss,255);
			//new wpn=W3GetCurrentWeaponEnt(client);
			//SetEntityAlpha(wpn,0);
		}

		//int GetBossEnemyTeam = GetClientTeam(iiBoss) == 2 ? 3 : 2;
		//LoopIsInTeam(GetBossEnemyTeam, otherteam)
		//{
			//PrintCenterText(otherteam,"Enemy Boss's Current Health is: %i of %i", curHealth, curMaxHp);
		//}
	}
}

