/**
 * Danmaku Fortress Subplugin Include
 *
 * Only included by subplugins.
 */

#include <danmaku_fortress>

// managed game frame -- ensures this only executes once per subplugin per frame
// it also ensures that subplugins properly synchronize with the core. for example, hero bombs MUST update before boss abilities.
new bool:MGF_AlreadyHandled[DG_MAX_GAMES][2];
public DF_ManagedGameFrame(gameIdx, bool:hero, Float:curTime)
{
	if (MGF_AlreadyHandled[gameIdx][hero])
		return;
	ManagedGameFrame(gameIdx, hero, curTime);
	MGF_AlreadyHandled[gameIdx][hero] = true;
}

public OnGameFrame()
{
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		MGF_AlreadyHandled[gameIdx][0] = false;
		MGF_AlreadyHandled[gameIdx][1] = false;
	}
}

// reflective method calls
#define DF_PLUGIN_FILENAME "danmaku_fortress.smx"
stock GetMethod(const String:methodName[], &Handle:retPlugin, &Function:retFunc)
{
	static String:buffer[256];
	new Handle:iter = GetPluginIterator();
	new Handle:plugin = INVALID_HANDLE;
	while (MorePlugins(iter))
	{
		plugin = ReadPlugin(iter);
		
		GetPluginFilename(plugin, buffer, sizeof(buffer));
		if (StrContains(buffer, DF_PLUGIN_FILENAME, false) != -1)
			break;
		else
			plugin = INVALID_HANDLE;
	}
	
	CloseHandle(iter);
	if (plugin != INVALID_HANDLE)
	{
		new Function:func = GetFunctionByName(plugin, methodName);
		if (func != INVALID_FUNCTION)
		{
			retPlugin = plugin;
			retFunc = func;
		}
		else
			PrintToServer("[danmaku_fortress] ERROR: Could not find %s:%s()", DF_PLUGIN_FILENAME, methodName);
	}
	else
		PrintToServer("[danmaku_fortress] ERROR: Could not find %s. %s() failed.", DF_PLUGIN_FILENAME, methodName);
}

new String:DF_AbilityStr[MAX_KEY_NAME_LENGTH];
new String:DF_ArgStr[MAX_KEY_NAME_LENGTH];
stock SetAbilityArgStrs(abilityIdx, argIdx)
{
	Format(DF_AbilityStr, MAX_KEY_NAME_LENGTH, "ability%d", abilityIdx);
	Format(DF_ArgStr, MAX_KEY_NAME_LENGTH, "arg%d", argIdx);
}

stock DB_SpawnBeam(gameIdx, bool:isHero, Float:start[3], Float:end[3], Float:radius, color, damage, flags = 0)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DB_SpawnBeam", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(isHero);
	Call_PushArray(start, 3);
	Call_PushArray(end, 3);
	Call_PushFloat(radius);
	Call_PushCell(color);
	Call_PushCell(damage);
	Call_PushCell(flags);
	Call_Finish();
	CloseHandle(plugin);
}

// spawn rocket on top of player (is actually offset randomly so rockets don't explode by being on top of each other)
stock DR_SpawnRocket(gameIdx, bool:isHero, Float:angles[3], Float:radius, Float:speed, color, damage, patternIdx, Float:param1, Float:param2, Float:lifetime = 0.0, flags = 0x0)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_SpawnRocket", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return -1;
	
	new ret = -1;
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(isHero);
	Call_PushArray(angles, 3);
	Call_PushFloat(radius);
	Call_PushFloat(speed);
	Call_PushCell(color);
	Call_PushCell(damage);
	Call_PushCell(patternIdx);
	Call_PushFloat(param1);
	Call_PushFloat(param2);
	Call_PushFloat(lifetime);
	Call_PushCell(flags);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

// spawn rocket at a specific location
stock DR_SpawnRocketAt(gameIdx, bool:isHero, Float:spawnPos[3], Float:angles[3], Float:radius, Float:speed, color, damage, patternIdx, Float:param1, Float:param2, Float:lifetime = 0.0, flags = 0x0)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_SpawnRocketAt", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return -1;

	new ret = -1;
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(isHero);
	Call_PushArray(spawnPos, 3);
	Call_PushArray(angles, 3);
	Call_PushFloat(radius);
	Call_PushFloat(speed);
	Call_PushCell(color);
	Call_PushCell(damage);
	Call_PushCell(patternIdx);
	Call_PushFloat(param1);
	Call_PushFloat(param2);
	Call_PushFloat(lifetime);
	Call_PushCell(flags);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

