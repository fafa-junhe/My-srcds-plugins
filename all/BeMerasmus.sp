/* Script generated by SourcePawn IDE */

#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>

#define PLUGIN_VERSION "0.5"
#define MERASMUS "models/bots/merasmus/merasmus.mdl"
#define DOOM1	"vo/halloween_merasmus/sf12_appears04.wav"
#define DOOM2	"vo/halloween_merasmus/sf12_appears09.wav"
#define DOOM3	"vo/halloween_merasmus/sf12_appears01.wav"

#define DEATH1	"vo/halloween_merasmus/sf12_defeated01.wav"
#define DEATH2	"vo/halloween_merasmus/sf12_defeated06.wav"
#define DEATH3	"vo/halloween_merasmus/sf12_defeated08.wav"

#define HELLFIRE "vo/halloween_merasmus/sf12_ranged_attack08.wav"
#define HELLFIRE2 "vo/halloween_merasmus/sf12_ranged_attack04.wav"
#define HELLFIRE3 "vo/halloween_merasmus/sf12_ranged_attack05.wav"

new bool:MerasmusAlive[MAXPLAYERS + 1];
new bool:IsTaunting;
new bool:IsMerasmus[MAXPLAYERS + 1];

new Handle:c_Health = INVALID_HANDLE;
new ParticleIndex;

public Plugin:myinfo =
{
    name = "Be The Merasmus!",
    author = "Starman4xz",
    description = "Be The Merasmus!",
    version = PLUGIN_VERSION,
    url = ""
}

public OnPluginStart()
{
    CreateConVar("_version", PLUGIN_VERSION, "", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    RegAdminCmd("sm_bmerasmus", Command_Merasmus, ADMFLAG_SLAY);
    HookEvent("player_death", Event_Death,  EventHookMode_Post);
    LoadTranslations("common.phrases");
    c_Health = CreateConVar("sm_merasmus_hp", "5000", "Sets the health the player playing Merasmus will have");
    HookEvent("post_inventory_application", Event_RedoModel, EventHookMode_Post);
}

public OnMapStart()
{
PrecacheModel(MERASMUS, true);
PrecacheSound(DOOM1, true);
PrecacheSound(DOOM2, true);
PrecacheSound(DOOM3, true);

PrecacheSound(DEATH1, true);
PrecacheSound(DEATH2, true);
PrecacheSound(DEATH3, true);

PrecacheSound(HELLFIRE, true);
PrecacheSound(HELLFIRE2, true);
PrecacheSound(HELLFIRE3, true);
}

public Action:Command_Merasmus(client, args)
{

	new String:arg1[32];
		
	GetCmdArg (1, arg1, sizeof(arg1));
	

	new String:target_name[MAX_TARGET_LENGTH]
	new target_list[MAXPLAYERS], target_count
	new bool:tn_is_ml
 
	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	
	BuildMerasmus(target_list[i]);
	
	return Plugin_Handled;
}

public Action:BuildMerasmus(client)
{
	SetModel(client, MERASMUS);
	SpawnSound();
	BuildParticle(client, "merasmus_ambient_body");
	MerasmusAlive[client] = true;
	IsMerasmus[client] = true;
	BuildClub(client);
	
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");
	
	SetEntProp(client, Prop_Data, "m_iHealth", GetConVarInt(c_Health));
}

public Action:SetModel(client, const String:model[])
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetVariantString(model);
		AcceptEntityInput(client, "SetCustomModel");

		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);

		
	}
}

public SpawnSound()
{
	new soundswitch;
	soundswitch = GetRandomInt(1, 3);

		
		switch(soundswitch)
		{
			case 1:
			{
			EmitSoundToAll(DOOM1);
			}
			
			case 2:
			{
			EmitSoundToAll(DOOM2);
			}
			
			case 3:
			{
			EmitSoundToAll(DOOM3);
			}
		}
}

// Thanks flamin for this wonderful stock.
public Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
		if (IsValidClient(client) && MerasmusAlive[client] == true)
		{
//			DoHorsemannDeath(client);
			//EmitSoundToAll(SAXTONDEATH);
			DeathSounds();
			MerasmusAlive[client] = false;
			IsMerasmus[client] = false;
			RemoveMerasmus(client);
			RemoveParticle();
			}
}

