/**
 * Danmaku Fortress Include
 *
 * Used by both the main plugin and all subplugins.
 */
#include <sourcemod>
#include <tf2_stocks>
#include <tf2items>
#include <sdkhooks>
#include <sdktools>
#include <sdktools_functions>
#include <morecolors>

// copied from tf2 sdk
// effects, for m_fEffects
#define EF_BONEMERGE 0x001	// Performs bone merge on client side
#define EF_BRIGHTLIGHT 0x002	// DLIGHT centered at entity origin
#define EF_DIMLIGHT 0x004	// player flashlight
#define EF_NOINTERP 0x008	// don't interpolate the next frame
#define EF_NOSHADOW 0x010	// Don't cast no shadow
#define EF_NODRAW 0x020		// don't draw entity
#define EF_NORECEIVESHADOW 0x040	// Don't receive no shadow
#define EF_BONEMERGE_FASTCULL 0x080	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
#define EF_ITEM_BLINK 0x100	// blink an item so that the user notices it.
#define EF_PARENT_ANIMATES 0x200	// always assume that the parent entity is animating

// solid types
#define SOLID_NONE 0 // no solid model
#define SOLID_BSP 1 // a BSP tree
#define SOLID_BBOX 2 // an AABB
#define SOLID_OBB 3 // an OBB (not implemented yet)
#define SOLID_OBB_YAW 4 // an OBB, constrained so that it can only yaw
#define SOLID_CUSTOM 5 // Always call into the entity for tests
#define SOLID_VPHYSICS 6 // solid vphysics object, get vcollide from the model and collide with that

#define FSOLID_CUSTOMRAYTEST 0x0001 // Ignore solid type + always call into the entity for ray tests
#define FSOLID_CUSTOMBOXTEST 0x0002 // Ignore solid type + always call into the entity for swept box tests
#define FSOLID_NOT_SOLID 0x0004 // Are we currently not solid?
#define FSOLID_TRIGGER 0x0008 // This is something may be collideable but fires touch functions
#define FSOLID_NOT_STANDABLE 0x0010 // You can't stand on this
#define FSOLID_VOLUME_CONTENTS 0x0020 // Contains volumetric contents (like water)
#define FSOLID_FORCE_WORLD_ALIGNED 0x0040 // Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
#define FSOLID_USE_TRIGGER_BOUNDS 0x0080 // Uses a special trigger bounds separate from the normal OBB
#define FSOLID_ROOT_PARENT_ALIGNED 0x0100 // Collisions are defined in root parent's local coordinate space
#define FSOLID_TRIGGER_TOUCH_DEBRIS 0x0200 // This trigger will touch debris objects

#define IsEmptyString(%1) (%1[0] == 0)
 
enum // Collision_Group_t in const.h
{
	COLLISION_GROUP_NONE  = 0,
	COLLISION_GROUP_DEBRIS,			// Collides with nothing but world and static stuff
	COLLISION_GROUP_DEBRIS_TRIGGER, // Same as debris, but hits triggers
	COLLISION_GROUP_INTERACTIVE_DEBRIS,	// Collides with everything except other interactive debris or debris
	COLLISION_GROUP_INTERACTIVE,	// Collides with everything except interactive debris or debris
	COLLISION_GROUP_PLAYER,
	COLLISION_GROUP_BREAKABLE_GLASS,
	COLLISION_GROUP_VEHICLE,
	COLLISION_GROUP_PLAYER_MOVEMENT,  // For HL2, same as Collision_Group_Player, for
										// TF2, this filters out other players and CBaseObjects
	COLLISION_GROUP_NPC,			// Generic NPC group
	COLLISION_GROUP_IN_VEHICLE,		// for any entity inside a vehicle
	COLLISION_GROUP_WEAPON,			// for any weapons that need collision detection
	COLLISION_GROUP_VEHICLE_CLIP,	// vehicle clip brush to restrict vehicle movement
	COLLISION_GROUP_PROJECTILE,		// Projectiles!
	COLLISION_GROUP_DOOR_BLOCKER,	// Blocks entities not permitted to get near moving doors
	COLLISION_GROUP_PASSABLE_DOOR,	// ** sarysa TF2 note: Must be scripted, not passable on physics prop (Doors that the player shouldn't collide with)
	COLLISION_GROUP_DISSOLVING,		// Things that are dissolving are in this group
	COLLISION_GROUP_PUSHAWAY,		// ** sarysa TF2 note: I could swear the collision detection is better for this than NONE. (Nonsolid on client and server, pushaway in player code)

	COLLISION_GROUP_NPC_ACTOR,		// Used so NPCs in scripts ignore the player.
	COLLISION_GROUP_NPC_SCRIPTED,	// USed for NPCs in scripts that should not collide with each other

	LAST_SHARED_COLLISION_GROUP
};

// text string limits
#define MAX_SOUND_FILE_LENGTH 80
#define MAX_MODEL_FILE_LENGTH 128
#define MAX_MATERIAL_FILE_LENGTH 128
#define MAX_WEAPON_NAME_LENGTH 64
#define MAX_WEAPON_ARG_LENGTH 256
#define MAX_EFFECT_NAME_LENGTH 48
#define MAX_ENTITY_CLASSNAME_LENGTH 48
#define MAX_CENTER_TEXT_LENGTH 128
#define MAX_RANGE_STRING_LENGTH 66
#define MAX_HULL_STRING_LENGTH 197
#define MAX_ATTACHMENT_NAME_LENGTH 48
#define COLOR_BUFFER_SIZE 12
#define HEX_OR_DEC_STRING_LENGTH 12 // max -2 billion is 11 chars + null termination
#define MAX_ABILITY_NAME_LENGTH 33
#define MAX_PLUGIN_NAME_LENGTH 33
#define MAX_CONFIG_NAME_LENGTH 33
#define MAX_AESTHETIC_NAME_LENGTH 33
#define MAX_DESCRIPTION_LENGTH 65
#define MAX_KEY_NAME_LENGTH 33

