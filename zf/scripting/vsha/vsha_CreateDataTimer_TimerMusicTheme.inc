// vsha_CreateDataTimer_TimerMusicTheme.inc

public Action TimerMusicTheme(Handle timer, DataPack pack)
{
	if (Enabled && (CheckRoundState() == ROUNDSTATE_START_ROUND_TIMER || CheckRoundState() == ROUNDSTATE_EVENT_ROUND_START))
	{
		char sound[PATHX];
		float ftime = -1.0;

		pack.Reset();
		pack.ReadString( sound, sizeof(sound) );
		ftime = pack.ReadFloat();

		//PrintToChatAll("sound: %s",sound);

		if (sound[0] != '\0' && !StrEqual(sound,""))
		{
			if(IsSoundPrecached(sound))
			{
				EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
				PrintToServer("[VSHA] Music Theme '%s' played.",sound);

				if(ftime > 0.0)
				{
					DataPack SndPack = new DataPack();
					SndPack.WriteString(sound);
					SndPack.WriteFloat(ftime);
					MusicTimer = CreateTimer(ftime, TimerMusicTheme, SndPack, TIMER_DATA_HNDL_CLOSE);
				}
			}
		}
		//PrintToChatAll("TimerMusicTheme datapack timer");
	}
	else
	{
		//PrintToChatAll("vsha_CreateDataTimer_TimerMusicTheme stopped MusicPlay");
		ClearTimer(MusicTimer);
		MusicTimer = null;
		return Plugin_Stop;
	}
	MusicTimer = null;
	return Plugin_Continue;
}
