// vsha_HookEvent_Deflected.inc

public Action Deflected(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || event.GetInt("weaponid") ) return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("ownerid"));
	if ( bIsBoss[client] )
	{
		//int airblaster = GetClientOfUserId(event.GetInt("userid"));

		VSHA_OnBossAirblasted(event, client);

	}
	return Plugin_Continue;
}
