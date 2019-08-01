// vsha_HookEvent_JumpHook.inc

public Action JumpHook(Event event, const char[] name, bool dontBroadcast)
{
	SetRJFlag( GetClientOfUserId(event.GetInt("userid")), StrEqual(name, "rocket_jump", false) );
	return Plugin_Continue;
}
