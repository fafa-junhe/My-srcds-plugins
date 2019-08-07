//=============================================================================//
//
// Purpose: TF2 MIRV Grenade (Dynamite Pack)
//
//=============================================================================//
// Plugin specific
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

// Set strict semicolon mode
#pragma semicolon 1

// Define plugin version
#define PLUGIN_VERSION "1.2"

//=============================================================================
//
// Plugin info
//
public Plugin:myinfo = {
	name = "[TF2] Demoman's Dynamite Pack",
	author = "404: User Not Found",
	description = "Reintegration of the scrapped Dynamite Pack weapon for the Demoman into TF2",
	version = PLUGIN_VERSION,
	url = "http://www.unfgaming.net/404/sourcemod.html"
};

//=============================================================================
//
// TF Demoman Mirv Grenade tables.
//
#define MODEL_MIRV 			"models/tf2grenades/w_grenade_mirv.mdl"
#define MODEL_STICK 		"models/tf2grenades/w_grenade_bomblet.mdl"

// Define sounds
#define SOUND_POP 			"ambient/machines/slicer3.wav"
#define SOUND_THROW 		"weapons/grenade_throw.wav"
#define SOUND_NOTHROW		"common/wpn_denyselect.wav"

// Define sprites
#define GRENADE_TRAIL_RED 	"stunballtrail_red_crit"
#define GRENADE_TRAIL_BLU 	"stunballtrail_blue_crit"

// Convar handles, floats, defines and other such things
new Handle:g_hMIRVThrowSpeed 		= INVALID_HANDLE;
new Handle:g_hMIRVMainDetDelay 		= INVALID_HANDLE;
new Handle:g_hSticksDetDelay 		= INVALID_HANDLE;
new Handle:g_hMIRVDamage 			= INVALID_HANDLE;
new Handle:g_hStickDamage 			= INVALID_HANDLE;
new Handle:g_hMIRVStickCount 		= INVALID_HANDLE;
new Handle:g_hMIRVRadius 			= INVALID_HANDLE;
new Handle:g_hStickRadius 			= INVALID_HANDLE;
new Handle:g_hBLUSkinVersion 		= INVALID_HANDLE;
new Handle:g_hMIRVAmount 			= INVALID_HANDLE;
new Handle:g_hStickVerticalVelocity = INVALID_HANDLE;
new Handle:g_hStickSpreadVelocity 	= INVALID_HANDLE;
new Handle:g_hStickVariation 		= INVALID_HANDLE;
new Handle:g_hStickAngCalc			= INVALID_HANDLE;
new Handle:g_hTrailParticles		= INVALID_HANDLE;
new Handle:g_hHUDXPos				= INVALID_HANDLE;
new Handle:g_hHUDYPos				= INVALID_HANDLE;
new Handle:g_hHUDRed				= INVALID_HANDLE;
new Handle:g_hHUDGreen				= INVALID_HANDLE;
new Handle:g_hHUDBlue				= INVALID_HANDLE;
new Handle:g_hHUDAlpha				= INVALID_HANDLE;
new Handle:g_hToggleGFE				= INVALID_HANDLE;

new Float:g_fMIRVThrowSpeed;
new Float:g_fMIRVMainDetDelay;
new Float:g_fSticksDetDelay;
new Float:g_fStickVerticalVelocity;
new Float:g_fStickSpreadVelocity;
new Float:g_fStickVariation;
new Float:g_fHUDXPos;
new Float:g_fHUDYPos;

new Handle:MIRVHUD;

new g_iMIRVStickCount;
new g_iMIRVDamage;
new g_iStickDamage;
new g_iMIRVRadius;
new g_iStickRadius;
new g_iBLUSkinVersion;
new g_MIRVNum[MAXPLAYERS+1];
new g_iMIRVAmount;
new g_iStickAngCalc;
new g_iTrailParticles;
new g_iHUDRed;
new g_iHUDGreen;
new g_iHUDBlue;
new g_iHUDAlpha;
new g_iToggleGFE;


