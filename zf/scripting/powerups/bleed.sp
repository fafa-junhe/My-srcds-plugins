/*
 * Include for Bleed Bad Perk.
 * This include is used in #manager.sp
 *
 */
 
static Handle g_hBleedTimer[MAX_CLIENTS];
 
void Bleed_BadPerk(int client, bool enabled)
{
	if (enabled)
	{
		g_hBleedTimer[client] = CreateTimer(1.0, Timer_BleedBadPerk, client, TIMER_REPEAT);
	}
	
	else
	{
		KillTimer(g_hBleedTimer[client]);
	}
}

public Action Timer_BleedBadPerk(Handle timer, any client)
{
	TF2_MakeBleed(client, client, 1.0);
}