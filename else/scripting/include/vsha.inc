#if defined _vsha_included
	#endinput
#endif
#define _vsha_included

// To enable printing debug messages via DP();
#define debugon 1

#include <tf2_stocks>
// not sure why we need this, compiles without it
//#include <sdktools_gamerules>
#include <tf2items>

#pragma newdecls			required

#pragma semicolon			1

//#define DEBUG

#if defined DEBUG
	#define DEBUGPRINT0(%1)			PrintToServer(%1)
	#define DEBUGPRINT1(%1)			LogMessage(%1)
	#define DEBUGPRINT2(%1)			CPrintToChatAll(%1)
	#define DEBUGPRINT3(%1)			LogToFile("addons/sourcemod/logs/vsha-debugoutput.txt", %1)
#endif

#define MaxEntities			2048
//#define PLYR				MAXPLAYERS+1 // 65	/**< Maximum number of players SourceMod supports */
										// This number is much higher than what TF2 supports

// Setting (PLYR = Max players) to maximum TF2 Supports (32 + 2 relay?)
#define PLYR				34

#define PATH				64
#define PATHX				PLATFORM_MAX_PATH
#define nullfunc			INVALID_FUNCTION
#define nullvec				NULL_VECTOR

#define LifeState_Alive 0
#define LifeState_Dead 2

#define HudTextScreenHoldTime 0.3

#define HEALTHBAR_CLASS "monster_resource"
#define HEALTHBAR_PROPERTY "m_iBossHealthPercentageByte"
#define HEALTHBAR_MAX 255

#define TEAM_SPEC 1
#define TEAM_RED 2
#define TEAM_BLUE 3

#define ALREADY_BOSS -2

#define VSHA_COLOR "{olive}[VSHA]{default}"

#define ROUNDSTATE_INVALID						-1		/**< Invalid RoundState (VSH is disabled)*/
#define ROUNDSTATE_EVENT_ROUND_START			0		/**< set on a StartRound Timer and On event start round (preround freeze)*/
#define ROUNDSTATE_START_ROUND_TIMER			1		/**< Start of a timer for roundstart (during round) */
#define ROUNDSTATE_ROUND_END					2		/**< Found in SaxtonHale_Timers "StartHaleTimer" (after round end) */ //%50


#define STRING(%1) %1, sizeof(%1)

#define LoopMaxPLYR(%1) for(int %1=0;%1<PLYR;++%1)

#define LoopMaxClients(%1) for(int %1=1;%1<=MaxClients;++%1)

#define LoopConnectedClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1))

#define LoopIngameClients(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1))

#define LoopInGameBots(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && IsFakeClient(%1))

#define LoopIngamePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsFakeClient(%1))

#define LoopAuthorizedPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientConnected(%1) && IsClientAuthorized(%1))

#define LoopAlivePlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1))\
								if(IsPlayerAlive(%1))

#define LoopIsInTeam(%1,%2) for(int %2=1;%2<=MaxClients;++%2)\
								if(IsClientInGame(%2) && IsPlayerAlive(%2) && (%1==GetClientTeam(%2)))

#define LoopTeamPlayers(%1,%2) for(int %2=1;%2<=MaxClients;++%2)\
								if(IsClientInGame(%2) && IsPlayerAlive(%2) && (GetClientTeam(%1)==GetClientTeam(%2)))

#define LoopDeadPlayers(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !IsPlayerAlive(%1))

#define LoopActiveBosses(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && bIsBoss[%1])

#define LoopInActiveBosses(%1) for(int %1=1;%1<=MaxClients;++%1)\
								if(IsClientInGame(%1) && !bIsBoss[%1])

#define Toggle(%1) %1=%1?false:true


// may use in future.. removed for now
/*
enum VSHA_EVENT
{
	ModelTimer,
	OnLastSurvivorLoop,
	OnBossSetHP,
	OnPlayerKilled,
	OnKillingSpree,
	OnBossKilled,
	OnBossAirblasted,
	OnBossKillBuilding
}*/

// VSHA Events
enum VSHA_EVENTS
{
	vshaRoundStart,
	vshaMakeBoss, // boss only
	vshaEquipPlayers, // happens before pre-equip players (players only)
	vshaRoundEnd,
}

