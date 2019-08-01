/*
 * Include for Slowed Bad Perk.
 * This include is used in #manager.sp
 *
 */
 
static Handle g_hSlowedTimer[MAX_CLIENTS];
static int g_iSpeedOffset;

void Slowed_OnPluginStart()
{
	g_iSpeedOffset = FindSendPropInfo("CTFPlayer", "m_flMaxspeed");
}

void Slowed_BadPerk(int client, bool enabled)
{
	if (enabled)
	{
		g_hSlowedTimer[client] = CreateTimer(0.1, Timer_SlowedBadPerk, client, TIMER_REPEAT);
	}
	
	else
	{
		KillTimer(g_hSlowedTimer[client]);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.1);
	}
}

public Action Timer_SlowedBadPerk(Handle timer, any client)
{
	SetEntDataFloat(client, g_iSpeedOffset, 50.0);
}