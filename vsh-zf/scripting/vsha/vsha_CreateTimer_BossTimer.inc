// vsha_CreateTimer_BossTimer.inc

// 0.2 Second Timer
int PLYtimer[PLYR];

public Action BossTimer(Handle timer)
{
	//if (InternalPause) return Plugin_Stop;

	if ( !Enabled || CheckRoundState() == ROUNDSTATE_ROUND_END ) return Plugin_Stop;
	LoopActiveBosses(client)
	{
		if ( IsValidClient(client) && IsPlayerAlive(client) )
		{
			PLYtimer[client]++;
			if(PLYtimer[client]>=5) // 5 * 0.2 = 1.0
			{
				PLYtimer[client] = 0;
				VSHA_OnBossTimer_1_Second(client);
			}
			// temp remove to see if OnGetMaxHealth will handle this
			//SetEntityHealth(client, iBossHealth[client]);
			ZeroPointTwoSecondThink(client);
			BossHUD(client);
			SetClientGlow(client, -0.2, _, flGlowTimer[client]);
		}
	}
	flHPTime -= 0.2;
	if ( flHPTime < 0.0 ) flHPTime = 0.0;
	UpdateHealthBar();
	return Plugin_Continue;
}

public void ZeroPointTwoSecondThink(int iClient)
{
	//VSHA_SetVar(EventClient,client);
	//VSHA_Private_Forward("VSHA_OnBossTimer");
	VSHA_OnBossTimer(iClient);
}
