#define PLUGIN_VERSION		"1.2"

/*=======================================================================================
	Plugin Info:

*	Name	:	[ANY] Trigger Multiple Commands
*	Author	:	SilverShot
*	Descrp	:	Create trigger_multiple boxes which execute commands when entered by players.
*	Link	:	http://forums.alliedmods.net/showthread.php?t=224121
*	Plugins	:	http://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.2 (05-May-2018)
	- Converted plugin source to the latest syntax utilizing methodmaps. Requires SourceMod 1.8 or newer.

1.1y (05-Sep-2016)
	- Update by "YoNer":
	- Added code that parses the command and replaces {me} with the clients ID.
	- This makes server commands execute commands on the player that activated the trigger.

1.1 (25-Aug-2013)
	- Added command "sm_trigger_dupe" to create a trigger where you are and take the settings from another trigger.
	- Doubled the maximum string length for commands (to 128 chars).
	- Fixed the plugin not loading trigger boxes in Team Fortress 2.

1.0 (20-Aug-2013)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define	CVAR_FLAGS			FCVAR_NOTIFY
#define CHAT_TAG			"\x03[Trigger Commands] \x05"
#define CONFIG_DATA			"data/sm_trigger.cfg"
#define MAX_ENTITIES		64
#define CMD_MAX_LENGTH		512
#define MAX_TEAM			16

#define BEAM_TIME			0.3

#define REFIRE_COUNT		1
#define REFIRE_TIME			3.0
#define DELAY_TIME			0.0
#define FIRE_CHANCE			100

int g_iTeamOne = 2;
int g_iTeamTwo = 3;
char g_sTeamOne[MAX_TEAM] = "1";
char g_sTeamTwo[MAX_TEAM] = "2";


Handle g_hTimerBeam;
ConVar g_hCvarAllow, g_hCvarBeam, g_hCvarColor, g_hCvarHalo, g_hCvarModel, g_hCvarRefire;
Menu g_hMenuAuth, g_hMenuBExec, g_hMenuBots, g_hMenuChance, g_hMenuDelay, g_hMenuEdit, g_hMenuExec, g_hMenuLeave, g_hMenuPos, g_hMenuRefire, g_hMenuTeam, g_hMenuTime, g_hMenuType, g_hMenuVMaxs, g_hMenuVMins;
int g_iColors[4], g_iCvarRefire, g_iEngine, g_iHaloMaterial, g_iLaserMaterial, g_iPlayerSpawn, g_iRoundStart, g_iSelectedTrig;
bool g_bCvarAllow, g_bLoaded;

Handle g_hTimerEnable[MAX_ENTITIES];
int g_iChance[MAX_ENTITIES], g_iCmdData[MAX_ENTITIES], g_iInside[MAXPLAYERS], g_iMenuEdit[MAXPLAYERS], g_iMenuSelected[MAXPLAYERS], g_iRefireCount[MAX_ENTITIES], g_iTriggers[MAX_ENTITIES];
bool g_bStopEnd[MAX_ENTITIES];
char g_sCommand[MAX_ENTITIES][CMD_MAX_LENGTH], g_sMaterialBeam[PLATFORM_MAX_PATH], g_sMaterialHalo[PLATFORM_MAX_PATH], g_sModelBox[PLATFORM_MAX_PATH];
float g_fDelayTime[MAX_ENTITIES], g_fRefireTime[MAX_ENTITIES];

enum ()
{
	ENGINE_ANY,
	ENGINE_CSGO,
	ENGINE_CSS,
	ENGINE_L4D,
	ENGINE_L4D2,
	ENGINE_TF2,
	ENGINE_DODS,
	ENGINE_HL2MP,
	ENGINE_INS,
	ENGINE_ZPS,
	ENGINE_AOC,
	ENGINE_DM,
	ENGINE_FF,
	ENGINE_GES,
	ENGINE_HID,
	ENGINE_NTS,
	ENGINE_ND,
	ENGINE_STLS
}

enum ()
{
	ALLOW_TEAM_1		= (1 << 0),
	ALLOW_TEAM_2		= (1 << 1),
	ALLOW_TEAMS			= (1 << 2),
	ALLOW_ALIVE			= (1 << 3),
	ALLOW_DEAD			= (1 << 4),
	ALLOW_SPEC			= (1 << 5),
	ALLOW_ALL			= (1 << 6),
	ALLOW_BOTS			= (1 << 7),
	ALLOW_REAL			= (1 << 8),
	EXEC_CLIENT			= (1 << 9),
	EXEC_ALL			= (1 << 10),
	EXEC_TEAM_1			= (1 << 11),
	EXEC_TEAM_2			= (1 << 12),
	EXEC_TEAMS			= (1 << 13),
	EXEC_ALIVE			= (1 << 14),
	EXEC_DEAD			= (1 << 15),
	EXEC_BOTS			= (1 << 16),
	EXEC_REAL			= (1 << 17),
	LEAVE_NO			= (1 << 18),
	LEAVE_YES			= (1 << 19),
	COMMAND_SERVER		= (1 << 20),
	COMMAND_CLIENT		= (1 << 21),
	COMMAND_FAKE		= (1 << 22),
	FLAGS_ANY			= (1 << 23),
	FLAGS_ADMIN			= (1 << 24),
	FLAGS_CHEAT			= (1 << 25),
	FLAGS_ADMINCHEAT	= (1 << 26)
}



// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[ANY] Trigger Multiple Commands",
	author = "SilverShot, mod by YoNer",
	description = "Create trigger_multiple boxes which execute commands when entered by players.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=224121"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	char sGameName[12];
	GetGameFolderName(sGameName, sizeof(sGameName));
	// if( strcmp(sGameName, "yourgame", false) )
	// {
		// strcopy(error, err_max, "Plugin does not support yourgame.");
		// return APLRes_SilentFailure;
	// }

	if( strcmp(sGameName, "csgo", false) == 0 )					g_iEngine = ENGINE_CSGO;
	else if( strcmp(sGameName, "cstrike", false) == 0 )			g_iEngine = ENGINE_CSS;
	else if( strcmp(sGameName, "left4dead", false) == 0 )		g_iEngine = ENGINE_L4D;
	else if( strcmp(sGameName, "left4dead2", false) == 0 )		g_iEngine = ENGINE_L4D2;
	else if( strcmp(sGameName, "tf", false) == 0 )				g_iEngine = ENGINE_TF2;
	else if( strcmp(sGameName, "dod", false) == 0 )				g_iEngine = ENGINE_DODS;
	else if( strcmp(sGameName, "hl2mp", false) == 0 )			g_iEngine = ENGINE_HL2MP;
	else if( strcmp(sGameName, "ins", false) == 0 ||
			strcmp(sGameName, "insurgency", false) == 0 )		g_iEngine = ENGINE_INS;
	else if( strcmp(sGameName, "zps", false) == 0 )				g_iEngine = ENGINE_ZPS;
	else if( strcmp(sGameName, "aoc", false) == 0 )				g_iEngine = ENGINE_AOC;
	else if( strcmp(sGameName, "mmdarkmessiah", false) == 0 )	g_iEngine = ENGINE_DM;
	else if( strcmp(sGameName, "ff", false) == 0 )				g_iEngine = ENGINE_FF;
	else if( strcmp(sGameName, "gesource", false) == 0 )		g_iEngine = ENGINE_GES;
	else if( strcmp(sGameName, "hidden", false) == 0 )			g_iEngine = ENGINE_HID;
	else if( strcmp(sGameName, "nts", false) == 0 )				g_iEngine = ENGINE_NTS;
	else if( strcmp(sGameName, "nucleardawn", false) == 0 )		g_iEngine = ENGINE_ND;
	else if( strcmp(sGameName, "sgtls", false) == 0 )			g_iEngine = ENGINE_STLS;


	/* Too much missing to convert yet
	g_iEngine = ENGINE_ANY;
	EngineVersion test = GetEngineVersion();
	switch( test )
	{
		case (Engine_CSGO): g_iEngine = ENGINE_CSGO;
		case (Engine_CSS): g_iEngine = ENGINE_CSS;
		case (Engine_Left4Dead): g_iEngine = ENGINE_L4D;
		case (Engine_Left4Dead2): g_iEngine = ENGINE_L4D2;
		case (Engine_TF2): g_iEngine = ENGINE_TF2;
		case (Engine_DODS): g_iEngine = ENGINE_DODS;
		case (Engine_HL2DM): g_iEngine = ENGINE_HL2MP;

		case (Engine_Insurgency): g_iEngine = ENGINE_INS;
		// case (Engine_Z): g_iEngine = ENGINE_ZPS;
		// case (Engine_): g_iEngine = ENGINE_AOC;
		case (Engine_DarkMessiah): g_iEngine = ENGINE_DM;
		// case (Engine_): g_iEngine = ENGINE_FF;
		// case (): g_iEngine = ENGINE_GES;
		// case (Engine_): g_iEngine = ENGINE_HID;
		// case (Engine_): g_iEngine = ENGINE_NTS;
		case (Engine_NuclearDawn): g_iEngine = ENGINE_ND;
		// case (Engine_): g_iEngine = ENGINE_STLS;
	}
	// */

	return APLRes_Success;
}