stock DR_FreezeAllRocketsRectangle(gameIdx, Float:duration, Float:min[3], Float:max[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_FreezeAllRocketsRectangle", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(duration);
	Call_PushArray(min, 3);
	Call_PushArray(max, 3);
	Call_Finish();
	CloseHandle(plugin);
}

stock DR_FreezeAllRocketsRadius(gameIdx, Float:duration, Float:point[3], Float:radius)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_FreezeAllRocketsRadius", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(duration);
	Call_PushArray(point, 3);
	Call_PushFloat(radius);
	Call_Finish();
	CloseHandle(plugin);
}

stock DR_FreezeAllRockets(gameIdx, Float:duration)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_FreezeAllRockets", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(duration);
	Call_Finish();
	CloseHandle(plugin);
}

stock DR_FreezeLastRocket(gameIdx, Float:duration)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_FreezeLastRocket", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(duration);
	Call_Finish();
	CloseHandle(plugin);
}

// note, I'm just future-proofing this method with all the additional params.
// when this method was created, only param1 existed. (2015-07-06) This is bound to change in the future.
stock DR_SetInternalParams(gameIdx, Float:param1, Float:param2 = 0.0, Float:param3 = 0.0, Float:param4 = 0.0, Float:param5 = 0.0, Float:param6 = 0.0)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_SetInternalParams", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(param1);
	Call_PushFloat(param2);
	Call_PushFloat(param3);
	Call_PushFloat(param4);
	Call_PushFloat(param5);
	Call_PushFloat(param6);
	Call_Finish();
	CloseHandle(plugin);
}

stock DS_SpawnSpawnerAt(gameIdx, bool:isHero, Float:spawnPos[3], Float:angles[3], Float:speed, modelIdx, movePattern, Float:moveParam1, Float:moveParam2, spawnPattern, Float:spawnInterval, Float:spawnParam1, Float:lifetimeOverride, rocketFlags)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DS_SpawnSpawnerAt", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return -1;

	new ret = -1;
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(isHero);
	Call_PushArray(spawnPos, 3);
	Call_PushArray(angles, 3);
	Call_PushFloat(speed);
	Call_PushCell(modelIdx);
	Call_PushCell(movePattern);
	Call_PushFloat(moveParam1);
	Call_PushFloat(moveParam2);
	Call_PushCell(spawnPattern);
	Call_PushFloat(spawnInterval);
	Call_PushFloat(spawnParam1);
	Call_PushFloat(lifetimeOverride);
	Call_PushCell(rocketFlags);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

// note: this must be called IMMEDIATELY after the above
// however, be sure to ensure the validity of the spawner first. (spawner != -1)
public DS_SetSpawnerProjectileParams(gameIdx, Float:childRadius, childColor, Float:childSpeed, childDamage)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DS_SetSpawnerProjectileParams", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(childRadius);
	Call_PushCell(childColor);
	Call_PushFloat(childSpeed);
	Call_PushCell(childDamage);
	Call_Finish();
	CloseHandle(plugin);
}

// pass -1.0 to mean default
stock DG_SetBossMoveSpeed(gameIdx, Float:moveSpeed = -1.0)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_SetBossMoveSpeed", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(moveSpeed);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_BossAbilityEnded(gameIdx)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_BossAbilityEnded", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_Finish();
	CloseHandle(plugin);
}


