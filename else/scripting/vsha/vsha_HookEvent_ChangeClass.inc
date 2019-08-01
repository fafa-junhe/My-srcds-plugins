// vsha_HookEvent_ChangeClass.inc

public Action ChangeClass(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId( event.GetInt("userid") );
	if (bIsBoss[client])
	{
		VSHA_OnBossChangeClass(event, client);
	}
	return Plugin_Continue;
}

