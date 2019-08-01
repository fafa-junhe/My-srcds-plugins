#pragma semicolon 1
#include <sourcemod>
//#include <sdkhooks>
#include <morecolors>
#include <vsha>
#include <vsha_stocks>

public Plugin myinfo =
{
	name 			= "Saxton Hale",
	author 			= "Valve",
	description 		= "Saxton Haaaaaaaaaaaaale",
	version 		= "1.3",
	url 			= "http://wiki.teamfortress.com/wiki/Saxton_Hale"
}

int iThisPlugin = -1; //DO NOT TOUCH THIS, THIS IS USED TO IDENTIFY THIS BOSS PLUGIN.

#define ThisConfigurationFile "configs/vsha/saxtonhale.cfg"

char HaleModel[PATHX];
char HaleModelPrefix[PATHX];


char HaleTheme1[PATHX];
char HaleTheme2[PATHX];
char HaleTheme3[PATHX];

#define HALE_JUMPCHARGE			5
#define HALE_JUMPCHARGETIME		100

//#define HaleModel			"models/player/saxton_hale/saxton_hale.mdl"
//#define HaleModelPrefix			"models/player/saxton_hale/saxton_hale"

// ?? i need to find these, as i dont have them - El Diablo
//#define HaleTheme1			"saxton_hale/saxtonhale.mp3"
//#define HaleTheme2			"saxton_hale/haletheme2.mp3"
//#define HaleTheme3			"saxton_hale/haletheme3.mp3"

char HaleComicArmsFallSound[PATHX];
char HaleLastB[PATHX];
char HaleKSpree[PATHX];
char HaleKSpree2[PATHX];
char HaleRoundStart[PATHX];
char HaleJump[PATHX];
char HaleRageSound[PATHX];
char HaleKillMedic[PATHX];
char HaleKillSniper1[PATHX];
char HaleKillSniper2[PATHX];
char HaleKillSpy1[PATHX];
char HaleKillSpy2[PATHX];
char HaleKillEngie1[PATHX];
char HaleKillEngie2[PATHX];
char HaleKSpreeNew[PATHX];
char HaleWin[PATHX];
char HaleLastMan[PATHX];
char HaleFail[PATHX];
char HaleJump132[PATHX];
char HaleStart132[PATHX];
char HaleKillDemo132[PATHX];
char HaleKillEngie132[PATHX];
char HaleKillHeavy132[PATHX];
char HaleKillScout132[PATHX];
char HaleKillSpy132[PATHX];
char HaleKillPyro132[PATHX];
char HaleSappinMahSentry132[PATHX];
char HaleKillKSpree132[PATHX];
char HaleKillLast132[PATHX];
char HaleStubbed132[PATHX];

//Saxton Hale voicelines
/*
#define HaleComicArmsFallSound		"saxton_hale/saxton_hale_responce_2.wav"
#define HaleLastB			"vo/announcer_am_lastmanalive"
#define HaleKSpree			"saxton_hale/saxton_hale_responce_3.wav"
#define HaleKSpree2			"saxton_hale/saxton_hale_responce_4.wav" //this line is broken and unused
#define HaleRoundStart			"saxton_hale/saxton_hale_responce_start" //1-5
#define HaleJump			"saxton_hale/saxton_hale_responce_jump"            //1-2
#define HaleRageSound			"saxton_hale/saxton_hale_responce_rage"           //1-4
#define HaleKillMedic			"saxton_hale/saxton_hale_responce_kill_medic.wav"
#define HaleKillSniper1			"saxton_hale/saxton_hale_responce_kill_sniper1.wav"
#define HaleKillSniper2			"saxton_hale/saxton_hale_responce_kill_sniper2.wav"
#define HaleKillSpy1			"saxton_hale/saxton_hale_responce_kill_spy1.wav"
#define HaleKillSpy2			"saxton_hale/saxton_hale_responce_kill_spy2.wav"
#define HaleKillEngie1			"saxton_hale/saxton_hale_responce_kill_eggineer1.wav"
#define HaleKillEngie2			"saxton_hale/saxton_hale_responce_kill_eggineer2.wav"
#define HaleKSpreeNew			"saxton_hale/saxton_hale_responce_spree"  //1-5
#define HaleWin				"saxton_hale/saxton_hale_responce_win" //1-2
#define HaleLastMan			"saxton_hale/saxton_hale_responce_lastman"  //1-5
#define HaleFail			"saxton_hale/saxton_hale_responce_fail"            //1-3
#define HaleJump132			"saxton_hale/saxton_hale_132_jump_" //1-2
#define HaleStart132			"saxton_hale/saxton_hale_132_start_"   //1-5
#define HaleKillDemo132			"saxton_hale/saxton_hale_132_kill_demo.wav"
#define HaleKillEngie132		"saxton_hale/saxton_hale_132_kill_engie_" //1-2
#define HaleKillHeavy132		"saxton_hale/saxton_hale_132_kill_heavy.wav"
#define HaleKillScout132		"saxton_hale/saxton_hale_132_kill_scout.wav"
#define HaleKillSpy132			"saxton_hale/saxton_hale_132_kill_spie.wav"
#define HaleKillPyro132			"saxton_hale/saxton_hale_132_kill_w_and_m1.wav"
#define HaleSappinMahSentry132		"saxton_hale/saxton_hale_132_kill_toy.wav"
#define HaleKillKSpree132		"saxton_hale/saxton_hale_132_kspree_"    //1-2
#define HaleKillLast132			"saxton_hale/saxton_hale_132_last.wav"
#define HaleStubbed132			"saxton_hale/saxton_hale_132_stub_"  //1-4
*/

