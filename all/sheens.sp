#define PLUGIN_VERSION "1.1"
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <tf2_stocks>

public Plugin myinfo =  {
	name = "TF2 Sheens", 
	author = "pear", 
	description = "", 
	version = PLUGIN_VERSION, 
	url = ""
};

Handle hItemSchemaSDK;
Handle hGetAttribSDK;
Handle hRuntimeAttribSDK;
Handle hRemoveAttribSDK;
Handle hDestroyAttribSDK;

char sheens[][] =  {
	"Team Shine", 
	"Deadly Daffodil", 
	"Manndarin", 
	"Mean Green", 
	"Agonizing Emerald", 
	"Villainous Violet", 
	"Hot Rod"
};

char effects[][] =  {
	"Fire Horns", 
	"Cerebral Discharge", 
	"Tornado", 
	"Flames", 
	"Singularity", 
	"Incinerator", 
	"Hypno-Beam"
};

public void OnPluginStart() {
	LoadSDKHandles("tf2.attributes");
	RegAdminCmd("sm_sheen", OnCommand, ADMFLAG_KICK, "Set killstreak effects on weapon");
	CreateConVar("sheens_version", PLUGIN_VERSION);
}

public void LoadSDKHandles(char[] config) {
	Handle cfg = LoadGameConfigFile(config);
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(cfg, SDKConf_Signature, "GEconItemSchema");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hItemSchemaSDK = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(cfg, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinition");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hGetAttribSDK = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(cfg, SDKConf_Signature, "CAttributeList::SetRuntimeAttributeValue");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	hRuntimeAttribSDK = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(cfg, SDKConf_Signature, "CAttributeList::RemoveAttribute");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain); //not a clue what this return is
	hRemoveAttribSDK = EndPrepSDKCall();
	
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(cfg, SDKConf_Signature, "CAttributeList::DestroyAllAttributes");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	hDestroyAttribSDK = EndPrepSDKCall();
}

public bool SetAttrib(int entity, int index, float value) {
	if (!IsValidEntity(entity))return false;
	int offs = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offs <= 0)return false;
	Address pEntity = GetEntityAddress(entity);
	if (pEntity == Address_Null)return false;
	Address pSchema = SDKCall(hItemSchemaSDK);
	if (pSchema == Address_Null)return false;
	Address pAttribDef = SDKCall(hGetAttribSDK, pSchema, index);
	static Address Address_MinimumValid = view_as<Address>(0x10000);
	if (pAttribDef == Address_Null)return false;
	int res;
	if (view_as<int>(pAttribDef) == view_as<int>(Address_MinimumValid))res = 0;
	if ((view_as<int>(pAttribDef) >>> 31) == (view_as<int>(Address_MinimumValid) >>> 31)) {
		res = ((view_as<int>(pAttribDef) & 0x7FFFFFFF) > (view_as<int>(Address_MinimumValid) & 0x7FFFFFFF)) ? 1 : -1;
	}
	res = ((view_as<int>(pAttribDef) >>> 31) > (view_as<int>(Address_MinimumValid) >>> 31)) ? 1 : -1;
	if (res >= 0)return false;
	SDKCall(hRuntimeAttribSDK, pEntity + view_as<Address>(offs), pAttribDef, value);
	return true;
}

public bool RemoveAttrib(int entity, int index) {
	if (!IsValidEntity(entity))return false;
	int offs = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offs <= 0)return false;
	Address pEntity = GetEntityAddress(entity);
	if (pEntity == Address_Null)return false;
	if (pEntity == Address_Null)return false;
	Address pSchema = SDKCall(hItemSchemaSDK);
	if (pSchema == Address_Null)return false;
	Address pAttribDef = SDKCall(hGetAttribSDK, pSchema, index);
	static Address Address_MinimumValid = view_as<Address>(0x10000);
	if (pAttribDef == Address_Null)return false;
	int res;
	if (view_as<int>(pAttribDef) == view_as<int>(Address_MinimumValid))res = 0;
	if ((view_as<int>(pAttribDef) >>> 31) == (view_as<int>(Address_MinimumValid) >>> 31)) {
		res = ((view_as<int>(pAttribDef) & 0x7FFFFFFF) > (view_as<int>(Address_MinimumValid) & 0x7FFFFFFF)) ? 1 : -1;
	}
	res = ((view_as<int>(pAttribDef) >>> 31) > (view_as<int>(Address_MinimumValid) >>> 31)) ? 1 : -1;
	if (res >= 0)return false;
	SDKCall(hRemoveAttribSDK, pEntity + view_as<Address>(offs), pAttribDef);
	return true;
}

