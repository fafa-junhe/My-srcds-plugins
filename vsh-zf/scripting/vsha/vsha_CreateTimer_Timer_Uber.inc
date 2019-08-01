// vsha_CreateTimer_Timer_Uber.inc

public Action Timer_Uber(Handle timer, any medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if (IsValidEntity(medigun) && CheckRoundState() == 1)
	{
		int medic = GetOwner(medigun);
		if (IsValidClient(medic) && IsPlayerAlive(medic) && GetEntPropEnt(medic, Prop_Send, "m_hActiveWeapon") == medigun)
		{
			int target = GetHealingTarget(medic);
			if ( GetMediCharge(medigun) > 0.05 )
			{
				/*TF2_AddCondition(medic, TFCond_HalloweenCritCandy, 0.5); what's the point in giving the ubering medic crits?*/
				if (IsValidClient(target) && IsPlayerAlive(target))
				{
					TF2_AddCondition(target, TFCond_HalloweenCritCandy, 0.5);
					iUberedTarget[medic] = target;

					VSHA_OnUberTimer(medic, target);
				}
				else iUberedTarget[medic] = -1;
			}
		}
		if ( GetMediCharge(medigun) <= 0.05 )
		{
			CreateTimer(3.0, ResetUberCharge, EntIndexToEntRef(medigun));
			return Plugin_Stop;
		}
	}
	else return Plugin_Stop;
	return Plugin_Continue;
}
