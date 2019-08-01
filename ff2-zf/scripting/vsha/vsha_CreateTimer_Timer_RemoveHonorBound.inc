// vsha_CreateTimer_Timer_RemoveHonorBound.inc

public Action Timer_RemoveHonorBound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64]; GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1) SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
	return Plugin_Continue;
}
