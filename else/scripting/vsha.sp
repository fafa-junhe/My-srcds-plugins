#undef REQUIRE_EXTENSIONS
#tryinclude <steamtools>
#define REQUIRE_EXTENSIONS

//#include <sourcemod>
#include <clientprefs>
#include <tf2attributes>
#include <morecolors>
#include <sdkhooks>
#include <vsha>
#include <vsha_stocks>

// auto precached on mapstart
#define GIBmodel "models/gibs/hgibs.mdl"
//#define BloodDropmodel "sprites/blood.vmt"
//#define BloodSpraymodel "sprites/bloodspray.vmt"

// old version 0.1.3 on forums
#define PLUGIN_VERSION			"0.1.4"

public Plugin myinfo = {
	name = "Versus Saxton Hale Engine",
	author = "Diablo, Nergal, Chdata, Cookies, with special props to Powerlord + Flamin' Sarge",
	description = "Es Sexy-time beyechez",
	version = PLUGIN_VERSION,
	url = "https://github.com/War3Evo/VSH-Advanced"
};

enum VSHAError
{
	Error_None,				// All-Clear :>
	Error_InvalidName,			// Invalid name for Boss
	Error_AlreadyExists,			// Boss Already Exists....
	Error_SubpluginAlreadyRegistered,	// The plugin registering a boss already has a boss registered
}

#include "vsha/vsha_variables.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_SDKHooks_OnPreThink.inc"
#include "vsha/vsha_SDKHooks_OnEntityCreated.inc"
#include "vsha/vsha_SDKHooks_OnGetMaxHealth.inc"
#include "vsha/vsha_SDKHooks_OnTakeDamage.inc"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_000_OnPluginStart.inc"
#include "vsha/vsha_000_OnClientPutInServer.inc"
#include "vsha/vsha_000_OnClientDisconnect.inc"
#include "vsha/vsha_000_OnMapStart.inc"
#include "vsha/vsha_000_OnMapEnd.inc"
#include "vsha/vsha_000_OnLibraryAdded.inc"
#include "vsha/vsha_000_OnLibraryRemoved.inc"
#include "vsha/vsha_000_OnConfigsExecuted.inc"
#include "vsha/vsha_000_RegConsoleCmd.inc"
#include "vsha/vsha_000_RegAdminCmd.inc"
#include "vsha/vsha_000_OnPlayerRunCmd.inc"
#include "vsha/vsha_000_TF2_CalcIsAttackCritical.inc"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_CommandListener_DoTaunt.inc"
#include "vsha/vsha_CommandListener_DoSuicide.inc"
#include "vsha/vsha_CommandListener_DoSuicide2.inc"
#include "vsha/vsha_CommandListener_clDestroy.inc"
#include "vsha/vsha_CommandListener_CallMedVoiceMenu.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_Engine_OnWeaponSpawned.inc"
#include "vsha/vsha_Engine_PlayerHUD.inc"
#include "vsha/vsha_Engine_BossHUD.inc"
#include "vsha/vsha_Engine_UpdateHealthBar.inc"
#include "vsha/vsha_Engine_SubPlugin_Configuration_File.inc"
#include "vsha/vsha_Engine_ClearVariables.inc"
#include "vsha/vsha_Engine_CacheDownloads.inc"
//#include "vsha/vsha_Engine_ModelManager.inc"
//#include "vsha/vsha_Engine_CoolDownManager.inc"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_CreateTimer_Timer_CheckDoors.inc"
#include "vsha/vsha_CreateTimer_Timer_DrawGame.inc"
#include "vsha/vsha_CreateTimer_Timer_SkipHalePanel.inc"
#include "vsha/vsha_CreateTimer_HaleTimer.inc"
#include "vsha/vsha_CreateTimer_Timer_Uber.inc"
#include "vsha/vsha_CreateTimer_Timer_RemoveHonorBound.inc"
#include "vsha/vsha_CreateTimer_BossTimer.inc"
#include "vsha/vsha_CreateTimer_WatchGameMode.inc"
#include "vsha/vsha_CreateTimer_MusicPlay.inc"
#include "vsha/vsha_CreateTimer_MakeBoss.inc"
#include "vsha/vsha_CreateTimer_MakeModelTimer.inc"
#include "vsha/vsha_CreateTimer_DoMessage.inc"
#include "vsha/vsha_CreateTimer_BossResponse.inc"
#include "vsha/vsha_CreateTimer_InitBoss.inc"
#include "vsha/vsha_CreateTimer_BossStart.inc"
#include "vsha/vsha_CreateTimer_tTenSecStart.inc"
#include "vsha/vsha_CreateTimer_CheckAlivePlayers.inc"
#include "vsha/vsha_CreateTimer_EquipPlayers.inc"
#include "vsha/vsha_CreateTimer_CalcScores.inc"
#include "vsha/vsha_CreateTimer_TimerNineThousand.inc"
#include "vsha/vsha_CreateTimer_ResetUberCharge.inc"
#include "vsha/vsha_CreateTimer_CleanScreen.inc"
#include "vsha/vsha_CreateTimer_ZeroPointTwo.inc"
//#include "vsha/"
//#include "vsha/"


#include "vsha/vsha_CreateDataTimer_TimerMusicTheme.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

#include "vsha/vsha_HookEvent_RoundStart.inc"
#include "vsha/vsha_HookEvent_RoundEnd.inc"
#include "vsha/vsha_HookEvent_PlayerSpawn.inc"
#include "vsha/vsha_HookEvent_UberDeployed.inc"
#include "vsha/vsha_HookEvent_JumpHook.inc"
#include "vsha/vsha_HookEvent_PlayerDeath.inc"
#include "vsha/vsha_HookEvent_PlayerHurt.inc"
#include "vsha/vsha_HookEvent_Destroyed.inc"
#include "vsha/vsha_HookEvent_Deflected.inc"
#include "vsha/vsha_HookEvent_ChangeClass.inc"
//#include "vsha/"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"
#include "vsha/vsha_TF2Items_OnGiveNamedItem.inc"

// may or may not use in future
//#include "vsha/vsha_Events.inc"

#include "vsha/vsha_misc_functions.inc"
#include "vsha/vsha_UnUsed_Functions.inc"
//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

//#include "vsha/"
//#include "vsha/"
//#include "vsha/"

public int PickBossSpecial(int &select)
{
	int pick = -1;
	if (select == -1) pick = GetRandomInt( 0, hArrayBossSubplugins.Length-1 ); //GetArraySize(hArrayBossSubplugins)-1 );
	else
	{
		pick = select;
		select = -1;
	}
	//Storage[client] = GetBossSubPlugin(hArrayBossSubplugins.Get(pick)); //GetArrayCell(hArrayBossSubplugins, iBoss[client]));

	return pick; //( GetBossSubPlugin(hArrayBossSubplugins.Get(pick)) );
}