#define MAX_PLAYERS_ARRAY 36
#define MAX_PLAYERS (MAX_PLAYERS_ARRAY < (MaxClients + 1) ? MAX_PLAYERS_ARRAY : (MaxClients + 1))
#define INVALID_ENTREF INVALID_ENT_REFERENCE

#define HeroTeam (_:TFTeam_Red)
#define BossTeam (_:TFTeam_Blue)

#define FAR_FUTURE 100000000.0

/**
 * Danmaku Rockets constants
 */
#define DR_REORIENT_INTERVAL 0.05
#define DR_FLAG_ACTIVE 0x0001 // subplugins: this is internal use only. changes made to this will be ignored.
#define DR_FLAG_BOMB_PROOF 0x0002
#define DR_FLAG_DISPOSE_PITCH 0x0004 // dispose pitch when orienting the projectile. the pitch's effect on velocity is unchanged.
#define DR_FLAG_NO_COLLIDE 0x0008 // useful for spawners that use rocket logic, but shouldn't hurt the hero
#define DR_FLAG_ANGLE_LOCKED 0x0010 // INTERNAL USE ONLY, DO NOT USE IN YOUR SUBPLUGINS!
#define DR_FLAG_NO_SHOT_SOUND 0x0020
#define DR_FLAG_OOB_NO_WARN 0x0040 // don't warn if attempting to spawn out of bounds (use this sparingly, not merely to shut the console up)
#define DR_FLAG_RAINBOW_COLORED 0x0080
#define DR_FLAG_ANGLE_CCW 0x0100
#define DR_FLAG_SPAWNER 0x0200
#define DR_PATTERN_STRAIGHT 0
#define DR_PATTERN_ANGLE 1
#define DR_PATTERN_WAVE 2
#define DR_PATTERN_HOMING 3
#define DR_PATTERN_CHAOTIC 4
#define DR_PATTERN_LAZY_HOMING 5
#define DR_PATTERN_RESIZING 6
#define DR_PATTERN_SHARP_TURN 7
#define DR_PATTERN_REPEAT_TURNS 8
#define DR_PATTERN_CHAOTIC_PROTECTED 9
#define DR_PATTERN_DELAYED_SEEKING 10 // starts immobile, then suddenly moves out toward the enemy
#define DR_PATTERN_CHAOTIC_DELAYED 11
// special patterns not directly set by the character maker
#define DR_PATTERN_SUBPLUGIN_DEFINED 100 // subplugins will eventually be able to use this
#define DR_PATTERN_VERTICAL_WAVE 101 // subplugins should use this if a wave shot is firing from the ceiling
#define DR_PATTERN_SPAWNER 102 // internal use only, subplugins should use the DS_ methods to create a spawner

/**
 * Danmaku Spawners constants
 */
// spawn patterns first
#define DS_SPAWN_STRAIGHT 0
#define DS_SPAWN_RADIAL 1
#define DS_SPAWN_TARGET 2
#define DS_SPAWN_RADIAL_TARGET 3
#define DS_SPAWN_HOMING 4
#define DS_SPAWN_SUBPLUGIN_DEFINED 100
// move patterns next
#define DS_MOVE_IMMOBILE 0 // also usable for subplugin defined
#define DS_MOVE_CHAOTIC 1 // will pass this one onto rockets
#define DS_MOVE_VERTICAL_CIRCLE 2

/**
 * Danmaku Beams constants
 */
#define DB_STANDARD_INTERVAL 0.1 // having beams last shorter than this may cause them to last forever, like this: http://steamcommunity.com/sharedfiles/filedetails/?id=461301733
#define DB_FREQUENCY (DB_STANDARD_INTERVAL + 0.08)
#define DB_FLAG_ACTIVE 0x0001
#define DB_FLAG_HARMLESS 0x0002 // used for the wind-up of a beam, or allow beams to only harm projectiles
#define DB_FLAG_NO_RENDER 0x0004
#define DB_FLAG_DESTROY_PROJECTILES 0x0008
#define DB_FLAG_NO_SOUND 0x0010

/**
 * Danmaku Games constants
 */
#define DG_MAX_GAMES 5 // hard maximum. I can't imagine being able to handle the projectiles for even this many, frankly.
#define DG_WALL_BEHIND_HERO 0
#define DG_WALL_BEHIND_BOSS 1
#define DG_WALL_HERO_LEFT 2 // hero looks to the left after spawning. that wall
#define DG_WALL_HERO_RIGHT 3 // hero looks to the right after spawning. that wall
#define DG_WALL_CEILING 4
#define DG_WALL_FLOOR 5
#define DG_AXIS_FORWARD_BACK 0
#define DG_AXIS_LEFT_RIGHT 1
#define DG_AXIS_UP_DOWN 2
#define DG_USER_FLAG_FOCUSED 1
#define DG_EXPECTED_ARENA_HEIGHT 384.0

/**
 * Danmaku Core constants
 */
#define DC_HERO_HIT_SPOT_Z_OFFSET 68.0
#define DC_PLAYERS_FORCED_CLASS TFClass_Pyro
#define DC_DESPAWN_RANGE 128.0 // artificial "despawn", as the same N projectiles are constantly moved in and out of play
#define DC_RECOMMENDED_BUFFER 192.0

/**
 * Might as well stick all my stocks here too
 */
stock bool:IsLivingPlayer(clientIdx)
{
	if (clientIdx <= 0 || clientIdx >= MAX_PLAYERS)
		return false;
		
	return IsClientInGame(clientIdx) && IsPlayerAlive(clientIdx);
}

stock bool:IsValidPlayer(clientIdx)
{
	if (clientIdx <= 0 || clientIdx >= MAX_PLAYERS)
		return false;
		
	return IsClientInGame(clientIdx);
}

stock Float:getLinearVelocity(Float:vecVelocity[3])
{
	return SquareRoot((vecVelocity[0] * vecVelocity[0]) + (vecVelocity[1] * vecVelocity[1]) + (vecVelocity[2] * vecVelocity[2]));
}

stock clamp(&x, min, max)
{
	if (x < min)
		x = min;
	else if (x > max)
		x = max;
}

