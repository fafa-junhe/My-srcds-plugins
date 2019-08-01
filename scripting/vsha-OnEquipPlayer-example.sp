// vsha-OnEquipPlayer-example.sp
#include <tf2attributes>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>


public Plugin myinfo = {
	name = "Versus Saxton Hale OnEquipPlayer Addon",
	author = "Diablo",
	description = "OnEquipPlayer External Example",
	version = "1.0",
	url = "https://github.com/War3Evo/VSH-Advanced"
};


//#define OVERRIDE_MEDIGUNS_ON

ConVar EnableEurekaEffect;
ConVar SetupEquipment;

bool bMedieval;

// from FF2
/**
 *
 * Gives ammo to a weapon
 *
 * @param client	Client's index
 * @param weapon	Weapon
 * @param ammo		Ammo (set to 1 for clipless weapons, then set the actual ammo using clip)
 * @param clip		Clip
 * @noreturn
 */
stock void FF2_SetAmmo(int client, int weapon, int ammo=-1, int clip=-1)
{
	if(IsValidEntity(weapon))
	{
		if(clip>-1)
		{
			SetEntProp(weapon, Prop_Data, "m_iClip1", clip);
		}

		int ammoType=(ammo>-1 ? GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType") : -1);
		if(ammoType!=-1)
		{
			SetEntProp(client, Prop_Data, "m_iAmmo", ammo, _, ammoType);
		}
		else if(ammo>-1)  //Only complain if we're trying to set ammo
		{
			char classname[64];
			GetEdictClassname(weapon, classname, sizeof(classname));
			LogError("[VSHA] FF2-Equipment - Cannot give ammo to weapon %s", classname);
		}
	}
}

stock int FindPlayerBack_FF2(int client, int index)
{
	int entity=MaxClients+1;
	while((entity=FindEntityByClassname2(entity, "tf_wearable"))!=-1)
	{
		char netclass[32];
		if(GetEntityNetClass(entity, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable") && GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex")==index && GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
		{
			return entity;
		}
	}
	return -1;
}

// from VSH
stock void SetAmmo(int client, int wepslot, int newAmmo)
{
	int weapon = GetPlayerWeaponSlot(client, wepslot);
	if (!IsValidEntity(weapon)) return;
	int type = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (type < 0 || type > 31) return;
	SetEntProp(client, Prop_Send, "m_iAmmo", newAmmo, _, type);
}

public void OnAllPluginsLoaded()
{
	VSHAHook(VSHAHook_OnEquipPlayer_Pre, OnEquipPlayer_Pre);

	EnableEurekaEffect = FindConVar("vsha_alloweureka");

	SetupEquipment = CreateConVar("vsha_equipment", "0", "0 default, 1 to use VSH Equipement, 2 to use FF2 Equipement", FCVAR_PLUGIN, true, 0.0, true, 1.0);

	bMedieval=FindEntityByClassname(-1, "tf_logic_medieval")!=-1 || GetConVarBool(FindConVar("tf_medieval"));
}

public Action OnEquipPlayer_Pre(int iClient)
{
	if(!ValidPlayer(iClient)) return Plugin_Continue;

	if(SetupEquipment.IntValue == 1)
	{
		return MakeNoBoss_VSH(iClient);
	}

	if(SetupEquipment.IntValue == 2)
	{
		return CheckItems_FF2(iClient);
	}

	return Plugin_Continue;
}


public Action Timer_RemoveHonorBound(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
		int index = GetItemIndex(weapon);
		int active = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		char classname[64]; GetEdictClassname(active, classname, sizeof(classname));
		if (index == 357 && active == weapon && strcmp(classname, "tf_weapon_katana", false) == 0)
		{
			SetEntProp(weapon, Prop_Send, "m_bIsBloody", 1);
			if (GetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy") < 1) SetEntProp(client, Prop_Send, "m_iKillCountSinceLastDeploy", 1);
		}
	}
	return Plugin_Continue;
}

// copied from:
//https://github.com/Chdata/Versus-Saxton-Hale/blob/master/addons/sourcemod/scripting/saxtonhale.sp#L3003-L3301
public Action MakeNoBoss_VSH(int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");

	// VSHA handles team changes internally
	//ChangeTeam(client, OtherTeam);
	//TF2_RegeneratePlayer(client);

	//SetEntityRenderColor(client, 255, 255, 255, 255);

	//HelpPanel2(client);

#if defined _tf2attributes_included
	if (IsValidEntity(FindPlayerBack(client, { 444 }, 1)))    //  Fixes mantreads to have jump height again
	{
		TF2Attrib_SetByDefIndex(client, 58, 1.8);          //  "self dmg push force increased"
	}
	else
	{
		TF2Attrib_RemoveByDefIndex(client, 58);
	}
#endif

	int weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	int index = -1;
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 41:    // ReplacelistPrimary
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_minigun", 15, 1, 0, "");
			}
			case 402:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_sniperrifle", 14, 1, 0, "");
			}
			case 772, 448: // Block BFB and Soda Popper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_scattergun", 13, 1, 0, "");
			}
			case 237:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 99999.0");
				SetAmmo(client, 0, 20);
			}
			case 17, 204, 36, 412:
			{
				if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_syringegun_medic", 17, 1, 10, "17 ; 0.05 ; 144 ; 1");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
//          case 226:
//          {
//              TF2_RemoveWeaponSlot(client, 1);
//              weapon = SpawnWeapon(client, "tf_weapon_shotgun_soldier", 10, 1, 0, "");
//          }
			case 528:   // ReplacelistSecondary
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_laser_pointer", 140, 1, 0, "");
			}
			case 46, 1145:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_lunchbox_drink", 163, 1, 0, "144 ; 2");
			}
			case 57:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
			}
			case 265:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
				SetAmmo(client, 1, 24);
			}
