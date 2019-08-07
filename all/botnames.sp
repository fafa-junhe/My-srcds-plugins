#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma unused cvarVersion

#define PLUGIN_VERSION "1.0"
#define PLUGIN_DESCRIPTION "Gives automatic names to bots on creation."
#define BOT_NAME_FILE "configs/botnames.txt"

// this array will store the names loaded
new Handle:bot_names;

// this array will have a list of indexes to
// bot_names, use these in order
new Handle:name_redirects;

// this is the next index to use into name_redirects
// update this each time you use a name
new next_index;

// various convars
new Handle:cvarVersion; // version cvar!
new Handle:cvarEnabled; // are we enabled?
new Handle:cvarPrefix; // bot name prefix
new Handle:cvarRandom; // use random-order names?
new Handle:cvarAnnounce; // announce new bots?
new Handle:cvarSuppress; // supress join/team/namechange messages?

public Plugin:myinfo =
{
	name = "Bot Names",
	author = "Rakeri",
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = ""
}

// a function to generate name_redirects
GenerateRedirects()
{
	new loaded_names = GetArraySize(bot_names);

	if (name_redirects != INVALID_HANDLE)
	{
		ResizeArray(name_redirects, loaded_names);
	} else {
		name_redirects = CreateArray(1, loaded_names);
	}

	for (new i = 0; i < loaded_names; i++)
	{
		SetArrayCell(name_redirects, i, i);
		
		// nothing to do random-wise if i == 0
		if (i == 0)
		{
			continue;
		}

		// now to introduce some chaos
		if (GetConVarBool(cvarRandom))
		{
			SwapArrayItems(name_redirects, GetRandomInt(0, i - 1), i);
		}
	}
}

// a function to load data into bot_names
ReloadNames()
{
	next_index = 0;
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), BOT_NAME_FILE);
	
	if (bot_names != INVALID_HANDLE)
	{
		ClearArray(bot_names);
	} else {
		bot_names = CreateArray(MAX_NAME_LENGTH);
	}
	
	new Handle:file = OpenFile(path, "r");
	if (file == INVALID_HANDLE)
	{
		//PrintToServer("bot name file unopened");
		return;
	}
	
	// this LENGTH*3 is sort of a hack
	// don't make long lines, people!
	decl String:newname[MAX_NAME_LENGTH*3];
	decl String:formedname[MAX_NAME_LENGTH];
	decl String:prefix[MAX_NAME_LENGTH];

	GetConVarString(cvarPrefix, prefix, MAX_NAME_LENGTH);

	while (IsEndOfFile(file) == false)
	{
		if (ReadFileLine(file, newname, sizeof(newname)) == false)
		{
			break;
		}
		
		// trim off comments starting with // or #
		new commentstart;
		commentstart = StrContains(newname, "//");
		if (commentstart != -1)
		{
			newname[commentstart] = 0;
		}
		commentstart = StrContains(newname, "#");
		if (commentstart != -1)
		{
			newname[commentstart] = 0;
		}
		
		new length = strlen(newname);
		if (length < 2)
		{
			// we loaded a bum name
			// (that is, blank line or 1 char == bad)
			//PrintToServer("bum name");
			continue;
		}

		// get rid of pesky whitespace
		TrimString(newname);
		
		Format(formedname, MAX_NAME_LENGTH, "%s%s", prefix, newname);
		PushArrayString(bot_names, formedname);
	}
	
	CloseHandle(file);
}

