// vsha_CreateTimer_Timer_CheckDoors.inc

public Action Timer_CheckDoors(Handle hTimer)
{
	if ( (!Enabled && CheckRoundState() != -1) || (Enabled && CheckRoundState() != 1) )
	{
		//ClearTimer(hdoorchecktimer);
		return Plugin_Stop;
	}
	int ent = -1;
	while ( (ent = FindEntityByClassname2(ent, "func_door")) != -1 )
	{
		AcceptEntityInput(ent, "Open");
		AcceptEntityInput(ent, "Unlock");
	}
	return Plugin_Continue;
}
