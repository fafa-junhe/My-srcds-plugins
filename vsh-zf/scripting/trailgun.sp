#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <vphysics>
#include <clientprefs>

#define PLUGIN_VERSION "1.0"
#define MAX_BUTTONS 25

public Plugin myinfo = {
	name = "[TF2] Trail Gun",
	author = "Nanochip",
	description = "Shoots props with a trail attached",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/xNanochip"
};

ConVar cvWeapon, cvWeaponSlot, cvButton, cvDespawnTime, cvDelayTime;
Handle cTrailGun, cTrailType, cTrailColor, cTrailProp;
char g_sWeapon[32];
int g_iWeaponSlot;
int g_iButton;
float g_fDelay;
int g_LastButtons[MAXPLAYERS+1];
bool canShoot[MAXPLAYERS+1] = {true, ...};

bool trailGun[MAXPLAYERS+1];
int trailType[MAXPLAYERS+1];
int trailColor[MAXPLAYERS+1];
int trailProp[MAXPLAYERS+1];

ArrayList g_aColor;
ArrayList g_aColorName;
ArrayList g_aProp;
ArrayList g_aPropName;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("TG_Enabled", Native_TrailGunEnabled);
	RegPluginLibrary("trailgun");
	
	return APLRes_Success;
}

public int Native_TrailGunEnabled(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return trailGun[client];
}

public void OnPluginStart()
{
	CreateConVar("sm_trailgun_version", PLUGIN_VERSION, "[TF2] Trail Gun Version", FCVAR_UNLOGGED|FCVAR_DONTRECORD);
	cvWeapon = CreateConVar("sm_trailgun_weapon", "tf_weapon_flaregun", "What weapon(s) is/are used as the trail gun? Separate classnames with a comma. Put \"all\" if you want all weapons to be considered as a trailgun.");
	cvWeaponSlot = CreateConVar("sm_trailgun_weapon_slot", "-1", "Which weapon slot should the trailgun be used on? -1 = All weapon slots are allowed, 0 = Primary Slot, 1 = Secondary Slot, 2 = Melee Slot");
	cvButton = CreateConVar("sm_trailgun_button", "2", "Which button shoots the trail gun? 1 = +attack, 2 = +attack2, 3 = +attack3, 4 = +use");
	cvDespawnTime = CreateConVar("sm_trailgun_despawn_time", "6", "After a prop & trail is shot out of the gun, how many seconds till it despawns?");
	cvDelayTime = CreateConVar("sm_trailgun_delay", "4.0", "Time in seconds before a prop can be shot again.");
	
	cvWeapon.AddChangeHook(OnCvarChanged);
	cvWeaponSlot.AddChangeHook(OnCvarChanged);
	cvButton.AddChangeHook(OnCvarChanged);
	cvDelayTime.AddChangeHook(OnCvarChanged);
	
	cvWeapon.GetString(g_sWeapon, sizeof(g_sWeapon));
	g_iWeaponSlot = cvWeaponSlot.IntValue;
	g_fDelay = cvDelayTime.FloatValue;
	switch (cvButton.IntValue)
	{
		case 1: g_iButton = IN_ATTACK;
		case 2: g_iButton = IN_ATTACK2;
		case 3: g_iButton = IN_ATTACK3;
		case 4: g_iButton = IN_USE;
	}
	
	cTrailGun = RegClientCookie("sm_trailgun_enabled", "", CookieAccess_Protected);
	cTrailType = RegClientCookie("sm_trailgun_type", "", CookieAccess_Protected);
	cTrailColor = RegClientCookie("sm_trailgun_color", "", CookieAccess_Protected);
	cTrailProp = RegClientCookie("sm_trailgun_prop", "", CookieAccess_Protected);
	
	RegAdminCmd("sm_trailgun", Cmd_TrailGun, ADMFLAG_RESERVATION, "Shoot a prop with a trail attached!");
	
	for (int i = 1; i <= MaxClients; i++)
	{
		trailGun[i] = false;
		trailType[i] = 1;
		trailColor[i] = 0;
		trailProp[i] = 0;
		if (IsClientInGame(i) && AreClientCookiesCached(i)) OnClientCookiesCached(i);
	}
	
	LoadConfigs();
	
	AutoExecConfig(true);
}