public bool ResetAttribs(int entity) {
	if (!IsValidEntity(entity))return false;
	int offs = GetEntSendPropOffs(entity, "m_AttributeList", true);
	if (offs <= 0)return false;
	Address pEntity = GetEntityAddress(entity);
	if (pEntity == Address_Null)return false;
	SDKCall(hDestroyAttribSDK, pEntity + view_as<Address>(offs)); //disregard the return (Valve does!)
	return true;
}

public Action OnCommand(int client, int args) {
	CreateMenu1(client);
	return Plugin_Handled;
}

void AddKsType(int client, int index, float value) {
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	SetAttrib(weapon, index, value);
}

void CreateMenu1(int client) {
	Menu menu = CreateMenu(Menu1);
	SetMenuTitle(menu, "Type");
	AddMenuItem(menu, "0", "Off");
	AddMenuItem(menu, "1", "Normal");
	AddMenuItem(menu, "2", "Specalized");
	AddMenuItem(menu, "3", "Professional");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
}

void CreateMenu2(int client, bool prof) {
	Menu menu;
	if (prof)menu = CreateMenu(Menu2_Ext);
	else menu = CreateMenu(Menu2);
	SetMenuTitle(menu, "Sheen");
	for (int i = 0; i < sizeof(sheens); i++) {
		char num[32]; IntToString(i, num, sizeof(num));
		AddMenuItem(menu, num, sheens[i]);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
}

void CreateMenu3(int client, char[] sheen) {
	Menu menu = CreateMenu(Menu3);
	SetMenuTitle(menu, "Effect");
	for (int i = 0; i < sizeof(effects); i++) {
		char num[32]; IntToString(2001 + i, num, sizeof(num));
		AddMenuItem(menu, num, effects[i]);
	}
	AddMenuItem(menu, sheen, "", ITEMDRAW_IGNORE);
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
}

public int Menu1(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End)delete menu;
	if (action == MenuAction_Select) {
		switch (item) {
			case 0: {
				AddKsType(client, 2013, 0.0);
				AddKsType(client, 2014, 0.0);
				AddKsType(client, 2025, 0.0);
				PrintToChat(client, "[Sheen] Disabled weapon killstreak");
			}
			case 1: {
				AddKsType(client, 2025, 1.0);
				PrintToChat(client, "[Sheen] Enabled weapon killstreak");
			}
			case 2: {
				AddKsType(client, 2025, 2.0);
				CreateMenu2(client, false);
			}
			case 3: {
				AddKsType(client, 2025, 3.0);
				CreateMenu2(client, true);
			}
		}
	}
	return 0;
}

public int Menu2(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End)delete menu;
	if (action == MenuAction_Select) {
		char info[32]; GetMenuItem(menu, item, info, sizeof(info));
		AddKsType(client, 2014, StringToFloat(info) + 1);
		PrintToChat(client, "[Sheen] Set weapon sheen to '%s'", sheens[item]);
	}
	return 0;
}

public int Menu2_Ext(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End)delete menu;
	if (action == MenuAction_Select) {
		char info[32]; GetMenuItem(menu, item, info, sizeof(info));
		AddKsType(client, 2014, StringToFloat(info) + 1);
		CreateMenu3(client, sheens[item]);
	}
}

public int Menu3(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End)delete menu;
	if (action == MenuAction_Select) {
		char info[32]; GetMenuItem(menu, item, info, sizeof(info));
		char sheen[32]; GetMenuItem(menu, GetMenuItemCount(menu) - 1, sheen, sizeof(sheen));
		AddKsType(client, 2013, StringToFloat(info) + 1);
		PrintToChat(client, "[Sheen] Set sheen to '%s' and effect to '%s'", sheen, effects[item]);
	}
} 