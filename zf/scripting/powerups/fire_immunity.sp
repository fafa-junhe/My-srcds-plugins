/*
 * Include for Bullet Immunity powerup.
 * This include is used in #manager.sp
 *
 */
 
void FireImmunity_Powerup(int client, bool enabled)
{
	if (enabled)
	{
		TF2_AddCondition(client, TFCond_FireImmune);
		EmitSoundToAll("items/powerup_pickup_resistance.wav", client);
	}
	
	else
	{
		TF2_RemoveCondition(client, TFCond_FireImmune);
	}
}

void FireImmunity_OnMapStart()
{
	PrecacheSound("items/powerup_pickup_resistance.wav");
}