enum VSHA_Var
{
	hString,
	EventTime,
	EventOnPrepBoss,
	EventSound,
	EventModelTimer,
	EventModel,
	EventBoss,
	EventClient,
	EventTarget,
	EventAttacker,
	EventVictim,
	EventHitPoints,
	EventArg1, //generic vsha event arguments
	EventArg2,
	EventArg3,
	EventArg4,
	SmEvent, ///usual game events from sm hooked events
}

/*methodmap CTFBoss < CTFPlayer
{
	public CTFBoss(int playerindex)
	{
		return view_as<CTFBoss>( new CTFPlayer( clientIndex ) );
	}
}*/



//=================================================================================================================================
//=================================================== [ N A T I V E ] =============================================================

// MISC
native bool VSHA_LoadConfiguration(char[] cFileName); // Load Subplugin Configuration file

// MISC
native Handle VSHA_RegisterNonBossAddon();
native void VSHA_UnRegisterNonBossAddon();

// BOSS
// set bypassHandleRestrictions to true when you have more than one boss to register inside the same plugin

// returns the BossArrayListIndex instead of plugin handle.
native int VSHA_RegisterBoss(char BossShortName[16], char BossLongName[32]); //EVERY DAMN BOSS SUBPLUGIN REQUIRES THIS TO WORK; PREFERABLY USE IN ONPLUGINSTART OK?

// BOSS
native Handle VSHA_GetBossPluginHandle(int iiBoss);

// BOSS
native int VSHA_GetBossArrayListIndex(int iiBoss);

// BOSS
native int VSHA_GetBossUserID(int iiBoss); //gets boss' userid
native void VSHA_SetBossUserID(int iiBoss, int userid);

// BOSS
native int VSHA_GetDifficulty(int iiBoss); /* this is to modify bosses based on what difficulty level the player wants his boss to be, doesn't do anything by itself but this API should help with it. */
native void VSHA_SetDifficulty(int iiBoss, int difficultylevel);

// ANY PLAYER
native int VSHA_GetLives(int client); /* gets the player's lives, you can get/set lives for both players and bosses */
native void VSHA_SetLives(int client, int lives);
native int VSHA_GetMaxLives(int client); /* gets the player's lives, you can get/set lives for both players and bosses */
native void VSHA_SetMaxLives(int client, int lives);

// BOSS
native int VSHA_GetPresetBoss(int iiBoss); //this gets the preset boss special ID, similar to VSH Special or FF2 Get special
native void VSHA_SetPresetBoss(int iiBoss, int presetboss);

// BOSS
native int VSHA_GetBossHealth(int iiBoss);
native void VSHA_SetBossHealth(int iiBoss, int health);

// BOSS
native int VSHA_GetBossMaxHealth(int iiBoss);
native void VSHA_SetBossMaxHealth(int iiBoss, int maxhealth);

// BOSS
native int VSHA_GetBossPlayerKills(int iiBoss); //how many players a boss killed in the entire round
native void VSHA_SetBossPlayerKills(int iiBoss, int kills);

// BOSS
native int VSHA_GetBossKillstreak(int iiBoss); //how many people boss killed in a certain amount of time
native void VSHA_SetBossKillstreak(int iiBoss, int killspree);

// PLAYER
native int VSHA_GetPlayerBossKills(int iiBoss); //how many times a player has killed a boss in entire map time
native void VSHA_SetPlayerBossKills(int iiBoss, int bosseskilled);

// ANY PLAYER
native int VSHA_GetDamage(int client); //this can also get the boss' damage.
native void VSHA_SetDamage(int client, int dmg);

// BOSS
native int VSHA_GetBossMarkets(int iiBoss); /* how many times a boss was market-gardened. THIS DOES NOT AUTO INCREMENT IN CORE PLUGIN. If you want your boss to take Market-Garden Backstab-like damage, you should use this. */
native void VSHA_SetBossMarkets(int iiBoss, int markets);

// BOSS
native int VSHA_GetBossStabs(int iiBoss); //how many times a boss was backstabbed
native void VSHA_SetBossStabs(int iiBoss, int stabs);

// ANY PLAYER
native int VSHA_GetHits(int client); //how many times a client was hit aka took dmg.
native void VSHA_SetHits(int client, int hits);

// MISC
native int VSHA_GetMaxWepAmmo(int wepentity);
native void VSHA_SetMaxWepAmmo(int wepentity, int maxammo);

// MISC
native int VSHA_GetMaxWepClip(int wepentity);
native void VSHA_SetMaxWepClip(int wepentity, int maxclip);