stock DF_GetArgInt(String:configName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argIdx, defaultValue = 0)
{
	new ret = 0;

	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("KV_ReadInt", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return defaultValue;
		
	SetAbilityArgStrs(abilityIdx, argIdx);
	Call_StartFunction(plugin, func);
	Call_PushStringEx(configName, MAX_CONFIG_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_AbilityStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_ArgStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushCell(defaultValue);
	Call_Finish(ret);
	CloseHandle(plugin);
		
	return ret;
}

stock Float:DF_GetArgFloat(String:configName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argIdx, Float:defaultValue = 0.0)
{
	new Float:ret = 0.0;

	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("KV_ReadFloat", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return defaultValue;
		
	SetAbilityArgStrs(abilityIdx, argIdx);
	Call_StartFunction(plugin, func);
	Call_PushStringEx(configName, MAX_CONFIG_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_AbilityStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_ArgStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushCell(defaultValue);
	Call_Finish(ret);
	CloseHandle(plugin);
		
	return ret;
}

stock bool:DF_GetArgString(String:configName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argIdx, String:someStr[], length)
{
	new bool:ret = false;
	
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("KV_ReadString", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return ret;
		
	SetAbilityArgStrs(abilityIdx, argIdx);
	Call_StartFunction(plugin, func);
	Call_PushStringEx(configName, MAX_CONFIG_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_AbilityStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_ArgStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(someStr, length, 2, 1);
	Call_PushCell(length);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

stock bool:DF_GetArgRectangle(String:configName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argIdx, Float:rect[2][3])
{
	new bool:ret = false;
	
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("KV_ReadRectangleExternal", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return ret;
		
	SetAbilityArgStrs(abilityIdx, argIdx);
	Call_StartFunction(plugin, func);
	Call_PushStringEx(configName, MAX_CONFIG_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_AbilityStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(DF_ArgStr, MAX_KEY_NAME_LENGTH, 2, 1);
	Call_PushArray(rect[0], 3);
	Call_PushArray(rect[1], 3);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

stock DG_GetWallMinMaxAndFiringAngle(gameIdx, wallType, Float:min[3], Float:max[3], Float:firingAngle[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_GetWallMinMaxAndFiringAngle", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(wallType);
	Call_PushArrayEx(min, 3, 1);
	Call_PushArrayEx(max, 3, 1);
	Call_PushArrayEx(firingAngle, 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

// WARNING: Since some arenas might be circular, this only returns the skybox rectangle.
// you still need to account for things like the despawn rectangle and the "rockets only" buffer space
stock DG_GetArenaRectangle(gameIdx, Float:rect[2][3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_GetArenaRectangle", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushArrayEx(rect[0], 3, 1);
	Call_PushArrayEx(rect[1], 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_GetFurthestSpawnPattern(gameIdx, axis) // implied: from hero (since boss is supposed to be easily wailed on)
{
	new ret = DR_PATTERN_STRAIGHT;
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_GetFurthestSpawnPattern", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return ret;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(axis);
	Call_Finish(ret);
	CloseHandle(plugin);
	return ret;
}

stock DG_OnHeroHit(gameIdx)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_OnHeroHit", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_OnBossHit(gameIdx, damage)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_OnBossHit", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(damage);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_SetWarningMessage(gameIdx, String:warningText[MAX_CENTER_TEXT_LENGTH], String:warningSound[MAX_SOUND_FILE_LENGTH])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_SetWarningMessage", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushStringEx(warningText, MAX_CENTER_TEXT_LENGTH, 2, 1);
	Call_PushStringEx(warningSound, MAX_SOUND_FILE_LENGTH, 2, 1);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_RadiusBombEffect(gameIdx, Float:radius, Float:heroPos[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_RadiusBombEffect", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushFloat(radius);
	Call_PushArrayEx(heroPos, 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

// note: not required to have these be min/max. the plugin will resolve that itself.
stock DG_RectangleBombEffect(gameIdx, Float:point1[3], Float:point2[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_RectangleBombEffect", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushArrayEx(point1, 3, 1);
	Call_PushArrayEx(point2, 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

stock DG_BeamBombEffect(gameIdx, Float:point1[3], Float:point2[3], Float:beamRadius)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DG_BeamBombEffect", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushArrayEx(point1, 3, 1);
	Call_PushArrayEx(point2, 3, 1);
	Call_PushFloat(beamRadius);
	Call_Finish();
	CloseHandle(plugin);
}

stock DR_GetDefaultFiringPosition(clientIdx, Float:pos[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_GetDefaultFiringPosition", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(clientIdx);
	Call_PushArrayEx(pos, 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

stock DR_GetHeroHitPosition(gameIdx, Float:pos[3])
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod("DR_GetHeroHitPosition", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushArrayEx(pos, 3, 1);
	Call_Finish();
	CloseHandle(plugin);
}

/**
 * Stocks which don't really demand method invocation, but will be used by many subplugins
 */
// the purpose of this is to not have rockets spawn on top of the skybox, leading to unpredictable results
stock DG_AdjustWallFiringPosition(Float:wallRect[2][3], const Float:angle[3], wallType, Float:offset = 1.0)
{
	offset += DC_DESPAWN_RANGE;
	
	if (wallType == DG_WALL_CEILING)
	{
		wallRect[0][2] -= offset;
		wallRect[1][2] -= offset;
	}
	else if (wallType == DG_WALL_FLOOR)
	{
		wallRect[0][2] += offset;
		wallRect[1][2] += offset;
	}
	else
	{
		if (angle[1] == 90.0 || fabs(angle[1] - 90.0) == 360.0)
		{
			wallRect[0][1] += offset;
			wallRect[1][1] += offset;
		}
		else if (angle[1] == 180.0 || fabs(angle[1] - 180.0) == 360.0)
		{
			wallRect[0][0] -= offset;
			wallRect[1][0] -= offset;
		}
		else if (angle[1] == 270.0 || fabs(angle[1] - 270.0) == 360.0)
		{
			wallRect[0][1] -= offset;
			wallRect[1][1] -= offset;
		}
		else if (angle[1] == 0.0 || angle[1] == 360.0 || angle[1] == -360.0)
		{
			wallRect[0][0] += offset;
			wallRect[1][0] += offset;
		}
		else
			PrintToServer("[danmaku_fortress] WARNING: Invalid yaw passed to DG_AdjustWallFiringPosition() -- %f (cannot move out from skybox)", angle[1]);
	}
}

// if you use the above, call that one before this one
#define DG_IDEAL_RECT_OFFSET (DC_DESPAWN_RANGE + 100.0)
stock DG_GetIdealRectangle(const Float:wallRect[2][3], const Float:angle[3], wallType)
{
	if (wallType == DG_WALL_CEILING || wallType == DG_WALL_FLOOR)
	{
		// shrink 100 off the X and Y. easy peasy.
		wallRect[0][0] += DG_IDEAL_RECT_OFFSET;
		wallRect[1][0] -= DG_IDEAL_RECT_OFFSET;
		wallRect[0][1] += DG_IDEAL_RECT_OFFSET;
		wallRect[1][1] -= DG_IDEAL_RECT_OFFSET;
	}
	else
	{
		if (angle[1] == 90.0 || fabs(angle[1] - 90.0) == 360.0 || angle[1] == 27.0 || fabs(angle[1] - 27.0) == 360.0)
		{
			// y is forward, so only shave off X and Z
			wallRect[0][0] += DG_IDEAL_RECT_OFFSET;
			wallRect[1][0] -= DG_IDEAL_RECT_OFFSET;
			wallRect[0][2] += DG_IDEAL_RECT_OFFSET;
			wallRect[1][2] -= DG_IDEAL_RECT_OFFSET;
		}
		else
		{
			// x must be forward, so only shave off Y and Z
			wallRect[0][1] += DG_IDEAL_RECT_OFFSET;
			wallRect[1][1] -= DG_IDEAL_RECT_OFFSET;
			wallRect[0][2] += DG_IDEAL_RECT_OFFSET;
			wallRect[1][2] -= DG_IDEAL_RECT_OFFSET;
		}
	}
}

// this logic was showing up way too often in df_default_abilities
// and too often I'm only using heroPos once, thus...this.
stock DG_GetAngleToHero(gameIdx, const Float:startPos[3], Float:angles[3])
{
	static Float:heroPos[3];
	DR_GetHeroHitPosition(gameIdx, heroPos);
	GetVectorAnglesTwoPoints(startPos, heroPos, angles);
}

stock DF_ReadSound(String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argInt, String:soundFile[MAX_SOUND_FILE_LENGTH])
{
	DF_GetArgString(characterName, abilityIdx, argInt, soundFile, MAX_SOUND_FILE_LENGTH);
	if (strlen(soundFile) > 3)
		PrecacheSound(soundFile);
}

stock DF_ReadModel(String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argInt, String:modelFile[MAX_MODEL_FILE_LENGTH])
{
	DF_GetArgString(characterName, abilityIdx, argInt, modelFile, MAX_MODEL_FILE_LENGTH);
	if (strlen(modelFile) > 3)
		PrecacheModel(modelFile);
}

stock DF_ReadModelToInt(String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx, argInt)
{
	static String:modelFile[MAX_MODEL_FILE_LENGTH];
	DF_GetArgString(characterName, abilityIdx, argInt, modelFile, MAX_MODEL_FILE_LENGTH);
	if (strlen(modelFile) > 3)
		return PrecacheModel(modelFile);
	return -1;
}
