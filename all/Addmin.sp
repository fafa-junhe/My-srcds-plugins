#include <sourcemod>

char KvPath[256];

char TargetFlagsRegistred[MAXPLAYERS][64];
char TargetGivenSteamID[MAXPLAYERS][64];
char TargetName[MAXPLAYERS][64];

bool TargetHasFlags[MAXPLAYERS];
bool ClientCanSayID[MAXPLAYERS];
bool ClientCanSayName[MAXPLAYERS];

int TargetSymbol[MAXPLAYERS];
int CGB[MAXPLAYERS];
int iSQL;
Handle g_hCvarSQL;

public Plugin:myinfo = 
{
	name = "In Game Admin Manager",
	author = "Facksy",
	description = "In-Game Admin Manager",
	version = "1.0",
	url = "http://steamcommunity.com/id/iamfacksy/"
}

public OnPluginStart()
{
	RegAdminCmd("sm_addmin", Cmd_Addmin, ADMFLAG_ROOT, "Open Admin Manager");
	RegAdminCmd("sm_addmins", Cmd_Addmin, ADMFLAG_ROOT, "Open Admin Manager");
	RegAdminCmd("sm_addadmin", Cmd_Addmin, ADMFLAG_ROOT, "Open Admin Manager");
	RegAdminCmd("sm_addadmins", Cmd_Addmin, ADMFLAG_ROOT, "Open Admin Manager");
	RegAdminCmd("sm_adminmanager", Cmd_Addmin, ADMFLAG_ROOT, "Open Admin Manager");
	
	g_hCvarSQL = CreateConVar("sm_sql_on", "1", "If MySQL or SQLlite is launched");
	iSQL = GetConVarInt(g_hCvarSQL);
	
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}

public OnMapStart()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			InitialiseCl(i);
		}
	}
}

public Action:InitialiseCl(client)
{
	if(IsValidClient(client))
	{
		Format(TargetFlagsRegistred[client], 64, "");
		Format(TargetGivenSteamID[client], 64, "");
		Format(TargetName[client], 64, "");
		
		TargetHasFlags[client] = false;
		ClientCanSayID[client] = false;
		ClientCanSayName[client] = false;
		
		TargetSymbol[client] == 0;
	}
}


