// vsha_000_OnMapStart.inc

public void OnMapStart()
{
	if ( IsVSHMap() )
	{
		Enabled = true;

		PrecacheModel(GIBmodel, true);
		//BloodSpraymodelEntity = PrecacheModel(BloodDropmodel, true);
		//BloodDropmodelEntity = PrecacheModel(BloodSpraymodel, true);

		tf_arena_use_queue = GetConVarInt( FindConVar("tf_arena_use_queue") );
		mp_teams_unbalance_limit = GetConVarInt( FindConVar("mp_teams_unbalance_limit") );
		tf_arena_first_blood = GetConVarInt( FindConVar("tf_arena_first_blood") );
		mp_forcecamera = GetConVarInt( FindConVar("mp_forcecamera") );
		tf_scout_hype_pep_max = GetConVarFloat( FindConVar("tf_scout_hype_pep_max") );
		CacheDownloads();
		//FindHealthBar(); // removed so that UpdateHealthBar would do the checking.
#if defined _steamtools_included
		if (steamtools)
		{
			char gameDesc[64];
			Format(gameDesc, sizeof(gameDesc), "VS Saxton Hale Advanced v%s", PLUGIN_VERSION);
			Steam_SetGameDescription(gameDesc);
		}
#endif
		SetConVarInt(FindConVar("tf_arena_use_queue"), 0);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), FirstRound.BoolValue ? 0 : 1); //GetConVarBool(FirstRound)
		SetConVarInt(FindConVar("tf_arena_first_blood"), 0);
		SetConVarInt(FindConVar("mp_forcecamera"), 0);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), 100.0);
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::OnMapStart() **** Map is VSH map & VSHA is enabled! ****");
#endif
		CreateTimer(1.0, WatchGameModeTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

		// Model Manager
		CreateTimer(2.0, MakeModelTimer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		Enabled = false; //enforcing strict arena only
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
		DEBUGPRINT2("{lime}VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
		DEBUGPRINT3("VSH Engine::OnMapStart() **** Plugin Disabled Cuz current map is not VSH/FF2 compatible ****");
#endif
	}
}
