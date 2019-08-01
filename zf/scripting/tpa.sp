#include <sourcemod>
#include <sdktools>
new Float:tpa[][3];
public Plugin:myinfo =
 { 
	name = "tpaccept",
	author = "",
	description = "tpaccept",
	version = "1.0"£¬
	url = "nope"; 
} ;
public void OnPluginStart ()
{
	RegConsoleCmd("sm_yes", Command_Accept);
	RegConsoleCmd("sm_no", Command_Refuse);
	RegConsoleCmd("sm_autono", Command_AutoRefuse);
	RegConsoleCmd("sm_autoyes", Command_AutoAccept);
	RegConsoleCmd("sm_tpa", Command_Tpa);
	PrintToServer("tpaccept load!");
}
public Action Command_MySlap(int client, int args)
{
	char arg1[32];
 
	/* By default, we set damage = 0 */
	int damage = 0;
 
	/* Get the first argument */
	GetCmdArg(1, arg1, sizeof(arg1));
 
	/* If there are 2 or more arguments, we set damage to
	 * what the user specified. If a damage isn't specified
	 * then it will stay zero. */ 
	/* Try and find a matching player */
	int target = FindTarget(client, arg1);
	if (target == -1)
	{
		/* FindTarget() automatically replies with the 
		 * failure reason and returns -1 so we know not 
		 * to continue
		 */
		return Plugin_Handled;
	}
 	GetClientAbsOrigin(client, tpa[target]);
	TeleportEntity(client, tpa[target], NULL_VECTOR, NULL_VECTOR);
 
	char name[MAX_NAME_LENGTH];
 
	GetClientName(target, name, sizeof(name));
	ReplyToCommand(client, "[SM] You slapped %s for %d damage!", name, damage);
 
	return Plugin_Handled;
}