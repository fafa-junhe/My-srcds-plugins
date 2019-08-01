// vsha_CreateTimer_DoMessage.inc

public Action DoMessage(Handle timer, int data)
{
	if (CheckRoundState() != 0)
	{
		hDoMessage = null;
		return Plugin_Continue;
	}

	int entity = -1;
	while ( (entity = FindEntityByClassname2(entity, "func_door")) != -1 )
	{
		AcceptEntityInput(entity, "Open");
		AcceptEntityInput(entity, "Unlock");
	}
	if ( hdoorchecktimer == null )
	{
		hdoorchecktimer = CreateTimer(5.0, Timer_CheckDoors, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}

	int CountBosses = 0;
	LoopActiveBosses(target)
	{
		CountBosses++;
	}

	char sBossName[32];
	char sClientName[32];


	//if(CountBosses>0)
	//{
	LoopActiveBosses(target)
	{
		if(VSHA_OnMessageTimer(target) == Plugin_Continue)
		{
			if(GetBossName(Storage[target],STRING(sBossName)))
			{
				GetClientName(target,STRING(sClientName));
				CPrintToChatAll("%s %s became %s starting with %d HP",VSHA_COLOR,sClientName,sBossName,iBossMaxHealth[target]);
			}
		}
	}
	//}

	//VSHA_Private_Forward("VSHA_MessageTimer");
	//VSHA_OnMessageTimer();

	/*SetHudTextParams(-1.0, 0.4, 10.0, 255, 255, 255, 255);
	char text[PATHX];
	for (int client = 1; bIsBoss[client]; client++)
	{
		if ( !IsValidClient(client) ) continue;
		Format(text, sizeof(text), "%s\n%N became %s with %i HP", text, client, charBossName, iBossMaxHealth[client]);
	}
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsValidClient(client) ) ShowHudText(client, -1, text);
	}*/
	hDoMessage = null;
	return Plugin_Continue;
}