void LoadConfigs()
{
	char colorPath[PLATFORM_MAX_PATH], propPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, colorPath, sizeof(colorPath), "configs/trailgun_colors.cfg");
	BuildPath(Path_SM, propPath, sizeof(propPath), "configs/trailgun_props.cfg");
	if (!FileExists(colorPath)) LogError("[TrailGun] ERROR! trailgun_colors.cfg does not exist in %s!", colorPath);
	if (!FileExists(propPath)) LogError("TrailGun] ERROR! trailgun_props.cfg does not exists in %s!", propPath);
	
	g_aColor = new ArrayList(256);
	g_aColorName = new ArrayList(256);
	g_aProp = new ArrayList(256);
	g_aPropName = new ArrayList(256);
	
	KeyValues ckv = new KeyValues("TrailGun Colors");
	ckv.ImportFromFile(colorPath);
	if (!ckv.GotoFirstSubKey(true)) LogError("[TrailGun] ERROR! trailgun_colors.cfg contains no key values!");
	char buffer[64];
	do 
	{
		ckv.GetSectionName(buffer, sizeof(buffer));
		g_aColorName.PushString(buffer);
		
		ckv.GetString("color", buffer, sizeof(buffer));
		g_aColor.PushString(buffer);
	} while (ckv.GotoNextKey());
	
	delete ckv;
	
	KeyValues pkv = new KeyValues("TrailGun Props");
	pkv.ImportFromFile(propPath);
	if (!pkv.GotoFirstSubKey(true)) LogError("[TrailGun] ERROR! trailgun_props.cfg contains no key values!");
	do 
	{
		pkv.GetSectionName(buffer, sizeof(buffer));
		g_aPropName.PushString(buffer);
		
		pkv.GetString("prop", buffer, sizeof(buffer));
		g_aProp.PushString(buffer);
	} while (pkv.GotoNextKey());
	
	delete pkv;
}

public void OnClientConnected(int client)
{
	trailGun[client] = false;
	trailType[client] = 1;
	trailColor[client] = 0;
	trailProp[client] = 0;
}

public void OnClientCookiesCached(int client)
{
	char value[8];
	GetClientCookie(client, cTrailGun, value, sizeof(value));
	if (StrEqual(value, "1")) trailGun[client] = true;
	
	int num;
	GetClientCookie(client, cTrailType, value, sizeof(value));
	num = StringToInt(value);
	if (num > 0) trailType[client] = num;
	
	GetClientCookie(client, cTrailColor, value, sizeof(value));
	num = StringToInt(value);
	if (num > 0) trailColor[client] = num;
	
	GetClientCookie(client, cTrailProp, value, sizeof(value));
	num = StringToInt(value);
	if (num > 0) trailProp[client] = num;
}

public Action Cmd_TrailGun(int client, int args)
{
	if (IsValidClient(client)) TrailGunMenu(client);
	return Plugin_Handled;
}

void TrailGunMenu(int client)
{
	Menu menu = new Menu(TrailGunMenuHandler, MENU_ACTIONS_ALL);
	menu.SetTitle("Trail Gun");
	if (trailGun[client]) menu.AddItem("4", "Trail Gun: Currently Enabled");
	else menu.AddItem("5", "Trail Gun: Currently Disabled");
	menu.AddItem("1", "Trail Type");
	menu.AddItem("2", "Trail Color");
	menu.AddItem("3", "Prop");
	
	menu.Display(client, 20);
}

