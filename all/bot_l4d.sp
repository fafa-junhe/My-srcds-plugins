/* Plugin Template generated by Pawn Studio */
 
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions> 
new GameMode;
new L4D2Version;

new Handle:l4d_bot_max;
new Handle:l4d_bot_min;
new Handle:l4d_bot_teleport;
new Handle:l4d_bot_kick_player_leave;
new Handle:l4d_bot_kick_bot_die;

new bool:IsNewPlayer[MAXPLAYERS+1]
new ClientState[MAXPLAYERS+1]
new ClientKickTime[MAXPLAYERS+1]
 
public Plugin:myinfo = 
{
	name = " Bots Control In Coop Mode",
	author = "Pan XiaoHai",
	description = "<- Description ->",
	version = "1.0",
	url = "<- URL ->"
} 

public OnPluginStart()
{  
	GameCheck();
	if(GameMode==2)return;
	l4d_bot_max = CreateConVar("l4d_bot_max", "13", "max bots");
	l4d_bot_min = CreateConVar("l4d_bot_min", "4", "min bots");
	l4d_bot_teleport = CreateConVar("l4d_bot_teleport", "0", "teleport the new bot to a palyer");
	l4d_bot_kick_bot_die = CreateConVar("l4d_bot_bot_die", "1", "kick bot if he die");
	l4d_bot_kick_player_leave = CreateConVar("l4d_bot_kick_player_leave", "0", "kick the bot if player leave");
	//RegConsoleCmd("sm_bot123", sm_bot123);  
	AutoExecConfig(true, "bot_l4d"); 
	HookEvent("player_spawn", player_spawn);	
	HookEvent("player_team", player_team  );
	HookEvent("player_death", player_death); 
}
public OnMapStart()
{
	for(new client=1; client<=MaxClients; client++)
	{
		
	} 
}
public player_team(Handle:event, const String:name[], bool:dontBroadcast)
{ 
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	new team =  GetEventInt(event, "team") ;
	
	new isnew=IsNewPlayer[client];
	IsNewPlayer[client]=false;  
	if(isnew && client>0 && IsClientInGame(client) && !IsFakeClient(client))
	{
		if(client>0 && IsClientInGame(client) && !IsFakeClient(client))PrintToServer("player %N change team to %d", client, team);
		CreateTimer(1.0, ClientInServer, client);	 
	}
}
public Action:ClientInServer(Handle:timer, any:client)
{
	if(client>0 && IsClientInGame(client) && !IsFakeClient(client))
	{ 
		PrintToServer("player %N join survivor", client );
		if (GetClientTeam(client)==1)
		{			
			new bot=GetABot();
			if(bot>0)
			{
				TakeOverBot(client, bot);
				PrintToServer("player %N takeover %N ", client,bot );
				
			}
		}
		new bool:bstate=GetAliveState(client); 
		if(bstate && !IsPlayerAlive(client))
		{
			Respawn(client);
			PrintToServer("force player %N respawn",client);
			if(GetConVarInt(l4d_bot_teleport)==1)
			{
				TeleportClientTo(client);
			}
		}	
		
	}
}
 
public Action:player_death(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(client>0 && IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client)) 
	{
		SetAliveState(client, false); 
	}
	if(GetConVarInt(l4d_bot_kick_bot_die)==0)return;
	if(client>0 && IsClientInGame(client) && GetClientTeam(client)==2 && IsFakeClient(client)) 
	{
		new bot=GetSurvivorCount();
		new player=GetRealPlayerCount();
		if(bot>GetConVarInt(l4d_bot_min) && bot>player)
		{			
			if(client>0)PrintToChatAll("Delete dead bot %N", client);
			if(client>0)PrintToServer("Delete dead bot %N", client);
			KickClient(client);
		}
	}
	
}
public Action:player_spawn(Handle:hEvent, const String:strName[], bool:DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid")); 
	if(client>0 && IsClientInGame(client) && GetClientTeam(client)==2 && !IsFakeClient(client)) 
	{
		SetAliveState(client, true); 
	} 
}
public OnClientPutInServer(client)
{
	if(client>0 && !IsFakeClient(client)) 
	{
		//PrintToServer("OnClientPutInServer %N", client );
		IsNewPlayer[client]=true;
		
		new bot=GetSurvivorCount();
		new player=GetRealPlayerCount();
		PrintToServer("client %N join game bot %d human %d", client,bot ,player);
		if(bot<player && bot<GetConVarInt(l4d_bot_max))
		{
			CreateBot(client);
		}
	}
}
public OnClientDisconnect(client)
{
	if(GetConVarInt(l4d_bot_kick_player_leave)==0)return;
	if(client>0 && !IsFakeClient(client))
	{		 
		//PrintToServer("OnClientDisconnect %N", client);
		ClientState[client]=0;
		ClientKickTime[client]=0;  
		new bot=GetSurvivorCount();
		new player=GetRealPlayerCount(client); 
	 
		if(bot>GetConVarInt(l4d_bot_min) && bot>player)
		{			
			KickDeadBot(1,client); 
		}
	}
}
KickDeadBot(count=1, client)
{ 
	new c=0;
	for(new i=1; i<MaxClients && c<count; i++)
	{
		if (IsClientInGame(i) &&  GetClientTeam(i) == 2 && IsFakeClient(i)  && !IsPlayerAlive(i))
		{
			PrintToChatAll("Delete dead bot %N bacause %N leave",i,client);
			PrintToServer("Delete dead bot %N bacause %N leave",i,client);
			c++;
		} 
	}	 
}
TeleportClientTo(client)
{
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && i!=client)
		{
			new Float:pos[3];
			GetClientAbsOrigin(i, pos);
			TeleportEntity(client, pos, NULL_VECTOR,NULL_VECTOR);
		} 
	}
}

