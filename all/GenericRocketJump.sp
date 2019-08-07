/*
 *descriptions here
 */

new const String:PLUGIN_VERSION[60] = "1.0.0.2";

public Plugin:myinfo = {
	
	name = "GenericRocketJump",
	author = "javalia",
	description = "Customizable Rocket Jump",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
	
};

//uncomment if u wanna use function of these include file
#include <sourcemod>
#include <sdktools>
//#include <cstrike>
#include "sdkhooks"
//#include "vphysics"
#include "stocklib"

//semicolon!!!!
#pragma semicolon 1

new Handle:g_cvarUnassignedTeamEnable = INVALID_HANDLE;
new Handle:g_cvarBlueTeamEnable = INVALID_HANDLE;
new Handle:g_cvarRedTeamEnable = INVALID_HANDLE;

new Handle:g_cvarRocketJumpWeapons = INVALID_HANDLE;

new Handle:g_cvarRocketJumpDamage = INVALID_HANDLE;

new Handle:g_cvarRocketJumpForce = INVALID_HANDLE;

new Handle:g_cvarRocketJumpTeamMate = INVALID_HANDLE;
new Handle:g_cvarRocketJumpEnemy = INVALID_HANDLE;

public OnPluginStart(){

	CreateConVar("genericrocketjumpmod_version", PLUGIN_VERSION, "plugin info cvar", FCVAR_REPLICATED | FCVAR_NOTIFY);
	
	g_cvarUnassignedTeamEnable = CreateConVar("genericrocketjumpmod_unassignedteam_enable", "1", "1 for enable 0 for disable");
	g_cvarBlueTeamEnable = CreateConVar("genericrocketjumpmod_blueteam_enable", "1", "1 for enable 0 for disable");
	g_cvarRedTeamEnable = CreateConVar("genericrocketjumpmod_redteam_enable", "1", "1 for enable 0 for disable");

	g_cvarRocketJumpWeapons = CreateConVar("genericrocketjumpmod_weapons", "grenade_ar2;rpg_missile;hegrenade_projectile", "weapon list of RocketJump, separate with ;");

	g_cvarRocketJumpDamage = CreateConVar("genericrocketjumpmod_damage", "0.2", "damage reduce by rocketjump weapon");

	g_cvarRocketJumpForce = CreateConVar("genericrocketjumpmod_jumpforce", "10.0", "jump force of rocketjump");

	g_cvarRocketJumpTeamMate = CreateConVar("genericrocketjumpmod_teammate", "0", "allow rocket jump by teammate`s fire?");
	g_cvarRocketJumpEnemy = CreateConVar("genericrocketjumpmod_teammate", "0", "allow rocket jump by enemy`s fire?");
	
	AutoExecConfig();

}

public OnMapStart(){

	AutoExecConfig();

}

public OnClientPutInServer(client){

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageHook);

}

public Action:OnTakeDamageHook(client, &attacker, &inflictor, &Float:damage, &damagetype){
	
	if(~damagetype & DMG_BLAST){
	
		return Plugin_Continue;
	
	}
	
	if(isClientEffectedByRocketJump(client, attacker) && isRocketJumpWeapon(inflictor)){
		
		//�ڽ��� ���� �̵��ӵ���, ���߷� ���� �̵��ӵ��� ���Ѵ�.
		decl Float:vec_PlayerSpeed[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec_PlayerSpeed);
		
		//���߹��κ��� �ڽ��� ��ġ���� �븻���͸� ���Ѵ�
		decl Float:vec_PlayerPos[3], Float:vec_InflcitorPos[3], Float:vec_Direction[3];
		
		GetClientAbsOrigin(client, vec_PlayerPos);
		GetEntPropVector(inflictor, Prop_Send, "m_vecOrigin", vec_InflcitorPos);
		
		MakeVectorFromPoints(vec_InflcitorPos, vec_PlayerPos, vec_Direction);
		NormalizeVector(vec_Direction, vec_Direction);
		
		//�������� �ٰ��� �븻���͸� Ű���.
		ScaleVector(vec_Direction, damage * GetConVarFloat(g_cvarRocketJumpForce));
		AddVectors(vec_PlayerSpeed, vec_Direction, vec_PlayerSpeed);
		
		//�������� ���δ�
		damage = damage * GetConVarFloat(g_cvarRocketJumpDamage);
		
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec_PlayerSpeed);
		
		return Plugin_Changed;
		
	}
	
	return Plugin_Continue;
	
}

bool:isClientEffectedByRocketJump(client, attacker){

	//�켱 Ŭ���� ���� �������� ���� ���Ѵ�
	new clientteam = GetClientTeam(client);
	new attackerteam = IsClientConnectedIngame(attacker) ? GetClientTeam(attacker) : 0;
	
	//Ŭ���� ���� ���� ������ ����Ǵ� ���ΰ�?
	if((clientteam == 0 && GetConVarBool(g_cvarUnassignedTeamEnable))
		|| (clientteam == 2 && GetConVarBool(g_cvarRedTeamEnable))
		|| (clientteam == 3 && GetConVarBool(g_cvarBlueTeamEnable))){
		
		if((client == attacker) || ((clientteam == attackerteam) && GetConVarBool(g_cvarRocketJumpTeamMate))
			|| ((clientteam != attackerteam) && GetConVarBool(g_cvarRocketJumpEnemy))){
		
			return true;
		
		}
		
	}
	
	return false;

}

bool:isRocketJumpWeapon(inflictor){

	new String:weaponname[32];
	GetEdictClassname(inflictor, weaponname, 32);
	
	decl String:cvarstring[256];
	GetConVarString(g_cvarRocketJumpWeapons, cvarstring, 256);
	
	if(StrContains(cvarstring, weaponname, false) != -1){
		
		return true;
		
	}

	return false;
	
}