public int TrailGunMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		menu.GetItem(param2, info, sizeof(info));
		int num = StringToInt(info);
		switch (num)
		{
			case 1: TrailTypeMenu(client);
			case 2: TrailColorMenu(client);
			case 3: TrailPropMenu(client);
			case 4: 
			{
				trailGun[client] = false;
				TrailGunMenu(client);
				SetClientCookie(client, cTrailGun, "0");
				PrintToChat(client, "[SM] Trail Gun Disabled.");
			}
			case 5: 
			{
				trailGun[client] = true;
				TrailGunMenu(client);
				SetClientCookie(client, cTrailGun, "1");
				
				char button[16];
				switch (cvButton.IntValue)
				{
					case 1: Format(button, sizeof(button), "+attack");
					case 2: Format(button, sizeof(button), "+attack2");
					case 3: Format(button, sizeof(button), "+attack3");
					case 4:	Format(button, sizeof(button), "+use");			
				}
				
				char slotSentence[128];
				switch (g_iWeaponSlot)
				{
					case 0: Format(slotSentence, sizeof(slotSentence), " and hold out your primary weapon");
					case 1: Format(slotSentence, sizeof(slotSentence), " and hold out your secondary weapon");
					case 2: Format(slotSentence, sizeof(slotSentence), " and hold out your melee weapon");
				}
				
				char weaponSentence[1024];
				if (!StrEqual(g_sWeapon, "all"))
				{
					Format(weaponSentence, sizeof(weaponSentence), " with this weapon equipped: %s", g_sWeapon);
				}
				PrintToChat(client, "[SM] Trail Gun Enabled. To shoot a prop, press %s%s%s.", button, slotSentence, weaponSentence);
			}
		}
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}
}

void TrailTypeMenu(int client)
{
	Menu menu = new Menu(TrailTypeMenuHandler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("Pick the type of trail:");
	menu.AddItem("1", "Solid Trail");
	menu.AddItem("2", "Thick Outline");
	menu.AddItem("3", "Thin Outline");
	menu.AddItem("4", "Random");
	
	menu.ExitBackButton = true;
	menu.Display(client, 20);
}

public int TrailTypeMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		menu.GetItem(param2, info, sizeof(info));
		trailType[client] = StringToInt(info);
		SetClientCookie(client, cTrailType, info);
		PrintToChat(client, "[SM] Trail Gun: Trail Type selected.");
		TrailGunMenu(client);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) TrailGunMenu(client);
	}
	if (action == MenuAction_End) 
	{
		delete menu;
	}
}

void TrailColorMenu(int client)
{
	Menu menu = new Menu(TrailColorMenuHandler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("Pick the color of the trail:");
	
	char num[8], colorName[32];
	for (int i = 0; i < g_aColorName.Length; i++)
	{
		IntToString(i, num, sizeof(num));
		g_aColorName.GetString(i, colorName, sizeof(colorName));
		menu.AddItem(num, colorName);
	}
	IntToString(g_aColorName.Length, num, sizeof(num));
	menu.AddItem(num, "Random Color");
	
	menu.ExitBackButton = true;
	menu.Display(client, 20);
}

public int TrailColorMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		menu.GetItem(param2, info, sizeof(info));
		trailColor[client] = StringToInt(info);
		SetClientCookie(client, cTrailColor, info);
		PrintToChat(client, "[SM] Trail Gun: Trail Color selected.");
		TrailGunMenu(client);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) TrailGunMenu(client);
	}
	if (action == MenuAction_End) 
	{
		delete menu;
	}
}

void TrailPropMenu(int client)
{
	Menu menu = new Menu(TrailPropMenuHandler, MENU_ACTIONS_ALL);
	
	menu.SetTitle("Pick the type of prop to shoot:");
	
	char num[8], propName[32];
	for (int i = 0; i < g_aPropName.Length; i++)
	{
		IntToString(i, num, sizeof(num));
		g_aPropName.GetString(i, propName, sizeof(propName));
		menu.AddItem(num, propName);
	}
	IntToString(g_aPropName.Length, num, sizeof(num));
	menu.AddItem(num, "Random Prop");
	
	menu.ExitBackButton = true;
	menu.Display(client, 20);
}

