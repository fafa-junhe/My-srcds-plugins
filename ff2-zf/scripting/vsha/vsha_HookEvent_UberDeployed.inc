// vsha_HookEvent_UberDeployed.inc

public Action UberDeployed(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId( event.GetInt("userid") );
	//int target = GetClientOfUserId(event.GetInt("targetid"));
	if (IsPlayerAlive(client) )
	{
		int medigun = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		if (GetItemQuality(medigun) == 10)
		{
			TF2_AddCondition(client, TFCond_HalloweenCritCandy, 0.5, client);
			int target = GetHealingTarget(client);
			if (IsValidClient(target) && IsPlayerAlive(target))
			{
				TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5, client);
				iUberedTarget[client] = target;
			}
			else iUberedTarget[client] = -1;
			SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 1.50);
			CreateTimer(0.4, Timer_Uber, EntIndexToEntRef(medigun), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