stock fclamp(&Float:x, Float:min, Float:max)
{
	if (x < min)
		x = min;
	else if (x > max)
		x = max;
}

stock abs(x)
{
	return x < 0 ? -x : x;
}

stock Float:fabs(Float:x)
{
	return x < 0 ? -x : x;
}

stock min(n1, n2)
{
	return n1 < n2 ? n1 : n2;
}

stock Float:fmin(Float:n1, Float:n2)
{
	return n1 < n2 ? n1 : n2;
}

stock max(n1, n2)
{
	return n1 > n2 ? n1 : n2;
}

stock Float:fmax(Float:n1, Float:n2)
{
	return n1 > n2 ? n1 : n2;
}

stock Float:fsquare(Float:x)
{
	return x * x;
}

stock Float:getFloatDecimalComponent(Float:x)
{
	new xInt = RoundFloat(x);
	if (float(xInt) > x)
		xInt--;
	return fabs(x - float(xInt));
}

stock Float:getFloatWholeComponent(Float:x)
{
	new xInt = RoundFloat(x);
	if (float(xInt) > x)
		xInt--;
	return float(xInt);
}

stock getWholeComponent(Float:x)
{
	return RoundFloat(getFloatWholeComponent(x));
}

stock FindRandomPlayer(bool:isBossTeam, Float:position[3] = NULL_VECTOR, Float:maxDistance = 0.0, bool:anyTeam = false, bool:deadOnly = false)
{
	new player = -1;

	// first, get a player count for the team we care about
	new playerCount = 0;
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (!deadOnly && !IsLivingPlayer(clientIdx))
			continue;
		else if (deadOnly)
		{
			if (!IsClientInGame(clientIdx) || IsLivingPlayer(clientIdx))
				continue;
		}
			
		if (!deadOnly && maxDistance > 0.0 && !IsPlayerInRange(clientIdx, position, maxDistance))
			continue;
			
		if (blacklist[clientIdx])
			continue;

		// fixed to not grab people in spectator, since we can now include the dead
		new bool:valid = anyTeam && (GetClientTeam(clientIdx) == BossTeam || GetClientTeam(clientIdx) == HeroTeam);
		if (!valid)
			valid = (isBossTeam && GetClientTeam(clientIdx) == BossTeam) || (!isBossTeam && GetClientTeam(clientIdx) == HeroTeam);
			
		if (valid)
			playerCount++;
	}

	// ensure there's at least one living valid player
	if (playerCount <= 0)
		return -1;

	// now randomly choose our victim
	new rand = GetRandomInt(0, playerCount - 1);
	playerCount = 0;
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (!deadOnly && !IsLivingPlayer(clientIdx))
			continue;
		else if (deadOnly)
		{
			if (!IsClientInGame(clientIdx) || IsLivingPlayer(clientIdx))
				continue;
		}
			
		if (!deadOnly && maxDistance > 0.0 && !IsPlayerInRange(clientIdx, position, maxDistance))
			continue;

		if (blacklist[clientIdx])
			continue;

		// fixed to not grab people in spectator, since we can now include the dead
		new bool:valid = anyTeam && (GetClientTeam(clientIdx) == BossTeam || GetClientTeam(clientIdx) == HeroTeam);
		if (!valid)
			valid = (isBossTeam && GetClientTeam(clientIdx) == BossTeam) || (!isBossTeam && GetClientTeam(clientIdx) == HeroTeam);
			
		if (valid)
		{
			if (playerCount == rand) // needed if rand is 0
			{
				player = clientIdx;
				break;
			}
			playerCount++;
			if (playerCount == rand) // needed if rand is playerCount - 1, executes for all others except 0
			{
				player = clientIdx;
				break;
			}
		}
	}
	
	return player;
}

stock SpawnWeapon(client, String:name[], index, level, quality, String:attribute[], visible = 1)
{
	new Handle:weapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	TF2Items_SetClassname(weapon, name);
	TF2Items_SetItemIndex(weapon, index);
	TF2Items_SetLevel(weapon, level);
	TF2Items_SetQuality(weapon, quality);
	new String:attributes[32][32];
	new count = ExplodeString(attribute, ";", attributes, 32, 32);
	if(count%2!=0)
	{
		count--;
	}

	if(count>0)
	{
		TF2Items_SetNumAttributes(weapon, count/2);
		new i2 = 0;
		for(new i = 0; i < count; i += 2)
		{
			new attrib = StringToInt(attributes[i]);
			if (attrib == 0)
			{
				LogError("Bad weapon attribute passed: %s ; %s", attributes[i], attributes[i+1]);
				return -1;
			}
			TF2Items_SetAttribute(weapon, i2, attrib, StringToFloat(attributes[i+1]));
			i2++;
		}
	}
	else
	{
		TF2Items_SetNumAttributes(weapon, 0);
	}

	if (weapon == INVALID_HANDLE)
	{
		PrintToServer("[sarysamods9] Error: Invalid weapon spawned. client=%d name=%s idx=%d attr=%s", client, name, index, attribute);
		return -1;
	}

	new entity = TF2Items_GiveNamedItem(client, weapon);
	CloseHandle(weapon);
	EquipPlayerWeapon(client, entity);
	
	// sarysa addition
	if (!visible)
	{
		SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", -1);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.001);
	}
	
	return entity;
}

stock bool:IsInstanceOf(entity, const String:desiredClassname[])
{
	static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
	GetEntityClassname(entity, classname, MAX_ENTITY_CLASSNAME_LENGTH);
	return strcmp(classname, desiredClassname) == 0;
}

stock bool:EntityStartsWith(entity, const String:desiredPrefix[])
{
	static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
	GetEntityClassname(entity, classname, MAX_ENTITY_CLASSNAME_LENGTH);
	return StrContains(classname, desiredPrefix) == 0;
}