public int TrailPropMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		menu.GetItem(param2, info, sizeof(info));
		trailProp[client] = StringToInt(info);
		SetClientCookie(client, cTrailProp, info);
		PrintToChat(client, "[SM] Trail Gun: Prop selected.");
		TrailGunMenu(client);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack) TrailGunMenu(client);
	}
	if (action == MenuAction_End) 
	{
		delete menu;
	}
}

public int OnCvarChanged(ConVar cvar, const char[] oldValue, const char[] newValue)
{
	if (cvar == cvWeapon) cvWeapon.GetString(g_sWeapon, sizeof(g_sWeapon));
	if (cvar == cvWeaponSlot) g_iWeaponSlot = cvWeaponSlot.IntValue;
	if (cvar == cvDelayTime) g_fDelay = cvDelayTime.FloatValue;
	if (cvar == cvButton)
	{
		switch (cvButton.IntValue)
		{
			case 1: g_iButton = IN_ATTACK;
			case 2: g_iButton = IN_ATTACK2;
			case 3: g_iButton = IN_ATTACK3;
			case 4: g_iButton = IN_USE;
		}
	}
}


public void OnMapStart()
{
	char prop[PLATFORM_MAX_PATH];
	for (int i = 0; i < g_aProp.Length; i++)
	{
		g_aProp.GetString(i, prop, sizeof(prop));
		PrecacheModel(prop);
	}
	
	PrecacheSound(")sound/player/taunt_western_shoot1.wav", true);
	PrecacheSound(")sound/player/taunt_western_shoot2.wav", true);
}

public void OnClientDisconnect_Post(int client)
{
	g_LastButtons[client] = 0;
	canShoot[client] = true;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	for (int i = 0; i < MAX_BUTTONS; i++)
	{
		int button = (1 << i);
		
		if ((buttons & button))
		{
			if (!(g_LastButtons[client] & button))
			{
				OnButtonPress(client, button);
			}
		}
	}
	
	g_LastButtons[client] = buttons;
	
	return Plugin_Continue;
}

void OnButtonPress(client, button)
{
	char wep[64];
	GetClientWeapon(client, wep, sizeof(wep));
	int slot = GetClientActiveSlot(client);
	if (g_iWeaponSlot == -1 || g_iWeaponSlot == slot)
	{
		if (StrContains(g_sWeapon, wep) != -1 || StrContains(g_sWeapon, "all") != -1)
		{
			if (button & g_iButton)
			{
				if (trailGun[client] && canShoot[client] && IsPlayerAlive(client))
				{
					canShoot[client] = false;
					if (CheckCommandAccess(client, "sm_trailgun_override_delay", ADMFLAG_ROOT, true))
					{
						CreateTimer(0.1, Timer_Delay, GetClientUserId(client));
					}
					else
					{
						CreateTimer(g_fDelay, Timer_Delay, GetClientUserId(client));
					}
					
					SpawnPropPhysics(client, 0.0, 0.0);
					
					float vec[3];
					GetClientEyePosition(client, vec);
					char sound[64];
					Format(sound, sizeof(sound), ")player/taunt_western_shoot%d.wav", GetRandomInt(1, 2));
					EmitSoundToAll(sound,
					 SOUND_FROM_WORLD,
					 SNDCHAN_STATIC,
					 SNDLEVEL_NORMAL,
					 SND_NOFLAGS,
					 SNDVOL_NORMAL,
					 SNDPITCH_NORMAL,
					 -1,
					 vec);
				}
			}
		}
	}
}

