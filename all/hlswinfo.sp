#pragma semicolon 1

#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <mapchooser>

#define PL_VERSION "1.1"

public Plugin:myinfo =
{
	name        = "HLSW Info",
	author      = "Tsunami",
	description = "Shows next map and time left in HLSW.",
	version     = PL_VERSION,
	url         = "http://www.tsunami-productions.nl"
}

new bool:g_bMapChooser;
new Handle:g_hNextMap;
new Handle:g_hTimeLeft;

public OnPluginStart()
{
	CreateConVar("sm_hlswinfo_version", PL_VERSION, "Shows next map and time left in HLSW.", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	g_hNextMap    = CreateConVar("cm_nextmap",  "", "Next map in HLSW",  FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	g_hTimeLeft   = CreateConVar("cm_timeleft", "", "Time left in HLSW", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	g_bMapChooser = LibraryExists("mapchooser");
	
	CreateTimer(15.0, Timer_Update, _, TIMER_REPEAT);
	LoadTranslations("basetriggers.phrases");
}

public OnLibraryAdded(const String:name[])
{
	if(strcmp(name, "mapchooser") == 0)
		g_bMapChooser = true;
}

public OnLibraryRemoved(const String:name[])
{
	if(strcmp(name, "mapchooser") == 0)
		g_bMapChooser = false;
}

public Action:Timer_Update(Handle:timer)
{
	decl String:sNextMap[64], String:sTimeLeft[8];
	new iMins, iSecs, iTimeLeft;
	
	// Format next map
	if(g_bMapChooser && EndOfMapVoteEnabled() && !HasEndOfMapVoteFinished())
		Format(sNextMap, sizeof(sNextMap), "%t", "Pending Vote");
	else
		GetNextMap(sNextMap, sizeof(sNextMap));
	
	// Format time left
	if(GetMapTimeLeft(iTimeLeft) && iTimeLeft > 0)
	{
		iMins = iTimeLeft / 60;
		if(iTimeLeft % 60 > 30)
		{
			iMins += 1;
			iSecs  = 0;
		}
		else
			iSecs  = 30;
	}
	
	// Set next map
	SetCommandFlags("cm_nextmap",  FCVAR_PLUGIN|FCVAR_SPONLY);
	SetConVarString(g_hNextMap,    sNextMap);
	SetCommandFlags("cm_nextmap",  FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	
	// Set time left
	Format(sTimeLeft, sizeof(sTimeLeft), "%d:%02d", iMins, iSecs);
	SetCommandFlags("cm_timeleft", FCVAR_PLUGIN|FCVAR_SPONLY);
	SetConVarString(g_hTimeLeft,   sTimeLeft);
	SetCommandFlags("cm_timeleft", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
}