public DeathSounds()
{
	new soundswitch;
	soundswitch = GetRandomInt(1, 3);

		
		switch(soundswitch)
		{
			case 1:
			{
			EmitSoundToAll(DEATH1);
			}
			
			case 2:
			{
			EmitSoundToAll(DEATH2);
			}
			
			case 3:
			{
			EmitSoundToAll(DEATH3);
			}
		}
}

public BuildParticle(client, const String:path[32])
{
		new TParticle = CreateEntityByName("info_particle_system");
		if (IsValidEdict(TParticle))
		{
		new Float:pos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		
		TeleportEntity(TParticle, pos, NULL_VECTOR, NULL_VECTOR);
		
		DispatchKeyValue(TParticle, "effect_name", path);
		
		DispatchKeyValue(TParticle, "targetname", "particle");
		
		SetVariantString("!activator");
		AcceptEntityInput(TParticle, "SetParent", client, TParticle, 0);
		
		SetVariantString("effect_robe");
		AcceptEntityInput(TParticle, "SetParentAttachment", TParticle, TParticle, 0);
	
		DispatchSpawn(TParticle);
		ActivateEntity(TParticle);
		AcceptEntityInput(TParticle, "Start");
		
		ParticleIndex = TParticle;
		}
}

stock bool:IsValidClient(client) 
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
//	if (!IsClientConnected(client)) return false; // Thanks again sarge.
	return IsClientInGame(client);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
      if (buttons & IN_ATTACK2 && MerasmusAlive[client] == true && IsTaunting != true && IsMerasmus[client] == true)
	  { 
	  		  
		TF2_StunPlayer(client, Float:3.0, Float:1.0, TF_STUNFLAGS_LOSERSTATE);
		MakePlayerInvisible(client, 0);
		
		
		new Model = CreateEntityByName("prop_dynamic");
		if (IsValidEdict(Model))
		{
		IsTaunting = true;
		new Float:pos[3], Float:angles[3];
		decl String:ClientModel[256], String:Skin[2];
		
		GetClientModel(client, ClientModel, sizeof(ClientModel));
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		TeleportEntity(Model, pos, NULL_VECTOR, NULL_VECTOR);
		GetClientEyeAngles(client, angles);
		angles[0] = 0.0;
		angles[2] = 0.0;
		IntToString(GetClientTeam(client)-2, Skin, sizeof(Skin));
		
		DispatchKeyValue(Model, "skin", Skin);
		DispatchKeyValue(Model, "model", ClientModel);
		DispatchKeyValue(Model, "DefaultAnim", "zap_attack");	
		DispatchKeyValueVector(Model, "angles", angles);
		
		DispatchSpawn(Model);
		
		SetVariantString("OnAnimationDone !self:KillHierarchy::0.0:1");
		AcceptEntityInput(Model, "AddOutput");
		
		CreateTimer(Float:1.0, DoHellfire, client);
		
		PlayHellfire();
		
		CreateTimer(Float:2.8, ResetTaunt, client);
		
		
		}
	}
	if (!(GetEntityFlags(client) & FL_ONGROUND))
	{
	return Plugin_Continue;
	}


}

stock MakePlayerInvisible(client, alpha)
{
	SetWeaponsAlpha(client, alpha);
	SetWearablesAlpha(client, alpha);
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, alpha);
}

stock SetWeaponsAlpha (client, alpha){
	decl String:classname[64];
	new m_hMyWeapons = FindSendPropOffs("CBasePlayer", "m_hMyWeapons");
	for(new i = 0, weapon; i < 189; i += 4)
	{
		weapon = GetEntDataEnt2(client, m_hMyWeapons + i);
		if(weapon > -1 && IsValidEdict(weapon))
		{
			GetEdictClassname(weapon, classname, sizeof(classname));
			if(StrContains(classname, "tf_weapon", false) != -1 || StrContains(classname, "tf_wearable", false) != -1)
			{
				SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
				SetEntityRenderColor(weapon, 255, 255, 255, alpha);
			}
		}
	}
}

