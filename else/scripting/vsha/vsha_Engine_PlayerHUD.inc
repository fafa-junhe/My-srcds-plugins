// vsha_Engine_PlayerHUD.inc

public void PlayerHUD(int client)
{
	if(bIsBoss[client]) return;

	if(!ValidPlayer(client,true)) return;

	if (GetClientButtons(client) & IN_SCORE) return;
	TFClassType tfclass = TF2_GetPlayerClass(client);
	if (!IsClientObserver(client) && IsPlayerAlive(client))
	{
		switch (tfclass)
		{
			case TFClass_Spy:
			{
				if (GetClientCloakIndex(client) == 59)
				{
					int drstatus = TF2_IsPlayerInCondition(client, TFCond_Cloaked) ? 2 : GetEntProp(client, Prop_Send, "m_bFeignDeathReady") ? 1 : 0;
					char s[32];
					switch (drstatus)
					{
						case 1:
						{
							SetHudTextParams(-1.0, 0.83, HudTextScreenHoldTime, 90, 255, 90, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Feign-Death Ready");
						}
						case 2:
						{
							SetHudTextParams(-1.0, 0.83, HudTextScreenHoldTime, 255, 64, 64, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Dead-Ringered");
						}
						default:
						{
							SetHudTextParams(-1.0, 0.83, HudTextScreenHoldTime, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
							Format(s, sizeof(s), "Status: Inactive");
						}
					}
					ShowSyncHudText(client, MiscHUD, "%s", s);
				}
	    		}
			case TFClass_Medic:
			{
				int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
				if (GetItemQuality(medigun) == 10)
				{
					SetHudTextParams(-1.0, 0.83, HudTextScreenHoldTime, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					int charge = RoundToFloor(GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel")*100);
					ShowSyncHudText(client, MiscHUD, "ÃœberCharge: %i%", charge);
				}
			}
			case TFClass_Soldier:
			{
				if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Primary) == 1104)
				{
					SetHudTextParams(-1.0, 0.83, HudTextScreenHoldTime, 255, 255, 255, 255, 0, 0.2, 0.0, 0.1);
					ShowSyncHudText(client, MiscHUD, "Air-Strike Damage: %i", iAirDamage[client]);
				}
			}
		}
		SetHudTextParams(-1.0, 0.88, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
	}
	else if ( IsClientObserver(client) || !IsPlayerAlive(client) )
	{
		SetHudTextParams(-1.0, 0.88, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
		int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
		if (IsValidClient(spec))
		{
			ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i} | [%N's Damage]: {%i}", iDamage[client], spec, iDamage[spec]);
		}
		else
		{
			ShowSyncHudText(client, hPlayerHUD, "[Damage]: {%i}", iDamage[client]);
		}
	}
}

