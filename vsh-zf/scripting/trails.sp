#include <sourcemod>

public Plugin myinfo =
{
	name = "trails",
	author = "fafa_junhe",
	description = "trails",
	version = "1.0",
	url = "https://discourse.jymc.top/"
};

public void OnPluginStart()
{
  if (FileExists("trails.txt", false))
{
  new Handle:SMC = SMC_CreateParser();
  SMC_SetReaders(SMC, NewSection, KeyValue, EndSection);
  SMC_ParseFile(SMC, "trails.txt"); //...cstrike/file.txt or ...tf/file.txt
  CloseHandle(SMC)
  }
	else
	{
		PrintToServer("trails.txt not found")
	}
  RegConsoleCmd("sm_trails",Command_trails)
}
public Action Command_trails(int client, int args)
{

}
public SMCResult:NewSection(Handle:smc, const String:name[], bool:opt_quotes)
{
    PrintToServer("\n%20s %20s", "SMC_NewSection", name);
}

public SMCResult:KeyValue(Handle:smc, const String:key[], const String:value[], bool:key_quotes, bool:value_quotes)
{
}

public SMCResult:EndSection(Handle:smc)
{
}
