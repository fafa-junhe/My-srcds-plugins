// vsha_CreateTimer_HaleTimer.inc

public Action HaleTimer(Handle hTimer)
{
	//if (!Enabled || CheckRoundState() == ROUNDSTATE_ROUND_END || CheckRoundState() == ROUNDSTATE_INVALID) return Plugin_Stop;
	if (!Enabled || CheckRoundState() == ROUNDSTATE_ROUND_END ) return Plugin_Stop;
	LoopActiveBosses(iClient)
	{
		//if (IsValidClient(iClient) && !bIsBoss[iClient] && GetClientTeam(iClient) == OtherTeam) continue;
		if (IsValidClient(iClient) && GetClientTeam(iClient) == OtherTeam) continue;
		if (!IsPlayerAlive(iClient)) continue;
		char wepclassname[32];
		//int killstreaker = iDamage[i] / 500;
		//if (killstreaker >= 1) SetEntProp(i, Prop_Send, "m_iKillStreak", killstreaker);
		PlayerHUD(iClient);
		TFClassType class = TF2_GetPlayerClass(iClient);
		int weapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		int index = GetItemIndex(weapon);
		if (TF2_IsPlayerInCondition(iClient, TFCond_Cloaked))
		{
			if (GetClientCloakIndex(iClient) == 59)
			{
				if (TF2_IsPlayerInCondition(iClient, TFCond_DeadRingered)) TF2_RemoveCondition(iClient, TFCond_DeadRingered);
			}
			else TF2_AddCondition(iClient, TFCond_DeadRingered, 0.3);
		}
		if ( iRedAlivePlayers == 1 && !TF2_IsPlayerInCondition(iClient, TFCond_Cloaked) )
		{
			TF2_AddCondition(iClient, TFCond_HalloweenCritCandy, 0.3);
			int primary = GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary);
			if (class == TFClass_Engineer && weapon == primary && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false)) SetEntProp(iClient, Prop_Send, "m_iRevengeCrits", 3);

			TF2_AddCondition(iClient, TFCond_Buffed, 0.3);

			//VSHA_SetVar(EventClient,iClient);
			//VSHA_Private_Forward("VSHA_OnLastSurvivorLoop");
			VSHA_OnLastSurvivorLoop(iClient);

			//if (bAllowSuperWeap && HaleHealth >= 7000) PickSuperWeapon(i, -1); later
			continue;
		}
		if ( iRedAlivePlayers == 2 && !TF2_IsPlayerInCondition(iClient, TFCond_Cloaked) ) TF2_AddCondition(iClient, TFCond_Buffed, 0.3);

		//==============================	C R I T S  P A R T S	   =============================================
		TFCond cond = TFCond_HalloweenCritCandy;
		if (TF2_IsPlayerInCondition(iClient, TFCond_CritCola) && (class == TFClass_Scout || class == TFClass_Heavy))
		{
			TF2_AddCondition(iClient, cond, 0.3);
			continue;
		}
		bool EnableCrits[2] = {false, false}; //0 - minicrits, 1 - full crits
		LoopAlivePlayers(iTarget)
		{
			if ( (0 < iTarget && iTarget <= MaxClients) && GetHealingTarget(iTarget) == iClient )
			{
				EnableCrits[0] = true;
				break;
			}
		}
		if (weapon == GetPlayerWeaponSlot(iClient, TFWeaponSlot_Melee))
		{
			//slightly longer check but makes sure that any weapon that can backstab will not crit (e.g. Saxxy)
			if (strcmp(wepclassname, "tf_weapon_knife", false) != 0 && index != 416) EnableCrits[1] = true;
		}
		switch (index)
		{
			case 305, 1079, 1081, 56, 16, 203, 58, 1083, 1105, 1100, 1005, 1092, 812, 833, 997, 39, 351, 740, 588, 595: //Critlist
			{
				int flindex = GetIndexOfWeaponSlot(iClient, TFWeaponSlot_Primary);
				// No crits if using phlog
				if (TF2_GetPlayerClass(iClient) == TFClass_Pyro && flindex == 594) EnableCrits[1] = false;
				else EnableCrits[1] = true;
			}
			case 22, 23, 160, 209, 294, 449, 773:
			{
				EnableCrits[1] = true;
				if (class == TFClass_Scout && cond == TFCond_HalloweenCritCandy) cond = TFCond_Buffed;
			}
			case 656:
			{
				EnableCrits[1] = true;
				cond = TFCond_Buffed;
			}
		}
		if (index == 16 && EnableCrits[1] && IsValidEntity(FindPlayerBack(iClient, { 642 }, 1))) EnableCrits[1] = false;
		switch (class)
		{
			case TFClass_Spy:
			{
				if (weapon == GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary))
				{
					if (!TF2_IsPlayerCritBuffed(iClient) && !TF2_IsPlayerInCondition(iClient, TFCond_Buffed) && !TF2_IsPlayerInCondition(iClient, TFCond_Cloaked) && !TF2_IsPlayerInCondition(iClient, TFCond_Disguised) && !GetEntProp(iClient, Prop_Send, "m_bFeignDeathReady"))
					{
						TF2_AddCondition(iClient, TFCond_CritCola, 0.3);
					}
				}
			}
			case TFClass_Engineer:
			{
				if (weapon == GetPlayerWeaponSlot(iClient, TFWeaponSlot_Primary) && StrEqual(wepclassname, "tf_weapon_sentry_revenge", false))
				{
					int sentry = FindSentry(iClient);
					if (IsValidEntity(sentry))
					{
						int TargettedBoss = GetEntPropEnt(sentry, Prop_Send, "m_hEnemy");
						if (bIsBoss[TargettedBoss])
						{
							SetEntProp(iClient, Prop_Send, "m_iRevengeCrits", 3);
							TF2_AddCondition(iClient, TFCond_Kritzkrieged, 0.3);
						}
					}
					else
					{
						if (GetEntProp(iClient, Prop_Send, "m_iRevengeCrits")) SetEntProp(iClient, Prop_Send, "m_iRevengeCrits", 0);
						else if (TF2_IsPlayerInCondition(iClient, TFCond_Kritzkrieged) && !TF2_IsPlayerInCondition(iClient, TFCond_Healing))
						{
							TF2_RemoveCondition(iClient, TFCond_Kritzkrieged);
						}
					}
				}
			}
			case TFClass_Medic:
			{
				if (weapon == GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary))
				{
					int healtarget = GetHealingTarget(iClient);
					if (IsValidClient(healtarget) && TF2_GetPlayerClass(healtarget) == TFClass_Scout)
					{
						TF2_AddCondition(iClient, TFCond_SpeedBuffAlly, 0.3);
					}
				}
			}
			case TFClass_DemoMan:
			{
				if (!IsValidEntity(GetPlayerWeaponSlot(iClient, TFWeaponSlot_Secondary)))
				{
					EnableCrits[1] = true;
					/*if (!bDemoShieldCrits &&GetEntPropEnt(i, Prop_Send, "m_hActiveWeapon") != GetPlayerWeaponSlot(i, TFWeaponSlot_Melee)) cond = TFCond_Buffed;*/
				}
			}
		}
		if (EnableCrits[1])
		{
			TF2_AddCondition(iClient, cond, 0.3);
			if (EnableCrits[0] && cond != TFCond_Buffed) TF2_AddCondition(iClient, TFCond_Buffed, 0.3);
		}
	}
	return Plugin_Continue;
}