// ANY PLAYER
native int VSHA_GetPresetBossPlayer(); //Get when or which player will be forced as the next boss
native void VSHA_SetPresetBossPlayer(int client);

// MISC
native int VSHA_GetAliveRedPlayers();
native int VSHA_GetAliveBluPlayers();

// BOSS
native float VSHA_GetBossRage(int iiBoss); /* gets the charge of the hardcoded, built-in rage charge. You can create multiple rage charges or make the default one charge up from different things than just taking damage. */
native void VSHA_SetBossRage(int iiBoss, float rage);

// MISC
native float VSHA_GetGlowTimer(int client); //used to set glow timers on players, use in boss subplugins plz
native void VSHA_SetGlowTimer(int client, float glowtime);

// BOSS
native bool VSHA_IsBossPlayer(int iiBoss); //is client a boss?
native void VSHA_SetBossPlayer(int iiBoss, bool state);

// ANY PLAYER
native bool VSHA_IsPlayerInJump(int client); //did player rocket/sticky jump?

// BOSS
native bool VSHA_CanBossTaunt(int iiBoss); //is boss taunt cooldown over?

// BOSS
native int VSHA_FindNextBoss(bool[] clientarray, int arraysize); /* gets the next player in queue list */

// PLAYER
native int VSHA_CountScoutsLeft(); /* counts how many scouts are left */
native int VSHA_GetPlayerCount();

// ANY PLAYER // no need much anymore.. handled interally
native void VSHA_CallModelTimer(float time, int client);

// ANY PLAYER // Only good for plugins that are not packs of bosses
// 				this native uses plugin-handle to look up boss
native bool VSHA_SetPluginModel(int iBossArrayListIndex, char ModelString[PATHX]); // sets up a model for a boss plugin for model manager

// ANY PLAYER
native void VSHA_SetShield(int client, int ShieldEntity); // set the entity of the shield if a player is wearing a demoshield
native int VSHA_HasShield(int client); // the entity of the shield a player has

// GAME MODE EXTRA NATIVES
native void VSHA_BossSelected_Forward(int client);
native void VSHA_SetClientQueuePoints(int client, int points);
native int VSHA_GetClientQueuePoints(int client);

// BOSS
native bool VSHA_GetBossName(int iiBoss, char[] BossLongName, int size);

native int VSHA_AddBoss(int iiBoss);
// USE STOCK if your just going to add a random boss VSHA_AddBossStock();
stock int VSHA_AddBossStock(int iiBoss = -1)
{
	return VSHA_AddBoss(iiBoss);
}

native void VSHA_SetPlayMusic(bool bSetPlayMusic);
native void VSHA_SetHealthBar(bool bSetHealthBar);

// BOSS
/**
 * @brief Allows addon programmer to prevent core from making OnTakeDamage changes
 *
 * Best to set this OnBossSelect Hook, because every round this option is reset.
 *
 * You can still Hook other OnBossDamages and get the information and make changes yourself.
 * There will be a exra option that you can send back to the core to "bypass PreventCoreOnTakeDamageChanges"
 * for the hook that you wish to use.
 *
 * @param		iiBoss							client index
 * @param		PreventCoreOnTakeDamageChanges	set true if you wish to NOT allow VSHA core to make
 * 												damage calucations and changes that are outside
 * 												the VSHA hooks provided.
 *
 * 												if not set, then the VSHA core will assume you
 * 												wish to use core calcuations for damage.
 *
 *
 * @return		returns							nothing
 */
native void VSHA_SetPreventCoreOnTakeDamageChanges(int iiBoss, bool PreventCoreOnTakeDamageChanges);


// may use in future, removed for now
//native int VSHA_CreateEvent(VSHA_EVENT event, int client);

/* BEGIN GLOBAL VARS */
//retrieves specified values from the main VSHA plugin, see VSHA_Var enum in constants.inc, only those values are allowed
//this mostly used for accessing a variable without creating a special native just for it
//this returns any:, you should tag it if return value is not suppose to be normal integer.
// to get integer.. do this: view_as<int>(VSHA_GetVar(EventArg1)); or view_as<Handle>(VSHA_GetVar(EventArg1));
//most are temporary variables and this function should be called immidiately in the right functions
//examples VSHA_GetVar(EventArg1)   VSHA_GetVar(EventArg2)
//See VSHA_Var enum in constants to get a list
//Do not get/set vars arbitrarily unless you know what you are doing
native any VSHA_GetVar(VSHA_Var variabletoretrieve);
native void VSHA_SetVar(VSHA_Var variabletoretrieve, any value);
/* END GLOBAL VARS */

