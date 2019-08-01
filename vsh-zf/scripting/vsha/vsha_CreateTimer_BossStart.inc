// vsha_CreateTimer_BossStart.inc

public Action BossStart(Handle timer, int data)
{
	iPlaying = 0;
	LoopIngameClients(iClient) //loop iClients first for health calculation
	{
		if ( IsClientValid(iClient) && IsPlayerAlive(iClient) && !bIsBoss[iClient])
		{
			iPlaying++;
			SetEntityMoveType(iClient, MOVETYPE_WALK); // >_>
			CreateTimer(0.2, EquipPlayers, GetClientUserId(iClient)); //SUIT UP!
		}
	}
	//VSH Engine::BossStart() **** non-Boss Player loop finished

	LoopActiveBosses(iClient)
	{
		// LoopActiveBosses takes care of this:
		//if ( !IsClientValid(iClient) || !bIsBoss[iClient] ) continue;

		if ( !IsPlayerAlive(iClient) ) TF2_RespawnPlayer(iClient);
		SetEntityMoveType(iClient, MOVETYPE_WALK);

		//VSHA_SetVar(EventBoss,iClient);
		//VSHA_SetVar(EventHitPoints,2500);
		//VSHA_Private_Forward("VSHA_OnBossSetHP");
		int MaxBossHP = 2500;

		if(VSHA_OnBossSetHP_Pre(iClient, MaxBossHP) == Plugin_Continue)
		{
			VSHA_OnBossSetHP(iClient, MaxBossHP);
		}

		VSHA_OnBossSetHP_Post(iClient);

		//int MaxBossHP = VSHA_GetVar(EventHitPoints);

		if(MaxBossHP <= 0)
		{
			MaxBossHP = 2500;
		}

		//GetTrieString(GetArrayCell(hArrayBossSubplugins, iBoss[iClient]), "BossName", charBossName, sizeof(charBossName));
		//if (iBossMaxHealth[iClient] <= 0) iBossMaxHealth[iClient] = HealthCalc(760.8, float(iPlaying), 1.0, 1.0341, 2046.0);

		if (iBossMaxHealth[iClient] < MaxBossHP) iBossMaxHealth[iClient] = MaxBossHP; //fallback incase accident
		iBossHealth[iClient] = iBossMaxHealth[iClient];

		int maxhp = GetEntProp(iClient, Prop_Data, "m_iMaxHealth");

		if (IsValidEntity(iClient)) TF2Attrib_RemoveAll(iClient);
		SetEntityHealth( iClient, GetEntProp(iClient, Prop_Data, "m_iMaxHealth") );

		TF2Attrib_SetByDefIndex( iClient, 26, float(iBossMaxHealth[iClient]-maxhp) );
		SetEntityHealth( iClient, iBossHealth[iClient] );

		if(!VSHHelped[iClient])
		{
			VSHA_ShowBossHelpMenu(iClient);
			VSHHelped[iClient] = true;
		}

		if(AllowMusic)
		{
			if ( CheckRoundState() == 0 ) CreateTimer(2.0, MusicPlay, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	if(!AllowMusic)
	{
		// Send OnMusic to Game Mode Addon
		if ( CheckRoundState() == 0 ) CreateTimer(2.0, MusicPlay, -2, TIMER_FLAG_NO_MAPCHANGE);
	}
	// VSH Engine::TimerBossStart() **** Boss Player loop finished

	CreateTimer(0.2, CheckAlivePlayers);
	// ZeroPointTwo takes care of HaleTimer and BossTimer
	CreateTimer(0.2, ZeroPointTwo, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	//CreateTimer(0.2, HaleTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	//CreateTimer(0.2, BossTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

	// VSH Engine::TimerBossStart() **** Boss & Client Loop Timers created ****

	if ( !PointType && iPlaying > AliveToEnable.IntValue ) SetControlPoint(false); //GetConVarInt(AliveToEnable)

	hBossStartTimer = null;
}
