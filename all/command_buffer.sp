#define PLUGIN_VERSION 		"2.1"

/*======================================================================================
	Plugin Info:

*	Name	:	[ANY] Command and ConVar - Buffer Overflow Fixer
*	Author	:	SilverShot and Peace-Maker
*	Descrp	:	Fixes incorrect ConVars values due to 'Cbuf_AddText: buffer overflow' console error on servers.
*	Plugins	:	http://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

2.1 (07-Aug-2018)
	- Added support for GoldenEye and other games using the OrangeBox engine on Windows and Linux.
	- Added support for Left4Dead2 Windows - not required from my testing on a Dedicated Server.
	- Gamedata .txt and plugin updated.

2.0.1 (02-Aug-2018)
	- Turned off debugging.

2.0 (02-Aug-2018)
	- Now fixes all ConVars from being set to incorrect values.
	- Supports CSGO (win/nix), L4D1 (win/nix) and L4D2 (nix).
	- Other games with issues please request support.

1.0 (27-Jun-2018)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

#define GAMEDATA			"command_buffer.games"
#define ARGS_BUFFER_LENGTH	8192
#define DEBUGGING			0
#if DEBUGGING
#define MAX_CVARS			5000
#endif

bool g_NextFrame;
ArrayList g_sPrimaryCmdList;
ArrayList g_sSecondaryCmdList;
char g_sCurrentCommand[ARGS_BUFFER_LENGTH];

public Plugin myinfo =
{
	name = "[ANY] Command and ConVar - Buffer Overflow Fixer",
	author = "SilverShot and Peace-Maker",
	description = "Fixes the 'Cbuf_AddText: buffer overflow' console error on servers, which causes ConVars to use their default value.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=309656"
}

public void OnPluginStart()
{
	CreateConVar("command_buffer_version", PLUGIN_VERSION, "Command and ConVar - Buffer Overflow Fixer plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_sPrimaryCmdList = new ArrayList(ByteCountToCells(ARGS_BUFFER_LENGTH));
	g_sSecondaryCmdList = new ArrayList(ByteCountToCells(ARGS_BUFFER_LENGTH));

	// ====================================================================================================
	// Detour - Anytime convars are added to the buffer this will fire
	// ====================================================================================================
	Handle hGamedata = LoadGameConfigFile(GAMEDATA);
	if( hGamedata == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	Handle hDetour = DHookCreateFromConf(hGamedata, "CCommandBuffer::InsertCommand");
	delete hGamedata;

	if( !hDetour )
		SetFailState("Failed to find \"CCommandBuffer::InsertCommand\" signature.");

	if( !DHookEnableDetour(hDetour, false, InsertCommand) )
		SetFailState("Failed to detour \"CCommandBuffer::InsertCommand\".");

	if( !DHookEnableDetour(hDetour, true, InsertCommandPost) )
		SetFailState("Failed to detour post \"CCommandBuffer::InsertCommand\".");

	// Debug
	#if DEBUGGING
		char cvar[64];
		for( int i = 0; i < MAX_CVARS; i++ )
		{
			Format(cvar, sizeof cvar, "sm_cvar_test_%d", i);
			CreateConVar(cvar, "0");
		}
		AutoExecConfig(true, "sm_cvar_test");
		RegAdminCmd("sm_cvar_test", sm_cvar_test, ADMFLAG_ROOT);
	#endif
}

#if DEBUGGING
public Action sm_cvar_test(int c, int a)
{
	int cv;
	ConVar cvar;
	char temp[64];
	for( int i = 0; i < MAX_CVARS; i++ )
	{
		Format(temp, sizeof temp, "sm_cvar_test_%d", i);
		cvar = FindConVar(temp);
		if( cvar != INVALID_HANDLE && GetConVarInt(cvar) != 1 ) cv++;
	}
	ReplyToCommand(c, "%d out of %d cvars are wrong.", cv, MAX_CVARS);
	return Plugin_Handled;
}
#endif

// ====================================================================================================
// Detour
// ====================================================================================================
public MRESReturn InsertCommand(Handle hReturn, Handle hParams)
{
	// Get command argument.
	DHookGetParamString(hParams, 1, g_sCurrentCommand, sizeof(g_sCurrentCommand));
	return MRES_Ignored;
}

public MRESReturn InsertCommandPost(Handle hReturn, Handle hParams)
{
	// See if the server was able to insert the command just fine.
	bool bSuccess = DHookGetReturn(hReturn);
	if( bSuccess )
		return MRES_Ignored;

	// The command buffer overflowed. Add the commands again on the next frame.
	if( !g_NextFrame )
	{
		g_NextFrame = true;
		RequestFrame(onNextFrame);
	}

	// Debug print
	#if DEBUGGING
		PrintToServer("Fix: [%s]", g_sCurrentCommand);
	#endif

	g_sPrimaryCmdList.PushString(g_sCurrentCommand);

	// Prevent "Cbuf_AddText: buffer overflow" message
	DHookSetReturn(hReturn, true);
	return MRES_Override;
}

// ====================================================================================================
// Reinsert the convars/commands that failed to be executed on the last frame now.
// Doesn't get called when servers hibernating, eg on first start up, until server wakes.
// ====================================================================================================
public void onNextFrame(any na)
{
	// Swap the buffers so we don't add to the list we're currently processing in our InsertServerCommand hook.
	// Executes the ConVars/commands in the order they were.
	ArrayList sCmdList = g_sPrimaryCmdList;
	g_sPrimaryCmdList = g_sSecondaryCmdList;
	g_sSecondaryCmdList = sCmdList;

	char sCommand[ARGS_BUFFER_LENGTH];
	for ( int i = 0; i < sCmdList.Length; i++ )
	{
		#if DEBUGGING
			static int g_iCount;
			PrintToServer("Ins: %d %s", g_iCount++, sCommand);
		#endif

		// Insert
		sCmdList.GetString(i, sCommand, sizeof(sCommand));
		InsertServerCommand("%s", sCommand);

		// Flush the command buffer now. Outside of loop doesn't work - the convars would remain incorrect.
		ServerExecute();
	}

	// Clean up
	sCmdList.Clear();
	g_NextFrame = false;
}