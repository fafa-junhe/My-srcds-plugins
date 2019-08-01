#if defined _sf2_profiles_included
 #endinput
#endif
#define _sf2_profiles_included

#define FILE_PROFILES "configs/sf2/profiles.cfg"
#define FILE_PROFILES_PACKS "configs/sf2/profiles_packs.cfg"
#define FILE_PROFILES_PACKS_DIR "configs/sf2/profiles/packs"

static Handle:g_hBossProfileList = INVALID_HANDLE;
static Handle:g_hSelectableBossProfileList = INVALID_HANDLE;

static Handle:g_hBossProfileNames = INVALID_HANDLE;
static Handle:g_hBossProfileData = INVALID_HANDLE;

new Handle:g_cvBossProfilePack = INVALID_HANDLE;
new Handle:g_cvBossProfilePackDefault = INVALID_HANDLE;

new Handle:g_hBossPackConfig = INVALID_HANDLE;

new Handle:g_cvBossPackEndOfMapVote;
new Handle:g_cvBossPackVoteStartTime;
new Handle:g_cvBossPackVoteStartRound;
new Handle:g_cvBossPackVoteShuffle;

static bool:g_bBossPackVoteEnabled = false;

#if defined METHODMAPS

methodmap SF2BossProfile
{
	property int Index
	{
		public get() { return _:this; }
	}
	
	property int UniqueProfileIndex
	{
		public get() { return GetBossProfileUniqueProfileIndex(this.Index); }
	}
	
	property int Skin
	{
		public get() { return GetBossProfileSkin(this.Index); }
	}
	
	property int BodyGroups
	{
		public get() { return GetBossProfileBodyGroups(this.Index); }
	}
	
	property float ModelScale
	{
		public get() { return GetBossProfileModelScale(this.Index); }
	}
	
	property int Type
	{
		public get() { return GetBossProfileType(this.Index); }
	}
	
	property int Flags
	{
		public get() { return GetBossProfileFlags(this.Index); }
	}
	
	property float SearchRadius
	{
		public get() { return GetBossProfileSearchRadius(this.Index); }
	}
	
	property float FOV
	{
		public get() { return GetBossProfileFOV(this.Index); }
	}
	
	property float TurnRate
	{
		public get() { return GetBossProfileTurnRate(this.Index); }
	}
	
	property float AngerStart
	{
		public get() { return GetBossProfileAngerStart(this.Index); }
	}
	
	property float AngerAddOnPageGrab
	{
		public get() { return GetBossProfileAngerAddOnPageGrab(this.Index); }
	}
	
	property float AngerAddOnPageGrabTimeDiff
	{
		public get() { return GetBossProfileAngerPageGrabTimeDiff(this.Index); }
	}
	
	property float InstantKillRadius
	{
		public get() { return GetBossProfileInstantKillRadius(this.Index); }
	}
	
	property float ScareRadius
	{
		public get() { return GetBossProfileScareRadius(this.Index); }
	}
	
	property float ScareCooldown
	{
		public get() { return GetBossProfileScareCooldown(this.Index); }
	}
	
	property int TeleportType
	{
		public get() { return GetBossProfileTeleportType(this.Index); }
	}
	
	public float GetSpeed(int difficulty)
	{
		return GetBossProfileSpeed(this.Index, difficulty);
	}
	
	public float GetMaxSpeed(int difficulty)
	{
		return GetBossProfileMaxSpeed(this.Index, difficulty);
	}
	
	public void GetEyePositionOffset(float buffer[3])
	{
		GetBossProfileEyePositionOffset(this.Index, buffer);
	}
	
	public void GetEyeAngleOffset(float buffer[3])
	{
		GetBossProfileEyeAngleOffset(this.Index, buffer);
	}
}

#endif

#include "sf2/profiles/profile_chaser.sp"

enum
{
	BossProfileData_UniqueProfileIndex,
	BossProfileData_Type,
	BossProfileData_ModelScale,
	BossProfileData_Skin,
	BossProfileData_Body,
	BossProfileData_Flags,
	
	BossProfileData_SpeedEasy,
	BossProfileData_SpeedNormal,
	BossProfileData_SpeedHard,
	BossProfileData_SpeedInsane,
	
	BossProfileData_WalkSpeedEasy,
	BossProfileData_WalkSpeedNormal,
	BossProfileData_WalkSpeedHard,
	BossProfileData_WalkSpeedInsane,
	
	BossProfileData_AirSpeedEasy,
	BossProfileData_AirSpeedNormal,
	BossProfileData_AirSpeedHard,
	BossProfileData_AirSpeedInsane,
	
	BossProfileData_MaxSpeedEasy,
	BossProfileData_MaxSpeedNormal,
	BossProfileData_MaxSpeedHard,
	BossProfileData_MaxSpeedInsane,
	
	BossProfileData_MaxWalkSpeedEasy,
	BossProfileData_MaxWalkSpeedNormal,
	BossProfileData_MaxWalkSpeedHard,
	BossProfileData_MaxWalkSpeedInsane,
	
