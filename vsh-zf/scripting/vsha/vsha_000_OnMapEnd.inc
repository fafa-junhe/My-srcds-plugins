// vsha_000_OnMapEnd.inc

public void OnMapEnd()
{
	if ( Enabled )
	{
		SetConVarInt(FindConVar("tf_arena_use_queue"), tf_arena_use_queue);
		SetConVarInt(FindConVar("mp_teams_unbalance_limit"), mp_teams_unbalance_limit);
		SetConVarInt(FindConVar("tf_arena_first_blood"), tf_arena_first_blood);
		SetConVarInt(FindConVar("mp_forcecamera"), mp_forcecamera);
		SetConVarFloat(FindConVar("tf_scout_hype_pep_max"), tf_scout_hype_pep_max);
#if defined _steamtools_included
		if (steamtools) Steam_SetGameDescription("Team Fortress");
#endif
	}

	ClearAllVariables();
}