public void SearchForItemPacks()
{
	//bool foundAmmo = false, foundHealth = false;
	int ent = -1;
	//float pos[3];
	/*while ((ent = FindEntityByClassname2(ent, "item_ammopack_full")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			DispatchSpawn(ent2);
			TeleportEntity(ent2, pos, nullvec, nullvec);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
			//foundAmmo = true;
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		if (Enabled)
		{
			GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
			AcceptEntityInput(ent, "Kill");
			int ent2 = CreateEntityByName("item_ammopack_small");
			TeleportEntity(ent2, pos, nullvec, nullvec);
			DispatchSpawn(ent2);
			SetEntProp(ent2, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		}
		//foundAmmo = true;
	}
	ent = -1;*/
	while ((ent = FindEntityByClassname2(ent, "item_ammopack_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundAmmo = true;
	}

	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_small")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_medium")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "item_healthkit_large")) != -1)
	{
		SetEntProp(ent, Prop_Send, "m_iTeamNum", (Enabled ? OtherTeam : 0), 4);
		//foundHealth = true;
	}
//#if defined DEBUG
//	DEBUGPRINT1("VSH Engine::SearchForItemPacks() **** item kits are set! ****");
//#endif
}

public void LoadSubPlugins() //"stolen" from ff2 lol
{
	char path[PATHX], filename[PATHX];
	BuildPath(Path_SM, path, PATHX, "plugins/");
	FileType filetype;
	DirectoryListing directory = OpenDirectory(path);
	//while ( ReadDirEntry(directory, filename, PATHX, filetype) )
	while ( directory.GetNext(filename, PATHX, filetype) )
	{
		if ( filetype == FileType_File && StrContains(filename, ".smx", false) != -1 )
		{
			ServerCommand("sm plugins load %s", filename);
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::LoadSubPlugins() **** LoadSubPlugins() Called ****");
#endif
}

public int GetFirstBossIndex() //purpose is for the Storage client Handle
{
	int i = 0;
	for ( i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientValid(i) && bIsBoss[i] ) return i;
	}
	return -1;
}

public int FindNextBoss(bool[] array) //why force specs to Boss? They're prob AFK...
{
	int inBoss = -1;
	LoopIngameClients(i) // no bots for now
	//LoopIngamePlayers(i)
	{
		if ( IsValidClient(i) )
		{
			if ( IsOnBlueOrRedTeam(i) )
			{
				if (GetClientQueuePoints(i) >= GetClientQueuePoints(inBoss))
				{
					if( !array[i] )
					{
						inBoss = i;
					}
				}
			 }
		 }
	}
	return inBoss;
}

public Action VSHA_Private_Forward(const char[] EventString)
{
	//if(InternalPause) return Plugin_Continue;

	Handle TempStorage[PLYR];
	int TmpNum = 0;
	bool found = false;
	int iTmp;
	Action result = Plugin_Continue;

	// Loop thru all active boss sub plugins
	LoopActiveBosses(BossID)
	{
		// Make sure we don't call the same boss twice
		found = false;
		for ( iTmp = 0; iTmp < PLYR; iTmp++ )
		{
			if(Storage[BossID] == Storage[TempStorage[iTmp]])
			{
				found = true;
				break;
			}
		}
		if(found)
		{
			continue;
		}

		TempStorage[TmpNum] = Storage[BossID];
		TmpNum++;

		if(Storage[BossID] != null)
		{
			Function FuncBossKillToy = GetFunctionByName(Storage[BossID], EventString);
			if (FuncBossKillToy != nullfunc)
			{
				Call_StartFunction(Storage[BossID], FuncBossKillToy);
				Call_Finish(result);
			}
		}
	}
	return result;
}

public Action VSHA_Registered_Global_Forward(const char[] EventString)
{
	//if(InternalPause) return Plugin_Continue;

	Action result = Plugin_Continue;

	if(hArrayNonBossSubplugins != null)
	{
		int count = hArrayNonBossSubplugins.Length; //GetArraySize(hMyArray);
		Handle MyPlugin = null;
		Function FuncRegisteredGlobal = nullfunc;
		for (int i = 0; i < count; i++)
		{
			MyPlugin = hArrayNonBossSubplugins.Get(i);

			if(MyPlugin != null)
			{
				FuncRegisteredGlobal = GetFunctionByName(MyPlugin, EventString);
				if (FuncRegisteredGlobal != nullfunc)
				{
					Call_StartFunction(MyPlugin, FuncRegisteredGlobal);
					Call_Finish(result);
					if(result == Plugin_Stop) break;
				}
			}
		}
	}

	return result;
}
//===================================================================================================================================

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////// N A T I V E S  &  F O R W A R D S //////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// Special Graphics for loading screen
	PrintToServer("");
	PrintToServer("");
	PrintToServer(" #     #  #####  #     #    #    ");
	PrintToServer(" #     # #     # #     #   # #   ");
	PrintToServer(" #     # #       #     #  #   #  ");
	PrintToServer(" #     #  #####  ####### #     # ");
	PrintToServer("  #   #        # #     # ####### ");
	PrintToServer("   # #   #     # #     # #     # ");
	PrintToServer("    #     #####  #     # #     # ");
	PrintToServer("");
	PrintToServer("");

	// N A T I V E S ============================================================================================================
	CreateNative("VSHA_LoadConfiguration", Native_LoadConfigurationSubplugin);

	// May delete soon, this isn't used any longer since we moved to "hooks"
	CreateNative("VSHA_RegisterNonBossAddon", Native_RegisterNonBossAddon);
	CreateNative("VSHA_UnRegisterNonBossAddon", Native_UnRegisterNonBossAddon);

	CreateNative("VSHA_RegisterBoss", Native_RegisterBossSubplugin);

	CreateNative("VSHA_GetBossPluginHandle", Native_GetBossHandle);
	CreateNative("VSHA_GetBossArrayListIndex", Native_GetBossArrayListIndex);

	CreateNative("VSHA_SetPluginModel", Native_SetPluginModel);
	//CreateNative("VSHA_RemovePluginModel", Native_RemovePluginModel);

	CreateNative("VSHAHook", Native_Hook);
	CreateNative("VSHAHookEx", Native_HookEx);
	CreateNative("VSHAUnhook", Native_Unhook);
	CreateNative("VSHAUnhookEx", Native_UnhookEx);

	CreateNative("VSHA_SetPreventCoreOnTakeDamageChanges", Native_SetPreventCoreOnTakeDamageChanges);

	CreateNative("VSHA_SetPlayMusic", Native_SetPlayMusic);
	CreateNative("VSHA_SetHealthBar", Native_SetHealthBar);

	CreateNative("VSHA_GetBossUserID", Native_GetBossUserID);
	CreateNative("VSHA_SetBossUserID", Native_SetBossUserID);

	CreateNative("VSHA_GetDifficulty", Native_GetDifficulty);
	CreateNative("VSHA_SetDifficulty", Native_SetDifficulty);

	CreateNative("VSHA_GetLives", Native_GetLives);
	CreateNative("VSHA_SetLives", Native_SetLives);
	CreateNative("VSHA_GetMaxLives", Native_GetMaxLives);
	CreateNative("VSHA_SetMaxLives", Native_SetMaxLives);

	CreateNative("VSHA_GetPresetBoss", Native_GetPresetBoss);
	CreateNative("VSHA_SetPresetBoss", Native_SetPresetBoss);

	CreateNative("VSHA_GetBossHealth", Native_GetBossHealth);
	CreateNative("VSHA_SetBossHealth", Native_SetBossHealth);

	CreateNative("VSHA_GetBossMaxHealth", Native_GetBossMaxHealth);
	CreateNative("VSHA_SetBossMaxHealth", Native_SetBossMaxHealth);

	CreateNative("VSHA_GetBossPlayerKills", Native_GetBossPlayerKills);
	CreateNative("VSHA_SetBossPlayerKills", Native_SetBossPlayerKills);

	CreateNative("VSHA_GetBossKillstreak", Native_GetBossKillstreak);
	CreateNative("VSHA_SetBossKillstreak", Native_SetBossKillstreak);

	CreateNative("VSHA_GetPlayerBossKills", Native_GetPlayerBossKills);
	CreateNative("VSHA_SetPlayerBossKills", Native_SetPlayerBossKills);

	CreateNative("VSHA_GetDamage", Native_GetDamage);
	CreateNative("VSHA_SetDamage", Native_SetDamage);

	CreateNative("VSHA_GetBossMarkets", Native_GetBossMarkets);
	CreateNative("VSHA_SetBossMarkets", Native_SetBossMarkets);

	CreateNative("VSHA_GetBossStabs", Native_GetBossStabs);
	CreateNative("VSHA_SetBossStabs", Native_SetBossStabs);

	CreateNative("VSHA_GetHits", Native_GetHits);
	CreateNative("VSHA_SetHits", Native_SetHits);

	CreateNative("VSHA_GetMaxWepAmmo", Native_GetMaxWepAmmo);
	CreateNative("VSHA_SetMaxWepAmmo", Native_SetMaxWepAmmo);

	CreateNative("VSHA_GetMaxWepClip", Native_GetMaxWepClip);
	CreateNative("VSHA_SetMaxWepClip", Native_SetMaxWepClip);

	CreateNative("VSHA_GetPresetBossPlayer", Native_GetPresetBossPlayer);
	CreateNative("VSHA_SetPresetBossPlayer", Native_SetPresetBossPlayer);

	CreateNative("VSHA_GetAliveRedPlayers", Native_GetAliveRedPlayers);
	CreateNative("VSHA_GetAliveBluPlayers", Native_GetAliveBluePlayers);

	CreateNative("VSHA_GetBossRage", Native_GetBossRage);
	CreateNative("VSHA_SetBossRage", Native_SetBossRage);

	CreateNative("VSHA_GetGlowTimer", Native_GetGlowTimer);
	CreateNative("VSHA_SetGlowTimer", Native_SetGlowTimer);

	CreateNative("VSHA_IsBossPlayer", Native_IsBossPlayer);
	CreateNative("VSHA_SetBossPlayer", Native_SetBossPlayer);

	CreateNative("VSHA_IsPlayerInJump", Native_IsPlayerInJump);
	CreateNative("VSHA_CanBossTaunt", Native_CanBossTaunt);

	CreateNative("VSHA_FindNextBoss", Native_FindNextBoss);

	CreateNative("VSHA_CountScoutsLeft", Native_CountScoutsLeft);

	CreateNative("VSHA_GetPlayerCount", Native_GetPlayerCount);

	CreateNative("VSHA_GetVar",Native_VSHA_GetVar);
	CreateNative("VSHA_SetVar",Native_VSHA_SetVar);

	CreateNative("VSHA_HasShield",Native_VSHA_HasShield);
	CreateNative("VSHA_SetShield",Native_VSHA_SetShield);

	CreateNative("VSHA_CallModelTimer",Native_CallModelTimer);

	// EXTRA GAME MODE STUFF

	CreateNative("VSHA_BossSelected_Forward",Native_BossSelected_Forward);
	CreateNative("VSHA_SetClientQueuePoints",Native_SetClientQueuePoints);
	CreateNative("VSHA_GetClientQueuePoints",Native_GetClientQueuePoints);
	CreateNative("VSHA_AddBoss",Native_AddBoss);

	CreateNative("VSHA_GetBossName", Native_GetBossName);

	// may use in future.. depends
	//vsha_Events_AskPluginLoad2();

	//===========================================================================================================================

	RegPluginLibrary("vsha");
#if defined _steamtools_included
	MarkNativeAsOptional("Steam_SetGameDescription");
#endif
	return APLRes_Success;
}

