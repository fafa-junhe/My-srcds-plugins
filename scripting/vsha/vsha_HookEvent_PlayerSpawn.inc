// vsha_HookEvent_PlayerSpawn.inc

public Action PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if (!Enabled) return Plugin_Continue;
	int client = GetClientOfUserId( event.GetInt("userid") );
	//if ( client && IsClientInGame(client) && (CheckRoundState() == ROUNDSTATE_EVENT_ROUND_START || CheckRoundState() == ROUNDSTATE_START_ROUND_TIMER) )
	if ( ValidPlayer(client) )
	{
		if ( bIsBoss[client] )
		{
			iModelRetrys[client] = 25;
			//DP("Player Spawn MakeBoss");
			//PawnTimer(MakeBoss, 0.5, GetClientUserId(client)); //CreateTimer(0.1, MakeBoss, GetClientUserId(client));
			CreateTimer(0.2, MakeBoss, GetClientUserId(client));
		}
		else
		{
			SetVariantString("");
			AcceptEntityInput(client, "SetCustomModel");

			TF2_RemoveAllWeapons2(client);
			TF2_RegeneratePlayer(client);
			CreateTimer(0.2, EquipPlayers, GetClientUserId(client));
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::PlayerSpawn() **** Non-Boss Player sent to Equip Timer! ****");
#endif
		}
	}
	if ( CheckRoundState() == 1 ) CreateTimer(0.2, CheckAlivePlayers);
	return Plugin_Continue;
}