public Action:Cmd_Addmin(client, args)
{
	args=0;
	InitialiseCl(client);
	new Handle:menu = CreateMenu(Menu_Handler);
	SetMenuTitle(menu, "-=- In-Game Admin Manager -=-");
	AddMenuItem(menu, "-", "-----", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "1", "View in-game players");
	AddMenuItem(menu, "2", "Add/Modify Player with SteamID");
	AddMenuItem(menu, "3", "View file admin.cfg");
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Menu_Handler(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info, "1"))
		{
			InGamePlayersMenu(client);
		}
		if(StrEqual(info, "2"))
		{
			SteamIDTool(client);
		}
		if(StrEqual(info, "3"))
		{
			AdminFileMenu(client);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public Action:InGamePlayersMenu(client)
{
	new Handle:menu = CreateMenu(Menu_Handler2);
	SetMenuTitle(menu, "List of all Online Players");
	for(new i = 1; i<= MaxClients; i++)
	{
		if(IsValidClient(i))
		{
			char strName[64], strUID[64];
			GetClientName(i, strName, 64);
			IntToString(GetClientUserId(i), strUID, 64)				
			AddMenuItem(menu, strUID, strName);
		}
	}
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Menu_Handler2(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		int target = GetClientOfUserId(StringToInt(info));
		if(IsValidClient(target))
		{
			GetClientAuthId(target, AuthId_Steam2, TargetGivenSteamID[client], 64);
			GetClientName(target, TargetName[client], 64);
			
			CGB[client] = 1;
			SearchInCfg(client);
		}
	}
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
		{
			Cmd_Addmin(client, 0);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}



public Action:SearchInCfg(client)
{
	BuildPath(Path_SM, KvPath, sizeof(KvPath), "configs/admins.cfg");
	new Handle:DB = CreateKeyValues("Admins");
	FileToKeyValues(DB, KvPath);
	
	char FileSteamID[64], MenuTitle[64], MenuItem[64];
	bool Found;
	
	Format(MenuTitle, 64, "Info about this player");
	
	new Handle:menu = CreateMenu(Menu_Handler3);
	SetMenuTitle(menu, MenuTitle);
	
	if(KvGotoFirstSubKey(DB))
	{
		KvGetString(DB, "identity", FileSteamID, 64);
		if(StrEqual(TargetGivenSteamID[client], FileSteamID))
		{
			KvGetString(DB, "flags", TargetFlagsRegistred[client], 64);
			KvGetSectionSymbol(DB, TargetSymbol[client]);
			Found = true;
		}
		while(KvGotoNextKey(DB) && !Found)
		{
			KvGetString(DB, "identity", FileSteamID, 64);
			if(StrEqual(TargetGivenSteamID[client], FileSteamID))
			{
				KvGetString(DB, "flags", TargetFlagsRegistred[client], 64);
				KvGetSectionSymbol(DB, TargetSymbol[client]);
				Found = true;
			}
		}
	}
	if(Found)
	{
		Found = false;
		if(CGB[client] != 3)
		{
			PrintToChat(client, "\x04[Addmin]\x03This player is in admin list");
		}
		TargetHasFlags[client] = true;
		
		Format(MenuItem, 64, "His flags are: %s", TargetFlagsRegistred[client]);
		AddMenuItem(menu, "-", MenuItem, ITEMDRAW_DISABLED);
		
		Format(MenuItem, 64, "His SteamID: %s", TargetGivenSteamID[client]);
		AddMenuItem(menu, "-", MenuItem, ITEMDRAW_DISABLED);
		
		AddMenuItem(menu, "-", "------", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "1", "Modify his flags");
	}
	else
	{
		PrintToChat(client, "\x04[Addmin]\x03This player is not in admin list");
		
		Format(MenuItem, 64, "His flags are: Ø");
		AddMenuItem(menu, "-", MenuItem, ITEMDRAW_DISABLED);
		
		Format(MenuItem, 64, "His SteamID: %s", TargetGivenSteamID[client]);
		AddMenuItem(menu, "-", MenuItem, ITEMDRAW_DISABLED);
		
		AddMenuItem(menu, "-", "------", ITEMDRAW_DISABLED);
		AddMenuItem(menu, "1", "Modify his flags");
	}
	SetMenuExitBackButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	CloseHandle(DB);
}


public Menu_Handler3(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info, "1"))
		{
			ChooseFlagMenu(client);
		}
	}
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
		{
			if(CGB[client] == 1)
			{
				InGamePlayersMenu(client);
			}
			if(CGB[client] == 3)
			{
				CloseHandle(menu);
			}
			if(CGB[client] == 3)
			{
				AdminFileMenu(client);
			}
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:ChooseFlagMenu(client)
{
	new Handle:menu = CreateMenu(Menu_Handler4);
	char MenuTitle[64];
	if(!StrEqual(TargetName[client], ""))
	{
		Format(MenuTitle, 64, "Flags of %s", TargetName[client]);
	}
	else
	{
		Format(MenuTitle, 64, "Flags of your target");
	}
	SetMenuTitle(menu, MenuTitle);
	
	char TheFlag[64];
	Format(TheFlag, 64, "[%s]Flag a: Reserved slots", (CheckFlags(client, "a") ? "x" : ""));
	AddMenuItem(menu, "a", TheFlag);
	Format(TheFlag, 64, "[%s]Flag b: Generic admin, required for admins", (CheckFlags(client, "b") ? "x" : ""));
	AddMenuItem(menu, "b", TheFlag);
	Format(TheFlag, 64, "[%s]Flag c: Kick other players", (CheckFlags(client, "c") ? "x" : ""));
	AddMenuItem(menu, "c", TheFlag);
	Format(TheFlag, 64, "[%s]Flag d: Banning other players", (CheckFlags(client, "d") ? "x" : ""));
	AddMenuItem(menu, "d", TheFlag);
	Format(TheFlag, 64, "[%s]Flag e: Removing bans", (CheckFlags(client, "e") ? "x" : ""));
	AddMenuItem(menu, "e", TheFlag);
	Format(TheFlag, 64, "[%s]Flag f: Slaying other players", (CheckFlags(client, "f") ? "x" : ""));
	AddMenuItem(menu, "f", TheFlag);
	Format(TheFlag, 64, "[%s]Flag g: Changing the map", (CheckFlags(client, "g") ? "x" : ""));
	AddMenuItem(menu, "g", TheFlag);
	Format(TheFlag, 64, "[%s]Flag h: Changing cvars", (CheckFlags(client, "h") ? "x" : ""));
	AddMenuItem(menu, "h", TheFlag);
	Format(TheFlag, 64, "[%s]Flag i: Changing configs", (CheckFlags(client, "i") ? "x" : ""));
	AddMenuItem(menu, "i", TheFlag);
	Format(TheFlag, 64, "[%s]Flag j: Special chat privileges", (CheckFlags(client, "j") ? "x" : ""));
	AddMenuItem(menu, "j", TheFlag);
	Format(TheFlag, 64, "[%s]Flag k: Voting", (CheckFlags(client, "k") ? "x" : ""));
	AddMenuItem(menu, "k", TheFlag);
	Format(TheFlag, 64, "[%s]Flag l: Password the server", (CheckFlags(client, "l") ? "x" : ""));
	AddMenuItem(menu, "l", TheFlag);
	Format(TheFlag, 64, "[%s]Flag m: Remote console", (CheckFlags(client, "m") ? "x" : ""));
	AddMenuItem(menu, "m", TheFlag);
	Format(TheFlag, 64, "[%s]Flag n: Change sv_cheats and related commands", (CheckFlags(client, "n") ? "x" : ""));
	AddMenuItem(menu, "n", TheFlag);
	Format(TheFlag, 64, "[%s]Flag o: custom1", (CheckFlags(client, "o") ? "x" : ""));
	AddMenuItem(menu, "o", TheFlag);
	Format(TheFlag, 64, "[%s]Flag p: custom2", (CheckFlags(client, "p") ? "x" : ""));
	AddMenuItem(menu, "p", TheFlag);
	Format(TheFlag, 64, "[%s]Flag q: custom3", (CheckFlags(client, "q") ? "x" : ""));
	AddMenuItem(menu, "q", TheFlag);
	Format(TheFlag, 64, "[%s]Flag r: custom4", (CheckFlags(client, "r") ? "x" : ""));
	AddMenuItem(menu, "r", TheFlag);
	Format(TheFlag, 64, "[%s]Flag s: custom5", (CheckFlags(client, "s") ? "x" : ""));
	AddMenuItem(menu, "s", TheFlag);
	Format(TheFlag, 64, "[%s]Flag t: custom6", (CheckFlags(client, "t") ? "x" : ""));
	AddMenuItem(menu, "t", TheFlag);
	Format(TheFlag, 64, "[%s]Flag z: root", (CheckFlags(client, "z") ? "x" : ""));
	AddMenuItem(menu, "z", TheFlag);
	
	AddMenuItem(menu, "1", "Save these flags");
	
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


bool CheckFlags(client, char[] flag)
{	
	if(StrContains(TargetFlagsRegistred[client], flag, false) != -1)
	{
		return true;
	}
	return false;
}


public Menu_Handler4(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(!StrEqual(info, "1"))
		{
			if(StrContains(TargetFlagsRegistred[client], info, false) != -1)
			{
				ReplaceString(TargetFlagsRegistred[client], 64, info, "", false);
			}
			else
			{
				Format(TargetFlagsRegistred[client], 64, "%s%s", TargetFlagsRegistred[client], info);
			}
			ChooseFlagMenu(client);
		}
		else
		{
			if(TargetHasFlags[client])
			{
				StartReWrite(client);
			}
			else
			{
				if(!StrEqual(TargetName[client], "", false))
				{
					StartWrite(client);
				}
				else
				{
					PreStartWrite(client);
				}
			}
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:SteamIDTool(client)
{
	PrintToChat(client, "\x04[Addmin]\x03Now type the SteamID of the player in the chat (STEAM_0:1234....)");
	ClientCanSayID[client] = true;
}

public Action:Command_Say(client, const String:command[], argc)
{
	char sArgs[64];
	GetCmdArgString(sArgs, 64);
	
	if(ClientCanSayID[client])
	{
		if(StrContains(sArgs, "STEAM_", false) != -1)
		{
			ClientCanSayID[client] = false;
			ReplaceString(sArgs, 64, " ", "", false);
			ReplaceString(sArgs, 64, "\"", "", false);
			Format(TargetGivenSteamID[client], 64, "%s", sArgs);
			CGB[client] = 2;
			SearchInCfg(client);
			return Plugin_Handled;
		}
		else
		{
			if(StrContains(sArgs, "cancel", false) != -1)
			{
				ReplaceString(sArgs, 64, "\"", "", false);
				PrintToChat(client, "\x04[Addmin]\x03Canceled");
				InitialiseCl(client);
				return Plugin_Handled;
			}
			else
			{
				PrintToChat(client, "\x04[Addmin]\x03Fail, try again (type cancel or !cancel to stop)");
				return Plugin_Handled;
			}
		}	
	}
	if(ClientCanSayName[client])
	{
		if(StrContains(sArgs, "cancel", false) != -1)
		{
			PrintToChat(client, "\x04[Addmin]\x03Canceled");
			InitialiseCl(client);
			return Plugin_Handled;
		}
		else
		{
			ClientCanSayName[client] = false;
			ReplaceString(sArgs, 64, "\"", "", false);
			Format(TargetName[client], 64, "%s", sArgs);
			StartWrite(client);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:PreStartWrite(client)
{
	PrintToChat(client, "\x04[Addmin]\x03Now type the name of the player in the chat!");
	ClientCanSayName[client] = true;
}	

public Action:StartWrite(client)
{
	BuildPath(Path_SM, KvPath, sizeof(KvPath), "configs/admins.cfg");
	new Handle:DB = CreateKeyValues("Admins");
	FileToKeyValues(DB, KvPath);
	
	if(KvJumpToKey(DB, TargetName[client], true))
	{
		KvSetString(DB, "auth", "steam");
		KvSetString(DB, "identity", TargetGivenSteamID[client]);
		KvSetString(DB, "flags", TargetFlagsRegistred[client]);
		KvRewind(DB);
		KeyValuesToFile(DB, KvPath);
		PrintToChat(client, "\x04[Addmin]\x03Admin succesfully created with flags: \"%s\"!", TargetFlagsRegistred[client]);
	}
	InitialiseCl(client);
	if(iSQL == 1)
	{
		DumpAdminCache(AdminCache_Admins, true);
	}
	CloseHandle(DB);
}



public Action:StartReWrite(client)
{	
	BuildPath(Path_SM, KvPath, sizeof(KvPath), "configs/admins.cfg");
	new Handle:DB = CreateKeyValues("Admins");
	FileToKeyValues(DB, KvPath);
	
	if(KvJumpToKeySymbol(DB, TargetSymbol[client]))
	{
		KvSetString(DB, "flags", TargetFlagsRegistred[client]);
		PrintToChat(client, "\x04[Addmin]\x03Player flags succesfully changed to \"%s\"!", TargetFlagsRegistred[client]);
		KvRewind(DB);
		KeyValuesToFile(DB, KvPath);
	}
	InitialiseCl(client);
	if(iSQL == 1)
	{
		DumpAdminCache(AdminCache_Admins, true);
	}
	CloseHandle(DB);
}

public Action:AdminFileMenu(client)
{
	BuildPath(Path_SM, KvPath, sizeof(KvPath), "configs/admins.cfg");
	new Handle:DB = CreateKeyValues("Admins");
	FileToKeyValues(DB, KvPath);
	
	char FName[64], FileSteamID[64], FileFlags[64];
	new Handle:menu = CreateMenu(Menu_Handler6);
	SetMenuTitle(menu, "List of all admins of the server");
	
	if(KvGotoFirstSubKey(DB))
	{
		KvGetSectionName(DB, FName, 64);
		KvGetString(DB, "identity", FileSteamID, 64);
		KvGetString(DB, "flags", FileFlags, 64);
		AddMenuItem(menu, FileSteamID, FName);
		while(KvGotoNextKey(DB))
		{
			KvGetSectionName(DB, FName, 64);
			KvGetString(DB, "identity", FileSteamID, 64);
			KvGetString(DB, "flags", FileFlags, 64);
			AddMenuItem(menu, FileSteamID, FName);
		}
	}
	CloseHandle(DB);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}


public Menu_Handler6(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		Format(TargetGivenSteamID[client], 64, "%s", info);
		CGB[client] = 3;
		SearchInCfg(client);
	}
	if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
		{
			Cmd_Addmin(client, 0);
		}
	}
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock bool:IsValidClient(client)
{ 
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || IsFakeClient(client) || !IsClientInGame(client))
	{
		return false; 
	}
	return true; 
}