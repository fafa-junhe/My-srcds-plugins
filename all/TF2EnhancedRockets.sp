#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks> // TF2 Stocks (Plus TF2 & SDKTools)

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION		"1.0"

ConVar cvEnable;
ConVar cvTeamColoredDirectHit;
ConVar cvTeamColoredRocketJumper;

public Plugin myinfo =
{
	name = "TF2: Enhanced Rockets",
	author = "404 (abrandnewday)",
	description = "Quality of life plugin that integrates Elbagast's much-requested custom TF2 rocket models to the game.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net"
};

public void OnPluginStart()
{
	CreateConVar("sm_enhancedrockets_version", PLUGIN_VERSION, "TF2: Enhanced Rockets plugin version.", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	cvEnable = CreateConVar("sm_enhancedrockets_enable", "1", "Enable Enhanced Rockets?", _, true, 0.0, true, 1.0);
	cvTeamColoredDirectHit = CreateConVar("sm_enhancedrockets_tcdirecthit", "0", "Enable team-colored Direct Hit rocket skins?", _, true, 0.0, true, 1.0);
	cvTeamColoredRocketJumper = CreateConVar("sm_enhancedrockets_tcjumper", "0", "Enable BLU cream spirit team-colored Rocket Jumper rocket skin?", _, true, 0.0, true, 1.0);
}

public void OnMapStart()
{
	// Yeah it's not pretty, but I don't give a fuck.
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit.vtf");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit_blue.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit_blue.vtf");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit_red.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_directhit_red.vtf");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.mdl");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.phy");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_directhit.vvd");
	
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_blackbox.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_blackbox.vtf");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.mdl");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.phy");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.vvd");
	
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.vtf");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper_blue.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper_blue.vtf");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.mdl");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.phy");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.vvd");
	
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.vtf");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.mdl");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.phy");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.vvd");
	
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_original.vmt");
	AddFileToDownloadsTable("materials/models/weapons/w_models/enhancedrockets/w_rocket_original.vtf");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.mdl");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.phy");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.sw.vtx");
	AddFileToDownloadsTable("models/weapons/w_models/enhancedrockets/w_rocket_original.vvd");
	
	// Precache this shit so nothing gets fucky.
	PrecacheModel("models/weapons/w_models/w_rocket.mdl", true);
	PrecacheModel("models/weapons/w_models/enhancedrockets/w_rocket_directhit.mdl", true);
	PrecacheModel("models/weapons/w_models/enhancedrockets/w_rocket_blackbox.mdl", true);
	PrecacheModel("models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.mdl", true);
	PrecacheModel("models/weapons/w_models/enhancedrockets/w_rocket_original.mdl", true);
	PrecacheModel("models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.mdl", true);
}

public void OnEntityCreated(int iEntity, const char[] strClassname)
{
	if(cvEnable)
	{
		if(StrEqual(strClassname, "tf_projectile_rocket"))
		{
			SDKHook(iEntity, SDKHook_SpawnPost, CTFProjectile_RocketSpawned);
		}
	}
}

public void CTFProjectile_RocketSpawned(int iEntity)
{
	if(IsValidEntity(iEntity))
	{
		int iClient = GetEntPropEnt(iEntity, Prop_Data, "m_hOwnerEntity");
		int iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
		int iWeaponId = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
		if(iWeapon && IsValidEdict(iWeapon))
		{
			switch(iWeaponId)
			{
				// Stock Rocket Launcher, Stock Rocket Launcher (Renamed/Strange), Festive Rocket Launcher, The Beggar's Bazooka, all the Botkiller Rocket Launchers, and all the Decorated Rocket Launchers.
				case 18, 205, 658, 730, 800, 809, 889, 898, 907, 916, 965, 974, 15006, 15014, 15028, 15043, 15052, 15057, 15081, 15104, 15015, 15129, 15130, 15150:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/w_rocket.mdl");
				}
				
				// Direct Hit
				case 127:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/enhancedrockets/w_rocket_directhit.mdl");
					
					// Team colored rockets, or nah?
					if(cvTeamColoredDirectHit.IntValue == 0)
					{
						SetEntProp(iEntity, Prop_Send, "m_nSkin", 0);
					}
					else if(cvTeamColoredDirectHit.IntValue == 1)
					{
						TFTeam iClientTeam = TF2_GetClientTeam(iClient);
						switch(iClientTeam)
						{
							case TFTeam_Red:
							{
								SetEntProp(iEntity, Prop_Send, "m_nSkin", 1);
							}
							case TFTeam_Blue:
							{
								SetEntProp(iEntity, Prop_Send, "m_nSkin", 2);
							}
						}
					}
				}
				
				// Black Box & Festive Black Box
				case 228, 1085:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/enhancedrockets/w_rocket_blackbox.mdl");
				}
				
				// Rocket Jumper
				case 237:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/enhancedrockets/w_rocket_rocketjumper.mdl");
					
					// Team colored rockets, or nah?
					if(cvTeamColoredRocketJumper.IntValue == 0)
					{
						SetEntProp(iEntity, Prop_Send, "m_nSkin", 0);
					}
					else if(cvTeamColoredRocketJumper.IntValue == 1)
					{
						TFTeam iClientTeam = TF2_GetClientTeam(iClient);
						switch(iClientTeam)
						{
							case TFTeam_Red:
							{
								SetEntProp(iEntity, Prop_Send, "m_nSkin", 0);
							}
							case TFTeam_Blue:
							{
								SetEntProp(iEntity, Prop_Send, "m_nSkin", 1);
							}
						}
					}
				}
				
				// Liberty Launcher
				case 414:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/enhancedrockets/w_rocket_libertylauncher.mdl");
				}
				
				// The Original
				case 513:
				{
					SetEntityModel(iEntity, "models/weapons/w_models/enhancedrockets/w_rocket_original.mdl");
				}
			}
		}
	}
}

stock bool IsValidClient(int iClient)
{
	if(iClient <= 0)
	{
		return false;
	}
	if(iClient > MaxClients)
	{
		return false;
	}
	return IsClientInGame(iClient);
}
