// vsha_CreateTimer_MakeModelTimer.inc

public Action MakeModelTimer(Handle hTimer, any userid)
{
	//DP("Action MakeModelTimer");
	//int iClient = GetClientOfUserId(userid);
	//if ( iClient <= 0 || CheckRoundState() = ROUNDSTATE_INVALID  || CheckRoundState() = ROUNDSTATE_ROUND_END || !bIsBoss[iClient] ) return Plugin_Stop;

	if ( (CheckRoundState() == ROUNDSTATE_INVALID) || (CheckRoundState() == ROUNDSTATE_ROUND_END) ) return Plugin_Continue;

	int iBossArrayListIndex = -1;
	char ModelString[PATHX];
	char sClientName[32];
	for (int i = 0; i < hArrayModelManagerPlugin.Length; i++)
	{
		iBossArrayListIndex = hArrayModelManagerPlugin.Get(i);
		hArrayModelManagerStringName.GetString(i, STRING(ModelString));

		if(iBossArrayListIndex < 0) continue;

		LoopAlivePlayers(TargetPlayer)
		{
			if(IsPlayerAlive(TargetPlayer))
			{
				if(bIsBoss[TargetPlayer])
				{
					if (BossArrayListIndex[TargetPlayer] == iBossArrayListIndex)
					{
						GetClientName(TargetPlayer,STRING(sClientName));
						//PrintToServer("ModelString %s Applied to %s",ModelString,sClientName);
						// apply ModelString to player
						SetVariantString(ModelString);
						AcceptEntityInput(TargetPlayer, "SetCustomModel");
						SetEntProp(TargetPlayer, Prop_Send, "m_bUseClassAnimations", 1);
					}
				}
				else
				{
						SetVariantString("");
						AcceptEntityInput(TargetPlayer, "SetCustomModel");
						//SetEntProp(TargetPlayer, Prop_Send, "m_bUseClassAnimations", 1);
				}
			}
			else
			{
					SetVariantString("");
					AcceptEntityInput(TargetPlayer, "SetCustomModel");
					//SetEntProp(TargetPlayer, Prop_Send, "m_bUseClassAnimations", 1);
			}
		}
	}

	/*
	if ( !bIsBoss[iClient] )
	{
		//DP("MakeModelTimer ValidPlayer");

		//DP("iModelRetrys %d",iModelRetrys[iClient]);

		if(iModelRetrys[iClient] > 0)
		{
			//DP("MakeModelTimer PawnTimer");
			iModelRetrys[iClient]--;
			//PawnTimer(MakeModelTimer, 0.2, GetClientUserId(iClient));
			CreateTimer(0.2, MakeModelTimer, GetClientUserId(iClient));
			return Plugin_Continue;
		}
		return Plugin_Stop;
	}

	//DP("Loading Private Forward");

	char model[PATHX];
	//StringMap ModelMap = new StringMap();
	//ModelMap.SetString("Model", model);

	//VSHA_SetVar(EventModel,ModelMap);
	//VSHA_SetVar(EventModelTimer,iClient);
	//Action result = VSHA_Private_Forward("VSHA_OnModelTimer");
	*
	* // OLD TECH
	Action result = VSHA_OnModelTimer(Storage[iClient], iClient, model);
	if(result == Plugin_Changed)
	{
		//DP("VSHA_OnModelTimer result != Plugin_Continue");

		//PrintToChatAll("model = '%s'",model);

		//TrimString(model);

		SetVariantString(model);
		AcceptEntityInput(iClient, "SetCustomModel");
		SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);

		iModelRetrys[iClient]=0;
	}


	Function FuncModelTimer = GetFunctionByName(Storage[iClient], "VSHA_OnModelTimer");
	if (FuncModelTimer != nullfunc)
	{
		Call_StartFunction(Storage[iClient], FuncModelTimer);
		Call_PushCell(iClient);
		char model[PATH];
		Call_PushStringEx(model, sizeof(model), 0, SM_PARAM_COPYBACK);
		Call_Finish(result);

		SetVariantString(model);
		AcceptEntityInput(iClient, "SetCustomModel");
		SetEntProp(iClient, Prop_Send, "m_bUseClassAnimations", 1);
		return result;
	}
	else LogError("**** VSH Engine Error: Cannot find 'VSHA_OnModelTimer' Function ****");
	*/
	return Plugin_Continue;
}

