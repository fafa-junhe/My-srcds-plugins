/*
 * Include for Reduced Damage Bad Perk.
 * This include is used in #manager.sp
 */
 
static bool bReducedDamage[MAXPLAYERS + 1];
static float multiplier = 0.3;
static bool multiplierReceived = false;
 
void ReducedDamage_BadPerk(int client, char[] properties, bool enabled)
{
	if (!multiplierReceived)
	{
		if (String_IsInteger(properties))
		{
			multiplier = float(StringToInt(properties));
		}
		
		else if (String_IsFloat(properties))
		{
			multiplier = StringToFloat(properties);
		}
		
		else
		{
			LogError("[Powerups Shop] Reduced Damage property is invalid. Using default damage multiplier (0.3).");
		}
		
		multiplierReceived = true;
	}
	
	bReducedDamage[client] = enabled;
}

Action ReducedDamage_OnTakeDamage(int victim, int &attacker, float &damage)
{
	if (victim > 0 && victim <= MAXPLAYERS + 1 && attacker > 0 && attacker <= MAXPLAYERS + 1 && victim != attacker && bReducedDamage[attacker])
	{
		damage *= multiplier;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}