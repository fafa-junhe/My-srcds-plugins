/*
 * This file controls all included powerups, and gives interfaces to them.
 * Modify this file adding your powerups and modify ps_powerups.txt adding your powerup info.
 *
 */
 
 //Your powerups
 #include <powerups/ubercharge.sp> 			// 0
 #include <powerups/criticals.sp> 			// 1
 #include <powerups/bullet_immunity.sp> 	// 2
 #include <powerups/explosion_immunity.sp> 	// 3
 #include <powerups/fire_immunity.sp> 		// 4
 #include <powerups/health_buff.sp> 		// 5
 #include <powerups/suicide.sp> 			// 6
 #include <powerups/slowed.sp>				// 7
 #include <powerups/infinite_ammo.sp>		// 8
 #include <powerups/bleed.sp>				// 9
 #include <powerups/reduced_damage.sp>		// 10
 #include <powerups/eye_for_an_eye.sp>		// 11
 

//The param "method" defines if the powerup will be added (true) or removed (false).
void Manager_ManagePowerup(int client, int powerup, char[] properties, bool method)
{
	switch (powerup)
	{
		case 0:Ubercharge_Powerup(client, method);
		case 1:Criticals_Powerup(client, method);
		case 2:BulletImmunity_Powerup(client, method);
		case 3:ExplosionImmunity_Powerup(client, method);
		case 4:FireImmunity_Powerup(client, method);
		case 5:HealthBuff_Powerup(client, properties, method);
		case 6:Suicide_BadPerk(client, method);
		case 7:Slowed_BadPerk(client, method);
		case 8:InfiniteAmmo_Powerup(client, method);
		case 9:Bleed_BadPerk(client, method);
		case 10:ReducedDamage_BadPerk(client, properties, method);
		case 11:EyeForAnEye_BadPerk(client, method);
	}
}

void Manager_OnPluginStart()
{
	Slowed_OnPluginStart();
	InfiniteAmmo_OnPluginStart();
}

void Manager_OnMapStart()
{
	Ubercharge_OnMapStart();
	Criticals_OnMapStart();
	BulletImmunity_OnMapStart();
	ExplosionImmunity_OnMapStart();
	FireImmunity_OnMapStart();
	HealthBuff_OnMapStart();
	Suicide_OnMapStart();
}

/*
void Manager_OnClientPostAdminCheck(int client)
{

}

void Manager_OnClientDisconnect(int client)
{
	
}

void Manager_OnPluginEnd()
{
	
}

void Manager_HookPlayerDeath(Event playerDeath)
{
	int client = GetClientOfUserId(playerDeath.GetInt("userid"));
}

void Manager_HookPlayerSpawn(Event playerSpawn)
{
	int client = GetClientOfUserId(playerSpawn.GetInt("userid"));
}

void Manager_HookPlayerTeam(Event playerTeam)
{
	int client = GetClientOfUserId(playerTeam.GetInt("userid"));
}
*/

Action Manager_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	Action act = ReducedDamage_OnTakeDamage(victim, attacker, damage);
	
	if (act != Plugin_Continue)
	{
		return act;
	}
	
	EyeForAnEye_OnTakeDamage(victim, attacker, damage);
	
	return Plugin_Continue;
}