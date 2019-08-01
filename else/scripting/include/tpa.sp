#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
new Float:fuck[][3];
public Plugin:myinfo =
{
	name = "tpaccept",
	author = "233fafa_junhe",
	description = "tpaccept",
	version = "1.0",
	url = "nope"
};
public void OnPluginStart ()
{
	RegConsoleCmd("sm_yes", Command_Accept);
	RegConsoleCmd("sm_no", Command_Refuse);
	RegConsoleCmd("sm_tpa", Command_Tpa);
	PrintToServer("tpaccept load!");
}
public Action Command_Tpa(int client, int args)
{
	if (args < 1)
	{
		PrintToConsole(client, "Usage: admin_kick <name>");
		return Plugin_Handled;
	}
 
	char name[32];
        int target = -1;
	GetCmdArg(1, name, sizeof(name));
 
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientConnected(i))
		{
			continue;
		}
		char other[32];
		GetClientName(i, other, sizeof(other));
		if (StrEqual(name, other))
		{
			target = i;
		}
	}
 
	if (target == -1)
	{
		PrintToConsole(client, "Could not find any player with the name: \"%s\"", name);
		return Plugin_Handled;
	}
 
	if (!CanUserTarget(client, target))
	{
		PrintToConsole(client, "You cannot target this client.");
		return Plugin_Handled;
	}
	GetClientAbsOrigin(target, fuck[3]);
 	TeleportEntity(client, fuck[target], NULL_VECTOR, NULL_VECTOR);
	return Plugin_Handled;
}
public Action Command_Accept(int client, int args)
{
}
public Action Command_Refuse(int client, int args)
{
}