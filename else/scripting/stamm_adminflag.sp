/**
 * -----------------------------------------------------
 * File        stamm_adminflag.sp
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
#include <autoexecconfig>

#undef REQUIRE_PLUGIN
#include <stamm>
#include <updater>

#pragma semicolon 1




public Plugin:myinfo =
{
	name = "Stamm Feature Admin Flags",
	author = "Popoklopsi",
	version = "1.4.1",
	description = "Give VIP's Admin Flags",
	url = "https://forums.alliedmods.net/showthread.php?t=142073"
};




// Add feature
public OnAllPluginsLoaded()
{
	if (!STAMM_IsAvailable())
	{
		SetFailState("Can't Load Feature, Stamm is not installed!");
	}

	STAMM_LoadTranslation();
	STAMM_RegisterFeature("VIP Admin Flags", false);
}




// Feature loaded
public STAMM_OnFeatureLoaded(const String:basename[])
{
	decl String:theflags[64];
	decl String:urlString[256];



	Format(urlString, sizeof(urlString), "http://popoklopsi.de/stamm/updater/update.php?plugin=%s", basename);

	if (LibraryExists("updater") && STAMM_AutoUpdate())
	{
		// Add to auto updater
		Updater_AddPlugin(urlString);
		Updater_ForceUpdate();
	}



	// Get flags for each level
	for (new i=1; i <= STAMM_GetLevelCount(); i++)
	{
		Format(theflags, sizeof(theflags), "");
		
		getLevelFlag(theflags, sizeof(theflags), i);
	}
}




// Add descriptions
public STAMM_OnClientRequestFeatureInfo(client, block, &Handle:array)
{
	decl String:fmt[256];
	
	STAMM_GetBlockName(block, fmt, sizeof(fmt));
	Format(fmt, sizeof(fmt), "%T", "GetAdminFlags", client, fmt);
	
	PushArrayString(array, fmt);
}




public STAMM_OnClientReady(client)
{
	if (STAMM_IsClientValid(client))
	{
		decl String:theflags[64];
		new bytes;


		// Get Flags for client level
		Format(theflags, sizeof(theflags), "");
		getClientFlags(client, theflags, sizeof(theflags));


		if (!StrEqual(theflags, "") && theflags[0] != '\0') 
		{
			// Get bits of the string
			bytes = ReadFlagString(theflags);

			// Set flags
			if (bytes)
			{
				SetUserFlagBits(client, bytes | GetUserFlagBits(client));
			}
		}
	}
}




public STAMM_OnClientBecomeVip(client, oldlevel, newlevel)
{
	STAMM_OnClientReady(client);
}




// Read out the flags
public getLevelFlag(String:theflags[], size, level)
{
	new blocks = STAMM_GetBlockCount();


	// Do we have a file?
	if (!FileExists("cfg/stamm/features/adminflags.txt") && blocks <= 0)
	{
		SetFailState("Couldn't find any block and also 'cfg/stamm/features/adminflags.txt' doesn't exist!");

		return;
	}


	if (blocks > 0)
	{
		for (new i=1; i <= blocks; i++)
		{
			if (STAMM_GetBlockLevel(i) == level)
			{
				STAMM_GetBlockName(i, theflags, size);

				break;
			}
		}
	}
	else
	{
		new Handle:flagvalue = CreateKeyValues("AdminFlags");
		
		FileToKeyValues(flagvalue, "cfg/stamm/features/adminflags.txt");
		

		STAMM_WriteToLog(false, "Attention: Found only old AdminFlags level config. New one is in: cfg/stamm/levels/adminflags.txt!");


		// Key Value loop
		if (KvGotoFirstSubKey(flagvalue, false))
		{
			do
			{
				decl String:section[64];
				
				KvGetSectionName(flagvalue, section, sizeof(section));


				// Only Flags for specific level
				if (STAMM_GetLevelNumber(section) == level)
				{
					KvGoBack(flagvalue);
					KvGetString(flagvalue, section, theflags, size);
				}
			}
			while (KvGotoNextKey(flagvalue, false));
		}
		
		CloseHandle(flagvalue);
	}
}



// Read out the flags
public getClientFlags(client, String:theflags[], size)
{
	if (STAMM_GetBlockCount() > 0)
	{
		new block = STAMM_GetClientBlock(client);

		if (block > 0)
		{
			STAMM_GetBlockName(block, theflags, size);
		}
	}
	else
	{
		new Handle:flagvalue = CreateKeyValues("AdminFlags");
		
		FileToKeyValues(flagvalue, "cfg/stamm/features/adminflags.txt");
		

		// Key Value loop
		if (KvGotoFirstSubKey(flagvalue, false))
		{
			do
			{
				decl String:section[64];
				
				KvGetSectionName(flagvalue, section, sizeof(section));


				// Only Flags for specific level
				if (STAMM_GetLevelNumber(section) == STAMM_GetClientLevel(client))
				{
					KvGoBack(flagvalue);
					KvGetString(flagvalue, section, theflags, size);
				}
			}
			while (KvGotoNextKey(flagvalue, false));
		}
		
		CloseHandle(flagvalue);
	}
}