// vsha_SDKHooks_OnGetMaxHealth.inc

/**
* OnGetMaxHealth:
*
* Helps keep Hale from looking as if he has overheal.
*
*/
public Action OnGetMaxHealth(int client, int &maxhealth)
{
	if( CheckRoundState() != ROUNDSTATE_START_ROUND_TIMER)
	{
		return Plugin_Continue;
	}
	if(!ValidPlayer(client,true)) return Plugin_Continue;
	if(!bIsBoss[client]) return Plugin_Continue;
	if(iBossMaxHealth[client]<=0) return Plugin_Continue;

	int HP = GetEntProp(client, Prop_Data, "m_iHealth");
	if(HP>iBossMaxHealth[client] || HP<iBossHealth[client])
	{
		SetEntProp(client, Prop_Data, "m_iHealth", iBossHealth[client]);
	}
	maxhealth=iBossMaxHealth[client];
	return Plugin_Handled;
}