public void OnPluginStart()
{
	// COMMANDS
	RegAdminCmd("sm_trigger",			CmdTriggerMenu,		ADMFLAG_ROOT,	"Displays a menu with options to edit and position triggers.");
	RegAdminCmd("sm_trigger_add",		CmdTriggerAdd,		ADMFLAG_ROOT,	"Add a command to the currently selected trigger. Usage: sm_trigger_add <command>");
	RegAdminCmd("sm_trigger_dupe",		CmdTriggerDupe,		ADMFLAG_ROOT,	"Create a trigger where you are standing and duplicate the settings from another trigger.");
	RegAdminCmd("sm_trigger_flags",		CmdTriggerFlags,	ADMFLAG_ROOT,	"Usage: sm_trigger_flags <flags>. Displays the bit sum flags (from data config), eg: sm_trigger_flags 17039624");
	RegAdminCmd("sm_trigger_reload",	CmdTriggerReload,	ADMFLAG_ROOT,	"Resets the plugin, removing all triggers and reloading the maps data config.");

	// CVARS
	g_hCvarAllow =	CreateConVar("sm_trigger_allow",		"1",									"0=Plugin off, 1=Plugin on.", CVAR_FLAGS);
	g_hCvarColor =	CreateConVar("sm_trigger_color",		"255 0 0",								"Color of the laser box when displaying the trigger. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", CVAR_FLAGS);
	g_hCvarBeam =	CreateConVar("sm_trigger_mat_beam",		"materials/sprites/laserbeam.vmt",		"Used for the laser beam to display Trigger Boxes.", CVAR_FLAGS);
	g_hCvarHalo =	CreateConVar("sm_trigger_mat_halo",		"materials/sprites/halo01.vmt",			"Used for the laser beam to display Trigger Boxes.", CVAR_FLAGS);
	g_hCvarModel =	CreateConVar("sm_trigger_model",		"models/props/cs_militia/silo_01.mdl",	"The model to use for the bounding box, the larger the better, will be invisible and is used as the maximum size for a trigger box.", CVAR_FLAGS);
	g_hCvarRefire =	CreateConVar("sm_trigger_refire",		"0",									"How does the Activate Chance affect the Refire Count when the chance fails to activate? 0=Do not add to the Refire Count. 1=Add to the Refire Count on Chance fail.", CVAR_FLAGS);
	CreateConVar("sm_trigger_version",		PLUGIN_VERSION,											"Trigger Multiple Commands plugin version.", CVAR_FLAGS|FCVAR_DONTRECORD);

	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarModel.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarBeam.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHalo.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRefire.AddChangeHook(ConVarChanged_Cvars);


	char sTemp[64];

	// Menu team names
	if( g_iEngine == ENGINE_CSGO || g_iEngine == ENGINE_CSS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Counter Terrorist");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Terrorist");
	}
	else if( g_iEngine == ENGINE_L4D || g_iEngine == ENGINE_L4D2 )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Survivor");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Infected");
	}
	else if( g_iEngine == ENGINE_TF2 || g_iEngine == ENGINE_FF )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Blu");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Red");
	}
	else if( g_iEngine == ENGINE_DODS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Allies");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Axis");
	}
	else if( g_iEngine == ENGINE_HL2MP )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Rebels");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Combine");
	}
	else if( g_iEngine == ENGINE_INS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Marines");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Insurgents");
	}
	else if( g_iEngine == ENGINE_ZPS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Survivors");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Zombies");
	}
	else if( g_iEngine == ENGINE_AOC )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Agatha Knights");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Mason Order");
	}
	else if( g_iEngine == ENGINE_DM )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Humans");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Undead");
	}
	else if( g_iEngine == ENGINE_GES )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "MI6");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Janus");
	}
	else if( g_iEngine == ENGINE_HID )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Hidden");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "IRIS");
	}
	else if( g_iEngine == ENGINE_NTS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "NSF");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Jinrai");
	}
	else if( g_iEngine == ENGINE_ND )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Consortium");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Empire");
	}
	else if( g_iEngine == ENGINE_STLS )
	{
		Format(g_sTeamOne, sizeof(g_sTeamOne), "Tauri");
		Format(g_sTeamTwo, sizeof(g_sTeamTwo), "Goauld");
	}


	// MENUS
	g_hMenuEdit = new Menu(EditMenuHandler);
	g_hMenuEdit.AddItem("", "Type Of Command To Exec");
	g_hMenuEdit.AddItem("", "Command Flags (Admin/Cheat)");
	g_hMenuEdit.AddItem("", "Who Can Activate");
	g_hMenuEdit.AddItem("", "Who Executes The Command");
	g_hMenuEdit.AddItem("", "Refire Count");
	g_hMenuEdit.AddItem("", "Refire Time");
	g_hMenuEdit.AddItem("", "Command Delay");
	g_hMenuEdit.AddItem("", "Activate Chance");
	g_hMenuEdit.AddItem("", "Leave Box");
	g_hMenuEdit.SetTitle("TMC: Edit Options");
	g_hMenuEdit.ExitBackButton = true;

	g_hMenuType = new Menu(DataMenuHandler);
	g_hMenuType.AddItem("", "Server Command (executes the command on the server)");
	g_hMenuType.AddItem("", "Client Command (executes the command client side)");
	g_hMenuType.AddItem("", "Fake Client Command (executes the command on the server as if the client had sent)");
	g_hMenuType.SetTitle("TMC: Command Type\nWhich type of command do you want to execute?");
	g_hMenuType.ExitBackButton = true;

	g_hMenuAuth = new Menu(DataMenuHandler);
	g_hMenuAuth.AddItem("", "Standard");
	g_hMenuAuth.AddItem("", "Remove Cheat Flags");
	g_hMenuAuth.AddItem("", "Execute as Root Admin");
	g_hMenuAuth.AddItem("", "Execute as Root Admin and Remove Cheat Flags");
	g_hMenuAuth.SetTitle("TMC: Command Flags\nDo you want to remove the cheat flag and/or give the user Root admin rights when executing the command?");
	g_hMenuAuth.ExitBackButton = true;

	g_hMenuTeam = new Menu(DataMenuHandler);
	g_hMenuTeam.AddItem("", "Alive Players");
	Format(sTemp, sizeof(sTemp), "Team %s", g_sTeamOne);
	g_hMenuTeam.AddItem("", sTemp);
	Format(sTemp, sizeof(sTemp), "Team %s", g_sTeamTwo);
	g_hMenuTeam.AddItem("", sTemp);
	Format(sTemp, sizeof(sTemp), "Team %s + %s", g_sTeamOne, g_sTeamTwo);
	g_hMenuTeam.AddItem("", sTemp);
	g_hMenuTeam.AddItem("", "Dead Players");
	g_hMenuTeam.AddItem("", "Spectators");
	g_hMenuTeam.AddItem("", "All Players");
	g_hMenuTeam.SetTitle("TMC: Who Activates the Trigger");
	g_hMenuTeam.ExitBackButton = true;

	g_hMenuBots = new Menu(DataMenuHandler);
	g_hMenuBots.AddItem("", "All");
	g_hMenuBots.AddItem("", "Only Humans");
	g_hMenuBots.AddItem("", "Only Bots");
	g_hMenuBots.SetTitle("TMC: Who Activates the Trigger");
	g_hMenuBots.ExitBackButton = true;

	g_hMenuExec = new Menu(DataMenuHandler);
	g_hMenuExec.AddItem("", "Activator Only");
	g_hMenuExec.AddItem("", "Everyone");
	Format(sTemp, sizeof(sTemp), "Team %s", g_sTeamOne);
	g_hMenuExec.AddItem("", sTemp);
	Format(sTemp, sizeof(sTemp), "Team %s", g_sTeamTwo);
	g_hMenuExec.AddItem("", sTemp);
	Format(sTemp, sizeof(sTemp), "Team %s + %s", g_sTeamOne, g_sTeamTwo);
	g_hMenuExec.AddItem("", sTemp);
	g_hMenuExec.AddItem("", "Alive Players");
	g_hMenuExec.AddItem("", "Dead Players");
	g_hMenuExec.SetTitle("TMC: Command Execute\nDo you want the command to run on all players or only the activator?");
	g_hMenuExec.ExitBackButton = true;

	g_hMenuBExec = new Menu(DataMenuHandler);
	g_hMenuBExec.AddItem("", "All");
	g_hMenuBExec.AddItem("", "Only Humans");
	g_hMenuBExec.AddItem("", "Only Bots");
	g_hMenuBExec.SetTitle("TMC: Who To Execute On");
	g_hMenuBExec.ExitBackButton = true;

	g_hMenuRefire = new Menu(RefireMenuHandler);
	g_hMenuRefire.AddItem("0", "Unlimited");
	g_hMenuRefire.AddItem("-", "- 1");
	g_hMenuRefire.AddItem("+", "+ 1");
	g_hMenuRefire.AddItem("1", "1");
	g_hMenuRefire.AddItem("2", "2");
	g_hMenuRefire.AddItem("3", "3");
	g_hMenuRefire.AddItem("4", "4");
	g_hMenuRefire.AddItem("5", "5");
	g_hMenuRefire.AddItem("10", "10");
	g_hMenuRefire.AddItem("15", "15");
	g_hMenuRefire.AddItem("20", "20");
	g_hMenuRefire.AddItem("25", "25");
	g_hMenuRefire.AddItem("30", "30");
	g_hMenuRefire.AddItem("50", "50");
	g_hMenuRefire.SetTitle("TMC: Refire Count\nHow many times can the trigger be activated");
	g_hMenuRefire.ExitBackButton = true;

	g_hMenuTime = new Menu(TimeMenuHandler);
	g_hMenuTime.AddItem("0.5", "0.5 (minimum)");
	g_hMenuTime.AddItem("-", "- 1.0");
	g_hMenuTime.AddItem("+", "+ 1.0");
	g_hMenuTime.AddItem("1.0", "1.0");
	g_hMenuTime.AddItem("1.5", "1.5");
	g_hMenuTime.AddItem("2.0", "2.0");
	g_hMenuTime.AddItem("5.0", "5.0");
	g_hMenuTime.AddItem("10.0", "10.0");
	g_hMenuTime.AddItem("15.0", "15.0");
	g_hMenuTime.AddItem("20.0", "20.0");
	g_hMenuTime.AddItem("25.0", "25.0");
	g_hMenuTime.AddItem("30.0", "30.0");
	g_hMenuTime.AddItem("45.0", "45.0");
	g_hMenuTime.AddItem("60.0", "60.0");
	g_hMenuTime.SetTitle("TMC: Refire Time\nHow soon after the trigger is activated to re-enable the trigger");
	g_hMenuTime.ExitBackButton = true;

	g_hMenuDelay = new Menu(DelayMenuHandler);
	g_hMenuDelay.AddItem("0.0", "Instant - No delay");
	g_hMenuDelay.AddItem("-", "- 1.0");
	g_hMenuDelay.AddItem("+", "+ 1.0");
	g_hMenuDelay.AddItem("0.5", "0.5");
	g_hMenuDelay.AddItem("1.0", "1.0");
	g_hMenuDelay.AddItem("2.0", "2.0");
	g_hMenuDelay.AddItem("3.0", "3.0");
	g_hMenuDelay.AddItem("5.0", "5.0");
	g_hMenuDelay.AddItem("10.0", "10.0");
	g_hMenuDelay.AddItem("15.0", "15.0");
	g_hMenuDelay.AddItem("20.0", "20.0");
	g_hMenuDelay.AddItem("25.0", "25.0");
	g_hMenuDelay.AddItem("30.0", "30.0");
	g_hMenuDelay.AddItem("45.0", "45.0");
	g_hMenuDelay.SetTitle("TMC: Command Delay\nExecute the command instantly after triggering or set delay in seconds");
	g_hMenuDelay.ExitBackButton = true;

	g_hMenuChance = new Menu(ChanceMenuHandler);
	g_hMenuChance.AddItem("100", "Always 100%");
	g_hMenuChance.AddItem("95", "95%");
	g_hMenuChance.AddItem("90", "90%");
	g_hMenuChance.AddItem("80", "80%");
	g_hMenuChance.AddItem("75", "75%");
	g_hMenuChance.AddItem("50", "50%");
	g_hMenuChance.AddItem("30", "30%");
	g_hMenuChance.AddItem("25", "25%");
	g_hMenuChance.AddItem("20", "20%");
	g_hMenuChance.AddItem("15", "15%");
	g_hMenuChance.AddItem("10", "10%");
	g_hMenuChance.AddItem("5", "5%");
	g_hMenuChance.AddItem("3", "3%");
	g_hMenuChance.AddItem("1", "1%");
	g_hMenuChance.SetTitle("TMC: Activate Chance\nDo you want this trigger to always fire or based on random chance?");
	g_hMenuChance.ExitBackButton = true;

	g_hMenuLeave = new Menu(DataMenuHandler);
	g_hMenuLeave.AddItem("", "Yes");
	g_hMenuLeave.AddItem("", "No");
	g_hMenuLeave.SetTitle("TMC: Leave Box\nShould clients have to leave the trigger box before they can activate it again?");
	g_hMenuLeave.ExitBackButton = true;

	g_hMenuVMaxs = new Menu(VMaxsMenuHandler);
	g_hMenuVMaxs.AddItem("", "10 x 10 x 100");
	g_hMenuVMaxs.AddItem("", "25 x 25 x 100");
	g_hMenuVMaxs.AddItem("", "50 x 50 x 100");
	g_hMenuVMaxs.AddItem("", "100 x 100 x 100");
	g_hMenuVMaxs.AddItem("", "150 x 150 x 100");
	g_hMenuVMaxs.AddItem("", "200 x 200 x 100");
	g_hMenuVMaxs.AddItem("", "250 x 250 x 100");
	g_hMenuVMaxs.SetTitle("TMC: VMaxs");
	g_hMenuVMaxs.ExitBackButton = true;

	g_hMenuVMins = new Menu(VMinsMenuHandler);
	g_hMenuVMins.AddItem("", "-10 x -10 x 0");
	g_hMenuVMins.AddItem("", "-25 x -25 x 0");
	g_hMenuVMins.AddItem("", "-50 x -50 x 0");
	g_hMenuVMins.AddItem("", "-100 x -100 x 0");
	g_hMenuVMins.AddItem("", "-150 x -150 x 0");
	g_hMenuVMins.AddItem("", "-200 x -200 x 0");
	g_hMenuVMins.AddItem("", "-250 x -250 x 0");
	g_hMenuVMins.SetTitle("TMC: VMins");
	g_hMenuVMins.ExitBackButton = true;

	g_hMenuPos = new Menu(PosMenuHandler);
	g_hMenuPos.AddItem("", "X + 1.0");
	g_hMenuPos.AddItem("", "Y + 1.0");
	g_hMenuPos.AddItem("", "Z + 1.0");
	g_hMenuPos.AddItem("", "X - 1.0");
	g_hMenuPos.AddItem("", "Y - 1.0");
	g_hMenuPos.AddItem("", "Z - 1.0");
	g_hMenuPos.AddItem("", "SAVE");
	g_hMenuPos.SetTitle("TMC: Origin");
	g_hMenuPos.ExitBackButton = true;
}

