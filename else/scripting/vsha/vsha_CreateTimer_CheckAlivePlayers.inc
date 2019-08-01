// vsha_CreateTimer_CheckAlivePlayers.inc

public Action CheckAlivePlayers(Handle timer, int data)
{
	if ( CheckRoundState() == 2 ) return Plugin_Continue;
	iRedAlivePlayers = 0, iBluAlivePlayers = 0;
	for (int client = 1; client <= MaxClients; client++)
	{
		if ( IsClientInGame(client) && IsPlayerAlive(client) )
		{
			if (GetClientTeam(client) == OtherTeam) iRedAlivePlayers++;
			else if (GetClientTeam(client) == HaleTeam) iBluAlivePlayers++;
		}
	}
#if defined DEBUG
	DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Players Looped ****");
#endif
	if (iRedAlivePlayers <= 0) ForceTeamWin(HaleTeam);
	else if (iRedAlivePlayers == 1 && iBluAlivePlayers)
	{
		//VSHA_Private_Forward("VSHA_OnLastSurvivor");
		VSHA_OnLastSurvivor();

		/*char message[PATH];
		for (int boss = 1; bIsBoss[boss]; boss++)
		{
			if (IsValidClient(boss)) Format(message, sizeof(message), "%s\n%N's Health is %i of %i", message, boss, iBossHealth[boss], iBossMaxHealth[boss]);
		}
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsValidClient(target)) PrintCenterText(target, message);
		}
		decl String:sound[PLATFORM_MAX_PATH];
		if(RandomSound("sound_lastman", sound, PLATFORM_MAX_PATH))
		{
			EmitSoundToAll(sound);
			EmitSoundToAll(sound);
		}*/
	}
	else if ( !PointType && (iRedAlivePlayers <= AliveToEnable.IntValue) && !PointReady ) //GetConVarInt(AliveToEnable)
	{
		if (iRedAlivePlayers == AliveToEnable.IntValue) //GetConVarInt(AliveToEnable))
		{
			char sound[PATH];
			if (GetRandomInt(0, 1))
			{
				Format(sound, sizeof(sound), "vo/announcer_am_capenabled0%i.wav", GetRandomInt(1, 4));
				EmitSoundToAll(sound);
			}
			else
			{
				int i = GetRandomInt(1, 4);
				if ( !(i % 2) ) i--;
				Format(sound, sizeof(sound), "vo/announcer_am_capincite0%i.wav", i);
				EmitSoundToAll(sound);
			}
		}
		SetControlPoint(true);
		PointReady = true; //:>
#if defined DEBUG
		DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Control Point Control Enabled ****");
#endif
	}
	if ( iRedAlivePlayers <= CountDownPlayerLimit.IntValue &&
		iLowestBossHP > CountDownHealthLimit.IntValue &&
		LastPlayersTimerCountDown.IntValue > 1 && !DrawGameTimer )
	{
		if (FindEntityByClassname2(-1, "team_control_point") != -1)
		{
			timeleft = LastPlayersTimerCountDown.IntValue; //GetConVarInt(LastPlayersTimerCountDown);
			DrawGameTimer = CreateTimer(1.0, Timer_DrawGame, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
#if defined DEBUG
			DEBUGPRINT1("VSH Engine::CheckAlivePlayers() **** Final Countdown Created ****");
#endif
		}
	}
	return Plugin_Continue;
}