GetPCount()
{
	new count=0;
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)  && GetClientTeam(i) == 1)
		{
			count++;
		} 
	}	
	return count;
}
GetSurvivorCount()
{
	new count=0;
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			count++;
		} 
	}	
	return count;
}
GetBotCount()
{
	new count=0;
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsFakeClient(i))
		{
			count++;
		} 
	}	
	return count;
}
GetABot()
{
	new r=0;
	new bots=0;
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2) 
		{
			if( IsFakeClient(i) ) r=i;
			bots++;
		} 
	}	  
	return r;
}
CreateBot(client=0)
{
	new bot = CreateFakeClient("I am not real.");
	if(bot != 0)
	{
		ChangeClientTeam(bot, 2);
		if(DispatchKeyValue(bot, "classname", "SurvivorBot") == false)
		{
			PrintToServer("\x01Create bot failed");
			return 0;
		}
		
		if(DispatchSpawn(bot) == false)
		{
			PrintToServer("\x01Create bot failed");
			return 0;
		}
		SetEntityRenderColor(bot, 128, 0, 0, 255); 
		CreateTimer(0.1,TimerKick, bot, TIMER_FLAG_NO_MAPCHANGE); 
		if(client>0)PrintToChatAll("Create a bot for %N", client);
		if(client>0)PrintToServer("Create a bot for %N", client);
	}
	return bot;
}
public Action:TimerKick(Handle:timer, any:bot)
{
	KickClient(bot, "fake player");
	return Plugin_Stop;
}
GetRealPlayerCount(except=0)
{
	new count=0;
	for(new i=1; i<MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i)!= 3 && !IsFakeClient(i) && i!=except)
		{
			count++;
		} 
	}	
	return count;
}
public Action:sm_bot123(client,args)
{
	Respawn(client); 
} 
stock TakeOverBot(client, bot)
{ 
	static Handle:hSpec;
	if(hSpec == INVALID_HANDLE)
	{
		new Handle:hGameConf;
		
		hGameConf = LoadGameConfigFile("l4dsb");
		if(hGameConf==INVALID_HANDLE)PrintToChatAll("load error");
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		hSpec = EndPrepSDKCall();
	}
	
	static Handle:hSwitch;
	if(hSwitch == INVALID_HANDLE)
	{
		new Handle:hGameConf;
		
		hGameConf = LoadGameConfigFile("l4dsb");
		
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
		PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
		hSwitch = EndPrepSDKCall();
	}
	
	SDKCall(hSpec, bot, client);
	SDKCall(hSwitch, client, true); 
	return;
}
stock Respawn(client)
{
	static Handle:hRoundRespawn=INVALID_HANDLE;
	if (hRoundRespawn == INVALID_HANDLE)
	{
		new Handle:hGameConf = LoadGameConfigFile("respawn");
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "RoundRespawn");
		hRoundRespawn = EndPrepSDKCall();  
		if (hRoundRespawn == INVALID_HANDLE) 
		{ 
			PrintToChatAll("L4D_SM_Respawn: RoundRespawn Signature broken");
		}		
  	}
	SDKCall(hRoundRespawn, client); 
}



SetAliveState(client, bool:bstate)
{
	if(bstate)ClientCommand(client, "setinfo %s %s", "alive", "true"); 	
	else ClientCommand(client, "setinfo %s %s", "alive", "false"); 	
}
bool:GetAliveState(client)
{
	new String:info[64];
	GetClientInfo(client, "alive", info, 64);
	PrintToServer("palyer %N info %s", client, info);
	if(StrEqual(info, "false"))	return false;
	return true;
} 
GameCheck()
{
	decl String:GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));
	
	
	if (StrEqual(GameName, "survival", false))
		GameMode = 3;
	else if (StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false))
		GameMode = 2;
	else if (StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false))
		GameMode = 1;
	else
	{
		GameMode = 0;
 	}
	GameMode+=0;
 
	GetGameFolderName(GameName, sizeof(GameName));
	if (StrEqual(GameName, "left4dead2", false))
	{
	 
		L4D2Version=true;
	}	
	else
	{		 
		L4D2Version=false;
	}
 
}