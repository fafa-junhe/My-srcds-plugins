/*
 * Include for Ubercharge powerup.
 * This include is used in #manager.sp
 *
 */
 
void Ubercharge_Powerup(int client, bool enabled)
{
	if (enabled)
	{
		TF2_AddCondition(client, TFCond_UberchargedCanteen);
		EmitSoundToAll("player/invulnerable_on.wav", client);
	} 
	
	else 
	{
		TF2_RemoveCondition(client, TFCond_UberchargedCanteen);
	}
}

void Ubercharge_OnMapStart()
{
	PrecacheSound("player/invulnerable_on.wav");
}