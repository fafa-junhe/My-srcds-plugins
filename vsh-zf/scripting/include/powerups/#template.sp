/* Powerup template.
 * Don't include this in the real plugin.
 */

/* <How to create your powerup>
 * You need a .sp file that will have functions to be called when someone chooses your powerup.
 * You will need to modify ps_powerups.txt in "...\addons\sourcemod\configs" including your powerup information, so your newly created powerup can be accessible.
 * You will need to create a translation for your powerup name in ps.phrases at "...\addons\sourcemod\translations".
 *
 * For the .sp file, you will need a function that will be called when someone wants to start a powerup and stop it. In this template, this function is YourPowerup_Powerup.
 * For this function, you will need a integer that will be the client, a char array (string) that will be the custom properties of your powerup in "ps_powerups.txt", and a boolean that will
 * indicate if the plugin is wanting to activate your powerup on some client, or remove it.
 *
 * You can also hook events using the #manager.sp include event functions.
 *
 * When you finish creating your custom powerup, you need to modify "ps_powerups.txt" including your plugin information. Example:
 *
 * "id" // --> ID of your plugin as a number. The ID needs to follow a sequence: Last powerup ID + 1. The first powerup of the file have the ID 0. Annotate the ID because we will use it on #manager.sp.
 * {
 *		"powerup_name"		"your powerup name" // --> Modify "your powerup name", leaving the quotes, with your new powerup name. Remember this name because we'll use this to translate your powerup later.
 *		"cost"		"the cost of your powerup"  // --> Modify "the cost of your powerup", leaving the quotes, with your powerup cost as an natural number.
 *		"duration"		"time"  			    // --> Modify "time", leaving the quotes, with your powerup duration time, in seconds.
 *		"enabled"	"choice"				    // --> Modify "choice", leaving the quotes, with 0 or 1. 1 enables your powerup to be used and 0 disables it.
 *		"properties"	"powerup properties"    // --> Modify "powerup properties", leaving the quotes, with an string that will be send to your plugin function.
 * }
 *
 * After modifying "ps_powerups.txt", you will need to make a translation for the name of your powerup. In the "ps.phrases.txt" translation file, add:
 *
 * "your powerup name"				// --> The name of your powerup that you used in the "ps_powerups.txt" file.
 * {
 *		"en"		"Powerup Name"  // --> Modify "Powerup Name", leaving the quotes, with your final powerup name that will be shown to everyone on the server.
 * }
 *
 * After modifying the translation file, you will need to add your powerup call function (The function that will be called to add or remove a powerup on someone) to the #manager.sp file, in 
 * the function "Manager_ManagePowerup". Remember the ID that you used for your powerup in "ps_powerups.txt"? You'll need to add a case to the switch in the "Manager_ManagePowerup" function,
 * that will call your powerup.
 *
 * Now you're finished! Compile and test your new powerup!
 *
 * Note: You will probably get some warnings when you compile the plugin. This happens because some functions on #manager.sp aren't being used, but they could be necessary later.
 
 
void YourPowerup_Powerup(int client, char[] properties, bool enabled)
{
	if (enabled)
	{
		//Activate the powerup on the client
	}
	
	else
	{
		//Remove the powerup from the client
	}
}