public int Native_LoadConfigurationSubplugin(Handle plugin, int numParams)
{
	char cFileName[64];
	GetNativeString(1, STRING(cFileName));
	return VSHA_Load_Configuration(plugin, cFileName);
}


public int Native_RegisterNonBossAddon(Handle plugin, int numParams)
{
	Handle BossHandle = RegisterNonBossAddon( plugin );
	return view_as<int>( BossHandle );
}
public int Native_UnRegisterNonBossAddon(Handle plugin, int numParams)
{
	UnRegisterNonBossAddon( plugin );
	return 0;
}

public int Native_RegisterBossSubplugin(Handle plugin, int numParams)
{
	char ShortBossSubPluginName[16];
	GetNativeString(1, ShortBossSubPluginName, sizeof(ShortBossSubPluginName));
	char BossSubPluginName[32];
	GetNativeString(2, BossSubPluginName, sizeof(BossSubPluginName));
	//VSHAError erroar;
	int iBossArrayListIndex = RegisterBoss( plugin, ShortBossSubPluginName, BossSubPluginName ); //ALL PROPS TO COOKIES.NET AKA COOKIES.IO
	return iBossArrayListIndex;
}

public int Native_GetBossHandle(Handle plugin, int numParams)
{
	return view_as<int>(Storage[GetNativeCell(1)]);
}
public int Native_GetBossArrayListIndex(Handle plugin, int numParams)
{
	return BossArrayListIndex[GetNativeCell(1)];
}

