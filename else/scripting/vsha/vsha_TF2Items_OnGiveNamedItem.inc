// vsha_TF2Items_OnGiveNamedItem.inc

public Action TF2Items_OnGiveNamedItem(int client, char[] classname, int iItemDefinitionIndex, Handle &hItem)
{
	if (!Enabled || bIsBoss[client]) return Plugin_Continue;
	switch ( iItemDefinitionIndex )
	{
		case 40: //backburner
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "165 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 349: //sun on a stick
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "208 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 648: //wrap assassin
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "279 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 224: //Letranger
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "166 ; 15 ; 1 ; 0.8", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 225, 574: //YER
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "155 ; 1 ; 160 ; 1", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 232, 401: // Bushwacka + Shahanshah
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "236 ; 1");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 226: // The Battalion's Backup
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "252 ; 0.25 ; 125 -20"); //125 ; -10
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 305, 1079: // Medic Xbow
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "17 ; 0.12 ; 2 ; 1.45 ; 6 ; 1.5"); // ; 266 ; 1.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 56, 1005, 1092: // Huntsman
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "2 ; 1.5 ; 76 ; 2.0");
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 38, 457: // Axetinguisher
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 43, 239, 1084, 1100: //gru
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "107 ; 1.65 ; 1 ; 0.5 ; 128 ; 1 ; 191 ; -7", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
		case 415: //reserve shooter
		{
			Handle hItemOverride = PrepareItemHandle(hItem, _, _, "179 ; 1 ; 265 ; 999.0 ; 178 ; 0.6 ; 2 ; 1.1 ; 3 ; 0.66", true);
			if (hItemOverride != null)
			{
				hItem = hItemOverride;
				return Plugin_Changed;
			}
		}
	}
	if (TF2_GetPlayerClass(client) == TFClass_Soldier)
	{
		Handle hItemOverride = null;
		if ( !strncmp(classname, "tf_weapon_rocketlauncher", 24, false) )
		{
			switch (iItemDefinitionIndex)
			{
				case 127: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0 ; 179 ; 1.0");
				default: hItemOverride = PrepareItemHandle(hItem, _, _, "265 ; 999.0");
			}
		}
		if (hItemOverride != null)
		{
			hItem = hItemOverride;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