stock bool:CheckGroundClearance(clientIdx, Float:minClearance, bool:failInWater)
{
	// standing? automatic fail.
	if (GetEntityFlags(clientIdx) & FL_ONGROUND)
		return false;
	else if (failInWater && (GetEntityFlags(clientIdx) & (FL_SWIM | FL_INWATER)))
		return false;
		
	// need to do a trace
	static Float:origin[3];
	GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", origin);
	
	new Handle:trace = TR_TraceRayFilterEx(origin, Float:{90.0,0.0,0.0}, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
	static Float:endPos[3];
	TR_GetEndPosition(endPos, trace);
	CloseHandle(trace);
	
	// only Z should change, so this is easy.
	return origin[2] - endPos[2] >= minClearance;
}

// stole this stock from KissLick. it's a good stock!
stock DispatchKeyValueFormat(entity, const String:keyName[], const String:format[], any:...)
{
	static String:value[256];
	VFormat(value, sizeof(value), format, 4);

	DispatchKeyValue(entity, keyName, value);
} 

stock bool:PlayerIsInvincible(clientIdx)
{
	return TF2_IsPlayerInCondition(clientIdx, TFCond_Ubercharged) ||
		TF2_IsPlayerInCondition(clientIdx, TFCond_UberchargedHidden) ||
		TF2_IsPlayerInCondition(clientIdx, TFCond_UberchargedCanteen) ||
		TF2_IsPlayerInCondition(clientIdx, TFCond_UberchargedOnTakeDamage) ||
		TF2_IsPlayerInCondition(clientIdx, TFCond_Bonked);
}

stock GetA(c) { return abs(c>>24); }
stock GetR(c) { return abs((c>>16)&0xff); }
stock GetG(c) { return abs((c>>8 )&0xff); }
stock GetB(c) { return abs((c    )&0xff); }

stock ColorToDecimalString(String:buffer[COLOR_BUFFER_SIZE], rgb)
{
	Format(buffer, COLOR_BUFFER_SIZE, "%d %d %d", GetR(rgb), GetG(rgb), GetB(rgb));
}

stock BlendColorsRGB(oldColor, Float:oldWeight, newColor, Float:newWeight)
{
	new r = min(RoundFloat((GetR(oldColor) * oldWeight) + (GetR(newColor) * newWeight)), 255);
	new g = min(RoundFloat((GetG(oldColor) * oldWeight) + (GetG(newColor) * newWeight)), 255);
	new b = min(RoundFloat((GetB(oldColor) * oldWeight) + (GetB(newColor) * newWeight)), 255);
	return (r<<16) + (g<<8) + b;
}

stock SetColorRGBA(color[4], r, g, b, a)
{
	color[0] = abs(r)%256;
	color[1] = abs(g)%256;
	color[2] = abs(b)%256;
	color[3] = abs(a)%256;
}

stock bool:AngleWithinTolerance(Float:entityAngles[3], Float:targetAngles[3], Float:tolerance)
{
	static bool:tests[2];
	
	for (new i = 0; i < 2; i++)
		tests[i] = fabs(entityAngles[i] - targetAngles[i]) <= tolerance || fabs(entityAngles[i] - targetAngles[i]) >= 360.0 - tolerance;
	
	return tests[0] && tests[1];
}

stock Float:ConformAxisValue(Float:src, Float:dst, Float:distCorrectionFactor)
{
	return src - ((src - dst) * distCorrectionFactor);
}

stock bool:ConformLineDistance(Float:result[3], const Float:src[3], const Float:dst[3], Float:maxDistance, bool:canExtend = false)
{
	new Float:distance = GetVectorDistance(src, dst);
	if ((distance <= maxDistance && !canExtend) || distance <= 0.0)
	{
		// everything's okay.
		result[0] = dst[0];
		result[1] = dst[1];
		result[2] = dst[2];
	}
	else
	{
		// need to find a point at roughly maxdistance. (FP irregularities aside)
		new Float:distCorrectionFactor = maxDistance / distance;
		result[0] = ConformAxisValue(src[0], dst[0], distCorrectionFactor);
		result[1] = ConformAxisValue(src[1], dst[1], distCorrectionFactor);
		result[2] = ConformAxisValue(src[2], dst[2], distCorrectionFactor);
	}
	
	return distance != 0.0;
}

stock bool:CylinderCollision(Float:cylinderOrigin[3], Float:colliderOrigin[3], Float:maxDistance, Float:zMin, Float:zMax)
{
	if (colliderOrigin[2] < zMin || colliderOrigin[2] > zMax)
		return false;

	static Float:tmpVec1[3];
	tmpVec1[0] = cylinderOrigin[0];
	tmpVec1[1] = cylinderOrigin[1];
	tmpVec1[2] = 0.0;
	static Float:tmpVec2[3];
	tmpVec2[0] = colliderOrigin[0];
	tmpVec2[1] = colliderOrigin[1];
	tmpVec2[2] = 0.0;
	
	return GetVectorDistance(tmpVec1, tmpVec2, true) <= maxDistance * maxDistance;
}

stock bool:IsPointInRect(const Float:hull[2][3], const Float:point[3])
{
	return (point[0] >= hull[0][0] && point[0] <= hull[1][0]) &&
		(point[1] >= hull[0][1] && point[1] <= hull[1][1]) &&
		(point[2] >= hull[0][2] && point[2] <= hull[1][2]);
}

stock ReadHexOrDecInt(String:hexOrDecString[HEX_OR_DEC_STRING_LENGTH])
{
	if (StrContains(hexOrDecString, "0x") == 0)
	{
		new result = 0;
		for (new i = 2; i < 10 && hexOrDecString[i] != 0; i++)
		{
			result = result<<4;
				
			if (hexOrDecString[i] >= '0' && hexOrDecString[i] <= '9')
				result += hexOrDecString[i] - '0';
			else if (hexOrDecString[i] >= 'a' && hexOrDecString[i] <= 'f')
				result += hexOrDecString[i] - 'a' + 10;
			else if (hexOrDecString[i] >= 'A' && hexOrDecString[i] <= 'F')
				result += hexOrDecString[i] - 'A' + 10;
		}
		
		return result;
	}
	else
		return StringToInt(hexOrDecString);
}

stock BlendColorOneFactor(color1, color2, Float:factor)
{
	new r = GetR(color1) + RoundFloat((GetR(color2) - GetR(color1)) * factor);
	new g = GetG(color1) + RoundFloat((GetG(color2) - GetG(color1)) * factor);
	new b = GetB(color1) + RoundFloat((GetB(color2) - GetB(color1)) * factor);
	return (r<<16) + (g<<8) + b;
}

stock Float:DEG2RAD(Float:n) { return n * 0.017453; }

stock Float:RAD2DEG(Float:n) { return n * 57.29578; }

stock bool:IsInRange(entity1, entity2, Float:radius)
{
	radius *= radius;
	static Float:ent1Pos[3];
	static Float:ent2Pos[3];
	GetEntPropVector(entity1, Prop_Send, "m_vecOrigin", ent1Pos);
	GetEntPropVector(entity2, Prop_Send, "m_vecOrigin", ent2Pos);
	return radius >= GetVectorDistance(ent1Pos, ent2Pos, true);
}

stock bool:IsPointInRange(Float:point[3], entity, Float:radius)
{
	radius *= radius;
	static Float:entPos[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entPos);
	return radius >= GetVectorDistance(point, entPos, true);
}

stock bool:ArePointsInRange(const Float:point1[3], const Float:point2[3], Float:radius)
{
	radius *= radius;
	return radius >= GetVectorDistance(point1, point2, true);
}

stock Float:GetRayAngles(Float:startPoint[3], Float:endPoint[3], Float:angle[3])
{
	static Float:tmpVec[3];
	tmpVec[0] = endPoint[0] - startPoint[0];
	tmpVec[1] = endPoint[1] - startPoint[1];
	tmpVec[2] = endPoint[2] - startPoint[2];
	GetVectorAngles(tmpVec, angle);
}

// only use this if there's going to be a random yaw.
//stock Float:constrainPitch(Float:pitch)
//{
//	if (pitch > 90.0)
//		pitch -= (pitch - 90.0);
//	else if (pitch < -90.0)
//		pitch -= (pitch + 90.0);
//	return pitch;
//}

stock Float:fixAngle(Float:angle)
{
	new sanity = 0;
	while (angle < -180.0 && (sanity++) <= 10)
		angle = angle + 360.0;
	while (angle > 180.0 && (sanity++) <= 10)
		angle = angle - 360.0;
	
	// gotta pick a winner here, for standardization
	if (angle == -180.0)
		angle = 180.0;
		
	return angle;
}

stock fixAngles(Float:angles[3])
{
	for (new i = 0; i < 3; i++)
		angles[i] = fixAngle(angles[i]);
}

public bool:TraceWallsOnly(entity, contentsMask)
{
	return false;
}

// really wish that the original GetVectorAngles() worked this way.
stock Float:GetVectorAnglesTwoPoints(const Float:startPos[3], const Float:endPos[3], Float:angles[3])
{
	static Float:tmpVec[3];
	tmpVec[0] = endPos[0] - startPos[0];
	tmpVec[1] = endPos[1] - startPos[1];
	tmpVec[2] = endPos[2] - startPos[2];
	GetVectorAngles(tmpVec, angles);
}

public Action:RemoveEntity(Handle:timer, any:entid)
{
	new entity = EntRefToEntIndex(entid);
	if (IsValidEdict(entity) && entity > MaxClients)
		AcceptEntityInput(entity, "Kill");
}

stock AttachParticle(entity, const String:particleType[], Float:offset=0.0, bool:attach=true)
{
	new particle = CreateEntityByName("info_particle_system");
	
	if (!IsValidEntity(particle))
		return -1;

	static String:targetName[128];
	static Float:position[3];
	GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
	position[2] += offset;
	TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);

	Format(targetName, sizeof(targetName), "target%i", entity);
	DispatchKeyValue(entity, "targetname", targetName);

	DispatchKeyValue(particle, "targetname", "tf2particle");
	DispatchKeyValue(particle, "parentname", targetName);
	DispatchKeyValue(particle, "effect_name", particleType);
	DispatchSpawn(particle);
	SetVariantString(targetName);
	if (attach)
	{
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", entity);
	}
	ActivateEntity(particle);
	AcceptEntityInput(particle, "start");
	return particle;
}

