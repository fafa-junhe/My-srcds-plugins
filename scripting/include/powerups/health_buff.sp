/*
 * Include for Health Buff powerup.
 * This include is used in #manager.sp
 *
 */
 
void HealthBuff_Powerup(int client, char[] properties, bool enabled)
{
	if (enabled)
	{
		int iHealthBuff = 500;
		
		if (String_IsInteger(properties))
		{
			iHealthBuff = StringToInt(properties);
		}
		
		else
		{
			LogError("[Powerups Shop] Invalid property for Health Buff. Using default value (500).");
		}
		
		SetEntityHealth(client, (GetEntProp(client, Prop_Data, "m_iHealth") + iHealthBuff));
		EmitSoundToAll("items/smallmedkit1.wav", client);
	}
}

void HealthBuff_OnMapStart()
{
	PrecacheSound("items/smallmedkit1.wav");
}