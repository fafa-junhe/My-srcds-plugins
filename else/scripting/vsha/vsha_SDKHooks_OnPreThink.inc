// vsha_SDKHooks_OnPreThink.inc

public void OnPreThink(int client)
{
	if (Enabled)
	{
		if (IsNearSpencer(client) && TF2_IsPlayerInCondition(client, TFCond_Cloaked))
		{
			float cloak = GetEntPropFloat(client, Prop_Send, "m_flCloakMeter")-0.5; //PUT CVAR HEER
			if (cloak < 0.0) cloak = 0.0;
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
}
