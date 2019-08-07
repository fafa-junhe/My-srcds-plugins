#pragma semicolon 1

// Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2>
#include <tf2_stocks>
#include <sm_chaosmvm>

// Defines
#define ABIL_VERSION "1.0"
#define MAX_DISTANCE 400.0
#define SND_EXPLODE "sound/weapons/rocket_directhit_explode3.wav"

// Plugin Info
public Plugin:myinfo =
{
	name = "[Chaos MVM Ability]Meteor Crash",
	author = "X Kirby",
	description = "Fall Damage now causes an explosion!",
	version = ABIL_VERSION,
	url = "n/a",
}

// Variables
new Float:fl_AbilLevel[MAXPLAYERS+1] = 0.0;
new bool:b_Hooked[MAXPLAYERS+1] = false;
new g_ExplosionSprite;

// On Plugin Start
public OnPluginStart()
{
	// Explosion Effect Precache
	g_ExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");
	PrecacheSound(SND_EXPLODE);
	for(new i=1; i<=MAXPLAYERS; i++)
	{
		if(!IsValidEntity(i)){continue;}
		fl_AbilLevel[i] = 0.0;
		if(b_Hooked[i] == false)
		{
			b_Hooked[i] = true;
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}

// On Map Start
public OnMapStart()
{
	for(new i=1; i<=MAXPLAYERS; i++)
	{
		if(!IsValidEntity(i)){continue;}
		fl_AbilLevel[i] = 0.0;
		if(b_Hooked[i] == false)
		{
			b_Hooked[i] = true;
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}

// On Client Put In Server
public OnClientPutInServer(client)
{
	fl_AbilLevel[client] = 0.0;
	if(b_Hooked[client] == false)
	{
		b_Hooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

// On Client Disconnect
public OnClientDisconnect(client)
{
	if(IsClientInGame(client))
	{
		fl_AbilLevel[client] = 0.0;
		b_Hooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

// Set Attribute Value
public SetAttribValue(client, String:effectname[256], Float:value)
{
	if(StrEqual(effectname, "cmvm_abil_meteorcrash"))
	{
		fl_AbilLevel[client] = value;
	}
}

// Get Attribute Value
public Float:GetAttribValue(client, String:effectname[256])
{
	if(StrEqual(effectname, "cmvm_abil_meteorcrash"))
	{
		return fl_AbilLevel[client];
	}
	return 0.0;
}

// On Take Damage
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if(victim > 0 && victim <= MaxClients)
	{
		if(!IsClientInGame(victim))
		{
			return Plugin_Continue;
		}
		
		// Perform an Explosion if you take Fall Damage
		if(damagetype == DMG_FALL && fl_AbilLevel[victim] > 0.0)
		{
			FallExplosion(victim, damage * fl_AbilLevel[victim], MAX_DISTANCE);
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

// Fall Damage Explosion
FallExplosion(client, Float:dmg, Float:distance)
{
	if(IsPlayerAlive(client))
	{
		// Find User Location
		new Float:uservec[3], Float:targetvec[3];
		GetClientAbsOrigin(client, uservec);
		
		// Play Effects
		TE_SetupExplosion(uservec, g_ExplosionSprite, 2.0, 1, TE_EXPLFLAG_NONE, 300, 4);
		TE_SendToAll(0.0);
		EmitSoundToAll(SND_EXPLODE, client);
		
		// Look for all Clients
		for(new i=1; i<=MaxClients; i++)
		{
			if(!IsClientInGame(i)){continue;}
			
			// Get Target Location
			GetClientAbsOrigin(i, targetvec);
			
			// Check for close-by targets
			if(i != client && GetClientTeam(i) != GetClientTeam(client) && GetVectorDistance(uservec, targetvec, false) < distance)
			{
				TE_SetupExplosion(targetvec, g_ExplosionSprite, 2.0, 1, TE_EXPLFLAG_NONE, 300, 4);
				TE_SendToAll(0.0);
				
				new Float:force[3];
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", force);
				force[2] = 500.0;
				SDKHooks_TakeDamage(i, client, client, dmg, DMG_BLAST, -1, force, NULL_VECTOR);
			}
		}
	}
}