//-----------------------------------------------------------------------------
// Purpose: Plugin startup
//-----------------------------------------------------------------------------
public OnPluginStart()
{
	// Version ConVar
	CreateConVar("sm_mirvdemo_version", PLUGIN_VERSION, "[TF2] Meet the Dynamite Pack", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// Plugin ConVars
	g_hMIRVAmount = CreateConVar("sm_mirvdemo_spawnamount", "2", "Number of Dynamite Packs the Demoman spawns with?", _, true, 0.0, true, 10.0);
	g_hMIRVThrowSpeed = CreateConVar("sm_mirvdemo_pack_throwspeed", "500.0", "How fast is the Dynamite Pack is thrown from the player?", _, true, 0.0, true, 5000.0);
	g_hMIRVMainDetDelay = CreateConVar("sm_mirvdemo_pack_detdelay", "3.0", "Time (in seconds) before the Dynamite Pack explodes?", _, true, 1.0, true, 30.0);
	g_hMIRVRadius = CreateConVar("sm_mirvdemo_pack_radius", "198.0", "Explosion radius of the main pack explosion.\n100 is about like a normal grenade.", _, true, 0.0, true, 500.0);
	g_hMIRVDamage = CreateConVar("sm_mirvdemo_pack_damage", "180.0", "Damage magnitude of the main pack explosion.\n100 is about like a normal grenade.", _, true, 0.0, true, 500.0);
	g_hMIRVStickCount = CreateConVar("sm_mirvdemo_stickamount", "5", "How many sticks does the Dynamite Pack spawn?", _, true, 1.0, true, 10.0);
	g_hSticksDetDelay = CreateConVar("sm_mirvdemo_stick_detdelay", "2.0", "Time (in seconds) before the Dynamite sticks explode?", _, true, 1.0, true, 30.0);
	g_hStickAngCalc = CreateConVar("sm_mirvdemo_stick_angcalcmode", "1", "Which stick angle calculation method should be used?\n0 = Values that can be changed via convars\n1 = Values from 2008 TF2 source code leak", _, true, 0.0, true, 1.0);
	g_hStickVerticalVelocity = CreateConVar("sm_mirvdemo_stick_vertvel", "90.0", "How fast sticks are thrown in the air when spawned.\nRequires sm_mirvdemo_angcalcmode to be set to 0", _, true, 20.0, true, 500.0);
	g_hStickSpreadVelocity = CreateConVar("sm_mirvdemo_stick_spreadvel", "50.0", "How fast sticks spread out after they are spawned.\nRequires sm_mirvdemo_angcalcmode to be set to 0", _, true, 20.0, true, 500.0);
	g_hStickVariation = CreateConVar("sm_mirvdemo_stick_variation", "2.0", "Vertical and spread speeds will be varied between 1X and this value.\nRequires sm_mirvdemo_angcalcmode to be set to 0", _, true, 1.0, true, 5.0);
	g_hStickDamage = CreateConVar("sm_mirvdemo_stick_damage", "180.0", "Damage magnitude of each stick.\n100 is about like a normal grenade.", _, true, 0.0, true, 500.0);
	g_hStickRadius = CreateConVar("sm_mirvdemo_stick_radius", "198.0", "Explosion radius of each stick.\n100 is about like a normal grenade.", _, true, 0.0, true, 500.0);
	g_hBLUSkinVersion = CreateConVar("sm_mirvdemo_bluskinversion", "0", "Which BLU texture should be used?\n0 - Valve-made\n1 - Custom-made", _, true, 0.0, true, 1.0);
	g_hTrailParticles = CreateConVar("sm_mirvdemo_trailparticles", "1", "Enable/disable pack-attached trail particles?\n0 - Disable\n1 - Enable", _, true, 0.0, true, 1.0);
	g_hHUDXPos = CreateConVar("sm_mirvdemo_hud_xpos", "0.75", "X position for the HUD text", _, true, -1.0, true, 1.0);
	g_hHUDYPos = CreateConVar("sm_mirvdemo_hud_ypos", "0.85", "Y position for the HUD text", _, true, -1.0, true, 1.0);
	g_hHUDRed = CreateConVar("sm_mirvdemo_hud_red", "255", "Red value of HUD text", _, true, 0.0, true, 255.0);
	g_hHUDGreen = CreateConVar("sm_mirvdemo_hud_green", "255", "Green value of HUD text", _, true, 0.0, true, 255.0);
	g_hHUDBlue = CreateConVar("sm_mirvdemo_hud_blue", "255", "Blue value of HUD text", _, true, 0.0, true, 255.0);
	g_hHUDAlpha	= CreateConVar("sm_mirvdemo_hud_alpha", "255", "Alpha value of HUD text", _, true, 0.0, true, 255.0);
	g_hToggleGFE = CreateConVar("sm_mirvdemo_togglegfe", "0", "Enable/disable SetEntityGravity, m_flFriction and m_flElasticity values from the leaked source code on the main Dynamite Pack entity.", _, true, 0.0, true, 1.0);
	
	// Setup ConVar values
	g_fMIRVThrowSpeed = GetConVarFloat(g_hMIRVThrowSpeed);
	g_fMIRVMainDetDelay = GetConVarFloat(g_hMIRVMainDetDelay);
	g_fSticksDetDelay = GetConVarFloat(g_hSticksDetDelay);
	g_iMIRVStickCount = GetConVarInt(g_hMIRVStickCount);
	g_fStickVerticalVelocity = GetConVarFloat(g_hStickVerticalVelocity);
	g_fStickSpreadVelocity = GetConVarFloat(g_hStickSpreadVelocity);
	g_fStickVariation = GetConVarFloat(g_hStickVariation);
	g_iMIRVDamage = GetConVarInt(g_hMIRVDamage);
	g_iStickDamage = GetConVarInt(g_hStickDamage);
	g_iMIRVRadius = GetConVarInt(g_hMIRVRadius);
	g_iStickRadius = GetConVarInt(g_hStickRadius);
	g_iBLUSkinVersion = GetConVarInt(g_hBLUSkinVersion);
	g_iMIRVAmount = GetConVarInt(g_hMIRVAmount);
	g_iStickAngCalc = GetConVarInt(g_hStickAngCalc);
	g_iTrailParticles = GetConVarInt(g_hTrailParticles);
	g_fHUDXPos = GetConVarFloat(g_hHUDXPos);
	g_fHUDYPos = GetConVarFloat(g_hHUDYPos);
	g_iHUDRed = GetConVarInt(g_hHUDRed);
	g_iHUDGreen = GetConVarInt(g_hHUDGreen);
	g_iHUDBlue = GetConVarInt(g_hHUDBlue);
	g_iHUDAlpha = GetConVarInt(g_hHUDAlpha);
	g_iToggleGFE = GetConVarInt(g_hToggleGFE);
	
	// Hook ConVar changes
	HookConVarChange(g_hMIRVThrowSpeed, ConVarChanged);
	HookConVarChange(g_hMIRVMainDetDelay, ConVarChanged);
	HookConVarChange(g_hSticksDetDelay, ConVarChanged);
	HookConVarChange(g_hMIRVStickCount, ConVarChanged);
	HookConVarChange(g_hStickVerticalVelocity, ConVarChanged);
	HookConVarChange(g_hStickSpreadVelocity, ConVarChanged);
	HookConVarChange(g_hStickVariation, ConVarChanged);
	HookConVarChange(g_hMIRVDamage, ConVarChanged);
	HookConVarChange(g_hStickDamage, ConVarChanged);
	HookConVarChange(g_hMIRVRadius, ConVarChanged);
	HookConVarChange(g_hStickRadius, ConVarChanged);
	HookConVarChange(g_hBLUSkinVersion, ConVarChanged);
	HookConVarChange(g_hMIRVAmount, ConVarChanged);
	HookConVarChange(g_hStickAngCalc, ConVarChanged);
	HookConVarChange(g_hTrailParticles, ConVarChanged);
	HookConVarChange(g_hHUDXPos, ConVarChanged);
	HookConVarChange(g_hHUDYPos, ConVarChanged);
	HookConVarChange(g_hHUDRed, ConVarChanged);
	HookConVarChange(g_hHUDGreen, ConVarChanged);
	HookConVarChange(g_hHUDBlue, ConVarChanged);
	HookConVarChange(g_hHUDAlpha, ConVarChanged);
	HookConVarChange(g_hToggleGFE, ConVarChanged);
	
	// Register command
	RegConsoleCmd("sm_grenade2", Command_Grenade2, "Usage: sm_grenade2");
	
	// Plugin creates a config file
	AutoExecConfig(true, "TF2DynamitePack");
	
	// Hook events
	HookEvent("player_spawn", Event_Setup);
	HookEvent("post_inventory_application", Event_Setup);
	
	// Create HUD synchronizer
	MIRVHUD = CreateHudSynchronizer();
}

//-----------------------------------------------------------------------------
// Purpose: ConVar changing
//-----------------------------------------------------------------------------
public ConVarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == g_hMIRVThrowSpeed)				{ g_fMIRVThrowSpeed = StringToFloat(newValue); }
	else if (convar == g_hMIRVMainDetDelay)			{ g_fMIRVMainDetDelay = StringToFloat(newValue); }
	else if (convar == g_hSticksDetDelay)			{ g_fSticksDetDelay = StringToFloat(newValue); }
	else if (convar == g_hMIRVStickCount)			{ g_iMIRVStickCount = StringToInt(newValue); }
	else if (convar == g_hStickVerticalVelocity)	{ g_fStickVerticalVelocity = StringToFloat(newValue); }
	else if (convar == g_hStickSpreadVelocity)		{ g_fStickSpreadVelocity = StringToFloat(newValue); }
	else if (convar == g_hStickVariation)			{ g_fStickVariation = StringToFloat(newValue); }
	else if (convar == g_hMIRVDamage) 				{ g_iMIRVDamage = StringToInt(newValue); }
	else if (convar == g_hStickDamage)				{ g_iStickDamage = StringToInt(newValue); }
	else if (convar == g_hMIRVRadius) 				{ g_iMIRVRadius = StringToInt(newValue); }
	else if (convar == g_hStickRadius) 				{ g_iStickRadius = StringToInt(newValue); }
	else if (convar == g_hBLUSkinVersion) 			{ g_iBLUSkinVersion = StringToInt(newValue); }
	else if (convar == g_hMIRVAmount) 				{ g_iMIRVAmount = StringToInt(newValue); }
	else if (convar == g_hStickAngCalc)				{ g_iStickAngCalc = StringToInt(newValue); }
	else if (convar == g_hTrailParticles)			{ g_iTrailParticles = StringToInt(newValue); }
	else if (convar == g_hHUDXPos)					{ g_fHUDXPos = StringToFloat(newValue); }
	else if (convar == g_hHUDXPos)					{ g_fHUDYPos = StringToFloat(newValue); }
	else if (convar == g_hHUDRed)					{ g_iHUDRed = StringToInt(newValue); }
	else if (convar == g_hHUDGreen)					{ g_iHUDGreen = StringToInt(newValue); }
	else if (convar == g_hHUDBlue)					{ g_iHUDBlue = StringToInt(newValue); }
	else if (convar == g_hHUDAlpha)					{ g_iHUDAlpha = StringToInt(newValue); }
	else if (convar == g_hToggleGFE)				{ g_iToggleGFE = StringToInt(newValue); }
}

