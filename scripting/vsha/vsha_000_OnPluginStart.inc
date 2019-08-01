// vsha_000_OnPluginStart.inc

public void OnPluginStart()
{
	hArrayBossSubplugins = new ArrayList();	//CreateArray();
	hArrayNonBossSubplugins = new ArrayList();	//CreateArray();
	hTrieBossSubplugins = new StringMap();	//CreateTrie();

	hArrayModelManagerPlugin = new ArrayList();
	hArrayModelManagerStringName = new ArrayList(ByteCountToCells(PATHX));
	//hArrayModelManagerBossShortName = new ArrayList(ByteCountToCells(PATHX));

	//hArrayAutomaticHooking = new ArrayList();

	hHudSynchronizer = CreateHudSynchronizer();
	hHudSynchronizer2 = CreateHudSynchronizer();


	// VSHAHook
	p_OnBossIntroTalk = CreateForward(ET_Ignore);
	p_AddToDownloads = CreateForward(ET_Ignore);

	p_OnPlayerKilledByBoss = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	p_OnKillingSpreeByBoss = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	p_OnBossKilled = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	p_OnBossWin = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);
	p_OnBossKillBuilding = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	p_OnMessageTimer = CreateForward(ET_Hook, Param_Cell);

	p_OnBossAirblasted = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	p_OnBossChangeClass = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_Cell);

	p_OnBossSelected = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnBossSetHP_Pre = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
	p_OnBossSetHP = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_CellByRef);
	p_OnBossSetHP_Post = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnLastSurvivor = CreateForward(ET_Ignore);

	p_OnBossTimer = CreateForward(ET_Ignore, Param_Cell, Param_Cell, Param_CellByRef, Param_CellByRef, Param_Cell, Param_Cell, Param_Cell);
	p_OnBossTimer_1_Second = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnPrepBoss = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnMusic = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_String, Param_FloatByRef);

	p_OnModelTimer = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_String);

	p_OnBossRage = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnConfiguration_Load_Sounds = CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef);
	p_OnConfiguration_Load_Materials = CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef);
	p_OnConfiguration_Load_Models = CreateForward(ET_Ignore, Param_String, Param_String, Param_String, Param_CellByRef, Param_CellByRef);
	p_OnConfiguration_Load_Misc =  CreateForward(ET_Ignore, Param_String, Param_String, Param_String);

	p_OnEquipPlayer_Pre = CreateForward(ET_Hook, Param_Cell);

	p_ShowPlayerHelpMenu = CreateForward(ET_Ignore, Param_Cell);

	p_OnEquipPlayer_Post = CreateForward(ET_Ignore, Param_Cell);

	p_ShowBossHelpMenu = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnUberTimer = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	p_OnLastSurvivorLoop =  CreateForward(ET_Ignore, Param_Cell);

	p_OnGameMode_BossSetup = 			 CreateForward(ET_Hook);
	p_OnGameMode_ForceBossTeamChange = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);
	p_OnGameMode_ForcePlayerTeamChange = CreateForward(ET_Hook, Param_Cell, Param_Cell, Param_Cell);

	p_OnGameMode_WatchGameModeTimer = 			 CreateForward(ET_Hook);

	p_OnGameOver = CreateForward(ET_Ignore);

	p_OnBossTakeFallDamage = CreateForward(ET_Hook,
											Param_Cell,
											Param_Cell,
											Param_CellByRef,
											Param_CellByRef,
											Param_FloatByRef,
											Param_CellByRef,
											Param_CellByRef,
											Param_Array,
											Param_Array,
											Param_Cell);

	p_OnBossStabbedPost = CreateForward(ET_Ignore, Param_Cell, Param_Cell);

	CreateConVar("vsha_version", PLUGIN_VERSION, "VSHA Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);

	LogMessage("==== Versus Saxton Hale Advanced Engine Initializing - v%s ====", PLUGIN_VERSION);
	bEnabled = CreateConVar("vsha_enabled", "1", "Enable the VSHA Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	FirstRound = CreateConVar("vsha_firstround", "1", "Enable first round for VSH Engine", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	MedigunReset = CreateConVar("vsha_medigunreset", "0.40", "default ubercharge for when mediguns reset", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	AliveToEnable = CreateConVar("vsha_alivetoenable", "3", "how many players left to enable cap", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownPlayerLimit = CreateConVar("vsha_countdownplayerlimit", "3", "how many players must be left to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 16.0);
	CountDownHealthLimit = CreateConVar("vsha_countdownbosshealth", "5000", "how low boss health must be to start the final countdown timer", FCVAR_PLUGIN, true, 0.0, true, 999999.0);
	LastPlayersTimerCountDown = CreateConVar("vsha_finalcountdowntimer", "120", "how long the final countdown timer is", FCVAR_PLUGIN, true, 0.0, true, 99999.0);
	EnableEurekaEffect = CreateConVar("vsha_alloweureka", "1", "(dis)allows the eureka wrench from being used", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	PointDelay = CreateConVar("vsha_capturepointdelay", "10", "time in seconds the cap is delayed from enabling", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	QueueIncrement = CreateConVar("vsha_queueincrement", "10", "by how much queue increments", FCVAR_PLUGIN, true, 1.0, true, 999.0);
	//FallDmgSoldier = CreateConVar("vsha_soldierfalldamage", "20.0", "divides fall damage by this number", FCVAR_PLUGIN, true, 0.0, true, 999.0);
	//DifficultyAmount = CreateConVar("vsha_difficultyamount", "3", "how many difficulty settings you want available for bosses to choose", FCVAR_PLUGIN, true, 0.0, true, 999.0);

	AddCommandListener(DoTaunt, "taunt");
	AddCommandListener(DoTaunt, "+taunt");
	AddCommandListener(CallMedVoiceMenu, "voicemenu");
	AddCommandListener(DoSuicide, "explode");
	AddCommandListener(DoSuicide, "kill");
	AddCommandListener(DoSuicide2, "jointeam");
	AddCommandListener(clDestroy, "destroy");

	HookEvent("teamplay_round_start", RoundStart);
	HookEvent("teamplay_round_win", RoundEnd);
	HookEvent("player_spawn", PlayerSpawn);
	//HookEvent("post_inventory_application", PlayerSpawn);
	HookEvent("player_chargedeployed", UberDeployed);
	HookEvent("rocket_jump", JumpHook);
	HookEvent("rocket_jump_landed", JumpHook);
	HookEvent("sticky_jump", JumpHook);
	HookEvent("sticky_jump_landed", JumpHook);
	HookEvent("player_death", JumpHook);
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_hurt", PlayerHurt, EventHookMode_Pre);
	HookEvent("object_destroyed", Destroyed, EventHookMode_Pre);
	HookEvent("object_deflected", Deflected, EventHookMode_Pre);
	HookEvent("player_changeclass", ChangeClass);

	vsha_000_RegConsoleCmd_OnPluginStart();
	vsha_000_RegAdminCmd_OnPluginStart();

	hBossHUD = CreateHudSynchronizer();
	hPlayerHUD = CreateHudSynchronizer();
	TimeLeftHUD = CreateHudSynchronizer();
	MiscHUD = CreateHudSynchronizer();

	PointCookie = RegClientCookie("vsha_queuepoints", "Amount of VSH Engine Queue points, the player has", CookieAccess_Protected);
	//LoadSubPlugins();
	//AutoExecConfig(true, "VSH-Engine");

	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidClient(i) ) continue;
		OnClientPutInServer(i);
	}
}

