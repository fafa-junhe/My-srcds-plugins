// vsha_CreateTimer_MusicPlay.inc

public Action MusicPlay(Handle Timer, int userid)
{
	int iClient = GetClientOfUserId(userid);
	if (CheckRoundState() != ROUNDSTATE_START_ROUND_TIMER && CheckRoundState() != ROUNDSTATE_EVENT_ROUND_START)
	{
		//PrintToChatAll("vsha_PawnTimer_MusicPlay stopped MusicPlay");
		return;
	}
	char sound[PATHX];
	float ftime = -1.0;
	ClearTimer(MusicTimer);

	sound[0] = '\0';

	//StringMap SoundMap = new StringMap();
	//SoundMap.SetString("Sound", sound);

	//VSHA_SetVar(EventSound,SoundMap);
	//VSHA_SetVar(EventTime,ftime);
	//VSHA_Private_Forward("VSHA_OnMusic");

	if(AllowMusic)
	{
		VSHA_OnMusic(iClient, sound, ftime);
	}
	else if(userid == -2)
	{
		// Send OnMusic to Game Mode Addon
		VSHA_OnMusic(-2, sound, ftime);
	}

	//SoundMap = VSHA_GetVar(EventSound);
	//ftime = view_as<float>(VSHA_GetVar(EventTime));

	//PrintToChatAll("Music Time %.2f",ftime);

	//SoundMap.GetString("Sound",STRING(sound));

	//PrintToChatAll("VSHA_OnMusic %s",sound);

	if ( sound[0] != '\0' && !StrEqual(sound,""))
	{
		if(IsSoundPrecached(sound))
		{
			//Format(sound, sizeof(sound), "#%s", sound);
			EmitSoundToAll(sound, _, _, SNDLEVEL_TRAFFIC, SND_NOFLAGS, SNDVOL_NORMAL, 100, _, nullvec, nullvec, false, 0.0);
			PrintToServer("[VSHA] Music Theme '%s' played.",sound);

			if ( ftime > 0.0 )
			{
				//PrintToChatAll("Started CreateDataTimer for MusicPlay");

				DataPack SndPack = new DataPack();
				SndPack.WriteString(sound);
				SndPack.WriteFloat(ftime);
				MusicTimer = CreateTimer(ftime, TimerMusicTheme, SndPack, TIMER_DATA_HNDL_CLOSE);
			}
		}
	}
	return;
}