void SpawnPropPhysics(int client, float pitch, float yaw)
{
	float ori[3];
	float ang[3];
	float vec[3];

	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, ori);
	
	ang[0] += pitch;
	ang[1] += yaw;

	float tempvec[3];
	GetAngleVectors(ang, tempvec, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(tempvec, 40.0);
	AddVectors(ori, tempvec, ori);
	
	int ent_projectile = CreateEntityByName("prop_physics_override");
	
	char child[128];
	Format(child, sizeof(child), "trailgun_nohook_%i", ent_projectile);
	DispatchKeyValue(ent_projectile, "targetname", child);
	
	SetEntPropEnt(ent_projectile, Prop_Data, "m_hOwnerEntity", client);
	int num = trailProp[client];
	if (num == g_aPropName.Length) num = GetRandomInt(0, g_aPropName.Length-1);
	char prop[PLATFORM_MAX_PATH];
	g_aProp.GetString(num, prop, sizeof(prop));
	SetEntityModel(ent_projectile, prop);
	
	SetEntityMoveType(ent_projectile, MOVETYPE_FLY);
	SetEntProp(ent_projectile, Prop_Data, "m_CollisionGroup", 1);
	SetEntProp(ent_projectile, Prop_Data, "m_usSolidFlags", 16);

	SetEntPropFloat(ent_projectile, Prop_Data, "m_flGravity", 0.0);

	DispatchSpawn(ent_projectile);

	GetAngleVectors(ang, vec, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vec, 2000.0);
	
	int Trail = CreateEntityByName("env_spritetrail");
	DispatchKeyValue(Trail, "renderamt", "255");
	DispatchKeyValue(Trail, "rendermode", "1");
	
	num = trailType[client];
	if (num == 4) num = GetRandomInt(1, 3);
	switch (num)
	{
		case 1: DispatchKeyValue(Trail, "spritename", "materials/sprites/spotlight.vmt");
		case 2: DispatchKeyValue(Trail, "spritename", "materials/sprites/laser.vmt");
		case 3: DispatchKeyValue(Trail, "spritename", "materials/sprites/laserbeam.vmt");
	}
	
	DispatchKeyValue(Trail, "lifetime", "2.5");
	DispatchKeyValue(Trail, "startwidth", "8.0");
	DispatchKeyValue(Trail, "endwidth", "0.1");
	
	num = trailColor[client];
	char color[32];
	if (num == g_aColorName.Length) // random color
	{
		char red[8], green[8], blue[8];
		IntToString(GetRandomInt(0, 255), red, sizeof(red));
		IntToString(GetRandomInt(0, 255), green, sizeof(green));
		IntToString(GetRandomInt(0, 255), blue, sizeof(blue));
		Format(color, sizeof(color), "%s, %s, %s", red, green, blue);
	}
	else g_aColor.GetString(num, color, sizeof(color)); // specific color
	
	DispatchKeyValue(Trail, "rendercolor", color);
	
	DispatchSpawn(Trail);
	
	Phys_EnableDrag(ent_projectile, false);
	
	TeleportEntity(ent_projectile, ori, ang, vec);
	TeleportEntity(Trail, ori, NULL_VECTOR, NULL_VECTOR);
	
	SetVariantString(child);
	AcceptEntityInput(Trail, "SetParent");
	
	// Despawn
	char info[64];
	Format(info, sizeof(info), "OnUser1 !self:kill::%d:1", cvDespawnTime.IntValue);
	SetVariantString(info);
	AcceptEntityInput(ent_projectile, "AddOutput");
	AcceptEntityInput(ent_projectile, "FireUser1");
	
	SetVariantString(info);
	AcceptEntityInput(Trail, "AddOutput");
	AcceptEntityInput(Trail, "FireUser1");
}

public Action Timer_Delay(Handle hTimer, any userid)
{
	int client = GetClientOfUserId(userid);
	canShoot[client] = true;
}

stock bool IsValidClient(int iClient, bool bAlive = false)
{
	if (iClient >= 1 &&
	iClient <= MaxClients &&
	IsClientConnected(iClient) &&
	IsClientInGame(iClient) &&
	(bAlive == false || IsPlayerAlive(iClient)))
	{
		return true;
	}

	return false;
}

stock int GetClientActiveSlot(int client)
{
	if (client == 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))
		return -1;
	
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	for (int i = 0; i < 5; i++)
	{
		if (GetPlayerWeaponSlot(client, i) != weapon)
			continue;

		return i;
	}

	return -1;
}