//-----------------------------------------------------------------------------
// Purpose: Map start event
//-----------------------------------------------------------------------------
public OnMapStart()
{
	// Add materials to downloads table
	// Yes I know, this code is bulky and can be switched to a fancier system using wildcards
	// and directory checking and what-not. I tried those methods before, and tested them out.
	// It didn't go so well. The plugin only forced the download of half the files for some reason.
	// So I'm sticking with this method.
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_red.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_red.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_blue.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_blue.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_blue_alt.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_blue_alt.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_mirv/w_grenade_mirv_normal.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_red.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_red.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_blue.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_blue.vtf");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_blue_alt.vmt");
	AddFileToDownloadsTable("materials/models/tf2grenades/w_grenade_bomblet/w_grenade_bomblet_blue_alt.vtf");
	
	// Add models to downloads table
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.dx80.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.dx90.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.mdl");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.phy");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.sw.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_mirv.vvd");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.dx80.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.dx90.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.mdl");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.phy");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.sw.vtx");
	AddFileToDownloadsTable("models/tf2grenades/w_grenade_bomblet.vvd");
	
	// Precache particle systems
	// Not sure if this actually works, saw it used in another plugin, figured I'd try it.
	PrecacheParticleSystem(GRENADE_TRAIL_RED);
	PrecacheParticleSystem(GRENADE_TRAIL_BLU);
	
	// Precache models
	PrecacheModel(MODEL_MIRV, true);
	PrecacheModel(MODEL_STICK, true);
	
	// Precache sounds
	PrecacheSound(SOUND_POP, true);
	PrecacheSound(SOUND_THROW, true);
	PrecacheSound(SOUND_NOTHROW, true);
}

