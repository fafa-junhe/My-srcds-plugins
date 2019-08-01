/*
 * Include for Criticals powerup.
 * This include is used in #manager.sp
 *
 */
 
void Criticals_Powerup(int client, bool enabled)
{
	if (enabled)
	{
		TF2_AddCondition(client, TFCond_CritCanteen);
		EmitSoundToAll("items/powerup_pickup_uber.wav", client);
	}
	
	else
	{
		TF2_RemoveCondition(client, TFCond_CritCanteen);
	}
}

void Criticals_OnMapStart()
{
	PrecacheSound("items/powerup_pickup_uber.wav");
}