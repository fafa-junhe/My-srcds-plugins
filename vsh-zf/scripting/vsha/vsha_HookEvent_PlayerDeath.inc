// vsha_HookEvent_PlayerDeath.inc

stock void WriteParticle(int Ent, char[] ParticleName)
{

	//Declare:
	int Particle;
	char tName[64];

	//Initialize:
	Particle = CreateEntityByName("info_particle_system");

	//Validate:
	if(IsValidEdict(Particle))
	{

		//Declare:
		float Position[3], Angles[3];

		//Initialize:
		Angles[0] = GetRandomFloat(0.0, 360.0);
		Angles[1] = GetRandomFloat(0.0, 15.0);
		Angles[2] = GetRandomFloat(0.0, 15.0);

		//Origin:
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", Position);
		Position[2] += GetRandomFloat(35.0, 65.0);
		TeleportEntity(Particle, Position, Angles, NULL_VECTOR);

		//Properties:
		GetEntPropString(Ent, Prop_Data, "m_iName", tName, sizeof(tName));
		StrCat(tName,63,"unambiguate");
		DispatchKeyValue(Particle, "targetname", "TF2Particle");
		DispatchKeyValue(Particle, "parentname", tName);
		DispatchKeyValue(Particle, "effect_name", ParticleName);

		//Spawn:
		DispatchSpawn(Particle);

		//Parent:
		//SetVariantString(tName);
		//AcceptEntityInput(Particle, "SetParent", -1, -1, 0);
		ActivateEntity(Particle);
		AcceptEntityInput(Particle, "start");

		//Delete:
		CreateTimer(6.0, DeleteParticle, Particle);
	}
}

//Delete:
public Action DeleteParticle(Handle Timer, any Particle)
{

	//Validate:
	if(IsValidEntity(Particle))
	{

		//Declare:
		char Classname[64];

		//Initialize:
		GetEdictClassname(Particle, Classname, sizeof(Classname));

		//Is a Particle:
		if(StrEqual(Classname, "info_particle_system", false))
		{

			//Delete:
			RemoveEdict(Particle);
		}
	}
}

public void Gore(int client)
{
	WriteParticle(client, "blood_spray_red_01_far");
	WriteParticle(client, "blood_impact_red_01");
}

int RuptureLoopCheck = 0;

public Action RuptureLoop(Handle Timer, int victim)
{
	if(!ValidPlayer(victim))
	{
		RuptureLoopCheck=0;
		return Plugin_Stop;
	}
	RuptureLoopCheck++;
	if(RuptureLoopCheck > 30)
	{
		RuptureLoopCheck=0;
		return Plugin_Stop;
	}
	Gore(victim);
	return Plugin_Continue;
}

public Action PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if ( !Enabled || CheckRoundState() != 1 || (event.GetInt("death_flags") & TF_DEATHFLAG_DEADRINGER) )
	{
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
		DEBUGPRINT2("{lime}VSH Engine::PlayerDeath() **** PlayerDeath Skipped ****");
#endif
		return Plugin_Continue;
	}
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	CreateTimer(0.2, CheckAlivePlayers);
	SetClientOverlay(victim, "");
	if (!bIsBoss[victim])
	{
		CPrintToChat( victim, "{olive}[VSHA Engine]{default} Damage dealt: {red}%i{default}. Score for this round: {red}%i{default}", iDamage[victim], RoundFloat(iDamage[victim]/600.0) );
		if (bIsBoss[attacker])
		{
			if ( GetGameTime() <= flKillStreak[attacker] ) iPlayerKilled[attacker][1]++;
			else iPlayerKilled[attacker][1] = 0;

			//VSHA_SetVar(EventBoss,victim);
			//VSHA_SetVar(EventAttacker,attacker);
			//VSHA_Private_Forward("VSHA_OnPlayerKilledByBoss");

			VSHA_OnPlayerKilledByBoss(victim, attacker);

			if ( iPlayerKilled[attacker][1] >= GetRandomInt(2, 3) )
			{
				//VSHA_SetVar(EventBoss,victim);
				//VSHA_SetVar(EventAttacker,attacker);
				//VSHA_Private_Forward("VSHA_OnKillingSpreeByBoss");

				VSHA_OnKillingSpreeByBoss(victim, attacker);

				iPlayerKilled[attacker][1] = 0;
			}
			else flKillStreak[attacker] = GetGameTime() + 5.0;
			iPlayerKilled[attacker][0]++;
		}
		if (TF2_GetPlayerClass(victim) == TFClass_Engineer) //Destroys sentry gun when Engineer dies before it.
		{
			FakeClientCommand(victim, "destroy 2");
			int KillSentry = FindSentry(victim);
			if ( KillSentry != -1 )
			{
				SetVariantInt(GetEntPropEnt(KillSentry, Prop_Send, "m_iMaxHealth")+1);
				AcceptEntityInput(KillSentry, "RemoveHealth");

				Event engieevent = CreateEvent("object_removed", true);
				engieevent.SetInt("userid", GetClientUserId(victim));
				engieevent.SetInt("index", KillSentry);
				engieevent.Fire();
				AcceptEntityInput(KillSentry, "Kill");
			}
		}
	}
	else if (bIsBoss[victim] && !bIsBoss[attacker])
	{
		iBossesKilled[attacker]++;
		if ( iBossHealth[victim] < 0 ) iBossHealth[victim] = 0;

		//VSHA_SetVar(EventBoss,victim);
		//VSHA_SetVar(EventAttacker,attacker);
		//VSHA_Private_Forward("VSHA_OnBossKilled");

		// Create the illusion the boss was killed!
		CreateTimer(0.1,RuptureLoop, victim,TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		float Origin[3], Direction[3];
		GetClientAbsOrigin(victim, Origin);

		Origin[2]+=45;

		Direction[0] = GetRandomFloat(-100.0, 100.0);
		Direction[1] = GetRandomFloat(-100.0, 100.0);
		Direction[2] = 300.0;
		Gib(Origin, Direction, GIBmodel);

		VSHA_OnBossKilled(victim, attacker);

		SDKUnhook(victim, SDKHook_GetMaxHealth, OnGetMaxHealth);

		UpdateHealthBar();
		iStabbed[victim] = 0;
		iMarketed[victim] = 0;
		// moved to calculation of scores
		//bIsBoss[victim] = false;
	}
	return Plugin_Continue;
}