stock SetWearablesAlpha (client, alpha){
	if(IsPlayerAlive(client))
	{
		new Float:pos[3], Float:wearablepos[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
		new wearable= -1;
		while ((wearable= FindEntityByClassname(wearable, "tf_wearable")) != -1)
		{
			GetEntPropVector(wearable, Prop_Data, "m_vecAbsOrigin", wearablepos);
			if (GetVectorDistance(pos, wearablepos, true) < 2)
			{
				SetEntityRenderMode(wearable, RENDER_TRANSCOLOR);
				SetEntityRenderColor(wearable, 255, 255, 255, alpha);
			}
		}
		while ((wearable= FindEntityByClassname(wearable, "tf_wearable_item_demoshield")) != -1)
		{
			GetEntPropVector(wearable, Prop_Data, "m_vecAbsOrigin", wearablepos); 
			if (GetVectorDistance(pos, wearablepos, true) < 2)
			{
				SetEntityRenderMode(wearable, RENDER_TRANSCOLOR);
				SetEntityRenderColor(wearable, 255, 255, 255, alpha);
			}
		}
	}
}

public Action:DoHellfire(Handle:timer, any:client)
{
	new Float:vec[3];
	GetClientEyePosition(client, vec);
	
		
	for(new i=1; i<=MaxClients; i++)
	{
		// Check for a valid client
		if(!IsClientInGame(i) || !IsPlayerAlive(i)) continue;
		
		new Float:pos[3];
		GetClientEyePosition(i, pos);
		
		new Float:distance = GetVectorDistance(vec, pos);
		
		new Float:dist = 310.0;
		
				
		if(distance < dist)
		{
			if (i == client) continue;
		
			new Float:vecc[3];
			
			vecc[0] = 0.0;
			vecc[1] = 0.0;
			vecc[2] = 1500.0;
			
			TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vecc);
  			TF2_IgnitePlayer(i, client);
			//PrintToChatAll("Should be rocketing..");
			
		}
	}
}

public Action:ResetTaunt(Handle:timer, any:client)
{
IsTaunting = false;
MakePlayerInvisible(client, 255);

}

public RemoveParticle()
{
	if (IsValidEntity(ParticleIndex))
	{
		AcceptEntityInput(ParticleIndex, "Kill");
	}
	
	
}

public Action:BuildClub(client)
{
	//TF2_RemoveWeaponSlot(client, 0);
	//TF2_RemoveWeaponSlot(client, 1);
	//if (TF2_GetPlayerClass(client) == 8){  // Nope. Sorry spy.
	//TF2_RemoveWeaponSlot(client, 4);
	TF2_RemoveAllWeapons(client); // Better method.
	
		new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon != INVALID_HANDLE)
	{
		TF2Items_SetClassname(hWeapon, "tf_weapon_club");
		TF2Items_SetItemIndex(hWeapon, 3);
		TF2Items_SetLevel(hWeapon, 100);
		TF2Items_SetQuality(hWeapon, 5);
		TF2Items_SetNumAttributes(hWeapon, 9); // Atrib Number Total
		
		TF2Items_SetAttribute(hWeapon, 0, 2, 100.0);
		TF2Items_SetAttribute(hWeapon, 1, 4, 91.0);
		TF2Items_SetAttribute(hWeapon, 3, 6, 0.25);
		TF2Items_SetAttribute(hWeapon, 4, 110, 500.0);
		TF2Items_SetAttribute(hWeapon, 5, 26, 250.0);
		TF2Items_SetAttribute(hWeapon, 6, 31, 10.0);
		TF2Items_SetAttribute(hWeapon, 7, 107, 3.0);
		TF2Items_SetAttribute(hWeapon, 8, 97, 0.4);
		TF2Items_SetAttribute(hWeapon, 9, 134, 4.0);
		
				
		
		new weapon = TF2Items_GiveNamedItem(client, hWeapon);
		EquipPlayerWeapon(client, weapon);

		CloseHandle(hWeapon);
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", 0);
		
	}	
}

public PlayHellfire()
{
	new soundswitch;
	soundswitch = GetRandomInt(1, 3);

		
		switch(soundswitch)
		{
			case 1:
			{
			EmitSoundToAll(HELLFIRE);
			}
			
			case 2:
			{
			EmitSoundToAll(HELLFIRE2);
			}
			
			case 3:
			{
			EmitSoundToAll(HELLFIRE3);
			}
		}
}

public RemoveMerasmus(client)
{
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel");
}

public Action:Event_RedoModel(Handle:event, const String:name[], bool:dontBroadcast)
{
	new merasmus = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsMerasmus[merasmus] == true){
	SetModel(merasmus, MERASMUS);
	BuildClub(merasmus);}
	return Plugin_Continue;
}