//=================================================================================================================================

//=================================================== [ F O R W A R D S ] =========================================================

// may add in the future?
//forward Action OnVSHAEvent(VSHA_EVENT event, int client);

enum VSHAHookType
{
	VSHAHook_None,
	VSHAHook_OnLastSurvivor,
	VSHAHook_OnMessageTimer,
	VSHAHook_OnBossIntroTalk,
	VSHAHook_OnBossKilled,
	VSHAHook_OnBossWin,				// Best Place to rehook your functions
	VSHAHook_OnBossKillBuilding,
	VSHAHook_OnBossAirblasted,
	VSHAHook_OnBossChangeClass,
	VSHAHook_OnBossSelected,
	VSHAHook_OnBossSetHP_Pre, // make health changes here (non-boss)
	VSHAHook_OnBossSetHP,	// for bosses to make health changes
	VSHAHook_OnBossSetHP_Post, // read only, please don't make any changes here
	VSHAHook_OnBossRage,
	VSHAHook_OnBossTimer,
	VSHAHook_OnBossTimer_1_Second,
	VSHAHook_OnPlayerKilledByBoss,
	VSHAHook_OnKillingSpreeByBoss,
	VSHAHook_OnPrepBoss,
	VSHAHook_OnMusic,
	VSHAHook_OnModelTimer,
	VSHAHook_AddToDownloads,
	VSHAHook_OnConfiguration_Load_Sounds,
	VSHAHook_OnConfiguration_Load_Materials,
	VSHAHook_OnConfiguration_Load_Models,
	VSHAHook_OnConfiguration_Load_Misc,
	VSHAHook_OnEquipPlayer_Pre,
	VSHAHook_ShowPlayerHelpMenu,
	VSHAHook_OnEquipPlayer_Post,
	VSHAHook_ShowBossHelpMenu,
	VSHAHook_OnUberTimer,
	VSHAHook_OnLastSurvivorLoop,
	VSHAHook_OnGameMode_BossSetup,
	VSHAHook_OnGameMode_ForceBossTeamChange,
	VSHAHook_OnGameMode_ForcePlayerTeamChange,
	VSHAHook_OnGameMode_WatchGameModeTimer,
	VSHAHook_OnGameOver, // the very end of round or game over, best place to reset variables for your boss
	VSHAHook_OnBossTakeFallDamage,
	VSHAHook_OnBossStabbedPost,
};

typeset VSHAHookCB
{
	// VSHAHook OnGameMode_BossSetup
	// VSHAHook OnGameMode_WatchGameModeTimer - Repeating 1 second timer to watch for games that need to be restarted / started.
	function Action ();

	// VSHAHook OnGameMode_ForceBossTeamChange
	// VSHAHook OnGameMode_ForcePlayerTeamChange
	function Action (VSHA_EVENTS vshaEvent, int iEntity, int iTeam);

	// VSHAHook OnBossIntroTalk
	// VSHAHook AddToDownloads
	// VSHAHook OnLastSurvivor
	// VSHAHook OnGameOver
	// VSHAHook_OnBossStabbedPost
	function void ();

	// VSHAHook OnBossSelected
	// VSHAHook OnPrepBoss
	// VSHAHook OnBossRage
	// VSHAHook ShowBossHelpMenu
	// VSHAHook OnBossTimer_1_Second
	// VSHAHook OnBossSetHP_Post
	// VSHAHook OnBossStabbedPost
	function void (int iBossArrayListIndex, int iEntity);

	// VSHAHook OnBossTimer
	function void (int BossArrayListIndex, int iEntity, int &iiBossHealth, int &iiBossMaxHealth, int buttons, Handle hHudSync, Handle hHudSync2);

	// VSHAHook OnEquipPlayer_Pre
	// VSHAHook OnMessageTimer
	function Action (int iEntity);

	// VSHAHook OnEquipPlayer_Post
	// VSHAHook OnLastSurvivorLoop
	// VSHAHook ShowPlayerHelpMenu
	function void (int iEntity);

	// VSHAHook OnPlayerKilledByBoss
	// VSHAHook OnKillingSpreeByBoss
	// VSHAHook OnBossKilled
	// VSHAHook OnUberTimer
	function void (int BossArrayListIndex, int iEntity, int OtherEntity);

	// VSHAHook OnUberTimer -- may want to move this whole thing into player's equipment plugin
	function void (int iMedic, int iTarget);

	// VSHAHook OnBossWin
	// VSHAHook OnBossKillBuilding
	// VSHAHook OnBossAirblasted
	// VSHAHook OnBossChangeClass
	function void (int BossArrayListIndex, Event smEvent, int iEntity);

	// VSHAHook OnBossSetHP_Pre
	// VSHAHook OnBossSetHP
	function Action (int BossArrayListIndex, int BossEntity, int &BossMaxHealth);

	// VSHAHook OnMusic
	function Action (int BossArrayListIndex, int iiBoss, char BossTheme[PATHX], float &time);

	// VSHAHook OnModelTimer
	function Action (int BossArrayListIndex, int iiBoss, char modelpath[PATHX]);

	// VSHAHook OnConfiguration_Load_Sounds
	// VSHAHook OnConfiguration_Load_Materials
	// VSHAHook OnConfiguration_Load_Models
	function void (char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable);

	// VSHAHook OnConfiguration_Load_Misc
	function void (char[] cFile, char[] skey, char[] value);

	// VSHAHook_OnBossTakeFallDamage
	function Action (int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom);
};

