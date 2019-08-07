#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION  "1.2"

#pragma semicolon 1

public Plugin:myinfo = 
{
	name = "TFBots Change Class",
	author = "EfeDursun125",
	description = "TFBots now changing classes.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/EfeDursun91/"
}

public OnPluginStart()
{
	HookEvent("player_spawn", BotSpawn, EventHookMode_Post);
}

public OnMapStart()
{
	ServerCommand("sm_cvar tf_bot_reevaluate_class_in_spawnroom 0");
	ServerCommand("sm_cvar tf_bot_keep_class_after_death 1");
}

public TF2_OnWaitingForPlayersStart()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsFakeClient(client))
		{
			new team = GetClientTeam(client);
			if(team == 2 && IsPlayerAlive(client) || team == 3 && IsPlayerAlive(client))
			{
				new random = GetRandomInt(1,9);
				switch(random)
				{
					case 1:
			    	{
			    		TF2_SetPlayerClass(client, TFClass_Scout);
					}
					case 2:
			    	{
			    		TF2_SetPlayerClass(client, TFClass_Soldier);
					}
					case 3:
			   		{
			    		TF2_SetPlayerClass(client, TFClass_Pyro);
					}
					case 4:
			    	{
			    		TF2_SetPlayerClass(client, TFClass_DemoMan);
					}
					case 5:
			    	{
			    		TF2_SetPlayerClass(client, TFClass_Heavy);
					}
					case 6:
			 	  	{
			    		TF2_SetPlayerClass(client, TFClass_Engineer);
					}
					case 7:
			   		{
			    		TF2_SetPlayerClass(client, TFClass_Medic);
					}
					case 8:
			   		{
			  	  		TF2_SetPlayerClass(client, TFClass_Sniper);
					}
					case 9:
		  	 		{
			    		TF2_SetPlayerClass(client, TFClass_Spy);
					}
				}
				if(IsValidClient(client))
				{
					TF2_RespawnPlayer(client);
				}
			}
		}
	}
}

public Action:BotSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new botid = GetClientOfUserId(GetEventInt(event, "userid"));
	new team = GetClientTeam(botid);
	
	if(IsFakeClient(botid))
	{
		if(IsPlayerAlive(botid))
		{
			new changeclass = GetRandomInt(1,20);
			if(changeclass == 1)
			{
				if(GameRules_GetProp("m_bPlayingMannVsMachine"))
				{
					if(team == 2)
					{
						new random = GetRandomInt(1,6);
						switch(random)
						{
							case 1:
				    		{
			    				TF2_SetPlayerClass(botid, TFClass_Scout);
							}
							case 2:
			    			{
			    				TF2_SetPlayerClass(botid, TFClass_Soldier);
							}
							case 3:
			   			 	{
			    				TF2_SetPlayerClass(botid, TFClass_Pyro);
							}
							case 4:
			    			{
			    				TF2_SetPlayerClass(botid, TFClass_DemoMan);
							}
							case 5:
			    			{
			    				TF2_SetPlayerClass(botid, TFClass_Heavy);
							}
							case 6:
			   				{
			    				TF2_SetPlayerClass(botid, TFClass_Medic);
							}
						}
					}
					if(IsValidClient(botid) && team == 2)
					{
						TF2_RespawnPlayer(botid);
					}
				}
				else
				{
					new random = GetRandomInt(1,9);
					switch(random)
					{
						case 1:
			    		{
			    			TF2_SetPlayerClass(botid, TFClass_Scout);
						}
						case 2:
			    		{
			    			TF2_SetPlayerClass(botid, TFClass_Soldier);
						}
						case 3:
			   		 	{
			    			TF2_SetPlayerClass(botid, TFClass_Pyro);
						}
						case 4:
			    		{
			    			TF2_SetPlayerClass(botid, TFClass_DemoMan);
						}
						case 5:
			    		{
			    			TF2_SetPlayerClass(botid, TFClass_Heavy);
						}
						case 6:
			 	  		{
			    			TF2_SetPlayerClass(botid, TFClass_Engineer);
						}
						case 7:
			   			{
			    			TF2_SetPlayerClass(botid, TFClass_Medic);
						}
						case 8:
			   			{
			  		  		TF2_SetPlayerClass(botid, TFClass_Sniper);
						}
						case 9:
			  	 		{
			    			TF2_SetPlayerClass(botid, TFClass_Spy);
						}
					}
					if(IsValidClient(botid))
					{
						TF2_RespawnPlayer(botid);
					}
				}
			}
		}
	}
}

public OnClientPutInServer(client)
{
	if(IsFakeClient(client))
	{
		if(IsValidClient(client))
		{
			if(!GameRules_GetProp("m_bPlayingMannVsMachine"))
			{
				if(GetTeamClientCount(2) < GetTeamClientCount(3))
				{
					TF2_ChangeClientTeam(client, TFTeam_Red);
					new random = GetRandomInt(1,9);
					switch(random)
					{
						case 1:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Scout);
						}
						case 2:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Soldier);
						}
						case 3:
			   		 	{
			    			TF2_SetPlayerClass(client, TFClass_Pyro);
						}
						case 4:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_DemoMan);
						}
						case 5:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Heavy);
						}
						case 6:
			 	  		{
			    			TF2_SetPlayerClass(client, TFClass_Engineer);
						}
						case 7:
			   			{
			    			TF2_SetPlayerClass(client, TFClass_Medic);
						}
						case 8:
			   			{
			  		  		TF2_SetPlayerClass(client, TFClass_Sniper);
						}
						case 9:
			  	 		{
			    			TF2_SetPlayerClass(client, TFClass_Spy);
						}
					}
				}
				else
				{
					TF2_ChangeClientTeam(client, TFTeam_Blue);
					new random = GetRandomInt(1,9);
					switch(random)
					{
						case 1:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Scout);
						}
						case 2:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Soldier);
						}
						case 3:
			   		 	{
			    			TF2_SetPlayerClass(client, TFClass_Pyro);
						}
						case 4:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_DemoMan);
						}
						case 5:
			    		{
			    			TF2_SetPlayerClass(client, TFClass_Heavy);
						}
						case 6:
			 	  		{
			    			TF2_SetPlayerClass(client, TFClass_Engineer);
						}
						case 7:
			   			{
			    			TF2_SetPlayerClass(client, TFClass_Medic);
						}
						case 8:
			   			{
			  		  		TF2_SetPlayerClass(client, TFClass_Sniper);
						}
						case 9:
			  	 		{
			    			TF2_SetPlayerClass(client, TFClass_Spy);
						}
					}
				}
			}
		}
	}
}

bool:IsValidClient( client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}
  