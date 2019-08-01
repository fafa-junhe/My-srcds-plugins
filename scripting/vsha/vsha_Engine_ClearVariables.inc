// vsha_Engine_ClearVariables.inc

public void ClearVariablesRoundStart(int client)
{
	bIsBoss[client] = false;
	iDamage[client] = 0;
	iModelRetrys[client] = 25;
	VSHHelped[client] = false;

	Storage[client] = null;
	BossArrayListIndex[client] = -1;
	iBossUserID[client] = 0;

	OnPreventCoreOnTakeDamageChanges[client] = false;
}

public void ClearAllVariables()
{
	Enabled = false;
	bTenSecStart[0] = false;
	bTenSecStart[1] = false;

	PointReady = false;
	flHPTime = 0.0;
	timeleft = 0;
	RoundCount = 0;
	TeamRoundCounter = 0;
	iPlaying = 0;
	iRedAlivePlayers = 0;
	iBluAlivePlayers = 0;
	iHealthBar = -1;
	iLowestBossHP = 0;
	iNextBossPlayer = 0;

	LoopMaxPLYR(player)
	{
		VSHHelped[player] = false;
		iBossHealth[player]=0;
		iBossMaxHealth[player]=0;
		iBossUserID[player]=0;
		iModelRetrys[player] = 25;
		Storage[player] = null;
		BossArrayListIndex[player] = -1;
		iBoss[player] = -1;
		iPresetBoss[player] = -1;
		bIsBoss[player] = false;
		iDifficulty[player] = 0;
		iDamage[player] = 0;
		iBossesKilled[player] = 0;
		iPlayerKilled[player][0] = 0;
		iPlayerKilled[player][1] = 1;
		iHits[player] = 0;
		bNoTaunt[player] = false;
		iLives[player] = 0;
		iUberedTarget[player] = 0;
		iAirDamage[player] = 0;
		iMarketed[player] = 0;
		iStabbed[player] = 0;
		flCharge[player] = 0.0;
		flKillStreak[player] = 0.0;
		flGlowTimer[player] = 0.0;
		bInJump[player] = false;
		OnPreventCoreOnTakeDamageChanges[player] = false;
	}
	RetryCounter = 10;
}
