/**
 * -----------------------------------------------------
 * File        stamm_morespeed.sp
 * Authors     David <popoklopsi> Ordnung
 * License     GPLv3
 * Web         http://popoklopsi.de
 * -----------------------------------------------------
 * 
 * Copyright (C) 2012-2014 David <popoklopsi> Ordnung
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>
 */


// Includes
#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>

#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>

#pragma semicolon 1



new Handle:g_hSpeed;




public Plugin:myinfo =
{
	name = "Stamm Feature MoreSpeed",
	author = "Popoklopsi",
	version = "1.3.1",
	description = "Give VIP's more speed",
	url = "https://forums.alliedmods.net/showthread.php?t=142073"
};




// Add Feature
public OnAllPluginsLoaded()
{
	if (!STAMM_IsAvailable()) 
	{
		SetFailState("Can't Load Feature, Stamm is not installed!");
	}

	STAMM_LoadTranslation();
	STAMM_RegisterFeature("VIP MoreSpeed");
}




// Create config
public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);


	AutoExecConfig_SetFile("morespeed", "stamm/features");
	AutoExecConfig_SetCreateFile(true);

	g_hSpeed = AutoExecConfig_CreateConVar("speed_increase", "20", "Speed increase in percent each block!");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
}




// Auto updater and description
public STAMM_OnFeatureLoaded(const String:basename[])
{
	decl String:urlString[256];


	Format(urlString, sizeof(urlString), "http://popoklopsi.de/stamm/updater/update.php?plugin=%s", basename);


	if (LibraryExists("updater") && STAMM_AutoUpdate())
	{
		Updater_AddPlugin(urlString);
		Updater_ForceUpdate();
	}
}




// Add descriptions
public STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array)
{
	decl String:fmt[256];
	
	Format(fmt, sizeof(fmt), "%T", "GetMoreSpeed", client, GetConVarInt(g_hSpeed) * block);
	
	PushArrayString(array, fmt);
}





// Player spawned
public PlayerSpawn(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	STAMM_OnClientChangedFeature(client, true, false);
}



public STAMM_OnClientBecomeVip(client, oldlevel, newlevel)
{
	STAMM_OnClientChangedFeature(client, true, false);
}



// Client changed feature state
public STAMM_OnClientChangedFeature(client, bool:mode, bool:isShop)
{
	if (STAMM_IsClientValid(client) && IsPlayerAlive(client))
	{
		// He want more speed
		if (mode)
		{
			// Get highest client block
			new clientBlock = STAMM_GetClientBlock(client);


			// Client have block?
			if (clientBlock > 0)
			{
				// Set new speed of player
				new Float:newSpeed;
				
				newSpeed = 1.0 + float(GetConVarInt(g_hSpeed)) / 100.0 * clientBlock;
				
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", newSpeed);
			}
		}
		else
		{
			// Set default speed
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
}