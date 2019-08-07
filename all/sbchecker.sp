// Some snippets such as the sourcebans.cfg parsing are taken near-directly from the Sourcebans plugin

#include <sourcemod>

#define VERSION "1.0.2"
#define LISTBANS_USAGE "sm_listsbbans <#userid|name> - Lists a user's prior bans from Sourcebans"

new String:g_DatabasePrefix[10] = "sb";
new Handle:g_ConfigParser;
new Handle:g_DB;

public Plugin:myinfo = 
{
	name = "Sourcebans Checker",
	author = "psychonic & Ca$h Munny",
	description = "Notifies admins of prior bans from Sourcebans upon player connect.",
	version = VERSION,
	url = "http://www.nicholashastings.com"
};

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	CreateConVar("sbchecker_version", VERSION, "", FCVAR_NOTIFY);
	RegAdminCmd("sm_listsbbans", OnListSourceBansCmd, ADMFLAG_BAN, LISTBANS_USAGE);
	RegAdminCmd("sb_reload", OnReloadCmd, ADMFLAG_RCON, "Reload sourcebans config and ban reason menu options");
	
	SQL_TConnect(OnDatabaseConnected, "sourcebans");
}

public OnMapStart()
{
	ReadConfig();
}

public Action:OnReloadCmd(client, args)
{
	ReadConfig();
	return Plugin_Handled;
}

public OnDatabaseConnected(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		SetFailState("Failed to connect to SB db, %s", error);
	
	g_DB = hndl;
}

public OnClientAuthorized(client, const String:auth[])
{
	if (g_DB == INVALID_HANDLE)
		return;
	
	/* Do not check bots nor check player with lan steamid. */
	if(auth[0] == 'B' || auth[9] == 'L')
		return;
	
	decl String:query[512], String:ip[30];
	GetClientIP(client, ip, sizeof(ip));
	FormatEx(query, sizeof(query), "SELECT COUNT(bid) FROM %s_bans WHERE ((type = 0 AND authid REGEXP '^STEAM_[0-9]:%s$') OR (type = 1 AND ip = '%s')) AND ((length > '0' AND ends > UNIX_TIMESTAMP()) OR RemoveType IS NOT NULL)", g_DatabasePrefix, auth[8], ip);
	
	SQL_TQuery(g_DB, OnConnectBanCheck, query, GetClientUserId(client), DBPrio_Low);
}

public OnConnectBanCheck(Handle:owner, Handle:hndl, const String:error[], any:userid)
{
	new client = GetClientOfUserId(userid);
	
	if (!client || hndl == INVALID_HANDLE || !SQL_FetchRow(hndl))
		return;
		
	new bancount = SQL_FetchInt(hndl, 0);
	if (bancount > 0)
	{
		PrintToBanAdmins("\x04[SBChecker]\x01 Warning: Player \"%N\" has %d previous SB ban%s on record.", client, bancount, ((bancount>0)?"s":""));
	}
}

public Action:OnListSourceBansCmd(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, LISTBANS_USAGE);
	}
	
	if (g_DB == INVALID_HANDLE)
	{
		ReplyToCommand(client, "Error: database not ready.");
		return Plugin_Handled;
	}
	
	decl String:targetarg[64];
	GetCmdArg(1, targetarg, sizeof(targetarg));
	
	new target = FindTarget(client, targetarg, true, true);
	if (target == -1)
	{
		return Plugin_Handled;
	}
	
	decl String:auth[32];
	if (!GetClientAuthString(target, auth, sizeof(auth))
		|| auth[0] == 'B' || auth[9] == 'L')
	{
		ReplyToCommand(client, "Error: could not retrieve %N's steam id.", target);
		return Plugin_Handled;
	}
	
	decl String:query[1024], String:ip[30];
	GetClientIP(target, ip, sizeof(ip));
	FormatEx(query, sizeof(query), "SELECT created, %s_admins.user, ends, length, reason, RemoveType FROM %s_bans LEFT JOIN %s_admins ON %s_bans.aid = %s_admins.aid WHERE ((type = 0 AND %s_bans.authid REGEXP '^STEAM_[0-9]:%s$') OR (type = 1 AND ip = '%s')) AND ((length > '0' AND ends > UNIX_TIMESTAMP()) OR RemoveType IS NOT NULL)", g_DatabasePrefix, g_DatabasePrefix, g_DatabasePrefix, g_DatabasePrefix, g_DatabasePrefix, g_DatabasePrefix, auth[8], ip);
	
	decl String:targetName[MAX_NAME_LENGTH];
	GetClientName(target, targetName, sizeof(targetName));
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, (client == 0) ? 0 : GetClientUserId(client));
	WritePackString(pack, targetName);
	
	SQL_TQuery(g_DB, OnListBans, query, pack, DBPrio_Low);
	
	if (client == 0)
	{
		ReplyToCommand(client, "[SBChecker] Note: if you are using this command through an rcon tool, you will not see results.");
	}
	else
	{
		ReplyToCommand(client, "\x04[SBChecker]\x01 Look for %N's ban results in console.", target);
	}
	
	return Plugin_Handled;
}

