/*
 * Include for "Eye for an Eye" Bad Perk.
 * This include is used in #manager.sp
 */

static bool bEyeForEye[MAXPLAYERS + 1];

void EyeForAnEye_BadPerk(int client, bool enabled)
{
	bEyeForEye[client] = enabled;
}

void EyeForAnEye_OnTakeDamage(int victim, int &attacker, float &damage)
{
	if (victim > 0 && victim <= MAXPLAYERS + 1 && attacker > 0 && attacker <= MAXPLAYERS + 1 && victim != attacker && bEyeForEye[attacker])
	{
		SDKHooks_TakeDamage(attacker, 0, attacker, damage);
	}
}