public int Native_GetBossUserID(Handle plugin, int numParams)
{
	return iBossUserID[GetNativeCell(1)];
}
public int Native_SetBossUserID(Handle plugin, int numParams)
{
	iBossUserID[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDifficulty(Handle plugin, int numParams)
{
	return iDifficulty[GetNativeCell(1)];
}
public int Native_SetDifficulty(Handle plugin, int numParams)
{
	iDifficulty[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetLives(Handle plugin, int numParams)
{
	return iLives[GetNativeCell(1)];
}
public int Native_SetLives(Handle plugin, int numParams)
{
	iLives[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxLives(Handle plugin, int numParams)
{
	return iMaxLives[GetNativeCell(1)];
}
public int Native_SetMaxLives(Handle plugin, int numParams)
{
	iMaxLives[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBoss(Handle plugin, int numParams)
{
	return iPresetBoss[GetNativeCell(1)];
}
public int Native_SetPresetBoss(Handle plugin, int numParams)
{
	iPresetBoss[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossHealth(Handle plugin, int numParams)
{
	return iBossHealth[GetNativeCell(1)];
}
public int Native_SetBossHealth(Handle plugin, int numParams)
{
	iBossHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMaxHealth(Handle plugin, int numParams)
{
	return iBossMaxHealth[GetNativeCell(1)];
}
public int Native_SetBossMaxHealth(Handle plugin, int numParams)
{
	iBossMaxHealth[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossPlayerKills(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][0];
}
public int Native_SetBossPlayerKills(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][0] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossKillstreak(Handle plugin, int numParams)
{
	return iPlayerKilled[GetNativeCell(1)][1];
}
public int Native_SetBossKillstreak(Handle plugin, int numParams)
{
	iPlayerKilled[GetNativeCell(1)][1] = GetNativeCell(2);
	return 0;
}

public int Native_GetPlayerBossKills(Handle plugin, int numParams)
{
	return iBossesKilled[GetNativeCell(1)];
}
public int Native_SetPlayerBossKills(Handle plugin, int numParams)
{
	iBossesKilled[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetDamage(Handle plugin, int numParams)
{
	return iDamage[GetNativeCell(1)];
}
public int Native_SetDamage(Handle plugin, int numParams)
{
	iDamage[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossMarkets(Handle plugin, int numParams)
{
	return iMarketed[GetNativeCell(1)];
}
public int Native_SetBossMarkets(Handle plugin, int numParams)
{
	iMarketed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetBossStabs(Handle plugin, int numParams)
{
	return iStabbed[GetNativeCell(1)];
}
public int Native_SetBossStabs(Handle plugin, int numParams)
{
	iStabbed[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetHits(Handle plugin, int numParams)
{
	return iHits[GetNativeCell(1)];
}
public int Native_SetHits(Handle plugin, int numParams)
{
	iHits[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepAmmo(Handle plugin, int numParams)
{
	return AmmoTable[GetNativeCell(1)];
}
public int Native_SetMaxWepAmmo(Handle plugin, int numParams)
{
	AmmoTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetMaxWepClip(Handle plugin, int numParams)
{
	return ClipTable[GetNativeCell(1)];
}
public int Native_SetMaxWepClip(Handle plugin, int numParams)
{
	ClipTable[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetPresetBossPlayer(Handle plugin, int numParams)
{
	return iNextBossPlayer;
}
public int Native_SetPresetBossPlayer(Handle plugin, int numParams)
{
	iNextBossPlayer = GetNativeCell(1);
	return 0;
}

public int Native_GetAliveRedPlayers(Handle plugin, int numParams)
{
	return iRedAlivePlayers;
}
public int Native_GetAliveBluePlayers(Handle plugin, int numParams)
{
	return iBluAlivePlayers;
}

public int Native_GetBossRage(Handle plugin, int numParams)
{
	return view_as<int>(flCharge[GetNativeCell(1)]);
}
public int Native_SetBossRage(Handle plugin, int numParams)
{
	flCharge[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_GetGlowTimer(Handle plugin, int numParams)
{
	return view_as<int>(flGlowTimer[GetNativeCell(1)]);
}
public int Native_SetGlowTimer(Handle plugin, int numParams)
{
	flGlowTimer[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_IsBossPlayer(Handle plugin, int numParams)
{
	return view_as<int>(bIsBoss[GetNativeCell(1)]);
}
public int Native_SetBossPlayer(Handle plugin, int numParams)
{
	// Make sure only boss plugins can set this!
	bool foundBoss = false;
	LoopMaxPLYR(SearchBosses)
	{
		if(Storage[SearchBosses] == plugin)
		{
			foundBoss = true;
			break;
		}
	}
	if(foundBoss)
	{
		int iiBoss = GetNativeCell(1);
		Storage[iiBoss] = plugin;

		// needs to be updated to set the ArrayListIndex too!
		//BossArrayListIndex[boss] = PickBossSpecial(iPresetBoss[boss]);
		//Storage[boss] = GetBossSubPlugin(hArrayBossSubplugins.Get(BossArrayListIndex[boss]));

		iBossUserID[iiBoss] = GetClientUserId(iiBoss);
		bIsBoss[iiBoss] = GetNativeCell(2);
	}
	return 0;
}

public int Native_IsPlayerInJump(Handle plugin, int numParams)
{
	return bInJump[GetNativeCell(1)];
}
public int Native_CanBossTaunt(Handle plugin, int numParams)
{
	return bNoTaunt[GetNativeCell(1)];
}

public int Native_FindNextBoss(Handle plugin, int numParams)
{
	int size = GetNativeCell(2);
	if (size < 1)
	{
		LogError("VSHA Engine::Native_FindNextBoss() **** Invalid Array Size (size = %i) ****", size);
		return -1;
	}
	bool[] array = new bool[size]; GetNativeArray(1, array, size);
	return FindNextBoss(array);
}

public int Native_CountScoutsLeft(Handle plugin, int numParams)
{
	return CountScoutsLeft();
}

public int Native_GetPlayerCount(Handle plugin, int numParams)
{
	return iPlaying;
}

public int FindByBossSubPluginByID(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(MyStringMap) == plugin) return i;
	}
	return -1;
}
public Handle FindByBossSubPlugin(Handle plugin)
{
	int count = hArrayBossSubplugins.Length; //GetArraySize(hMyArray);
	for (int i = 0; i < count; i++)
	{
		StringMap MyStringMap = hArrayBossSubplugins.Get(i);
		if (GetBossSubPlugin(MyStringMap) == plugin) return MyStringMap;
	}
	return null;
}
public Handle FindByNonBossSubPlugin(Handle plugin)
{
	int count = hArrayNonBossSubplugins.Length; //GetArraySize(hMyArray);
	Handle MyPlugin = null;
	for (int i = 0; i < count; i++)
	{
		MyPlugin = hArrayNonBossSubplugins.Get(i);
		if (MyPlugin == plugin) return MyPlugin;
	}
	return null;
}
public int FindByNonBossSubPluginByID(Handle plugin)
{
	for (int i = 0; i < hArrayNonBossSubplugins.Length; i++)
	{
		if (hArrayNonBossSubplugins.Get(i) == plugin) return i;
	}
	return -1;
}
public Handle FindBossName(const char[] name)
{
	Handle GotBossName;
	if ( GetTrieValueCaseInsensitive(hTrieBossSubplugins, name, GotBossName) ) return GotBossName;
	return null;
}
public Handle RegisterNonBossAddon(Handle pluginhndl)
{
	Handle MyPluginHandle = FindByNonBossSubPlugin(pluginhndl);

	if (MyPluginHandle != null)
	{
		LogError("**** RegisterNonBossAddon - Non-Boss Subplugin Already Registered / Returned current handle ****");
		return MyPluginHandle;
	}

	hArrayNonBossSubplugins.Push(pluginhndl);

	return pluginhndl;
}
public void UnRegisterNonBossAddon(Handle pluginhndl)
{
	int iPlugin = FindByNonBossSubPluginByID(pluginhndl);

	if (iPlugin == -1)
	{
		LogError("**** UnRegisterNonBossAddon - Unable to unregister ****");
		return;
	}

	hArrayNonBossSubplugins.Erase(iPlugin);
}
public bool GetBossName(Handle pluginhandle, char[] BossName, int stringsize)
{
	int BossPluginID = FindByBossSubPluginByID(pluginhandle);
	if(BossPluginID > -1)
	{
		StringMap BossSubplug = hArrayBossSubplugins.Get(BossPluginID);
		return BossSubplug.GetString("BossLongName", BossName, stringsize);
	}
	return false;
}
public int RegisterBoss(Handle pluginhndl,
			const char shortname[16],
			const char longname[32])
{
	if (!ValidateName(shortname))
	{
		LogError("**** RegisterBoss - Invalid Name ****");
		//error = Error_InvalidName;
		return -1;
	}

	// Since we moved to using BossArrayListIndex, checking
	// for pluginhndl duplication is stupid.

	// allows us to store multiple bosses from the same plugin
	// if we set bypassHandleRestrictions to true
	//if(!bypassHandleRestrictions)
	//{
		//if (FindByBossSubPlugin(pluginhndl) != null)
		//{
			//LogError("**** RegisterBoss - Boss Subplugin Already Registered ****");
			//error = Error_SubpluginAlreadyRegistered;
			//return -1;
		//}
	//}
	if (FindBossName(shortname) != null)
	{
		LogError("**** RegisterBoss - Boss Name Already Exists ****");
		//error = Error_AlreadyExists;
		return -1;
	}
	// Create the trie to hold the data about the boss
	StringMap BossSubplug = new StringMap(); //CreateTrie();
#if defined DEBUG
	if (BossSubplug == null) DEBUGPRINT1("VSH Engine::RegisterBoss() **** BossSubplug StringMap Trie is Null ****");
#endif
	BossSubplug.SetValue("Subplugin", pluginhndl); //SetTrieValue(BossSubplug, "Subplugin", pluginhndl);
	BossSubplug.SetString("BossShortName", shortname); //SetTrieString(BossSubplug, "BossName", name);
	BossSubplug.SetString("BossLongName", longname);

	// Then push it to the global array and trie
	// Don't forget to convert the string to lower cases!
	hArrayBossSubplugins.Push(BossSubplug); //PushArrayCell(hArrayBossSubplugins, BossSubplug);
	SetTrieValueCaseInsensitive(hTrieBossSubplugins, shortname, BossSubplug);

	bool pluginupdated = false;

	//InternalPause = false;

	if(StrEqual(ReloadBossShortName,shortname))
	{
		LoopMaxPLYR(plyrBoss)
		{
			if(ReloadPlayer[plyrBoss])
			{
				pluginupdated = true;
				ReloadPlayer[plyrBoss] = false;
				if(ValidPlayer(plyrBoss,true))
				{
					iBossUserID[plyrBoss] = GetClientUserId(plyrBoss);
					bIsBoss[plyrBoss] = true;
					Storage[plyrBoss] = pluginhndl;
					BossArrayListIndex[plyrBoss] = hArrayBossSubplugins.Length-1;

					//VSHA_OnBossSelected(plyrBoss);

					CreateTimer(1.0, LoadPluginTimer, plyrBoss);
					//PrintToChatAll("Loading boss selection...");

					//PrintToChatAll("VSHA_OnBossSelected %d",plyrBoss);
					//VSHA_OnPrepBoss(plyrBoss);

					//iModelRetrys[plyrBoss]=15;

					//CreateTimer(0.2, MakeModelTimer, GetClientUserId(plyrBoss));
				}
			}
		}
	}

	char sClientName[256];
	LoopIngameClients(iClient)
	{
		GetClientName(iClient,STRING(sClientName));
		PrintToChatAll("[client id] %s %d",sClientName,iClient);
	}

	if(pluginupdated)
	{
		PrintToChatAll("%s updated.",longname);
	}

	return hArrayBossSubplugins.Length-1;
}
public Action LoadPluginTimer(Handle hTimer, int plyrBoss)
{
	VSHA_OnBossSelected(plyrBoss);
	//PrintToChatAll("VSHA_OnBossSelected %d",plyrBoss);
	//ReplyToCommand(client, "[VSH Engine] Reload Finished");
	return Plugin_Continue;
}

public int Native_VSHA_GetVar(Handle plugin, int numParams)
{
	return view_as<int>(VSHA_VarArr[GetNativeCell(1)]);
}
public int Native_VSHA_SetVar(Handle plugin, int numParams)
{
	VSHA_VarArr[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_VSHA_HasShield(Handle plugin, int numParams)
{
	return iShield[GetNativeCell(1)];
}
public int Native_VSHA_SetShield(Handle plugin, int numParams)
{
	iShield[GetNativeCell(1)] = GetNativeCell(2);
	return 0;
}

public int Native_CallModelTimer(Handle plugin, int numParams)
{
	float time = view_as<float>(GetNativeCell(1));
	int userid = GetNativeCell(2);

	CreateTimer(time, MakeModelTimer, userid);
	return 0;
}

// Real Private Forwards

stock Handle GetVSHAHookType(VSHAHookType vshaHOOKtype)
{
	switch(vshaHOOKtype)
	{
		case VSHAHook_OnBossIntroTalk:
		{
			return p_OnBossIntroTalk;
		}
		case VSHAHook_AddToDownloads:
		{
			return p_AddToDownloads;
		}
		case VSHAHook_OnPlayerKilledByBoss:
		{
			return p_OnPlayerKilledByBoss;
		}
		case VSHAHook_OnKillingSpreeByBoss:
		{
			return p_OnKillingSpreeByBoss;
		}
		case VSHAHook_OnBossKilled:
		{
			return p_OnBossKilled;
		}
		case VSHAHook_OnBossKillBuilding:
		{
			return p_OnBossKillBuilding;
		}
		case VSHAHook_OnMessageTimer:
		{
			return p_OnMessageTimer;
		}
		case VSHAHook_OnBossAirblasted:
		{
			return p_OnBossAirblasted;
		}
		case VSHAHook_OnBossChangeClass:
		{
			return p_OnBossChangeClass;
		}
		case VSHAHook_OnBossSelected:
		{
			return p_OnBossSelected;
		}
		case VSHAHook_OnBossSetHP_Pre:
		{
			return p_OnBossSetHP_Pre;
		}
		case VSHAHook_OnBossSetHP:
		{
			return p_OnBossSetHP;
		}
		case VSHAHook_OnBossSetHP_Post:
		{
			return p_OnBossSetHP_Post;
		}
		case VSHAHook_OnLastSurvivor:
		{
			return p_OnLastSurvivor;
		}
		case VSHAHook_OnBossTimer:
		{
			return p_OnBossTimer;
		}
		case VSHAHook_OnPrepBoss:
		{
			return p_OnPrepBoss;
		}
		case VSHAHook_OnMusic:
		{
			return p_OnMusic;
		}
		case VSHAHook_OnModelTimer:
		{
			return p_OnModelTimer;
		}
		case VSHAHook_OnBossRage:
		{
			return p_OnBossRage;
		}
		case VSHAHook_OnConfiguration_Load_Sounds:
		{
			return p_OnConfiguration_Load_Sounds;
		}
		case VSHAHook_OnConfiguration_Load_Materials:
		{
			return p_OnConfiguration_Load_Materials;
		}
		case VSHAHook_OnConfiguration_Load_Models:
		{
			return p_OnConfiguration_Load_Models;
		}
		case VSHAHook_OnConfiguration_Load_Misc:
		{
			return p_OnConfiguration_Load_Misc;
		}
		case VSHAHook_OnEquipPlayer_Pre:
		{
			return p_OnEquipPlayer_Pre;
		}
		case VSHAHook_ShowPlayerHelpMenu:
		{
			return p_ShowPlayerHelpMenu;
		}
		case VSHAHook_OnEquipPlayer_Post:
		{
			return p_OnEquipPlayer_Post;
		}
		case VSHAHook_ShowBossHelpMenu:
		{
			return p_ShowBossHelpMenu;
		}
		case VSHAHook_OnUberTimer:
		{
			return p_OnUberTimer;
		}
		case VSHAHook_OnLastSurvivorLoop:
		{
			return p_OnLastSurvivorLoop;
		}
		case VSHAHook_OnBossWin:
		{
			return p_OnBossWin;
		}
		case VSHAHook_OnGameMode_BossSetup:
		{
			return p_OnGameMode_BossSetup;
		}
		case VSHAHook_OnGameMode_ForceBossTeamChange:
		{
			return p_OnGameMode_ForceBossTeamChange;
		}
		case VSHAHook_OnGameMode_ForcePlayerTeamChange:
		{
			return p_OnGameMode_ForcePlayerTeamChange;
		}
		case VSHAHook_OnGameMode_WatchGameModeTimer:
		{
			return p_OnGameMode_WatchGameModeTimer;
		}
		case VSHAHook_OnGameOver:
		{
			return p_OnGameOver;
		}
		case VSHAHook_OnBossTimer_1_Second:
		{
			return p_OnBossTimer_1_Second;
		}
		case VSHAHook_OnBossTakeFallDamage:
		{
			return p_OnBossTakeFallDamage;
		}
		case VSHAHook_OnBossStabbedPost:
		{
			return p_OnBossStabbedPost;
		}
	}
	return null;
}
/*
public Function HasAutomaticHooking(Handle plugin, VSHAHookType vshaHOOKtype)
{
	Handle STORplugin;
	VSHAHookType STORvshaHOOKtype;
	Function myFunction;
	StringMap MapHooking = new StringMap();
	int count = hArrayAutomaticHooking.Length;
	for (int i = 0; i < count; i++)
	{
		MapHooking = hArrayAutomaticHooking.Get(i);

		if(MapHooking.GetValue("Plugin", STORplugin) && MapHooking.GetValue("VSHAHookType", STORvshaHOOKtype))
		{
			if(STORplugin == plugin && STORvshaHOOKtype == vshaHOOKtype)
			{
				MapHooking.GetValue("Function", myFunction)
				return myFunction;
			}
		}
	}
	return null;
}

 *
 * code safed for when sourcemod will allow us to
 * save functions into stringmaps.
 *
 * for now we can not save functions into stringmaps.
 * // Force Coercions.. ?? safe ?? not sure
 * #define FORCE_COERCIONS

public void UnHookAutomaticHooks(Handle plugin)
{
	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);
	int AutomaticHook = HasAutomaticHooking(plugin,VSHAHook_OnBossIntroTalk);
	if(AutomaticHook > -1)
	{
		FwdHandle = GetVSHAHookType(VSHAHook_OnBossIntroTalk);

		if(FwdHandle != null)
		{
			RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
		}
	}
}

public void RemoveAutomaticHooking(Handle plugin)
{
	StringMap MapHooking = new StringMap();
	int count = hArrayAutomaticHooking.Length;
	for (int i = 0; i < count; i++)
	{
		MapHooking = hArrayAutomaticHooking.Get(i);

		if(MapHooking.GetValue("Plugin", plugin))
		{
			// Found, lets remove!
			hArrayAutomaticHooking.Erase(i);
			break;
		}
	}
}*/

public int Native_Hook(Handle plugin, int numParams)
{
	VSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		/*
		if(GetNativeCell(3))
		{
			// if true to automatic hooking

			StringMap MapHooking = new StringMap();
			MapHooking.SetValue("Plugin", plugin);
			MapHooking.SetValue("VSHAHookType", vshaHOOKtype);

			hArrayAutomaticHooking.Push(MapHooking);
		}*/
		AddToForward(FwdHandle, plugin, Func);
	}
}

public int Native_HookEx(Handle plugin, int numParams)
{
	VSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);
	Function Func = GetNativeFunction(2);

	if(FwdHandle != null)
	{
		/*
		if(GetNativeCell(3))
		{
			// if true to automatic hooking
			StringMap MapHooking = new StringMap();
			MapHooking.SetValue("Plugin", plugin);
			MapHooking.SetValue("VSHAHookType", vshaHOOKtype);
			MapHooking.SetValue("Function", Func);

			hArrayAutomaticHooking.Push(MapHooking);
		}*/
		return AddToForward(FwdHandle, plugin, Func);
	}
	return 0;
}

public int Native_Unhook(Handle plugin, int numParams)
{
	VSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);

	if(FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
}
public int Native_UnhookEx(Handle plugin, int numParams)
{
	VSHAHookType vshaHOOKtype = GetNativeCell(1);

	Handle FwdHandle = GetVSHAHookType(vshaHOOKtype);

	if(FwdHandle != null)
	{
		//RemoveAutomaticHooking(plugin);
		return RemoveFromForward(FwdHandle, plugin, GetNativeFunction(2));
	}
	return 0;
}

// Internal private forward calls

public void VSHA_OnBossIntroTalk() // 0
{
	Call_StartForward(p_OnBossIntroTalk);
	Call_Finish();
}

public void VSHA_AddToDownloads() // 0
{
	Call_StartForward(p_AddToDownloads);
	Call_Finish();
}

public void VSHA_OnPlayerKilledByBoss(int iiBoss, int attacker) // 3
{
	Call_StartForward(p_OnPlayerKilledByBoss);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void VSHA_OnKillingSpreeByBoss(int iiBoss, int attacker) // 3
{
	Call_StartForward(p_OnKillingSpreeByBoss);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void VSHA_OnBossKilled(int iiBoss, int attacker) // 3
{
	SDKUnhook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	Call_StartForward(p_OnBossKilled);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_PushCell(attacker);
	Call_Finish();
}

public void VSHA_OnBossWin(Event event, int iiBoss) // 3
{
	SDKUnhook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	Call_StartForward(p_OnBossWin);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void VSHA_OnBossKillBuilding(Event event, int iiBoss) // 3
{
	Call_StartForward(p_OnBossKillBuilding);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public Action VSHA_OnMessageTimer(int iiBoss) // 1
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnMessageTimer);
	Call_PushCell(iiBoss);
	Call_Finish(result);
	return result;
}

public void VSHA_OnBossAirblasted(Event event, int iiBoss) // 3
{
	Call_StartForward(p_OnBossAirblasted);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void VSHA_OnBossChangeClass(Event event, int iiBoss) // 3
{
	Call_StartForward(p_OnBossChangeClass);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(event);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void VSHA_OnBossSelected(int iiBoss) // 2
{
	SDKHook(iiBoss, SDKHook_OnTakeDamage, OnTakeDamage);
	Call_StartForward(p_OnBossSelected);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public Action VSHA_OnBossSetHP_Pre(int BossEntity, int &BossMaxHealth) // 3
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnBossSetHP_Pre);
	Call_PushCell(BossArrayListIndex[BossEntity]);
	Call_PushCell(BossEntity);
	Call_PushCellRef(BossMaxHealth);
	Call_Finish(result);
	return result;
}
public Action VSHA_OnBossSetHP(int BossEntity, int &BossMaxHealth) // 3
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnBossSetHP);
	Call_PushCell(BossArrayListIndex[BossEntity]);
	Call_PushCell(BossEntity);
	Call_PushCellRef(BossMaxHealth);
	Call_Finish(result);
	return result;
}
public void VSHA_OnBossSetHP_Post(int iEntity) // 2
{
	Call_StartForward(p_OnBossSetHP_Post);
	Call_PushCell(BossArrayListIndex[iEntity]);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void VSHA_OnLastSurvivor() // 0
{
	Call_StartForward(p_OnLastSurvivor);
	Call_Finish();
}

public void VSHA_OnBossTimer(int iiBoss) // 7
{
	Call_StartForward(p_OnBossTimer);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_PushCellRef(iBossHealth[iiBoss]);
	Call_PushCellRef(iBossMaxHealth[iiBoss]);
	Call_PushCell(Buttons[iiBoss]);
	Call_PushCell(hHudSynchronizer);
	Call_PushCell(hHudSynchronizer2);
	Call_Finish();
}
public void VSHA_OnBossTimer_1_Second(int iiBoss) // 2
{
	Call_StartForward(p_OnBossTimer_1_Second);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_Finish();
}
public void VSHA_OnPrepBoss(int iiBoss) // 2
{
	Call_StartForward(p_OnPrepBoss);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public Action VSHA_OnMusic(int iClient, char BossTheme[PATHX], float &time) // 4
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnMusic);
	Call_PushCell(BossArrayListIndex[iClient]);
	Call_PushCell(iClient);
	Call_PushStringEx(STRING(BossTheme),0, SM_PARAM_COPYBACK);
	Call_PushFloatRef(time);
	Call_Finish(result);
	return result;
}

public Action VSHA_OnModelTimer(int iClient, char modelpath[PATHX]) // 3
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnModelTimer);
	Call_PushCell(BossArrayListIndex[iClient]);
	Call_PushCell(iClient);
	Call_PushStringEx(STRING(modelpath),0, SM_PARAM_COPYBACK);
	Call_Finish(result);
	return result;
}

public void VSHA_OnBossRage(int iiBoss) // 2
{
	Call_StartForward(p_OnBossRage);
	Call_PushCell(BossArrayListIndex[iiBoss]);
	Call_PushCell(iiBoss);
	Call_Finish();
}

public void VSHA_OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	Call_StartForward(p_OnConfiguration_Load_Sounds);
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void VSHA_OnConfiguration_Load_Materials(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	Call_StartForward(p_OnConfiguration_Load_Materials);
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void VSHA_OnConfiguration_Load_Models(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable) // 5
{
	Call_StartForward(p_OnConfiguration_Load_Models);
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_PushCellRef(bPreCacheFile);
	Call_PushCellRef(bAddFileToDownloadsTable);
	Call_Finish();
}

public void VSHA_OnConfiguration_Load_Misc(char[] cFile, char[] skey, char[] value) // 3
{
	Call_StartForward(p_OnConfiguration_Load_Misc);
	Call_PushString(cFile);
	Call_PushString(skey);
	Call_PushString(value);
	Call_Finish();
}

public Action VSHA_OnEquipPlayer_Pre(int iEntity) // 1
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnEquipPlayer_Pre);
	Call_PushCell(iEntity);
	Call_Finish(result);
	return result;
}

public void VSHA_ShowPlayerHelpMenu(int iEntity) // 1
{
	Call_StartForward(p_ShowPlayerHelpMenu);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void VSHA_OnEquipPlayer_Post(int iEntity) // 1
{
	Call_StartForward(p_OnEquipPlayer_Post);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void VSHA_ShowBossHelpMenu(int iEntity) // 2
{
	Call_StartForward(p_ShowBossHelpMenu);
	Call_PushCell(BossArrayListIndex[iEntity]);
	Call_PushCell(iEntity);
	Call_Finish();
}

public void VSHA_OnUberTimer(int iMedic, int iTarget) // 2
{
	Call_StartForward(p_OnUberTimer);
	Call_PushCell(iMedic);
	Call_PushCell(iTarget);
	Call_Finish();
}

public void VSHA_OnLastSurvivorLoop(int iEntity) // 1
{
	Call_StartForward(p_OnLastSurvivorLoop);
	Call_PushCell(iEntity);
	Call_Finish();
}

public Action VSHA_OnGameMode_BossSetup() // 1
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnGameMode_BossSetup);
	Call_Finish(result);
	return result;
}
public Action VSHA_OnGameMode_ForceBossTeamChange(VSHA_EVENTS vshaEvent, int iEntity, int iTeam) // 3
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnGameMode_ForceBossTeamChange);
	Call_PushCell(vshaEvent);
	Call_PushCell(iEntity);
	Call_PushCell(iTeam);
	Call_Finish(result);
	return result;
}
public Action VSHA_OnGameMode_ForcePlayerTeamChange(VSHA_EVENTS vshaEvent, int iEntity, int iTeam) // 3
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnGameMode_ForcePlayerTeamChange);
	Call_PushCell(vshaEvent);
	Call_PushCell(iEntity);
	Call_PushCell(iTeam);
	Call_Finish(result);
	return result;
}

public Action VSHA_OnGameMode_WatchGameModeTimer() // 0
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnGameMode_WatchGameModeTimer);
	Call_Finish(result);
	return result;
}

public void VSHA_OnGameOver() // 0
{
	Call_StartForward(p_OnGameOver);
	Call_Finish();
}

public Action VSHA_OnBossTakeFallDamage(int victim,
										int &attacker,
										int &inflictor,
										float &damage,
										int &damagetype,
										int &weapon,
										float damageForce[3],
										float damagePosition[3],
										int damagecustom) // 10
{
	Action result = Plugin_Continue;
	Call_StartForward(p_OnBossTakeFallDamage);
	Call_PushCell(BossArrayListIndex[victim]);
	Call_PushCell(victim);
	Call_PushCellRef(attacker);
	Call_PushCellRef(inflictor);
	Call_PushFloatRef(damage);
	Call_PushCellRef(damagetype);
	Call_PushCellRef(weapon);
	Call_PushArray(damageForce,3);
	Call_PushArray(damagePosition,3);
	Call_PushCell(damagecustom);
	Call_Finish(result);
	return result;
}

public void VSHA_OnBossStabbedPost(int victim) // 0
{
	Call_StartForward(p_OnBossStabbedPost);
	Call_PushCell(BossArrayListIndex[victim]);
	Call_PushCell(victim);
	Call_Finish();
}







// GAME MODE EXTRA NATIVES

public int Native_BossSelected_Forward(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if(ValidPlayer(iClient))
	{
		VSHA_OnBossSelected(iClient);
	}
	return 0;
}
public int Native_SetClientQueuePoints(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if(ValidPlayer(iClient))
	{
		int iPoints = GetNativeCell(2);
		SetClientQueuePoints(iClient,iPoints);
	}
	return 0;
}
public int Native_GetClientQueuePoints(Handle plugin, int numParams)
{
	int iClient = GetNativeCell(1);
	if(ValidPlayer(iClient))
	{
		return GetClientQueuePoints(iClient);
	}
	return 0;
}
public int Native_AddBoss(Handle plugin, int numParams)
{
	int boss = GetNativeCell(1);

	if(boss == -1)
	{
		if ( IsClientValid(iNextBossPlayer) ) boss = iNextBossPlayer;
		else boss = FindNextBoss(bIsBoss);
	}

	if (!ValidPlayer(boss))
	{
		return -1;
	}

	iBossUserID[boss] = GetClientUserId(boss);
	bIsBoss[boss] = true;
	BossArrayListIndex[boss] = PickBossSpecial(iPresetBoss[boss]);
	Storage[boss] = GetBossSubPlugin(hArrayBossSubplugins.Get(BossArrayListIndex[boss]));

	return boss;
}
public int Native_SetPlayMusic(Handle plugin, int numParams)
{
	AllowMusic = view_as<bool>(GetNativeCell(1));
	return 0;
}

public int Native_SetHealthBar(Handle plugin, int numParams)
{
	AllowHealthBar = view_as<bool>(GetNativeCell(1));
	return 0;
}

public int Native_SetPluginModel(Handle plugin, int numParams)
{
	char ModelString[PATHX];
	int iBossArrayListIndex = GetNativeCell(1);
	if(GetNativeString(2, STRING(ModelString)) == SP_ERROR_NONE)
	{
		for (int i = 0; i < hArrayModelManagerPlugin.Length; i++)
		{
			if (hArrayModelManagerPlugin.Get(i) == iBossArrayListIndex)
			{
				// if found same plugin, overwrite old model
				hArrayModelManagerStringName.SetString(i,ModelString);
				return true;
			}
		}

		hArrayModelManagerPlugin.Push(iBossArrayListIndex);
		hArrayModelManagerStringName.PushString(ModelString);
		/*

		char bossShortName[PATHX];
		if(GetNativeString(2, STRING(bossShortName)) == SP_ERROR_NONE)
		{
			hArrayModelManagerBossShortName.PushString(bossShortName);
		}
		else
		{
			hArrayModelManagerBossShortName.PushString("");
		}
		return true;*/
	}
	return false;
}

public int Native_GetBossName(Handle plugin, int numParams)
{
	int iiBoss = GetNativeCell(1);
	char[] sBossName = "";
	int stringsize = GetNativeCell(3);
	if(GetNativeString(2, sBossName, stringsize) == SP_ERROR_NONE)
	{
		return GetBossName(Storage[iiBoss],sBossName,stringsize);
	}
	return false;
}

public int Native_SetPreventCoreOnTakeDamageChanges(Handle plugin, int numParams)
{
	int iiBoss = GetNativeCell(1);
	bool PreventCoreOnTakeDamageChanges = view_as<bool>(GetNativeCell(2));
	OnPreventCoreOnTakeDamageChanges[iiBoss] = PreventCoreOnTakeDamageChanges;
}

