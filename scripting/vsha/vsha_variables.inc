// vsha_variables.sp

// V A R I A B L E S =========================================================================

//ArrayList hArrayAutomaticHooking = null; // saved for when sourcemod allows saving functions to stringmaps

ArrayList hArrayNonBossSubplugins = null;	// List <Subplugin Addon> Not a boss addon, just an external extra


ArrayList hArrayBossSubplugins = null;	// List <Subplugin>
StringMap hTrieBossSubplugins = null;	// Map <Boss Name, Subplugin Handle>

// Model Manager
ArrayList hArrayModelManagerPlugin = null;
ArrayList hArrayModelManagerStringName = null;
//ArrayList hArrayModelManagerBossShortName = null;

//Handles
Handle Storage[PLYR];
//Handle ModelTimer[PLYR];

BossArrayListIndex[PLYR];

// Timer Handles
Handle HandletTenSecStartTimer = null;
Handle HandletTenSecStartTimer2 = null;
Handle hBossStartTimer = null;
Handle hInitBossTimer = null;
Handle hBossResponse = null;
Handle hDoMessage = null;
Handle hForceRoundStartCheckTimer = null;

//ints
int iModelRetrys[PLYR],
	iBossUserID[PLYR],		//USERID NUM OVER CLIENT INT
	iBoss[PLYR],		//THIS IS NOT THE USER, IT'S THE SPECIAL BOSS IDs
	iQueuePoints[PLYR],		// sometimes the queuepoints system fails, this is for backup
	iDifficulty[PLYR],
	iPresetBoss[PLYR],
	iBossHealth[PLYR],
	iBossMaxHealth[PLYR],
	iPlayerKilled[PLYR][2],	//0 - kill count, 1 - killing spree
	iBossesKilled[PLYR],
	iDamage[PLYR],
	iAirDamage[PLYR],
	iMarketed[PLYR],
	iStabbed[PLYR],
	iShield[PLYR],		// Shield Entity a player is wearing
	iUberedTarget[PLYR],
	iLives[PLYR],		//lives can work for BOTH Bosses & for players, get creative!
	iMaxLives[PLYR],
	iHits[PLYR],		//How many times a player has been hit lol
	AmmoTable[2049], // currenly in OnWeaponSpawned.inc, but not used for anything
	ClipTable[2049], // currenly in OnWeaponSpawned.inc, but not used for anything
	HaleTeam = 3,
	OtherTeam = 2,
	iNextBossPlayer,
	iLowestBossHP,
	iHealthBar = -1,
	iRedAlivePlayers,
	iBluAlivePlayers,
	iPlaying = 0,
	TeamRoundCounter,
	RoundCount,
	Buttons[PLYR],
	timeleft;
	//BloodSpraymodelEntity,
	//BloodDropmodelEntity;

//floats
float flCharge[PLYR], //SINGLE MEDIC-TAUNT/RAGE CHARGE, MAKE YOUR OWN CHARGE VARS IN YOUR OWN BOSS SUBPLUGINS
	flKillStreak[PLYR],
	flGlowTimer[PLYR],
	flHPTime;

//bools
bool Enabled,
	bIsBoss[PLYR], //EITHER IS BOSS OR NOT
	bInJump[PLYR],
	bNoTaunt[PLYR],
	bTenSecStart[2],
	PointType, // It's being used, but not set anywhere
	PointReady,
	steamtools;

//================================================================================================

int tf_arena_use_queue, mp_teams_unbalance_limit, tf_arena_first_blood, mp_forcecamera;
float tf_scout_hype_pep_max;



//cvar Handles
ConVar bEnabled = null;
ConVar FirstRound = null;
ConVar MedigunReset = null;
ConVar AliveToEnable = null;
ConVar CountDownPlayerLimit = null;
ConVar CountDownHealthLimit = null;
ConVar LastPlayersTimerCountDown = null;
ConVar EnableEurekaEffect = null;
ConVar PointDelay = null;
ConVar QueueIncrement = null;
//ConVar FallDmgSoldier = null;
//ConVar DifficultyAmount = null;

//non-cvar Handles
Handle hBossHUD;
Handle hPlayerHUD;
Handle TimeLeftHUD = null;
Handle MiscHUD = null; //for various other HUD additions
//Handle CustomHUD = null;
Handle hdoorchecktimer = null;
Handle PointCookie = null;
Handle MusicTimer = null;
Handle DrawGameTimer = null;

Handle hHudSynchronizer = null;
Handle hHudSynchronizer2 = null;

// may use later?
//Handle g_VSHA_GlobalEventFH;
any VSHA_VarArr[VSHA_Var];

//bool InternalPause = false;

int RetryCounter = 10;


// Reload
bool ReloadPlayer[PLYR];
char ReloadBossShortName[16];
char hLoadPlugin[PATHX];

// Help

bool VSHHelped[PLYR];


// Private Forwards
Handle p_OnBossIntroTalk;
Handle p_AddToDownloads;
Handle p_OnPlayerKilledByBoss;
Handle p_OnKillingSpreeByBoss;
Handle p_OnBossKilled;
Handle p_OnBossWin;
Handle p_OnBossKillBuilding;
Handle p_OnMessageTimer;
Handle p_OnBossAirblasted;
Handle p_OnBossChangeClass;
Handle p_OnBossSelected;
Handle p_OnBossSetHP_Pre;
Handle p_OnBossSetHP;
Handle p_OnBossSetHP_Post;
Handle p_OnLastSurvivor;
Handle p_OnBossTimer;
Handle p_OnBossTimer_1_Second;
Handle p_OnPrepBoss;
Handle p_OnMusic;
Handle p_OnModelTimer;
Handle p_OnBossRage;
Handle p_OnConfiguration_Load_Sounds;
Handle p_OnConfiguration_Load_Materials;
Handle p_OnConfiguration_Load_Models;
Handle p_OnConfiguration_Load_Misc;
Handle p_OnEquipPlayer_Pre;
Handle p_ShowPlayerHelpMenu;
Handle p_OnEquipPlayer_Post;
Handle p_ShowBossHelpMenu;
Handle p_OnUberTimer;
Handle p_OnLastSurvivorLoop;
Handle p_OnGameMode_BossSetup;
Handle p_OnGameMode_ForceBossTeamChange;
Handle p_OnGameMode_ForcePlayerTeamChange;
Handle p_OnGameMode_WatchGameModeTimer;
Handle p_OnGameOver;

// OnTakeDamage
Handle p_OnBossTakeFallDamage;
Handle p_OnBossStabbedPost;

// Multi boss
bool AllowMusic = true;
bool AllowHealthBar = true;

bool OnPreventCoreOnTakeDamageChanges[PLYR];