/**
 * @brief Hooks for function
 *
 * @param		type					Type of function to hook
 * @param		callback				Function to call when hook is called
 * @param		AllowAutomaticHooking	Will Unhook/Rehook functions that are deemed not need for a round event.
 * 										Most likely will unload a function before round start, if is not a active boss
 * 										plugin, and rehook at round end.
 * @return		returns					nothing
 */
// possible future if sourcemod allows storing of functions:
//native void VSHAHook(VSHAHookType type, VSHAHookCB callback, bool AllowAutomaticHooking = true);
native void VSHAHook(VSHAHookType type, VSHAHookCB callback);

/**
 * @brief Hooks for function
 *
 * @param		type					Type of function to hook
 * @param		callback				Function to call when hook is called
 * @param		AllowAutomaticHooking	Will Unhook/Rehook functions that are deemed not need for a round event.
 * 										Most likely will unload a function before round start, if is not a active boss
 * 										plugin, and rehook at round end.
 * @return		returns					true if successful
 */
// possible future if sourcemod allows storing of functions:
//native bool VSHAHookEx(VSHAHookType type, VSHAHookCB callback, bool AllowAutomaticHooking = true);
native bool VSHAHookEx(VSHAHookType type, VSHAHookCB callback);

/**
 * @brief Unhooks a function
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		nothing
 */
native void VSHAUnhook(VSHAHookType type, VSHAHookCB callback);

/**
 * @brief Unhooks a function
 *
 * @param		type		Type of function to unhook
 * @param		callback	Callback function to unhook
 * @return		returns		true if successful
 */
native bool VSHAUnhookEx(VSHAHookType type, VSHAHookCB callback);


