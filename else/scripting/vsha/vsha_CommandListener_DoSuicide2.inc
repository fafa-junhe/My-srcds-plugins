// vsha_CommandListener_DoSuicide2.inc

public Action DoSuicide2(int client, const char[] command, int argc)
{
	if (Enabled && bIsBoss[client] && bTenSecStart[0])
	{
		CPrintToChat(client, "You Can't Change Teams This Early!!");
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

