/*
 * Include for Suicide Bad Perk.
 * This include is used in #manager.sp
 *
 */
 
void Suicide_BadPerk(int client, bool enabled)
{
	if (enabled)
	{
		ForcePlayerSuicide(client);
		
		EmitSoundToAll("player/crit_received1.wav", client);
	}
}

void Suicide_OnMapStart()
{
	PrecacheSound("player/crit_received1.wav");
}