stock CopyVector(Float:dst[3], const Float:src[3])
{
	dst[0] = src[0];
	dst[1] = src[1];
	dst[2] = src[2];
}

stock RemoveInvincibility(victim)
{
	if (TF2_IsPlayerInCondition(victim, TFCond_Ubercharged))
		TF2_RemoveCondition(victim, TFCond_Ubercharged);
	if (TF2_IsPlayerInCondition(victim, TFCond_UberchargedHidden))
		TF2_RemoveCondition(victim, TFCond_UberchargedHidden);
	if (TF2_IsPlayerInCondition(victim, TFCond_UberchargedCanteen))
		TF2_RemoveCondition(victim, TFCond_UberchargedCanteen);
	if (TF2_IsPlayerInCondition(victim, TFCond_UberchargedOnTakeDamage))
		TF2_RemoveCondition(victim, TFCond_UberchargedOnTakeDamage);
	if (TF2_IsPlayerInCondition(victim, TFCond_Bonked))
		TF2_RemoveCondition(victim, TFCond_Bonked);
	if (TF2_IsPlayerInCondition(victim, TFCond_DefenseBuffMmmph))
		TF2_RemoveCondition(victim, TFCond_DefenseBuffMmmph);

	SetEntProp(victim, Prop_Data, "m_takedamage", 2);
}

stock RemoveUberOverlay(clientIdx)
{
	new flags = GetCommandFlags("r_screenoverlay");
	SetCommandFlags("r_screenoverlay", flags & ~FCVAR_CHEAT);
	ClientCommand(clientIdx, "r_screenoverlay off");
	SetCommandFlags("r_screenoverlay", flags);
}

// seriously, am I the only one who uses basic "get substring" without regex anymore?
stock substr(String:dst[], length, const String:src[], start, endExclusive)
{
	if (endExclusive - start > length - 1)
		endExclusive = start + (length - 1);
	
	new count = 0;
	for (new i = start; i <= endExclusive; i++)
	{
		if (i == endExclusive)
			dst[count] = 0;
		else
			dst[count] = src[i];
		count++;
	}
}

