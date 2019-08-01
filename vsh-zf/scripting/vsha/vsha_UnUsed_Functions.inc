// vsha_UnUsed_Functions.inc

public Action CommandQueuePoints(int client, int args)
{
	//if(InternalPause) return Plugin_Continue;

	if ( !Enabled ) return Plugin_Continue;
	if (args != 2)
	{
		ReplyToCommand(client, "[VSHA Engine] Usage: vsha_addpoints <target> <points>");
		return Plugin_Handled;
	}
	char s2[80];
	char targetname[PLATFORM_MAX_PATH];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	int points = StringToInt(s2);
	char target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	if ( (target_count = ProcessTargetString(
			targetname,
			client,
			target_list,
			MAXPLAYERS,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (int i = 0; i < target_count; i++)
	{
		SetClientQueuePoints(target_list[i], GetClientQueuePoints(target_list[i])+points);
		LogAction(client, target_list[i], "\"%L\" added %d VSHA queue points to \"%L\"", client, points, target_list[i]);
	}
	ReplyToCommand(client, "[VSHA Engine] Added %d queue points to %s", points, target_name);
	return Plugin_Handled;
}
public Action CommandBossSelect(int client, int args)
{
	if (!Enabled) return Plugin_Continue;
	if (args < 1)
	{
		ReplyToCommand(client, "[VSHA] Usage: hale_select <target> [\"hidden\"]");
		return Plugin_Handled;
	}
	char s2[32];
	char targetname[32];
	GetCmdArg(1, targetname, sizeof(targetname));
	GetCmdArg(2, s2, sizeof(s2));
	if ( strcmp(targetname, "@me", false) == 0 && IsValidClient(client) ) iNextBossPlayer = client;
	else
	{
		int target = FindTarget(client, targetname);
		if (IsValidClient(target)) iNextBossPlayer = target;
	}
	return Plugin_Handled;
}
