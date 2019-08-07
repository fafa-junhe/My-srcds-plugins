#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#include <store>

#pragma semicolon 1
#pragma newdecls required

#include <multicolors>

#define RADIO_MODEL "models/props/cs_office/radio.mdl"

public Plugin myinfo = 
{
	name = "STORE - Songs", 
	author = "good_live", 
	description = "Allows players to buy songs and play them through a ingame radio entity.", 
	version = "0.1", 
	url = "painlessgaming.eu"
};

ArrayList g_aPaths;
ArrayList g_aCooldowns;

int g_iCooldown[MAXPLAYERS + 1];

ConVar g_cHP;

int g_iRadioSong[2048];

public void OnPluginStart()
{
	g_aPaths = new ArrayList(PLATFORM_MAX_PATH);
	g_aCooldowns = new ArrayList();
	
	Store_RegisterHandler("song", "path", Store_OnMapStart, Store_Reset, Store_Config, Store_Use, INVALID_FUNCTION, false);
	
	g_cHP = CreateConVar("store_song_hp", "100", "The amount of hp that the spawned radio has.");
	AutoExecConfig(true);
}

public bool Store_Config(KeyValues &kv, int itemid)
{
	if (kv == INVALID_HANDLE)
		SetFailState("Failed to read store config");
	char sBuffer[PLATFORM_MAX_PATH];
	if (!kv.GetString("path", sBuffer, sizeof(sBuffer)))
		return false;
	
	g_aCooldowns.Push(kv.GetNum("cd", 0));
	
	Store_SetDataIndex(itemid, g_aPaths.PushString(sBuffer));
	return true;
}

public void Store_OnMapStart()
{
	PrecacheModel(RADIO_MODEL);
	
	char sPath[PLATFORM_MAX_PATH];
	char sBuffer[PLATFORM_MAX_PATH];
	
	for (int i = 0; i < g_aPaths.Length; i++)
	{
		g_aPaths.GetString(i, sPath, sizeof(sPath));
		
		Format(sBuffer, sizeof(sBuffer), "sound/%s", sPath);
		AddFileToDownloadsTable(sBuffer);
		
		Format(sBuffer, sizeof(sBuffer), "*%s", sPath);
		PrecacheSound(sBuffer);
	}
}

public void Store_Reset()
{
	g_aPaths.Clear();
	g_aCooldowns.Clear();
}

public int Store_Use(int client, int id)
{
	if (!IsPlayerAlive(client))
	{
		CPrintToChat(client, "{default}[{lightblue}TTT{default}]{lightblue}Du musst leben um ein Radio nutzen zu können!");
		return 1;
	}
	
	if (g_iCooldown[client] > GetTime())
	{
		CPrintToChat(client, "{default}[{lightblue}TTT{default}]{lightblue}Dein Radio hat noch einen Cooldown!");
		return 1;
	}
	
	int index = Store_GetDataIndex(id);
	
	g_iCooldown[client] = GetTime() + g_aCooldowns.Get(index);
	
	SpawnRadioAtPlayer(client, index, g_cHP.IntValue);
	return 0;
}

void SpawnRadioAtPlayer(int client, int song, int hp)
{
	float pos[3];
	GetClientEyePosition(client, pos);
	float vec[3];
	GetClientEyeAngles(client, vec);
	GetAngleVectors(vec, vec, NULL_VECTOR, NULL_VECTOR);
	vec[2] = 0.0;
	NormalizeVector(vec, vec);
	vec[0] *= 20.0;
	vec[1] *= 20.0;
	AddVectors(pos, vec, pos);
	SpawnRadio(pos, hp, song);
}

void SpawnRadio(float position[3], int hp, int song)
{
	
	char health[8];
	FormatEx(health, sizeof health, "%d", hp);
	
	int ent = CreateEntityByName("prop_physics_multiplayer");
	
	DispatchKeyValue(ent, "model", RADIO_MODEL);
	DispatchKeyValue(ent, "targetname", "office_radio_2k15");
	DispatchKeyValue(ent, "health", health);
	DispatchKeyValue(ent, "spawnflags", "256"); // +usable
	
	DispatchSpawn(ent);
	
	
	SetEntProp(ent, Prop_Data, "m_iHealth", hp);
	
	g_iRadioSong[ent] = song;
	
	HookSingleEntityOutput(ent, "OnPlayerUse", OnRadioUse, true);
	HookSingleEntityOutput(ent, "OnBreak", OnRadioBreak, true);
	
	TeleportEntity(ent, position, NULL_VECTOR, NULL_VECTOR);
}

public void OnRadioUse(const char[] output, int caller, int activator, float delay)
{
	char sPath[PLATFORM_MAX_PATH];
	if (!g_aPaths.GetString(g_iRadioSong[caller], sPath, sizeof(sPath)))
		return;
	
	char buffer[PLATFORM_MAX_PATH];
	Format(buffer, sizeof(buffer), "*%s", sPath);
	
	StopSound(caller, SNDCHAN_AUTO, buffer);
	EmitSoundToAll(buffer, caller);
}

public void OnRadioBreak(const char[] output, int caller, int activator, float delay)
{
	// stop twice to account for loop point area 
	// (it may have two sounds active briefly)
	
	char sPath[PLATFORM_MAX_PATH];
	if (!g_aPaths.GetString(g_iRadioSong[caller], sPath, sizeof(sPath)))
		return;
	
	char buffer[PLATFORM_MAX_PATH];
	Format(buffer, sizeof(buffer), "*%s", sPath);
	
	
	StopSound(caller, SNDCHAN_AUTO, buffer);
	StopSound(caller, SNDCHAN_AUTO, buffer);
}