stock StrEndsWith(const String:str[], const String:endsWithThis[])
{
	new strLength = strlen(str);
	new ewtLength = strlen(endsWithThis);
	if (ewtLength > strLength)
		return false;
		
	for (new i = 1; i <= ewtLength; i++)
		if (str[strLength - i] != endsWithThis[ewtLength - i])
			return false;
	
	return true;
}

stock bool:PluginExists(const String:other[])
{
	static String:buffer[PLATFORM_MAX_PATH];
	new Handle:iter = GetPluginIterator();
	new Handle:plugin = INVALID_HANDLE;
	while (MorePlugins(iter))
	{
		plugin = ReadPlugin(iter);
		
		GetPluginFilename(plugin, buffer, sizeof(buffer));
		if (StrContains(buffer, other, false) != -1)
			return true;
		else
			plugin = INVALID_HANDLE;
	}
	return false;
}

// fix for the really screwed up model resizing factors
stock Float:GetActualModelScale(Float:modelSize, Float:desiredSize)
{
	return SquareRoot(desiredSize / modelSize);
}

// time must be between 0.0 and 1.0
stock GetTimedRainbowColor(Float:time)
{
	// rainbow recoloring
	new r = 0, g = 0, b = 0;
	if (time <= 0.16666)
	{
		r = 255;
		b = RoundFloat(255.0 * (0.16666 - time) / 0.16666);
	}
	else if (time <= 0.33333)
	{
		r = 255;
		g = RoundFloat(255.0 * (time - 0.16666) / 0.16666);
	}
	else if (time <= 0.5)
	{
		r = RoundFloat(255.0 * (0.5 - time) / 0.16666);
		g = 255;
	}
	else if (time <= 0.66666)
	{
		g = 255;
		b = RoundFloat(255.0 * (time - 0.5) / 0.16666);
	}
	else if (time <= 0.83333)
	{
		g = RoundFloat(255.0 * (0.83333 - time) / 0.16666);
		b = 255;
	}
	else if (time < 1.0)
	{
		r = RoundFloat(255.0 * (time - 0.83333) / 0.16666);
		b = 255;
	}
	clamp(r, 0, 255);
	clamp(g, 0, 255);
	clamp(b, 0, 255);
	return (r<<16) | (g<<8) | b;
}

// returns -1 on failure
stock FindUser(String:partialName[], length, errorClient)
{
	static String:targetName[MAX_TARGET_LENGTH];
	static targetList[MAX_PLAYERS_ARRAY];
	new targetCount;
	new bool:wtfIsThis;
	if ((targetCount = ProcessTargetString(partialName, errorClient, targetList, MAX_PLAYERS_ARRAY, COMMAND_FILTER_CONNECTED, targetName, sizeof(targetName), wtfIsThis)) <= 0)
	{
		CReplyToCommand(errorClient, "Partial name match not found: %s", partialName);
		return -1;
	}
	else if (targetCount > 1)
	{
		CReplyToCommand(errorClient, "Multiple matches found for: %s", partialName);
		for (new i = 0; i < targetCount; i++)
		{
			GetClientName(targetList[i], partialName, length);
			CReplyToCommand(errorClient, "%d: %s", i + 1, partialName);
		}
		return -1;
	}

	return targetList[0];
}

stock Float:FloatModulus(Float:value, Float:divisor)
{
	new Float:tmp = value / divisor;
	tmp = getFloatDecimalComponent(tmp);
	return tmp * divisor;
}

/**
 * Hard math adapted from other sources
 *
 * Distance from point to line (3D): http://geomalgorithms.com/a02-_lines.html
 */
// Copyright 2001 softSurfer, 2012 Dan Sunday, adapted to SourcePawn by sarysa 2015
// This code may be freely used, distributed and modified for any purpose
// providing that this copyright notice is included with it.
// SoftSurfer makes no warranty for this code, and cannot be held
// liable for any real or imagined damage resulting from its use.
// Users of this code must verify correctness for their application.
stock vecSub(Float:result[3], const Float:vec1[3], const Float:vec2[3])
{
	result[0] = vec1[0] - vec2[0];
	result[1] = vec1[1] - vec2[1];
	result[2] = vec1[2] - vec2[2];
}

stock vecAdd(Float:result[3], const Float:vec1[3], const Float:vec2[3])
{
	result[0] = vec1[0] + vec2[0];
	result[1] = vec1[1] + vec2[1];
	result[2] = vec1[2] + vec2[2];
}

// great description here. lol
stock Float:someDistanceMethod(const Float:u[3], const Float:v[3])
{
	static Float:tmpVec[3];
	vecSub(tmpVec, u, v);
	return SquareRoot(GetVectorDotProduct(tmpVec, tmpVec));
}

stock Float:someDistanceMethodSquared(const Float:u[3], const Float:v[3])
{
	static Float:tmpVec[3];
	vecSub(tmpVec, u, v);
	//new Float:ret = GetVectorDotProduct(tmpVec, tmpVec);
	//PrintToServer("distance: %f", SquareRoot(ret));
	//return ret;
	return GetVectorDotProduct(tmpVec, tmpVec);
}

//stock Float:dist_Point_to_Segment( Point P, Segment S)
stock Float:dist_Point_to_Segment(const Float:point[3], const Float:start[3], const Float:end[3])
{
	static Float:v[3];
	vecSub(v, end, start);
	static Float:w[3];
	vecSub(w, point, start);
	
	new Float:c1 = GetVectorDotProduct(w, v);
	if (c1 <= 0)
		return someDistanceMethod(point, start);

	new Float:c2 = GetVectorDotProduct(v, v);
	if (c2 <= c1)
		return someDistanceMethod(point, end);
		
	new Float:b = c1 / c2;
	static Float:pb[3];
	CopyVector(pb, v);
	ScaleVector(pb, b);
	vecAdd(pb, pb, start);
	return someDistanceMethod(point, pb);
}