public void OnPluginEnd()
{
	ResetPlugin();
}

public void OnMapStart()
{
	GetCvars();
	if( strcmp(g_sMaterialBeam, "") ) g_iLaserMaterial = PrecacheModel(g_sMaterialBeam);
	if( strcmp(g_sMaterialHalo, "") ) g_iHaloMaterial = PrecacheModel(g_sMaterialHalo);
	if( strcmp(g_sModelBox, "") ) PrecacheModel(g_sModelBox, true);
}

public void OnMapEnd()
{
	ResetPlugin();
}

void ResetPlugin()
{
	g_iSelectedTrig = 0;
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	g_bLoaded = false;

	for( int i = 0; i < MAXPLAYERS; i++ )
	{
		g_iMenuSelected[i] = 0;
		g_iMenuEdit[i] = 0;
		g_iInside[i] = 0;
	}

	for( int i = 0; i < MAX_ENTITIES; i++ )
	{
		g_bStopEnd[i] = false;
		g_iChance[i] = FIRE_CHANCE;
		g_iRefireCount[i] = REFIRE_COUNT;
		g_fRefireTime[i] = REFIRE_TIME;
		g_fDelayTime[i] = DELAY_TIME;

		if( IsValidEntRef(g_iTriggers[i]) ) AcceptEntityInput(g_iTriggers[i], "Kill");
		g_iTriggers[i] = 0;

		if( g_hTimerEnable[i] != null ) delete g_hTimerEnable[i];
	}
}



// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	GetColor(g_hCvarColor);
	g_hCvarModel.GetString(g_sModelBox, sizeof(g_sModelBox));
	g_hCvarBeam.GetString(g_sMaterialBeam, sizeof(g_sMaterialBeam));
	g_hCvarHalo.GetString(g_sMaterialHalo, sizeof(g_sMaterialHalo));
	g_iCvarRefire = g_hCvarRefire.IntValue;
}

void GetColor(ConVar cvar)
{
	char sTemp[12], sColors[3][4];
	cvar.GetString(sTemp, sizeof(sTemp));
	ExplodeString(sTemp, " ", sColors, 3, 4);

	g_iColors[0] = StringToInt(sColors[0]);
	g_iColors[1] = StringToInt(sColors[1]);
	g_iColors[2] = StringToInt(sColors[2]);
	g_iColors[3] = 255;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true )
	{
		g_bCvarAllow = true;

		HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);

		if( g_iEngine == ENGINE_TF2 )
		{
			HookEvent("teamplay_round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
			HookEvent("stats_resetround",			Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEvent("teamplay_round_win",			Event_RoundEnd,		EventHookMode_PostNoCopy);
			HookEvent("teamplay_win_panel",			Event_RoundEnd,		EventHookMode_PostNoCopy);
		} else {
			HookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
			HookEvent("round_end",					Event_RoundEnd,		EventHookMode_PostNoCopy);
		}

		LoadDataConfig();
	}

	else if( g_bCvarAllow == true && bCvarAllow == false )
	{
		ResetPlugin();
		g_bCvarAllow = false;

		UnhookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);

		if( g_iEngine == ENGINE_TF2 )
		{
			UnhookEvent("teamplay_round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
			UnhookEvent("stats_resetround",			Event_RoundEnd,		EventHookMode_PostNoCopy);
			UnhookEvent("teamplay_round_win",		Event_RoundEnd,		EventHookMode_PostNoCopy);
			UnhookEvent("teamplay_win_panel",		Event_RoundEnd,		EventHookMode_PostNoCopy);
		} else {
			UnhookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
			UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
		}
	}
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 ) CreateTimer(1.0, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 ) CreateTimer(1.0, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public Action tmrStart(Handle timer)
{
	LoadDataConfig();
}



// ====================================================================================================
//					LOAD
// ====================================================================================================
void LoadDataConfig()
{
	if( g_bLoaded == true ) return;
	g_bLoaded = true;

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_DATA);
	if( !FileExists(sPath) ) return;

	KeyValues hFile = new KeyValues("triggers");
	hFile.SetEscapeSequences(true);
	hFile.ImportFromFile(sPath);

	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

	if( !hFile.JumpToKey(sMap) )
	{
		delete hFile;
		return;
	}

	char sTemp[16];
	float vPos[3], vMax[3], vMin[3];

	for( int i = 0; i < MAX_ENTITIES; i++ )
	{
		IntToString(i+1, sTemp, sizeof(sTemp));

		if( hFile.JumpToKey(sTemp, false) )
		{
			// TRIGGER BOXES
			hFile.GetVector("vpos", vPos);
			if( vPos[0] != 0.0 && vPos[1] != 0.0 && vPos[2] != 0.0 )
			{
				hFile.GetVector("vmin", vMin);
				hFile.GetVector("vmax", vMax);
				g_iChance[i] = hFile.GetNum("chance", FIRE_CHANCE);
				g_iRefireCount[i] = hFile.GetNum("refire_count", REFIRE_COUNT);
				g_fRefireTime[i] = hFile.GetFloat("refire_time", REFIRE_TIME);
				g_fDelayTime[i] = hFile.GetFloat("delay_time", DELAY_TIME);
				hFile.GetString("command", g_sCommand[i], CMD_MAX_LENGTH);
				g_iCmdData[i] = hFile.GetNum("data", 1);
				if( g_iCmdData[i] & LEAVE_NO != LEAVE_NO && g_iCmdData[i] & LEAVE_YES != LEAVE_YES )
				{
					g_iCmdData[i] = g_iCmdData[i] | LEAVE_YES;
				}

				CreateTriggerMultiple(i, vPos, vMax, vMin, true);
			}

			hFile.GoBack();
		}
	}

	delete hFile;
}



// ====================================================================================================
//					COMMAND - RELOAD
// ====================================================================================================
public Action CmdTriggerReload(int client, int args)
{
	g_bCvarAllow = false;
	ResetPlugin();
	GetCvars();
	IsAllowed();
	if( client )	PrintToChat(client, "%sPlugin reset.", CHAT_TAG);
	else			PrintToConsole(client, "[Trigger Commands] Plugin reset.");
	return Plugin_Handled;
}



// ====================================================================================================
//					COMMAND - FLAGS
// ====================================================================================================
public Action CmdTriggerDupe(int client, int args)
{
	ShowMenuTrigList(client, 7);
	return Plugin_Handled;
}



// ====================================================================================================
//					COMMAND - FLAGS
// ====================================================================================================
public Action CmdTriggerFlags(int client, int args)
{
	char sTemp[256];
	GetCmdArg(1, sTemp, sizeof(sTemp));
	int flags = StringToInt(sTemp);

	GetFlags(flags, sTemp, sizeof(sTemp));

	if( client )	PrintToChat(client, sTemp);
	else			PrintToConsole(client, sTemp);

	return Plugin_Handled;
}

