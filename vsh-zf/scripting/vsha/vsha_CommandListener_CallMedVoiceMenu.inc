// vsha_CommandListener_CallMedVoiceMenu.inc

public Action CallMedVoiceMenu(int iClient, const char[] sCommand, int iArgc)
{
	if (iArgc < 2) return Plugin_Handled;
	char sCmd1[8]; GetCmdArg(1, sCmd1, sizeof(sCmd1));
	char sCmd2[8]; GetCmdArg(2, sCmd2, sizeof(sCmd2));
	//Capture call for medic commands (represented by "voicemenu 0 0")
	if (sCmd1[0] == '0' && sCmd2[0] == '0' && IsPlayerAlive(iClient) && bIsBoss[iClient])
	{
		DoTaunt(iClient, "", 0);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