//-----------------------------------------------------------------------------
// Purpose: General event for setting up the HUD text
//-----------------------------------------------------------------------------
public Event_Setup(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new TFClassType:class = TF2_GetPlayerClass(client);
	if (class == TFClass_DemoMan)
	{
		g_MIRVNum[client] = g_iMIRVAmount;
		SetHudTextParams(g_fHUDXPos, g_fHUDYPos, 100000.0, g_iHUDRed, g_iHUDGreen, g_iHUDBlue, g_iHUDAlpha, 2, 0.0, 0.0, 0.0);
		ShowSyncHudText(client, MIRVHUD, "Dynamite Packs: %i", g_MIRVNum[client]);
	}
}

//-----------------------------------------------------------------------------
// Purpose: Grenade2 command
//-----------------------------------------------------------------------------
public Action:Command_Grenade2(client, args)
{
	// Get players class, execute class-specific grenade throwing.
	new TFClassType:class = TF2_GetPlayerClass(client);
	switch(class)
	{
		// No other classes get this Dynamite pack
		// Other classes will soon get their own grenades
		// But for this plugin, only the Demoman can use this.
		// Sorry every other class :(
		// This is only in here because I'm working on more grenade plugins
		// Once I've completed more, they'll be combined into one plugin
		case TFClass_Scout, TFClass_Soldier, TFClass_Pyro, TFClass_Heavy, TFClass_Engineer, TFClass_Medic, TFClass_Sniper, TFClass_Spy:
		{
			PrintToChat(client, "[SM] Sorry, this command can only be used when playing as a Demoman.");
			return Plugin_Handled;
		}
		
		// Demoman - Dynamite Pack
		case TFClass_DemoMan:
		{
			// Is client alive and not suffering from impairing conditions? If so, proceed!
			if (IsClientAlive(client) && IsClientReady(client))
			{
				// Make sure we don't crash the map with entities
				if (GetMaxEntities() - GetEntityCount() < 200)
				{
					ThrowError("Cannot spawn Dynamite Pack, too many entities exist. Try reloading the map.");
					EmitSoundToClient(client, SOUND_NOTHROW, client, _, _, _, 1.0);
					return Plugin_Handled;
				}
				
				// Make sure the player actually has MIRVs.
				if (g_MIRVNum[client] == 0)
				{
					// PrintToChat(client, "[SM] You're out of Dynamite Packs!");
					EmitSoundToClient(client, SOUND_NOTHROW, client, _, _, _, 1.0);
					return Plugin_Handled;
				}
				
				// Get player position and angles
				decl Float:pos[3];
				decl Float:ePos[3];
				decl Float:angs[3];
				decl Float:vecs[3];			
				GetClientEyePosition(client, pos);
				GetClientEyeAngles(client, angs);
				GetAngleVectors(angs, vecs, NULL_VECTOR, NULL_VECTOR);
				
				// Check to make sure the player isn't in front of a wall
				new Handle:trace = TR_TraceRayFilterEx(pos, angs, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
				if (TR_DidHit(trace))
				{
					TR_GetEndPosition(ePos, trace);
					if (GetVectorDistance(ePos, pos, false) < 45.0)
					{
						// Player is too close to a wall
						EmitSoundToClient(client, SOUND_NOTHROW, client, _, _, _, 1.0);
						return Plugin_Handled;
					}
				}
				CloseHandle(trace);			
			
				// Set throw position to directly in front of player
				pos[0] += vecs[0] * 32.0;
				pos[1] += vecs[1] * 32.0;
				
				// Set up the throw speed
				ScaleVector(vecs, g_fMIRVThrowSpeed);

				// Create prop entity for the Dynamite Pack
				new pack = CreateEntityByName("prop_physics_override");
				if (IsValidEntity(pack))
				{					
					DispatchKeyValue(pack, "model", MODEL_MIRV);
					DispatchKeyValue(pack, "solid", "6");
					
					if(g_iToggleGFE == 1)
					{
						SetEntityGravity(pack, 0.5); // Gravity, copied over from leaked source code
						SetEntPropFloat(pack, Prop_Data, "m_flFriction", 0.8); // Friction, copied over from leaked source code
						SetEntPropFloat(pack, Prop_Send, "m_flElasticity", 0.45); // Elasticity, copied over from leaked source code
					}
					SetEntProp(pack, Prop_Data, "m_CollisionGroup", 1);
					SetEntProp(pack, Prop_Data, "m_usSolidFlags", 0x18);
					SetEntProp(pack, Prop_Data, "m_nSolidType", 6); 
						
					// Set skin and trail for each team
					if (GetClientTeam(client) == _:TFTeam_Red)
					{
						DispatchKeyValue(pack, "skin", "0");
					//	new iTrailParticles = GetConVarInt(g_hTrailParticles);
						if(g_iTrailParticles == 1)
						{
							Function_SpawnParticle(GRENADE_TRAIL_RED, 0.0, _, pack, _, _, _, _);
						}
					}
					else if (GetClientTeam(client) == _:TFTeam_Blue)
					{
						// Get optional BLU skin convar integer
						switch (g_iBLUSkinVersion)
						{
							case 0: DispatchKeyValue(pack, "skin", "1"); // Valve-made skin
							case 1: DispatchKeyValue(pack, "skin", "2"); // Custom-made skin, created by 404
						}
					//	new iTrailParticles = GetConVarInt(g_hTrailParticles);
						if(g_iTrailParticles == 1)
						{
							Function_SpawnParticle(GRENADE_TRAIL_BLU, 0.0, _, pack, _, _, _, _);
						}
					}
					DispatchKeyValue(pack, "renderfx", "0");
					DispatchKeyValue(pack, "rendercolor", "255 255 255");
					DispatchKeyValue(pack, "renderamt", "255");					
					SetEntPropEnt(pack, Prop_Data, "m_hOwnerEntity", client);
					DispatchSpawn(pack);
					TeleportEntity(pack, pos, NULL_VECTOR, vecs);
						
					CreateTimer(g_fMIRVMainDetDelay, Function_MIRVExplode, pack);
				}
				EmitSoundToAll(SOUND_THROW, client, _, _, _, 1.0);
				g_MIRVNum[client] --;
				SetHudTextParams(g_fHUDXPos, g_fHUDYPos, 100000.0, g_iHUDRed, g_iHUDGreen, g_iHUDBlue, g_iHUDAlpha, 2, 0.0, 0.0, 0.0);
				ShowSyncHudText(client, MIRVHUD, "Dynamite Packs: %i", g_MIRVNum[client]);
			}
			
			// Pack was unable to be spawned for whatever reason not covered above
			else
			{
				// Play sound, handle plugin
				EmitSoundToClient(client, SOUND_NOTHROW, client, _, _, _, 1.0);
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}

//-----------------------------------------------------------------------------
// Purpose: MIRV explosion
//-----------------------------------------------------------------------------
public Action:Function_MIRVExplode(Handle:timer, any:pack)
{
	if (IsValidEntity(pack))
	{
		// Make sure we don't crash the map with entities
		if (GetMaxEntities() - GetEntityCount() < 200)
		{
			ThrowError("Cannot spawn initial explosion, too many entities exist. Try reloading the map.");
			return Plugin_Handled;
		}
		
		decl Float:pos[3];
		GetEntPropVector(pack, Prop_Data, "m_vecOrigin", pos);
		
		// Play corny "explode" sound
		EmitAmbientSound(SOUND_POP, pos, SOUND_FROM_WORLD, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, 100, 0.0);
		
		// Raise the position up a bit
		pos[2] += 32.0;

		// Get the owner of the Dynamite Pack, and which team he's on
		new client = GetEntPropEnt(pack, Prop_Data, "m_hOwnerEntity");
		new team = GetEntProp(client, Prop_Send, "m_iTeamNum");
		
		// Kill the Dynamite Pack entity
		AcceptEntityInput(pack, "Kill");
		
		// Set up the explosion
		new explosion = CreateEntityByName("env_explosion");
		if (explosion != -1)
		{
			decl String:tMag[8];
			IntToString(g_iMIRVDamage, tMag, sizeof(tMag));
			DispatchKeyValue(explosion, "iMagnitude", tMag);
			decl String:tRad[8];
			IntToString(g_iMIRVRadius, tRad, sizeof(tRad));
			DispatchKeyValue(explosion, "iRadiusOverride", tRad);
			DispatchKeyValue(explosion, "spawnflags", "0");
			DispatchKeyValue(explosion, "rendermode", "5");
			SetEntProp(explosion, Prop_Send, "m_iTeamNum", team);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", client);
			DispatchSpawn(explosion);
			ActivateEntity(explosion);
			TeleportEntity(explosion, pos, NULL_VECTOR, NULL_VECTOR);				
			AcceptEntityInput(explosion, "Explode");
			AcceptEntityInput(explosion, "Kill");
		}
		
		
		// Spawn individual Dynamite Sticks
		decl Float:ang[3];
		for (new i = 0; i < g_iMIRVStickCount; i++)
		{
			// Make sure we don't crash the map with entities
			if (GetMaxEntities() - GetEntityCount() < 200)
			{
				ThrowError("Cannot spawn dynamite sticks, too many entities exist. Try reloading the map.");
				return Plugin_Handled;
			}
			
			// Choose which version of dynamite stick angle calculation to use
		//	new iAngCalcVersion = GetConVarInt(g_hStickAngCalc);
			if(g_iStickAngCalc == 1)
			{
				// New code with values direct from the 2008 TF2 source code leak.
				ang[0] = (GetRandomFloat(-75.0, 75.0) * 3.0);
				ang[1] = (GetRandomFloat(-75.0, 75.0) * 3.0);
				ang[2] = (GetRandomFloat(30.0, 75.0) * 5.0);
			}
			else
			{
				// Original code, decided to keep it and set up a convar to allow for switching to it
				ang[0] = ((GetURandomFloat() + 0.1) * g_fStickSpreadVelocity - g_fStickSpreadVelocity / 2.0) * ((GetURandomFloat() + 0.1) * g_fStickVariation);
				ang[1] = ((GetURandomFloat() + 0.1) * g_fStickSpreadVelocity - g_fStickSpreadVelocity / 2.0) * ((GetURandomFloat() + 0.1) * g_fStickVariation);
				ang[2] = ((GetURandomFloat() + 0.1) * g_fStickVerticalVelocity) * ((GetURandomFloat() + 0.1) * g_fStickVariation);
			}

			// Create Dynamite Stick
			new stick = CreateEntityByName("prop_physics_override");
			if (stick != -1)
			{
				DispatchKeyValue(stick, "model", MODEL_STICK);
				DispatchKeyValue(stick, "solid", "6");
				SetEntityGravity(stick, 0.5);
				SetEntPropFloat(stick, Prop_Data, "m_flFriction", 0.8);
				SetEntPropFloat(stick, Prop_Send, "m_flElasticity", 0.45);
				
				// Set skin for each team
				if (GetClientTeam(client) == _:TFTeam_Red)
				{
					DispatchKeyValue(stick, "skin", "0");
				}
				else if (GetClientTeam(client) == _:TFTeam_Blue)
				{
					// Get optional BLU skin convar integer
					switch (g_iBLUSkinVersion)
					{
						case 0: DispatchKeyValue(stick, "skin", "1"); // Valve-made skin
						case 1: DispatchKeyValue(stick, "skin", "2"); // Custom-made skin, created by 404
					}
				}
				DispatchKeyValue(stick, "renderfx", "0");
				DispatchKeyValue(stick, "rendercolor", "255 255 255");
				DispatchKeyValue(stick, "renderamt", "255");
				SetEntPropEnt(stick, Prop_Data, "m_hOwnerEntity", client);
				DispatchSpawn(stick);
				TeleportEntity(stick, pos, NULL_VECTOR, ang);
				
				// More code taken from the old source code.
				new Float:flTime = g_fSticksDetDelay + GetRandomFloat(0.0, 1.0);
				CreateTimer(flTime, Function_StickExplode, stick, TIMER_FLAG_NO_MAPCHANGE);
			}			
		}
	}
	return Plugin_Handled;
}

//-----------------------------------------------------------------------------
// Purpose: Bomblet explosion
//-----------------------------------------------------------------------------
public Action:Function_StickExplode(Handle:timer, any:stick)
{
	if (IsValidEntity(stick))
	{
		// Make sure we don't crash the map with entities
		if (GetMaxEntities() - GetEntityCount() < 200)
		{
			ThrowError("Cannot spawn dynamite stick explosions, too many entities exist. Try reloading the map.");
			return Plugin_Handled;
		}
		
		decl Float:pos[3];
		GetEntPropVector(stick, Prop_Data, "m_vecOrigin", pos);
		
		// Raise the position up a bit
		pos[2] += 32.0;

		// Get the owner of the Dynamite Pack, and which team he's on
		new client = GetEntPropEnt(stick, Prop_Data, "m_hOwnerEntity");
		new team = GetEntProp(client, Prop_Send, "m_iTeamNum");
		
		// Kill the Dynamite Stick entity
		AcceptEntityInput(stick, "Kill");
		
		// Set up the explosion
		new explosion = CreateEntityByName("env_explosion");
		if (explosion != -1)
		{
			decl String:tMag[8];
			IntToString(g_iStickDamage, tMag, sizeof(tMag));
			DispatchKeyValue(explosion, "iMagnitude", tMag);
			decl String:tRad[8];
			IntToString(g_iStickRadius, tRad, sizeof(tRad));
			DispatchKeyValue(explosion, "iRadiusOverride", tRad);
			DispatchKeyValue(explosion, "spawnflags", "0");
			DispatchKeyValue(explosion, "rendermode", "5");
			SetEntProp(explosion, Prop_Send, "m_iTeamNum", team);
			SetEntPropEnt(explosion, Prop_Data, "m_hOwnerEntity", client);
			DispatchSpawn(explosion);
			ActivateEntity(explosion);
			TeleportEntity(explosion, pos, NULL_VECTOR, NULL_VECTOR);				
			AcceptEntityInput(explosion, "Explode");
			AcceptEntityInput(explosion, "Kill");
		}		
	}
	return Plugin_Handled;
}

//=============================================================================
//
// Particle functions
//

//-----------------------------------------------------------------------------
// Purpose: Particle spawning
//-----------------------------------------------------------------------------
stock _:Function_SpawnParticle(const String:particleName[], Float:durationTime = 0.0, bool:startSpawn = true, attachEnt = 0, const String:attachBone[] = "", Float:effectPos[3] = NULL_VECTOR, Float:effectAng[3] = NULL_VECTOR, Float:effectVel[3] = NULL_VECTOR)
{
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{
		new Float:pos[3];
		new Float:ang[3];

		if (StrEqual(attachBone, ""))
		{
			GetEntPropVector(attachEnt, Prop_Send, "m_vecOrigin", pos);
			AddVectors(pos, effectPos, pos);
			GetEntPropVector(attachEnt, Prop_Send, "m_angRotation", ang);
			AddVectors(ang, effectAng, ang);
			TeleportEntity(particle, pos, ang, effectVel);
		}

		new String:tName[32];
		GetEntPropString(attachEnt, Prop_Data, "m_iName", tName, sizeof(tName));
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "parentname", tName);
		DispatchKeyValue(particle, "effect_name", particleName);
		DispatchSpawn(particle);

		if (attachEnt != 0)
		{
			SetVariantString("!activator");
			AcceptEntityInput(particle, "SetParent", attachEnt, particle, 0);
			
			if (!StrEqual(attachBone, ""))
			{
				SetVariantString(attachBone);
				AcceptEntityInput(particle, "SetParentAttachment", attachEnt, particle, 0);
				TeleportEntity(particle, effectPos, effectAng, effectVel);
			}
		}
		ActivateEntity(particle);
		
		if (startSpawn)
		{
			AcceptEntityInput(particle, "start");
		}
		
		if (durationTime > 0.0)
		{
			CreateTimer(durationTime, Timer_RemoveParticle, particle);
		}
		
		return particle;
	}
	return -1;
}

//-----------------------------------------------------------------------------
// Purpose: Particle stopping
//-----------------------------------------------------------------------------
stock Function_StopParticle(&particle)
{
	if (particle != -1)
	{
		if (IsValidEdict(particle))
		{
			new String:classname[32];
			GetEdictClassname(particle, classname, sizeof(classname));
			if (StrEqual(classname, "info_particle_system", false))
			{
				ActivateEntity(particle);
				AcceptEntityInput(particle, "stop");
			}
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: Particle deletion
//-----------------------------------------------------------------------------
stock Function_DeleteParticle(&particle, Float:delay = 0.0)
{
	if (particle != -1)
	{
		if (IsValidEdict(particle))
		{
			new String:classname[32];
			GetEdictClassname(particle, classname, sizeof(classname));
			if (StrEqual(classname, "info_particle_system", false))
			{
				ActivateEntity(particle);
				AcceptEntityInput(particle, "stop");
				CreateTimer(delay, Timer_RemoveParticle, particle);
				particle = -1;
			}
		}
	}
} 

//-----------------------------------------------------------------------------
// Purpose: Particle removal timer
//-----------------------------------------------------------------------------
public Action:Timer_RemoveParticle(Handle:timer, any:particle)
{
	if (IsValidEntity(particle))
	{
		new String:classname[32];
		GetEdictClassname(particle, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "stop");
			AcceptEntityInput(particle, "Kill");
			particle = -1;
		}
	}
}

//-----------------------------------------------------------------------------
// Purpose: Particle TraceEntity
//-----------------------------------------------------------------------------
stock TraceEntity_Particle(String:Name[], Float:origin[3]=NULL_VECTOR, Float:start[3]=NULL_VECTOR, Float:angles[3]=NULL_VECTOR, entindex=-1, attachtype=-1, attachpoint=-1, bool:resetParticles=true)
{
	// Find string table
	new tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx==INVALID_STRING_TABLE)
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}

	// Find particle index
	new String:tmp[256];
	new count = GetStringTableNumStrings(tblidx);
	new stridx = INVALID_STRING_INDEX;
	new i;
	for (i=0; i<count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx==INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", Name);
		return;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	
	if (entindex!=-1)
	{
		TE_WriteNum("entindex", entindex);
	}
	if (attachtype!=-1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	if (attachpoint!=-1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	
	TE_WriteNum("m_bResetParticles", resetParticles ? 1 : 0);
}

//-----------------------------------------------------------------------------
// Purpose: Precache particle system
//-----------------------------------------------------------------------------
stock PrecacheParticleSystem(const String:p_strEffectName[])
{
	static s_numStringTable = INVALID_STRING_TABLE;
	if (s_numStringTable == INVALID_STRING_TABLE)
	{
		s_numStringTable = FindStringTable("ParticleEffectNames");
	}
	AddToStringTable(s_numStringTable, p_strEffectName);
}

//-----------------------------------------------------------------------------
// Purpose: Trace entity, filter player
//-----------------------------------------------------------------------------
public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
}

//-----------------------------------------------------------------------------
// Purpose: Check if client is ingame and real
//-----------------------------------------------------------------------------
public bool:IsClientHere(client)
{
	if (client > 0)
	{
		if (IsClientConnected(client))
		{
			if (!IsFakeClient(client))
			{
				if (IsClientInGame(client))
				{
					return true;
				}
			}
		}
	}
	return false;
}

//-----------------------------------------------------------------------------
// Purpose: Check if client is alive
//-----------------------------------------------------------------------------
public bool:IsClientAlive(client)
{
	if (client > 0)
	{
		if (IsClientConnected(client))
		{
			if (!IsFakeClient(client))
			{
				if (IsClientInGame(client))
				{
					if (IsPlayerAlive(client))
					{
						return true;
					}
				}
			}
		}
	}
	return false;   
}

//-----------------------------------------------------------------------------
// Purpose: Check if client does not have impairing conditions
//-----------------------------------------------------------------------------
public bool:IsClientReady(client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Cloaked)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_Dazed)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_Taunting)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_Bonked)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_RestrictToMelee)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_MeleeOnly)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_HalloweenGhostMode)) { return false; }
	if (TF2_IsPlayerInCondition(client, TFCond_HalloweenKart)) { return false; }
	
	return true;   
}