	BossProfileData_MaxAirSpeedEasy,
	BossProfileData_MaxAirSpeedNormal,
	BossProfileData_MaxAirSpeedHard,
	BossProfileData_MaxAirSpeedInsane,
	
	BossProfileData_SearchRange,
	BossProfileData_FieldOfView,
	BossProfileData_TurnRate,
	BossProfileData_EyePosOffsetX,
	BossProfileData_EyePosOffsetY,
	BossProfileData_EyePosOffsetZ,
	BossProfileData_EyeAngOffsetX,
	BossProfileData_EyeAngOffsetY,
	BossProfileData_EyeAngOffsetZ,
	BossProfileData_AngerStart,
	BossProfileData_AngerAddOnPageGrab,
	BossProfileData_AngerPageGrabTimeDiffReq,
	BossProfileData_InstantKillRadius,
	
	BossProfileData_ScareRadius,
	BossProfileData_ScareCooldown,
	
	BossProfileData_TeleportType,
	BossProfileData_MaxStats
};

InitializeBossProfiles()
{
	g_hBossProfileNames = CreateTrie();
	g_hBossProfileData = CreateArray(BossProfileData_MaxStats);
	
	g_cvBossProfilePack = CreateConVar("sf2_boss_profile_pack", "", "The boss pack referenced in profiles_packs.cfg that should be loaded.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	g_cvBossProfilePackDefault = CreateConVar("sf2_boss_profile_pack_default", "", "If the boss pack defined in sf2_boss_profile_pack is blank or could not be loaded, this pack will be used instead.", FCVAR_NOTIFY);
	g_cvBossPackEndOfMapVote = CreateConVar("sf2_boss_profile_pack_endvote", "0", "Enables/Disables a boss pack vote at the end of the map.");
	g_cvBossPackVoteStartTime = CreateConVar("sf2_boss_profile_pack_endvote_start", "4", "Specifies when to start the vote based on time remaining on the map, in minutes.", FCVAR_NOTIFY);
	g_cvBossPackVoteStartRound = CreateConVar("sf2_boss_profile_pack_endvote_startround", "2", "Specifies when to start the vote based on rounds remaining on the map.", FCVAR_NOTIFY);
	g_cvBossPackVoteShuffle = CreateConVar("sf2_boss_profile_pack_endvote_shuffle", "0", "Shuffles the menu options of boss pack endvotes if enabled.");
	
	InitializeChaserProfiles();
}

BossProfilesOnMapEnd()
{
	ClearBossProfiles();
}

/**
 *	Clears all data and memory currently in use by all boss profiles.
 */
ClearBossProfiles()
{
	if (g_hBossProfileList != INVALID_HANDLE)
	{
		CloseHandle(g_hBossProfileList);
		g_hBossProfileList = INVALID_HANDLE;
	}
	
	if (g_hSelectableBossProfileList != INVALID_HANDLE)
	{
		CloseHandle(g_hSelectableBossProfileList);
		g_hSelectableBossProfileList = INVALID_HANDLE;
	}
	
	ClearTrie(g_hBossProfileNames);
	ClearArray(g_hBossProfileData);
	
	ClearChaserProfiles();
}

ReloadBossProfiles()
{
	if (g_hConfig != INVALID_HANDLE)
	{
		CloseHandle(g_hConfig);
		g_hConfig = INVALID_HANDLE;
	}
	
	if (g_hBossPackConfig != INVALID_HANDLE)
	{
		CloseHandle(g_hBossPackConfig);
		g_hBossPackConfig = INVALID_HANDLE;
	}
	
	// Clear and reload the lists.
	ClearBossProfiles();
	
	g_hConfig = CreateKeyValues("root");
	g_hBossPackConfig = CreateKeyValues("root");
	
	if (g_hBossProfileList == INVALID_HANDLE)
	{
		g_hBossProfileList = CreateArray(SF2_MAX_PROFILE_NAME_LENGTH);
	}
	
	if (g_hSelectableBossProfileList == INVALID_HANDLE)
	{
		g_hSelectableBossProfileList = CreateArray(SF2_MAX_PROFILE_NAME_LENGTH);
	}
	
	decl String:configPath[PLATFORM_MAX_PATH];
	
	// First load from configs/sf2/profiles.cfg
	BuildPath(Path_SM, configPath, sizeof(configPath), FILE_PROFILES);
	LoadProfilesFromFile(configPath);
	
	BuildPath(Path_SM, configPath, sizeof(configPath), FILE_PROFILES_PACKS);
	FileToKeyValues(g_hBossPackConfig, configPath);
	
	g_bBossPackVoteEnabled = true;
	
	// Try loading boss packs, if they're set to load.
	KvRewind(g_hBossPackConfig);
	if (KvJumpToKey(g_hBossPackConfig, "packs"))
	{
		if (KvGotoFirstSubKey(g_hBossPackConfig))
		{
			new endVoteItemCount = 0;
		
			decl String:forceLoadBossPackName[128];
			GetConVarString(g_cvBossProfilePack, forceLoadBossPackName, sizeof(forceLoadBossPackName));
			
			new bool:voteBossPackLoaded = false;
			
			do
			{
				decl String:bossPackName[128];
				KvGetSectionName(g_hBossPackConfig, bossPackName, sizeof(bossPackName));
				
				new bool:autoLoad = bool:KvGetNum(g_hBossPackConfig, "autoload");
				
				if (autoLoad || (strlen(forceLoadBossPackName) > 0 && StrEqual(forceLoadBossPackName, bossPackName)))
				{
					decl String:packConfigFile[PLATFORM_MAX_PATH];
					KvGetString(g_hBossPackConfig, "file", packConfigFile, sizeof(packConfigFile));
					
					decl String:packConfigFilePath[PLATFORM_MAX_PATH];
					Format(packConfigFilePath, sizeof(packConfigFilePath), "%s/%s", FILE_PROFILES_PACKS_DIR, packConfigFile);
					
					BuildPath(Path_SM, configPath, sizeof(configPath), packConfigFilePath);
					LoadProfilesFromFile(configPath);
					
					if (!voteBossPackLoaded)
					{
						if (StrEqual(forceLoadBossPackName, bossPackName))
						{
							voteBossPackLoaded = true;
						}
					}
				}
				
				if (!autoLoad)
				{
					endVoteItemCount++; 
				}
			}
			while (KvGotoNextKey(g_hBossPackConfig));
			
			KvGoBack(g_hBossPackConfig);
			
			if (!voteBossPackLoaded)
			{
				GetConVarString(g_cvBossProfilePackDefault, forceLoadBossPackName, sizeof(forceLoadBossPackName));
				if (strlen(forceLoadBossPackName) > 0)
				{
					if (KvJumpToKey(g_hBossPackConfig, forceLoadBossPackName))
					{
						decl String:packConfigFile[PLATFORM_MAX_PATH];
						KvGetString(g_hBossPackConfig, "file", packConfigFile, sizeof(packConfigFile));
						
						decl String:packConfigFilePath[PLATFORM_MAX_PATH];
						Format(packConfigFilePath, sizeof(packConfigFilePath), "%s/%s", FILE_PROFILES_PACKS_DIR, packConfigFile);
						
						BuildPath(Path_SM, configPath, sizeof(configPath), packConfigFilePath);
						LoadProfilesFromFile(configPath);
					}
				}
			}
			
			if (endVoteItemCount <= 0)
			{
				g_bBossPackVoteEnabled = false;
			}
		}
		else
		{
			g_bBossPackVoteEnabled = false;
		}
	}
	else
	{
		g_bBossPackVoteEnabled = false;
	}
}

static LoadProfilesFromFile(const String:configPath[])
{
	LogSF2Message("Loading boss profiles from file %s...", configPath);
	
	if (!FileExists(configPath))
	{
		LogSF2Message("File not found! Skipping...");
		return;
	}
	
	new Handle:kv = CreateKeyValues("root");
	if (!FileToKeyValues(kv, configPath))
	{
		CloseHandle(kv);
		LogSF2Message("Unexpected error while reading file! Skipping...");
		return;
	}
	else
	{
		if (KvGotoFirstSubKey(kv))
		{
			decl String:sProfile[SF2_MAX_PROFILE_NAME_LENGTH];
			decl String:sProfileLoadFailReason[512];
			
			new iLoadedCount = 0;
			
			do
			{
				KvGetSectionName(kv, sProfile, sizeof(sProfile));
				if (LoadBossProfile(kv, sProfile, sProfileLoadFailReason, sizeof(sProfileLoadFailReason)))
				{
					iLoadedCount++;
					LogSF2Message("%s...", sProfile);
				}
				else
				{
					LogSF2Message("%s...FAILED (reason: %s)", sProfile, sProfileLoadFailReason);
				}
			}
			while (KvGotoNextKey(kv));
			
			LogSF2Message("Loaded %d boss profile(s) from file!", iLoadedCount);
		}
		else
		{
			LogSF2Message("No boss profiles loaded from file!");
		}
		
		CloseHandle(kv);
	}
}

/**
 *	Loads a profile in the current KeyValues position in kv.
 */
static bool:LoadBossProfile(Handle:kv, const String:sProfile[], String:sLoadFailReasonBuffer[], iLoadFailReasonBufferLen)
{
	new iBossType = KvGetNum(kv, "type", SF2BossType_Unknown);
	if (iBossType == SF2BossType_Unknown || iBossType >= SF2BossType_MaxTypes) 
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "boss type is unknown!");
		return false;
	}
	
	new Float:flBossModelScale = KvGetFloat(kv, "model_scale", 1.0);
	if (flBossModelScale <= 0.0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "model_scale must be a value greater than 0!");
		return false;
	}
	
	new iBossSkin = KvGetNum(kv, "skin");
	if (iBossSkin < 0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "skin must be a value that is at least 0!");
		return false;
	}
	
	new iBossBodyGroups = KvGetNum(kv, "body");
	if (iBossBodyGroups < 0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "body must be a value that is at least 0!");
		return false;
	}
	
	new Float:flBossAngerStart = KvGetFloat(kv, "anger_start", 1.0);
	if (flBossAngerStart < 0.0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "anger_start must be a value that is at least 0!");
		return false;
	}
	
	new Float:flBossInstantKillRadius = KvGetFloat(kv, "kill_radius");
	if (flBossInstantKillRadius < 0.0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "kill_radius must be a value that is at least 0!");
		return false;
	}
	
	new Float:flBossScareRadius = KvGetFloat(kv, "scare_radius");
	if (flBossScareRadius < 0.0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "scare_radius must be a value that is at least 0!");
		return false;
	}
	
	new iBossTeleportType = KvGetNum(kv, "teleport_type");
	if (iBossTeleportType < 0)
	{
		Format(sLoadFailReasonBuffer, iLoadFailReasonBufferLen, "unknown teleport type!");
		return false;
	}
	
	new Float:flBossFOV = KvGetFloat(kv, "fov", 90.0);
	if (flBossFOV < 0.0)
	{
		flBossFOV = 0.0;
	}
	else if (flBossFOV > 360.0)
	{
		flBossFOV = 360.0;
	}
	
	new Float:flBossMaxTurnRate = KvGetFloat(kv, "turnrate", 90.0);
	if (flBossMaxTurnRate < 0.0)
	{
		flBossMaxTurnRate = 0.0;
	}
	
	new Float:flBossScareCooldown = KvGetFloat(kv, "scare_cooldown");
	if (flBossScareCooldown < 0.0)
	{
		// clamp value 
		flBossScareCooldown = 0.0;
	}
	
	new Float:flBossAngerAddOnPageGrab = KvGetFloat(kv, "anger_add_on_page_grab", -1.0);
	if (flBossAngerAddOnPageGrab < 0.0)
	{
		flBossAngerAddOnPageGrab = KvGetFloat(kv, "anger_page_add", -1.0);		// backwards compatibility
		if (flBossAngerAddOnPageGrab < 0.0)
		{
			flBossAngerAddOnPageGrab = 0.0;
		}
	}
	
	new Float:flBossAngerPageGrabTimeDiffReq = KvGetFloat(kv, "anger_req_page_grab_time_diff", -1.0);
	if (flBossAngerPageGrabTimeDiffReq < 0.0)
	{
		flBossAngerPageGrabTimeDiffReq = KvGetFloat(kv, "anger_page_time_diff", -1.0);		// backwards compatibility
		if (flBossAngerPageGrabTimeDiffReq < 0.0)
		{
			flBossAngerPageGrabTimeDiffReq = 0.0;
		}
	}
	
	new Float:flBossSearchRadius = KvGetFloat(kv, "search_radius", -1.0);
	if (flBossSearchRadius < 0.0)
	{
		flBossSearchRadius = KvGetFloat(kv, "search_range", -1.0);		// backwards compatibility
		if (flBossSearchRadius < 0.0)
		{
			flBossSearchRadius = 0.0;
		}
	}
	
	new Float:flBossDefaultSpeed = KvGetFloat(kv, "speed", 150.0);
	new Float:flBossSpeedEasy = KvGetFloat(kv, "speed_easy", flBossDefaultSpeed);
	new Float:flBossSpeedHard = KvGetFloat(kv, "speed_hard", flBossDefaultSpeed);
	new Float:flBossSpeedInsane = KvGetFloat(kv, "speed_insane", flBossDefaultSpeed);
	
	new Float:flBossDefaultMaxSpeed = KvGetFloat(kv, "speed_max", 150.0);
	new Float:flBossMaxSpeedEasy = KvGetFloat(kv, "speed_max_easy", flBossDefaultMaxSpeed);
	new Float:flBossMaxSpeedHard = KvGetFloat(kv, "speed_max_hard", flBossDefaultMaxSpeed);
	new Float:flBossMaxSpeedInsane = KvGetFloat(kv, "speed_max_insane", flBossDefaultMaxSpeed);
	
	decl Float:flBossEyePosOffset[3];
	KvGetVector(kv, "eye_pos", flBossEyePosOffset);
	
	decl Float:flBossEyeAngOffset[3];
	KvGetVector(kv, "eye_ang_offset", flBossEyeAngOffset);
	
	// Parse through flags.
	new iBossFlags = 0;
	if (KvGetNum(kv, "static_shake")) iBossFlags |= SFF_HASSTATICSHAKE;
	if (KvGetNum(kv, "static_on_look")) iBossFlags |= SFF_STATICONLOOK;
	if (KvGetNum(kv, "static_on_radius")) iBossFlags |= SFF_STATICONRADIUS;
	if (KvGetNum(kv, "proxies")) iBossFlags |= SFF_PROXIES;
	if (KvGetNum(kv, "jumpscare")) iBossFlags |= SFF_HASJUMPSCARE;
	if (KvGetNum(kv, "sound_sight_enabled")) iBossFlags |= SFF_HASSIGHTSOUNDS;
	if (KvGetNum(kv, "sound_static_loop_local_enabled")) iBossFlags |= SFF_HASSTATICLOOPLOCALSOUND;
	if (KvGetNum(kv, "view_shake", 1)) iBossFlags |= SFF_HASVIEWSHAKE;
	if (KvGetNum(kv, "copy")) iBossFlags |= SFF_COPIES;
	if (KvGetNum(kv, "wander_move", 1)) iBossFlags |= SFF_WANDERMOVE;
	
	// Try validating unique profile.
	new iUniqueProfileIndex = -1;
	
	switch (iBossType)
	{
		case SF2BossType_Chaser:
		{
			if (!LoadChaserBossProfile(kv, sProfile, iUniqueProfileIndex, sLoadFailReasonBuffer, iLoadFailReasonBufferLen))
			{
				return false;
			}
		}
	}
	
	// Add the section to our config.
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile, true);
	KvCopySubkeys(kv, g_hConfig);
	
	new bool:createNewBoss = false;
	new iIndex = FindStringInArray(GetBossProfileList(), sProfile);
	if (iIndex == -1)
	{
		createNewBoss = true;
	}
	
	// Add to/Modify our array.
	if (createNewBoss)
	{
		iIndex = PushArrayCell(g_hBossProfileData, -1);
		SetTrieValue(g_hBossProfileNames, sProfile, iIndex);
		
		// Add to the boss list since it's not there already.
		PushArrayString(GetBossProfileList(), sProfile);
	}
	
	SetArrayCell(g_hBossProfileData, iIndex, iUniqueProfileIndex, BossProfileData_UniqueProfileIndex);
	
	SetArrayCell(g_hBossProfileData, iIndex, iBossType, BossProfileData_Type);
	SetArrayCell(g_hBossProfileData, iIndex, flBossModelScale, BossProfileData_ModelScale);
	SetArrayCell(g_hBossProfileData, iIndex, iBossSkin, BossProfileData_Skin);
	SetArrayCell(g_hBossProfileData, iIndex, iBossBodyGroups, BossProfileData_Body);
	
	SetArrayCell(g_hBossProfileData, iIndex, iBossFlags, BossProfileData_Flags);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossDefaultSpeed, BossProfileData_SpeedNormal);
	SetArrayCell(g_hBossProfileData, iIndex, flBossSpeedEasy, BossProfileData_SpeedEasy);
	SetArrayCell(g_hBossProfileData, iIndex, flBossSpeedHard, BossProfileData_SpeedHard);
	SetArrayCell(g_hBossProfileData, iIndex, flBossSpeedInsane, BossProfileData_SpeedInsane);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossDefaultMaxSpeed, BossProfileData_MaxSpeedNormal);
	SetArrayCell(g_hBossProfileData, iIndex, flBossMaxSpeedEasy, BossProfileData_MaxSpeedEasy);
	SetArrayCell(g_hBossProfileData, iIndex, flBossMaxSpeedHard, BossProfileData_MaxSpeedHard);
	SetArrayCell(g_hBossProfileData, iIndex, flBossMaxSpeedInsane, BossProfileData_MaxSpeedInsane);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyePosOffset[0], BossProfileData_EyePosOffsetX);
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyePosOffset[1], BossProfileData_EyePosOffsetY);
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyePosOffset[2], BossProfileData_EyePosOffsetZ);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyeAngOffset[0], BossProfileData_EyeAngOffsetX);
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyeAngOffset[1], BossProfileData_EyeAngOffsetY);
	SetArrayCell(g_hBossProfileData, iIndex, flBossEyeAngOffset[2], BossProfileData_EyeAngOffsetZ);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossAngerStart, BossProfileData_AngerStart);
	SetArrayCell(g_hBossProfileData, iIndex, flBossAngerAddOnPageGrab, BossProfileData_AngerAddOnPageGrab);
	SetArrayCell(g_hBossProfileData, iIndex, flBossAngerPageGrabTimeDiffReq, BossProfileData_AngerPageGrabTimeDiffReq);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossInstantKillRadius, BossProfileData_InstantKillRadius);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossScareRadius, BossProfileData_ScareRadius);
	SetArrayCell(g_hBossProfileData, iIndex, flBossScareCooldown, BossProfileData_ScareCooldown);
	
	SetArrayCell(g_hBossProfileData, iIndex, iBossTeleportType, BossProfileData_TeleportType);
	
	SetArrayCell(g_hBossProfileData, iIndex, flBossSearchRadius, BossProfileData_SearchRange);
	SetArrayCell(g_hBossProfileData, iIndex, flBossFOV, BossProfileData_FieldOfView);
	SetArrayCell(g_hBossProfileData, iIndex, flBossMaxTurnRate, BossProfileData_TurnRate);
	
	if (bool:KvGetNum(kv, "enable_random_selection", 1))
	{
		if (FindStringInArray(GetSelectableBossProfileList(), sProfile) == -1)
		{
			// Add to the selectable boss list if it isn't there already.
			PushArrayString(GetSelectableBossProfileList(), sProfile);
		}
	}
	else
	{
		new selectIndex = FindStringInArray(GetSelectableBossProfileList(), sProfile);
		if (selectIndex != -1)
		{
			RemoveFromArray(GetSelectableBossProfileList(), selectIndex);
		}
	}
	
	if (KvGotoFirstSubKey(kv))
	{
		decl String:s2[64], String:s3[64], String:s4[PLATFORM_MAX_PATH], String:s5[PLATFORM_MAX_PATH];
		
		do
		{
			KvGetSectionName(kv, s2, sizeof(s2));
			
			if (!StrContains(s2, "sound_"))
			{
				for (new i = 1;; i++)
				{
					IntToString(i, s3, sizeof(s3));
					KvGetString(kv, s3, s4, sizeof(s4));
					if (!s4[0]) break;
					
					PrecacheSound2(s4);
				}
			}
			else if (StrEqual(s2, "download"))
			{
				for (new i = 1;; i++)
				{
					IntToString(i, s3, sizeof(s3));
					KvGetString(kv, s3, s4, sizeof(s4));
					if (!s4[0]) break;
					
					AddFileToDownloadsTable(s4);
				}
			}
			else if (StrEqual(s2, "mod_precache"))
			{
				for (new i = 1;; i++)
				{
					IntToString(i, s3, sizeof(s3));
					KvGetString(kv, s3, s4, sizeof(s4));
					if (!s4[0]) break;
					
					PrecacheModel(s4, true);
				}
			}
			else if (StrEqual(s2, "mat_download"))
			{	
				for (new i = 1;; i++)
				{
					IntToString(i, s3, sizeof(s3));
					KvGetString(kv, s3, s4, sizeof(s4));
					if (!s4[0]) break;
					
					Format(s5, sizeof(s5), "%s.vtf", s4);
					AddFileToDownloadsTable(s5);
					Format(s5, sizeof(s5), "%s.vmt", s4);
					AddFileToDownloadsTable(s5);
				}
			}
			else if (StrEqual(s2, "mod_download"))
			{
				static const String:extensions[][] = { ".mdl", ".phy", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd" };
				
				for (new i = 1;; i++)
				{
					IntToString(i, s3, sizeof(s3));
					KvGetString(kv, s3, s4, sizeof(s4));
					if (!s4[0]) break;
					
					for (new is = 0; is < sizeof(extensions); is++)
					{
						Format(s5, sizeof(s5), "%s%s", s4, extensions[is]);
						AddFileToDownloadsTable(s5);
					}
				}
			}
		}
		while (KvGotoNextKey(kv));
		
		KvGoBack(kv);
	}
	
	return true;
}

