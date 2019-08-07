#define PLUGIN_VERSION "1.4"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define CVAR_FLAGS			FCVAR_NOTIFY

char g_sLogPath[PLATFORM_MAX_PATH] = "CRASH/restart.log"; // "addons/sourcemod/logs/restart.log";

public Plugin myinfo = 
{
	name = "Restart Empty", 
	author = "Alex Dragokas", 
	description = "Restart server when all players leave the game",
	version = PLUGIN_VERSION, 
	url = "https://dragokas.com"
};

/*
	ChangeLog
	1.0
	 - Initial release
	 
	1.1
	 - Added log file
	 
	1.2
	 - Removing crash logs caused by server restart for some reason
	 
	1.3
	 - Added sv_hibernate_when_empty to force server not hibernate allowing this plugin to make its work
	 - Added alternative method for restarting ("crash" command) (thanks to Luckylock)
	 - Added ConVars
	 - Crash logs remover: parser method is replaced by time based method.
	 - Create "CRASH" folder
	 
	1.4
	 - Fixed "Client index 0 is invalid" in IsFakeClient() check.
*/

ConVar g_ConVarEnable;
ConVar g_ConVarMethod;
ConVar g_ConVarDelay;
ConVar g_ConVarHibernate;

public void OnPluginStart()
{
	CreateConVar("sm_restart_empty_version", PLUGIN_VERSION, "Plugin Version", FCVAR_DONTRECORD);
	g_ConVarEnable = CreateConVar("sm_restart_empty_enable", "1", "Enable plugin (1 - On / 0 - Off)", CVAR_FLAGS);
	g_ConVarMethod = CreateConVar("sm_restart_empty_method", "1", "1 - _restart method, 2 - crash method (use if method # 1 is not work)", CVAR_FLAGS);
	g_ConVarDelay = CreateConVar("sm_restart_empty_delay", "10.0", "Grace period (in sec.) waiting for new player to join until beginning restart the server", CVAR_FLAGS);
	
	AutoExecConfig(true, "sm_restart_empty");

	g_ConVarHibernate = FindConVar("sv_hibernate_when_empty");
	
	if (!DirExists("CRASH"))
		CreateDirectory("CRASH", 511); // == bits 755
	
	RemoveCrashLog();
	
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_ConVarEnable.BoolValue)
		return Plugin_Continue;

	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if ((client == 0 || !IsFakeClient(client)) && !RealPlayerExist(client)) {
		g_ConVarHibernate.SetInt(0);
		CreateTimer(g_ConVarDelay.FloatValue, Timer_CheckPlayers);
	}
	return Plugin_Continue;
}

public Action Timer_CheckPlayers(Handle timer, int UserId)
{
	if (!RealPlayerExist()) {
		LogToFile(g_sLogPath, "Restarting server... Reason: no players.");
		
		if (g_ConVarMethod.IntValue == 1) {
			ServerCommand("_restart");
		}
		else {
			SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
			ServerCommand("crash");
		}
		
		/* P.S. Other commands seen:
			- "quit"
			- "exit"
		*/
	}
}

bool RealPlayerExist(int iExclude = 0)
{
	for (int client = 1; client < MaxClients; client++)
	{
		if (client != iExclude && IsClientConnected(client))
		{
			if (!IsFakeClient(client)) {
				return (true);
			}
		}
	}
	return (false);
}

void RemoveCrashLog()
{
	if (!FileExists(g_sLogPath))
		return;

	char sFile[PLATFORM_MAX_PATH];
	int ft, ftReport = GetFileTime(g_sLogPath, FileTime_LastChange);
	
	if (DirExists("CRASH")) {
		DirectoryListing hDir = OpenDirectory("CRASH");
		if (hDir != null) {
			while(hDir.GetNext(sFile, sizeof(sFile))){
				TrimString(sFile);
				if (StrContains(sFile, "crash-") != -1) {

					Format(sFile, sizeof(sFile), "CRASH/%s", sFile);
					ft = GetFileTime(sFile, FileTime_Created);
					
					if (0 < ft - ftReport < 10) { // fresh crash
						DeleteFile(sFile);
					}
				}
			}
			delete hDir;
		}
	}
}