stock bool:IsLineInRangeOfPoint(const Float:point[3], const Float:start[3], const Float:end[3], Float:maxDistance)
{
	maxDistance *= maxDistance;
	static Float:v[3];
	vecSub(v, end, start);
	static Float:w[3];
	vecSub(w, point, start);
	
	new Float:c1 = GetVectorDotProduct(w, v);
	if (c1 <= 0)
		return maxDistance >= someDistanceMethodSquared(point, start);

	new Float:c2 = GetVectorDotProduct(v, v);
	if (c2 <= c1)
		return maxDistance >= someDistanceMethodSquared(point, end);
		
	new Float:b = c1 / c2;
	static Float:pb[3];
	CopyVector(pb, v);
	ScaleVector(pb, b);
	vecAdd(pb, pb, start);
	return maxDistance >= someDistanceMethodSquared(point, pb);
}

// a little more original but of the same family as the above, circle vs rectangle collision
// also a hell of a lot more expensive than the above
stock bool:IsRectInRangeOfPoint(Float:point[3], Float:rect[2][3], Float:radius)
{
	// first, basic "is point in rectangle" (match three)
	if (IsPointInRect(rect, point))
		return true;
	
	// test the six faces, which is way cheaper than what's coming next (match two)
	if (point[0] >= rect[0][0] && point[0] <= rect[1][0])
	{
		if (point[1] >= rect[0][1] && point[1] <= rect[1][1])
		{
			// all we have to do is check z distance
			if (fabs(point[2] - rect[0][2]) <= radius || fabs(point[2] - rect[1][2]) <= radius)
				return true;
		}
		else if (point[2] >= rect[0][2] && point[2] <= rect[1][2])
		{
			// all we have to do is check y distance
			if (fabs(point[1] - rect[0][1]) <= radius || fabs(point[1] - rect[1][1]) <= radius)
				return true;
		}
	}
	else if (point[1] >= rect[0][1] && point[1] <= rect[1][1] && point[2] >= rect[0][2] && point[2] <= rect[1][2])
		if (fabs(point[0] - rect[0][0]) <= radius || fabs(point[0] - rect[1][0]) <= radius)
			return true;
	
	// next, the "match 1" tests where we narrow down the number of line segments to test
	// ultimately using the above method
	static Float:start[3];
	static Float:end[3];
	new within = -1;
	new other1 = 0;
	new other2 = 0;
	for (new i = 0; i <= 2; i++)
	{
		if (point[i] >= rect[0][i] && point[i] <= rect[1][i])
		{
			within = i;
			other1 = (i+1)%3;
			other2 = (i+2)%3;
			break;
		}
	}
	
	// so what's going on in here:
	// if the point is within the min/max of 1 axis, we need to check the 4 line segments that span that axis
	// the other two axis are unchanging, either always min or always max each. this gives us four tests to perform.
	// I wanted to make this as cheap as possible, instead of adding the expense of 12 line segment tests per hero pellet
	if (within != -1)
	{
		new bool:success = false;
		start[within] = rect[0][within]; end[within] = rect[1][within];
		start[other1] = rect[0][other1]; end[other1] = rect[0][other1]; start[other2] = rect[0][other2]; end[other2] = rect[0][other2];
		success = success | IsLineInRangeOfPoint(point, start, end, radius);
		start[other1] = rect[1][other1]; end[other1] = rect[1][other1]; start[other2] = rect[0][other2]; end[other2] = rect[0][other2];
		success = success | IsLineInRangeOfPoint(point, start, end, radius);
		start[other1] = rect[1][other1]; end[other1] = rect[1][other1]; start[other2] = rect[1][other2]; end[other2] = rect[1][other2];
		success = success | IsLineInRangeOfPoint(point, start, end, radius);
		start[other1] = rect[0][other1]; end[other1] = rect[0][other1]; start[other2] = rect[1][other2]; end[other2] = rect[1][other2];
		success = success | IsLineInRangeOfPoint(point, start, end, radius);
		return success;
	}
	
	// finally, the match 0 tests where we get distance from the eight points
	static Float:otherPoint[3];
	new Float:radiusSquared = radius * radius;
	for (new x = 0; x <= 1; x++)
	{
		for (new y = 0; y <= 1; y++)
		{
			for (new z = 0; z <= 1; z++)
			{
				otherPoint[0] = rect[x][0];
				otherPoint[1] = rect[y][1];
				otherPoint[2] = rect[z][2];
				if (GetVectorDistance(point, otherPoint, true) <= radiusSquared)
					return true;
			}
		}
	}
	
	// and none of these worked. fail.
	return false;
}

// figured out a way to BS the above. very slight inaccuracy, but also way cheaper CPU-wise.
stock bool:IsRectInRangeOfPointCheap(const Float:point[3], const Float:rect[2][3], Float:radius)
{
	static Float:biggerRect[2][3];
	biggerRect[0][0] = rect[0][0] - radius;
	biggerRect[0][1] = rect[0][1] - radius;
	biggerRect[0][2] = rect[0][2] - radius;
	biggerRect[1][0] = rect[1][0] + radius;
	biggerRect[1][1] = rect[1][1] + radius;
	biggerRect[1][2] = rect[1][2] + radius;
	
	return IsPointInRect(biggerRect, point);
}

// pretty much an alias of the above, though different variable order due to difference in emphasis
stock bool:IsSphereInRect(const Float:rect[2][3], const Float:point[3], Float:radius)
{
	return IsRectInRangeOfPointCheap(point, rect, radius);
}

