#pragma semicolon 1

#include <sourcemod>

#define PL_VERSION "0.5.5"

#define TF_OBJECT_DISPENSER		0
#define TF_OBJECT_SENTRY			2
#define TF_OBJECT_TELEPORTER	1

#define TF_TELEPORTER_ENTR		0
#define TF_TELEPORTER_EXIT		1

#define TF_TEAM_BLU						3
#define TF_TEAM_RED						2

public Plugin:myinfo =
{
	name        = "TF2 Build Restrictions",
	author      = "Tsunami",
	description = "Restrict buildings in TF2.",
	version     = PL_VERSION,
	url         = "http://www.tsunami-productions.nl"
}

new g_iMaxEntities;
new Handle:g_hEnabled;
new Handle:g_hImmunity;
new Handle:g_hLimits[4][3][2];

public OnPluginStart()
{
	CreateConVar("sm_buildrestrict_version", PL_VERSION, "Restrict buildings in TF2.", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_hEnabled                                                       = CreateConVar("sm_buildrestrict_enabled",                "1", "Enable/disable restricting buildings in TF2.");
	g_hImmunity                                                      = CreateConVar("sm_buildrestrict_immunity",               "0", "Enable/disable admin immunity for restricting buildings in TF2.");
	g_hLimits[TF_TEAM_BLU][TF_OBJECT_DISPENSER][0]                   = CreateConVar("sm_buildrestrict_blu_dispensers",         "1", "Limit for Blu dispensers in TF2.");
	g_hLimits[TF_TEAM_BLU][TF_OBJECT_SENTRY][0]                      = CreateConVar("sm_buildrestrict_blu_sentries",           "1", "Limit for Blu sentries in TF2.");
	g_hLimits[TF_TEAM_BLU][TF_OBJECT_TELEPORTER][TF_TELEPORTER_ENTR] = CreateConVar("sm_buildrestrict_blu_teleport_entrances", "1", "Limit for Blu teleport entrances in TF2.");
	g_hLimits[TF_TEAM_BLU][TF_OBJECT_TELEPORTER][TF_TELEPORTER_EXIT] = CreateConVar("sm_buildrestrict_blu_teleport_exits",     "1", "Limit for Blu teleport exits in TF2.");
	g_hLimits[TF_TEAM_RED][TF_OBJECT_DISPENSER][0]                   = CreateConVar("sm_buildrestrict_red_dispensers",         "1", "Limit for Red dispensers in TF2.");
	g_hLimits[TF_TEAM_RED][TF_OBJECT_SENTRY][0]                      = CreateConVar("sm_buildrestrict_red_sentries",           "1", "Limit for Red sentries in TF2.");
	g_hLimits[TF_TEAM_RED][TF_OBJECT_TELEPORTER][TF_TELEPORTER_ENTR] = CreateConVar("sm_buildrestrict_red_teleport_entrances", "1", "Limit for Red teleport entrances in TF2.");
	g_hLimits[TF_TEAM_RED][TF_OBJECT_TELEPORTER][TF_TELEPORTER_EXIT] = CreateConVar("sm_buildrestrict_red_teleport_exits",     "1", "Limit for Red teleport exits in TF2.");
	g_iMaxEntities                                                   = GetMaxEntities();
	
	AddCommandListener(CommandListener_Build, "build");
}

public Action:CommandListener_Build(client, const String:command[], argc)
{
	// If executed from RCON, or plugin is disabled, or immunity is enabled and client is immune, allow building
	if(!client || !GetConVarBool(g_hEnabled) || (GetConVarBool(g_hImmunity) && GetUserFlagBits(client) & (ADMFLAG_GENERIC|ADMFLAG_ROOT)))
		return Plugin_Continue;
	
	// Get arguments
	decl String:sObjectMode[256], String:sObjectType[256];
	GetCmdArg(1, sObjectType, sizeof(sObjectType));
	GetCmdArg(2, sObjectMode, sizeof(sObjectMode));
	
	// Get object mode, type and client's team
	new iObjectMode = StringToInt(sObjectMode),
			iObjectType = StringToInt(sObjectType),
			iTeam       = GetClientTeam(client);
	
	// If invalid object type passed, or client is not on Blu or Red
	if(iObjectType < TF_OBJECT_DISPENSER || iObjectType > TF_OBJECT_SENTRY || iTeam < TF_TEAM_RED)
		return Plugin_Continue;
	
	// Get limit for that object type and mode on client's team
	new iLimit  = GetConVarInt(g_hLimits[iTeam][iObjectType][iObjectMode]);
	// If limit is -1, allow building
	if(iLimit == -1)
		return Plugin_Continue;
	// If limit is 0, block building
	else if(iLimit == 0)
		return Plugin_Handled;
	
	decl String:sClassName[32];
	// Loop through all entities, excluding clients and the world
	for(new i = MaxClients + 1, iCount = 0; i < g_iMaxEntities; i++)
	{
		// If entity index is invalid, continue
		if(!IsValidEntity(i))
			continue;
		
		GetEntityNetClass(i, sClassName, sizeof(sClassName));
		// If entity is an object, object type equals the argument, builder equals the client and limit was reached, block building
		if (strncmp(sClassName, "CObject", 7)            == 0           &&
				GetEntProp(i,    Prop_Send, "m_iObjectType") == iObjectType &&
				GetEntProp(i,    Prop_Send, "m_iObjectMode") == iObjectMode &&
				GetEntPropEnt(i, Prop_Send, "m_hBuilder")    == client      &&
				++iCount == iLimit)
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}