//make defines, handles, variables heer lololol
int HaleCharge[PLYR];

int HaleChargeCoolDown[PLYR];

float WeighDownTimer = 0.0;
float RageDist = 800.0;

public void OnPluginStart()
{
	//AutoExecConfig(true, "VSHA-Boss-SaxtonHale");
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::OnPluginStart() **** loaded VSHA Subplugin ****");
#endif
}
public void Load_VSHAHooks()
{
	if(!VSHAHookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error loading VSHAHook_OnBossIntroTalk forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error loading VSHAHook_OnPlayerKilledByBoss forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error loading VSHAHook_OnKillingSpreeByBoss forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error loading VSHAHook_OnBossKilled forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error loading VSHAHook_OnBossWin forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossKillBuilding, OnBossKillBuilding))
	{
		LogError("Error loading VSHAHook_OnBossKillBuilding forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error loading VSHAHook_OnBossAirblasted forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error loading VSHAHook_OnBossChangeClass forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error loading VSHAHook_OnBossSetHP forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error loading VSHAHook_OnLastSurvivor forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error loading VSHAHook_OnBossTimer forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error loading VSHAHook_OnPrepBoss forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error loading VSHAHook_OnMusic forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error loading VSHAHook_OnBossRage forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error loading VSHAHook_OnGameOver forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error loading VSHAHook_ShowBossHelpMenu forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnBossStabbedPost, OnBossStabbedPost))
	{
		LogError("Error loading VSHAHook_OnBossStabbedPost forwards for saxton hale.");
	}
}

public void UnLoad_VSHAHooks()
{
	if(!VSHAUnhookEx(VSHAHook_OnBossIntroTalk, OnBossIntroTalk))
	{
		LogError("Error unloading VSHAHook_OnBossIntroTalk forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPlayerKilledByBoss, OnPlayerKilledByBoss))
	{
		LogError("Error unloading VSHAHook_OnPlayerKilledByBoss forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnKillingSpreeByBoss, OnKillingSpreeByBoss))
	{
		LogError("Error unloading VSHAHook_OnKillingSpreeByBoss forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossKilled, OnBossKilled))
	{
		LogError("Error unloading VSHAHook_OnBossKilled forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossWin, OnBossWin))
	{
		LogError("Error unloading VSHAHook_OnBossWin forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossKillBuilding, OnBossKillBuilding))
	{
		LogError("Error unloading VSHAHook_OnBossKillBuilding forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossAirblasted, OnBossAirblasted))
	{
		LogError("Error unloading VSHAHook_OnBossAirblasted forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossChangeClass, OnChangeClass))
	{
		LogError("Error unloading VSHAHook_OnBossChangeClass forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossSetHP, OnBossSetHP))
	{
		LogError("Error unloading VSHAHook_OnBossSetHP forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnLastSurvivor, OnLastSurvivor))
	{
		LogError("Error unloading VSHAHook_OnLastSurvivor forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossTimer, OnBossTimer))
	{
		LogError("Error unloading VSHAHook_OnBossTimer forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnPrepBoss, OnPrepBoss))
	{
		LogError("Error unloading VSHAHook_OnPrepBoss forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnMusic, OnMusic))
	{
		LogError("Error unloading VSHAHook_OnMusic forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnBossRage, OnBossRage))
	{
		LogError("Error unloading VSHAHook_OnBossRage forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_OnGameOver, OnGameOver))
	{
		LogError("Error unloading VSHAHook_OnGameOver forwards for saxton hale.");
	}
	if(!VSHAUnhookEx(VSHAHook_ShowBossHelpMenu, OnShowBossHelpMenu))
	{
		LogError("Error unloading VSHAHook_ShowBossHelpMenu forwards for saxton hale.");
	}
}

public void OnAllPluginsLoaded()
{
	iThisPlugin = VSHA_RegisterBoss("saxtonhale","Saxton Hale");

	if(!VSHAHookEx(VSHAHook_OnBossSelected, OnBossSelected))
	{
		LogError("Error loading VSHAHook_OnBossSelected forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Sounds, OnConfiguration_Load_Sounds))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Sounds forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Materials, OnConfiguration_Load_Materials))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Materials forwards for saxton hale.");
	}
	if(!VSHAHookEx(VSHAHook_OnConfiguration_Load_Models, OnConfiguration_Load_Models))
	{
		LogError("Error loading VSHAHook_OnConfiguration_Load_Models forwards for saxton hale.");
	}

	// LoadConfiguration ALWAYS after VSHAHook
	VSHA_LoadConfiguration(ThisConfigurationFile);
}
//public void OnPluginEnd()
//{
	//if(ThisPluginHandle != null)
	//{
		//VSHA_UnRegisterBoss("saxtonhale");
	//}
//}
public void OnMapStart()
{
	PrecacheParticleSystem("ghost_appearation");
	PrecacheParticleSystem("yikes_fx");
}
public void OnMapEnd()
{
	WeighDownTimer = 0.0;
	RageDist = 800.0;

	LoopMaxPLYR(player)
	{
		HaleCharge[player] = 0;
	}
}

//public void OnClientDisconnect(int client)
//{
	//if(VSHA_GetBossHandle(iiBoss)!=ThisPluginHandle) return;

	//bool see[PLYR];
	//see[client] = true;
	//int tHale;
	//if (VSHA_GetPresetBossPlayer() > 0) tHale = VSHA_GetPresetBossPlayer();
	//else tHale = VSHA_FindNextBoss( see, sizeof(see) );
	//if (IsValidClient(tHale))
	//{
		//if (GetClientTeam(tHale) != 3)
		//{
			//ForceTeamChange(Hale[client], 3);
			//DP("vsha-saxtonhale 166 ForceTeamChange(i, 3)");
		//}
	//}
//}
public void OnChangeClass(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if (TF2_GetPlayerClass(iiBoss) != TFClass_Soldier) TF2_SetPlayerClass(iiBoss, TFClass_Soldier, _, false);
	TF2_RemovePlayerDisguise(iiBoss);
}
public void OnPlayerKilledByBoss(int iBossArrayListIndex, int iiBoss, int attacker)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if (!GetRandomInt(0, 2) && VSHA_GetAliveRedPlayers() != 1)
	{
		char playsound[PATHX];
		TFClassType playerclass = TF2_GetPlayerClass(iiBoss);
		switch (playerclass)
		{
			case TFClass_Scout:     strcopy(playsound, PLATFORM_MAX_PATH, HaleKillScout132);
			case TFClass_Pyro:      strcopy(playsound, PLATFORM_MAX_PATH, HaleKillPyro132);
			case TFClass_DemoMan:   strcopy(playsound, PLATFORM_MAX_PATH, HaleKillDemo132);
			case TFClass_Heavy:     strcopy(playsound, PLATFORM_MAX_PATH, HaleKillHeavy132);
			case TFClass_Medic:     strcopy(playsound, PLATFORM_MAX_PATH, HaleKillMedic);
			case TFClass_Sniper:
			{
				if (GetRandomInt(0, 1)) strcopy(playsound, PLATFORM_MAX_PATH, HaleKillSniper1);
				else strcopy(playsound, PLATFORM_MAX_PATH, HaleKillSniper2);
			}
			case TFClass_Spy:
			{
				int see = GetRandomInt(0, 2);
				if (!see) strcopy(playsound, PLATFORM_MAX_PATH, HaleKillSpy1);
				else if (see == 1) strcopy(playsound, PLATFORM_MAX_PATH, HaleKillSpy2);
				else strcopy(playsound, PLATFORM_MAX_PATH, HaleKillSpy132);
			}
			case TFClass_Engineer:
			{
				int see = GetRandomInt(0, 3);
				if (!see) strcopy(playsound, PLATFORM_MAX_PATH, HaleKillEngie1);
				else if (see == 1) strcopy(playsound, PLATFORM_MAX_PATH, HaleKillEngie2);
				else Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillEngie132, GetRandomInt(1, 2));
			}
		}
		if ( !StrEqual(playsound, "") ) EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void OnKillingSpreeByBoss(int iBossArrayListIndex, int iiBoss, int attacker)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];

	int see = GetRandomInt(0, 7);
	if (!see || see == 1) strcopy(playsound, PLATFORM_MAX_PATH, HaleKSpree);
	else if (see < 5 && see > 1) Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleKSpreeNew, GetRandomInt(1, 5));
	else Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleKillKSpree132, GetRandomInt(1, 2));

	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, attacker, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossKilled(int iBossArrayListIndex, int iiBoss, int attacker) //victim is boss
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];

	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleFail, GetRandomInt(1, 3));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossWin(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];

	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleWin, GetRandomInt(1, 2));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( !IsClientValid(i) ) continue;
		StopSound(i, SNDCHAN_AUTO, HaleTheme1);
		StopSound(i, SNDCHAN_AUTO, HaleTheme2);
		StopSound(i, SNDCHAN_AUTO, HaleTheme3);
	}
}
public void OnGameOver() // best play to reset all variables
{
	LoopMaxPLYR(players)
	{
		HaleCharge[players]=0;
		//InRage[players]=false;

		if(ValidPlayer(players))
		{
			StopSound(players, SNDCHAN_AUTO, HaleTheme1);
			StopSound(players, SNDCHAN_AUTO, HaleTheme2);
			StopSound(players, SNDCHAN_AUTO, HaleTheme3);
		}
	}
	// Dynamically unload private forwards
	UnLoad_VSHAHooks();
}

public void OnBossKillBuilding(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if ( !GetRandomInt(0, 4) )
	{
		char playsound[PATHX];
		strcopy(playsound, PLATFORM_MAX_PATH, HaleSappinMahSentry132);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	}
}
public void OnBossAirblasted(int iBossArrayListIndex, Event event, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	//float rage = 0.04*RageDMG;
	//HaleRage += RoundToCeil(rage);
	//if (HaleRage > RageDMG) HaleRage = RageDMG;
	VSHA_SetBossRage(iiBoss, VSHA_GetBossRage(iiBoss)+4.0); //make this a convar/cvar!
}
public void OnBossSelected(int iBossArrayListIndex, int iiBoss)
{
	if(iBossArrayListIndex!=iThisPlugin)
	{
		// reset variables
		HaleCharge[iiBoss]=0;
		//InRage[iiBoss]=false;
		return;
	}

	//CPrintToChatAll("%s, Saxton Hale Selected!",VSHA_COLOR);

	// Dynamically load private forwards
	Load_VSHAHooks();
}
public void OnBossIntroTalk()
{
	char playsound[PATHX];
	if (!GetRandomInt(0, 1)) Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleRoundStart, GetRandomInt(1, 5));
	else Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleStart132, GetRandomInt(1, 5));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public Action OnBossSetHP(int iBossArrayListIndex, int BossEntity, int &BossMaxHealth)
{
	if (iThisPlugin != iBossArrayListIndex) return Plugin_Continue;
	BossMaxHealth = HealthCalc( 760.8, float( VSHA_GetPlayerCount() ), 1.0, 1.0341, 2046.0 );
	//VSHA_SetBossMaxHealth(Hale[BossEntity], BossMax);
	return Plugin_Changed;
}
public void OnLastSurvivor()
{
	char playsound[PATHX];
	int see = GetRandomInt(0, 5);
	switch (see)
	{
		case 0:		strcopy(playsound, PLATFORM_MAX_PATH, HaleComicArmsFallSound);
		case 1:		Format(playsound, PLATFORM_MAX_PATH, "%s0%i.wav", HaleLastB, GetRandomInt(1, 4));
		case 2:		strcopy(playsound, PLATFORM_MAX_PATH, HaleKillLast132);
		default:	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleLastMan, GetRandomInt(1, 5));
	}
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}
public void OnBossTimer(int iBossArrayListIndex, int iiBoss, int &curHealth, int &curMaxHp, int buttons, Handle hHudSync, Handle hHudSync2)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];
	float speed;
	//int curHealth = VSHA_GetBossHealth(iiBoss), curMaxHp = VSHA_GetBossMaxHealth(iiBoss);
	// temporary health fix
	if (curHealth < 0)
	{
		ForcePlayerSuicide(iiBoss);
		return;
	}
	if(GetClientHealth(iiBoss) != curHealth)
	{
		SetEntityHealth(iiBoss,curHealth);
	}
	if (curHealth <= curMaxHp) speed = 340.0 + 0.7 * (100.0-float(curHealth)*100.0/float(curMaxHp)); //convar/cvar for speed here!
	SetEntPropFloat(iiBoss, Prop_Send, "m_flMaxspeed", speed);

	//int buttons = GetClientButtons(iiBoss);
	if (HaleChargeCoolDown[iiBoss] <= GetTime())
	{
		if ( ((buttons & IN_DUCK) || (buttons & IN_ATTACK2)) && HaleCharge[iiBoss] >= 0 )
		{
			if ((HaleCharge[iiBoss] + HALE_JUMPCHARGE) < HALE_JUMPCHARGETIME) HaleCharge[iiBoss] += HALE_JUMPCHARGE;
			else HaleCharge[iiBoss] = HALE_JUMPCHARGETIME;
			//DP("%d",HaleCharge[iiBoss]);
			if (!(buttons & IN_SCORE))
			{
				SetHudTextParams(-1.0, 0.70, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
				ShowSyncHudText(iiBoss, hHudSync, "Jump Charge: %i%", HaleCharge[iiBoss]);
			}
		}
		// 5 * 60 = 300
		// 5 * .2 = 1 second, so 5 times number of seconds equals number for HaleCharge after superjump
		// 300 = 1 minute wait
		float ExtraBoost = float(HaleCharge[iiBoss])/4;
		if ( HaleCharge[iiBoss] > 1 && SuperJump(iiBoss, ExtraBoost, -15.0, HaleCharge[iiBoss], -150) ) //put convar/cvar for jump sensitivity here!
		{
			HaleChargeCoolDown[iiBoss] = GetTime()+3;
			Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", GetRandomInt(0, 1) ? HaleJump : HaleJump132, GetRandomInt(1, 2));
			EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
		}
	}
	else
	{
		HaleCharge[iiBoss] = 0;
		if (!(buttons & IN_SCORE))
		{
			SetHudTextParams(-1.0, 0.75, HudTextScreenHoldTime, 90, 255, 90, 200, 0, 0.0, 0.0, 0.0);
			ShowSyncHudText(iiBoss, hHudSync, "Super Jump will be ready again in: %i", (HaleChargeCoolDown[iiBoss]-GetTime()));
		}
	}

	int iAlivePlayers;
	LoopAlivePlayers(alivePlayers)
	{
		++iAlivePlayers;
	}
	float AddToRage = 0.0;//VSHA_GetBossRage(iiBoss);

	if (iAlivePlayers > 12)
	{
		//PrintCenterTextAll("Saxton Hale's Current Health is: %i of %i", curHealth, curMaxHp);
		AddToRage += 0.5;
	}
	else if(iAlivePlayers > 1)
	{
		//AddToRage += (float((MaxClients + 1) - iAlivePlayers) * 0.001);
		AddToRage += float(iAlivePlayers) * 0.001;
	}
	int iGetOtherTeam = GetClientTeam(iiBoss) == 2 ? 3:2;
	if ( OnlyScoutsLeft(iGetOtherTeam ) )
	{
		AddToRage += 1.0;
		//VSHA_SetBossRage(iiBoss, VSHA_GetBossRage(iiBoss)+0.5);
	}
	if(AddToRage > 0)
	{
		VSHA_SetBossRage(iiBoss, (VSHA_GetBossRage(iiBoss)+AddToRage));
	}


	if ( !(GetEntityFlags(iiBoss) & FL_ONGROUND) ) WeighDownTimer += 0.2;
	else WeighDownTimer = 0.0;

	if ( (buttons & IN_DUCK) && Weighdown(iiBoss, WeighDownTimer, 60.0, 0.0) )
	{
		//CPrintToChat(client, "{olive}[VSHE]{default} You just used your weighdown!");
		//all this just to do a cprint? It's not like weighdown has a limit...
	}
}
public void OnPrepBoss(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	TF2_SetPlayerClass(iiBoss, TFClass_Soldier, _, false);
	HaleCharge[iiBoss] = 0;

	TF2_RemoveAllWeapons2(iiBoss);
	TF2_RemovePlayerDisguise(iiBoss);

	bool pri = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Primary));
	bool sec = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Secondary));
	bool mel = IsValidEntity(GetPlayerWeaponSlot(iiBoss, TFWeaponSlot_Melee));

	if (pri || sec || !mel)
	{
		TF2_RemoveAllWeapons2(iiBoss);
		char attribs[PATH];
		Format(attribs, sizeof(attribs), "68 ; 2.0 ; 2 ; 3.0 ; 259 ; 1.0 ; 252 ; 0.6 ; 214 ; %d", GetRandomInt(999, 9999));
		int SaxtonWeapon = SpawnWeapon(iiBoss, "tf_weapon_shovel", 5, 100, 4, attribs);
		SetEntPropEnt(iiBoss, Prop_Send, "m_hActiveWeapon", SaxtonWeapon);
	}
}
public Action OnMusic(int iBossArrayListIndex, int iiBoss, char BossTheme[PATHX], float &ftime)
{
	if (iThisPlugin != iBossArrayListIndex) return Plugin_Continue;

	if (iiBoss<0)
	{
		return Plugin_Continue;
	}

	//char BossTheme[256];
	//float ftime;

	switch ( GetRandomInt(0, 2) )
	{
		case 0:
		{
			BossTheme = HaleTheme1;
			ftime = 150.0;
		}
		case 1:
		{
			BossTheme = HaleTheme2;
			ftime = 150.0;
		}
		case 2:
		{
			BossTheme = HaleTheme3;
			ftime = 220.0;
		}
	}
	//StringMap SoundMap = new StringMap();
	//SoundMap.SetString("Sound", BossTheme);
	//VSHA_SetVar(EventSound,SoundMap);
	//VSHA_SetVar(EventTime,time);

	return Plugin_Continue;
}
bool InRage[PATHX];
public void OnBossRage(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;
	if (InRage[iiBoss]) return;
	// Helps prevent multiple rages
	InRage[iiBoss] = true;
	char playsound[PATHX];
	float pos[3];
	GetEntPropVector(iiBoss, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 20.0;
	TF2_AddCondition(iiBoss, view_as<TFCond>(42), 4.0);
	strcopy(playsound, PLATFORM_MAX_PATH, "");
	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleRageSound, GetRandomInt(1, 4));
	EmitSoundToAll(playsound, iiBoss, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, pos, NULL_VECTOR, true, 0.0);
	EmitSoundToAll(playsound, iiBoss, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, pos, NULL_VECTOR, true, 0.0);
	CreateTimer(0.6, UseRage, iiBoss);
}
public void TF2_OnConditionAdded(int client, TFCond condition)
{
	if(VSHA_GetBossArrayListIndex(client)!=iThisPlugin) return;

	switch (condition)
	{
		case TFCond_Jarated:
		{
			VSHA_SetBossRage(client, VSHA_GetBossRage(client)-8.0);
			TF2_RemoveCondition(client, condition);
		}
		case TFCond_MarkedForDeath:
		{
			VSHA_SetBossRage(client, VSHA_GetBossRage(client)-5.0);
			TF2_RemoveCondition(client, condition);
		}
		case TFCond_Disguised: TF2_RemoveCondition(client, condition);
	}
	if (TF2_IsPlayerInCondition(client, view_as<TFCond>(42))
		&& TF2_IsPlayerInCondition(client, TFCond_Dazed)) TF2_RemoveCondition(client, TFCond_Dazed);
}
public void OnBossStabbedPost(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	char playsound[PATHX];
	Format(playsound, PLATFORM_MAX_PATH, "%s%i.wav", HaleStubbed132, GetRandomInt(1, 4));
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
	EmitSoundToAll(playsound, _, SNDCHAN_VOICE, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, iiBoss, NULL_VECTOR, NULL_VECTOR, false, 0.0);
}

public Action UseRage(Handle hTimer, int iiBoss)
{
	float pos[3], pos2[3];
	int i;
	float distance;
	if (!IsValidClient(iiBoss)) return Plugin_Continue;
	if (!GetEntProp(iiBoss, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(iiBoss, Prop_Send, "m_hHighFivePartner")))
	{
		TF2_RemoveCondition(iiBoss, TFCond_Taunting);
	}
	GetEntPropVector(iiBoss, Prop_Send, "m_vecOrigin", pos);
	LoopMaxClients(target)
	{
		if (IsValidClient(target) && IsPlayerAlive(target) && target != iiBoss)
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
			distance = GetVectorDistance(pos, pos2);
			if (!TF2_IsPlayerInCondition(target, TFCond_Ubercharged) && distance < RageDist)
			{
				//int flags = TF_STUNFLAGS_GHOSTSCARE;
				//flags |= TF_STUNFLAG_NOSOUNDOREFFECT;
				CreateTimer( 5.0, RemoveEnt, EntIndexToEntRef(AttachParticle(target, "yikes_fx", 75.0)) );
				TF2_StunPlayer(target, 5.0, _, (TF_STUNFLAGS_GHOSTSCARE|TF_STUNFLAG_NOSOUNDOREFFECT), iiBoss);
				//if (CheckRoundState() != 0) TF2_StunPlayer(target, 5.0, _, flags, iiBoss);
			}
		}
	}
	StunSentry( iiBoss, RageDist, 6.0, GetEntProp(i, Prop_Send, "m_iHealth") );
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_dispenser")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (distance < RageDist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}
	i = -1;
	while ((i = FindEntityByClassname2(i, "obj_teleporter")) != -1)
	{
		GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos2);
		distance = GetVectorDistance(pos, pos2);
		if (distance < RageDist)    //(!mode && (distance < RageDist)) || (mode && (distance < RageDist/2)))
		{
			SetVariantInt(1);
			AcceptEntityInput(i, "RemoveHealth");
		}
	}
	InRage[iiBoss]=false;
	return Plugin_Continue;
}
public Action Timer_StopTickle(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return Plugin_Continue;
	if (!GetEntProp(client, Prop_Send, "m_bIsReadyToHighFive") && !IsValidEntity(GetEntPropEnt(client, Prop_Send, "m_hHighFivePartner"))) TF2_RemoveCondition(client, TFCond_Taunting);
	return Plugin_Continue;
}
// stocks
stock bool OnlyScoutsLeft( int iTeam )
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == iTeam)
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) return false;
		}
	}
	return true;
}

// LOAD CONFIGURATION
public void OnConfiguration_Load_Sounds(char[] cFile, char[] skey, char[] value, bool &bPreCacheFile, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	// AutoLoad is not attached to any variable
	if(StrEqual(skey, "AutoLoad"))
	{
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleTheme1"))
	{
		strcopy(STRING(HaleTheme1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleTheme2"))
	{
		strcopy(STRING(HaleTheme2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleTheme3"))
	{
		strcopy(STRING(HaleTheme3), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleComicArmsFallSound"))
	{
		strcopy(STRING(HaleComicArmsFallSound), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleLastB"))
	{
		strcopy(STRING(HaleLastB), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKSpree"))
	{
		strcopy(STRING(HaleKSpree), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKSpree2"))
	{
		strcopy(STRING(HaleKSpree2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleRoundStart"))
	{
		strcopy(STRING(HaleRoundStart), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleJump"))
	{
		strcopy(STRING(HaleJump), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleRageSound"))
	{
		strcopy(STRING(HaleRageSound), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillMedic"))
	{
		strcopy(STRING(HaleKillMedic), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillSniper1"))
	{
		strcopy(STRING(HaleKillSniper1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillSniper2"))
	{
		strcopy(STRING(HaleKillSniper2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillSpy1"))
	{
		strcopy(STRING(HaleKillSpy1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillSpy2"))
	{
		strcopy(STRING(HaleKillSpy2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillEngie1"))
	{
		strcopy(STRING(HaleKillEngie1), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillEngie2"))
	{
		strcopy(STRING(HaleKillEngie2), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKSpreeNew"))
	{
		strcopy(STRING(HaleKSpreeNew), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleWin"))
	{
		strcopy(STRING(HaleWin), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleLastMan"))
	{
		strcopy(STRING(HaleLastMan), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleFail"))
	{
		strcopy(STRING(HaleFail), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleJump132"))
	{
		strcopy(STRING(HaleJump132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleStart132"))
	{
		strcopy(STRING(HaleStart132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillDemo132"))
	{
		strcopy(STRING(HaleKillDemo132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillEngie132"))
	{
		strcopy(STRING(HaleKillEngie132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillHeavy132"))
	{
		strcopy(STRING(HaleKillHeavy132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillScout132"))
	{
		strcopy(STRING(HaleKillScout132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillSpy132"))
	{
		strcopy(STRING(HaleKillSpy132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillPyro132"))
	{
		strcopy(STRING(HaleKillPyro132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleSappinMahSentry132"))
	{
		strcopy(STRING(HaleSappinMahSentry132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillKSpree132"))
	{
		strcopy(STRING(HaleKillKSpree132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleKillLast132"))
	{
		strcopy(STRING(HaleKillLast132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}
	else if(StrEqual(skey, "HaleStubbed132"))
	{
		strcopy(STRING(HaleStubbed132), value);
		bPreCacheFile = true;
		bAddFileToDownloadsTable = true;
	}

	if(bPreCacheFile || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading Sounds %s = %s",skey,value);
	}
}
public void OnConfiguration_Load_Materials(char[] cFile, char[] skey, char[] value, bool &bPrecacheGeneric, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	if(StrEqual(skey, "MaterialPrefix"))
	{
		char s[PATHX];
		char extensionsb[][] = { ".vtf", ".vmt" };

		for (int i = 0; i < sizeof(extensionsb); i++)
		{
			Format(s, PATHX, "%s%s", value, extensionsb[i]);
			if ( FileExists(s, true) )
			{
				AddFileToDownloadsTable(s);

				PrintToServer("Loading Materials %s",s);
			}
		}
	}
}
public void OnConfiguration_Load_Models(char[] cFile, char[] skey, char[] value, bool &bPreCacheModel, bool &bAddFileToDownloadsTable)
{
	if(!StrEqual(cFile, ThisConfigurationFile)) return;

	if(StrEqual(skey, "HaleModel"))
	{
		strcopy(STRING(HaleModel), value);
		bPreCacheModel = true;
		bAddFileToDownloadsTable = true;
		// For Model Manager:
		VSHA_SetPluginModel(iThisPlugin, HaleModel);
	}
	else if(StrEqual(skey, "HaleModelPrefix"))
	{
		char s[PATHX];
		char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };

		for (int i = 0; i < sizeof(extensions); i++)
		{
			Format(s, PATHX, "%s%s", HaleModelPrefix, extensions[i]);
			if ( FileExists(s, true) )
			{
				AddFileToDownloadsTable(s);
				PrintToServer("Loading Model %s = %s",skey,value);
			}
		}
	}
	if(bPreCacheModel || bAddFileToDownloadsTable)
	{
		PrintToServer("Loading Model %s = %s",skey,value);
	}
}
// Just in case you want to have extra configurations for your sub plugin.
// This makes loading configurations easier for you.
// Keeping all your configurations for your sub plugin in one location!
/*
public void VSHA_OnConfiguration_Load_Misc(char[] cFile, char[] skey, char[] value)
{
}
*/

// Is triggered by VSHA engine when a boos needs a help menu
public void OnShowBossHelpMenu(int iBossArrayListIndex, int iiBoss)
{
	if (iThisPlugin != iBossArrayListIndex) return;

	if(ValidPlayer(iiBoss))
	{
		Handle panel = CreatePanel();
		char s[512];
		Format(s, 512, "Help menu needs work.");
		SetPanelTitle(panel, s);
		DrawPanelItem(panel, "Exit");
		SendPanelToClient(panel, iiBoss, HintPanelH, 12);
		CloseHandle(panel);
	}
}

public int HintPanelH(Handle menu, MenuAction action, int param1, int param2)
{
	if (!ValidPlayer(param1)) return;
	//if (action == MenuAction_Select || (action == MenuAction_Cancel && param2 == MenuCancel_Exit)) VSHFlags[param1] |= VSHFLAG_CLASSHELPED;
	return;
}

#if !defined _smlib_included
/* SMLIB
 * Precaches the given particle system.
 * It's best to call this OnMapStart().
 * Code based on Rochellecrab's, thanks.
 *
 * @param particleSystem    Name of the particle system to precache.
 * @return                  Returns the particle system index, INVALID_STRING_INDEX on error.
 */
stock int PrecacheParticleSystem(const char[] particleSystem)
{
	static int particleEffectNames = INVALID_STRING_TABLE;

	if (particleEffectNames == INVALID_STRING_TABLE) {
		if ((particleEffectNames = FindStringTable("ParticleEffectNames")) == INVALID_STRING_TABLE) {
			return INVALID_STRING_INDEX;
		}
	}

	int index = FindStringIndex2(particleEffectNames, particleSystem);
	if (index == INVALID_STRING_INDEX) {
		int numStrings = GetStringTableNumStrings(particleEffectNames);
		if (numStrings >= GetStringTableMaxStrings(particleEffectNames)) {
			return INVALID_STRING_INDEX;
		}

		AddToStringTable(particleEffectNames, particleSystem);
		index = numStrings;
	}

	return index;
}

/* SMLIB
 * Rewrite of FindStringIndex, because in my tests
 * FindStringIndex failed to work correctly.
 * Searches for the index of a given string in a string table.
 *
 * @param tableidx      A string table index.
 * @param str           String to find.
 * @return              String index if found, INVALID_STRING_INDEX otherwise.
 */
stock int FindStringIndex2(int tableidx, const char[] str)
{
	char buf[1024];

	int numStrings = GetStringTableNumStrings(tableidx);
	for (int i=0; i < numStrings; i++) {
		ReadStringTable(tableidx, i, buf, sizeof(buf));

		if (StrEqual(buf, str)) {
			return i;
		}
	}

	return INVALID_STRING_INDEX;
}
#endif