static Handle:g_hBossPackVoteMapTimer;
static Handle:g_hBossPackVoteTimer;
static bool:g_bBossPackVoteCompleted;
static bool:g_bBossPackVoteStarted;

InitializeBossPackVotes()
{
	g_hBossPackVoteMapTimer = INVALID_HANDLE;
	g_hBossPackVoteTimer = INVALID_HANDLE;
	g_bBossPackVoteCompleted = false;
	g_bBossPackVoteStarted = false;
}

SetupTimeLimitTimerForBossPackVote()
{
	new time;
	if (GetMapTimeLeft(time) && time > 0)
	{
		if (GetConVarBool(g_cvBossPackEndOfMapVote) && g_bBossPackVoteEnabled && !g_bBossPackVoteCompleted && !g_bBossPackVoteStarted)
		{
			new startTime = GetConVarInt(g_cvBossPackVoteStartTime) * 60;
			if ((time - startTime) <= 0)
			{
				if (!IsVoteInProgress())
				{
					InitiateBossPackVote();
				}
				else
				{
					g_hBossPackVoteTimer = CreateTimer(5.0, Timer_BossPackVoteLoop, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			else
			{
				if (g_hBossPackVoteMapTimer != INVALID_HANDLE)
				{
					CloseHandle(g_hBossPackVoteMapTimer);
					g_hBossPackVoteMapTimer = INVALID_HANDLE;
				}
				
				g_hBossPackVoteMapTimer = CreateTimer(float(time - startTime), Timer_StartBossPackVote, _, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

CheckRoundLimitForBossPackVote(roundCount)
{
	if (!GetConVarBool(g_cvBossPackEndOfMapVote) || !g_bBossPackVoteEnabled || g_bBossPackVoteStarted || g_bBossPackVoteCompleted) return;
	
	if (g_cvMaxRounds == INVALID_HANDLE) return;
	
	if (GetConVarInt(g_cvMaxRounds) > 0)
	{
		if (roundCount >= (GetConVarInt(g_cvMaxRounds) - GetConVarInt(g_cvBossPackVoteStartRound)))
		{
			if (!IsVoteInProgress())
			{
				InitiateBossPackVote();
			}
			else
			{
				g_hBossPackVoteTimer = CreateTimer(5.0, Timer_BossPackVoteLoop, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	
	CloseHandle(g_cvMaxRounds);
}

InitiateBossPackVote()
{
	if (g_bBossPackVoteStarted || g_bBossPackVoteCompleted || IsVoteInProgress()) return;
	
	// Gather boss packs, if any.
	if (g_hBossPackConfig == INVALID_HANDLE) return;
	
	KvRewind(g_hBossPackConfig);
	if (!KvJumpToKey(g_hBossPackConfig, "packs")) return;
	if (!KvGotoFirstSubKey(g_hBossPackConfig)) return;
	
	new Handle:voteMenu = CreateMenu(Menu_BossPackVote);
	SetMenuTitle(voteMenu, "%t%t\n \n", "SF2 Prefix", "SF2 Boss Pack Vote Menu Title");
	SetMenuExitBackButton(voteMenu, false);
	SetMenuExitButton(voteMenu, false);
	
	new Handle:menuDisplayNamesTrie = CreateTrie();
	new Handle:menuOptionsInfo = CreateArray(128);
	
	do
	{
		if (!bool:KvGetNum(g_hBossPackConfig, "autoload") && bool:KvGetNum(g_hBossPackConfig, "show_in_vote", 1))
		{
			decl String:bossPack[128];
			KvGetSectionName(g_hBossPackConfig, bossPack, sizeof(bossPack));
			
			decl String:bossPackName[64];
			KvGetString(g_hBossPackConfig, "name", bossPackName, sizeof(bossPackName), bossPack);
			
			SetTrieString(menuDisplayNamesTrie, bossPack, bossPackName);
			PushArrayString(menuOptionsInfo, bossPack);
		}
	}
	while (KvGotoNextKey(g_hBossPackConfig));
	
	if (GetArraySize(menuOptionsInfo) == 0)
	{
		CloseHandle(menuDisplayNamesTrie);
		CloseHandle(menuOptionsInfo);
		CloseHandle(voteMenu);
		return;
	}
	
	if (GetConVarBool(g_cvBossPackVoteShuffle))
	{
		SortADTArray(menuOptionsInfo, Sort_Random, Sort_String);
	}
	
	for (new i = 0; i < GetArraySize(menuOptionsInfo); i++)
	{
		decl String:bossPack[128], String:bossPackName[64];
		GetArrayString(menuOptionsInfo, i, bossPack, sizeof(bossPack));
		GetTrieString(menuDisplayNamesTrie, bossPack, bossPackName, sizeof(bossPackName));
		
		AddMenuItem(voteMenu, bossPack, bossPackName);
	}
	
	CloseHandle(menuDisplayNamesTrie);
	CloseHandle(menuOptionsInfo);
	
	g_bBossPackVoteStarted = true;
	if (g_hBossPackVoteMapTimer != INVALID_HANDLE)
	{
		CloseHandle(g_hBossPackVoteMapTimer);
		g_hBossPackVoteMapTimer = INVALID_HANDLE;
	}
	
	if (g_hBossPackVoteTimer != INVALID_HANDLE)
	{
		CloseHandle(g_hBossPackVoteTimer);
		g_hBossPackVoteTimer = INVALID_HANDLE;
	}
	
	VoteMenuToAll(voteMenu, 20);
}

public Menu_BossPackVote(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_VoteStart:
		{
			g_bBossPackVoteStarted = true;
		}
		case MenuAction_VoteEnd:
		{
			g_bBossPackVoteCompleted = true;
		
			decl String:bossPack[128], String:bossPackName[64];
			GetMenuItem(menu, param1, bossPack, sizeof(bossPack), _, bossPackName, sizeof(bossPackName));
			
			SetConVarString(g_cvBossProfilePack, bossPack);
			
			CPrintToChatAll("%t%t", "SF2 Prefix", "SF2 Boss Pack Vote Successful", bossPackName);
		}
		case MenuAction_End:
		{
			g_bBossPackVoteStarted = false;
			CloseHandle(menu);
		}
	}
}

public Action:Timer_StartBossPackVote(Handle:timer)
{
	if (timer != g_hBossPackVoteMapTimer) return;
	
	g_hBossPackVoteTimer = CreateTimer(5.0, Timer_BossPackVoteLoop, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TriggerTimer(g_hBossPackVoteTimer, true);
}

public Action:Timer_BossPackVoteLoop(Handle:timer)
{
	if (timer != g_hBossPackVoteTimer || g_bBossPackVoteCompleted || g_bBossPackVoteStarted) return Plugin_Stop;
	
	if (!IsVoteInProgress())
	{
		g_hBossPackVoteTimer = INVALID_HANDLE;
		InitiateBossPackVote();
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

bool:IsProfileValid(const String:sProfile[])
{
	return bool:(FindStringInArray(GetBossProfileList(), sProfile) != -1);
}

stock GetProfileNum(const String:sProfile[], const String:keyValue[], defaultValue=0)
{
	if (!IsProfileValid(sProfile)) return defaultValue;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	return KvGetNum(g_hConfig, keyValue, defaultValue);
}

stock Float:GetProfileFloat(const String:sProfile[], const String:keyValue[], Float:defaultValue=0.0)
{
	if (!IsProfileValid(sProfile)) return defaultValue;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	return KvGetFloat(g_hConfig, keyValue, defaultValue);
}

stock bool:GetProfileVector(const String:sProfile[], const String:keyValue[], Float:buffer[3], const Float:defaultValue[3]=NULL_VECTOR)
{
	for (new i = 0; i < 3; i++) buffer[i] = defaultValue[i];
	
	if (!IsProfileValid(sProfile)) return false;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	KvGetVector(g_hConfig, keyValue, buffer, defaultValue);
	return true;
}

stock bool:GetProfileColor(const String:sProfile[], 
	const String:keyValue[], 
	&r, 
	&g, 
	&b, 
	&a,
	dr=255,
	dg=255,
	db=255,
	da=255)
{
	r = dr;
	g = dg;
	b = db;
	a = da;
	
	if (!IsProfileValid(sProfile)) return false;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	decl String:sValue[64];
	KvGetString(g_hConfig, keyValue, sValue, sizeof(sValue));
	
	if (strlen(sValue) != 0)
	{
		KvGetColor(g_hConfig, keyValue, r, g, b, a);
	}
	
	return true;
}

stock bool:GetProfileString(const String:sProfile[], const String:keyValue[], String:buffer[], bufferlen, const String:defaultValue[]="")
{
	strcopy(buffer, bufferlen, defaultValue);
	
	if (!IsProfileValid(sProfile)) return false;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	KvGetString(g_hConfig, keyValue, buffer, bufferlen, defaultValue);
	return true;
}

GetBossProfileIndexFromName(const String:sProfile[])
{
	new iReturn = -1;
	GetTrieValue(g_hBossProfileNames, sProfile, iReturn);
	return iReturn;
}

GetBossProfileUniqueProfileIndex(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_UniqueProfileIndex);
}

GetBossProfileSkin(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_Skin);
}

GetBossProfileBodyGroups(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_Body);
}

Float:GetBossProfileModelScale(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_ModelScale);
}

GetBossProfileType(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_Type);
}

GetBossProfileFlags(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_Flags);
}

Float:GetBossProfileSpeed(iProfileIndex, iDifficulty)
{
	switch (iDifficulty)
	{
		case Difficulty_Easy: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_SpeedEasy);
		case Difficulty_Hard: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_SpeedHard);
		case Difficulty_Insane: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_SpeedInsane);
	}
	
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_SpeedNormal);
}

Float:GetBossProfileMaxSpeed(iProfileIndex, iDifficulty)
{
	switch (iDifficulty)
	{
		case Difficulty_Easy: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_MaxSpeedEasy);
		case Difficulty_Hard: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_MaxSpeedHard);
		case Difficulty_Insane: return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_MaxSpeedInsane);
	}
	
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_MaxSpeedNormal);
}