public OnListBans(Handle:owner, Handle:hndl, const String:error[], any:pack)
{
	ResetPack(pack);
	new clientuid = ReadPackCell(pack);
	new client = GetClientOfUserId(clientuid);
	decl String:targetName[MAX_NAME_LENGTH];
	ReadPackString(pack, targetName, sizeof(targetName));
	CloseHandle(pack);
	
	if (clientuid > 0 && client == 0)
		return;
	
	if (hndl == INVALID_HANDLE)
	{
		PrintListResponse(clientuid, client, "[SBChecker] DB error while retrieving bans for %s:\n%s", targetName, error);		
		return;
	}
	
	if (SQL_GetRowCount(hndl) == 0)
	{
		PrintListResponse(clientuid, client, "[SBChecker] No bans found for %s.", targetName);
		return;
	}
	
	PrintListResponse(clientuid, client, "[SBChecker] Listing bans for %s", targetName);
	PrintListResponse(clientuid, client, "Ban Date    Banned By   Length      End Date    R  Reason");
	PrintListResponse(clientuid, client, "-------------------------------------------------------------------------------");
	while (SQL_FetchRow(hndl))
	{
		new String:createddate[11] = "<Unknown> ";
		new String:bannedby[11]    = "<Unknown> ";
		new String:lenstring[11]   = "N/A       ";
		new String:enddate[11]     = "N/A       ";
		new String:reason[28];
		new String:RemoveType[2] = " ";
		
		if (!SQL_IsFieldNull(hndl, 0))
		{
			FormatTime(createddate, sizeof(createddate), "%Y-%m-%d", SQL_FetchInt(hndl, 0));
		}
		
		if (!SQL_IsFieldNull(hndl, 1))
		{
			SQL_FetchString(hndl, 1, bannedby, sizeof(bannedby));
			new len = SQL_FetchSize(hndl, 1);
			if (len > sizeof(bannedby)-1)
			{
				reason[sizeof(bannedby)-4] = '.';
				reason[sizeof(bannedby)-3] = '.';
				reason[sizeof(bannedby)-2] = '.';
			}
			else
			{
				for (new i = len; i < sizeof(bannedby)-1; i++)
				{
					bannedby[i] = ' ';
				}
			}
		}
		
		// NOT NULL
		new length = SQL_FetchInt(hndl, 3);
		if (length == 0)
		{
			strcopy(lenstring, sizeof(lenstring), "Permanent ");
		}
		else
		{
			new len = IntToString(length, lenstring, sizeof(lenstring));
			if (len < sizeof(lenstring)-1)
			{
				// change the '\0' to a ' '. the original \0 at the end will still be there
				lenstring[len] = ' ';
			}
		}
		
		if (!SQL_IsFieldNull(hndl, 2))
		{
			FormatTime(enddate, sizeof(enddate), "%Y-%m-%d", SQL_FetchInt(hndl, 2));
		}
		
		// NOT NULL
		SQL_FetchString(hndl, 4, reason, sizeof(reason));
		new len = SQL_FetchSize(hndl, 4);
		if (len > sizeof(reason)-1)
		{
			reason[sizeof(reason)-4] = '.';
			reason[sizeof(reason)-3] = '.';
			reason[sizeof(reason)-2] = '.';
		}
		else
		{
			for (new i = len; i < sizeof(reason)-1; i++)
			{
				reason[i] = ' ';
			}
		}
		
		if (!SQL_IsFieldNull(hndl, 5))
		{
			SQL_FetchString(hndl, 5, RemoveType, sizeof(RemoveType));
		}
		
		PrintListResponse(clientuid, client, "%s  %s  %s  %s  %s  %s", createddate, bannedby, lenstring, enddate, RemoveType, reason);
	}
}

PrintListResponse(userid, client, const String:format[], any:...)
{
	decl String:msg[192];
	VFormat(msg, sizeof(msg), format, 4);
	
	if (userid == 0)
	{
		PrintToServer("%s", msg);
	}
	else
	{
		PrintToConsole(client, "%s", msg);
	}
}

PrintToBanAdmins(const String:format[], any:...)
{
	decl String:msg[128];
	VFormat(msg, sizeof(msg), format, 2);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)
			&& CheckCommandAccess(i, "sm_listsourcebans", ADMFLAG_BAN)
			)
		{
			PrintToChat(i, "%s", msg);
		}
	}
}

stock ReadConfig()
{
	InitializeConfigParser();

	if (g_ConfigParser == INVALID_HANDLE)
	{
		return;
	}

	decl String:ConfigFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, ConfigFile, sizeof(ConfigFile), "configs/sourcebans/sourcebans.cfg");

	if(FileExists(ConfigFile))
	{
		InternalReadConfig(ConfigFile);
	}
	else
	{
		decl String:Error[PLATFORM_MAX_PATH + 64];
		FormatEx(Error, sizeof(Error), "FATAL *** ERROR *** can not find %s", ConfigFile);
		SetFailState(Error);
	}
}

static InitializeConfigParser()
{
	if (g_ConfigParser == INVALID_HANDLE)
	{
		g_ConfigParser = SMC_CreateParser();
		SMC_SetReaders(g_ConfigParser, ReadConfig_NewSection, ReadConfig_KeyValue, ReadConfig_EndSection);
	}
}

static InternalReadConfig(const String:path[])
{
	new SMCError:err = SMC_ParseFile(g_ConfigParser, path);

	if (err != SMCError_Okay)
	{
		decl String:buffer[64];
		if (SMC_GetErrorString(err, buffer, sizeof(buffer)))
		{
			PrintToServer(buffer);
		}
		else
		{
			PrintToServer("Fatal parse error");
		}
	}
}

public SMCResult:ReadConfig_NewSection(Handle:smc, const String:name[], bool:opt_quotes)
{
	return SMCParse_Continue;
}

public SMCResult:ReadConfig_KeyValue(Handle:smc, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes)
{
	if (strcmp("DatabasePrefix", key, false) == 0) 
	{
		strcopy(g_DatabasePrefix, sizeof(g_DatabasePrefix), value);

		if (g_DatabasePrefix[0] == '\0')
		{
			g_DatabasePrefix = "sb";
		}
	}
	
	return SMCParse_Continue;
}

public SMCResult:ReadConfig_EndSection(Handle:smc)
{
	return SMCParse_Continue;
}