/*
 *
 *
 *
forward Action VSHA_OnBossIntroTalk() {}; //play boss intro response sound clip in this forward

forward Action VSHA_OnLastSurvivor() {}; //when CheckAlivePlayers counts only 1 player left, called once.

forward VSHA_MessageTimer() {}; //called when a round begins.


EXAMPLES ON HOW TO USE SOME OF THESE PRIVATE FORWARDS:

//when a boss kills a player
public Action VSHA_OnPlayerKilledByBoss()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int attacker = VSHA_GetVar(EventAttacker);
};

//when boss has killed certain amount of players in a certain amount of time, conveniently gets the killed player who triggered this forward
public Action VSHA_OnKillingSpreeByBoss()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int attacker = VSHA_GetVar(EventAttacker);
};

//when a boss is killed, conveniently gets the player who killed the boss too, give the lucky sob a medal :3
public Action VSHA_OnBossKilled() //victim is boss
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int attacker = VSHA_GetVar(EventAttacker);
}

// self explanatory lol
public Action VSHA_OnBossWin()
{
	//Event event = VSHA_GetVar(SmEvent);
	int iiBoss = VSHA_GetVar(EventBoss);
}

// also self explanatory
public Action VSHA_OnBossKillBuilding()
{
	Event event = VSHA_GetVar(SmEvent);
	int building = event.GetInt("index");
	int attacker = VSHA_GetVar(EventAttacker);
}

//when boss is airblasted, client is the airblasted boss
public Action VSHA_OnBossAirblasted()
{
	int iiBoss = VSHA_GetVar(EventBoss);
	int airblaster = VSHA_GetVar(EventAttacker);
}

//when a boss is selected, the client is the player that is assigned to be the boss
public Action VSHA_OnBossSelected()
{
	int iiBoss = VSHA_GetVar(EventClient);
}

//self explanatory, when boss has their hp set and client is the individual boss
public Action VSHA_OnBossSetHP()
{
	int iClient = VSHA_GetVar(EventClient);
}

//called every 0.2 seconds on each boss, health is set automatically though
public Action VSHA_OnBossTimer()
{
	int iClient = VSHA_GetVar(EventClient);
}

//called during MakeBoss timer; in this forward, the boss is disarmed and stripped of all equipment. Equip them or whatever in this forward ok?
public Action VSHA_OnPrepBoss()
{
	int iClient = VSHA_GetVar(EventOnPrepBoss);
}

//sets the boss theme music, no shitty earrape music ok?
public Action VSHA_OnMusic()
{
	char BossTheme[256];
	float time;

	switch ( GetRandomInt(0, 2) )
	{
	case 0:
	{
		BossTheme = HaleTheme1;
		time = 150.0;
	}
	case 1:
	{
		BossTheme = HaleTheme2;
		time = 150.0;
	}
	case 2:
	{
		BossTheme = HaleTheme3;
		time = 220.0;
	}
	}
	StringMap SoundMap = new StringMap();
	SoundMap.SetString("Sound", BossTheme);
	VSHA_SetVar(EventSound,SoundMap);
	VSHA_SetVar(EventTime,time);

	return Plugin_Continue;
}

//YOU NEED THIS TIMER FOR EVERY BOSS + MINION OR ELSE PLUGIN WILL BITCH @ U
public Action VSHA_OnModelTimer()
{
	int iClient = VSHA_GetVar(EventModelTimer);

	char modelpath[PATHX];

	//DP("VSHA_OnModelTimer");
	if (iClient != Hale[iClient])
	{
		SetVariantString("");
		AcceptEntityInput(iClient, "SetCustomModel");
		return Plugin_Stop;
	}
	modelpath = HaleModel;

	StringMap ModelMap = new StringMap();
	ModelMap.SetString("Model", modelpath);
	VSHA_SetVar(EventModel,ModelMap);

	SetVariantString(modelpath);
	AcceptEntityInput(iClient, "SetCustomModel");
	SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);

	return Plugin_Continue;
}

//when boss does taunt or medic call rage
public Action VSHA_OnBossRage()
{
	int iClient = VSHA_GetVar(EventBoss);
}


OUT DATED FORWARD INFORMATION!
OUT DATED FORWARD INFORMATION!
OUT DATED FORWARD INFORMATION!

forward void VSHA_OnPlayerKilled(int attacker, int client); //when a boss kills a player

forward void VSHA_OnKillingSpree(int attacker, int client); //when boss has killed certain amount of players in a certain amount of time, conveniently gets the killed player who triggered this forward

forward void VSHA_OnBossKilled(int client, int attacker); //when a boss is killed, conveniently gets the player who killed the boss too, give the lucky sob a medal :3

forward void VSHA_OnBossWin(); // self explanatory lol

forward void VSHA_OnBossKillBuilding(int attacker, int building); // also self explanatory

forward void VSHA_OnBossAirblasted(int client, int airblaster); //when boss is airblasted, client is the airblasted boss

forward void VSHA_OnBossSelected(int client); //when a boss is selected, the client is the player that is assigned to be the boss

forward void VSHA_OnBossIntroTalk(); //play boss intro response sound clip in this forward

forward void VSHA_OnBossSetHP(int client); //self explanatory, when boss has their hp set and client is the individual boss

forward void VSHA_OnLastSurvivorLoop(int target); //target = lucky survivor

forward void VSHA_OnLastSurvivor(); //when CheckAlivePlayers counts only 1 player left, called once.

forward void VSHA_OnBossTimer(int client); //called every 0.2 seconds on each boss, health is set automatically though

forward void VSHA_OnPrepBoss(int client); //called during MakeBoss timer; in this forward, the boss is disarmed and stripped of all equipment. Equip them or whatever in this forward ok?

forward void VSHA_OnMusic(char BossTheme[256], float &time); //sets the boss theme music, no shitty earrape music ok?

forward Action VSHA_OnModelTimer(int client, char modelpath[64]); //YOU NEED THIS TIMER FOR EVERY BOSS + MINION OR ELSE PLUGIN WILL BITCH @ U

forward void VSHA_OnBossRage(int client); //when boss does taunt or medic call rage

//public void VSHA_OnBossConditionAdded(int client, TFCond condition); //when condition like jarate is added

forward void VSHA_OnUberTimer(int medic, int target); //called every 0.4 seconds

forward void VSHA_MessageTimer(); //called when a round begins.
*/
//=================================================================================================================================

