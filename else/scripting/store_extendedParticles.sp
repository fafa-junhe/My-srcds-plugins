#include <sourcemod> 
#include <sdktools> 
#include <sdkhooks>
#include <store> 
#include <multicolors>
#include <clientprefs>

bool g_bHideParticles[MAXPLAYERS + 1];

char g_cParticleNames[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];
int g_iParticleId = 0;
int g_iClientParticles[MAXPLAYERS + 1];
char g_cParticleName[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

char g_cParticleTrailNames[STORE_MAX_ITEMS][PLATFORM_MAX_PATH];
int g_iParticleTrailId = 0;
int g_iClientParticleTrail[MAXPLAYERS + 1];
char g_cParticleTrailName[MAXPLAYERS + 1][PLATFORM_MAX_PATH];

Handle g_hClientHideCookie = INVALID_HANDLE;

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Extended Particle Systems", 
	author = "Totenfluch", 
	description = "Adds Particles to the Store", 
	version = "2.0", 
	url = "http://ggc-base.de"
}

public void OnPluginStart() {
	Store_RegisterHandler("Aura", "Name", particlesOnMapStart, ResetParticles, particlesOnConfig, particlesOnEquip, particlesOnReset, true, false);
	Store_RegisterHandler("Particles", "Name", particlesTrailOnMapStart, ResetParticlesTrail, particlesTrailOnConfig, particlesTrailOnEquip, particlesTrailOnReset, true, false);
	
	HookEvent("round_start", onRoundStart);
	HookEvent("round_end", onRoundEnd);
	HookEvent("player_death", onPlayerDeath);
	HookEvent("player_spawn", onPlayerSpawn);
	
	g_hClientHideCookie = RegClientCookie("particleHideCookie", "Cookie to check if Particles are blocked", CookieAccess_Private);
	for (new i = MaxClients; i > 0; --i) {
		if (!AreClientCookiesCached(i)) {
			continue;
		}
		OnClientCookiesCached(i);
	}
	
	RegConsoleCmd("sm_hidep", cmdOnHide, "Hides the Particles");
}

public void OnClientCookiesCached(int client) {
	char sValue[8];
	GetClientCookie(client, g_hClientHideCookie, sValue, sizeof(sValue));
	
	g_bHideParticles[client] = (sValue[0] != '\0' && StringToInt(sValue));
}

public Action cmdOnHide(int client, int args)
{
	g_bHideParticles[client] = !g_bHideParticles[client];
	if (g_bHideParticles[client]) {
		CPrintToChat(client, "{purple}Disabled Particles for you");
		SetClientCookie(client, g_hClientHideCookie, "1");
	} else {
		CPrintToChat(client, "{purple}Enabled Particles for you again");
		SetClientCookie(client, g_hClientHideCookie, "0");
	}
	return Plugin_Handled;
}

public void OnClientDisconnect(int client) {
	g_iClientParticles[client] = 0;
	g_cParticleName[client] = "";
	g_iClientParticleTrail[client] = 0;
	g_cParticleTrailName[client] = "";
	g_bHideParticles[client] = false;
}

public Action onPlayerDeath(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	removeParticles(client);
	removeParticlesTrail(client);
}

public Action onPlayerSpawn(Handle event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetParticles(client);
	SetParticlesTrail(client);
}

public Action onRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	CreateTimer(0.5, Timer_SetParticles);
	CreateTimer(0.5, Timer_SetTrailParticles);
}

public Action Timer_SetParticles(Handle Timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			SetParticles(i);
		}
	}
}

public Action Timer_SetTrailParticles(Handle Timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsPlayerAlive(i)) {
			SetParticlesTrail(i);
		}
	}
}

public Action onRoundEnd(Handle event, const char[] name, bool dontBroadcast) {
	for (int i = 1; i <= MaxClients; i++) {
		g_iClientParticles[i] = 0;
		g_iClientParticleTrail[i] = 0;
	}
}

public void ResetParticles() {
	g_iParticleId = 0;
}

public void ResetParticlesTrail() {
	g_iParticleTrailId = 0;
}

public bool particlesOnConfig(&Handle:kv, int itemid) {
	Store_SetDataIndex(itemid, g_iParticleId);
	KvGetString(kv, "Name", g_cParticleNames[g_iParticleId++], PLATFORM_MAX_PATH);
	return true;
}

public particlesTrailOnConfig(&Handle:kv, itemid)
{
	Store_SetDataIndex(itemid, g_iParticleTrailId);
	KvGetString(kv, "Name", g_cParticleTrailNames[g_iParticleTrailId++], PLATFORM_MAX_PATH);
	return true;
}