Float:GetBossProfileSearchRadius(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_SearchRange);
}

Float:GetBossProfileFOV(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_FieldOfView);
}

Float:GetBossProfileTurnRate(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_TurnRate);
}

GetBossProfileEyePositionOffset(iProfileIndex, Float:buffer[3])
{
	buffer[0] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyePosOffsetX);
	buffer[1] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyePosOffsetY);
	buffer[2] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyePosOffsetZ);
}

GetBossProfileEyeAngleOffset(iProfileIndex, Float:buffer[3])
{
	buffer[0] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyeAngOffsetX);
	buffer[1] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyeAngOffsetY);
	buffer[2] = Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_EyeAngOffsetZ);
}

Float:GetBossProfileAngerStart(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_AngerStart);
}

Float:GetBossProfileAngerAddOnPageGrab(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_AngerAddOnPageGrab);
}

Float:GetBossProfileAngerPageGrabTimeDiff(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_AngerPageGrabTimeDiffReq);
}

Float:GetBossProfileInstantKillRadius(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_InstantKillRadius);
}

Float:GetBossProfileScareRadius(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_ScareRadius);
}

Float:GetBossProfileScareCooldown(iProfileIndex)
{
	return Float:GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_ScareCooldown);
}

GetBossProfileTeleportType(iProfileIndex)
{
	return GetArrayCell(g_hBossProfileData, iProfileIndex, BossProfileData_TeleportType);
}