//          case 39, 351:
//          {
//              if (GetEntProp(weapon, Prop_Send, "m_iEntityQuality") != 10)
//              {
//                  TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
//                  weapon = SpawnWeapon(client, "tf_weapon_flaregun", 39, 5, 10, "25 ; 0.5 ; 207 ; 1.33 ; 144 ; 1.0 ; 58 ; 3.2")
//              }
//          }
		}
	}
	if (IsValidEntity(FindPlayerBack(client, { 57 }, 1)))
	{
		RemovePlayerBack(client, { 57 }, 1);
		SpawnWeapon(client, "tf_weapon_smg", 16, 1, 0, "");
	}
	if (IsValidEntity(FindPlayerBack(client, { 642 }, 1)))
	{
		SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85");
	}
	weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if (weapon > MaxClients && IsValidEdict(weapon))
	{
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch (index)
		{
			case 331:
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				SpawnWeapon(client, "tf_weapon_fists", 195, 1, 6, "");
			}
			case 357:
			{
				CreateTimer(1.0, Timer_RemoveHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			case 589:
			{
				if (!EnableEurekaEffect.BoolValue)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	weapon = GetPlayerWeaponSlot(client, 4);
	if (weapon > MaxClients && IsValidEdict(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") == 60)
	{
		TF2_RemoveWeaponSlot(client, 4);
		SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
	}
	if (TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		weapon = GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
		#if defined OVERRIDE_MEDIGUNS_ON
		if (GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel") < 0.41)
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.41);
		#endif

		#if !defined OVERRIDE_MEDIGUNS_ON
		int mediquality = (weapon > MaxClients && IsValidEdict(weapon) ? GetEntProp(weapon, Prop_Send, "m_iEntityQuality") : -1);
		if (mediquality != 10)
		{
			TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
			weapon = SpawnWeapon(client, "tf_weapon_medigun", 35, 5, 10, "18 ; 0.0 ; 10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0");  //200 ; 1 for area of effect healing    // ; 178 ; 0.75 ; 128 ; 1.0 Faster switch-to
			if (GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 142)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, 75); // What is the point of making gunslinger translucent? When will a medic ever even have a gunslinger equipped???
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.41);
		}
		#endif
	}

	// VSH usually does this during damage detections, but should probably not,
	// so we detect ahead of time
	int entity=-1;
	while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)  //Demoshields
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
		{
			break;
		}
	}

	VSHA_SetShield(client, entity);

	return Plugin_Changed;
}


// copied from
//https://github.com/50DKP/FF2-Official/blob/stable/addons/sourcemod/scripting/freak_fortress_2.sp#L3727-L3917
public Action CheckItems_FF2(int userid)
{
	int client=GetClientOfUserId(userid);
	if(!IsValidClient(client) || !IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}

	SetEntityRenderColor(client, 255, 255, 255, 255);
	int shield=0;
	int index=-1;
	int civilianCheck;

	if(bMedieval)  //Make sure players can't stay cloaked forever in medieval mode
	{
		int weapon=GetPlayerWeaponSlot(client, 4);
		if(weapon && IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==60)  //Cloak and Dagger
		{
			TF2_RemoveWeaponSlot(client, 4);
			weapon=SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
		}
		return Plugin_Continue;
	}

	int weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Primary);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 17, 36, 204, 412:  //Syringe Gun, Blutsauger, Strange Syringe Gun, Overdose
			{
				if(GetEntProp(weapon, Prop_Send, "m_iEntityQuality")!=10)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
					SpawnWeapon(client, "tf_weapon_syringegun_medic", (index==204 ? 204 : 17), 1, 10, "17 ; 0.05 ; 144 ; 1");  //Strange if possible
						//17: +5 uber/hit
						//144:  NOOP
				}
			}
			case 41:  //Natascha
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_minigun", 15, 1, 0, "");
			}
			case 237:  //Rocket Jumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				weapon=SpawnWeapon(client, "tf_weapon_rocketlauncher", 18, 1, 0, "265 ; 99999.0");
					//265: Mini-crits airborne targets for 99999 seconds
				FF2_SetAmmo(client, weapon, 20);
			}
			case 402:  //Bazaar Bargain
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Primary);
				SpawnWeapon(client, "tf_weapon_sniperrifle", 14, 1, 0, "");
			}
		}
	}
	else
	{
		civilianCheck++;
	}

	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Secondary);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 265:  //Stickybomb Jumper
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
				weapon=SpawnWeapon(client, "tf_weapon_pipebomblauncher", 20, 1, 0, "");
				FF2_SetAmmo(client, weapon, 24);
			}
		}

		if(TF2_GetPlayerClass(client)==TFClass_Medic && GetEntProp(weapon, Prop_Send, "m_iEntityQuality")!=10)  //10 means the weapon is customized, so we don't want to touch those
		{
			switch(index)
			{
				case 211, 663, 796, 805, 885, 894, 903, 912, 961, 970:  //Renamed/Strange, Festive, Silver Botkiller, Gold Botkiller, Rusty Botkiller, Bloody Botkiller, Carbonado Botkiller, Diamond Botkiller Mk.II, Silver Botkiller Mk.II, and Gold Botkiller Mk.II Mediguns
				{
					//NOOP
				}
				default:
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Secondary);
					weapon=SpawnWeapon(client, "tf_weapon_medigun", 29, 5, 10, "10 ; 1.25 ; 178 ; 0.75 ; 144 ; 2.0 ; 11 ; 1.5");
						//Switch to regular medigun
						//10: +25% faster charge rate
						//178: +25% faster weapon switch
						//144: Quick-fix speed/jump effects
						//11: +50% overheal bonus
				}
			}
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.40);

			if(GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee)==142)  //Gunslinger (Randomizer, etc. compatability)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, 75);
			}
		}
	}
	else
	{
		civilianCheck++;
	}

	int playerBack=FindPlayerBack_FF2(client, 57);  //Razorback
	shield=playerBack!=-1 ? playerBack : 0;
	if(IsValidEntity(FindPlayerBack_FF2(client, 642)))  //Cozy Camper
	{
		weapon=SpawnWeapon(client, "tf_weapon_smg", 16, 1, 6, "149 ; 1.5 ; 15 ; 0.0 ; 1 ; 0.85");
	}

	#if defined _tf2attributes_included
	//if(tf2attributes)
	//{
		if(IsValidEntity(FindPlayerBack_FF2(client, 444)))  //Mantreads
		{
			TF2Attrib_SetByDefIndex(client, 58, 1.5);  //+50% increased push force
		}
		else
		{
			TF2Attrib_RemoveByDefIndex(client, 58);
		}
	//}
	#endif

	int entity=-1;
	while((entity=FindEntityByClassname2(entity, "tf_wearable_demoshield"))!=-1)  //Demoshields
	{
		if(GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")==client && !GetEntProp(entity, Prop_Send, "m_bDisguiseWearable"))
		{
			shield=entity;
		}
	}

	VSHA_SetShield(client, shield);

	weapon=GetPlayerWeaponSlot(client, TFWeaponSlot_Melee);
	if(weapon && IsValidEdict(weapon))
	{
		index=GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		switch(index)
		{
			case 43:  //KGB
			{
				TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
				weapon=SpawnWeapon(client, "tf_weapon_fists", 239, 1, 6, "1 ; 0.5 ; 107 ; 1.5 ; 128 ; 1 ; 191 ; -7");  //GRU
					//1: -50% damage
					//107: +50% move speed
					//128: Only when weapon is active
					//191: -7 health/second
			}
			case 357:  //Half-Zatoichi
			{
				CreateTimer(1.0, Timer_RemoveHonorBound, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			case 589:  //Eureka Effect
			{
				if (!EnableEurekaEffect.BoolValue)
				{
					TF2_RemoveWeaponSlot(client, TFWeaponSlot_Melee);
					weapon=SpawnWeapon(client, "tf_weapon_wrench", 7, 1, 0, "");
				}
			}
		}
	}
	else
	{
		civilianCheck++;
	}

	weapon=GetPlayerWeaponSlot(client, 4);
	if(weapon && IsValidEntity(weapon) && GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")==60)  //Cloak and Dagger
	{
		TF2_RemoveWeaponSlot(client, 4);
		weapon=SpawnWeapon(client, "tf_weapon_invis", 30, 1, 0, "");
	}

	if(civilianCheck==3)
	{
		//civilianCheck[client]=0;
		CPrintToChat(client, "{olive}[VSHA][FF2]{default} Respawning you because you have no weapons!");
		TF2_RespawnPlayer(client);
	}
	//civilianCheck[client]=0;
	return Plugin_Changed;
}
