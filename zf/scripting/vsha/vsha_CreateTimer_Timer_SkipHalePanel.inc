// vsha_CreateTimer_Timer_SkipHalePanel.inc

public Action Timer_SkipHalePanel(Handle hTimer)
{
	int i, j, client;
	do
	{
		client = FindNextBoss(bIsBoss);
		if (IsValidClient(client) && !bIsBoss[client])
		{
			if (!IsFakeClient(client))
			{
				CPrintToChat(client, "{olive}[VSHA Engine]{default} You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.");
				if (i == 0) SkipHalePanelNotify(client);
			}
			i++;
		}
		j++;
	}
	while (i < 3 && j < PLYR);
	return Plugin_Continue;
}
public void SkipHalePanelNotify(int client)
{
	if (!Enabled || !IsValidClient(client) || IsVoteInProgress()) return;
	Handle panel = CreatePanel();
	char s[PATH];
	SetPanelTitle(panel, "[VSHA Engine] You're the next Boss!");
	Format(s, sizeof(s), "You are going to be Hale soon! Type {olive}/halenext{default} to check/reset your queue points.\nAlternatively, use !resetq.");
	CRemoveTags(s, sizeof(s));
	ReplaceString(s, sizeof(s), "{olive}", "");
	ReplaceString(s, sizeof(s), "{default}", "");
	DrawPanelItem(panel, s);
	SendPanelToClient(panel, client, SkipHalePanelH, 30);
	CloseHandle(panel);
	return;
}
//(Handle:panel, client, MenuHandler:handler, time)
public int SkipHalePanelH(Menu menu, MenuAction action, int client, int selection)
{
	//for later
	//if ( IsValidAdmin(client, "b") ) Command_SetBoss( client, -1 );
	//else Command_SetSkill(client, -1);
	return;
}

