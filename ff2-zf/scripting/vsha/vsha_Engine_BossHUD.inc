// vsha_Engine_BossHUD.inc

public void BossHUD(int client)
{
	SetHudTextParams(-1.0, 0.88, 0.3, 90, 255, 90, 200); // was 1.0 .. from 0.3
	if ( !(GetClientButtons(client) & IN_SCORE) )
	{
		if (IsPlayerAlive(client) )
		{
			ClampCharge(flCharge[client]); //automatically clamp the rage charge so it never goes over in subplugins :>
			if (flCharge[client] == 100.0)
			{
				ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: FULL", iBossHealth[client], iBossMaxHealth[client]);
			}
			else
			{
				ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i%", iBossHealth[client], iBossMaxHealth[client], RoundFloat(flCharge[client]));
			}
		}
		else
		{
			int spec = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
			if (IsValidClient(spec) && bIsBoss[spec])
			{
				ShowSyncHudText(client, hBossHUD, "[Health]: {%i/%i} | [Charge]: %i", iBossHealth[spec], iBossMaxHealth[spec], RoundFloat(flCharge[spec]));
			}
		}
	}
	return;
}