void GetFlags(int flags, char[] sTemp, int size)
{
	Format(sTemp, size, "");
	if( flags & ALLOW_TEAM_1 ==		ALLOW_TEAM_1 )		StrCat(sTemp, size, "ALLOW_TEAM_1|");
	if( flags & ALLOW_TEAM_2 ==		ALLOW_TEAM_2 )		StrCat(sTemp, size, "ALLOW_TEAM_2|");
	if( flags & ALLOW_TEAMS ==		ALLOW_TEAMS )		StrCat(sTemp, size, "ALLOW_TEAMS|");
	if( flags & ALLOW_ALIVE ==		ALLOW_ALIVE )		StrCat(sTemp, size, "ALLOW_ALIVE|");
	if( flags & ALLOW_DEAD ==		ALLOW_DEAD )		StrCat(sTemp, size, "ALLOW_DEAD|");
	if( flags & ALLOW_SPEC ==		ALLOW_SPEC )		StrCat(sTemp, size, "ALLOW_SPEC|");
	if( flags & ALLOW_ALL ==		ALLOW_ALL )			StrCat(sTemp, size, "ALLOW_ALL|");
	if( flags & ALLOW_BOTS ==		ALLOW_BOTS )		StrCat(sTemp, size, "ALLOW_BOTS|");
	if( flags & ALLOW_REAL ==		ALLOW_REAL )		StrCat(sTemp, size, "ALLOW_REAL|");
	if( flags & EXEC_CLIENT ==		EXEC_CLIENT )		StrCat(sTemp, size, "EXEC_CLIENT|");
	if( flags & EXEC_ALL ==			EXEC_ALL )			StrCat(sTemp, size, "EXEC_ALL|");
	if( flags & EXEC_TEAM_1 ==		EXEC_TEAM_1 )		StrCat(sTemp, size, "EXEC_TEAM_1|");
	if( flags & EXEC_TEAM_2 ==		EXEC_TEAM_2 )		StrCat(sTemp, size, "EXEC_TEAM_2|");
	if( flags & EXEC_TEAMS ==		EXEC_TEAMS )		StrCat(sTemp, size, "EXEC_TEAMS|");
	if( flags & EXEC_ALIVE ==		EXEC_ALIVE )		StrCat(sTemp, size, "EXEC_ALIVE|");
	if( flags & EXEC_DEAD ==		EXEC_DEAD )			StrCat(sTemp, size, "EXEC_DEAD|");
	if( flags & EXEC_BOTS ==		EXEC_BOTS )			StrCat(sTemp, size, "EXEC_BOTS|");
	if( flags & EXEC_REAL ==		EXEC_REAL )			StrCat(sTemp, size, "EXEC_REAL|");
	if( flags & LEAVE_NO ==			LEAVE_NO )			StrCat(sTemp, size, "LEAVE_NO|");
	if( flags & LEAVE_YES ==		LEAVE_YES )			StrCat(sTemp, size, "LEAVE_YES|");
	if( flags & COMMAND_SERVER ==	COMMAND_SERVER )	StrCat(sTemp, size, "COMMAND_SERVER|");
	if( flags & COMMAND_CLIENT ==	COMMAND_CLIENT )	StrCat(sTemp, size, "COMMAND_CLIENT|");
	if( flags & COMMAND_FAKE ==		COMMAND_FAKE )		StrCat(sTemp, size, "COMMAND_FAKE|");
	if( flags & FLAGS_ANY ==		FLAGS_ANY )			StrCat(sTemp, size, "FLAGS_ANY|");
	if( flags & FLAGS_ADMIN ==		FLAGS_ADMIN )		StrCat(sTemp, size, "FLAGS_ADMIN|");
	if( flags & FLAGS_CHEAT ==		FLAGS_CHEAT )		StrCat(sTemp, size, "FLAGS_CHEAT|");
	if( flags & FLAGS_ADMINCHEAT ==	FLAGS_ADMINCHEAT )	StrCat(sTemp, size, "FLAGS_ADMINCHEAT|");

	int len = strlen(sTemp);
	if( len > 1 ) sTemp[len-1] = '\x0';
}



// ====================================================================================================
//					COMMANDS
// ====================================================================================================
public Action CmdTriggerAdd(int client, int args)
{
	if( client == 0 )
	{
		PrintToConsole(client, "[Trigger Commands] This command can only be used in-game on a dedicated server.");
		return Plugin_Handled;
	}

	char sCmd[256];
	GetCmdArgString(sCmd, sizeof(sCmd));

	StripQuotes(sCmd);

	CreateTrigger(client, sCmd);

	g_iMenuEdit[client] = 0;

	g_hMenuType.ExitBackButton = false;
	g_hMenuType.Display(client, MENU_TIME_FOREVER);

	PrintToChat(client, "%sIf you exit the menu, the trigger you are adding will be deleted.", CHAT_TAG);
	return Plugin_Handled;
}

public Action CmdTriggerMenu(int client, int args)
{
	if( client == 0 )
	{
		PrintToConsole(client, "[Trigger Commands] This command can only be used in-game on a dedicated server.");
		return Plugin_Handled;
	}

	ShowMainMenu(client);
	return Plugin_Handled;
}



// ====================================================================================================
//					MENUS
// ====================================================================================================
void ShowMainMenu(int client)
{
	g_iMenuEdit[client] = 0;

	Menu hMenu = new Menu(TrigMenuHandler);

	if( g_hTimerBeam == null )	hMenu.AddItem("1", "Show");
	else									hMenu.AddItem("1", "Hide");
	hMenu.AddItem("2", "Edit Trigger");
	hMenu.AddItem("3", "Set VMaxs");
	hMenu.AddItem("4", "Set VMins");
	hMenu.AddItem("5", "Set Origin");
	hMenu.AddItem("6", "Go To Trigger");
	hMenu.AddItem("7", "Delete");
	hMenu.SetTitle("TMC - Trigger Box:");
	hMenu.ExitButton = true;

	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int TrigMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_End )
	{
		delete menu;
	}
	else if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		if( index == 0 )
		{
			if( g_hTimerBeam != null )
			{
				delete g_hTimerBeam;
				g_iSelectedTrig = 0;
			}
			ShowMenuTrigList(client, index);
		}
		else
		{
			ShowMenuTrigList(client, index);
		}
	}
}

void ShowMenuTrigList(int client, int index)
{
	g_iMenuSelected[client] = index;

	int count;
	Menu hMenu = new Menu(TrigListMenuHandler);
	char sIndex[8], sTemp[64];

	g_iMenuEdit[client] = 0;

	for( int i = 0; i < MAX_ENTITIES; i++ )
	{
		if( IsValidEntRef(g_iTriggers[i]) == true )
		{
			count++;
			Format(sTemp, sizeof(sTemp), "Trigger %d (%s)", i+1, g_sCommand[i]);

			IntToString(i, sIndex, sizeof(sIndex));
			hMenu.AddItem(sIndex, sTemp);
		}
	}

	if( count == 0 )
	{
		PrintToChat(client, "%sError: No saved Triggers were found. Create a new one using the command sm_trigger_add.", CHAT_TAG);
		delete hMenu;
		ShowMainMenu(client);
		return;
	}

	if( index == 0 )		hMenu.SetTitle("TMC: Trigger Box - Show:");
	else if( index == 1 )	hMenu.SetTitle("TMC: Trigger Box - Edit Options:");
	else if( index == 2 )	hMenu.SetTitle("TMC: Trigger Box - Maxs:");
	else if( index == 3 )	hMenu.SetTitle("TMC: Trigger Box - Mins:");
	else if( index == 4 )	hMenu.SetTitle("TMC: Trigger Box - Origin:");
	else if( index == 5 )	hMenu.SetTitle("TMC: Trigger Box - Go To:");
	else if( index == 6 )	hMenu.SetTitle("TMC: Trigger Box - Delete:");
	else if( index == 7 )	hMenu.SetTitle("TMC: Trigger Box - Duplicate:");

	hMenu.ExitBackButton = true;
	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int TrigListMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_End )
	{
		delete menu;
	}
	else if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		int type = g_iMenuSelected[client];
		char sTemp[4];
		menu.GetItem(index, sTemp, sizeof(sTemp));
		index = StringToInt(sTemp);

		if( type == 0 )
		{
			g_iSelectedTrig = g_iTriggers[index];

			if( IsValidEntRef(g_iSelectedTrig) )	g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
			else									g_iSelectedTrig = 0;

			ShowMainMenu(client);
		}
		else if( type == 1 )
		{
			g_iMenuSelected[client] = index;
			g_hMenuEdit.Display(client, MENU_TIME_FOREVER);

			int flags = g_iCmdData[index];
			char sFlags[256];
			GetFlags(flags, sFlags, sizeof(sFlags));
			PrintToChat(client, "%sCurrent flags: (%d) %s", CHAT_TAG, flags, sFlags);
		}
		else if( type == 2 )
		{
			g_iMenuSelected[client] = index;
			g_hMenuVMaxs.Display(client, MENU_TIME_FOREVER);
		}
		else if( type == 3 )
		{
			g_iMenuSelected[client] = index;
			g_hMenuVMins.Display(client, MENU_TIME_FOREVER);
		}
		else if( type == 4 )
		{
			g_iMenuSelected[client] = index;
			g_hMenuPos.Display(client, MENU_TIME_FOREVER);
		}
		else if( type == 5 )
		{
			int trigger = g_iTriggers[index];
			if( IsValidEntRef(trigger) )
			{
				float vPos[3];
				GetEntPropVector(trigger, Prop_Send, "m_vecOrigin", vPos);

				if( vPos[0] == 0.0 && vPos[1] == 0.0 && vPos[2] == 0.0 )
				{
					PrintToChat(client, "%sCannot teleport you, the Target Zone is missing.", CHAT_TAG);
				}
				else
				{
					vPos[2] += 10.0;
					TeleportEntity(client, vPos, NULL_VECTOR, NULL_VECTOR);
				}
			}
			ShowMainMenu(client);
		}
		else if( type == 6 )
		{
			DeleteTrigger(client, index+1);
			ShowMainMenu(client);
		}
		else if( type == 7 )
		{
			DupeTrigger(client, index);
			ShowMainMenu(client);
		}
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - EDIT OPTIONS
// ====================================================================================================
public int EditMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		g_iMenuEdit[client] = index + 1;

		if( index == 0 )
		{
			g_hMenuType.ExitButton = true;
			g_hMenuType.ExitBackButton = true;
			g_hMenuType.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 1 )
		{
			g_hMenuAuth.ExitButton = true;
			g_hMenuAuth.ExitBackButton = true;
			g_hMenuAuth.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 2 )
		{
			g_hMenuTeam.ExitButton = true;
			g_hMenuTeam.ExitBackButton = true;
			g_hMenuTeam.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 3 )
		{
			g_hMenuExec.ExitButton = true;
			g_hMenuExec.ExitBackButton = true;
			g_hMenuExec.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 4 )
		{
			g_hMenuRefire.ExitBackButton = true;
			g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 5 )
		{
			g_hMenuTime.ExitBackButton = true;
			g_hMenuTime.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 6 )
		{
			g_hMenuDelay.ExitBackButton = true;
			g_hMenuDelay.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 7 )
		{
			g_hMenuChance.ExitBackButton = true;
			g_hMenuChance.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 8 )
		{
			g_hMenuLeave.ExitBackButton = true;
			g_hMenuLeave.Display(client, MENU_TIME_FOREVER);
		}
	}
}



