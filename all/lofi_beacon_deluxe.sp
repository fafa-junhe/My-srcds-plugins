// Required includes
#include <sourcemod>
#include <clients>
#include <sdktools_functions>
#include <sdktools_engine>
#include <sdktools_tempents>
#include <sdktools_tempents_stocks>
#include <events>

// Set strict semicolon mode
#pragma semicolon 1

// Define plugin version
#define PLUGIN_VERSION "2.1"

// New defines
new bool:g_bIsLofi[MAXPLAYERS+1];
new g_BeamSprite = -1;
new g_HaloSprite = -1;

// Beacon color ConVar stuff
new Handle:c_BeaconRed;
new Handle:c_BeaconGreen;
new Handle:c_BeaconBlue;
new Handle:c_BeaconAlpha;
new g_BeaconColor[4];

// Beacon settings ConVar stuff
new Handle:c_BeaconRadius;
new Handle:c_BeaconInterval;
new Float:f_BeaconRadius = 24.0;
new Float:f_BeaconInterval = 1.5;

// Plugin information
public Plugin:myinfo =
{
	name = "[TF2] Lo-Fi Beacon Deluxe",
	author = "404: User Not Found",
	description = "Adds a beacon effect to all Lo-Fi Longwave hats",
	version = PLUGIN_VERSION,
	url = "http://www.unfgaming.net/404"
}

// Event: Plugin has loaded
public OnPluginStart()
{
	// Make sure the server is a Team Fortress 2 server
	decl String:strModName[32]; GetGameFolderName(strModName, sizeof(strModName));
	if (!StrEqual(strModName, "tf"))
	{
		SetFailState("This plugin is only for Team Fortress 2.");
	}
	
	// CREATE PLUGIN VERSION CONVAR
	CreateConVar("lofibeacon_deluxe_version", PLUGIN_VERSION, "Lo-Fi Longwave Beacon Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// Create the ConVars
	// Note: The default RGB values are those of the "Vintage" item quality color in Team Fortress 2.
	// The Lo-Fi Longwave hat was first distributed in Vintage quality, hence the color choice.
	c_BeaconRed = CreateConVar("lofi_beacon_red", "71", "Beacon Color: Red value", _, true, 0.0, true, 255.0);
	c_BeaconGreen = CreateConVar("lofi_beacon_green", "98", "Beacon Color: Green value", _, true, 0.0, true, 255.0);
	c_BeaconBlue = CreateConVar("lofi_beacon_blue", "145", "Beacon Color: Blue value", _, true, 0.0, true, 255.0);
	c_BeaconAlpha = CreateConVar("lofi_beacon_alpha", "255", "Beacon Color: Alpha value", _, true, 0.0, true, 255.0);
	c_BeaconRadius = CreateConVar("lofi_beacon_radius", "24.0", "Set the radius of the beacon effect", _, true, 0.0, true, 500.0);
	c_BeaconInterval = CreateConVar("lofi_beacon_interval", "1.5", "Set interval for the beacon effect to display at (Default: 1.5)", _, true, 0.0, true, 500.0);
	
	// Hook the events
	HookEvent("post_inventory_application", Event_EquipItem,  EventHookMode_Post);
	
	// Hook ConVar changes
	HookConVarChange(c_BeaconRed, ConvarChange);
	HookConVarChange(c_BeaconGreen, ConvarChange);
	HookConVarChange(c_BeaconBlue, ConvarChange);
	HookConVarChange(c_BeaconAlpha, ConvarChange);
	HookConVarChange(c_BeaconRadius, ConvarChange);
	HookConVarChange(c_BeaconInterval, ConvarChange);
	
	// Create the timer for the beacon effect
	CreateTimer(f_BeaconInterval, Timer_BeaconCheck, INVALID_HANDLE, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

// Event: Map has loaded
public OnMapStart()
{
	// Precache the necessary files
	g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
	g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
}

// Event: Player has equipped an item
public Action:Event_EquipItem(Handle:event, const String:name[], bool:dontBroadcast)
{
	// Define what the client is.
	new user = GetEventInt(event, "userid");
	new client = GetClientOfUserId(user);

	// Make sure the item we're detecting is a hat
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "tf_wearable")) != -1)
	{
		// Double check the net class to make sure it's definitely a "wearable"
		decl String:netclass[32];
		if (GetEntityNetClass(entity, netclass, sizeof(netclass)) && strcmp(netclass, "CTFWearable") == 0)
		{
			// Check to make sure the hat is indeed the Lo-Fi Longwave
			new entityindex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
			if (entityindex == 470 && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") == client)
			{
				// Instead of that old silly KnownHats check, we'll use a bool!
				g_bIsLofi[client] = true;
			}
		}
	}
	return Plugin_Continue;
}

// Function: Hook ConVar changes
public ConvarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	// Beacon radius ConVar
	if (convar == c_BeaconRadius)
	{
		f_BeaconRadius = GetConVarFloat(convar);
	}
	
	// Beacon interval ConVar
	else if (convar == c_BeaconInterval)
	{
		f_BeaconInterval = GetConVarFloat(convar);
	}
	
	// Beacon color ConVars
	g_BeaconColor[0] = GetConVarInt(c_BeaconRed);
	g_BeaconColor[1] = GetConVarInt(c_BeaconGreen);
	g_BeaconColor[2] = GetConVarInt(c_BeaconBlue);
	g_BeaconColor[3] = GetConVarInt(c_BeaconAlpha);
}

// Timer: Create the beacon effect
public Action:Timer_BeaconCheck(Handle:timer)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		// Check if the client is valid and if they are wearing a Lofi Longwave.
		if (IsValidClient(i) && g_bIsLofi[i] == true)
		{
			new Float:vec[3];
			GetClientEyePosition(i, vec);
			vec[2] += 13.0;
			TE_SetupBeamRingPoint(vec, 0.01, f_BeaconRadius, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, g_BeaconColor, 10, 0);
			TE_SendToAll();
		}
	}
	return Plugin_Continue;
}

// Function: Is client valid?
stock bool:IsValidClient(client)
{
    if (client <= 0)
	{
		return false;
	}
	
    if (client > MaxClients)
	{
		return false;
	}
	
    if (!IsClientConnected(client))
	{
		return false;
	}
    return IsClientInGame(client);
} 