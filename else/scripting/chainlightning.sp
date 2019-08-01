/*  TF2 Chain Lightning
 *
 *  Copyright (C) 2017 Calvin Lee (Chaosxk)
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <morecolors>

#pragma newdecls required

#define PLUGIN_VERSION "1.0"
#define SMOKE "sprites/steam1.vmt"
#define LIGHTNING "sprites/lgtning.vmt"
#define SOUND_ZAP "misc/halloween/spell_lightning_ball_impact.wav"

#define BLACK { 0, 0, 0, 255 }
#define GREEN { 0, 255, 0, 255 }
#define YELLOW { 255, 255, 0, 255 }
#define ORANGE { 255, 165, 0, 255 }
#define RED { 255, 0, 0, 255 }
#define NAVY { 0, 0, 128, 255 }
#define BLUE { 0, 0, 255, 255 }
#define PURPLE { 255, 0, 255, 255 }
#define TEAL { 0, 128, 128, 255 }
#define PINK { 255, 192, 203, 255 }
#define AQUAMARINE { 127, 255, 212, 255 }
#define PEACHPUFF { 255, 218, 185, 255}
#define WHITE { 255, 255, 255, 255}

char g_sColor[14][16] = {
	"team",
	"black",
	"green",
	"yellow",
	"orange",
	"red",
	"navy",
	"blue",
	"purple",
	"teal",
	"pink",
	"aquamarine",
	"peachpuff",
	"white"
};

Handle g_hClientCookie_Color, g_hClientCookie_Toggle;
ConVar g_cEnabled, g_cDistance, g_cTargets, g_cDamage, g_cUnify, g_cCrits;
bool g_bEnabled[MAXPLAYERS + 1];
int g_iColor[MAXPLAYERS + 1][4];
int g_iLightSprite;

bool g_bPostAdminCheckDone[MAXPLAYERS + 1];
bool g_bCookieCacheDone[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "[TF2] Chain Lightning",
	author = "Tak (Chaosxk)",
	description = "Causes a chain lighting reaction on critical hit.",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	CreateConVar("sm_clight_version", PLUGIN_VERSION, "Chain Lightning Version.", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cEnabled = CreateConVar("sm_clight_enabled", "1", "Enables/Disables Chain Lightning.");
	g_cDistance = CreateConVar("sm_clight_distance", "300", "Unit distance of how far the chain lighting can reach.");
	g_cTargets = CreateConVar("sm_clight_targets", "3", "How many targets will chain lighting hurt at once.");
	g_cDamage = CreateConVar("sm_clight_damage", "0.25", "Damage done to targets in percent in respect to original damage.");
	g_cUnify = CreateConVar("sm_clight_unify", "1", "With respect to sm_clight_damage and original damage, unifies the damage across all targets and victim.");
	g_cCrits = CreateConVar("sm_clight_crits", "0", "Only enable this effect on critical shots.");
	
	RegAdminCmd("sm_clightcolor", Function_ToggleColor, ADMFLAG_GENERIC, "Opens menu to change Chain Lightning colors.");
	RegAdminCmd("sm_clight", Function_ToggleChain, ADMFLAG_GENERIC, "Toggles Chain Lighting.");
	
	g_hClientCookie_Toggle = RegClientCookie("chainlightning_cookietoggle", "Cookie for Chain Lightning toggle.", CookieAccess_Private);
	g_hClientCookie_Color = RegClientCookie("chainlightning_cookiecolor", "Cookie for Chain Lightning colors.", CookieAccess_Private);
	
	OnLateLoad();
	AutoExecConfig(true, "chainlightning");
}

public void OnMapStart()
{
	g_iLightSprite = PrecacheModel(LIGHTNING);
	PrecacheSound(SOUND_ZAP, true);
}

public void OnClientPostAdminCheck(int client)
{
	g_bEnabled[client] = false;
	SDKHook(client, SDKHook_OnTakeDamageAlive, Hook_OnTakeDamageAlive);
	
	g_bPostAdminCheckDone[client] = true;
	
	if (g_bCookieCacheDone[client])
		CacheCookies(client);
}

public void OnClientCookiesCached(int client)
{
	g_bCookieCacheDone[client] = true;
	
	if (g_bPostAdminCheckDone[client])
		CacheCookies(client);
}

public void OnClientDisconnect(int client)
{
	g_bPostAdminCheckDone[client] = false;
	g_bCookieCacheDone[client] = false;
}

public void OnLateLoad()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPostAdminCheck(i);
			OnClientCookiesCached(i);
		}
	}
}

public Action Function_ToggleColor(int client, int args)
{
	if (!g_cEnabled.IntValue)
		return Plugin_Handled;
	
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, "[SM] You must be in-game to use this command.");
		return Plugin_Handled;
	}
	
	Menu menu = new Menu(Handle_Menu);
	menu.SetTitle("Chain Lightning colors");
	menu.AddItem("0", "Team");
	menu.AddItem("1", "Black");
	menu.AddItem("2", "Green");
	menu.AddItem("3", "Yellow");
	menu.AddItem("4", "Orange");
	menu.AddItem("5", "Red");
	menu.AddItem("6", "Navy");
	menu.AddItem("7", "Blue");
	menu.AddItem("8", "Purple");
	menu.AddItem("9", "Teal");
	menu.AddItem("10", "Pink");
	menu.AddItem("11", "Aquamarine");
	menu.AddItem("12", "Peachpuff");
	menu.AddItem("13", "White");
	
	menu.ExitButton = true;
	menu.Display(client, 30);
	
	return Plugin_Handled;
}

public int Handle_Menu(Menu menu, MenuAction action, int param1, int param2) 
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		
		int select = StringToInt(info);
		switch (select)
		{ 
			case 0: {
				int team = GetClientTeam(param1);
				g_iColor[param1] =  team == 2 ? RED : BLUE;
				select = team == 2 ? 5 : 7;
			}
			case 1: g_iColor[param1] =  BLACK;
			case 2: g_iColor[param1] =  GREEN;
			case 3: g_iColor[param1] =  YELLOW;
			case 4: g_iColor[param1] =  ORANGE;
			case 5: g_iColor[param1] =  RED;
			case 6: g_iColor[param1] =  NAVY;
			case 7: g_iColor[param1] =  BLUE;
			case 8: g_iColor[param1] =  PURPLE;
			case 9: g_iColor[param1] =  TEAL;
			case 10: g_iColor[param1] = PINK;
			case 11: g_iColor[param1] = AQUAMARINE;
			case 12: g_iColor[param1] = PEACHPUFF;
			case 13:g_iColor[param1] = WHITE;
		}
		SetColorCookies(param1);
		CPrintToChat(param1, "{yellow}[SM] {normal}You have set your Chain Lightning color to {%s}%s{normal}.", g_sColor[select], g_sColor[select]);
	}
	else if (action == MenuAction_End) 
		delete menu; 
}

public Action Function_ToggleChain(int client, int args)
{
	if (!g_cEnabled.IntValue)
		return Plugin_Handled;
	
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, "[SM] You must be in-game to use this command.");
		return Plugin_Handled;
	}
	
	g_bEnabled[client] = !g_bEnabled[client];
	CReplyToCommand(client, "{yellow}[SM]{normal} You have %s{%normal} Chain Lighting.", g_bEnabled[client] ? "{green}enabled" : "{red}disabled");
	
	SetToggleCookies(client);
	return Plugin_Handled;
}

public Action Hook_OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!g_cEnabled.IntValue || !IsValidClient(victim) || !IsValidClient(attacker) || !g_bEnabled[attacker])
		return Plugin_Continue;
		
	//if ((damagetype & DMG_CRIT) && g_cCrits.BoolValue || (damagetype & ~DMG_CRIT) && g_cCrits.BoolValue)
	if (!(damagetype & DMG_CRIT) && g_cCrits.BoolValue)
		return Plugin_Continue;
		
	ArrayList array = new ArrayList();
	int attacker_team = GetClientTeam(attacker);
	
	float tpos[3];
	
	for (int target = 1; target <= MaxClients; target++)
	{
		if(!IsClientInGame(target) || target == victim || GetClientTeam(target) == attacker_team || !IsPlayerAlive(target))
			continue;
			
		GetClientAbsOrigin(target, tpos);
		tpos[2] = damagePosition[2];
		
		if (GetVectorDistance(damagePosition, tpos) <= g_cDistance.IntValue)
			array.Push(target);
	}
	
	int total_targets = !g_cTargets ? GetRandomInt(1, 5) : g_cTargets.IntValue;
	int array_length = array.Length;
	
	if (total_targets > array_length)
		total_targets = array_length;
	
	if(total_targets)
	{
		//Stops the sound so it doesn't overlap over each other and cause a loud pitch sound
		EmitAmbientSound(SOUND_ZAP, damagePosition, victim, _, SND_STOPLOOPING, _, _, _);
		EmitAmbientSound(SOUND_ZAP, damagePosition, victim, SNDLEVEL_GUNFIRE, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, 0.0);
	}

	while(total_targets)
	{
		int i = GetRandomInt(0, array_length-1);
		int target = array.Get(i);
		
		GetClientAbsOrigin(target, tpos);
		tpos[2] = damagePosition[2];
		
		TE_SetupBeamPoints(damagePosition, tpos, g_iLightSprite, 0, 0, 0, 0.2, 10.0, 0.5, 10, 10.0, g_iColor[attacker], 1);
		TE_SendToAll();
		
		SDKHooks_TakeDamage(target, 0, attacker, g_cUnify.BoolValue ? damage*g_cDamage.FloatValue : damage*g_cDamage.FloatValue, DMG_DISSOLVE);
		
		array.Erase(i);
		array_length--;
		total_targets--;
	}
	
	delete array;
	
	if(g_cUnify.BoolValue)
	{
		damage = damage * g_cDamage.FloatValue;
		return Plugin_Changed;
	}
	
	return Plugin_Continue;
}

void CacheCookies(int client)
{
	char sValue[32];	
	GetClientCookie(client, g_hClientCookie_Toggle, sValue, sizeof(sValue));
	
	//Check client cookie first time for toggle variable
	if(!strlen(sValue))
	{
		g_bEnabled[client] = false;
		SetToggleCookies(client);
	}
	else
		g_bEnabled[client] = view_as<bool>(StringToInt(sValue));
	
	GetClientCookie(client, g_hClientCookie_Color, sValue, sizeof(sValue));
	
	//Check client cookie first time for color variable
	if(!strlen(sValue))
	{
		g_iColor[client] =  GetClientTeam(client) == 2 ? RED : BLUE;
		SetColorCookies(client);
	}
	else
	{
		char value[4][8];
		ExplodeString(sValue, " ", value, sizeof(value), sizeof(value[]));		
		for (int i = 0; i < 4; i++)
			g_iColor[client][i] = StringToInt(value[i]);
	}
}

void SetToggleCookies(int client)
{
	char sValue[2];
	Format(sValue, sizeof(sValue), "%d", g_bEnabled[client] ? 1 : 0);
	SetClientCookie(client, g_hClientCookie_Toggle, sValue);
}

void SetColorCookies(int client)
{
	char sValue[32];
	Format(sValue, sizeof(sValue), "%d %d %d %d", g_iColor[client][0], g_iColor[client][1], g_iColor[client][2], g_iColor[client][3]);
	SetClientCookie(client, g_hClientCookie_Color, sValue);
}

bool IsValidClient(int client)
{
	return 1 <= client <= MaxClients && IsClientInGame(client);
}