// Code originally from FF2. Credits to the original authors Rainbolt Dash and FlaminSarge.
stock bool:GetRandomStringFromProfile(const String:sProfile[], const String:strKeyValue[], String:buffer[], bufferlen, index=-1)
{
	strcopy(buffer, bufferlen, "");
	
	if (!IsProfileValid(sProfile)) return false;
	
	KvRewind(g_hConfig);
	KvJumpToKey(g_hConfig, sProfile);
	
	if (!KvJumpToKey(g_hConfig, strKeyValue)) return false;
	
	decl String:s[32], String:s2[PLATFORM_MAX_PATH];
	
	new i = 1;
	for (;;)
	{
		IntToString(i, s, sizeof(s));
		KvGetString(g_hConfig, s, s2, sizeof(s2));
		if (!s2[0]) break;
		
		i++;
	}
	
	if (i == 1) return false;
	
	IntToString(index < 0 ? GetRandomInt(1, i - 1) : index, s, sizeof(s));
	KvGetString(g_hConfig, s, buffer, bufferlen);
	return true;
}

/**
 *	Returns an array of strings of the profile names of every valid boss.
 */
Handle:GetBossProfileList()
{
	return g_hBossProfileList;
}

/**
 *	Returns an array of strings of the profile names of every valid boss that can be randomly selected.
 */
Handle:GetSelectableBossProfileList()
{
	return g_hSelectableBossProfileList;
}