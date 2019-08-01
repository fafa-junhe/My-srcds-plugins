// vsha_000_RegAdminCmd.inc

public void vsha_000_RegAdminCmd_OnPluginStart()
{
	RegAdminCmd("sm_forceboss", Command_forceboss, ADMFLAG_ROOT, "sm_forceboss");
	RegAdminCmd("sm_reloadboss", Command_ReloadBoss, ADMFLAG_ROOT, "sm_reloadboss");
}

public Action Command_ReloadBoss(int client, int args)
{
	Menu pickboss = new Menu(MenuHandler_ReloadBoss);
	pickboss.SetTitle("[VSHA Engine] Which Boss to Reload?");
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

//int InternalCounter;

public int MenuHandler_ReloadBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
	{
		//InternalPause = true;

		char bossnameholder[16];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossLongName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSH Engine] Reloading %s!", bossnameholder);
		//iPresetBoss[client] = selection;

		GetTrieString(hArrayBossSubplugins.Get(selection), "BossShortName", bossnameholder, sizeof(bossnameholder));

		if(RemoveFromTrie(hTrieBossSubplugins, bossnameholder))
		{
			strcopy(STRING(ReloadBossShortName), bossnameholder);
			ReplyToCommand(client, "[VSHA Engine] Successful RemoveFromTrie");
		}

		StringMap MyStringMap = hArrayBossSubplugins.Get(selection);

		Handle plugin;
		MyStringMap.GetValue("Subplugin", plugin);

		//char hPlugin[PATHX];

		GetPluginFilename(plugin, STRING(hLoadPlugin));

		LoopMaxPLYR(plyrBoss)
		{
			if(Storage[plyrBoss] == plugin)
			{
				Storage[plyrBoss] = null;
				BossArrayListIndex[plyrBoss] = -1;
				ReloadPlayer[plyrBoss] = true;
				PrintToChatAll("ReloadPlayer %d",plyrBoss);
			}
			else
			{
				ReloadPlayer[plyrBoss] = false;
			}
		}

		hArrayBossSubplugins.Erase(selection);

		ServerCommand("sm plugins reload %s",hLoadPlugin);

		ReplyToCommand(client, "[VSHA Engine] reload of %s ...",bossnameholder);

		//CreateTimer(1.0, LoadPluginTimer, client);
		//InternalCounter = 10;
		//ReplyToCommand(client, "[VSH Engine] Waiting %d seconds...",InternalCounter);
	}
	else if (action == MenuAction_End) delete menu;
}
/*
public Action LoadPluginTimer(Handle hTimer, int client)
{
	--InternalCounter;
	if(InternalCounter>0)
	{
		ReplyToCommand(client, "[VSH Engine] Waiting %d seconds...",InternalCounter);
		CreateTimer(1.0, LoadPluginTimer, client);
		return Plugin_Continue;
	}
	ServerCommand("sm plugins load %s",hLoadPlugin);
	ReplyToCommand(client, "[VSH Engine] Reload Finished");
	return Plugin_Continue;
}*/

public Action Command_forceboss(int client, int args)
{
	if (Enabled && IsClientInGame(client))
	{
		Menu pickboss = new Menu(MenuHandler_ForceBoss);
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
public int MenuHandler_ForceBoss(Menu menu, MenuAction action, int client, int selection)
{
	char blahblah[32];
	menu.GetItem(selection, blahblah, sizeof(blahblah));
	if (action == MenuAction_Select)
	{
		char bossnameholder[32];
		GetTrieString(hArrayBossSubplugins.Get(selection), "BossLongName", bossnameholder, sizeof(bossnameholder));
		ReplyToCommand(client, "[VSHA Engine] You selected %s as your boss!", bossnameholder);
		iPresetBoss[client] = selection;

		SetClientQueuePoints(client, 99999);
	}
	else if (action == MenuAction_End) delete menu;
}
