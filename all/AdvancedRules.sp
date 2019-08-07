#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <clientprefs>

#undef REQUIRE_PLUGIN
#tryinclude <updater>
#define REQUIRE_PLUGIN

#define MENU_ACTION_OFFSET -3

#define KV_ROOT_NAME "server_rules"
#define MENU_ITEM_BACK 7
#define MENU_ITEM_DELETE_RULE 6

#define MENU_SELECT_SOUND	"buttons/button14.wav"
#define MENU_EXIT_SOUND	"buttons/combine_button7.wav"

#define UPDATE_URL    "https://raw.githubusercontent.com/eyal282/AlliedmodsUpdater/master/AdvancedRules/updatefile.txt"

new const String:PLUGIN_VERSION[] = "2.1";

new bool:DisplayRules[MAXPLAYERS+1];

new String:ClientRuleName[MAXPLAYERS+1][64], String:ClientRuleDesc[MAXPLAYERS+1][1024], String:LastRulesItem[MAXPLAYERS+1];

new ClientConfirmDeleteRuleItem[MAXPLAYERS+1], ClientConfirmDeleteRuleUnixTime[MAXPLAYERS+1];

new Handle:Array_Rules = INVALID_HANDLE;

new Handle:hCookie_LastAccept = INVALID_HANDLE;

new RulesLastEdit = 0; // This is the latest updated rule out of all.
new LastConfigsExecuted = 0; // This is to protect from double deleting resulting in the wrong rule being deleted.

new String:RulesPath[1024];

enum enRules
{
	String:enRuleName[64],
	String:enRuleDesc[1024],
	enRuleLastEdit,
}

new Handle:hcv_ForceShowRules = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "Advanced Rules Menu",
	author = "Eyal282",
	description = "A highly efficient rules menu that prioritizes maximum convenience.",
	version = PLUGIN_VERSION,
	url = ""
}

native bool:AdvancedRules_ShouldClientReadRules(client);

/**
* @param client 			client index to test if he has some rules to read.
* @return					true if client did not read and accept all rules, false if he did.

*/

native AdvancedRules_ShowRulesToClient(client, item=0);

/**
* @param client 			client index to test if he has some rules to read.
* @param item 				item from which the rules menu will be displayed from.

* @return					true on success, false on failure and will throw an error.

*/

public APLRes:AskPluginLoad2(Handle:myself, bool:bLate, String:error[], errorLen)
{
	CreateNative("AdvancedRules_ShouldClientReadRules", Native_ShouldClientReadRules);
	CreateNative("AdvancedRules_ShowRulesToClient", Native_ShowRulesToClient);
}

public Native_ShouldClientReadRules(Handle:plugin, params)
{
	new client = GetNativeCell(1);
	
	if(!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Invalid client index or client not in-game");
		
		return false;
	}
	else if(!AreClientCookiesCached(client))
		return false;
	
	return RulesLastEdit > GetClientLastAcceptRules(client);
}

public Native_ShowRulesToClient(Handle:plugin, params)
{
	new client = GetNativeCell(1);
	
	if(!IsClientInGame(client))
	{
		ThrowNativeError(SP_ERROR_ABORTED, "Invalid client index or client not in-game");
		
		return false;
	}
	
	new item = GetNativeCell(2);
	ShowRulesMenu(client, item);
	
	return true;
}

public OnPluginStart()
{
	BuildPath(Path_SM, RulesPath, sizeof(RulesPath), "configs/Rules.cfg");
	
	Array_Rules = CreateArray(enRules);
	
	RegConsoleCmd("sm_rules", Command_Rules, "Display the server rules");
	RegAdminCmd("sm_statusrules", Command_StatusRules, ADMFLAG_GENERIC, "Display the list of players and their last date of accepting the rules.");
	RegAdminCmd("sm_showrules", Command_StatusRules, ADMFLAG_GENERIC, "Display the list of players and their last date of accepting the rules.");
	RegAdminCmd("sm_managerules", Command_ManageRules, ADMFLAG_ROOT, "Manage the server rules");
	
	RegAdminCmd("sm_addrule_name", Command_AddRule_Name, ADMFLAG_ROOT, "Name of new rule to add");
	RegAdminCmd("sm_addrule_desc", Command_AddRule_Desc, ADMFLAG_ROOT, "Description of new rule to add");
	
	CreateConVar("advanced_rules_version", PLUGIN_VERSION, "", FCVAR_NOTIFY);
	hcv_ForceShowRules = CreateConVar("advanced_rules_force_show", "-1", "If a player didn't accept the rules or if they were updated, show rules menu in x seconds after connect, -1 to disable.");
	hCookie_LastAccept = RegClientCookie("AdvancedRules_LastAcceptRules", "The last time you have accepted the rules, unix timestamp.", CookieAccess_Public);
	
	OnMapStart();
	
	#if defined _updater_included
	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
	
}

