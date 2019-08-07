/* Plugin Template generated by Pawn Studio */

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

#define PL_VERSION				"0.2"

#define CVAR_VERSION			0
#define CVAR_ENABLE				1
#define CVAR_RADIUS				2
#define CVAR_PUNISH				3
#define CVAR_PTYPE				4
#define CVAR_PMESSAGE			5
#define CVAR_PBANTIME			6
#define NUM_CVARS				7

new Handle:g_cvars[NUM_CVARS];
new bool:g_built[MAXPLAYERS+1][2];
new g_offenses[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "Teleporter Trap Suppression",
	author = "Jindo",
	description = "Destroy placed teleporter exits and entrances that are too close to each other.",
	version = PL_VERSION,
	url = "http://www.topaz-games.com/"
}

public OnPluginStart()
{
	g_cvars[CVAR_VERSION] = CreateConVar("teletrapfix_version", PL_VERSION, "Version of the plugin.", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_cvars[CVAR_ENABLE] = CreateConVar("tts_enable", "1", "Enable the plugin.", FCVAR_PLUGIN);
	g_cvars[CVAR_RADIUS] = CreateConVar("tts_radius", "30.0", "Teleporters within this range of another friendly teleporter will be destroyed.", FCVAR_PLUGIN);
	g_cvars[CVAR_PUNISH] = CreateConVar("tts_punishmin", "0", "Number of teletrap attempts before punishing players (0 = don't punish)", FCVAR_PLUGIN);
	g_cvars[CVAR_PTYPE] = CreateConVar("tts_punishtype", "0", "Punishment type for repeated exploiters. 0 = Destroy buildings, 1 = Kick player, 2 = Ban player", FCVAR_PLUGIN);
	g_cvars[CVAR_PMESSAGE] = CreateConVar("tts_message", "You have been punished for building teleporter traps.", "Punishment message to dsiplay to repeated exploiters.", FCVAR_PLUGIN);
	g_cvars[CVAR_PBANTIME] = CreateConVar("tts_bantime", "10", "Ban-time, only applies if \"tts_punishtype\" is set to 2. Setting this to 0 makes the ban permanant.", FCVAR_PLUGIN);
	
	HookEvent("player_builtobject", Event_Build);
	HookEvent("object_destroyed", Event_Update);
	HookEvent("post_inventory_application", Event_CheckPunish);
}

public OnClientConnected(client)
{
	g_built[client][0] = false;
	g_built[client][1] = false;
	g_offenses[client] = 0;
}

public Action:Event_Build(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_cvars[CVAR_ENABLE]))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!GetConVarInt(g_cvars[CVAR_PTYPE]) && g_offenses[client] >= GetConVarInt(g_cvars[CVAR_PUNISH]) && GetConVarInt(g_cvars[CVAR_PUNISH]))
		{
			SetVariantInt(9999);
			AcceptEntityInput(GetEventInt(event, "index"), "RemoveHealth");
			return Plugin_Continue;
		}
		if (GetEventInt(event, "object") == 1 || GetEventInt(event, "object") == 2)
		{
			CheckTeleporter(GetEventInt(event, "object"), GetEventInt(event, "index"), GetEventInt(event, "userid"));
		}
	}
	return Plugin_Continue;
}

public Action:Event_Update(Handle:event, const String:name[], bool:dontBroadcast)
{
	new object = GetEventInt(event, "objecttype");
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (object == 1 || object == 2)
	{
		g_built[client][object-1] = false;
	}
	return Plugin_Continue;
}

public Action:Event_CheckPunish(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && client <= MaxClients)
	{
		if (IsClientConnected(client) && IsClientInGame(client))
		{
			if (g_offenses[client] >= GetConVarInt(g_cvars[CVAR_PUNISH]) && GetConVarInt(g_cvars[CVAR_PUNISH]))
			{
				if (!GetConVarInt(g_cvars[CVAR_PTYPE]))
				{
					TF2_RemoveWeaponSlot(client, 3);
				}
			}
		}
	}
	return Plugin_Continue;
}

CheckTeleporter(object, ent, userid)
{
	new client = GetClientOfUserId(userid);
	g_built[client][object-1] = true;
	decl String:classname[64];
	GetEdictClassname(ent, classname, sizeof(classname));
	new ent2;
	if (g_built[client][0] && g_built[client][1])
	{
		if (!strcmp(classname, "obj_teleporter_entrance"))
		{
			while ((ent2 = FindEntityByClassname(ent2, "obj_teleporter_exit")) != -1)
			{
				if (WithinRange(ent, ent2) >= 2)
				{
					SetVariantInt(9999);
					AcceptEntityInput(ent, "RemoveHealth");
					PunishClient(client);
				}
			}
		}
		if (!strcmp(classname, "obj_teleporter_exit"))
		{
			while ((ent2 = FindEntityByClassname(ent2, "obj_teleporter_entrance")) != -1)
			{
				if (WithinRange(ent, ent2) >= 2)
				{
					SetVariantInt(9999);
					AcceptEntityInput(ent, "RemoveHealth");
					PunishClient(client);
				}
			}
		}
	}
}

PunishClient(client)
{
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		g_offenses[client]++;
		if (GetConVarInt(g_cvars[CVAR_PUNISH]) && g_offenses[client] >= GetConVarInt(g_cvars[CVAR_PUNISH]))
		{
			if (GetConVarInt(g_cvars[CVAR_PTYPE]) == 0)
			{
				decl String:message[128];
				GetConVarString(g_cvars[CVAR_PMESSAGE], message, sizeof(message));
				TF2_RemoveWeaponSlot(client, 3);
				PrintToChat(client, message);
			}
			else if (GetConVarInt(g_cvars[CVAR_PTYPE]) == 1)
			{
				decl String:message[128];
				GetConVarString(g_cvars[CVAR_PMESSAGE], message, sizeof(message));
				KickClient(client, message);
			}
			else if (GetConVarInt(g_cvars[CVAR_PTYPE]) == 2)
			{
				decl String:message[128];
				GetConVarString(g_cvars[CVAR_PMESSAGE], message, sizeof(message));
				BanClient(client, GetConVarInt(g_cvars[CVAR_PBANTIME]), BANFLAG_AUTO, "Exploiting", message);
			}
		}
		else
		{
			if (GetConVarInt(g_cvars[CVAR_PUNISH]))
			{
				new count = GetConVarInt(g_cvars[CVAR_PUNISH])-g_offenses[client];
				PrintToChat(client, "[SM] Teleporter trap detected and destroyed. You have %i more chances before you are punished.", count);
			}
			else
			{
				PrintToChat(client, "[SM] Teleporter trap detected and destroyed.");
			}
		}
	}
}

stock WithinRange(ent1, ent2)
{
	new Float:radius = GetConVarFloat(g_cvars[CVAR_RADIUS]);
	new Float:pos1[3], Float:pos2[3];
	GetEntPropVector(ent1, Prop_Data, "m_vecAbsOrigin", pos1);
	GetEntPropVector(ent2, Prop_Data, "m_vecAbsOrigin", pos2);
	new count = 0;
	for (new i = 0; i < 3; i++)
	{
		if (pos1[i] > pos2[i]-radius && pos1[i] < pos2[i]+radius)
		{
			count++;
			continue;
		}
	}
	return count;
}