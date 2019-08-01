// vsha_CommandListener_clDestroy.inc

public Action clDestroy(int client, const char[] command, int argc)
{
	if (!Enabled || bIsBoss[client]) return Plugin_Continue;
	if (client && TF2_GetPlayerClass(client) == TFClass_Engineer && TF2_IsPlayerInCondition(client, TFCond_Taunting) && GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 589) return Plugin_Handled;
	return Plugin_Continue;
}
