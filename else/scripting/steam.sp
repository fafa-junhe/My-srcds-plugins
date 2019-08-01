#include <sourcemod>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
name = "What's My SteamID",
author = "[HvG] Shitler",
description = "Prints out your SteamID and IP in chat",
version = PLUGIN_VERSION,
url = "http://steamcommunity.com/groups/HighVoltageServers"
};

public OnPluginStart()
{
SetConVarString(CreateConVar("sm_users_version", PLUGIN_VERSION, "Show steam id version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_CHEAT), PLUGIN_VERSION);


RegConsoleCmd("sm_steamid", steam, "STEAM ID True Chat!");

}

public Action:steam(client,args)
{
if (args < 1)
{
new String:user_steamid[21];
GetClientAuthString(client, user_steamid, 21);
PrintToChat(client, "%s", user_steamid);
}
return Plugin_Handled
}