stock bool:BeamIntersectsWithPoint(const Float:beamStart[3], const Float:beamEnd[3], Float:radius, const Float:otherPoint[3])
{
	// we can simplify this by combining the shortening the line by the radius and applying the radius to the player
	// it gets inaccurate if the line is too short, but oh well. we'll have to do a point vs point test
	new Float:distance = GetVectorDistance(beamStart, beamEnd);
	if (distance <= radius * 2)
	{
		// segment is too short. it'll be a point vs point test.
		new Float:radiusSquared = radius * radius;
		static Float:point[3];
		point[0] = (beamStart[0] + beamEnd[0]) * 0.5;
		point[1] = (beamStart[1] + beamEnd[1]) * 0.5;
		point[2] = (beamStart[2] + beamEnd[2]) * 0.5;
		if (GetVectorDistance(point, otherPoint, true) <= radiusSquared)
			return true;
	}
	else
	{
		// move in the points of the line segment, then do the point vs. line math
		static Float:start[3];
		static Float:end[3];
		CopyVector(start, beamStart);
		CopyVector(end, beamEnd);

		new Float:shrinkFactor = radius / distance;
		new Float:shrinkBy = (end[0] - start[0]) * shrinkFactor;
		start[0] += shrinkBy;
		end[0] -= shrinkBy;
		shrinkBy = (end[1] - start[1]) * shrinkFactor;
		start[1] += shrinkBy;
		end[1] -= shrinkBy;
		shrinkBy = (end[2] - start[2]) * shrinkFactor;
		start[2] += shrinkBy;
		end[2] -= shrinkBy;

		if (IsLineInRangeOfPoint(otherPoint, start, end, radius))
			return true;
	}
	
	return false;
}

stock bool:BeamIntersectsWithRectangle(const Float:beamStart[3], const Float:beamEnd[3], Float:radius, const Float:rect[2][3])
{
	static Float:biggerRect[2][3];
	biggerRect[0][0] = rect[0][0] - radius;
	biggerRect[0][1] = rect[0][1] - radius;
	biggerRect[0][2] = rect[0][2] - radius;
	biggerRect[1][0] = rect[1][0] + radius;
	biggerRect[1][1] = rect[1][1] + radius;
	biggerRect[1][2] = rect[1][2] + radius;
	
	new Float:distance = GetVectorDistance(beamStart, beamEnd);
	if (distance <= radius * 2)
	{
		// segment is too short. it'll be a point vs rect test.
		static Float:point[3];
		point[0] = (beamStart[0] + beamEnd[0]) * 0.5;
		point[1] = (beamStart[1] + beamEnd[1]) * 0.5;
		point[2] = (beamStart[2] + beamEnd[2]) * 0.5;
		return IsPointInRect(biggerRect, point);
	}

	// move in the points of the line segment, then do the line vs. rect math
	static Float:start[3];
	static Float:end[3];
	CopyVector(start, beamStart);
	CopyVector(end, beamEnd);

	new Float:shrinkFactor = radius / distance;
	new Float:shrinkBy = (end[0] - start[0]) * shrinkFactor;
	start[0] += shrinkBy;
	end[0] -= shrinkBy;
	shrinkBy = (end[1] - start[1]) * shrinkFactor;
	start[1] += shrinkBy;
	end[1] -= shrinkBy;
	shrinkBy = (end[2] - start[2]) * shrinkFactor;
	start[2] += shrinkBy;
	end[2] -= shrinkBy;

	return LineIntersectsWithRectangle(start, end, biggerRect);
}

// oh hey, I actually figured this one out on my own. yippie.
stock bool:LineIntersectsWithRectangle(const Float:lineStart[3], const Float:lineEnd[3], const Float:rect[2][3])
{
	static Float:tmpStart[3];
	static Float:tmpEnd[3];
	CopyVector(tmpStart, lineStart);
	CopyVector(tmpEnd, lineEnd);
	
	for (new axis = 0; axis < 3; axis++)
	{
		// if the min/max of this line segment exists wholely outside the min/max of the rect's same axis, the line can't intersect
		if (tmpStart[axis] < rect[0][axis] && tmpEnd[axis] < rect[0][axis])
			return false;
		else if (tmpStart[axis] > rect[1][axis] && tmpEnd[axis] > rect[1][axis])
			return false;
			
		// so we know this axis intersects. if the axis is 2, we've succeeded.
		if (axis == 2)
			return true;
			
		// need to preserve the start/end points of this iteration
		static Float:itStart[3];
		static Float:itEnd[3];
		CopyVector(itStart, tmpStart);
		CopyVector(itEnd, tmpEnd);
			
		// shrink the axis and adjust the others accordingly
		if (tmpStart[axis] >= rect[0][axis] && tmpStart[axis] <= rect[1][axis])
		{
			if (tmpEnd[axis] >= rect[0][axis] && tmpEnd[axis] <= rect[1][axis])
				continue; // segment exists entirely in the rectangle's same axis. no action required.
			else if (tmpEnd[axis] < rect[0][axis])
				tmpEnd[axis] = rect[0][axis];
			else if (tmpEnd[axis] > rect[1][axis])
				tmpEnd[axis] = rect[1][axis];
		}
		else if (tmpEnd[axis] >= rect[0][axis] && tmpEnd[axis] <= rect[1][axis])
		{
			if (tmpStart[axis] < rect[0][axis])
				tmpStart[axis] = rect[0][axis];
			else if (tmpStart[axis] > rect[1][axis])
				tmpStart[axis] = rect[1][axis];
		}
		else
		{
			// segment spans beyond the rectangle. clamp on both ends.
			if (tmpStart[axis] < tmpEnd[axis])
			{
				tmpStart[axis] = rect[0][axis];
				tmpEnd[axis] = rect[1][axis];
			}
			else if (tmpStart[axis] > tmpEnd[axis])
			{
				tmpStart[axis] = rect[1][axis];
				tmpEnd[axis] = rect[0][axis];
			}
		}
		
		// adjust the following axes appropriately (previous axes are already tested, therefore out of the equation)
		new Float:startClamp = (tmpStart[axis] == itStart[axis]) ? 0.0 : (fabs(itStart[axis] - tmpStart[axis]) / fabs(itStart[axis] - itEnd[axis]));
		new Float:endClamp = (tmpEnd[axis] == itEnd[axis]) ? 0.0 : (fabs(itEnd[axis] - tmpEnd[axis]) / fabs(itStart[axis] - itEnd[axis]));
		for (new otherAxis = axis + 1; otherAxis < 3; otherAxis++)
		{
			new Float:axisDistance = tmpEnd[otherAxis] - tmpStart[otherAxis];
			tmpStart[otherAxis] += axisDistance * startClamp;
			tmpEnd[otherAxis] -= axisDistance * endClamp;
		}
	}
	
	return false;
}
