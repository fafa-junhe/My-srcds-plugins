// vsha_CreateTimer_InitBoss.inc

public Action InitBoss(Handle timer, int data)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && bIsBoss[i])
		{
			bNoTaunt[i] = false;
			//PawnTimer(MakeBoss, 0.2, iBossUserID[i]); //CreateTimer(0.2, MakeBoss, iBossUserID[i]);
			CreateTimer(0.2, MakeBoss, iBossUserID[i]);
		}
	}
	hInitBossTimer = null;
	return Plugin_Continue;
}