public OnClientConnected(client)
{
	DisplayRules[client] = false;
}
public OnClientPostAdminCheck(client)
{
	if(!AreClientCookiesCached(client))
		DisplayRules[client] = true;
		
	else
	{
		if(RulesLastEdit > GetClientLastAcceptRules(client))
		{
			if(GetConVarFloat(hcv_ForceShowRules) > 0)
				CreateTimer(GetConVarFloat(hcv_ForceShowRules), Timer_DisplayRulesToClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				
			
			// After 3 seconds if it's set to -1 tell him about viewing the rules.
			CreateTimer(GetConVarFloat(hcv_ForceShowRules) + 4.0, Timer_DisplayInfoToClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action:Timer_DisplayRulesToClient(Handle:hTimer, UserId)
{
	new client = GetClientOfUserId(UserId);
	
	if(client == 0)
		return Plugin_Continue;
		
	ShowRulesMenu(client);
	
	PrintToChat(client, "\x01 Please take some take and view the server's rules.");
	PrintToChat(client, "\x01 Should you fail to do so, be aware of the consequences in case you break a rule by mistake.");
	
	return Plugin_Continue;
}

public Action:Timer_DisplayInfoToClient(Handle:hTimer, UserId)
{
	new client = GetClientOfUserId(UserId);
	
	if(client == 0)
		return Plugin_Continue;
		
	PrintToChat(client, "\x01 You need to view the rules and accept them.");
	
	return Plugin_Continue;
}

public OnClientCookiesCached(client)
{
	if(DisplayRules[client]) // Post Admin check and cookies weren't cached yet.
	{
		if(RulesLastEdit > GetClientLastAcceptRules(client) && GetConVarFloat(hcv_ForceShowRules) > 0)
			CreateTimer(GetConVarFloat(hcv_ForceShowRules), Timer_DisplayRulesToClient, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		
		DisplayRules[client] = false;
	}
}

public OnClientDisconnect(client)
{
	DisplayRules[client] = false;
}

#if defined _updater_included
public Updater_OnPluginUpdated()
{
	ReloadPlugin(INVALID_HANDLE);
}
#endif
public OnLibraryAdded(const String:name[])
{
	#if defined _updater_included
	if (StrEqual(name, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
	#endif
}

public OnMapStart()
{
	PrecacheSound(MENU_SELECT_SOUND);
	PrecacheSound(MENU_EXIT_SOUND);
}

public OnConfigsExecuted()
{
	LoadConfigFile();
}

public LoadConfigFile()
{
	ClearArray(Array_Rules);
	new Handle:keyValues = CreateKeyValues(KV_ROOT_NAME);
	
	if(!FileToKeyValues(keyValues, RulesPath))
	{
		CreateEmptyKvFile(RulesPath);
		return false;
	}	

	if(!KvGotoFirstSubKey(keyValues))
		return false;
	
	new RuleArray[enRules];
	
	new UnixTime = GetTime();
	
	new SectionIndex = 1, String:SectionName[11];
	do
	{
		IntToString(SectionIndex, SectionName, sizeof(SectionName));
		KvSetSectionName(keyValues, SectionName);
		KvGetString(keyValues, "name", RuleArray[enRuleName], enRules);
		KvGetString(keyValues, "description", RuleArray[enRuleDesc], enRules);
		
		ReplaceString(RuleArray[enRuleName], enRules, "//q", "\"");
		ReplaceString(RuleArray[enRuleDesc], enRules, "//q", "\"");
		
		RuleArray[enRuleLastEdit] = KvGetNum(keyValues, "last_edit", UnixTime);
		
		KvSetNum(keyValues, "last_edit", RuleArray[enRuleLastEdit]); // This is to update rules without a timestamp with the current one.
		
		if(RulesLastEdit < RuleArray[enRuleLastEdit])
			RulesLastEdit = RuleArray[enRuleLastEdit];
			
		PushArrayArray(Array_Rules, RuleArray, enRules);
		
		SectionIndex++;
	}
	while(KvGotoNextKey(keyValues));
	
	KvRewind(keyValues);
	KeyValuesToFile(keyValues, RulesPath);
	
	CloseHandle(keyValues);
	
	LastConfigsExecuted = GetTime();
	
	return true;
}

public Action:Command_Rules(client, args)
{
	ShowRulesMenu(client);
	
	return Plugin_Handled;
}

ShowRulesMenu(client, item=0)
{
	new Handle:hMenu = CreateMenu(MenuHandler_Rules);
	
	new RuleArray[enRules];
	
	new ArraySize = GetArraySize(Array_Rules);
	new String:TempFormat[65];
	
	new LastAcceptRules = GetClientLastAcceptRules(client);
	
	for(new i=0;i < ArraySize;i++)
	{
		GetArrayArray(Array_Rules, i, RuleArray, enRules);
		
		Format(TempFormat, sizeof(TempFormat), "%s%s", RuleArray[enRuleName], LastAcceptRules < RuleArray[enRuleLastEdit] ? "*" : "");
		AddMenuItem(hMenu, "", TempFormat);
	}
	
	AddMenuItem(hMenu, "accept", "ACCEPT THE RULES");
	
	SetMenuTitle(hMenu, "Choose a rule for info:\n Rules with * are newer than the last time you accepted them\n At the end of the menu you can accept the rules or accept possible punishments.");
	
	DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);
}


public MenuHandler_Rules(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{
		new String:Info[8];
		GetMenuItem(hMenu, item, Info, sizeof(Info));
		
		if(StrEqual(Info, "accept"))	
		{
			SetClientLastAcceptRules(client, GetTime());
			PrintToChat(client, "You have successfully accepted the rules. Should they be updated, you will know.");
		}
		else
		{
			LastRulesItem[client] = GetMenuSelectionPosition();
			ShowClientRule(client, item);
		}
	}
}

ShowClientRule(client, item)
{
	new Handle:hPanel = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
	
	new RuleArray[enRules];
	GetArrayArray(Array_Rules, item, RuleArray, enRules);
	
	new String:RuleDescLines[11][1024];
	
	new lines = ExplodeString(RuleArray[enRuleDesc], "/n", RuleDescLines, sizeof(RuleDescLines), sizeof(RuleDescLines[]));
	
	for(new i=0;i < lines;i++)
		DrawPanelText(hPanel, RuleDescLines[i]);
	
	SetPanelCurrentKey(hPanel, 7);
	DrawPanelItem(hPanel, "Back");
	
	SetPanelCurrentKey(hPanel, 9)
	DrawPanelItem(hPanel, "Exit");
	
	SetPanelKeys(hPanel, (1<<6)|(1<<8));
	
	new String:PanelTitle[66];
	Format(PanelTitle, sizeof(PanelTitle), "%s%s\n", RuleArray[enRuleName], GetClientLastAcceptRules(client) < RuleArray[enRuleLastEdit] ? "*" : "");
	SetPanelTitle(hPanel, PanelTitle, false);
	
	SendPanelToClient(hPanel, client, PanelHandler_ShowRule, MENU_TIME_FOREVER);
	
	CloseHandle(hPanel);
}

public PanelHandler_ShowRule(Handle:hPanel, MenuAction:action, client, item)
{		
	if(action == MenuAction_Select)
	{
		if(item == MENU_ITEM_BACK)
		{
			ShowRulesMenu(client, LastRulesItem[client]);
			EmitSoundToClient(client, MENU_SELECT_SOUND); // Fauken panels...
		}
		else
			EmitSoundToClient(client, MENU_EXIT_SOUND); // Fauken panels...
	}
}


public Action:Command_StatusRules(client, args)
{
	ShowStatusRules(client, 0);
	
	return Plugin_Handled;
}

ShowStatusRules(client, item)
{
	new Handle:hMenu = CreateMenu(MenuHandler_StatusRules);
	
	new String:TempFormat[128];
	
	new String:sUserId[11], String:Time[32];
	
	for(new i=1;i <= MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		else if(IsFakeClient(i))
			continue;
			
		
		IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
		
		new LastAcceptRules = GetClientLastAcceptRules(i);
		if(LastAcceptRules <= 0)
			Format(Time, sizeof(Time), "Never");
		
		else	
			FormatTime(Time, sizeof(Time), "%Y-%m-%d", LastAcceptRules);
			
		Format(TempFormat, sizeof(TempFormat), "%N [%s] [%s]", i, Time, LastAcceptRules < RulesLastEdit ? "Yes" : "No");
		AddMenuItem(hMenu, sUserId, TempFormat);
	}
	
	SetMenuTitle(hMenu, "Choose a player to force him to view the rules:\nName [Last Accepted Rules] [Did Rules Change Since Last Accept?]");
	
	DisplayMenuAtItem(hMenu, client, item, MENU_TIME_FOREVER);
}

public MenuHandler_StatusRules(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{
		new String:sUserId[11];
		GetMenuItem(hMenu, item, sUserId, sizeof(sUserId));
		
		new target = GetClientOfUserId(StringToInt(sUserId));
		
		if(target == 0)
		{
			PrintToChat(client, "Target client is no longer connected.");
			return;
		}
		
		Command_Rules(target, 0);
		PrintToChat(target, " \x01Admin \x03%N\x01 has forced you to read the rules.", client);
		
		ShowStatusRules(client, GetMenuSelectionPosition());
	}
}

public Action:Command_ManageRules(client, args)
{
	new Handle:hMenu = CreateMenu(MenuHandler_ManageRules);
	
	AddMenuItem(hMenu, "", "Add a rule");
	AddMenuItem(hMenu, "", "Delete a rule");
	AddMenuItem(hMenu, "", "Rearrange a rule");
	//AddMenuItem(hMenu, "", "Rearrange all rules");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}



public MenuHandler_ManageRules(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{
		switch(item)
		{
			case 0:
			{
				if(ClientRuleName[client][0] == EOS)
					PrintToChat(client, "Use \"sm_addrule_name <rule name>\" to set the new rule's name.");
					
				else if(ClientRuleDesc[client][0] == EOS)
					PrintToChat(client, "Use \"sm_addrule_desc <description name>\" to set the new rule's description.");
					
				else
				{
					AddNewRule(ClientRuleName[client], ClientRuleDesc[client]);
					
					ClientRuleName[client][0] = EOS;
					ClientRuleDesc[client][0] = EOS;
					
					PrintToChat(client, "Rule was successfully added.");
				}	
				
				Command_ManageRules(client, 0);
			}
			case 1:
			{
				Command_DeleteRules(client, 0);
			}
			case 2:
			{
				Command_MoveRule(client, 0);
			}
		}
	}
}

public Action:Command_AddRule_Name(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[SM] Usage: sm_addrule_name <rule name>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(ClientRuleName[client], sizeof(ClientRuleName[]));
	
	ReplaceString(ClientRuleName[client], sizeof(ClientRuleName[]), "\"", "//q");
	ReplaceString(ClientRuleDesc[client], sizeof(ClientRuleDesc[]), "\\", "");
	
	PrintToChat(client, "Successfully set the ongoing created rule's name to %s", ClientRuleName[client]);
	
	Command_ManageRules(client, 0);
	
	return Plugin_Handled;
}

public Action:Command_AddRule_Desc(client, args)
{
	if(args == 0)
	{
		ReplyToCommand(client, "[SM] Usage: sm_addrule_desc <rule description>");
		return Plugin_Handled;
	}
	
	GetCmdArgString(ClientRuleDesc[client], sizeof(ClientRuleDesc[]));
	
	ReplaceString(ClientRuleDesc[client], sizeof(ClientRuleDesc[]), "\"", "//q");
	ReplaceString(ClientRuleDesc[client], sizeof(ClientRuleDesc[]), "\\", "");
	
	PrintToChat(client, "Successfully set the ongoing created rule's name to %s", ClientRuleDesc[client]);
	Command_ManageRules(client, 0);
	
	return Plugin_Handled;
}

public Action:Command_DeleteRules(client, args)
{
	new Handle:hMenu = CreateMenu(MenuHandler_DeleteRules);
	
	new RuleArray[enRules];
	
	new ArraySize = GetArraySize(Array_Rules);
	
	new String:sUnixTime[11];
	IntToString(GetTime(), sUnixTime, sizeof(sUnixTime)); // Safety so if two admins edit rules the later will fail.
	for(new i=0;i < ArraySize;i++)
	{
		GetArrayArray(Array_Rules, i, RuleArray, enRules);

		AddMenuItem(hMenu, sUnixTime, RuleArray[enRuleName]);
	}
	
	SetMenuTitle(hMenu, "Choose a rule for deletion:");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public MenuHandler_DeleteRules(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{	
		new String:sUnixTime[11];
		GetMenuItem(hMenu, item, sUnixTime, sizeof(sUnixTime));
		ConfirmDeleteRule(client, item, StringToInt(sUnixTime));
	}
}

public ConfirmDeleteRule(client, item, UnixTime)
{		
	if(UnixTime < LastConfigsExecuted)
	{
		PrintToChat(client, "Couldn't delete the rule because the order of the rules has changed.");
		return;
	}
	
	ClientConfirmDeleteRuleItem[client] = item;
	ClientConfirmDeleteRuleUnixTime[client] = UnixTime;
	
	new Handle:hPanel = CreatePanel(GetMenuStyleHandle(MenuStyle_Radio));
	
	new RuleArray[enRules];
	GetArrayArray(Array_Rules, item, RuleArray, enRules);
	
	new String:RuleDescLines[11][1024];
	
	new lines = ExplodeString(RuleArray[enRuleDesc], "/n", RuleDescLines, sizeof(RuleDescLines), sizeof(RuleDescLines[]));
	
	for(new i=0;i < lines;i++)
		DrawPanelText(hPanel, RuleDescLines[i]);
	
	SetPanelCurrentKey(hPanel, 6);
	DrawPanelItem(hPanel, "DELETE");
	
	SetPanelCurrentKey(hPanel, 9); // There will not be a back button because 7 is close to 6.
	DrawPanelItem(hPanel, "Exit");
	
	SetPanelKeys(hPanel, (1<<5)|(1<<8));
	
	new String:Time[32];
	FormatTime(Time, sizeof(Time), "%d-%m-%Y", RuleArray[enRuleLastEdit]);
	new String:PanelTitle[65];
	Format(PanelTitle, sizeof(PanelTitle), "%s\nLast Edited: %s", RuleArray[enRuleName], Time);
	SetPanelTitle(hPanel, PanelTitle, false);
	
	SendPanelToClient(hPanel, client, PanelHandler_ConfirmDeleteRule, MENU_TIME_FOREVER);
	
	CloseHandle(hPanel);
}

public PanelHandler_ConfirmDeleteRule(Handle:hPanel, MenuAction:action, client, item)
{		
	if(action == MenuAction_Select)
	{
		if(item == MENU_ITEM_DELETE_RULE)
		{
			if(ClientConfirmDeleteRuleUnixTime[client] < LastConfigsExecuted)
			{
				PrintToChat(client, "Couldn't delete the rule because the order of the rules has changed.");
				return;
			}
			
			if(DeleteExistingRule(ClientConfirmDeleteRuleItem[client]+1))
				PrintToChat(client, "Successfully deleted the rule.");

			else
				PrintToChat(client, "Could not delete the rule.");
		}
	}
}		

public Action:Command_MoveRule(client, args)
{
	new ArraySize = GetArraySize(Array_Rules);
	
	if(ArraySize < 2)
	{
		PrintToChat(client, "There should be at least 2 rules to move the position of one of them.");
		return Plugin_Handled;
	}
	
	new Handle:hMenu = CreateMenu(MenuHandler_MoveRule);
	
	SetMenuTitle(hMenu, "Choose a rule to move its position:");
	
	new RuleArray[enRules];
	
	new String:sUnixTime[11];
	IntToString(GetTime(), sUnixTime, sizeof(sUnixTime)); // Safety so if two admins edit rules the later will fail.
	
	for(new i=0;i < ArraySize;i++)
	{
		GetArrayArray(Array_Rules, i, RuleArray, enRules);

		AddMenuItem(hMenu, sUnixTime, RuleArray[enRuleName]);
	}
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public MenuHandler_MoveRule(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{	
		new String:sUnixTime[11];
		GetMenuItem(hMenu, item, sUnixTime, sizeof(sUnixTime));
		
		if(StringToInt(sUnixTime) < LastConfigsExecuted)
		{
			PrintToChat(client, "Couldn't move the rule because the order of the rules has changed.");
			return;
		}
		MoveRuleReference(client, item, sUnixTime);
	}
}

public MoveRuleReference(client, item, String:sUnixTime[11])
{
	new Handle:hMenu = CreateMenu(MenuHandler_MoveRuleReference);
	
	new RuleArray[enRules];
	
	new ArraySize = GetArraySize(Array_Rules);

	new String:Info[25];
	Format(Info, sizeof(Info), "\"%s\" \"%i\"", sUnixTime, item);

	for(new i=0;i < ArraySize;i++)
	{
		if(item == i)
			continue;
			
		GetArrayArray(Array_Rules, i, RuleArray, enRules);

		AddMenuItem(hMenu, Info, RuleArray[enRuleName]);
	}
	
	SetMenuTitle(hMenu, "Choose a rule to put the selected rule before:");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}


public MenuHandler_MoveRuleReference(Handle:hMenu, MenuAction:action, client, item)
{
	if(action == MenuAction_End)
		CloseHandle(hMenu);
	
	else if(action == MenuAction_Select)
	{	
		new String:sUnixTime[11], String:sRuleIndex[11], String:Info[25];
		GetMenuItem(hMenu, item, Info, sizeof(Info));

		new len = BreakString(Info, sUnixTime, sizeof(sUnixTime));
		
		Format(sRuleIndex, sizeof(sRuleIndex), Info[len]);
		
		StripQuotes(sUnixTime);
		StripQuotes(sRuleIndex);
		
		if(StringToInt(sUnixTime) < LastConfigsExecuted)
		{
			PrintToChat(client, "Couldn't move the rule because the order of the rules has changed.");
			return;
		}
		
		new RuleItem = StringToInt(sRuleIndex);
		
		new RuleArray[2][enRules];
		
		if(item >= RuleItem)
			item++;
		
		GetArrayArray(Array_Rules, RuleItem, RuleArray[0], enRules);
		GetArrayArray(Array_Rules, item, RuleArray[1], enRules);

		if(MoveRuleToPosition(item, RuleItem))
			PrintToChat(client, "Successfully moved the rule.");

		else
			PrintToChat(client, "Could not move the rule.");
	}
}

stock bool:MoveRuleToPosition(RuleOldItem, RuleNewItem)
{
	
	if(!LoadConfigFile())
		return false;

	new RuleArray[enRules];
	if(!MoveArrayItem(Array_Rules, RuleOldItem, RuleNewItem))
		return false;
	
	new Handle:keyValues = CreateKeyValues("server_rules");
	
	new ArraySize = GetArraySize(Array_Rules);
	
	new String:sRuleIndex[11];
	
	for(new i=0;i < ArraySize;i++)
	{
		IntToString(i+1, sRuleIndex, sizeof(sRuleIndex));
		KvJumpToKey(keyValues, sRuleIndex, true);
		GetArrayArray(Array_Rules, i, RuleArray, enRules);
		
		ReplaceString(RuleArray[enRuleName], enRules, "\"", "//q");
		ReplaceString(RuleArray[enRuleDesc], enRules, "\"", "//q");
		
		KvSetString(keyValues, "name", RuleArray[enRuleName]);
		KvSetString(keyValues, "description", RuleArray[enRuleDesc]);
		KvSetNum(keyValues, "last_edit", RuleArray[enRuleLastEdit]);
		
		KvRewind(keyValues);
	}
	
	KvRewind(keyValues);
	KeyValuesToFile(keyValues, RulesPath);
	
	CloseHandle(keyValues);
	
	LoadConfigFile();
	
	return true;
}

stock AddNewRule(const String:RuleName[], const String:RuleDesc[])
{
	new Handle:keyValues = CreateKeyValues(KV_ROOT_NAME);
	
	if(!FileToKeyValues(keyValues, RulesPath))
	{
		CreateEmptyKvFile(RulesPath);
		
		if(!FileToKeyValues(keyValues, RulesPath))
			SetFailState("Something that should never happen has happened.");
	}	
	
	new String:SectionName[11];
	if(!KvGotoFirstSubKey(keyValues))
		SectionName = "1"

	else
	{	
		do
		{
			KvGetSectionName(keyValues, SectionName, sizeof(SectionName));
		}
		while(KvGotoNextKey(keyValues))
		
		new iSectionName = StringToInt(SectionName);
		
		IntToString(iSectionName + 1, SectionName, sizeof(SectionName));
		
		KvGoBack(keyValues);
	}
	KvJumpToKey(keyValues, SectionName, true);
	
	KvSetString(keyValues, "name", RuleName);
	KvSetString(keyValues, "description", RuleDesc);
	KvSetNum(keyValues, "last_edit", GetTime());
	KvRewind(keyValues);
	KeyValuesToFile(keyValues, RulesPath);
	CloseHandle(keyValues);
	
	LoadConfigFile();
}

stock bool:DeleteExistingRule(SectionIndex)
{
	new Handle:keyValues = CreateKeyValues(KV_ROOT_NAME);
	
	if(!FileToKeyValues(keyValues, RulesPath))
	{
		CloseHandle(keyValues);
		return false;
	}
	else if(!KvGotoFirstSubKey(keyValues))
	{
		CloseHandle(keyValues);
		return false;
	}
	new bool:Deleted, String:SectionName[11];
	
	do
	{
		KvGetSectionName(keyValues, SectionName, sizeof(SectionName));
		
		if(StringToInt(SectionName) == SectionIndex)
		{
			Deleted = true;
			KvDeleteThis(keyValues);
			break;
		}
	}
	while(KvGotoNextKey(keyValues))
	
	KvRewind(keyValues);
	KeyValuesToFile(keyValues, RulesPath);
	CloseHandle(keyValues);
	
	LoadConfigFile();
	
	return Deleted;
}

stock CreateEmptyKvFile(const String:Path[])
{
	new Handle:keyValues = CreateKeyValues(KV_ROOT_NAME);
	
	KvRewind(keyValues);
	KeyValuesToFile(keyValues, Path);
	
	CloseHandle(keyValues);
}

stock GetClientLastAcceptRules(client)
{
	new String:sValue[11];
	GetClientCookie(client, hCookie_LastAccept, sValue, sizeof(sValue));
	
	return StringToInt(sValue);
}

stock SetClientLastAcceptRules(client, timestamp)
{
	new String:sValue[11];
	IntToString(timestamp, sValue, sizeof(sValue));
	SetClientCookie(client, hCookie_LastAccept, sValue);
}

/**
 * Moves an item in an array before the new item.
 *
 *
 * @param Array				ADT Array Handle
 * @param OldItem			The old item to move from
 * @param NewItem			The item to before which the old item will move to.
 * @return					true on success, false if OldItem == NewItem.
 */
stock bool:MoveArrayItem(Handle:Array, OldItem, NewItem)
{
	if(NewItem == OldItem)
		return false;
	
	if(OldItem > NewItem)
	{
		for(new i=NewItem;i < OldItem-1;i++)
			SwapArrayItems(Array, i, i+1);
	}
	else
	{
		for(new i=NewItem;i > OldItem;i--)
			SwapArrayItems(Array, i, i-1);
	}
	
	return true;
}