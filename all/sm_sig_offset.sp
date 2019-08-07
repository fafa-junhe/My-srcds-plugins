#define PLUGIN_VERSION		"1.1.1"


/*=======================================================================================
	Plugin Info:

*	Name	:	[ANY] Gamedata Offset Tester
*	Author	:	SilverShot
*	Descrp	:	Dump memory bytes to server console for finding offsets. Uses signature bytes or gamedata for address.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=317074
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

1.1.1 (28-June-2019)
	- Allowed negative offset lookup.

1.1 (26-June-2019)
	- Added convar "sm_sig_offset_library" to determine which library to search.

1.0 (25-June-2019)
	- Initial release.

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define MAX_BUFFER	51200	// left4downtown.l4d2.txt gamedata is ~41kb
#pragma dynamic MAX_BUFFER

ConVar gCvarDisplay, gCvarPrint, gCvarLibrary;

public Plugin myinfo =
{
	name = "[ANY] Gamedata Offset Tester",
	author = "SilverShot",
	description = "Dump memory bytes to server console for finding offsets. Uses signature bytes or gamedata for address.",
	version = PLUGIN_VERSION,
	url = "http://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers"
}

public void OnPluginStart()
{
	gCvarDisplay =	CreateConVar(	"sm_sig_offset_display",	"1",	"0 = Dump all bytes space separated. 1 = Display offset number next to bytes.", 0);
	gCvarPrint =	CreateConVar(	"sm_sig_offset_print", 		"10",	"How many bytes to print per line in the console.", 0);
	gCvarLibrary =	CreateConVar(	"sm_sig_offset_library", 	"1",	"Which library to search. 0=Engine, 1=Server.", 0);
	CreateConVar(					"sm_sig_offset_version",	PLUGIN_VERSION, "Gamedata Offset Tester plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,			"sm_sig_offset");

	RegAdminCmd("sm_sig_off", CmdSig, ADMFLAG_ROOT, "Usage: sm_sig_off <offset> <signature bytes> || <gamedata> <signature> [offset] [bytes]");
}

public Action CmdSig(int client, int args)
{
	// Validate args
	if( args < 2 )
	{
		ReplyToCommand(client, "[SIG] Usage: sm_sig_off <offset> <signature bytes> || <gamedata> <signature> [offset] [bytes]");
		return Plugin_Handled;
	}

	// Vars
	Address pAddress;
	int offset;
	int bytes = 250;
	char temp[8];
	char sSignature[512];
	char sGamedata[PLATFORM_MAX_PATH];
	char sPath[PLATFORM_MAX_PATH];

	// Get Args
	GetCmdArg(1, sGamedata, sizeof sGamedata);
	GetCmdArg(2, sSignature, sizeof sSignature);



	// Check for signature bytes version of command
	bool bSigScan = true;
	for( int i = 0; i < strlen(sGamedata); i++ )
	{
		if( IsCharNumeric(sGamedata[i]) == false && sGamedata[i] != '-' )
		{
			bSigScan = false;
			break;
		}
	}

	// Get Signature
	if( bSigScan == true )
	{
		// Vars
		offset = StringToInt(sGamedata);

		// Get signature
		GetCmdArgString(sSignature, sizeof sSignature);

		int pos = FindCharInString(sSignature, ' ', false);
		Format(sSignature, sizeof sSignature, "%s", sSignature[pos + 1]);

		// Strip quotes
		StripQuotes(sSignature);

		// Bytes wildcard
		ReplaceString(sSignature, sizeof sSignature, "?", "2A");

		// Escape characters
		ReplaceString(sSignature, sizeof sSignature, " ", "\\x");

		if( sSignature[0] != '@' ) // Linux
			Format(sSignature, sizeof sSignature, "\\x%s", sSignature);
	}


	// Gamedata
	Handle hGameConfg;
	if( bSigScan == false )
	{
		// Optional args
		if( args == 3 )
		{
			GetCmdArg(3, temp, sizeof temp);
			offset = StringToInt(temp);
		}
		if( args == 4 )
		{
			GetCmdArg(4, temp, sizeof temp);
			bytes = StringToInt(temp);
		}

		// Gamedata exists
		BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/%s.txt", sGamedata);
		if( !FileExists(sPath) )
		{
			ReplyToCommand(client, "[SIG] Cannot find gamedata (1): \"%s.txt\".", sPath);
			return Plugin_Handled;
		}

		// Load gamedata
		hGameConfg = LoadGameConfigFile(sGamedata);
		if( hGameConfg == null )
		{
			ReplyToCommand(client, "[SIG] Cannot find gamedata (2): \"%s.txt\".", sPath);
			return Plugin_Handled;
		}

		// Address
		pAddress = GameConfGetAddress(hGameConfg, sSignature);
		delete hGameConfg;
	}



	// Write temporary gamedata adding the "Address" section
	if( !pAddress )
	{
		File hFile;
		char buffer[MAX_BUFFER];

		if( bSigScan == false )
		{
			// Build gamedata path
			BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/%s.txt", sGamedata);
			if( !FileExists(sPath) )
			{
				ReplyToCommand(client, "[SIG] Cannot find gamedata (3): \"%s.txt\"", sGamedata);
				return Plugin_Handled;
			}

			// Read gamedata file
			hFile = OpenFile(sPath, "r", false);
			if( hFile == null )
			{
				ReplyToCommand(client, "[SIG] Cannot open file: \"%s\".", sPath);
				return Plugin_Handled;
			}

			// Load file
			int len = FileSize(sPath, false);
			hFile.ReadString(buffer, sizeof buffer, len);
			delete hFile;
		}



		// Write custom gamedata
		BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/sm_sig_offset.txt");
		hFile = OpenFile(sPath, "w", false);

		int pos;
		if( bSigScan == false )
		{
			// Find entry section
			pos = StrContains(buffer, "\"Games\"") + 8;
			buffer[pos] = '\x0';

			// Write first part
			hFile.WriteLine(buffer, false);
		} else {
			hFile.WriteLine("\"Games\"");
		}

		// Write addresses section
		hFile.WriteLine("{");
		hFile.WriteLine("	\"#default\"");
		hFile.WriteLine("	{");
		hFile.WriteLine("		\"Addresses\"");
		hFile.WriteLine("		{");
		hFile.WriteLine("			\"%s\"", bSigScan ? "sig" : sSignature);
		hFile.WriteLine("			{");
		hFile.WriteLine("				\"windows\"");
		hFile.WriteLine("				{");
		hFile.WriteLine("					\"signature\"	\"%s\"", bSigScan ? "sig" : sSignature);
		hFile.WriteLine("				}");
		hFile.WriteLine("				\"linux\"");
		hFile.WriteLine("				{");
		hFile.WriteLine("					\"signature\"	\"%s\"", bSigScan ? "sig" : sSignature);
		hFile.WriteLine("				}");
		hFile.WriteLine("			}");
		hFile.WriteLine("		}");

		if( bSigScan == true )
		{
			hFile.WriteLine("		\"Signatures\"");
			hFile.WriteLine("		{");
			hFile.WriteLine("			\"sig\"");
			hFile.WriteLine("			{");
			hFile.WriteLine("				\"library\"	\"%s\"", gCvarLibrary.IntValue ? "server" : "engine");
			hFile.WriteLine("				\"windows\"	\"%s\"", sSignature);
			hFile.WriteLine("				\"linux\"	\"%s\"", sSignature);
			hFile.WriteLine("			}");
			hFile.WriteLine("		}");
			hFile.WriteLine("	}");
			hFile.WriteLine("}");
		} else {
			// Write last part
			hFile.WriteLine("	}");
			hFile.WriteString(buffer[pos + 1], false);
		}
		delete hFile;



		// Load new file
		strcopy(sPath, sizeof sPath, "sm_sig_offset");
		hGameConfg = LoadGameConfigFile(sPath);
		if( hGameConfg == null )
		{
			// Clean up
			BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/sm_sig_offset.txt");
			// DeleteFile(sPath, false);

			ReplyToCommand(client, "[SIG] Cannot find gamedata (4): \"%s.txt\".", sPath);
			return Plugin_Handled;
		}

		// Get Address
		pAddress = GameConfGetAddress(hGameConfg, bSigScan ? "sig" : sSignature);

		// Clean up
		delete hGameConfg;
		BuildPath(Path_SM, sPath, sizeof sPath, "gamedata/sm_sig_offset.txt");
		// DeleteFile(sPath, false);

		// Test again
		if( !pAddress )
		{
			ReplyToCommand(client, "[SIG] Cannot find signature.");
			return Plugin_Handled;
		}
	}



	// Print
	char buff[128];
	PrintToServer("");
	PrintToServer("Displaying %d bytes of %s from 0x%X + %d offset.\n", bytes, bSigScan ? "sig" : sSignature, pAddress, offset);

	// Loop memory
	int loop;
	for( int i = 0; i < bytes; i++ )
	{
		loop++;

		if( gCvarDisplay.IntValue == 0 )
		{
			// Load bytes into print buffer
			Format(buff, sizeof buff, "%s%02X ", buff, LoadFromAddress(pAddress + view_as<Address>(offset) + view_as<Address>(i), NumberType_Int8));

			// Print line to console and reset buffer
			if( loop == gCvarPrint.IntValue )
			{
				PrintToServer(buff);

				buff[0] = '\x0';
				loop = 0;
			}
		} else {
			// Padded line offset numbers
			if( loop == 1 ) Format(buff, sizeof buff, "[%3d%]  ", i + offset);

			// Load bytes into print buffer
			Format(buff, sizeof buff, "%s%02X ", buff, LoadFromAddress(pAddress + view_as<Address>(offset) + view_as<Address>(i), NumberType_Int8));

			// Double space in middlelast
			if( loop == gCvarPrint.IntValue / 2 ) StrCat(buff, sizeof buff, " ");

			// Print line to console and reset buffer
			if( loop == gCvarPrint.IntValue )
			{
				PrintToServer(buff);

				buff[0] = '\x0';
				loop = 0;
			}
		}

	}

	return Plugin_Handled;
}