public int particlesOnEquip(int client, int id) {
	int m_iData = Store_GetDataIndex(id);
	g_cParticleName[client] = g_cParticleNames[m_iData];
	if (g_iClientParticles[client] != 0) {
		removeParticles(client);
	}
	SetParticles(client);
	return 0;
}

public int particlesTrailOnEquip(int client, int id) {
	int m_iData = Store_GetDataIndex(id);
	g_cParticleTrailName[client] = g_cParticleTrailNames[m_iData];
	if (g_iClientParticleTrail[client] != 0) {
		removeParticlesTrail(client);
	}
	SetParticlesTrail(client);
	return 0;
}


public void particlesOnMapStart() {  }

public void particlesTrailOnMapStart() {  }

public void removeParticles(int client)
{
	if (g_iClientParticles[client] != 0) {
		if (IsClientInGame(client)) {
			if (IsValidEdict(g_iClientParticles[client])) {
				SDKUnhook(g_iClientParticles[client], SDKHook_SetTransmit, Hook_SetTransmit);
				AcceptEntityInput(g_iClientParticles[client], "Kill");
			}
		}
		g_iClientParticles[client] = 0;
	}
}

public void removeParticlesTrail(int client)
{
	if (g_iClientParticleTrail[client] != 0) {
		if (IsClientInGame(client)) {
			if (IsValidEdict(g_iClientParticleTrail[client])) {
				SDKUnhook(g_iClientParticleTrail[client], SDKHook_SetTransmit, Hook_SetTransmit);
				AcceptEntityInput(g_iClientParticleTrail[client], "Kill");
			}
		}
		g_iClientParticleTrail[client] = 0;
	}
}

public void SetParticles(int client) {
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		if (g_iClientParticles[client] != 0)
			removeParticles(client);
		
		if (IsPlayerAlive(client)) {
			if (!(strcmp(g_cParticleName[client], "", false) == 0)) {
				float clientOrigin[3];
				GetClientAbsOrigin(client, clientOrigin);
				int particle_system = CreateEntityByName("info_particle_system");
				DispatchKeyValue(particle_system, "start_active", "0");
				DispatchKeyValue(particle_system, "effect_name", g_cParticleName[client]);
				DispatchSpawn(particle_system);
				TeleportEntity(particle_system, clientOrigin, NULL_VECTOR, NULL_VECTOR);
				ActivateEntity(particle_system);
				SetVariantString("!activator");
				AcceptEntityInput(particle_system, "SetParent", client, particle_system, 0);
				CreateTimer(0.1, enableParticle, particle_system);
				g_iClientParticles[client] = particle_system;
			}
		}
	}
}

public void SetParticlesTrail(int client) {
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		if (g_iClientParticleTrail[client] != 0)
			removeParticlesTrail(client);
		
		if (IsPlayerAlive(client)) {
			if (!(strcmp(g_cParticleTrailName[client], "", false) == 0)) {
				float clientOrigin[3];
				GetClientAbsOrigin(client, clientOrigin);
				int particle_system = CreateEntityByName("info_particle_system");
				DispatchKeyValue(particle_system, "start_active", "0");
				DispatchKeyValue(particle_system, "effect_name", g_cParticleTrailName[client]);
				DispatchSpawn(particle_system);
				TeleportEntity(particle_system, clientOrigin, NULL_VECTOR, NULL_VECTOR);
				ActivateEntity(particle_system);
				SetVariantString("!activator");
				AcceptEntityInput(particle_system, "SetParent", client, particle_system, 0);
				CreateTimer(0.1, enableParticle, particle_system);
				g_iClientParticleTrail[client] = particle_system;
			}
		}
	}
}

public Action enableParticle(Handle Timer, any ent) {
	if (ent > 0 && IsValidEntity(ent)) {
		AcceptEntityInput(ent, "Start");
		setFlags(ent);
		SDKHook(ent, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}

public void setFlags(int edict) {
	if (GetEdictFlags(edict) & FL_EDICT_ALWAYS)
		SetEdictFlags(edict, (GetEdictFlags(edict) ^ FL_EDICT_ALWAYS));
}

public int particlesOnReset(int client) {
	removeParticles(client);
	g_iClientParticles[client] = 0;
	g_cParticleName[client] = "";
	return 0;
}

public int particlesTrailOnReset(int client) {
	removeParticlesTrail(client);
	g_iClientParticleTrail[client] = 0;
	g_cParticleTrailName[client] = "";
	return 0;
}

public Action Hook_SetTransmit(int entity, int client)
{
	setFlags(entity);
	if (g_bHideParticles[client])
		return Plugin_Handled;
	else
		return Plugin_Continue;
}