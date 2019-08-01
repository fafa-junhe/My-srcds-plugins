/*
 * Include for Bullet Immunity powerup.
 * This include is used in #manager.sp
 *
 */

void BulletImmunity_Powerup(int client, bool enabled)
{
	if (enabled)
	{
		TF2_AddCondition(client, TFCond_BulletImmune);
		EmitSoundToAll("items/powerup_pickup_resistance.wav", client);
	}
	
	else
	{
		TF2_RemoveCondition(client, TFCond_BulletImmune);
	}
}

void BulletImmunity_OnMapStart()
{
	PrecacheSound("items/powerup_pickup_resistance.wav");
}