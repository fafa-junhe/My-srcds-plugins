// vsha_CommandListener_DoSuicide.inc

public Action DoSuicide(int client, const char[] command, int argc)
{
	if ( Enabled && (CheckRoundState() == 0 || CheckRoundState() == 1) )
	{
		if (bIsBoss[client] && bTenSecStart[0])
		{
			CPrintToChat(client, "Do not suicide as a Boss, asshole!. Use !resetq instead.");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