// ====================================================================================================
//					MENU - DATA HANDLER
// ====================================================================================================
public int DataMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
		else if( index == MenuCancel_Exit && g_iMenuEdit[client] == 0 )	KillTriggerCreation(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];

		KeyValues hFile = ConfigOpen();

		if( hFile != null )
		{
			char sTemp[64];
			GetCurrentMap(sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) == true )
			{
				IntToString(cfgindex+1, sTemp, sizeof(sTemp));

				if( hFile.JumpToKey(sTemp) == true )
				{
					int data = hFile.GetNum("data", 0);
					bool show = false;

					if( menu == g_hMenuType )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~COMMAND_SERVER;
							data &= ~COMMAND_CLIENT;
							data &= ~COMMAND_FAKE;
						} else {
							data = 0; // Setting up trigger, clear data for first time menu.
						}

						switch (index)
						{
							case 0: data |= COMMAND_SERVER;
							case 1: data |= COMMAND_CLIENT;
							case 2: data |= COMMAND_FAKE;
						}

						if( g_iMenuEdit[client] == 0 )
						{
							g_hMenuAuth.ExitBackButton = false;
							g_hMenuAuth.Display(client, MENU_TIME_FOREVER);
						}
					}
					else if( menu == g_hMenuAuth )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~FLAGS_ANY;
							data &= ~FLAGS_CHEAT;
							data &= ~FLAGS_ADMIN;
							data &= ~FLAGS_ADMINCHEAT;
						}

						switch (index)
						{
							case 0: data |= FLAGS_ANY;
							case 1: data |= FLAGS_CHEAT;
							case 2: data |= FLAGS_ADMIN;
							case 3: data |= FLAGS_ADMINCHEAT;
						}

						if( g_iMenuEdit[client] == 0 )
						{
							g_hMenuTeam.ExitBackButton = false;
							g_hMenuTeam.Display(client, MENU_TIME_FOREVER);
						} else {
							g_hMenuRefire.ExitBackButton = false;
							g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
						}
					}
					else if( menu == g_hMenuTeam )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~ALLOW_ALIVE;
							data &= ~ALLOW_TEAM_1;
							data &= ~ALLOW_TEAM_2;
							data &= ~ALLOW_TEAMS;
							data &= ~ALLOW_DEAD;
							data &= ~ALLOW_SPEC;
							data &= ~ALLOW_ALL;
						}

						switch (index)
						{
							case 0: data |= ALLOW_ALIVE;
							case 1: data |= ALLOW_TEAM_1;
							case 2: data |= ALLOW_TEAM_2;
							case 3: data |= ALLOW_TEAMS;
							case 4: data |= ALLOW_DEAD;
							case 5: data |= ALLOW_SPEC;
							case 6: data |= ALLOW_ALL;
						}

						show = true;
						g_hMenuBots.ExitBackButton = false;
						g_hMenuBots.Display(client, MENU_TIME_FOREVER);
					}
					else if( menu == g_hMenuBots )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~ALLOW_REAL;
							data &= ~ALLOW_BOTS;
						}

						switch (index)
						{
							case 1: data |= ALLOW_REAL;
							case 2: data |= ALLOW_BOTS;
						}

						if( data & COMMAND_SERVER != COMMAND_SERVER )
						{
							if( g_iMenuEdit[client] == 0 )
							{
								g_hMenuExec.ExitBackButton = false;
								g_hMenuExec.Display(client, MENU_TIME_FOREVER);
							}
						}
						else
						{
							if( g_iMenuEdit[client] == 0 )
							{
								g_hMenuRefire.ExitBackButton = false;
								g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
							}
						}
					}
					else if( menu == g_hMenuExec )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~EXEC_CLIENT;
							data &= ~EXEC_ALL;
							data &= ~EXEC_TEAM_1;
							data &= ~EXEC_TEAM_2;
							data &= ~EXEC_TEAMS;
							data &= ~EXEC_ALIVE;
							data &= ~EXEC_DEAD;
						}

						switch (index)
						{
							case 0: data |= EXEC_CLIENT;
							case 1: data |= EXEC_ALL;
							case 2: data |= EXEC_TEAM_1;
							case 3: data |= EXEC_TEAM_2;
							case 4: data |= EXEC_TEAMS;
							case 5: data |= EXEC_ALIVE;
							case 6: data |= EXEC_DEAD;
						}

						if( !(data & EXEC_CLIENT == EXEC_CLIENT) )
						{
							show = true;
							g_hMenuBExec.ExitBackButton = false;
							g_hMenuBExec.Display(client, MENU_TIME_FOREVER);
						}
						else
						{
							if( g_iMenuEdit[client] == 0 )
							{
								g_hMenuRefire.ExitBackButton = false;
								g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
							}
						}
					}
					else if( menu == g_hMenuBExec )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~EXEC_REAL;
							data &= ~EXEC_BOTS;
						}

						switch (index)
						{
							case 0: data |= EXEC_REAL;
							case 1: data |= EXEC_BOTS;
						}

						if( g_iMenuEdit[client] == 0 )
						{
							g_hMenuRefire.ExitBackButton = false;
							g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
						}
					}
					else if( menu == g_hMenuLeave )
					{
						if( g_iMenuEdit[client] )
						{
							data &= ~LEAVE_YES;
							data &= ~LEAVE_NO;
						}

						switch (index)
						{
							case 0: data |= LEAVE_YES;
							case 1: data |= LEAVE_NO;
						}


						if( g_iMenuEdit[client] == 0 )
						{
							PrintToChat(client, "%sAll done, your trigger has been setup!", CHAT_TAG);

							int entity = g_iTriggers[cfgindex];
							if( IsValidEntRef(entity) )	AcceptEntityInput(entity, "Enable");

							ShowMainMenu(client);

							if( g_hTimerBeam != null )
							{
								delete g_hTimerBeam;
								g_iSelectedTrig = 0;
							}
						}
					}

					g_iCmdData[cfgindex] = data;
					hFile.SetNum("data", data);
					ConfigSave(hFile);

					if( g_iMenuEdit[client] )
					{
						if( !show )
							g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
						PrintToChat(client, "%sTrigger options modified and saved!", CHAT_TAG);

						char sFlags[256];
						GetFlags(data, sFlags, sizeof(sFlags));
						PrintToChat(client, "%sCurrent flags: (%d) %s", CHAT_TAG, data, sFlags);
					}
				}
			}

			delete hFile;
		}
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - REFIRE COUNT
// ====================================================================================================
public int RefireMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
		else if( index == MenuCancel_Exit && g_iMenuEdit[client] == 0 )	KillTriggerCreation(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];

		int value;
		if( index == 1 )		value = g_iRefireCount[cfgindex] - 1;
		else if( index == 2 )	value = g_iRefireCount[cfgindex] + 1;
		else
		{
			char sMenu[8];
			menu.GetItem(index, sMenu, sizeof(sMenu));
			value = StringToInt(sMenu);
		}
		if( value < 0 )			value = 0;

		if( g_iMenuEdit[client] == 0 && (index == 1 || index == 2) )
		{
			PrintToChat(client, "%sCannot select + or - when setting up, please choose a default value.", CHAT_TAG);
			g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
			return;
		}


		KeyValues hFile = ConfigOpen();

		if( hFile != null )
		{
			char sTemp[64];
			GetCurrentMap(sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) == true )
			{
				IntToString(cfgindex+1, sTemp, sizeof(sTemp));

				if( hFile.JumpToKey(sTemp) == true )
				{
					int trigger = g_iTriggers[cfgindex];
					g_iRefireCount[cfgindex] = value;
					hFile.SetNum("refire_count", value);
					PrintToChat(client, "%sSet trigger box '\x03%d\x05' refire count to \x03%d", CHAT_TAG, cfgindex+1, value);

					if( g_iMenuEdit[client] != 0 && IsValidEntRef(trigger) && GetEntProp(trigger, Prop_Data, "m_iHammerID") <= value )
					{
						AcceptEntityInput(trigger, "Enable");
						g_bStopEnd[cfgindex] = false;
					}

					ConfigSave(hFile);
				}
			}

			delete hFile;
		}

		if( g_iMenuEdit[client] == 0 )
		{
			if( value == 1 )
			{
				g_hMenuDelay.ExitBackButton = false;
				g_hMenuDelay.Display(client, MENU_TIME_FOREVER);
			}
			else
			{
				g_hMenuTime.ExitBackButton = false;
				g_hMenuTime.Display(client, MENU_TIME_FOREVER);
			}
		}
		else if( index == 1 || index == 2 ) g_hMenuRefire.Display(client, MENU_TIME_FOREVER);
		else g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - REFIRE TIME
// ====================================================================================================
public int TimeMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
		else if( index == MenuCancel_Exit && g_iMenuEdit[client] == 0 )	KillTriggerCreation(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];

		float value;
		if( index == 1 )		value = g_fRefireTime[cfgindex] - 1.0;
		else if( index == 2 )	value = g_fRefireTime[cfgindex] + 1.0;
		else
		{
			char sMenu[8];
			menu.GetItem(index, sMenu, sizeof(sMenu));
			value = StringToFloat(sMenu);
		}
		if( value < 0.5 )		value = 0.5;

		if( g_iMenuEdit[client] == 0 && (index == 1 || index == 2) )
		{
			PrintToChat(client, "%sCannot select + or - when setting up, please choose a default value.", CHAT_TAG);
			g_hMenuTime.Display(client, MENU_TIME_FOREVER);
			return;
		}


		KeyValues hFile = ConfigOpen();

		if( hFile != null )
		{
			char sTemp[64];
			GetCurrentMap(sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) == true )
			{
				IntToString(cfgindex+1, sTemp, sizeof(sTemp));

				if( hFile.JumpToKey(sTemp) == true )
				{
					g_fRefireTime[cfgindex] = value;
					hFile.SetFloat("refire_time", value);
					PrintToChat(client, "%sSet trigger box '\x03%d\x05' refire time to \x03%0.1f", CHAT_TAG, cfgindex+1, value);

					ConfigSave(hFile);
				}
			}

			delete hFile;
		}

		if( g_iMenuEdit[client] == 0 )
		{
			g_hMenuDelay.ExitBackButton = false;
			g_hMenuDelay.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 1 || index == 2 ) g_hMenuTime.Display(client, MENU_TIME_FOREVER);
		else g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - REFIRE TIME