public SharedPlugin __pl_vsha =
{
	name = "vsha",
	file = "vsha.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_vsha_SetNTVOptional()
{
	MarkNativeAsOptional("VSHAHook");
	MarkNativeAsOptional("VSHAUnhook");

	MarkNativeAsOptional("VSHA_RegisterBoss");
	MarkNativeAsOptional("VSHA_UnRegisterBoss");

	MarkNativeAsOptional("VSHA_GetBossUserID");
	MarkNativeAsOptional("VSHA_SetBossUserID");

	MarkNativeAsOptional("VSHA_GetDifficulty");
	MarkNativeAsOptional("VSHA_SetDifficulty");

	MarkNativeAsOptional("VSHA_GetLives");
	MarkNativeAsOptional("VSHA_SetLives");

	MarkNativeAsOptional("VSHA_GetPresetBoss");
	MarkNativeAsOptional("VSHA_SetPresetBoss");

	MarkNativeAsOptional("VSHA_GetBossHealth");
	MarkNativeAsOptional("VSHA_SetBossHealth");

	MarkNativeAsOptional("VSHA_GetBossMaxHealth");
	MarkNativeAsOptional("VSHA_SetBossMaxHealth");

	MarkNativeAsOptional("VSHA_GetBossPlayerKills");
	MarkNativeAsOptional("VSHA_SetBossPlayerKills");

	MarkNativeAsOptional("VSHA_GetBossKillstreak");
	MarkNativeAsOptional("VSHA_SetBossKillstreak");

	MarkNativeAsOptional("VSHA_GetPlayerBossKills");
	MarkNativeAsOptional("VSHA_SetPlayerBossKills");

	MarkNativeAsOptional("VSHA_GetDamage");
	MarkNativeAsOptional("VSHA_SetDamage");

	MarkNativeAsOptional("VSHA_GetBossMarkets");
	MarkNativeAsOptional("VSHA_SetBossMarkets");

	MarkNativeAsOptional("VSHA_GetBossStabs");
	MarkNativeAsOptional("VSHA_SetBossStabs");

	MarkNativeAsOptional("VSHA_GetHits");
	MarkNativeAsOptional("VSHA_SetHits");

	MarkNativeAsOptional("VSHA_GetMaxWepAmmo");
	MarkNativeAsOptional("VSHA_SetMaxWepAmmo");

	MarkNativeAsOptional("VSHA_GetMaxWepClip");
	MarkNativeAsOptional("VSHA_SetMaxWepClip");

	MarkNativeAsOptional("VSHA_GetPresetBossPlayer");
	MarkNativeAsOptional("VSHA_SetPresetBossPlayer");

	MarkNativeAsOptional("VSHA_GetAliveRedPlayers");
	MarkNativeAsOptional("VSHA_GetAliveBluPlayers");

	MarkNativeAsOptional("VSHA_GetBossRage");
	MarkNativeAsOptional("VSHA_SetBossRage");

	MarkNativeAsOptional("VSHA_GetGlowTimer");
	MarkNativeAsOptional("VSHA_SetGlowTimer");

	MarkNativeAsOptional("VSHA_IsBossPlayer");
	MarkNativeAsOptional("VSHA_SetBossPlayer");

	MarkNativeAsOptional("VSHA_IsPlayerInJump");
	MarkNativeAsOptional("VSHA_CanBossTaunt");

	MarkNativeAsOptional("VSHA_FindNextBoss");

	MarkNativeAsOptional("VSHA_CountScoutsLeft");
	MarkNativeAsOptional("VSHA_GetPlayerCount");

	MarkNativeAsOptional("VSHA_CallModelTimer");

	MarkNativeAsOptional("VSHA_GetBossPluginHandle");
	MarkNativeAsOptional("VSHA_GetBossArrayListIndex");

	MarkNativeAsOptional("VSHA_AddBoss");
}
#endif