// called when the plugin loads
public OnPluginStart()
{
	// cvars!
	cvarVersion = CreateConVar("sm_botnames_version", PLUGIN_VERSION, PLUGIN_DESCRIPTION, FCVAR_NOTIFY | FCVAR_PLUGIN | FCVAR_DONTRECORD);
	cvarEnabled = CreateConVar("sm_botnames_enabled", "1", "sets whether bot naming is enabled", FCVAR_NOTIFY | FCVAR_PLUGIN);
	cvarPrefix = CreateConVar("sm_botnames_prefix", "", "sets a prefix for bot names (include a trailing space, if needed!)", FCVAR_NOTIFY | FCVAR_PLUGIN);
	cvarRandom = CreateConVar("sm_botnames_random", "1", "sets whether to randomize names used", FCVAR_NOTIFY | FCVAR_PLUGIN);
	cvarAnnounce = CreateConVar("sm_botnames_announce", "1", "sets whether to announce bots when added", FCVAR_NOTIFY | FCVAR_PLUGIN);
	cvarSuppress = CreateConVar("sm_botnames_suppress", "1", "sets whether to supress join/team change/name change bot messages", FCVAR_NOTIFY | FCVAR_PLUGIN);
	
	// hook team change, connect to supress messages
	HookEvent("player_connect", Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);

	// trickier... name changes are user messages, so...
	HookUserMessage(GetUserMessageId("SayText2"), UserMessage_SayText2, true);

	// register our commands
	RegServerCmd("sm_botnames_reload", Command_Reload);

	AutoExecConfig();
}

public OnMapStart()
{
	ReloadNames();
	GenerateRedirects();
}

// reload bot name, via console
public Action:Command_Reload(args)
{
	ReloadNames();
	GenerateRedirects();
	PrintToServer("[botnames] Loaded %i names.", GetArraySize(bot_names));
}

// handle client connection, to change the names...
public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	if (!GetConVarBool(cvarEnabled))
	{
		return true;
	}

	new loaded_names = GetArraySize(bot_names);

	if (IsFakeClient(client) && loaded_names != 0)
	{
		// we got a bot, here, boss
		
		decl String:newname[MAX_NAME_LENGTH];
		GetArrayString(bot_names, GetArrayCell(name_redirects, next_index), newname, MAX_NAME_LENGTH);

		next_index++;
		if (next_index > loaded_names - 1)
		{
			next_index = 0;
		}
		
		SetClientInfo(client, "name", newname);
		if (GetConVarBool(cvarAnnounce))
		{
			PrintToChatAll("[botnames] Bot %s created.", newname);
			PrintToServer("[botnames] Bot %s created.", newname);
		}
	}
	return true;
}

// handle "SayText2" usermessages, including name change notifies!
public Action:UserMessage_SayText2(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	if (!(GetConVarBool(cvarEnabled) && GetConVarBool(cvarSuppress)))
	{
		return Plugin_Continue;
	}

	decl String:message[256];

	BfReadShort(bf); // team color

	BfReadString(bf, message, sizeof(message));
	// check for Name_Change, not #TF_Name_Change (compatibility?)
	if (StrContains(message, "Name_Change") != -1)
	{
		BfReadString(bf, message, sizeof(message)); // original
		BfReadString(bf, message, sizeof(message)); // new
		if (FindStringInArray(bot_names, message) != -1)
		{
			// 'tis a bot!
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

// handle player team change, to supress bot messages
public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!(GetConVarBool(cvarEnabled) && GetConVarBool(cvarSuppress)))
	{
		return Plugin_Continue;
	}

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client == 0)
	{
		// weird error, ignore
		return Plugin_Continue;
	}
	if (IsFakeClient(client))
	{
		// fake client == bot
		SetEventBool(event, "silent", true);
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

// handle player connect, to supress bot messages
public Action:Event_PlayerConnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!(GetConVarBool(cvarEnabled) && GetConVarBool(cvarSuppress)))
	{
		return Plugin_Continue;
	}

	decl String:networkID[32];
	GetEventString(event, "networkid", networkID, sizeof(networkID));

	if(!dontBroadcast && StrEqual(networkID, "BOT"))
	{
		// we got a bot connectin', resend event as no-broadcast
		decl String:clientName[MAX_NAME_LENGTH], String:address[32];
		GetEventString(event, "name", clientName, sizeof(clientName));
		GetEventString(event, "address", address, sizeof(address));

		new Handle:newEvent = CreateEvent("player_connect", true);
		SetEventString(newEvent, "name", clientName);
		SetEventInt(newEvent, "index", GetEventInt(event, "index"));
		SetEventInt(newEvent, "userid", GetEventInt(event, "userid"));
		SetEventString(newEvent, "networkid", networkID);
		SetEventString(newEvent, "address", address);

		FireEvent(newEvent, true);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}