// ====================================================================================================
public int DelayMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
		else if( index == MenuCancel_Exit && g_iMenuEdit[client] == 0 )	KillTriggerCreation(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];

		float value;
		if( index == 1 )		value = g_fDelayTime[cfgindex] - 1.0;
		else if( index == 2 )	value = g_fDelayTime[cfgindex] + 1.0;
		else
		{
			char sMenu[8];
			menu.GetItem(index, sMenu, sizeof(sMenu));
			value = StringToFloat(sMenu);
		}
		if( value < 0.0 )		value = 0.0;

		if( g_iMenuEdit[client] == 0 && (index == 1 || index == 2) )
		{
			PrintToChat(client, "%sCannot select + or - when setting up, please choose a default value.", CHAT_TAG);
			g_hMenuDelay.Display(client, MENU_TIME_FOREVER);
			return;
		}


		KeyValues hFile = ConfigOpen();

		if( hFile != null )
		{
			char sTemp[64];
			GetCurrentMap(sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) == true )
			{
				IntToString(cfgindex+1, sTemp, sizeof(sTemp));

				if( hFile.JumpToKey(sTemp) == true )
				{
					if( value == 0.0 )
					{
						g_fDelayTime[cfgindex] = value;
						hFile.SetFloat("delay_time", value);
						PrintToChat(client, "%sSet trigger box '\x03%d\x05' delay time to no delay. Executes the command without delay.", CHAT_TAG, cfgindex+1);
					}
					else
					{
						g_fDelayTime[cfgindex] = value;
						hFile.SetFloat("delay_time", value);
						PrintToChat(client, "%sSet trigger box '\x03%d\x05' delay time to \x03%0.1f", CHAT_TAG, cfgindex+1, value);

						ConfigSave(hFile);
					}
				}
			}

			delete hFile;
		}

		if( g_iMenuEdit[client] == 0 )
		{
			g_hMenuChance.ExitBackButton = false;
			g_hMenuChance.Display(client, MENU_TIME_FOREVER);
		}
		else if( index == 1 || index == 2 ) g_hMenuDelay.Display(client, MENU_TIME_FOREVER);
		else g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - FIRE CHANCE
// ====================================================================================================
public int ChanceMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
		else if( index == MenuCancel_Exit && g_iMenuEdit[client] == 0 )	KillTriggerCreation(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];

		int value;
		char sMenu[8];
		menu.GetItem(index, sMenu, sizeof(sMenu));
		value = StringToInt(sMenu);


		KeyValues hFile = ConfigOpen();

		if( hFile != null )
		{
			char sTemp[64];
			GetCurrentMap(sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) == true )
			{
				IntToString(cfgindex+1, sTemp, sizeof(sTemp));

				if( hFile.JumpToKey(sTemp) == true )
				{
					g_iChance[cfgindex] = value;
					hFile.SetNum("chance", value);
					PrintToChat(client, "%sSet trigger box '\x03%d\x05' chance to \x03%d\%", CHAT_TAG, cfgindex+1, value);
					ConfigSave(hFile);
				}
			}

			delete hFile;
		}

		if( g_iMenuEdit[client] == 0 )
		{
			if( g_iRefireCount[cfgindex] == 1 )
			{
				PrintToChat(client, "%sAll done, your trigger has been setup!", CHAT_TAG);

				int entity = g_iTriggers[cfgindex];
				if( IsValidEntRef(entity) )	AcceptEntityInput(entity, "Enable");

				ShowMainMenu(client);

				if( g_hTimerBeam != null )
				{
					delete g_hTimerBeam;
					g_iSelectedTrig = 0;
				}
			}
			else
			{
				g_hMenuLeave.ExitBackButton = false;
				g_hMenuLeave.Display(client, MENU_TIME_FOREVER);
			}
		}
		else g_hMenuEdit.Display(client, MENU_TIME_FOREVER);
	}
}



// ====================================================================================================
//					MENU - TRIGGER BOX - VMINS/VMAXS/VPOS - CALLBACKS
// ====================================================================================================
public int VMaxsMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		float vVec[3];

		if( index == 0 )		vVec = view_as<float>({ 10.0, 10.0, 100.0 });
		else if( index == 1 )	vVec = view_as<float>({ 25.0, 25.0, 100.0 });
		else if( index == 2 )	vVec = view_as<float>({ 50.0, 50.0, 100.0 });
		else if( index == 3 )	vVec = view_as<float>({ 100.0, 100.0, 100.0 });
		else if( index == 4 )	vVec = view_as<float>({ 150.0, 150.0, 100.0 });
		else if( index == 5 )	vVec = view_as<float>({ 200.0, 200.0, 100.0 });
		else if( index == 6 )	vVec = view_as<float>({ 300.0, 300.0, 100.0 });

		int cfgindex = g_iMenuSelected[client];
		int trigger = g_iTriggers[cfgindex];

		SaveTrigger(null, client, cfgindex + 1, "vmax", vVec);

		if( IsValidEntRef(trigger) )
		{
			SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", vVec);

			g_iSelectedTrig = trigger;
			if( g_hTimerBeam == null )	g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
		}

		g_hMenuVMaxs.Display(client, MENU_TIME_FOREVER);
	}
}

public int VMinsMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		float vVec[3];

		if( index == 0 )		vVec = view_as<float>({ -10.0, -10.0, -100.0 });
		else if( index == 1 )	vVec = view_as<float>({ -25.0, -25.0, -100.0 });
		else if( index == 2 )	vVec = view_as<float>({ -50.0, -50.0, -100.0 });
		else if( index == 3 )	vVec = view_as<float>({ -100.0, -100.0, -100.0 });
		else if( index == 4 )	vVec = view_as<float>({ -150.0, -150.0, -100.0 });
		else if( index == 5 )	vVec = view_as<float>({ -200.0, -200.0, -100.0 });
		else if( index == 6 )	vVec = view_as<float>({ -300.0, -300.0, -100.0 });

		int cfgindex = g_iMenuSelected[client];
		int trigger = g_iTriggers[cfgindex];

		SaveTrigger(null, client, cfgindex + 1, "vmin", vVec);

		if( IsValidEntRef(trigger) )
		{
			SetEntPropVector(trigger, Prop_Send, "m_vecMins", vVec);

			g_iSelectedTrig = trigger;
			if( g_hTimerBeam == null )	g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
		}

		g_hMenuVMins.Display(client, MENU_TIME_FOREVER);
	}
}

public int PosMenuHandler(Menu menu, MenuAction action, int client, int index)
{
	if( action == MenuAction_Cancel )
	{
		if( index == MenuCancel_ExitBack )	ShowMainMenu(client);
	}
	else if( action == MenuAction_Select )
	{
		int cfgindex = g_iMenuSelected[client];
		int trigger = g_iTriggers[cfgindex];

		if( IsValidEntRef(trigger) )
		{
			float vPos[3];
			GetEntPropVector(trigger, Prop_Send, "m_vecOrigin", vPos);

			if( index == 0 )			vPos[0] += 1.0;
			else if( index == 1 )		vPos[1] += 1.0;
			else if( index == 2 )		vPos[2] += 1.0;
			else if( index == 3 )		vPos[0] -= 1.0;
			else if( index == 4 )		vPos[1] -= 1.0;
			else if( index == 5 )		vPos[2] -= 1.0;

			if( index != 6 )	TeleportEntity(trigger, vPos, NULL_VECTOR, NULL_VECTOR);
			else				SaveTrigger(null, client, cfgindex + 1, "vpos", vPos);

			g_iSelectedTrig = trigger;
			if( g_hTimerBeam == null )	g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
		} else {
			PrintToChat(client, "%sError: Trigger (%d) not found.", cfgindex);
		}

		g_hMenuPos.Display(client, MENU_TIME_FOREVER);
	}
}



// ====================================================================================================
//					TRIGGER BOX - SAVE / DELETE / DUPE
// ====================================================================================================
void SaveTrigger(KeyValues hOpen, int client, int index, char[] sKey, float vVec[3])
{
	KeyValues hFile;
	if( hOpen == null ) hFile = ConfigOpen();
	else hFile = hOpen;

	if( hFile != null )
	{
		char sTemp[64];
		GetCurrentMap(sTemp, sizeof(sTemp));
		if( hFile.JumpToKey(sTemp, true) )
		{
			IntToString(index, sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp, true) )
			{
				hFile.SetVector(sKey, vVec);

				ConfigSave(hFile);

				if( client )	PrintToChat(client, "%s\x01(\x05%d\x01) - Saved trigger '%s'.", CHAT_TAG, index, sKey);
			}
			else if( client )
			{
				PrintToChat(client, "%s\x01(\x05%d\x01) - Failed to save trigger(A) '%s'.", CHAT_TAG, index, sKey);
			}
		}
		else if( client )
		{
			PrintToChat(client, "%s\x01(\x05%d\x01) - Failed to save trigger(B) '%s'.", CHAT_TAG, index, sKey);
		}

		if( hOpen == null ) delete hFile;
	}
}

void SaveData(KeyValues hOpen, int client, int index, char[] sKey, char[] sVal)
{
	KeyValues hFile;
	if( hOpen == null ) hFile = ConfigOpen();
	else hFile = hOpen;

	if( hFile != null )
	{
		char sTemp[64];
		GetCurrentMap(sTemp, sizeof(sTemp));
		if( hFile.JumpToKey(sTemp, true) )
		{
			IntToString(index, sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp, true) )
			{
				hFile.SetString(sKey, sVal);

				ConfigSave(hFile);

				if( client )	PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Saved trigger '%s'.", CHAT_TAG, index, MAX_ENTITIES, sKey);
			}
			else if( client )
			{
				PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Failed to save trigger(C) '%s'.", CHAT_TAG, index, MAX_ENTITIES, sKey);
			}
		}
		else if( client )
		{
			PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Failed to save trigger(D) '%s'.", CHAT_TAG, index, MAX_ENTITIES, sKey);
		}

		if( hOpen == null ) delete hFile;
	}
}

