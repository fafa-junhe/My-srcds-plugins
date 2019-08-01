/**
 * Danmaku Fortress - Debug Abilities
 *
 * These abilities are not intended to be used by actual characters.
 * I made them mainly to figure out problems with things like rocket resizing. Many won't even damage players.
 */

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0"

#include <df_subplugin>
#include <df_donator_interface> // DO NOT INCLUDE THIS IN YOUR SUBPLUGINS! It's being tested here.

public Plugin:myinfo = {
	name = "DF Debug Abilities",
	description = "Danmaku Fortress debug abilities. Not used in normal gameplay.",
	author = "sarysa",
	version = PLUGIN_VERSION,
}

/**
 * Boss Ability: Rocket Resize Test
 */
#define RRT_STRING "rocket_resize_test"
#define RRT_SEPARATION 300.0
#define RRT_NUM_PILLARS 9
new bool:RRT_ActiveThisGame[DG_MAX_GAMES];
new Float:RRT_RocketRadii[DG_MAX_GAMES][RRT_NUM_PILLARS];
new Float:RRT_RocketModelScales[DG_MAX_GAMES][RRT_NUM_PILLARS];

/**
 * Boss Ability: Donator Test
 */
#define DT_STRING "donator_test"
new bool:DT_ActiveThisGame[DG_MAX_GAMES];
		
public OnPluginStart()
{
	DF_GameCleanup(-1); // will clean up (initialize) all games
}

public OnMapStart()
{
	DF_GameCleanup(-1); // will clean up (initialize) all games
}

/**
 * REQUIRED METHODS (which are all lifecycle methods provided to us by the core. you likely won't need your own, except OnPluginStart() or OnMapStart() for reinitialization)
 * 
 * These are invoked with reflection. Same goes for method calls this subplugin makes to danmaku_fortress.sp
 */
public DF_InitAbility(gameIdx, owner, victim, String:abilityName[MAX_ABILITY_NAME_LENGTH], String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx)
{
	if (strcmp(abilityName, RRT_STRING) == 0)
	{
		RRT_ActiveThisGame[gameIdx] = true;
		
		for (new i = 0; i < RRT_NUM_PILLARS; i++)
		{
			RRT_RocketRadii[gameIdx][i] = DF_GetArgFloat(characterName, abilityIdx, 1 + (i * 2), 0.0);
			RRT_RocketModelScales[gameIdx][i] = DF_GetArgFloat(characterName, abilityIdx, 2 + (i * 2));
			PrintToServer("for #%d   radius=%f    scale=%f", i, RRT_RocketRadii[gameIdx][i], RRT_RocketModelScales[gameIdx][i]);
		}
	}
	else if (strcmp(abilityName, DT_STRING) == 0)
		DT_ActiveThisGame[gameIdx] = true;
}

// this one's different from the others since the subplugin .inc handles a ton of things related to game frame
// just keep in mind that OnGameFrame() can't be declared in this subplugin, since it is in the .inc
ManagedGameFrame(gameIdx, bool:hero, Float:curTime)
{
	// typically only boss abilities operate on this game frame,
	// because hero abilities have DF_OnAbilityUsed() called every frame
	// bombs are the exception
	if (hero || gameIdx || curTime) // I swear, the selective complaining about unused variables is annoying.
	{
	}
	else
	{
		// RRT does not tick
	}
}

public DF_OnAbilityUsed(gameIdx, String:abilityName[MAX_ABILITY_NAME_LENGTH], Float:curTime, Float:powerLevel, userFlags)
{
	if (RRT_ActiveThisGame[gameIdx] && strcmp(abilityName, RRT_STRING) == 0)
		RRT_OnUse(gameIdx, curTime, powerLevel, userFlags);
	else if (DT_ActiveThisGame[gameIdx] && strcmp(abilityName, DT_STRING) == 0)
		DT_OnUse(gameIdx);
}

public DF_GameCleanup(gameIdx)
{
	RRT_Cleanup(gameIdx);
	DT_Cleanup(gameIdx);
}

/**
 * Boss Ability: Rocket Resize Tests
 */
public RRT_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		RRT_ActiveThisGame[i] = false; // that's all, folks
	}
}

public RRT_OnUse(gameIdx, Float:curTime, Float:powerLevel, userFlags)
{
	DG_BossAbilityEnded(gameIdx);

	static Float:arenaRect[2][3];
	DG_GetArenaRectangle(gameIdx, arenaRect);
	static Float:startPos[3];
	startPos[0] = ((arenaRect[0][0] + arenaRect[1][0]) * 0.5) - RRT_SEPARATION;
	static Float:tmpAngle[3];
	tmpAngle[0] = tmpAngle[1] = tmpAngle[2] = 0.0;
	
	for (new x = 0; x < 3; x++)
	{
		startPos[1] = ((arenaRect[0][1] + arenaRect[1][1]) * 0.5) - RRT_SEPARATION;
		for (new y = 0; y < 3; y++)
		{
			new i = (x * 3) + y;
			startPos[2] = arenaRect[0][2] + DC_DESPAWN_RANGE + 192.0;

			for (new rocketIdx = 0; rocketIdx < 4; rocketIdx++)
			{
				if (RRT_RocketRadii[gameIdx][i] <= 0.0)
					continue;
					
				new rocket = DR_SpawnRocketAt(gameIdx, true, startPos, tmpAngle, RRT_RocketRadii[gameIdx][i], 0.0, 0xffffff,
					1, DR_PATTERN_STRAIGHT, 0.0, 0.0, 60.0, DR_FLAG_NO_SHOT_SOUND | DR_FLAG_NO_COLLIDE | DR_FLAG_RAINBOW_COLORED);
				if (IsValidEntity(rocket))
					SetEntPropFloat(rocket, Prop_Send, "m_flModelScale", RRT_RocketModelScales[gameIdx][i]);
					
				startPos[2] += RRT_RocketRadii[gameIdx][i] * 2;
			}
			
			startPos[1] += RRT_SEPARATION;
		}
		startPos[0] += RRT_SEPARATION;
	}
}

public DF_OnSpawnerDestroyed(gameIdx, spawnerEntRef)
{
	// this callback is necessary for subplugin-managed spawners
	// what you would do is pass this on to all abilities that manage spawners themselves
	// then those abilities would compare entities. (remember to call EntRefToEntIndex() on this ent ref and your spawner entrefs first)
	// it's very rare that a spawner would actually become an invalid entity, since spawners are actually from a cache of rockets that are constantly recycled.
	// so this is the only way your subplugin can know that a spawner it's managing is no longer valid
	//PrintToServer("spawner destroyed: %d %d", gameIdx, spawnerEntRef);
}

public DF_OnRocketDestroyed(gameIdx, rocketEntRef)
{
	// this callback is necessary for subplugin-managed rockets
	// what you would do is pass this on to all abilities that manage rockets themselves
	// then those abilities would compare entities. (remember to call EntRefToEntIndex() on this ent ref and your rocket entrefs first)
	// it's very rare that a rocket would actually become an invalid entity, since rockets are actually from a cache of rockets that are constantly recycled.
	// so this is the only way your subplugin can know that a rocket it's managing is no longer valid
	//PrintToServer("rocket destroyed: %d %d", gameIdx, spawnerEntRef);
}

/**
 * Boss Ability: Donator Test
 */
public DT_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		DT_ActiveThisGame[i] = false; // that's all, folks
	}
}

public DT_OnUse(gameIdx)
{
	DG_BossAbilityEnded(gameIdx);

	for (new i = 1; i <= 5; i++)
		DFP_ClientIsDonator(i);
}
