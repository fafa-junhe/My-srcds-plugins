// vsha_HookEvent_RoundEnd.inc


public Action RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled)
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::RoundEnd() **** RoundEnd - Plugin is Disabled ****");
		DEBUGPRINT2("{lime}VSH Engine::RoundEnd() **** RoundEnd - Plugin is Disabled ****");
#endif
		return Plugin_Continue;
	}
	TeamRoundCounter++;
	RoundCount++;
	int i;
	bool playedwinsound = false;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( !IsValidClient(i) ) continue;
		if ( bIsBoss[i] )
		{
			//ClearTimer(ModelTimer[i]);

			SetClientQueuePoints(i, 0);
			if (event.GetInt("team") == GetClientTeam(i) && !playedwinsound)
			{
				//VSHA_SetVar(SmEvent,event);
				//VSHA_SetVar(EventBoss,i);
				//VSHA_Private_Forward("VSHA_OnBossWin");

				VSHA_OnBossWin(event, i);

				playedwinsound = true;
			}
			SetEntProp(i, Prop_Send, "m_bGlowEnabled", 0);
			flGlowTimer[i] = 0.0;
			if ( IsPlayerAlive(i) ) CPrintToChatAll("{olive}[VSHA Engine]{default} %N had %i of %i", i, iBossHealth[i], iBossMaxHealth[i]);
			else
			{
				if (GetClientTeam(i) != HaleTeam)
				{
					if(VSHA_OnGameMode_ForceBossTeamChange(vshaRoundEnd, i, HaleTeam) != Plugin_Handled)
					{
						ForceTeamChange(i, HaleTeam);
						//DP("vsha_HookEvent_RoundEnd 39 ForceTeamChange(i, HaleTeam)");
					}
				}
			}
			// moved to calculate points
			//bIsBoss[i] = false;
		}
		else // reset client shit heer
		{
		}
	}

	int top[3];
	iDamage[0] = 0;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( iDamage[i] <= 0 ) continue;
		if ( iDamage[i] >= iDamage[top[0]] )
		{
			top[2] = top[1];
			top[1] = top[0];
			top[0] = i;
		}
		else if ( iDamage[i] >= iDamage[top[1]] )
		{
			top[2] = top[1];
			top[1] = i;
		}
		else if ( iDamage[i] >= iDamage[top[2]] )
		{
			top[2] = i;
		}
	}
	if ( iDamage[top[0]] > 9000 )
	{
		CreateTimer(1.0, TimerNineThousand, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	char first[32];
	if ( IsValidClient(top[0]) && (GetClientTeam(top[0]) == OtherTeam) ) GetClientName(top[0], first, 32);
	else
	{
		Format(first, sizeof(first), "---");
		top[0] = 0;
	}

	char second[32];
	if ( IsValidClient(top[1]) && (GetClientTeam(top[1]) == OtherTeam) ) GetClientName(top[1], second, 32);
	else
	{
		Format(second, sizeof(second), "---");
		top[1] = 0;
	}

	char third[32];
	if ( IsValidClient(top[2]) && (GetClientTeam(top[2]) == OtherTeam) ) GetClientName(top[2], third, 32);
	else
	{
		Format(third, sizeof(third), "---");
		top[2] = 0;
	}

	SetHudTextParams(-1.0, 0.3, 10.0, 255, 255, 255, 255);
	PrintCenterTextAll(""); //Should clear center text
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i) && !(GetClientButtons(i) & IN_SCORE))
		{
			ShowHudText(i, -1, "Most Damage Dealt By:\n1)%i - %s\n2)%i - %s\n3)%i - %s\n\nDamage Dealt: %i\nScore for this round: %i", iDamage[top[0]], first, iDamage[top[1]], second, iDamage[top[2]], third, iDamage[i], RoundFloat(iDamage[i]/600.0));
		}
	}

	CreateTimer(0.2, CalcScores, _, TIMER_FLAG_NO_MAPCHANGE);

	VSHA_OnGameOver();

	return Plugin_Continue;
}
