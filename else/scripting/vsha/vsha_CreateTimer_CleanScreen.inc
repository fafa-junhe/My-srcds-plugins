// vsha_CreateTimer_CleanScreen.inc

public Action CleanScreen(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if ( client <= 0 || !bIsBoss[client] ) return Plugin_Continue;
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
	ClientCommand(client, "r_screenoverlay \"\"");
	SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
	return Plugin_Continue;
}
