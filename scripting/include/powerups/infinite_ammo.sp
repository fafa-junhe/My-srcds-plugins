/*
 * Include for Infinite Ammo powerup.
 * This include is used in #manager.sp
 *
 */

static Handle g_hAmmoTimer[MAX_CLIENTS];
static int g_iClipCache[MAX_CLIENTS][2];
static int g_iClientWeapons[MAX_CLIENTS][2];

static int g_iClipOffset;

void InfiniteAmmo_OnPluginStart()
{
	g_iClipOffset = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	
	for (int a = 1; a < MAX_CLIENTS; a++)
	{
		ResetClientVars(a);
	}
}

void InfiniteAmmo_Powerup(int client, bool enable)
{
	if (enable)
	{
		InfiniteAmmo_UpdateClientWeapons(client);
		g_hAmmoTimer[client] = CreateTimer(0.5, Timer_InfiniteAmmo, client, TIMER_REPEAT);
	}
	
	else
	{
		KillTimer(g_hAmmoTimer[client]);
		SetOriginalAmmo(client);
		ResetClientVars(client);
	}
}

void SetOriginalAmmo(int client)
{
	if (g_iClientWeapons[client][0] != -1)
	{
		SetEntData(g_iClientWeapons[client][0], g_iClipOffset, g_iClipCache[client][0], _, true);
	}
	
	if (g_iClientWeapons[client][1] != -1)
	{
		SetEntData(g_iClientWeapons[client][1], g_iClipOffset, g_iClipCache[client][1], _, true);
	}
}

void ResetClientVars(int client)
{
	g_iClipCache[client][0] = 0;
	g_iClipCache[client][1] = 0;
	g_iClientWeapons[client][0] = -1;
	g_iClientWeapons[client][1] = -1;
}

void InfiniteAmmo_UpdateClientWeapons(int client)
{
	g_iClientWeapons[client][0] = GetPlayerWeaponSlot(client, 0);
	g_iClientWeapons[client][1] = GetPlayerWeaponSlot(client, 1);
	
	if (g_iClientWeapons[client][0] != -1)
	{
		g_iClipCache[client][0] = GetEntData(g_iClientWeapons[client][0], g_iClipOffset);
	}
	
	if (g_iClientWeapons[client][1] != -1)
	{
		g_iClipCache[client][1] = GetEntData(g_iClientWeapons[client][1], g_iClipOffset);
	}
}

public Action Timer_InfiniteAmmo(Handle timer, any client)
{
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	int iWeapon2 = GetPlayerWeaponSlot(client, 1);
	
	if (iWeapon != g_iClientWeapons[client][0] || iWeapon2 != g_iClientWeapons[client][1])
	{
		InfiniteAmmo_UpdateClientWeapons(client);
	}
	
	if (iWeapon != -1)
	{
		switch (GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case 441, 442, 588:
			{
				SetEntPropFloat(iWeapon, Prop_Send, "m_flEnergy", 20.0);
			}
			
			case 307:
			{
				SetEntProp(iWeapon, Prop_Send, "m_bBroken", 0);
				SetEntProp(iWeapon, Prop_Send, "m_iDetonated", 0);
			}
			
			default:
			{
				SetEntData(iWeapon, g_iClipOffset, 99, _, true);
			}
		}
	}
	
	if (iWeapon2 != -1)
	{
		SetEntData(iWeapon2, g_iClipOffset, 99, _, true);
	}
	
	switch (TF2_GetPlayerClass(client)) 
	{
		case TFClass_Engineer:
		{
			SetEntProp(client, Prop_Data, "m_iAmmo", 200, 4, 3);
		}
		
		case TFClass_Spy:
		{
			SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", 100.0);
		}
	}
}