void DeleteTrigger(int client, int cfgindex)
{
	KeyValues hFile = ConfigOpen();

	if( hFile != null )
	{
		char sMap[64];
		GetCurrentMap(sMap, sizeof(sMap));

		if( hFile.JumpToKey(sMap) )
		{
			char sTemp[16];
			IntToString(cfgindex, sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp) )
			{
				if( IsValidEntRef(g_iTriggers[cfgindex-1]) )	AcceptEntityInput(g_iTriggers[cfgindex-1], "Kill");
				g_iTriggers[cfgindex-1] = 0;

				hFile.DeleteKey("vpos");
				hFile.DeleteKey("vmax");
				hFile.DeleteKey("vmin");
				hFile.DeleteKey("data");
				hFile.DeleteKey("command");
				hFile.DeleteKey("chance");
				hFile.DeleteKey("refire_count");
				hFile.DeleteKey("refire_time");
				hFile.DeleteKey("delay_time");

				float vPos[3];
				hFile.GetVector("pos", vPos);

				hFile.GoBack();

				if( vPos[0] == 0.0 && vPos[1] == 0.0 && vPos[2] == 0.0 )
				{
					for( int i = cfgindex; i < MAX_ENTITIES; i++ )
					{
						g_iTriggers[i-1] = g_iTriggers[i];
						g_iTriggers[i] = 0;

						g_bStopEnd[i-1] = g_bStopEnd[i];
						g_bStopEnd[i] = false;

						g_iRefireCount[i-1] = g_iRefireCount[i];
						g_iRefireCount[i] = REFIRE_COUNT;

						g_fRefireTime[i-1] = g_fRefireTime[i];
						g_fRefireTime[i] = REFIRE_TIME;

						g_fDelayTime[i-1] = g_fDelayTime[i];
						g_fDelayTime[i] = DELAY_TIME;

						g_iChance[i-1] = g_iChance[i];
						g_iChance[i] = FIRE_CHANCE;

						g_iCmdData[i-1] = g_iCmdData[i];
						g_iCmdData[i] = 0;

						g_hTimerEnable[i-1] = g_hTimerEnable[i];
						g_hTimerEnable[i] = null;

						strcopy(g_sCommand[i-1], CMD_MAX_LENGTH, g_sCommand[i]);
						strcopy(g_sCommand[i], CMD_MAX_LENGTH, "");


						IntToString(i+1, sTemp, sizeof(sTemp));

						if( hFile.JumpToKey(sTemp) )
						{
							IntToString(i, sTemp, sizeof(sTemp));
							hFile.SetSectionName(sTemp);
							hFile.GoBack();
						}
					}
				}

				ConfigSave(hFile);

				PrintToChat(client, "%sTrigger removed from config.", CHAT_TAG);
			}
		}

		delete hFile;
	}
}

void KillTriggerCreation(int client)
{
	int cfgindex = g_iMenuSelected[client] + 1;
	DeleteTrigger(client, cfgindex);
	PrintToChat(client, "%sYou exited the menu, the trigger '\x03%d\x05' you were creating has been deleted from the config.", CHAT_TAG, cfgindex);
}


void DupeTrigger(int client, int cfgindex)
{

	int index = -1;

	for( int i = 0; i < MAX_ENTITIES; i++ )
	{
		if( IsValidEntRef(g_iTriggers[i]) == false )
		{
			index = i;
			break;
		}
	}

	if( index == -1 )
	{
		PrintToChat(client, "%sError: Cannot create a new group, too many placed (Limit: %d). Replace/delete triggers.", CHAT_TAG, MAX_ENTITIES);
		return;
	}


	strcopy(g_sCommand[index], CMD_MAX_LENGTH, g_sCommand[cfgindex]);
	g_iRefireCount[index] = g_iRefireCount[cfgindex];
	g_fRefireTime[index] = g_fRefireTime[cfgindex];
	g_fDelayTime[index] = g_fDelayTime[cfgindex];
	g_iChance[index] = g_iChance[cfgindex];
	g_iCmdData[index] = g_iCmdData[cfgindex];
	g_hTimerEnable[index] = null;
	g_bStopEnd[index] = false;

	float vPos[3];
	GetClientAbsOrigin(client, vPos);

	CreateTriggerMultiple(index, vPos, view_as<float>({ 25.0, 25.0, 100.0}), view_as<float>({ -25.0, -25.0, 0.0 }), true);

	KeyValues hFile = ConfigOpen();
	if( hFile != null )
	{
		char sTemp[64];
		GetCurrentMap(sTemp, sizeof(sTemp));
		if( hFile.JumpToKey(sTemp, true) )
		{
			IntToString(index+1, sTemp, sizeof(sTemp));

			if( hFile.JumpToKey(sTemp, true) )
			{
				hFile.SetVector("vpos", vPos);
				hFile.SetVector("vmax", view_as<float>({ 25.0, 25.0, 100.0}));
				hFile.SetVector("vmin", view_as<float>({ -25.0, -25.0, 0.0 }));
				hFile.SetString("command", g_sCommand[index]);
				hFile.SetNum("refire_count", g_iRefireCount[index]);
				hFile.SetFloat("refire_time", g_fRefireTime[index]);
				hFile.SetFloat("delay_time", g_fDelayTime[index]);
				hFile.SetNum("chance", g_iChance[index]);
				hFile.SetNum("data", g_iCmdData[index]);

				ConfigSave(hFile);

				PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Saved duplicated trigger.", CHAT_TAG, index+1, MAX_ENTITIES, cfgindex+1);
			}
			else
			{
				PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Failed to dupe trigger(A) '%d'.", CHAT_TAG, index+1, MAX_ENTITIES, cfgindex+1);
			}
		}
		else
		{
			PrintToChat(client, "%s\x01(\x05%d/%d\x01) - Failed to dupe trigger(B) '%d'.", CHAT_TAG, index+1, MAX_ENTITIES, cfgindex+1);
		}

		delete hFile;
	} else {
		LogError("Error opening config(A)? %s", CONFIG_DATA);
		PrintToChat(client, "%sFailed to save data(A), check your data config file.", CHAT_TAG);
	}

	g_iSelectedTrig = g_iTriggers[index];

	if( g_hTimerBeam == null )
		g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
}



// ====================================================================================================
//					TRIGGER BOX - SPAWN TRIGGER / TOUCH CALLBACK
// ====================================================================================================
void CreateTrigger(int client, char[] sCmd)
{
	int index = -1;

	for( int i = 0; i < MAX_ENTITIES; i++ )
	{
		if( IsValidEntRef(g_iTriggers[i]) == false )
		{
			index = i;
			break;
		}
	}

	if( index == -1 )
	{
		PrintToChat(client, "%sError: Cannot create a new group, too many placed (Limit: %d). Replace/delete triggers.", CHAT_TAG, MAX_ENTITIES);
		return;
	}

	float vPos[3];
	GetClientAbsOrigin(client, vPos);

	strcopy(g_sCommand[index], CMD_MAX_LENGTH, sCmd);
	g_iMenuSelected[client] = index;
	g_iSelectedTrig = g_iTriggers[index];
	g_iChance[index] = FIRE_CHANCE;
	g_iRefireCount[index] = REFIRE_COUNT;
	g_fRefireTime[index] = REFIRE_TIME;
	g_fDelayTime[index] = DELAY_TIME;
	g_bStopEnd[index] = false;

	CreateTriggerMultiple(index, vPos, view_as<float>({ 25.0, 25.0, 100.0}), view_as<float>({ -25.0, -25.0, 0.0 }), false);
	index += 1;

	KeyValues hFile = ConfigOpen();
	if( hFile != null )
	{
		SaveTrigger(hFile, client, index, "vpos", vPos);
		SaveTrigger(hFile, client, index, "vmax", view_as<float>({ 25.0, 25.0, 100.0}));
		SaveTrigger(hFile, client, index, "vmin", view_as<float>({ -25.0, -25.0, 0.0 }));
		SaveData(hFile, client, index, "command", sCmd);
		delete hFile;
	} else {
		LogError("Error opening config(B)? %s", CONFIG_DATA);
		PrintToChat(client, "%sFailed to save data(B), check your data config file.", CHAT_TAG);
	}

	if( g_hTimerBeam == null )
		g_hTimerBeam = CreateTimer(BEAM_TIME, TimerBeam, _, TIMER_REPEAT);
}

