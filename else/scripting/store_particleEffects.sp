#pragma semicolon 1

#define PLUGIN_AUTHOR "Totenfluch"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <store>


int g_iLoadedKillEffectsCount = 0;
char g_cLoadedKillEffects[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];
float g_fLoadedKillEffectDuration[STORE_MAX_ITEMS];
char g_cActiveKillEffect[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_fActiveKillEffectDuration[MAXPLAYERS + 1];

int g_iLoadedSpawnEffectsCount = 0;
char g_cLoadedSpawnEffects[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];
float g_fLoadedSpawnEffectDuration[STORE_MAX_ITEMS];
char g_cActiveSpawnEffect[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_fActiveSpawnEffectDuration[MAXPLAYERS + 1];

int g_iLoadedHitEffectsCount = 0;
char g_cLoadedHitEffects[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];
float g_fLoadedHitEffectDuration[STORE_MAX_ITEMS];
char g_cActiveHitEffect[MAXPLAYERS + 1][PLATFORM_MAX_PATH];
float g_fActiveHitEffectDuration[MAXPLAYERS + 1];

public Plugin myinfo = 
{
	name = "Particle Effects (Kill, Spawn, Hit)", 
	author = PLUGIN_AUTHOR, 
	description = "Particle Effects for Store", 
	version = PLUGIN_VERSION, 
	url = "http://ggc-base.de"
};

public void OnPluginStart()
{
	Store_RegisterHandler("kill_effect", "Particle", kill_effect_OnMapStart, kill_effect_Reset_all, kill_effect_Config, kill_effect_Equip, kill_effect_Reset, true);
	Store_RegisterHandler("spawn_effect", "Particle", spawn_effect_OnMapStart, spawn_effect_Reset_all, spawn_effect_Config, spawn_effect_Equip, spawn_effect_Reset, true);
	Store_RegisterHandler("hit_effect", "Particle", hit_effect_OnMapStart, hit_effect_Reset_all, hit_effect_Config, hit_effect_Equip, hit_effect_Reset, true);
	
	HookEvent("player_spawn", onPlayerSpawn);
	HookEvent("player_death", onPlayerDeath, EventHookMode_Pre);
	HookEvent("bullet_impact", onBulletImpact);
}

/* STORE LOGIC */

public void OnClientDisconnect(int client) {
	g_cActiveKillEffect[client] = "";
	g_fActiveKillEffectDuration[client] = 0.0;
	
	g_cActiveSpawnEffect[client] = "";
	g_fActiveSpawnEffectDuration[client] = 0.0;
	
	g_cActiveHitEffect[client] = "";
	g_fActiveHitEffectDuration[client] = 0.0;
}

public void kill_effect_OnMapStart() {  }
public void spawn_effect_OnMapStart() {  }
public void hit_effect_OnMapStart() {  }

public int kill_effect_Reset(int client) {
	g_cActiveKillEffect[client] = "";
	g_fActiveKillEffectDuration[client] = 0.0;
	return 0;
}

public int spawn_effect_Reset(int client) {
	g_cActiveSpawnEffect[client] = "";
	g_fActiveSpawnEffectDuration[client] = 0.0;
	return 0;
}

public int hit_effect_Reset(int client) {
	g_cActiveHitEffect[client] = "";
	g_fActiveHitEffectDuration[client] = 0.0;
	return 0;
}

public bool kill_effect_Config(&Handle:kv, int itemid) {
	Store_SetDataIndex(itemid, g_iLoadedKillEffectsCount);
	KvGetString(kv, "Particle", g_cLoadedKillEffects[g_iLoadedKillEffectsCount], PLATFORM_MAX_PATH);
	g_fLoadedKillEffectDuration[g_iLoadedKillEffectsCount++] = KvGetFloat(kv, "Duration", 5.0);
	return true;
}

public bool spawn_effect_Config(&Handle:kv, int itemid) {
	Store_SetDataIndex(itemid, g_iLoadedSpawnEffectsCount);
	KvGetString(kv, "Particle", g_cLoadedSpawnEffects[g_iLoadedSpawnEffectsCount], PLATFORM_MAX_PATH);
	g_fLoadedSpawnEffectDuration[g_iLoadedSpawnEffectsCount++] = KvGetFloat(kv, "Duration", 5.0);
	return true;
}

public bool hit_effect_Config(&Handle:kv, int itemid) {
	Store_SetDataIndex(itemid, g_iLoadedHitEffectsCount);
	KvGetString(kv, "Particle", g_cLoadedHitEffects[g_iLoadedHitEffectsCount], PLATFORM_MAX_PATH);
	g_fLoadedHitEffectDuration[g_iLoadedHitEffectsCount++] = KvGetFloat(kv, "Duration", 5.0);
	return true;
}

public int kill_effect_Equip(int client, int id) {
	int m_iData = Store_GetDataIndex(id);
	g_cActiveKillEffect[client] = g_cLoadedKillEffects[m_iData];
	g_fActiveKillEffectDuration[client] = g_fLoadedKillEffectDuration[m_iData];
	return 0;
}
public int spawn_effect_Equip(int client, int id) {
	int m_iData = Store_GetDataIndex(id);
	g_cActiveSpawnEffect[client] = g_cLoadedSpawnEffects[m_iData];
	g_fActiveSpawnEffectDuration[client] = g_fLoadedSpawnEffectDuration[m_iData];
	return 0;
}

public int hit_effect_Equip(int client, int id) {
	int m_iData = Store_GetDataIndex(id);
	g_cActiveHitEffect[client] = g_cLoadedHitEffects[m_iData];
	g_fActiveHitEffectDuration[client] = g_fLoadedHitEffectDuration[m_iData];
	return 0;
}

public int kill_effect_Reset_all() {
	g_iLoadedKillEffectsCount = 0;
	return 0;
}

public int spawn_effect_Reset_all() {
	g_iLoadedSpawnEffectsCount = 0;
	return 0;
}

public int hit_effect_Reset_all() {
	g_iLoadedHitEffectsCount = 0;
	return 0;
}

/* STORE LOGIC END */

public Action onPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (StrEqual(g_cActiveSpawnEffect[client], ""))
		return;
	
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	int spawnEffect = CreateEntityByName("info_particle_system");
	DispatchKeyValue(spawnEffect, "start_active", "0");
	DispatchKeyValue(spawnEffect, "effect_name", g_cActiveSpawnEffect[client]);
	DispatchSpawn(spawnEffect);
	ActivateEntity(spawnEffect);
	TeleportEntity(spawnEffect, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(spawnEffect, "Start");
	CreateTimer(g_fActiveSpawnEffectDuration[client], clearEffect, EntIndexToEntRef(spawnEffect));
}

public Action onPlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (client == attacker)
		return;
	
	if (StrEqual(g_cActiveKillEffect[attacker], ""))
		return;
	
	float pos[3];
	GetClientAbsOrigin(client, pos);
	
	int killEffect = CreateEntityByName("info_particle_system");
	DispatchKeyValue(killEffect, "start_active", "0");
	DispatchKeyValue(killEffect, "effect_name", g_cActiveKillEffect[attacker]);
	DispatchSpawn(killEffect);
	ActivateEntity(killEffect);
	TeleportEntity(killEffect, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(killEffect, "Start");
	CreateTimer(g_fActiveKillEffectDuration[attacker], clearEffect, EntIndexToEntRef(killEffect));
}

public Action onBulletImpact(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (StrEqual(g_cActiveHitEffect[client], ""))
		return;
	
	float pos[3];
	pos[0] = GetEventFloat(event, "x");
	pos[1] = GetEventFloat(event, "y");
	pos[2] = GetEventFloat(event, "z");
	
	int hitEffect = CreateEntityByName("info_particle_system");
	DispatchKeyValue(hitEffect, "start_active", "0");
	DispatchKeyValue(hitEffect, "effect_name", g_cActiveHitEffect[client]);
	DispatchSpawn(hitEffect);
	ActivateEntity(hitEffect);
	TeleportEntity(hitEffect, pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(hitEffect, "Start");
	CreateTimer(g_fActiveHitEffectDuration[client], clearEffect, EntIndexToEntRef(hitEffect));
}

public Action clearEffect(Handle Timer, any ent) {
	int iEnt = EntRefToEntIndex(ent);
	AcceptEntityInput(iEnt, "kill");
}