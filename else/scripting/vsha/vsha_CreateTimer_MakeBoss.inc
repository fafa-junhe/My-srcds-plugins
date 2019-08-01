// vsha_CreateTimer_MakeBoss.inc

public Action MakeBoss(Handle timer, int userid)
{
	//DP("MakeBoss");
	int iClient = GetClientOfUserId(userid);

	//if(iClient > 0)
	//{
		//DP("MakeBoss MakeModelTimer PawnTimer");
		//PawnTimer(MakeModelTimer, 0.1, iBossUserID[iClient]); //CreateTimer(0.2, MakeModelTimer, iBossUserID[iClient]);

		//CreateTimer(0.0, MakeModelTimer, userid);
	//}

	if ( iClient <= 0 || !IsClientInGame(iClient) || !bIsBoss[iClient] ) return;


	if(VSHA_OnGameMode_ForceBossTeamChange(vshaMakeBoss, iClient, HaleTeam) != Plugin_Handled)
	{
		ForceTeamChange(iClient, HaleTeam);
		//DP("MakeBoss ForceTeamChange");
	}
	//DP("vsha_PawnTimer_MakeBoss 18 ForceTeamChange(i, HaleTeam)");

	//DP("MakeBoss ForceTeamChange");

	if ( !IsPlayerAlive(iClient) )
	{
		if ( CheckRoundState() == 0 ) TF2_RespawnPlayer(iClient);
		else return;
	}

	//DP("MakeBoss MakeModelTimer");

	//if(ModelTimer[iClient] == null)
	//{
		//ModelTimer[iClient] = CreateTimer(10.0, MakeModelTimer, iBossUserID[iClient], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	//}

	int ent = -1, index = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable")) != -1)
	{
		if (GetOwner(ent) == iClient)
		{
			index = GetItemIndex(ent);
			switch (index)
			{
				case 167, 438, 463, 477, 1015, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120: {}
				default: TF2_RemoveWearable(iClient, ent); //AcceptEntityInput(ent, "kill");
			}
		}
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_powerup_bottle")) != -1)
	{
		if (GetOwner(ent) == iClient) TF2_RemoveWearable(iClient, ent); //AcceptEntityInput(ent,
	}
	ent = -1;
	while ((ent = FindEntityByClassname2(ent, "tf_wearable_demoshield")) != -1)
	{
		if (GetOwner(ent) == iClient) TF2_RemoveWearable(iClient, ent);
	}
	//TF2_RemoveAllWeapons2(iClient);
	//TF2_RemovePlayerDisguise(iClient);

	SDKHook(iClient, SDKHook_GetMaxHealth, OnGetMaxHealth);

	VSHA_OnPrepBoss(iClient);

	CreateTimer(0.2, CleanScreen, iBossUserID[iClient]);
	return;
}