void CreateTriggerMultiple(int index, float vPos[3], float vMaxs[3], float vMins[3], bool autoload)
{
	int trigger = CreateEntityByName("trigger_multiple");
	DispatchKeyValue(trigger, "StartDisabled", "1");
	DispatchKeyValue(trigger, "spawnflags", "1");
	SetEntityModel(trigger, g_sModelBox);
	TeleportEntity(trigger, vPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(trigger);
	SetEntPropVector(trigger, Prop_Send, "m_vecMaxs", vMaxs);
	SetEntPropVector(trigger, Prop_Send, "m_vecMins", vMins);
	SetEntProp(trigger, Prop_Send, "m_nSolidType", 2);

	if( autoload )
	{
		AcceptEntityInput(trigger, "Enable");
	} else {
		g_iSelectedTrig = EntIndexToEntRef(trigger);
	}

	HookSingleEntityOutput(trigger, "OnStartTouch", OnStartTouch);
	HookSingleEntityOutput(trigger, "OnEndTouch", OnEndTouch);
	g_iTriggers[index] = EntIndexToEntRef(trigger);
}

public Action TimerEnable(Handle timer, any index)
{
	g_hTimerEnable[index] = null;
	g_bStopEnd[index] = false;

	if( g_iCmdData[index] & LEAVE_NO == LEAVE_NO )
	{
		int trigger = g_iTriggers[index];
		if( IsValidEntRef(trigger) )
		{
			AcceptEntityInput(trigger, "Enable");
		}
	}
}

public void OnEndTouch(const char[] output, int caller, int activator, float delay)
{
	if( activator > 0 && activator <= MaxClients ) g_iInside[activator] = 0;
}

public void OnStartTouch(const char[] output, int caller, int activator, float delay)
{
	if( IsClientInGame(activator) )
	{
		caller = EntIndexToEntRef(caller);

		for( int i = 0; i < MAX_ENTITIES; i++ )
		{
			if( caller == g_iTriggers[i] )
			{
				if( g_bStopEnd[i] == false )
				{
					bool executed = false;
					int data = g_iCmdData[i];

					// Require users to leave the box before re-trigger
					if( data & LEAVE_NO != LEAVE_NO && g_iInside[activator] == caller ) return;

					g_iInside[activator] = caller;

					if( !(data & ALLOW_ALL == ALLOW_ALL) )
					{
						bool alive = IsPlayerAlive(activator);
						if( data & ALLOW_ALIVE == ALLOW_ALIVE && !alive ) return;
						if( data & ALLOW_DEAD == ALLOW_DEAD && alive ) return;

						int team = GetClientTeam(activator);
						if( data & ALLOW_SPEC == ALLOW_SPEC && team != 1 ) return;
						if( data & ALLOW_TEAMS == ALLOW_TEAMS && team == 1 ) return;
						if( data & ALLOW_TEAM_1 == ALLOW_TEAM_1 && team != 2 ) return;
						if( data & ALLOW_TEAM_2 == ALLOW_TEAM_2 && team != 3 ) return;
					}

					bool bot = IsFakeClient(activator);
					if( data & ALLOW_BOTS == ALLOW_BOTS && !bot ) return;
					if( data & ALLOW_REAL == ALLOW_REAL && bot ) return;

					int chance = g_iChance[i];
					if( chance == 100 || GetRandomInt(0, 100) <= chance ) // Chance to exec
					{
						g_bStopEnd[i] = true;

						if( g_iRefireCount[i] == 0 ) // Unlimited refires, create timer to enable the trigger.
						{
							executed = true;
							if( g_fDelayTime[i] > 0.0 )
							{
								CreateTimer(g_fDelayTime[i], tmrExecuteCommand, GetClientUserId(activator) | (i << 7));
							} else {
								ExecuteCommand(activator, i);
							}

							if( g_fRefireTime[i] > 0.0 )
							{
								if( g_hTimerEnable[i] != null )	delete g_hTimerEnable[i];
								g_hTimerEnable[i] = CreateTimer(g_fRefireTime[i], TimerEnable, i);
								if( data & LEAVE_NO == LEAVE_NO )	AcceptEntityInput(caller, "Disable");
							} else {
								g_bStopEnd[i] = false;
							}
						}
						else // Limited refires
						{
							int fired = GetEntProp(caller, Prop_Data, "m_iHammerID");

							if( g_iRefireCount[i] > fired )
							{
								executed = true;
								if( g_fDelayTime[i] > 0.0 )
								{
									CreateTimer(g_fDelayTime[i], tmrExecuteCommand, GetClientUserId(activator) | (i << 7));
								} else {
									ExecuteCommand(activator, i);
								}

								SetEntProp(caller, Prop_Data, "m_iHammerID", fired + 1);
								if( fired + 1 != g_iRefireCount[i] ) // Enable again if allowed
								{
									if( g_fRefireTime[i] > 0.0 )
									{
										if( g_hTimerEnable[i] != null )	delete g_hTimerEnable[i];
										g_hTimerEnable[i] = CreateTimer(g_fRefireTime[i], TimerEnable, i);
										if( data & LEAVE_NO == LEAVE_NO )	AcceptEntityInput(caller, "Disable");
									} else {
										g_bStopEnd[i] = false;
									}
								}
							} else {
								g_bStopEnd[i] = true;
								AcceptEntityInput(caller, "Disable");
							}
						}

						if( !executed && g_iCvarRefire == 1 && g_iRefireCount[i] != 0 )
						{
							int fired = GetEntProp(caller, Prop_Data, "m_iHammerID");
							SetEntProp(caller, Prop_Data, "m_iHammerID", fired + 1);
						}
					} else { // Chance fail, do we add to refire?
						if( g_iCvarRefire == 1 && g_iRefireCount[i] != 0 )
						{
							int fired = GetEntProp(caller, Prop_Data, "m_iHammerID");
							if( g_iRefireCount[i] > fired )
							{
								SetEntProp(caller, Prop_Data, "m_iHammerID", fired + 1);
							} else {
								g_bStopEnd[i] = true;
								AcceptEntityInput(caller, "Disable");
							}
						}
					}

					break;
				}
			}
		}
	}
}

public Action tmrExecuteCommand(Handle timer, any bits)
{
	int client = bits & 0x7F;
	int index = bits >> 7;

	client = GetClientOfUserId(client);

	if( client && IsClientInGame(client) )
	{
		ExecuteCommand(client, index);
	}
}

void ExecuteCommand(int client, int index)
{
	char sCommand[CMD_MAX_LENGTH];
	strcopy(sCommand, sizeof(sCommand), g_sCommand[index]);

	char sComm[CMD_MAX_LENGTH];
	int pos = StrContains(sCommand, " ");
	strcopy(sComm, sizeof(sComm), sCommand);
	if( pos != -1 ) sComm[pos] = '\x0';

	int data = g_iCmdData[index];
	int flags, bits;
	bool pass;
	int num = 1;
	int team;
	bool bot;

	if( !(data & COMMAND_SERVER == COMMAND_SERVER) && !(data & EXEC_CLIENT == EXEC_CLIENT) ) num = MaxClients;

	for( int i = 1; i <= num; i++ )
	{
		if( num == MaxClients )
		{
			pass = false;
			client = i;
			if( IsClientInGame(client) )
			{
				bot = IsFakeClient(client);
				team = GetClientTeam(client);

				if( data & EXEC_ALL == EXEC_ALL )													pass = true;
				else if( data & EXEC_DEAD == EXEC_DEAD && !IsPlayerAlive(client) )					pass = true;
				else if( data & EXEC_ALIVE == EXEC_ALIVE && IsPlayerAlive(client) )					pass = true;
				else if( data & EXEC_TEAM_1 == EXEC_TEAM_1 && team == g_iTeamOne )					pass = true;
				else if( data & EXEC_TEAM_2 == EXEC_TEAM_2 && team == g_iTeamTwo )					pass = true;
				else if( data & EXEC_TEAMS == EXEC_TEAMS )
				{
					if( team == g_iTeamOne || team == g_iTeamTwo )									pass = true;
				}

				if( !pass )
				{
					if( data & EXEC_BOTS == EXEC_BOTS && bot )										pass = true;
					if( data & EXEC_REAL == EXEC_REAL && !bot )										pass = true;
				} else {
					if( data & EXEC_BOTS == EXEC_BOTS && !bot )										pass = false;
					if( data & EXEC_REAL == EXEC_REAL && bot )										pass = false;
				}
			}
		} else {
			pass = true;
		}

		//Get the targets id and replace {me} with the client's id
		char id[32];
		Format(id, sizeof(id), "#%d", GetClientUserId(client));
		ReplaceString(sCommand, sizeof(sCommand), "{me}", id, false);

		if( pass )
		{
			bot = IsFakeClient(client);
			// COMMAND CHEAT FLAG
			if( data & FLAGS_CHEAT == FLAGS_CHEAT || data & FLAGS_ADMINCHEAT == FLAGS_ADMINCHEAT )
			{
				flags = GetCommandFlags(sComm);
				SetCommandFlags(sComm, flags & ~FCVAR_CHEAT);
			}
			// USER ADMIN BITS
			if( data & FLAGS_ADMIN == FLAGS_ADMIN || data & FLAGS_ADMINCHEAT == FLAGS_ADMINCHEAT )
			{
				bits = GetUserFlagBits(client);
				SetUserFlagBits(client, ADMFLAG_ROOT);
			}
			// SERVER COMMAND
			if( data & COMMAND_SERVER == COMMAND_SERVER )
			{
				ServerCommand(sCommand);
			}
			else if( data & COMMAND_CLIENT == COMMAND_CLIENT )
			{
				ClientCommand(client, sCommand);
			}
			else if( data & COMMAND_FAKE == COMMAND_FAKE )
			{
				FakeClientCommand(client, sCommand);
			}

			// RESTORE COMMAND FLAGS
			if( data & FLAGS_CHEAT == FLAGS_CHEAT || data & FLAGS_ADMINCHEAT == FLAGS_ADMINCHEAT )
			{
				SetCommandFlags(sComm, flags);
			}
			// RESTORE USER BITS
			if( data & FLAGS_ADMIN == FLAGS_ADMIN || data & FLAGS_ADMINCHEAT == FLAGS_ADMINCHEAT )
			{
				SetUserFlagBits(client, bits);
			}
		}
	}
}



// ====================================================================================================
//					TRIGGER BOX - DISPLAY BEAM BOX
// ====================================================================================================
public Action TimerBeam(Handle timer)
{
	if( IsValidEntRef(g_iSelectedTrig) )
	{
		float vMaxs[3], vMins[3], vPos[3];
		GetEntPropVector(g_iSelectedTrig, Prop_Send, "m_vecOrigin", vPos);
		GetEntPropVector(g_iSelectedTrig, Prop_Send, "m_vecMaxs", vMaxs);
		GetEntPropVector(g_iSelectedTrig, Prop_Send, "m_vecMins", vMins);
		AddVectors(vPos, vMaxs, vMaxs);
		AddVectors(vPos, vMins, vMins);
		TE_SendBox(vMins, vMaxs);
		return Plugin_Continue;
	}

	g_hTimerBeam = null;
	return Plugin_Stop;
}

void TE_SendBox(float vMins[3], float vMaxs[3])
{
	float vPos1[3], vPos2[3], vPos3[3], vPos4[3], vPos5[3], vPos6[3];
	vPos1 = vMaxs;
	vPos1[0] = vMins[0];
	vPos2 = vMaxs;
	vPos2[1] = vMins[1];
	vPos3 = vMaxs;
	vPos3[2] = vMins[2];
	vPos4 = vMins;
	vPos4[0] = vMaxs[0];
	vPos5 = vMins;
	vPos5[1] = vMaxs[1];
	vPos6 = vMins;
	vPos6[2] = vMaxs[2];
	TE_SendBeam(vMaxs, vPos1);
	TE_SendBeam(vMaxs, vPos2);
	TE_SendBeam(vMaxs, vPos3);
	TE_SendBeam(vPos6, vPos1);
	TE_SendBeam(vPos6, vPos2);
	TE_SendBeam(vPos6, vMins);
	TE_SendBeam(vPos4, vMins);
	TE_SendBeam(vPos5, vMins);
	TE_SendBeam(vPos5, vPos1);
	TE_SendBeam(vPos5, vPos3);
	TE_SendBeam(vPos4, vPos3);
	TE_SendBeam(vPos4, vPos2);
}

void TE_SendBeam(const float vMins[3], const float vMaxs[3])
{
	TE_SetupBeamPoints(vMins, vMaxs, g_iLaserMaterial, g_iHaloMaterial, 0, 0, BEAM_TIME + 0.1, 1.0, 1.0, 1, 0.0, g_iColors, 0);
	TE_SendToAll();
}



// ====================================================================================================
//					CONFIG - OPEN / SAVE
// ====================================================================================================
KeyValues ConfigOpen()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", CONFIG_DATA);

	if( !FileExists(sPath) || FileSize(sPath) == 0 )
	{
		File hCfg = OpenFile(sPath, "w");
		hCfg.WriteLine("");
		delete hCfg;
	}

	KeyValues hFile = new KeyValues("triggers");
	hFile.SetEscapeSequences(true);
	if( !hFile.ImportFromFile(sPath) )
	{
		delete hFile;
		return null;
	}

	return hFile;
}

void ConfigSave(KeyValues hFile)
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", CONFIG_DATA);

	if( !FileExists(sPath) ) return;

	hFile.Rewind();
	hFile.ExportToFile(sPath);
}



// ====================================================================================================
//					OTHER
// ====================================================================================================
bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}