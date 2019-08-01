/*
 * Include for Explosion Immunity powerup.
 * This include is used in #manager.sp
 *
 */
 
void ExplosionImmunity_Powerup(int client, bool enabled)
{
	if (enabled)
	{
		TF2_AddCondition(client, TFCond_BlastImmune);
		EmitSoundToAll("items/powerup_pickup_resistance.wav", client);
	}
	
	else
	{
		TF2_RemoveCondition(client, TFCond_BlastImmune);
	}
}

void ExplosionImmunity_OnMapStart()
{
	PrecacheSound("items/powerup_pickup_resistance.wav");
}