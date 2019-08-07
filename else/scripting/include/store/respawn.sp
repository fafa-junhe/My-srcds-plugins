#if defined STANDALONE_BUILD
#include <sourcemod>
#include <sdktools>

#include <store>
#include <zephstocks>
#endif
new g_iRespawnRoundLimit[MAXPLAYERS+1] = {0,...};

new g_cvarRespawnRoundLimit = -1;

#if defined STANDALONE_BUILD
public OnPluginStart()
#else
public Respawn_OnPluginStart()
#endif
{
	Store_RegisterHandler("respawn", "", Respawn_OnMapStart, Respawn_Reset, Respawn_Config, Respawn_Equip, Respawn_Remove, false);
	HookEvent("teamplay_round_start", Respawn_OnRoundStart);
	g_cvarRespawnRoundLimit = RegisterConVar("sm_store_respawn_round_limit", "1", "Number of times you can buy respawn in a round", TYPE_INT);

#if defined STANDALONE_BUILD
	HookEvent("player_spawn", Respawn_OnPlayerSpawn);

#endif
}

#if defined STANDALONE_BUILD
public Action:Respawn_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
#else
public Respawn_OnPlayerSpawn(client)
#endif
{
#if defined STANDALONE_BUILD
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!IsClientInGame(client))
		return Plugin_Continue;
#endif

	g_iRespawnRoundLimit[client] = 0;

}


public Action:Respawn_OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_iRespawnRoundLimit[client] = 0;
	return Plugin_Continue;
}



public Respawn_OnMapStart()
{
}

public Respawn_Reset(client, id)
{
	g_iRespawnRoundLimit[client] = 0;
}

public Respawn_Config(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, 0);

	return true;
}

public Respawn_Equip(client, id)
{
	if(g_iRespawnRoundLimit[client] == g_eCvars[g_cvarRespawnRoundLimit][aCache])
	{
		Chat(client, "%t", "Respawn Limit");
		return 1;
	}
	else
	{
		if(GAME_CSGO || GAME_CSS)
		{
			CS_RespawnPlayer(client);
		}
		else
		{
			TF2_RespawnPlayer(client);
			
		}
	}

	++g_iRoundLimit[client];
	return 0;
}

public Respawn_Remove(client)
{

}