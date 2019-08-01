// vsha_HookEvent_RoundStart.inc

public Action ForceRoundStartCheckTimer(Handle timer, int data)
{
	hForceRoundStartCheckTimer = null;
	RoundStartFunction();
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	return RoundStartFunction();
}

public Action RoundStartFunction()
{
	//DP("RoundStart");
	bool MakeEnabled = false;
	if (!bEnabled.BoolValue)
	{
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif

#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundStart() **** VSHA not Enabled ****");
#endif
		MakeEnabled = false;
		return Plugin_Continue;
	}
	else MakeEnabled = true;
	Enabled = MakeEnabled;
	if ( !Enabled )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
		DEBUGPRINT2("{lime}VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
		DEBUGPRINT3("VSH Engine::RoundStart() **** Plugin is NOT Enabled! ****");
#endif
		return Plugin_Continue;
	}

	// Stop RoundStart Timers
	// hopefully I'm add enough Handle = null after
	// a timer stops, so that it won't error this
	// and prevent the round from starting!
	ClearTimer(HandletTenSecStartTimer);
	ClearTimer(HandletTenSecStartTimer2);
	bTenSecStart[0] = false;
	bTenSecStart[1] = false;
	ClearTimer(hBossStartTimer);
	ClearTimer(hInitBossTimer);
	ClearTimer(hBossResponse);
	ClearTimer(hDoMessage);

	ClearTimer(MusicTimer);

	// We do this on round end, why need it on round start?
	// commenting this out to try and defeat a bug
	//ClearTimer(MusicTimer);
	CheckArena();
	int i;
	iPlaying = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && IsOnBlueOrRedTeam(i))
		{
			// bIsBoss is set to false in ClearVariables
			ClearVariablesRoundStart(i);
			//ForceTeamChange(i, OtherTeam);
			//iDamage[i] = 0;
			iPlaying++;
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::RoundStart() **** Player Loop finished! ****");
#endif
	if (GetClientCount() <= 1 || iPlaying < 2)
	{
		if(RetryCounter>0)
		{
			int entityTimer = FindEntityByClassname(-1, "team_round_timer");
			if (entityTimer > -1)
			{
				SetVariantInt(5);
				AcceptEntityInput(entityTimer, "AddTime");
				RetryCounter=10;
			}
			else
			{
				RetryCounter--;
			}
			hForceRoundStartCheckTimer = CreateTimer(4.8, ForceRoundStartCheckTimer);
			CPrintToChatAll("{olive}[VSHA Engine]{default} Waiting for more players...");
		}
		else
		{
			CPrintToChatAll("{olive}[VSHA Engine]{default} Need more players to begin!");
			Enabled = false;
			SetControlPoint(true);
		}
		return Plugin_Continue;
	}
	RetryCounter = 10;
	if (hArrayBossSubplugins.Length < 1) //if (GetArraySize(hArrayBossSubplugins) < 1)
	{
		LogMessage("VSHA Engine::RoundStart() **** No Boss Subplugins Loaded ****");
		Enabled = false;
		ClearTimer(hForceRoundStartCheckTimer);
		return Plugin_Continue;
	}

	ClearTimer(hForceRoundStartCheckTimer);

	// GAME MODE STARTS HERE

	if(VSHA_OnGameMode_BossSetup() != Plugin_Handled)
	{
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), 0);

		int boss = -1;
		if ( IsClientValid(iNextBossPlayer) ) boss = iNextBossPlayer;
		else boss = FindNextBoss(bIsBoss);

		if (boss <= 0)
		{
			CPrintToChatAll("{olive}[VSHA Engine]{default} Need more players to begin");
			Enabled = false;
			return Plugin_Continue;
		}

		iBossUserID[boss] = GetClientUserId(boss);
		bIsBoss[boss] = true;
		BossArrayListIndex[boss] = PickBossSpecial(iPresetBoss[boss]);
		Storage[boss] = GetBossSubPlugin(hArrayBossSubplugins.Get(BossArrayListIndex[boss]));

		/*
		LoopInActiveBosses(NonActiveBosses)
		{
			UnHookAutomaticHooks(Storage[NonActiveBosses]);
		}*/

		//VSHA_SetVar(EventClient,boss);
		//VSHA_Private_Forward("VSHA_OnBossSelected");
		VSHA_OnBossSelected(boss);


		if ( GetTeamPlayerCount(TEAM_BLUE) <= 0 || GetTeamPlayerCount(TEAM_RED) <= 0 )
		{
			for (i = 1; i <= MaxClients; i++)
			{
				if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
				{
					if(GetTeamPlayerCount(TEAM_BLUE) <= 0)
					{
						ForceTeamChange(i, TEAM_BLUE);
					}
					else if(GetTeamPlayerCount(TEAM_RED) <= 0)
					{
						ForceTeamChange(i, TEAM_RED);
					}
				}
			}
		}

		for (i = 1; i <= MaxClients; i++)
		{
			if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
			{
				if (bIsBoss[i])
				{
					//DP("HookEvent_RoundStart 123 ForceTeamChange(i, HaleTeam)");
					if(VSHA_OnGameMode_ForceBossTeamChange(vshaRoundStart, i, HaleTeam) != Plugin_Handled)
					{
						ForceTeamChange(i, HaleTeam);
					}
				}
				else
				{
					//DP("HookEvent_RoundStart 123 ForceTeamChange(i, OtherTeam)");
					if(VSHA_OnGameMode_ForcePlayerTeamChange(vshaRoundStart, i, OtherTeam) != Plugin_Handled)
					{
						ForceTeamChange(i, OtherTeam);
					}
				}
			}
		}
	}

	bTenSecStart[0] = true;
	bTenSecStart[1] = true;

	HandletTenSecStartTimer = CreateTimer(29.1, tTenSecStart, 0);
	HandletTenSecStartTimer2 = CreateTimer(60.1, tTenSecStart2, 1);

	hBossStartTimer = CreateTimer(9.1, BossStart); // 9.1
	hInitBossTimer = CreateTimer(0.2, InitBoss);
	hBossResponse = CreateTimer(3.5, BossResponse);
	hDoMessage = CreateTimer(9.6, DoMessage); //9.6
	PointReady = false;

	for ( int entity = MaxClients+1; entity < MaxEntities; entity++ )
	{
		if ( !IsValidEdict(entity) ) continue;
		char classname[64]; GetEdictClassname(entity, classname, sizeof(classname));

		if ( !strcmp(classname, "func_regenerate") || !strcmp(classname, "func_respawnroomvisualizer") ) AcceptEntityInput(entity, "Disable");

		if ( !strcmp(classname, "obj_dispenser") )
		{
			SetVariantInt(OtherTeam);
			AcceptEntityInput(entity, "SetTeam");
			AcceptEntityInput(entity, "skin");
			SetEntProp(entity, Prop_Send, "m_nSkin", OtherTeam-2);
		}
		if ( !strcmp(classname, "mapobj_cart_dispenser") )
		{
			SetVariantInt(OtherTeam);
			AcceptEntityInput(entity, "SetTeam");
			AcceptEntityInput(entity, "skin");
		}
	}
	SearchForItemPacks();

	return Plugin_Continue;
}
