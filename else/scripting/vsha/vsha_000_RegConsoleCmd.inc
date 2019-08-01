// vsha_000_RegConsoleCmd.inc
public void vsha_000_RegConsoleCmd_OnPluginStart()
{
	RegConsoleCmd("sm_vsha_special", CommandMakeNextSpecial);

	RegConsoleCmd("sm_pickhale", PickBossMenu);
	RegConsoleCmd("sm_setboss", PickBossMenu);
	RegConsoleCmd("sm_haleboss", PickBossMenu);
	RegConsoleCmd("sm_vshaboss", PickBossMenu);
	RegConsoleCmd("sm_vsheboss", PickBossMenu);
}

public Action CommandMakeNextSpecial(int client, int args)
{
	//if(InternalPause) return Plugin_Continue;

	char arg[32], name[64];
	if (args < 1)
	{
		ReplyToCommand(client, "[VSHA Engine] Usage: vsha_special <boss name>");
		return Plugin_Handled;
	}
	GetCmdArgString(arg, sizeof(arg));

	int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
	for (int i = 0; i < count; i++)
	{
		//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", name, sizeof(name));
		GetTrieString(hArrayBossSubplugins.Get(i), "BossShortName", name, sizeof(name));
		if (StrContains(arg, name, false) != -1)
		{
			iPresetBoss[FindNextBoss(bIsBoss)] = i;
			break;
		}
	}
	ReplyToCommand(client, "[VSHA Engine] Set the next Special to %s", name);
	return Plugin_Handled;
}
public Action PickBossMenu(int client, int args)
{
	if (Enabled && IsClientInGame(client))
	{
		Menu pickboss = new Menu(MenuHandler_PickBoss);
		//Handle MainMenu = CreateMenu(MenuHandler_Perks);
		pickboss.SetTitle("[VSHA Engine] Choose A Boss");
		int count = hArrayBossSubplugins.Length; //GetArraySize(hArrayBossSubplugins);
		for (int i = 0; i < count; i++)
		{
			//GetTrieString(GetArrayCell(hArrayBossSubplugins, i), "BossName", bossnameholder, sizeof(bossnameholder));
			char bossnameholder[32];
			GetTrieString(hArrayBossSubplugins.Get(i), "BossLongName", bossnameholder, sizeof(bossnameholder));
			pickboss.AddItem("pickclass", bossnameholder);
		}
		pickboss.Display(client, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}
public int MenuHandler_PickBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
        {
		char bossnameholder[32];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossLongName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSHA Engine] You selected %s as your boss!", bossnameholder);
		iPresetBoss[client] = selection;
        }
	else if (action == MenuAction_End) delete menu;
}
