/**
 * Danmaku Fortress - Default Abilities
 */

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0"

#include <df_subplugin>

new bool:PRINT_DEBUG_INFO = true;
new bool:PRINT_DEBUG_SPAM = true;

public Plugin:myinfo = {
	name = "DF Default Abilities",
	description = "Default abilities for Danmaku Fortress.",
	author = "sarysa",
	version = PLUGIN_VERSION,
}

/**
 * Hero Ability: Standard Shots
 */
#define SS_STRING "standard_shots"
new bool:SS_ActiveThisGame[DG_MAX_GAMES];
new SS_Owner[DG_MAX_GAMES]; // internal (common param)
//new SS_Victim[DG_MAX_GAMES]; // internal (common param)
new Float:SS_NextStandardVolleyAt[DG_MAX_GAMES]; // internal
new Float:SS_NextHomingVolleyAt[DG_MAX_GAMES]; // internal
new Float:SS_NextShotSoundAt[DG_MAX_GAMES]; // internal
new SS_StandardShotsPerVolley[DG_MAX_GAMES]; // arg1
new Float:SS_StandardRadius[DG_MAX_GAMES]; // arg2
new Float:SS_StandardDistance[DG_MAX_GAMES]; // arg3
new SS_StandardColor[DG_MAX_GAMES]; // arg4
new Float:SS_StandardSpeed[DG_MAX_GAMES]; // arg5
new Float:SS_StandardInterval[DG_MAX_GAMES]; // arg6
new SS_StandardDamage[DG_MAX_GAMES]; // arg7
new bool:SS_StandardIsWave[DG_MAX_GAMES]; // arg8
new Float:SS_StandardAnglePerSec[DG_MAX_GAMES]; // arg9
new Float:SS_FocusDistanceMult[DG_MAX_GAMES]; // arg10
new SS_HomingShotsPerVolley[DG_MAX_GAMES]; // arg11
new Float:SS_HomingRadius[DG_MAX_GAMES]; // arg12
new SS_HomingColor[DG_MAX_GAMES]; // arg13
new Float:SS_HomingSpeed[DG_MAX_GAMES]; // arg14
new Float:SS_HomingInterval[DG_MAX_GAMES]; // arg15
new SS_HomingDamage[DG_MAX_GAMES]; // arg16
new Float:SS_HomingAngleOffset[DG_MAX_GAMES]; // arg17
new Float:SS_HomingAnglePerSec[DG_MAX_GAMES]; // arg18
new Float:SS_FocusAngleMult[DG_MAX_GAMES]; // arg19
new String:SS_ShotSound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg20
new Float:SS_ShotSoundInterval[DG_MAX_GAMES]; // arg21

/**
 * Hero Ability: Basic Bomb
 */
#define BB_STRING "basic_bomb"
new bool:BB_ActiveThisGame[DG_MAX_GAMES];
new BB_Owner[DG_MAX_GAMES]; // internal (common param)
new BB_Victim[DG_MAX_GAMES]; // internal (common param)
new Float:BB_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:BB_Duration[DG_MAX_GAMES]; // arg1
new Float:BB_StartRadius[DG_MAX_GAMES]; // arg2
new Float:BB_EndRadius[DG_MAX_GAMES]; // arg3
new String:BB_Sound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg4
new BB_BossDamage[DG_MAX_GAMES]; // arg11

/**
 * Hero Ability: (Persistent) Beam Bomb
 */
#define PBB_STRING "persistent_beam_bomb"
new bool:PBB_ActiveThisGame[DG_MAX_GAMES];
new PBB_Owner[DG_MAX_GAMES]; // internal, common param
new PBB_Victim[DG_MAX_GAMES]; // internal, common param
new Float:PBB_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:PBB_NextBeamAt[DG_MAX_GAMES]; // internal
new PBB_NumHarmfulBeams[DG_MAX_GAMES]; // internal, used to determine when to make beams harmful
new Float:PBB_Duration[DG_MAX_GAMES]; // arg1
new Float:PBB_BombRadius[DG_MAX_GAMES]; // arg2
new Float:PBB_BeamRadius[DG_MAX_GAMES]; // arg3
new PBB_BeamColor[DG_MAX_GAMES]; // arg4
new Float:PBB_BeamRefreshInterval[DG_MAX_GAMES]; // arg5
new PBB_IndividualBeamDamage[DG_MAX_GAMES]; // arg6
new String:PBB_Sound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg7

/**
 * Boss Ability: Circumference Shot (was originally "surround shot" but that prefix was taken)
 */
#define CS_STRING "circumference_shot"
new bool:CS_ActiveThisGame[DG_MAX_GAMES];
new CS_Owner[DG_MAX_GAMES]; // internal (common param)
new CS_Victim[DG_MAX_GAMES]; // internal (common param)
new Float:CS_AbilityStartedAt[DG_MAX_GAMES]; // internal
new Float:CS_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:CS_NextVolleyAt[DG_MAX_GAMES]; // internal
new Float:CS_Duration[DG_MAX_GAMES]; // arg1
new CS_NumShotsXY[DG_MAX_GAMES]; // arg2
new CS_NumShotsZ[DG_MAX_GAMES]; // arg3
new Float:CS_Interval[DG_MAX_GAMES]; // arg4
new Float:CS_MoveSpeed[DG_MAX_GAMES]; // arg5
new Float:CS_RotationPerSecond[DG_MAX_GAMES]; // arg6
new CS_ShotType[DG_MAX_GAMES]; // arg7
new Float:CS_ShotParam1[DG_MAX_GAMES]; // arg8
new Float:CS_ShotParam2[DG_MAX_GAMES]; // arg9
new Float:CS_ShotRadius[DG_MAX_GAMES]; // arg10
new Float:CS_ShotZOffset[DG_MAX_GAMES]; // arg11
new CS_ShotColor[DG_MAX_GAMES]; // arg12
new Float:CS_ShotSpeed[DG_MAX_GAMES]; // arg13

/**
 * Boss Ability: Random Wall Attack
 */
#define RWA_STRING "random_wall_attack"
new bool:RWA_ActiveThisGame[DG_MAX_GAMES];
// victim and owner are unnecessary since their positions do not factor
new Float:RWA_AbilityStartedAt[DG_MAX_GAMES]; // internal
new Float:RWA_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:RWA_ReportEndAt[DG_MAX_GAMES]; // internal, allows other attacks to occur simultaneously with this one
new RWA_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new RWA_ActiveWallType[DG_MAX_GAMES]; // internal, used during the rage (combines arg1 and arg2 temporarily)
new Float:RWA_WallRect[DG_MAX_GAMES][2][3]; // internal
new Float:RWA_FiringAngle[DG_MAX_GAMES][3]; // internal
new bool:RWA_FixedMoveSpeed[DG_MAX_GAMES]; // internal
new RWA_WallType[DG_MAX_GAMES]; // arg1, not used if -1
new RWA_SpawnAxis[DG_MAX_GAMES]; // arg2, not used if -1 or if arg1 isn't -1
new RWA_ProjectilesPerSecond[DG_MAX_GAMES]; // arg3
new Float:RWA_Duration[DG_MAX_GAMES]; // arg4
new Float:RWA_AngleDeviation[DG_MAX_GAMES]; // arg5
new Float:RWA_FakeDuration[DG_MAX_GAMES]; // arg6, reported to the main plugin
new Float:RWA_Radius[DG_MAX_GAMES]; // arg7
new Float:RWA_Speed[DG_MAX_GAMES]; // arg8
new RWA_Color[DG_MAX_GAMES]; // arg9
new String:RWA_WarningText[DG_MAX_GAMES][MAX_CENTER_TEXT_LENGTH]; // arg11
new Float:RWA_StartDelay[DG_MAX_GAMES]; // arg12
new String:RWA_WarningSound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg13
new Float:RWA_MoveSpeed[DG_MAX_GAMES]; // arg21
new RWA_MoveSpeedType[DG_MAX_GAMES]; // arg22, 0 = until start delay is over, 1 = until mod told ability is over

/**
 * Boss Ability: Patterned Wall Attack
 */
#define PWA_STRING "patterned_wall_attack"
#define PWA_TYPE_ALL_AT_ONCE 0
#define PWA_TYPE_ROWS 1
#define PWA_TYPE_COLUMNS 2
#define PWA_TYPE_RECTANGLE_INWARD 3
#define PWA_TYPE_RECTANGLE_OUTWARD 4
new bool:PWA_ActiveThisGame[DG_MAX_GAMES];
// victim and owner are unnecessary since their positions do not factor
new Float:PWA_AbilityStartedAt[DG_MAX_GAMES]; // internal
new Float:PWA_NextWaveAt[DG_MAX_GAMES]; // internal
new PWA_WavesExpected[DG_MAX_GAMES]; // internal
new PWA_WavesSpawned[DG_MAX_GAMES]; // internal, used for rows, columns, and rectangle layers
new PWA_ActiveWallType[DG_MAX_GAMES]; // internal, used during the ability (combines arg1 and arg2 temporarily)
new Float:PWA_WallRect[DG_MAX_GAMES][2][3]; // internal
new Float:PWA_FiringAngle[DG_MAX_GAMES][3]; // internal
new Float:PWA_ActiveRadius[DG_MAX_GAMES]; // internal, used during the ability (combines arg7 and arg8 temporarily)
new PWA_WallType[DG_MAX_GAMES]; // arg1, not used if -1
new PWA_SpawnAxis[DG_MAX_GAMES]; // arg2, not used if -1 or if arg1 isn't -1
new PWA_NumPerRow[DG_MAX_GAMES]; // first half of arg3
new PWA_NumPerColumn[DG_MAX_GAMES]; // second half of arg3
new PWA_SpawnType[DG_MAX_GAMES]; // arg4, see PWA_TYPE_xxx
new Float:PWA_BossMoveSpeed[DG_MAX_GAMES]; // arg5, not used if spawn type is all at once
new Float:PWA_WaveDelay[DG_MAX_GAMES]; // arg6
new Float:PWA_StaticRadius[DG_MAX_GAMES]; // arg7
new Float:PWA_RelativeRadius[DG_MAX_GAMES]; // arg8
new Float:PWA_Speed[DG_MAX_GAMES]; // arg9
new PWA_Color[DG_MAX_GAMES]; // arg10
new String:PWA_WarningText[DG_MAX_GAMES][MAX_CENTER_TEXT_LENGTH]; // arg11
new Float:PWA_StartDelay[DG_MAX_GAMES]; // arg12
new String:PWA_WarningSound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg13
new PWA_ShotType[DG_MAX_GAMES]; // arg21
new Float:PWA_ShotParam1[DG_MAX_GAMES]; // arg22
new Float:PWA_ShotParam2[DG_MAX_GAMES]; // arg23

/**
 * Boss Ability: RNG Shot
 */
#define RNGS_STRING "rng_shot"
new bool:RNGS_ActiveThisGame[DG_MAX_GAMES];
new RNGS_Owner[DG_MAX_GAMES]; // internal (common param)
new Float:RNGS_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:RNGS_FakeAbilityEndsAt[DG_MAX_GAMES]; // internal, reported to the game
new RNGS_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new Float:RNGS_Duration[DG_MAX_GAMES]; // arg1
new Float:RNGS_ShotsPerSecond[DG_MAX_GAMES]; // arg2
new RNGS_ShotType[DG_MAX_GAMES]; // arg3
new Float:RNGS_MinParam1[DG_MAX_GAMES]; // arg4
new Float:RNGS_MaxParam1[DG_MAX_GAMES]; // arg5
new Float:RNGS_MinParam2[DG_MAX_GAMES]; // arg6
new Float:RNGS_MaxParam2[DG_MAX_GAMES]; // arg7
new Float:RNGS_MinRadius[DG_MAX_GAMES]; // arg8
new Float:RNGS_MaxRadius[DG_MAX_GAMES]; // arg9
new Float:RNGS_MinSpeed[DG_MAX_GAMES]; // arg10
new Float:RNGS_MaxSpeed[DG_MAX_GAMES]; // arg11
new RNGS_MinColors[DG_MAX_GAMES]; // arg12
new RNGS_MaxColors[DG_MAX_GAMES]; // arg13
new Float:RNGS_BossMoveSpeed[DG_MAX_GAMES]; // arg14
new Float:RNGS_FakeDuration[DG_MAX_GAMES]; // arg15

/**
 * Boss Ability: Projectile Freeze
 */
#define PF_STRING "projectile_freeze"
#define PF_TYPE_ALL 0
#define PF_TYPE_RADIUS 1
#define PF_TYPE_RECT 2
new bool:PF_ActiveThisGame[DG_MAX_GAMES];
new PF_Owner[DG_MAX_GAMES]; // internal (common param)
new PF_Victim[DG_MAX_GAMES]; // internal (common param)
new Float:PF_Duration[DG_MAX_GAMES]; // arg1
new String:PF_Sound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg2
new PF_Type[DG_MAX_GAMES]; // arg3
new Float:PF_Radius[DG_MAX_GAMES]; // arg4
new Float:PF_Rect[DG_MAX_GAMES][2][3]; // arg5

/**
 * Boss Ability: Projectile Freeze Delayed
 *
 * aka probably the only time I'm ever going to copy/paste this much code.
 */
#define PFD_STRING "projectile_freeze_delayed"
new bool:PFD_ActiveThisGame[DG_MAX_GAMES];
new PFD_Owner[DG_MAX_GAMES]; // internal (common param)
new PFD_Victim[DG_MAX_GAMES]; // internal (common param)
new Float:PFD_UseAbilityAt[DG_MAX_GAMES]; // internal
new Float:PFD_Duration[DG_MAX_GAMES]; // arg1
new String:PFD_Sound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg2
new PFD_Type[DG_MAX_GAMES]; // arg3
new Float:PFD_Radius[DG_MAX_GAMES]; // arg4
new Float:PFD_Rect[DG_MAX_GAMES][2][3]; // arg5
new Float:PFD_Delay[DG_MAX_GAMES]; // arg6

/**
 * Boss Ability: Rapid Randomized Bundle (spawns randomly near the boss, in a rapidly spawning bundle, then is sent at the player)
 */
#define RRB_STRING "rapid_randomized_bundle"
new RRB_ActiveThisGame[DG_MAX_GAMES];
new RRB_Owner[DG_MAX_GAMES]; // internal (common param)
new Float:RRB_AbilityEndsAt[DG_MAX_GAMES]; // internal
new RRB_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new Float:RRB_Duration[DG_MAX_GAMES]; // arg1
new Float:RRB_ShotsPerSecond[DG_MAX_GAMES]; // arg2
new Float:RRB_MaxDistanceFromBoss[DG_MAX_GAMES]; // arg3
new RRB_ShotType[DG_MAX_GAMES]; // arg4
new Float:RRB_ShotParam1[DG_MAX_GAMES]; // arg5
new Float:RRB_ShotParam2[DG_MAX_GAMES]; // arg6
new Float:RRB_MinRadius[DG_MAX_GAMES]; // arg7
new Float:RRB_MaxRadius[DG_MAX_GAMES]; // arg8
new RRB_MinColor[DG_MAX_GAMES]; // arg9
new RRB_MaxColor[DG_MAX_GAMES]; // arg10
new Float:RRB_ShotSpeed[DG_MAX_GAMES]; // arg11
new Float:RRB_BossMoveSpeed[DG_MAX_GAMES]; // arg12
new Float:RRB_ShotLifetime[DG_MAX_GAMES]; // arg13

/**
 * Boss Ability: Persistent Patterned Shot
 */
#define PPS_STRING "persistent_patterned_shot"
new PPS_ActiveThisGame[DG_MAX_GAMES];
// owner and victim completely unnecessary
new PPS_ColumnsSpawned[DG_MAX_GAMES];
new Float:PPS_NextColumnAt[DG_MAX_GAMES];
new PPS_NumSections[DG_MAX_GAMES]; // arg1
new PPS_NumColumns[DG_MAX_GAMES]; // arg2
new PPS_RocketsPerColumn[DG_MAX_GAMES]; // arg3
new Float:PPS_ColumnDelay[DG_MAX_GAMES]; // arg4
new Float:PPS_FBOffset[DG_MAX_GAMES]; // arg5
new Float:PPS_FBYawOffset[DG_MAX_GAMES]; // arg6
new Float:PPS_Radius[DG_MAX_GAMES]; // arg7
new Float:PPS_ShotSpeed[DG_MAX_GAMES]; // arg8
new PPS_ShotType[DG_MAX_GAMES]; // arg9
new Float:PPS_ShotParam1[DG_MAX_GAMES]; // arg10
new Float:PPS_ShotParam2[DG_MAX_GAMES]; // arg11
new Float:PPS_ShotLifetime[DG_MAX_GAMES]; // arg12
new PPS_ShotColor[DG_MAX_GAMES]; // arg13
new String:PPS_WarningText[DG_MAX_GAMES][MAX_CENTER_TEXT_LENGTH]; // arg21
new Float:PPS_StartDelay[DG_MAX_GAMES]; // arg22
new String:PPS_WarningSound[DG_MAX_GAMES][MAX_SOUND_FILE_LENGTH]; // arg23
new Float:PPS_BossMoveSpeed[DG_MAX_GAMES]; // arg31
new bool:PPS_MoveSpeedEndsWithAbility[DG_MAX_GAMES]; // arg32

/**
 * Boss Ability: Clone Radial Shots
 */
#define CRS_STRING "clone_radial_shots"
new bool:CRS_ActiveThisGame[DG_MAX_GAMES];
new CRS_Owner[DG_MAX_GAMES]; // internal, common param
new Float:CRS_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:CRS_NextVolleyAt[DG_MAX_GAMES]; // internal
new Float:CRS_Duration[DG_MAX_GAMES]; // arg1
new CRS_NumClones[DG_MAX_GAMES]; // arg2
new CRS_ModelIdx[DG_MAX_GAMES]; // arg3, model for clones
new Float:CRS_CloneMoveSpeed[DG_MAX_GAMES]; // arg4
new Float:CRS_CloneTurnSpeed[DG_MAX_GAMES]; // arg5
new CRS_ShotsPerVolley[DG_MAX_GAMES]; // arg6
new Float:CRS_VolleyInterval[DG_MAX_GAMES]; // arg7
new Float:CRS_ShotRadius[DG_MAX_GAMES]; // arg8
new Float:CRS_ShotSpeed[DG_MAX_GAMES]; // arg9
new CRS_ShotColor[DG_MAX_GAMES]; // arg10
new CRS_ShotType[DG_MAX_GAMES]; // arg11
new Float:CRS_Param1[DG_MAX_GAMES]; // arg12
new Float:CRS_Param2[DG_MAX_GAMES]; // arg13
new Float:CRS_BossMoveSpeed[DG_MAX_GAMES]; // arg14

/**
 * Boss Ability: Beam Grid
 */
#define BG_STRING "beam_grid"
new bool:BG_ActiveThisGame[DG_MAX_GAMES];
new Float:BG_AbilityStartedAt[DG_MAX_GAMES]; // internal
new Float:BG_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:BG_NextBeamsAt[DG_MAX_GAMES]; // internal
new BG_NumBeams[DG_MAX_GAMES]; // internal
new BG_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new Float:BG_Duration[DG_MAX_GAMES]; // arg1
new BG_FBBeamsOnZ[DG_MAX_GAMES]; // arg2
new BG_FBBeamsOnLR[DG_MAX_GAMES]; // arg3
new BG_LRBeamsOnZ[DG_MAX_GAMES]; // arg4
new BG_LRBeamsOnFB[DG_MAX_GAMES]; // arg5
new BG_ZBeamsOnFB[DG_MAX_GAMES]; // arg6
new BG_ZBeamsOnLR[DG_MAX_GAMES]; // arg7
new Float:BG_BeamRadius[DG_MAX_GAMES]; // arg8
new BG_BeamColor[DG_MAX_GAMES]; // arg9
new Float:BG_ImmunityDuration[DG_MAX_GAMES]; // arg10
new Float:BG_ShotsPerSecond[DG_MAX_GAMES]; // arg21
new Float:BG_ShotRadius[DG_MAX_GAMES]; // arg22
new Float:BG_ShotSpeed[DG_MAX_GAMES]; // arg23
new BG_ShotType[DG_MAX_GAMES]; // arg24
new Float:BG_ShotParam1[DG_MAX_GAMES]; // arg25
new Float:BG_ShotParam2[DG_MAX_GAMES]; // arg26
new BG_ShotColor[DG_MAX_GAMES]; // arg27
new Float:BG_BossMoveSpeed[DG_MAX_GAMES]; // arg28
new bool:BG_AllowConcurrentAbilities[DG_MAX_GAMES]; // arg29

/**
 * Boss Ability: Follow Spawn Shot
 */
#define FSS_STRING "follow_spawn_shot"
new bool:FSS_ActiveThisGame[DG_MAX_GAMES];
new FSS_Owner[DG_MAX_GAMES]; // internal, common param
new Float:FSS_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:FSS_LastPosition[DG_MAX_GAMES][3]; // internal
new Float:FSS_LastTime[DG_MAX_GAMES]; // internal
new FSS_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new Float:FSS_Duration[DG_MAX_GAMES]; // arg1
new Float:FSS_ShotsPerSecond[DG_MAX_GAMES]; // arg2
new Float:FSS_StalkingSpeed[DG_MAX_GAMES]; // arg3
new Float:FSS_ShotRadius[DG_MAX_GAMES]; // arg4
new FSS_ShotColor[DG_MAX_GAMES]; // arg5
new FSS_ShotType[DG_MAX_GAMES]; // arg6
new Float:FSS_ShotParam1[DG_MAX_GAMES]; // arg7
new Float:FSS_ShotParam2[DG_MAX_GAMES]; // arg8
new Float:FSS_ShotSpeed[DG_MAX_GAMES]; // arg9
new Float:FSS_BossMoveSpeed[DG_MAX_GAMES]; // arg10
new bool:FSS_AllowConcurrentAbilities[DG_MAX_GAMES]; // arg11
new Float:FSS_StartDelay[DG_MAX_GAMES]; // arg12
new bool:FSS_IsSilent[DG_MAX_GAMES]; // arg13

/**
 * Boss Ability: Mapwide Ripple Shots
 */
#define MRS_STRING "mapwide_ripple_shots"
new bool:MRS_ActiveThisGame[DG_MAX_GAMES];
new MRS_Owner[DG_MAX_GAMES]; // internal, common param
new Float:MRS_AbilityEndsAt[DG_MAX_GAMES]; // internal
new Float:MRS_NextBossRippleAt[DG_MAX_GAMES]; // internal
new Float:MRS_NextRandomRippleAt[DG_MAX_GAMES]; // internal
new Float:MRS_Duration[DG_MAX_GAMES]; // arg1
new Float:MRS_RandomMinDistance[DG_MAX_GAMES]; // arg2
new MRS_ShotsPerRipple[DG_MAX_GAMES]; // arg3
new Float:MRS_RandomRippleInterval[DG_MAX_GAMES]; // arg4, if 0.0 never spawn
new Float:MRS_BossRippleInterval[DG_MAX_GAMES]; // arg5, if 0.0 never spawn
new Float:MRS_ShotRadius[DG_MAX_GAMES]; // arg6
new Float:MRS_ShotSpeed[DG_MAX_GAMES]; // arg7
new MRS_ShotColor[DG_MAX_GAMES]; // arg8
new MRS_ShotType[DG_MAX_GAMES]; // arg9
new Float:MRS_ShotParam1[DG_MAX_GAMES]; // arg10
new Float:MRS_ShotParam2[DG_MAX_GAMES]; // arg11
new Float:MRS_BossMoveSpeed[DG_MAX_GAMES]; // arg12

/**
 * Boss Ability: Rotating Beam Wall
 */
#define RBW_STRING "rotating_beam_wall"
#define RBW_DIR_CCW 0
#define RBW_DIR_CW 1
#define RBW_DIR_ALTERNATING 2
#define RBW_BOSS_MOVE_SPEED 0.0 // forced, due to it #1 being unfair to the hero, #2 looks awful with the beams
#define RBW_REDRAW_INTERVAL 0.025
new bool:RBW_ActiveThisGame[DG_MAX_GAMES];
new RBW_Owner[DG_MAX_GAMES]; // internal (common param)
new Float:RBW_StartingYaw[DG_MAX_GAMES]; // internal
new Float:RBW_RotationStartsAt[DG_MAX_GAMES]; // internal
new Float:RBW_RampUpRedrawAt[DG_MAX_GAMES]; // internal
new Float:RBW_RotationEndsAt[DG_MAX_GAMES]; // internal
new Float:RBW_NextRedrawAt[DG_MAX_GAMES]; // internal, only happens while rotating
new bool:RBW_LastWasCCW[DG_MAX_GAMES]; // internal, used by arg6=2
new Float:RBW_BeamRadius[DG_MAX_GAMES]; // internal, determined very early
new RBW_ProjectilesSpawned[DG_MAX_GAMES]; // internal
new Float:RBW_SetupDuration[DG_MAX_GAMES]; // arg1
new Float:RBW_RotateDuration[DG_MAX_GAMES]; // arg2
new RBW_BeamsToSpawn[DG_MAX_GAMES]; // arg3
new Float:RBW_ProjectilesPerSecond[DG_MAX_GAMES]; // arg4
new Float:RBW_AngleVariance[DG_MAX_GAMES]; // arg5
new RBW_RotationDirection[DG_MAX_GAMES]; // arg6
new RBW_BeamColor[DG_MAX_GAMES]; // arg7
new Float:RBW_BeamDistance[DG_MAX_GAMES]; // arg8
new Float:RBW_ShotRadiusStatic[DG_MAX_GAMES]; // arg9, can be corrupted by the below if this is 0.0
new Float:RBW_ShotRadiusRelative[DG_MAX_GAMES]; // arg10, relative to beam
new Float:RBW_ShotSpeed[DG_MAX_GAMES]; // arg11
new RBW_ShotColor[DG_MAX_GAMES]; // arg12
new RBW_ShotType[DG_MAX_GAMES]; // arg13
new Float:RBW_ShotParam1[DG_MAX_GAMES]; // arg14
new Float:RBW_ShotParam2[DG_MAX_GAMES]; // arg15

/**
 * Boss Ability: Expanding Rotating Radial
 *
 * Based heavily on Circumference Shot, but built solely for DR_PATTERN_ANGLE
 */
#define ERR_STRING "expanding_rotating_radial"
new bool:ERR_ActiveThisGame[DG_MAX_GAMES];
new ERR_Owner[DG_MAX_GAMES]; // internal (common param)
new ERR_ShotsXY[DG_MAX_GAMES]; // arg1
new ERR_ShotsZ[DG_MAX_GAMES]; // arg2
new Float:ERR_ApexYawVariance[DG_MAX_GAMES]; // arg3
new bool:ERR_IgnorePitch[DG_MAX_GAMES]; // arg4
new ERR_ShotType[DG_MAX_GAMES]; // arg5
new Float:ERR_ShotParam1[DG_MAX_GAMES]; // arg6
new Float:ERR_ShotParam2[DG_MAX_GAMES]; // arg7
new Float:ERR_ShotRadius[DG_MAX_GAMES]; // arg8
new Float:ERR_RowZOffset[DG_MAX_GAMES]; // arg9
new ERR_ShotColor[DG_MAX_GAMES]; // arg10
new Float:ERR_ShotSpeed[DG_MAX_GAMES]; // arg11
new bool:ERR_RotateCCW[DG_MAX_GAMES]; // arg12

/**
 * Boss Ability: Drop One Spawner
 */
#define DOS_STRING "drop_one_spawner"
new bool:DOS_ActiveThisGame[DG_MAX_GAMES];
new DOS_Owner[DG_MAX_GAMES]; // internal, common param
new Float:DOS_SpawnerLifetime[DG_MAX_GAMES]; // arg1
new Float:DOS_SpawnerSpeed[DG_MAX_GAMES]; // arg2
new DOS_SpawnerModelIdx[DG_MAX_GAMES]; // arg3
new DOS_SpawnerMovePattern[DG_MAX_GAMES]; // arg4
new Float:DOS_SpawnerMoveParam1[DG_MAX_GAMES]; // arg5
new Float:DOS_SpawnerMoveParam2[DG_MAX_GAMES]; // arg6
new DOS_SpawnerSpawnPattern[DG_MAX_GAMES]; // arg7
new Float:DOS_SpawnerSpawnInterval[DG_MAX_GAMES]; // arg8
new Float:DOS_SpawnerSpawnParam1[DG_MAX_GAMES]; // arg9
new bool:DOS_IsBombProof[DG_MAX_GAMES]; // arg10
new Float:DOS_ShotRadius[DG_MAX_GAMES]; // arg11
new DOS_ShotColor[DG_MAX_GAMES]; // arg12
new Float:DOS_ShotSpeed[DG_MAX_GAMES]; // arg13

public OnPluginStart()
{
	DF_GameCleanup(-1); // will clean up (initialize) all games
}

public OnMapStart()
{
	DF_GameCleanup(-1); // will clean up (initialize) all games
}

/**
 * REQUIRED METHODS (which are all lifecycle methods provided to us by the core. you likely won't need your own, except OnPluginStart() or OnMapStart() for reinitialization)
 * 
 * These are invoked with reflection. Same goes for method calls this subplugin makes to danmaku_fortress.sp
 */
public DF_InitAbility(gameIdx, owner, victim, String:abilityName[MAX_ABILITY_NAME_LENGTH], String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx)
{
	if (strcmp(abilityName, SS_STRING) == 0)
	{
		SS_ActiveThisGame[gameIdx] = true;
		SS_Owner[gameIdx] = owner;
		//SS_Victim[gameIdx] = victim;
		SS_NextStandardVolleyAt[gameIdx] = 0.0;
		SS_NextHomingVolleyAt[gameIdx] = 0.0;
		
		// arguments
		SS_StandardShotsPerVolley[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 1);
		SS_StandardRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		SS_StandardDistance[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		SS_StandardColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		SS_StandardSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		SS_StandardInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		SS_StandardDamage[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 7);
		SS_StandardIsWave[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 8) == 1;
		SS_StandardAnglePerSec[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		SS_FocusDistanceMult[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		SS_HomingShotsPerVolley[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 11);
		SS_HomingRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		SS_HomingColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 13);
		SS_HomingSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 14);
		SS_HomingInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 15);
		SS_HomingDamage[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 16);
		SS_HomingAngleOffset[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 17);
		SS_HomingAnglePerSec[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 18);
		SS_FocusAngleMult[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 19);
		DF_ReadSound(characterName, abilityIdx, 20, SS_ShotSound[gameIdx]);
		SS_ShotSoundInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 21);
		
		SS_NextShotSoundAt[gameIdx] = (strlen(SS_ShotSound[gameIdx]) > 3) ? 0.0 : FAR_FUTURE;
		if (SS_FocusDistanceMult[gameIdx] <= 0.0)
			SS_FocusDistanceMult[gameIdx] = 1.0;
		if (SS_FocusAngleMult[gameIdx] <= 0.0)
			SS_FocusAngleMult[gameIdx] = 1.0;
	}
	else if (strcmp(abilityName, BB_STRING) == 0)
	{
		BB_ActiveThisGame[gameIdx] = true;
		BB_AbilityEndsAt[gameIdx] = 0.0;
		BB_Owner[gameIdx] = owner;
		BB_Victim[gameIdx] = victim;
		
		// arguments
		BB_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		BB_StartRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		BB_EndRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		DF_ReadSound(characterName, abilityIdx, 4, BB_Sound[gameIdx]);
		BB_BossDamage[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 11);
	}
	else if (strcmp(abilityName, PBB_STRING) == 0)
	{
		PBB_ActiveThisGame[gameIdx] = true;
		PBB_AbilityEndsAt[gameIdx] = 0.0;
		PBB_Owner[gameIdx] = owner;
		PBB_Victim[gameIdx] = victim;
		
		// arguments
		PBB_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		PBB_BombRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		PBB_BeamRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		PBB_BeamColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		PBB_BeamRefreshInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		PBB_IndividualBeamDamage[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 6);
		DF_ReadSound(characterName, abilityIdx, 7, PBB_Sound[gameIdx]);
		
		fclamp(PBB_BeamRefreshInterval[gameIdx], 0.0125, 1.0);
		PBB_BeamRadius[gameIdx] *= 0.5; // the reason for this is the radius as stated in the config file is the "overall radius" for the rendered beams
	}
	else if (strcmp(abilityName, CS_STRING) == 0)
	{
		CS_ActiveThisGame[gameIdx] = true;
		CS_Owner[gameIdx] = owner;
		CS_Victim[gameIdx] = victim;
		CS_AbilityStartedAt[gameIdx] = FAR_FUTURE;
		
		CS_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		CS_NumShotsXY[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		CS_NumShotsZ[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		CS_Interval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		CS_MoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		CS_RotationPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		CS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 7);
		CS_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		CS_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		CS_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		CS_ShotZOffset[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		CS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 12);
		CS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 13);
	}
	else if (strcmp(abilityName, RWA_STRING) == 0)
	{
		RWA_ActiveThisGame[gameIdx] = true;
		RWA_AbilityStartedAt[gameIdx] = FAR_FUTURE;
		RWA_ReportEndAt[gameIdx] = FAR_FUTURE;
		
		RWA_WallType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 1);
		RWA_SpawnAxis[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		RWA_ProjectilesPerSecond[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		RWA_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		RWA_AngleDeviation[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		RWA_FakeDuration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		RWA_Radius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		RWA_Speed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		RWA_Color[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 9);
		DF_GetArgString(characterName, abilityIdx, 11, RWA_WarningText[gameIdx], MAX_CENTER_TEXT_LENGTH);
		RWA_StartDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		DF_ReadSound(characterName, abilityIdx, 13, RWA_WarningSound[gameIdx]);
		RWA_MoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 21);
		RWA_MoveSpeedType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 22);
		
		// ensure validity
		if (RWA_FakeDuration[gameIdx] > RWA_Duration[gameIdx])
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[df_default_abilities] WARNING: Fake ability duration is longer than actual duration. Clamping. (ability: %s)", RWA_STRING);
			RWA_FakeDuration[gameIdx] = RWA_Duration[gameIdx];
		}
		
		if (RWA_WallType[gameIdx] == -1 && RWA_SpawnAxis[gameIdx] == -1)
		{
			PrintToServer("[df_default_abilities] WARNING: arg1 and arg2 are -1. Defaulting to forward/back axis. (ability: %s)", RWA_STRING);
			RWA_SpawnAxis[gameIdx] = DG_AXIS_FORWARD_BACK;
		}
	}
	else if (strcmp(abilityName, PWA_STRING) == 0)
	{
		PWA_ActiveThisGame[gameIdx] = true;
		PWA_AbilityStartedAt[gameIdx] = FAR_FUTURE;

		PWA_WallType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 1);
		PWA_SpawnAxis[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		
		// oh god, so much confusion with rows and columns
		// to make code as reasable as possible, it's going to be (arg description = what's in code)
		// number of rows = number per column
		// number of columns = number per row
		static String:rowColumn[10];
		static String:rowColumnSplit[2][5];
		DF_GetArgString(characterName, abilityIdx, 3, rowColumn, sizeof(rowColumn));
		ExplodeString(rowColumn, ";", rowColumnSplit, 2, 5);
		PWA_NumPerColumn[gameIdx] = StringToInt(rowColumnSplit[0]);
		PWA_NumPerRow[gameIdx] = StringToInt(rowColumnSplit[1]);
		
		PWA_SpawnType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		PWA_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		PWA_WaveDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		PWA_StaticRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		PWA_RelativeRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		PWA_Speed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		PWA_Color[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 10);
		DF_GetArgString(characterName, abilityIdx, 11, PWA_WarningText[gameIdx], MAX_CENTER_TEXT_LENGTH);
		PWA_StartDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		DF_ReadSound(characterName, abilityIdx, 13, PWA_WarningSound[gameIdx]);
		PWA_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 21);
		PWA_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 22);
		PWA_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 23);
		
		// ensure validity
		if (PWA_WallType[gameIdx] == -1 && PWA_SpawnAxis[gameIdx] == -1)
		{
			PrintToServer("[df_default_abilities] WARNING: arg1 and arg2 are -1. Defaulting to forward/back axis. (ability: %s)", PWA_STRING);
			PWA_SpawnAxis[gameIdx] = DG_AXIS_FORWARD_BACK;
		}
		
		if (PWA_StaticRadius[gameIdx] <= 0.0 && PWA_RelativeRadius[gameIdx] <= 0.0)
		{
			PWA_StaticRadius[gameIdx] = 25.0;
			PrintToServer("[df_default_abilities] WARNING: arg7 and arg8 are 0.0. Arbitrarily setting radius to %.0f. (ability: %s)", PWA_StaticRadius[gameIdx], PWA_STRING);
		}
		
		// lots of possible points of failure here, going to print the most likely
		if (PRINT_DEBUG_INFO)
			PrintToServer("[df_default_abilities] %s initializing. If not working properly, verify these points of failure: rows=%d columns=%d", PWA_STRING, PWA_NumPerRow[gameIdx], PWA_NumPerColumn[gameIdx]);
	}
	else if (strcmp(abilityName, RNGS_STRING) == 0)
	{
		RNGS_ActiveThisGame[gameIdx] = true;
		RNGS_Owner[gameIdx] = owner;
		RNGS_AbilityEndsAt[gameIdx] = 0.0;
		RNGS_FakeAbilityEndsAt[gameIdx] = FAR_FUTURE;
		
		RNGS_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		RNGS_ShotsPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		RNGS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		RNGS_MinParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		RNGS_MaxParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		RNGS_MinParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		RNGS_MaxParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		RNGS_MinRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		RNGS_MaxRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		RNGS_MinSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		RNGS_MaxSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		RNGS_MinColors[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 12);
		RNGS_MaxColors[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 13);
		RNGS_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 14);
		RNGS_FakeDuration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 15);
		
		// verification
		if (RNGS_FakeDuration[gameIdx] > RNGS_Duration[gameIdx])
		{
			PrintToServer("[df_default_abilities] WARNING: %s has fake duration set longer than actual duration. (%f > %f) Clamping.", RNGS_STRING, RNGS_FakeDuration[gameIdx], RNGS_Duration[gameIdx]);
			RNGS_FakeDuration[gameIdx] = RNGS_Duration[gameIdx];
		}
	}
	else if (strcmp(abilityName, PF_STRING) == 0)
	{
		PF_ActiveThisGame[gameIdx] = true;
		PF_Owner[gameIdx] = owner;
		PF_Victim[gameIdx] = victim;
		
		PF_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		DF_ReadSound(characterName, abilityIdx, 2, PF_Sound[gameIdx]);
		PF_Type[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		PF_Radius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		DF_GetArgRectangle(characterName, abilityIdx, 5, PF_Rect[gameIdx]);
	}
	else if (strcmp(abilityName, PFD_STRING) == 0)
	{
		PFD_ActiveThisGame[gameIdx] = true;
		PFD_Owner[gameIdx] = owner;
		PFD_Victim[gameIdx] = victim;
		PFD_UseAbilityAt[gameIdx] = FAR_FUTURE;
		
		PFD_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		DF_ReadSound(characterName, abilityIdx, 2, PFD_Sound[gameIdx]);
		PFD_Type[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		PFD_Radius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		DF_GetArgRectangle(characterName, abilityIdx, 5, PFD_Rect[gameIdx]);
		PFD_Delay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
	}
	else if (strcmp(abilityName, RRB_STRING) == 0)
	{
		RRB_ActiveThisGame[gameIdx] = true;
		RRB_Owner[gameIdx] = owner;
		RRB_AbilityEndsAt[gameIdx] = 0.0;

		RRB_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		RRB_ShotsPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		RRB_MaxDistanceFromBoss[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		RRB_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		RRB_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		RRB_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		RRB_MinRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		RRB_MaxRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		RRB_MinColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 9);
		RRB_MaxColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 10);
		RRB_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		RRB_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		RRB_ShotLifetime[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 13);
	}
	else if (strcmp(abilityName, PPS_STRING) == 0)
	{
		PPS_ActiveThisGame[gameIdx] = true;
		PPS_NextColumnAt[gameIdx] = FAR_FUTURE;

		PPS_NumSections[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 1);
		PPS_NumColumns[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		PPS_RocketsPerColumn[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		PPS_ColumnDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		PPS_FBOffset[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		PPS_FBYawOffset[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		PPS_Radius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		PPS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		PPS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 9);
		PPS_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		PPS_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		PPS_ShotLifetime[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		PPS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 13);
		DF_GetArgString(characterName, abilityIdx, 21, PPS_WarningText[gameIdx], MAX_CENTER_TEXT_LENGTH);
		PPS_StartDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 22);
		DF_ReadSound(characterName, abilityIdx, 23, PPS_WarningSound[gameIdx]);
		PPS_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 31);
		PPS_MoveSpeedEndsWithAbility[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 32) == 1;
		
		// set the radius now if it's 0, and calculate some internals now, save the trouble later
		if (PPS_Radius[gameIdx] <= 0.0)
			PPS_Radius[gameIdx] = (DG_EXPECTED_ARENA_HEIGHT / float(PPS_RocketsPerColumn[gameIdx])) * 0.5;
	}
	else if (strcmp(abilityName, CRS_STRING) == 0)
	{
		CRS_ActiveThisGame[gameIdx] = true;
		CRS_AbilityEndsAt[gameIdx] = 0.0;
		CRS_Owner[gameIdx] = owner;
		
		CRS_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		CRS_NumClones[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		CRS_ModelIdx[gameIdx] = DF_ReadModelToInt(characterName, abilityIdx, 3);
		CRS_CloneMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		CRS_CloneTurnSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		CRS_ShotsPerVolley[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 6);
		CRS_VolleyInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		CRS_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		CRS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		CRS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 10);
		CRS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 11);
		CRS_Param1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		CRS_Param2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 13);
		CRS_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 14);
	}
	else if (strcmp(abilityName, BG_STRING) == 0)
	{
		BG_ActiveThisGame[gameIdx] = true;
		BG_AbilityEndsAt[gameIdx] = 0.0;
		
		BG_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		BG_FBBeamsOnZ[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		BG_FBBeamsOnLR[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		BG_LRBeamsOnZ[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		BG_LRBeamsOnFB[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 5);
		BG_ZBeamsOnFB[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 6);
		BG_ZBeamsOnLR[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 7);
		BG_BeamRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		BG_BeamColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 9);
		BG_ImmunityDuration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		BG_ShotsPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 21);
		BG_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 22);
		BG_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 23);
		BG_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 24);
		BG_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 25);
		BG_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 26);
		BG_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 27);
		BG_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 28);
		BG_AllowConcurrentAbilities[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 29) == 1;
		
		// may as well cache this little equation now
		BG_NumBeams[gameIdx] = (BG_FBBeamsOnZ[gameIdx] * BG_FBBeamsOnLR[gameIdx]) + (BG_LRBeamsOnZ[gameIdx] * BG_LRBeamsOnFB[gameIdx]) + (BG_ZBeamsOnFB[gameIdx] * BG_ZBeamsOnLR[gameIdx]);
	}
	else if (strcmp(abilityName, FSS_STRING) == 0)
	{
		FSS_ActiveThisGame[gameIdx] = true;
		FSS_AbilityEndsAt[gameIdx] = 0.0;
		FSS_Owner[gameIdx] = owner;
		
		FSS_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		FSS_ShotsPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		FSS_StalkingSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		FSS_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		FSS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 5);
		FSS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 6);
		FSS_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		FSS_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		FSS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		FSS_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		FSS_AllowConcurrentAbilities[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 11) == 1;
		FSS_StartDelay[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
		FSS_IsSilent[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 13) == 1;
	}
	else if (strcmp(abilityName, MRS_STRING) == 0)
	{
		MRS_ActiveThisGame[gameIdx] = true;
		MRS_AbilityEndsAt[gameIdx] = 0.0;
		MRS_Owner[gameIdx] = owner;
		
		MRS_Duration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		MRS_RandomMinDistance[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		MRS_ShotsPerRipple[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		MRS_RandomRippleInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		MRS_BossRippleInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		MRS_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		MRS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		MRS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 8);
		MRS_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 9);
		MRS_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		MRS_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		MRS_BossMoveSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 12);
	}
	else if (strcmp(abilityName, RBW_STRING) == 0)
	{
		RBW_ActiveThisGame[gameIdx] = true;
		RBW_RotationEndsAt[gameIdx] = 0.0;
		RBW_LastWasCCW[gameIdx] = false; // for consistency across many games. always start as CCW
		RBW_Owner[gameIdx] = owner;
		
		RBW_SetupDuration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		RBW_RotateDuration[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		RBW_BeamsToSpawn[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 3);
		RBW_ProjectilesPerSecond[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 4);
		RBW_AngleVariance[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		RBW_RotationDirection[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 6);
		RBW_BeamColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 7);
		RBW_BeamDistance[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		RBW_ShotRadiusStatic[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		RBW_ShotRadiusRelative[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 10);
		RBW_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		RBW_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 12);
		RBW_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 13);
		RBW_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 14);
		RBW_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 15);
		
		RBW_BeamRadius[gameIdx] = (DG_EXPECTED_ARENA_HEIGHT / float(RBW_BeamsToSpawn[gameIdx])) * 0.5;
		if (RBW_ShotRadiusStatic[gameIdx] <= 0.0)
			RBW_ShotRadiusStatic[gameIdx] = RBW_ShotRadiusRelative[gameIdx] * RBW_BeamRadius[gameIdx];
	}
	else if (strcmp(abilityName, ERR_STRING) == 0)
	{
		ERR_ActiveThisGame[gameIdx] = true;
		ERR_Owner[gameIdx] = owner;
		
		ERR_ShotsXY[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 1);
		ERR_ShotsZ[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 2);
		ERR_ApexYawVariance[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 3);
		ERR_IgnorePitch[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4) == 1;
		ERR_ShotType[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 5);
		ERR_ShotParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		ERR_ShotParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 7);
		ERR_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		ERR_RowZOffset[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		ERR_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 10);
		ERR_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		ERR_RotateCCW[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 12) == 1;
	}
	else if (strcmp(abilityName, DOS_STRING) == 0)
	{
		DOS_ActiveThisGame[gameIdx] = true;
		DOS_Owner[gameIdx] = owner;
		
		DOS_SpawnerLifetime[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 1);
		DOS_SpawnerSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 2);
		DOS_SpawnerModelIdx[gameIdx] = DF_ReadModelToInt(characterName, abilityIdx, 3);
		DOS_SpawnerMovePattern[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 4);
		DOS_SpawnerMoveParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 5);
		DOS_SpawnerMoveParam2[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 6);
		DOS_SpawnerSpawnPattern[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 7);
		DOS_SpawnerSpawnInterval[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 8);
		DOS_SpawnerSpawnParam1[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 9);
		DOS_IsBombProof[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 10) == 1;
		DOS_ShotRadius[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 11);
		DOS_ShotColor[gameIdx] = DF_GetArgInt(characterName, abilityIdx, 12);
		DOS_ShotSpeed[gameIdx] = DF_GetArgFloat(characterName, abilityIdx, 13);
	}
}

// this one's different from the others since the subplugin .inc handles a ton of things related to game frame
// just keep in mind that OnGameFrame() can't be declared in this subplugin, since it is in the .inc
ManagedGameFrame(gameIdx, bool:hero, Float:curTime)
{
	// typically only boss abilities operate on this game frame,
	// because hero abilities have DF_OnAbilityUsed() called every frame
	// bombs are the exception
	if (hero)
	{
		BB_Tick(gameIdx, curTime);
		PBB_Tick(gameIdx, curTime);
	}
	else
	{
		CS_Tick(gameIdx, curTime);
		RWA_Tick(gameIdx, curTime);
		PWA_Tick(gameIdx, curTime);
		RNGS_Tick(gameIdx, curTime);
		// PF doesn't tick, which is rare for boss abilities
		PFD_Tick(gameIdx, curTime); // but PFD does, due to the delay
		RRB_Tick(gameIdx, curTime);
		PPS_Tick(gameIdx, curTime);
		CRS_Tick(gameIdx, curTime);
		BG_Tick(gameIdx, curTime);
		FSS_Tick(gameIdx, curTime);
		MRS_Tick(gameIdx, curTime);
		RBW_Tick(gameIdx, curTime);
		// ERR does not tick
		// DOS does not tick
	}
}

public DF_OnAbilityUsed(gameIdx, String:abilityName[MAX_ABILITY_NAME_LENGTH], Float:curTime, Float:powerLevel, userFlags)
{
	if (SS_ActiveThisGame[gameIdx] && strcmp(abilityName, SS_STRING) == 0)
		SS_OnUse(gameIdx, curTime, powerLevel, userFlags);
	if (BB_ActiveThisGame[gameIdx] && strcmp(abilityName, BB_STRING) == 0)
		BB_OnUse(gameIdx, curTime);
	if (PBB_ActiveThisGame[gameIdx] && strcmp(abilityName, PBB_STRING) == 0)
		PBB_OnUse(gameIdx, curTime);
	if (CS_ActiveThisGame[gameIdx] && strcmp(abilityName, CS_STRING) == 0)
		CS_OnUse(gameIdx, curTime);
	if (RWA_ActiveThisGame[gameIdx] && strcmp(abilityName, RWA_STRING) == 0)
		RWA_OnUse(gameIdx, curTime);
	if (PWA_ActiveThisGame[gameIdx] && strcmp(abilityName, PWA_STRING) == 0)
		PWA_OnUse(gameIdx, curTime);
	if (RNGS_ActiveThisGame[gameIdx] && strcmp(abilityName, RNGS_STRING) == 0)
		RNGS_OnUse(gameIdx, curTime);
	if (PF_ActiveThisGame[gameIdx] && strcmp(abilityName, PF_STRING) == 0)
		PF_OnUse(gameIdx, curTime);
	if (PFD_ActiveThisGame[gameIdx] && strcmp(abilityName, PFD_STRING) == 0)
		PFD_OnUse(gameIdx, curTime);
	if (RRB_ActiveThisGame[gameIdx] && strcmp(abilityName, RRB_STRING) == 0)
		RRB_OnUse(gameIdx, curTime);
	if (PPS_ActiveThisGame[gameIdx] && strcmp(abilityName, PPS_STRING) == 0)
		PPS_OnUse(gameIdx, curTime);
	if (CRS_ActiveThisGame[gameIdx] && strcmp(abilityName, CRS_STRING) == 0)
		CRS_OnUse(gameIdx, curTime);
	if (BG_ActiveThisGame[gameIdx] && strcmp(abilityName, BG_STRING) == 0)
		BG_OnUse(gameIdx, curTime);
	if (FSS_ActiveThisGame[gameIdx] && strcmp(abilityName, FSS_STRING) == 0)
		FSS_OnUse(gameIdx, curTime);
	if (MRS_ActiveThisGame[gameIdx] && strcmp(abilityName, MRS_STRING) == 0)
		MRS_OnUse(gameIdx, curTime);
	if (RBW_ActiveThisGame[gameIdx] && strcmp(abilityName, RBW_STRING) == 0)
		RBW_OnUse(gameIdx, curTime);
	if (ERR_ActiveThisGame[gameIdx] && strcmp(abilityName, ERR_STRING) == 0)
		ERR_OnUse(gameIdx, curTime);
	if (DOS_ActiveThisGame[gameIdx] && strcmp(abilityName, DOS_STRING) == 0)
		DOS_OnUse(gameIdx, curTime);
}

public DF_GameCleanup(gameIdx)
{
	SS_Cleanup(gameIdx);
	BB_Cleanup(gameIdx);
	PBB_Cleanup(gameIdx);
	CS_Cleanup(gameIdx);
	RWA_Cleanup(gameIdx);
	PWA_Cleanup(gameIdx);
	RNGS_Cleanup(gameIdx);
	PF_Cleanup(gameIdx);
	PFD_Cleanup(gameIdx);
	RRB_Cleanup(gameIdx);
	PPS_Cleanup(gameIdx);
	CRS_Cleanup(gameIdx);
	BG_Cleanup(gameIdx);
	FSS_Cleanup(gameIdx);
	MRS_Cleanup(gameIdx);
	RBW_Cleanup(gameIdx);
	ERR_Cleanup(gameIdx);
	DOS_Cleanup(gameIdx);
}

/**
 * Hero Ability: Standard Shots
 */
public SS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		SS_ActiveThisGame[i] = false; // that's all, folks
	}
}

public SS_OnUse(gameIdx, Float:curTime, Float:powerLevel, userFlags)
{
	// standard (non-homing) rockets first
	if (SS_ActiveThisGame[gameIdx] && curTime >= SS_NextStandardVolleyAt[gameIdx])
	{
		SS_NextStandardVolleyAt[gameIdx] = curTime + SS_StandardInterval[gameIdx];
		
		new Float:distance = SS_StandardDistance[gameIdx];
		if (userFlags & DG_USER_FLAG_FOCUSED)
			distance *= SS_FocusDistanceMult[gameIdx];
		
		new shots = SS_StandardShotsPerVolley[gameIdx];
		new Float:thisDistance = distance * float(shots - 1) * 0.5;
	
		// get angle and position
		static Float:angles[3];
		GetClientEyeAngles(SS_Owner[gameIdx], angles);
		static Float:pos[3];
		GetEntPropVector(SS_Owner[gameIdx], Prop_Send, "m_vecOrigin", pos);
		pos[2] += DC_HERO_HIT_SPOT_Z_OFFSET;
		
		// spawn all side rockets
		static Float:tmpPos[3];
		static Float:tmpAngle[3];
		tmpAngle[0] = tmpAngle[2] = 0.0;
		for (new i = 0; i < shots; i++) // previous logic (the isOdd stuff) ensures that this is sound
		{
			if (i > 0)
				thisDistance -= distance;
			
			// close enough to zero
			if (distance <= 1.0 && distance >= -1.0)
				CopyVector(tmpPos, pos);
			else
			{
				if (thisDistance < 0.0)
					tmpAngle[1] = fixAngle(angles[1] + 90.0);
				else
					tmpAngle[1] = fixAngle(angles[1] - 90.0);

				TR_TraceRayFilter(pos, tmpAngle, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
				TR_GetEndPosition(tmpPos);
				ConformLineDistance(tmpPos, pos, tmpPos, fabs(thisDistance), true);
			}
		
			// spawn the current rocket
			DR_SpawnRocketAt(gameIdx, true, tmpPos, angles, SS_StandardRadius[gameIdx], SS_StandardSpeed[gameIdx], SS_StandardColor[gameIdx],
					SS_StandardDamage[gameIdx], (SS_StandardIsWave[gameIdx] ? DR_PATTERN_WAVE : DR_PATTERN_STRAIGHT), SS_StandardAnglePerSec[gameIdx], 1.0, 0.0, DR_FLAG_NO_SHOT_SOUND);
		}
		
		// play the sound
		if (curTime >= SS_NextShotSoundAt[gameIdx])
		{
			SS_NextShotSoundAt[gameIdx] = curTime + SS_ShotSoundInterval[gameIdx];
			EmitAmbientSound(SS_ShotSound[gameIdx], pos, SS_Owner[gameIdx]);
		}
	}
	
	// homing rockets next
	if (curTime >= SS_NextHomingVolleyAt[gameIdx])
	{
		SS_NextHomingVolleyAt[gameIdx] = curTime + SS_HomingInterval[gameIdx];
		static Float:angles[3];
		GetClientEyeAngles(SS_Owner[gameIdx], angles);
		static Float:tmpAngle[3];
		tmpAngle[0] = tmpAngle[2] = 0.0;
		new Float:angleOffset = SS_HomingAngleOffset[gameIdx];
		if (userFlags & DG_USER_FLAG_FOCUSED)
			angleOffset *= SS_FocusAngleMult[gameIdx];
		for (new i = 0; i < SS_HomingShotsPerVolley[gameIdx]; i++)
		{
			new Float:yawOffset = ((1.0 + (i / 2)) * angleOffset) * (i % 2 == 1 ? -1.0 : 1.0);
			tmpAngle[1] = angles[1] + yawOffset;
			DR_SpawnRocket(gameIdx, true, tmpAngle, SS_HomingRadius[gameIdx], SS_HomingSpeed[gameIdx], SS_HomingColor[gameIdx],
					SS_HomingDamage[gameIdx], DR_PATTERN_HOMING, SS_HomingAnglePerSec[gameIdx], 0.0, 0.0, DR_FLAG_NO_SHOT_SOUND);
		}
	}
}

/**
 * Hero Ability: Basic Bomb
 */
public BB_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		BB_ActiveThisGame[i] = false; // that's all, folks
	}
}

public BB_OnUse(gameIdx, Float:curTime)
{
	BB_AbilityEndsAt[gameIdx] = curTime + BB_Duration[gameIdx];
	
	// play the sound now to both parties if applicable
	if (strlen(BB_Sound[gameIdx]) > 3)
	{
		EmitSoundToClient(BB_Owner[gameIdx], BB_Sound[gameIdx]);
		EmitSoundToClient(BB_Victim[gameIdx], BB_Sound[gameIdx]);
	}
	
	// do boss damage now if applicable
	if (BB_BossDamage[gameIdx] > 0)
		DG_OnBossHit(gameIdx, BB_BossDamage[gameIdx]);
		
	// print that it's happening
	if (PRINT_DEBUG_INFO)
		PrintToServer("Hero using basic bomb until %f, currently %f, did %d damage to boss", BB_AbilityEndsAt[gameIdx], curTime, BB_BossDamage[gameIdx]);
}

BB_Tick(gameIdx, Float:curTime)
{
	if (!BB_ActiveThisGame[gameIdx])
		return;
		
	if (curTime < BB_AbilityEndsAt[gameIdx])
	{
		new Float:radius = BB_StartRadius[gameIdx] + ((BB_EndRadius[gameIdx] - BB_StartRadius[gameIdx]) * ((BB_Duration[gameIdx] - (BB_AbilityEndsAt[gameIdx] - curTime)) / BB_Duration[gameIdx]));
		static Float:heroPos[3];
		DR_GetHeroHitPosition(gameIdx, heroPos);
		DG_RadiusBombEffect(gameIdx, radius, heroPos);
	}
}

/**
 * Hero Ability: (Persistent) Beam Bomb
 */
public PBB_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		PBB_ActiveThisGame[i] = false; // that's all, folks
	}
}

public PBB_OnUse(gameIdx, Float:curTime)
{
	PBB_AbilityEndsAt[gameIdx] = curTime + PBB_Duration[gameIdx];
	PBB_NumHarmfulBeams[gameIdx] = 0;
	PBB_NextBeamAt[gameIdx] = curTime;
	
	// play the sound now to both parties if applicable
	if (strlen(PBB_Sound[gameIdx]) > 3)
	{
		EmitSoundToClient(PBB_Owner[gameIdx], PBB_Sound[gameIdx]);
		EmitSoundToClient(PBB_Victim[gameIdx], PBB_Sound[gameIdx]);
	}
		
	// print that it's happening
	if (PRINT_DEBUG_INFO)
		PrintToServer("Hero using beam bomb until %f, currently %f, will do %d damage per 50ms per beam to boss", PBB_AbilityEndsAt[gameIdx], curTime, PBB_IndividualBeamDamage[gameIdx]);
}

#define PBB_MAXLEN 1300.0
PBB_Tick(gameIdx, Float:curTime)
{
	if (!PBB_ActiveThisGame[gameIdx] || PBB_AbilityEndsAt[gameIdx] == 0.0)
		return;
		
	if (curTime >= PBB_AbilityEndsAt[gameIdx])
	{
		// this sort of structure isn't really needed for bomb abilities, but who knows, in the future it might help.
		PBB_AbilityEndsAt[gameIdx] = 0.0;
		return;
	}
	
	// the "bomb" is always reported
	static Float:heroPos[3];
	DR_GetDefaultFiringPosition(PBB_Owner[gameIdx], heroPos);
	static Float:eyeAngles[3];
	GetClientEyeAngles(PBB_Owner[gameIdx], eyeAngles);
	static Float:endPos[3];
	TR_TraceRayFilter(heroPos, eyeAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	DG_BeamBombEffect(gameIdx, heroPos, endPos, PBB_BombRadius[gameIdx]);
	
	// nothing to do if it's not time to render another beam
	if (curTime < PBB_NextBeamAt[gameIdx])
		return;
		
	PBB_NextBeamAt[gameIdx] = curTime + PBB_BeamRefreshInterval[gameIdx];
	
	// how many harmful beams should there have been, versus the number there are
	new harmfulExpected = 1 + getWholeComponent((PBB_Duration[gameIdx] - (PBB_AbilityEndsAt[gameIdx] - curTime)) / DB_STANDARD_INTERVAL);
	new bool:shouldBeHarmful = (harmfulExpected > PBB_NumHarmfulBeams[gameIdx]);
	PBB_NumHarmfulBeams[gameIdx] = harmfulExpected;
	
	// now draw the four beams
	static Float:startPos[3];
	for (new pass = 0; pass < 4; pass++)
	{
		CopyVector(startPos, heroPos);
		if (pass == 0)
			startPos[2] += PBB_BeamRadius[gameIdx];
		else if (pass == 1)
			startPos[2] -= PBB_BeamRadius[gameIdx];
		else
		{
			static Float:tmpAngle[3];
			CopyVector(tmpAngle, eyeAngles);
			tmpAngle[0] = 0.0;
			if (pass == 2)
				tmpAngle[1] = fixAngle(tmpAngle[1] + 90.0);
			else
				tmpAngle[1] = fixAngle(tmpAngle[1] - 90.0);

			TR_TraceRayFilter(heroPos, tmpAngle, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
			TR_GetEndPosition(startPos);
			ConformLineDistance(startPos, heroPos, startPos, PBB_BeamRadius[gameIdx], true);
		}

		TR_TraceRayFilter(startPos, eyeAngles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
		TR_GetEndPosition(endPos);
		DB_SpawnBeam(gameIdx, true, startPos, endPos, PBB_BeamRadius[gameIdx], PBB_BeamColor[gameIdx], PBB_IndividualBeamDamage[gameIdx], shouldBeHarmful ? 0 : DB_FLAG_HARMLESS);
	}
}

/**
 * Boss Ability: Circumference Shot
 */
public CS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		CS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public CS_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	CS_AbilityStartedAt[gameIdx] = CS_NextVolleyAt[gameIdx] = curTime;
	CS_AbilityEndsAt[gameIdx] = CS_AbilityStartedAt[gameIdx] + CS_Duration[gameIdx];
	DG_SetBossMoveSpeed(gameIdx, CS_MoveSpeed[gameIdx]);
}
 
CS_Tick(gameIdx, Float:curTime)
{
	if (!CS_ActiveThisGame[gameIdx] || CS_AbilityStartedAt[gameIdx] == FAR_FUTURE)
		return;

	if (curTime >= CS_AbilityEndsAt[gameIdx])
	{
		CS_AbilityStartedAt[gameIdx] = FAR_FUTURE;
		DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability ends
		DG_BossAbilityEnded(gameIdx);
		return;
	}

	if (curTime >= CS_NextVolleyAt[gameIdx])
	{
		CS_NextVolleyAt[gameIdx] = curTime + CS_Interval[gameIdx];

		// to make up for the fewer number of projectiles available in bullet heck
		// we need to ensure those that do spawn are always a potential threat to the hero
		static Float:bossPos[3];
		static Float:heroPos[3];
		static Float:angles[3];
		DR_GetDefaultFiringPosition(CS_Owner[gameIdx], bossPos);
		DR_GetHeroHitPosition(gameIdx, heroPos);
		GetVectorAnglesTwoPoints(bossPos, heroPos, angles); // we just need the pitch from this, though

		// also need each x/y angle offset and starting yaw (which overrides the yaw from eye angles)
		new Float:yawOffset = 360.0 / float(CS_NumShotsXY[gameIdx]);
		angles[1] = fixAngle(((CS_AbilityEndsAt[gameIdx] - CS_AbilityStartedAt[gameIdx]) - (CS_AbilityEndsAt[gameIdx] - curTime)) * CS_RotationPerSecond[gameIdx]);

		// spawn our many projectiles!
		static Float:tmpPos[3];
		tmpPos[0] = bossPos[0];
		tmpPos[1] = bossPos[1];
		new Float:zStart = (float(CS_NumShotsZ[gameIdx] - 1) * CS_ShotZOffset[gameIdx]) * 0.5;
		for (new xy = 0; xy < CS_NumShotsXY[gameIdx]; xy++)
		{
			for (new z = 0; z < CS_NumShotsZ[gameIdx]; z++)
			{
				new Float:zOffset = zStart - (float(z) * CS_ShotZOffset[gameIdx]);
				tmpPos[2] = bossPos[2] + zOffset;
				DR_SpawnRocketAt(gameIdx, false, tmpPos, angles, CS_ShotRadius[gameIdx], CS_ShotSpeed[gameIdx], CS_ShotColor[gameIdx],
						1, CS_ShotType[gameIdx], CS_ShotParam1[gameIdx], CS_ShotParam2[gameIdx]);
			}

			angles[1] = fixAngle(angles[1] + yawOffset);
		}
	}
}

/**
 * Boss Ability: Random Wall Attack
 */
public RWA_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		RWA_ActiveThisGame[i] = false; // that's all, folks
	}
}

public RWA_OnUse(gameIdx, Float:curTime)
{
	RWA_AbilityStartedAt[gameIdx] = curTime + fmax(0.0, RWA_StartDelay[gameIdx]);
	RWA_AbilityEndsAt[gameIdx] = RWA_AbilityStartedAt[gameIdx] + RWA_Duration[gameIdx];
	RWA_ReportEndAt[gameIdx] = RWA_AbilityStartedAt[gameIdx] + RWA_FakeDuration[gameIdx];
	RWA_ProjectilesSpawned[gameIdx] = 0;
	RWA_FixedMoveSpeed[gameIdx] = false;
	DG_SetBossMoveSpeed(gameIdx, RWA_MoveSpeed[gameIdx]);
	
	// do some of these math calls now for efficiency and consistency
	// the goal is to get the ideal range of firing positions which will be used throughout the rage
	RWA_ActiveWallType[gameIdx] = RWA_WallType[gameIdx];
	if (RWA_ActiveWallType[gameIdx] == -1)
		RWA_ActiveWallType[gameIdx] = DG_GetFurthestSpawnPattern(gameIdx, RWA_SpawnAxis[gameIdx]);
	DG_GetWallMinMaxAndFiringAngle(gameIdx, RWA_ActiveWallType[gameIdx], RWA_WallRect[gameIdx][0], RWA_WallRect[gameIdx][1], RWA_FiringAngle[gameIdx]);
	DG_AdjustWallFiringPosition(RWA_WallRect[gameIdx], RWA_FiringAngle[gameIdx], RWA_ActiveWallType[gameIdx]);
	DG_GetIdealRectangle(RWA_WallRect[gameIdx], RWA_FiringAngle[gameIdx], RWA_ActiveWallType[gameIdx]);
	
	// send the warning notification to the base
	if (!IsEmptyString(RWA_WarningText[gameIdx]))
		DG_SetWarningMessage(gameIdx, RWA_WarningText[gameIdx], RWA_WarningSound[gameIdx]);
}
 
RWA_Tick(gameIdx, Float:curTime)
{
	if (!RWA_ActiveThisGame[gameIdx])
		return;

	if (curTime >= RWA_AbilityStartedAt[gameIdx])
	{
		if (!RWA_FixedMoveSpeed[gameIdx] && RWA_MoveSpeedType[gameIdx] == 0)
		{
			RWA_FixedMoveSpeed[gameIdx] = true;
			DG_SetBossMoveSpeed(gameIdx, -1.0);
		}
	
		// how many rockets do we spawn this frame?
		new rocketsThisFrame = 0;
		if (curTime < RWA_AbilityEndsAt[gameIdx])
		{
			new projectilesExpected = RoundFloat((curTime - RWA_AbilityStartedAt[gameIdx]) * float(RWA_ProjectilesPerSecond[gameIdx]));
			rocketsThisFrame = projectilesExpected - RWA_ProjectilesSpawned[gameIdx];
		}
		
		// sanity limit
		RWA_ProjectilesSpawned[gameIdx] += rocketsThisFrame; // lie in case we lower it, lest this sanity message become console spam
		if (rocketsThisFrame > 10)
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[df_default_abilities] WARNING: Passed sanity limit of rockets per frame. (%d > 10) Clamping.", rocketsThisFrame);
			rocketsThisFrame = 10;
		}
		
		// spawn them
		for (new i = 0; i < rocketsThisFrame; i++)
		{
			// angle is only slightly tricky. pitch over 90 degrees might cause console errors.
			static Float:tmpAngle[3];
			//tmpAngle[0] = constrainPitch(RWA_FiringAngle[gameIdx][0] + GetRandomFloat(-RWA_AngleDeviation[gameIdx], RWA_AngleDeviation[gameIdx]));
			tmpAngle[0] = RWA_FiringAngle[gameIdx][0] + GetRandomFloat(-RWA_AngleDeviation[gameIdx], RWA_AngleDeviation[gameIdx]);
			tmpAngle[1] = fixAngle(RWA_FiringAngle[gameIdx][1] + GetRandomFloat(-RWA_AngleDeviation[gameIdx], RWA_AngleDeviation[gameIdx]));
			tmpAngle[2] = 0.0;
				
			// no matter how much I try to simplify this, there's still a lot of code.
			// ceiling and floor position depend on wall type, while the other four walls depend on the yaw
			// since X and Y axis can be swapped at any time depending on what the map decided "hero forward" is
			static Float:position[3];
			if (RWA_ActiveWallType[gameIdx] == DG_WALL_CEILING || RWA_ActiveWallType[gameIdx] == DG_WALL_FLOOR)
			{
				position[0] = GetRandomFloat(RWA_WallRect[gameIdx][0][0], RWA_WallRect[gameIdx][1][0]);
				position[1] = GetRandomFloat(RWA_WallRect[gameIdx][0][1], RWA_WallRect[gameIdx][1][1]);
				position[2] = RWA_WallRect[gameIdx][0][2]; // min and max are the same
				
				// randomize the yaw to be anything, since we're firing from the top or bottom
				tmpAngle[1] = GetRandomFloat(-179.9, 179.9);
			}
			else if (RWA_WallRect[gameIdx][0][0] == RWA_WallRect[gameIdx][1][0]) // why remember angle math when you can cheat ;P
			{
				position[0] = RWA_WallRect[gameIdx][0][0];
				position[1] = GetRandomFloat(RWA_WallRect[gameIdx][0][1], RWA_WallRect[gameIdx][1][1]);
				position[2] = GetRandomFloat(RWA_WallRect[gameIdx][0][2], RWA_WallRect[gameIdx][1][2]);
			}
			else //if (RWA_WallRect[gameIdx][0][1] == RWA_WallRect[gameIdx][1][1]) // why remember angle math when you can cheat ;P
			{
				position[0] = GetRandomFloat(RWA_WallRect[gameIdx][0][0], RWA_WallRect[gameIdx][1][0]);
				position[1] = RWA_WallRect[gameIdx][0][1];
				position[2] = GetRandomFloat(RWA_WallRect[gameIdx][0][2], RWA_WallRect[gameIdx][1][2]);
			}
			
			DR_SpawnRocketAt(gameIdx, false, position, tmpAngle, RWA_Radius[gameIdx], RWA_Speed[gameIdx], RWA_Color[gameIdx],
						1, DR_PATTERN_STRAIGHT, 0.0, 0.0);
		}
		
		// now handle ability end
		if (curTime >= RWA_AbilityEndsAt[gameIdx])
			RWA_AbilityStartedAt[gameIdx] = FAR_FUTURE;
	}
	
	// intentionally outside of the above.
	if (curTime >= RWA_ReportEndAt[gameIdx])
	{
		if (RWA_MoveSpeedType[gameIdx] == 1)
			DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
		DG_BossAbilityEnded(gameIdx);
		RWA_ReportEndAt[gameIdx] = FAR_FUTURE;
	}
}

/**
 * Boss Ability: Patterned Wall Attack
 */
public PWA_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		PWA_ActiveThisGame[i] = false; // that's all, folks
	}
}

public PWA_OnUse(gameIdx, Float:curTime)
{
	PWA_AbilityStartedAt[gameIdx] = curTime + fmax(0.0, PWA_StartDelay[gameIdx]);
	if (PWA_SpawnType[gameIdx] != PWA_TYPE_ALL_AT_ONCE)
		DG_SetBossMoveSpeed(gameIdx, PWA_BossMoveSpeed[gameIdx]);

	// pertaining to waves
	PWA_NextWaveAt[gameIdx] = PWA_AbilityStartedAt[gameIdx];
	PWA_WavesExpected[gameIdx] = 1;
	if (PWA_SpawnType[gameIdx] == PWA_TYPE_ROWS)
		PWA_WavesExpected[gameIdx] = PWA_NumPerRow[gameIdx];
	else if (PWA_SpawnType[gameIdx] == PWA_TYPE_COLUMNS)
		PWA_WavesExpected[gameIdx] = PWA_NumPerColumn[gameIdx];
	else if (PWA_SpawnType[gameIdx] == PWA_TYPE_RECTANGLE_INWARD || PWA_SpawnType[gameIdx] == PWA_TYPE_RECTANGLE_OUTWARD)
	{
		new lowest = min(PWA_NumPerRow[gameIdx], PWA_NumPerColumn[gameIdx]);
		PWA_WavesExpected[gameIdx] = (lowest / 2) + (lowest % 2);
	}
	PWA_WavesSpawned[gameIdx] = 0;
	
	// do some of these math calls now for efficiency and consistency
	// the goal is to get the ideal range of firing positions which will be used throughout the rage
	PWA_ActiveWallType[gameIdx] = PWA_WallType[gameIdx];
	if (PWA_ActiveWallType[gameIdx] == -1)
		PWA_ActiveWallType[gameIdx] = DG_GetFurthestSpawnPattern(gameIdx, PWA_SpawnAxis[gameIdx]);
	DG_GetWallMinMaxAndFiringAngle(gameIdx, PWA_ActiveWallType[gameIdx], PWA_WallRect[gameIdx][0], PWA_WallRect[gameIdx][1], PWA_FiringAngle[gameIdx]);
	DG_AdjustWallFiringPosition(PWA_WallRect[gameIdx], PWA_FiringAngle[gameIdx], PWA_ActiveWallType[gameIdx]);
	DG_GetIdealRectangle(PWA_WallRect[gameIdx], PWA_FiringAngle[gameIdx], PWA_ActiveWallType[gameIdx]);
	
	// we need the above to figure out the projectile's radius
	PWA_ActiveRadius[gameIdx] = PWA_StaticRadius[gameIdx];
	if (PWA_ActiveRadius[gameIdx] <= 0.0)
	{
		new Float:minWidth = 1.0;
		if (PWA_WallRect[gameIdx][0][0] == PWA_WallRect[gameIdx][1][0])
			minWidth = fmin(PWA_WallRect[gameIdx][1][1] - PWA_WallRect[gameIdx][0][1], PWA_WallRect[gameIdx][1][2] - PWA_WallRect[gameIdx][0][2]);
		else if (PWA_WallRect[gameIdx][0][1] == PWA_WallRect[gameIdx][1][1])
			minWidth = fmin(PWA_WallRect[gameIdx][1][0] - PWA_WallRect[gameIdx][0][0], PWA_WallRect[gameIdx][1][2] - PWA_WallRect[gameIdx][0][2]);
		else if (PWA_WallRect[gameIdx][0][2] == PWA_WallRect[gameIdx][1][2])
			minWidth = fmin(PWA_WallRect[gameIdx][1][0] - PWA_WallRect[gameIdx][0][0], PWA_WallRect[gameIdx][1][1] - PWA_WallRect[gameIdx][0][1]);
		PWA_ActiveRadius[gameIdx] = PWA_RelativeRadius[gameIdx] * minWidth;
		PWA_ActiveRadius[gameIdx] *= 0.5; // because radius is not diameter
	}
	
	// send the warning notification to the base
	if (!IsEmptyString(PWA_WarningText[gameIdx]))
		DG_SetWarningMessage(gameIdx, PWA_WarningText[gameIdx], PWA_WarningSound[gameIdx]);
		
	// lots of possible points of failure here, going to print the most likely
	if (PRINT_DEBUG_SPAM)
		PrintToServer("[df_default_abilities] %s being used. min=%f,%f,%f max=%f,%f,%f angle=%f,%f,%f\nrows=%d columns=%d spawnType=%d radius=%f wallType=%d", PWA_STRING,
				PWA_WallRect[gameIdx][0][0], PWA_WallRect[gameIdx][0][1], PWA_WallRect[gameIdx][0][2],
				PWA_WallRect[gameIdx][1][0], PWA_WallRect[gameIdx][1][1], PWA_WallRect[gameIdx][1][2],
				PWA_FiringAngle[gameIdx][0], PWA_FiringAngle[gameIdx][1], PWA_FiringAngle[gameIdx][2],
				PWA_NumPerRow[gameIdx], PWA_NumPerColumn[gameIdx], PWA_SpawnType[gameIdx], PWA_ActiveRadius[gameIdx], PWA_ActiveWallType[gameIdx]);
}

public Float:PWA_GetNthPosition(Float:min, Float:max, posNum, posMax, Float:radius)
{
	// ensure the entire projectile spawns inside the specified rectangle
	min += radius;
	max -= radius;
	if (posMax <= 1) // prevent div by zero
		return (min + max) * 0.5;

	// posMax - 1 so that the first posFactor is 0.0 and the last is 1.0
	new Float:posFactor = float(posNum) / float(posMax - 1);
	return min + ((max - min) * posFactor);
}
 
PWA_Tick(gameIdx, Float:curTime)
{
	if (!PWA_ActiveThisGame[gameIdx])
		return;
		
	if (curTime >= PWA_AbilityStartedAt[gameIdx])
	{
		if (PWA_WavesExpected[gameIdx] > PWA_WavesSpawned[gameIdx] && curTime >= PWA_NextWaveAt[gameIdx])
		{
			for (new row = 0; row < PWA_NumPerRow[gameIdx]; row++)
			{
				new bool:shouldSpawn = (PWA_SpawnType[gameIdx] == PWA_TYPE_ALL_AT_ONCE);
				if (PWA_SpawnType[gameIdx] == PWA_TYPE_ROWS)
				{
					shouldSpawn = (row == PWA_WavesSpawned[gameIdx]);
					if (!shouldSpawn)
						continue; // one little glimmer of efficiency
				}
					
				for (new column = 0; column < PWA_NumPerColumn[gameIdx]; column++)
				{
					if (PWA_SpawnType[gameIdx] == PWA_TYPE_COLUMNS)
						shouldSpawn = (column == PWA_WavesSpawned[gameIdx]);
					else if (PWA_SpawnType[gameIdx] == PWA_TYPE_RECTANGLE_INWARD || PWA_SpawnType[gameIdx] == PWA_TYPE_RECTANGLE_OUTWARD)
					{
						new adjustedWave = PWA_WavesSpawned[gameIdx];
						if (PWA_SpawnType[gameIdx] == PWA_TYPE_RECTANGLE_OUTWARD)
							adjustedWave = (PWA_WavesExpected[gameIdx] - 1) - adjustedWave;
							
						// I way overcomplicated this logic in my head. turned out to be this simple when writing it out.
						if (row == adjustedWave || row == ((PWA_NumPerRow[gameIdx] - 1) - adjustedWave))
							if (column >= adjustedWave && column <= ((PWA_NumPerColumn[gameIdx] - 1) - adjustedWave))
								shouldSpawn = true;
								
						if (column == adjustedWave || column == ((PWA_NumPerColumn[gameIdx] - 1) - adjustedWave))
							if (row >= adjustedWave && row <= ((PWA_NumPerRow[gameIdx] - 1) - adjustedWave))
								shouldSpawn = true;
					}
					
					// that's all folks. lets spawn our rocket.
					if (shouldSpawn)
					{
						static Float:position[3];
						new actualShotType = PWA_ShotType[gameIdx];
						if (PWA_ActiveWallType[gameIdx] == DG_WALL_CEILING || PWA_ActiveWallType[gameIdx] == DG_WALL_FLOOR)
						{
							position[0] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][0], PWA_WallRect[gameIdx][1][0], row, PWA_NumPerRow[gameIdx], PWA_ActiveRadius[gameIdx]);
							position[1] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][1], PWA_WallRect[gameIdx][1][1], column, PWA_NumPerColumn[gameIdx], PWA_ActiveRadius[gameIdx]);
							position[2] = PWA_WallRect[gameIdx][0][2]; // min and max are the same
							
							// special for vertical, change the type of wave if applicable
							if (actualShotType == DR_PATTERN_WAVE)
								actualShotType = DR_PATTERN_VERTICAL_WAVE;
						}
						else if (PWA_WallRect[gameIdx][0][0] == PWA_WallRect[gameIdx][1][0]) // why remember angle math when you can cheat ;P
						{
							position[0] = PWA_WallRect[gameIdx][0][0];
							position[1] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][1], PWA_WallRect[gameIdx][1][1], row, PWA_NumPerRow[gameIdx], PWA_ActiveRadius[gameIdx]);
							position[2] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][2], PWA_WallRect[gameIdx][1][2], column, PWA_NumPerColumn[gameIdx], PWA_ActiveRadius[gameIdx]);
						}
						else //if (PWA_WallRect[gameIdx][0][1] == PWA_WallRect[gameIdx][1][1]) // why remember angle math when you can cheat ;P
						{
							position[0] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][0], PWA_WallRect[gameIdx][1][0], row, PWA_NumPerRow[gameIdx], PWA_ActiveRadius[gameIdx]);
							position[1] = PWA_WallRect[gameIdx][0][1];
							position[2] = PWA_GetNthPosition(PWA_WallRect[gameIdx][0][2], PWA_WallRect[gameIdx][1][2], column, PWA_NumPerColumn[gameIdx], PWA_ActiveRadius[gameIdx]);
						}

						//PrintToServer("Spawning rocket. row=%d column=%d position=%f,%f,%f angle=%f,%f,%f", row, column, position[0], position[1], position[2],
						//		PWA_FiringAngle[gameIdx][0], PWA_FiringAngle[gameIdx][1], PWA_FiringAngle[gameIdx][2]);
						DR_SpawnRocketAt(gameIdx, false, position, PWA_FiringAngle[gameIdx], PWA_ActiveRadius[gameIdx], PWA_Speed[gameIdx],
							PWA_Color[gameIdx], 1, actualShotType, PWA_ShotParam1[gameIdx], PWA_ShotParam2[gameIdx]);
					}
				}
			}
			
			PWA_NextWaveAt[gameIdx] = curTime + PWA_WaveDelay[gameIdx];
			PWA_WavesSpawned[gameIdx]++;
		}
		
		if (PWA_WavesExpected[gameIdx] <= PWA_WavesSpawned[gameIdx])
		{
			PWA_AbilityStartedAt[gameIdx] = FAR_FUTURE;
			DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
			DG_BossAbilityEnded(gameIdx);
		}
	}
}

/**
 * Boss Ability: RNG Shot
 */
public RNGS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		RNGS_ActiveThisGame[i] = false; // that's all, folks
	}
}

public RNGS_OnUse(gameIdx, Float:curTime)
{
	RNGS_AbilityEndsAt[gameIdx] = curTime + RNGS_Duration[gameIdx];
	RNGS_FakeAbilityEndsAt[gameIdx] = curTime + RNGS_FakeDuration[gameIdx];
	RNGS_ProjectilesSpawned[gameIdx] = 0;
	DG_SetBossMoveSpeed(gameIdx, RNGS_BossMoveSpeed[gameIdx]);
}

RNGS_Tick(gameIdx, Float:curTime)
{
	if (!RNGS_ActiveThisGame[gameIdx])
		return;
		
	if (curTime < RNGS_AbilityEndsAt[gameIdx])
	{
		new projectilesExpected = RoundFloat(RNGS_ShotsPerSecond[gameIdx] * (RNGS_Duration[gameIdx] - (RNGS_AbilityEndsAt[gameIdx] - curTime)));
		
		for (; RNGS_ProjectilesSpawned[gameIdx] < projectilesExpected; RNGS_ProjectilesSpawned[gameIdx]++)
		{
			static Float:eyeAngles[3];
			GetClientEyeAngles(RNGS_Owner[gameIdx], eyeAngles);
			new randomColor = (GetRandomInt(GetR(RNGS_MinColors[gameIdx]), GetR(RNGS_MaxColors[gameIdx]))<<16) | 
					(GetRandomInt(GetG(RNGS_MinColors[gameIdx]), GetG(RNGS_MaxColors[gameIdx]))<<8) | 
					GetRandomInt(GetB(RNGS_MinColors[gameIdx]), GetB(RNGS_MaxColors[gameIdx]));
			
			DR_SpawnRocket(gameIdx, false, eyeAngles, GetRandomFloat(RNGS_MinRadius[gameIdx], RNGS_MaxRadius[gameIdx]),
					GetRandomFloat(RNGS_MinSpeed[gameIdx], RNGS_MaxSpeed[gameIdx]), randomColor,
					1, RNGS_ShotType[gameIdx], GetRandomFloat(RNGS_MinParam1[gameIdx], RNGS_MaxParam1[gameIdx]),
					GetRandomFloat(RNGS_MinParam2[gameIdx], RNGS_MaxParam2[gameIdx]));
		}
	}
	
	// outside on purpose
	if (curTime >= RNGS_FakeAbilityEndsAt[gameIdx])
	{
		RNGS_FakeAbilityEndsAt[gameIdx] = FAR_FUTURE;
		DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
		DG_BossAbilityEnded(gameIdx);
	}
}

/**
 * Boss Ability: Projectile Freeze
 */
public PF_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		PF_ActiveThisGame[i] = false; // that's all, folks
	}
}

public PF_OnUse(gameIdx, Float:curTime)
{
	if (PF_Type[gameIdx] == PF_TYPE_ALL)
		DR_FreezeAllRockets(gameIdx, PF_Duration[gameIdx]);
	else if (PF_Type[gameIdx] == PF_TYPE_RADIUS)
	{
		static Float:point[3];
		GetEntPropVector(PF_Owner[gameIdx], Prop_Send, "m_vecOrigin", point);
		DR_FreezeAllRocketsRadius(gameIdx, PF_Duration[gameIdx], point, PF_Radius[gameIdx]);
	}
	else if (PF_Type[gameIdx] == PF_TYPE_RECT)
	{
		static Float:point[3];
		GetEntPropVector(PF_Owner[gameIdx], Prop_Send, "m_vecOrigin", point);
		static Float:rect[2][3];
		rect[0][0] = point[0] + PF_Rect[gameIdx][0][0];
		rect[0][1] = point[1] + PF_Rect[gameIdx][0][1];
		rect[0][2] = point[2] + PF_Rect[gameIdx][0][2];
		rect[1][0] = point[0] + PF_Rect[gameIdx][1][0];
		rect[1][1] = point[1] + PF_Rect[gameIdx][1][1];
		rect[1][2] = point[2] + PF_Rect[gameIdx][1][2];
		DR_FreezeAllRocketsRectangle(gameIdx, PF_Duration[gameIdx], rect[0], rect[1]);
	}
	
	// optional sound
	if (strlen(PF_Sound[gameIdx]) > 3)
	{
		EmitSoundToClient(PF_Owner[gameIdx], PF_Sound[gameIdx]);
		EmitSoundToClient(PF_Victim[gameIdx], PF_Sound[gameIdx]);
	}
	
	// over so soon?
	DG_BossAbilityEnded(gameIdx);
}

/**
 * Boss Ability: Projectile Freeze Delayed
 */
public PFD_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		PFD_ActiveThisGame[i] = false; // that's all, folks
	}
}

public PFD_OnUse(gameIdx, Float:curTime)
{
	PFD_UseAbilityAt[gameIdx] = curTime + PFD_Delay[gameIdx];
	
	// over so soon?
	DG_BossAbilityEnded(gameIdx);
}

PFD_Tick(gameIdx, Float:curTime)
{
	if (curTime < PFD_UseAbilityAt[gameIdx])
		return;

	PFD_UseAbilityAt[gameIdx] = FAR_FUTURE;
	if (PFD_Type[gameIdx] == PF_TYPE_ALL)
		DR_FreezeAllRockets(gameIdx, PFD_Duration[gameIdx]);
	else if (PFD_Type[gameIdx] == PF_TYPE_RADIUS)
	{
		static Float:point[3];
		GetEntPropVector(PFD_Owner[gameIdx], Prop_Send, "m_vecOrigin", point);
		DR_FreezeAllRocketsRadius(gameIdx, PFD_Duration[gameIdx], point, PFD_Radius[gameIdx]);
	}
	else if (PFD_Type[gameIdx] == PF_TYPE_RECT)
	{
		static Float:point[3];
		GetEntPropVector(PFD_Owner[gameIdx], Prop_Send, "m_vecOrigin", point);
		static Float:rect[2][3];
		rect[0][0] = point[0] + PFD_Rect[gameIdx][0][0];
		rect[0][1] = point[1] + PFD_Rect[gameIdx][0][1];
		rect[0][2] = point[2] + PFD_Rect[gameIdx][0][2];
		rect[1][0] = point[0] + PFD_Rect[gameIdx][1][0];
		rect[1][1] = point[1] + PFD_Rect[gameIdx][1][1];
		rect[1][2] = point[2] + PFD_Rect[gameIdx][1][2];
		DR_FreezeAllRocketsRectangle(gameIdx, PFD_Duration[gameIdx], rect[0], rect[1]);
	}
	
	// optional sound
	if (strlen(PFD_Sound[gameIdx]) > 3)
	{
		EmitSoundToClient(PFD_Owner[gameIdx], PFD_Sound[gameIdx]);
		EmitSoundToClient(PFD_Victim[gameIdx], PFD_Sound[gameIdx]);
	}
}

/**
 * Boss Ability: Rapid Randomized Bundle
 */
public RRB_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		RRB_ActiveThisGame[i] = false; // that's all, folks
	}
}

public RRB_OnUse(gameIdx, Float:curTime)
{
	RRB_AbilityEndsAt[gameIdx] = curTime + RRB_Duration[gameIdx];
	RRB_ProjectilesSpawned[gameIdx] = 0;
	DG_SetBossMoveSpeed(gameIdx, RRB_BossMoveSpeed[gameIdx]);
	
	PrintToServer("using for %f seconds", RRB_Duration[gameIdx]);
}

RRB_Tick(gameIdx, Float:curTime)
{
	if (!RRB_ActiveThisGame[gameIdx])
		return;
		
	if (RRB_AbilityEndsAt[gameIdx] != 0.0)
	{
		if (curTime >= RRB_AbilityEndsAt[gameIdx])
		{
			RRB_AbilityEndsAt[gameIdx] = 0.0;
			DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
			DG_BossAbilityEnded(gameIdx);
		}
		else
		{
			new projectilesExpected = RoundFloat(RRB_ShotsPerSecond[gameIdx] * (RRB_Duration[gameIdx] - (RRB_AbilityEndsAt[gameIdx] - curTime)));
			
			for (; RRB_ProjectilesSpawned[gameIdx] < projectilesExpected; RRB_ProjectilesSpawned[gameIdx]++)
			{
				// fire from feet, so the boss isn't blinded
				static Float:firePos[3];
				GetEntPropVector(RRB_Owner[gameIdx], Prop_Send, "m_vecOrigin", firePos);
				// 0.886 is roughly the multiplier to get a square that's the same area as a circle
				// using it for my cheaper "radius" substitute
				firePos[0] += GetRandomFloat(-RRB_MaxDistanceFromBoss[gameIdx], RRB_MaxDistanceFromBoss[gameIdx]) * 0.886;
				firePos[1] += GetRandomFloat(-RRB_MaxDistanceFromBoss[gameIdx], RRB_MaxDistanceFromBoss[gameIdx]) * 0.886;
				firePos[2] += GetRandomFloat(-RRB_MaxDistanceFromBoss[gameIdx], RRB_MaxDistanceFromBoss[gameIdx]) * 0.886;
				static Float:heroPos[3];
				DR_GetHeroHitPosition(gameIdx, heroPos);
				
				// get angles, synchronize random color/size, and send it off
				static Float:angles[3];
				GetVectorAnglesTwoPoints(firePos, heroPos, angles);
				new Float:randomVal = GetRandomFloat(0.0, 1.0);
				new Float:radius = RRB_MinRadius[gameIdx] + ((RRB_MaxRadius[gameIdx] - RRB_MinRadius[gameIdx]) * randomVal);
				new color = BlendColorOneFactor(RRB_MinColor[gameIdx], RRB_MaxColor[gameIdx], randomVal);
				DR_SpawnRocketAt(gameIdx, false, firePos, angles, radius, RRB_ShotSpeed[gameIdx],
					color, 1, RRB_ShotType[gameIdx], RRB_ShotParam1[gameIdx], RRB_ShotParam2[gameIdx], RRB_ShotLifetime[gameIdx]);
			}
		}
	}
}

/**
 * Persistent Patterned Shot
 */
public PPS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		PPS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public PPS_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	PPS_NextColumnAt[gameIdx] = curTime + PPS_StartDelay[gameIdx];
	PPS_ColumnsSpawned[gameIdx] = 0;
	DG_SetBossMoveSpeed(gameIdx, PPS_BossMoveSpeed[gameIdx]);
	
	// warning message if applicable
	if (!IsEmptyString(PPS_WarningText[gameIdx]))
		DG_SetWarningMessage(gameIdx, PPS_WarningText[gameIdx], PPS_WarningSound[gameIdx]);
}
 
PPS_Tick(gameIdx, Float:curTime)
{
	if (!PPS_ActiveThisGame[gameIdx])
		return;
	
	if (curTime >= PPS_NextColumnAt[gameIdx])
	{
		PPS_NextColumnAt[gameIdx] = curTime + PPS_ColumnDelay[gameIdx];
		if (PPS_MoveSpeedEndsWithAbility[gameIdx] && PPS_ColumnsSpawned[gameIdx] == 0)
		{
			DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
			DG_BossAbilityEnded(gameIdx);
		}
		
		// get dead center of the map
		static Float:rect[2][3];
		static Float:directionAngle[3];
		DG_GetWallMinMaxAndFiringAngle(gameIdx, DG_WALL_BEHIND_HERO, rect[0], rect[1], directionAngle);
		DG_GetArenaRectangle(gameIdx, rect);
		static Float:centerPos[3];
		centerPos[0] = (rect[0][0] + rect[1][0]) * 0.5;
		centerPos[1] = (rect[0][1] + rect[1][1]) * 0.5;
		centerPos[2] = (rect[0][2] + rect[1][2]) * 0.5;
		PrintToServer("centerpos=%f,%f,%f     distance=%f", centerPos[0], centerPos[1], centerPos[2], PPS_FBOffset[gameIdx]);
		
		for (new i = 0; i < PPS_NumSections[gameIdx]; i++)
		{
			if (i > 0)
				directionAngle[1] = fixAngle(directionAngle[1] + (360.0 / float(PPS_NumSections[gameIdx])));
			
			// find the best starting position. tracing a ray is easiest.
			static Float:startPos[3];
			TR_TraceRayFilter(centerPos, directionAngle, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
			TR_GetEndPosition(startPos);
			ConformLineDistance(startPos, centerPos, startPos, PPS_FBOffset[gameIdx], true);
			
			// get the firing angle and then simply spawn a column of them.
			static Float:firingAngle[3];
			firingAngle[0] = directionAngle[0];
			firingAngle[1] = directionAngle[1] + PPS_FBYawOffset[gameIdx];
			firingAngle[2] = 0.0;
			new Float:startZ = (centerPos[2] - (DG_EXPECTED_ARENA_HEIGHT * 0.5)) + PPS_Radius[gameIdx];
			for (new row = 0; row < PPS_RocketsPerColumn[gameIdx]; row++)
			{
				new Float:z = startZ + (float(row) * (PPS_Radius[gameIdx] * 2.0));
				static Float:rocketPos[3];
				CopyVector(rocketPos, startPos);
				rocketPos[2] = z;

				DR_SpawnRocketAt(gameIdx, false, rocketPos, firingAngle, PPS_Radius[gameIdx], PPS_ShotSpeed[gameIdx],
					PPS_ShotColor[gameIdx], 1, PPS_ShotType[gameIdx], PPS_ShotParam1[gameIdx], PPS_ShotParam2[gameIdx], PPS_ShotLifetime[gameIdx]);
			}
		}
		PPS_ColumnsSpawned[gameIdx]++;

		if (PPS_ColumnsSpawned[gameIdx] == PPS_NumColumns[gameIdx])
		{
			PPS_NextColumnAt[gameIdx] = FAR_FUTURE;
		
			if (!PPS_MoveSpeedEndsWithAbility[gameIdx])
			{
				DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
				DG_BossAbilityEnded(gameIdx);
			}
		}
	}
}

/**
 * Boss Ability: Clone Radial Shots
 */
public CRS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		CRS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public CRS_OnUse(gameIdx, Float:curTime)
{
	// try to fix model index with boss' current model
	// I don't do this in initialize because the model isn't applied yet
	if (CRS_ModelIdx[gameIdx] == -1)
	{
		static String:modelFile[MAX_MODEL_FILE_LENGTH];
		GetEntPropString(CRS_Owner[gameIdx], Prop_Data, "m_ModelName", modelFile, MAX_MODEL_FILE_LENGTH);
		if (strlen(modelFile) > 3)
			CRS_ModelIdx[gameIdx] = PrecacheModel(modelFile); // it's already precached, this just grabs the model identifier.
	}

	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	CRS_AbilityEndsAt[gameIdx] = curTime + CRS_Duration[gameIdx];
	CRS_NextVolleyAt[gameIdx] = curTime + CRS_VolleyInterval[gameIdx]; // give clones time to move away
	DG_SetBossMoveSpeed(gameIdx, CRS_BossMoveSpeed[gameIdx]);
	
	// spawn the clones now, which are actually just chaotic rockets that avoid the edge of the screen
	for (new i = 0; i < CRS_NumClones[gameIdx]; i++)
	{
		static Float:bossPos[3];
		GetEntPropVector(CRS_Owner[gameIdx], Prop_Send, "m_vecOrigin", bossPos);
		bossPos[0] += GetRandomFloat(-1.0, 1.0);
		bossPos[1] += GetRandomFloat(-1.0, 1.0);
		bossPos[2] += GetRandomFloat(-1.0, 1.0);
		static Float:angles[3];
		angles[0] = GetRandomFloat(-30.0, 30.0);
		angles[1] = GetRandomFloat(-179.9, 179.9);
		angles[2] = 0.0;
		
		new spawner = DS_SpawnSpawnerAt(gameIdx, false, bossPos, angles, CRS_CloneMoveSpeed[gameIdx], CRS_ModelIdx[gameIdx], DS_MOVE_CHAOTIC, CRS_CloneTurnSpeed[gameIdx],
				0.0, DS_SPAWN_RADIAL_TARGET, CRS_VolleyInterval[gameIdx], float(CRS_ShotsPerVolley[gameIdx]), CRS_Duration[gameIdx], DR_FLAG_BOMB_PROOF | DR_FLAG_DISPOSE_PITCH);
		if (spawner != -1)
			DS_SetSpawnerProjectileParams(gameIdx, CRS_ShotRadius[gameIdx], CRS_ShotColor[gameIdx], CRS_ShotSpeed[gameIdx], 0);
	}
}
 
CRS_Tick(gameIdx, Float:curTime)
{
	if (!CRS_ActiveThisGame[gameIdx])
		return;
	
	if (CRS_AbilityEndsAt[gameIdx] != 0.0)
	{
		if (curTime >= CRS_AbilityEndsAt[gameIdx])
		{
			// chances are, clones have already despawned, or will at the end of the frame. so just do typical "end" things
			CRS_AbilityEndsAt[gameIdx] = 0.0;
			DG_SetBossMoveSpeed(gameIdx, -1.0); // fix boss move speed when ability is reported as ended
			DG_BossAbilityEnded(gameIdx);
		}
		else if (curTime >= CRS_NextVolleyAt[gameIdx])
		{
			// clones are managed by the core. but this plugin still needs to manage the player's shots.
			CRS_NextVolleyAt[gameIdx] = curTime + CRS_VolleyInterval[gameIdx];
			static Float:heroPos[3];
			DR_GetHeroHitPosition(gameIdx, heroPos);
			static Float:spawnPos[3];
			DR_GetDefaultFiringPosition(CRS_Owner[gameIdx], spawnPos);
				
			static Float:angles[3];
			GetVectorAnglesTwoPoints(spawnPos, heroPos, angles);
			static Float:adjustedSpawnPos[3];
			for (new i = 0; i < CRS_ShotsPerVolley[gameIdx]; i++)
			{
				if (i != 0)
					angles[1] += 360.0 / float(CRS_ShotsPerVolley[gameIdx]);

				// must offset first to prevent rockets from spawning on top of each other
				CopyVector(adjustedSpawnPos, spawnPos);
				adjustedSpawnPos[0] += GetRandomFloat(-1.0, 1.0);
				adjustedSpawnPos[1] += GetRandomFloat(-1.0, 1.0);
				adjustedSpawnPos[2] += GetRandomFloat(-1.0, 1.0);

				// now spawn!
				DR_SpawnRocketAt(gameIdx, false, adjustedSpawnPos, angles, CRS_ShotRadius[gameIdx], CRS_ShotSpeed[gameIdx],
					CRS_ShotColor[gameIdx], 1, CRS_ShotType[gameIdx], CRS_Param1[gameIdx], CRS_Param2[gameIdx]);
			}
		}
	}
}

/**
 * Boss Ability: Beam Grid
 */
public BG_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		BG_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public BG_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	BG_AbilityStartedAt[gameIdx] = curTime;
	BG_AbilityEndsAt[gameIdx] = curTime + BG_Duration[gameIdx];
	BG_NextBeamsAt[gameIdx] = curTime + DB_STANDARD_INTERVAL; // can't really draw a 0 width beam immediately
	BG_ProjectilesSpawned[gameIdx] = 0;
	
	if (BG_AllowConcurrentAbilities[gameIdx])
		DG_BossAbilityEnded(gameIdx);
	else
		DG_SetBossMoveSpeed(gameIdx, BG_BossMoveSpeed[gameIdx]);
}

BG_Tick(gameIdx, Float:curTime)
{
	if (!BG_ActiveThisGame[gameIdx] || BG_AbilityEndsAt[gameIdx] == 0.0)
		return;
	
	if (curTime >= BG_AbilityEndsAt[gameIdx])
	{
		BG_AbilityEndsAt[gameIdx] = 0.0;
		
		if (!BG_AllowConcurrentAbilities[gameIdx])
		{
			DG_BossAbilityEnded(gameIdx);
			DG_SetBossMoveSpeed(gameIdx, -1.0);
		}
		return;
	}
	
	new projectilesExpected = max(RoundFloat(BG_ShotsPerSecond[gameIdx] * ((BG_Duration[gameIdx] - BG_ImmunityDuration[gameIdx]) - (BG_AbilityEndsAt[gameIdx] - curTime))), 0);
	new projectilesToSpawn = projectilesExpected - BG_ProjectilesSpawned[gameIdx];
	new bool:shouldDrawBeams = curTime >= BG_NextBeamsAt[gameIdx];
	if (!shouldDrawBeams && projectilesToSpawn <= 0)
		return;
	
	BG_ProjectilesSpawned[gameIdx] = projectilesExpected;
	if (shouldDrawBeams)
		BG_NextBeamsAt[gameIdx] = curTime + DB_STANDARD_INTERVAL;
		
	// sudden style change +5, I didn't feel like having gobs of indentation
	// first of all, we need to find out axis is forward/back and plan accordingly
	static Float:arenaRect[2][3];
	static Float:heroForwardAngle[3];
	DG_GetWallMinMaxAndFiringAngle(gameIdx, DG_WALL_BEHIND_BOSS, arenaRect[0], arenaRect[1], heroForwardAngle);
	new bool:heroForwardIsX = fixAngle(heroForwardAngle[1]) == fixAngle(0.0) || fixAngle(heroForwardAngle[1]) == fixAngle(180.0);
	
	// also, get the battlefield rect and filter out the typical padding
	DG_GetArenaRectangle(gameIdx, arenaRect);
	new Float:boundsOffset = (DC_DESPAWN_RANGE + DC_RECOMMENDED_BUFFER);
	arenaRect[0][0] += boundsOffset;
	arenaRect[0][1] += boundsOffset;
	arenaRect[0][2] += boundsOffset;
	arenaRect[1][0] -= boundsOffset;
	arenaRect[1][1] -= boundsOffset;
	arenaRect[1][2] -= boundsOffset;
	
	// the beam width factor also determines if the beam is harmful or not
	new Float:beamWidthFactor = 1.0;
	if (BG_ImmunityDuration[gameIdx] > 0.0 && curTime - BG_AbilityStartedAt[gameIdx] < BG_ImmunityDuration[gameIdx])
		beamWidthFactor = (curTime - BG_AbilityStartedAt[gameIdx]) / BG_ImmunityDuration[gameIdx];
	new Float:beamRadius = BG_BeamRadius[gameIdx] * beamWidthFactor;
	
	// now we have to spawn beams on each of the dominant axis
	new totalCount; // used for determining which beam to spawn the projectile on
	new spawnProjectilesAt = GetRandomInt(0, BG_NumBeams[gameIdx]);
	for (new axis = 0; axis <= 2; axis++) // fb, lr, z
	{
		new dominantAxis = -1;
		new supportAxis1 = -1;
		new supportAxis2 = -1;
		new supportCount1;
		new supportCount2;
		if (axis == 0)
		{
			dominantAxis = heroForwardIsX ? 0 : 1;
			supportAxis1 = heroForwardIsX ? 1 : 0;
			supportAxis2 = 2;
			supportCount1 = BG_FBBeamsOnLR[gameIdx];
			supportCount2 = BG_FBBeamsOnZ[gameIdx];
		}
		else if (axis == 1)
		{
			dominantAxis = heroForwardIsX ? 1 : 0;
			supportAxis1 = heroForwardIsX ? 0 : 1;
			supportAxis2 = 2;
			supportCount1 = BG_LRBeamsOnFB[gameIdx];
			supportCount2 = BG_LRBeamsOnZ[gameIdx];
		}
		else
		{
			dominantAxis = 2;
			supportAxis1 = heroForwardIsX ? 0 : 1;
			supportAxis2 = heroForwardIsX ? 1 : 0;
			supportCount1 = BG_ZBeamsOnFB[gameIdx];
			supportCount2 = BG_ZBeamsOnLR[gameIdx];
		}
		
		// start with 
		for (new i = 0; i < supportCount1; i++)
		{
			new Float:support1Pos = arenaRect[0][supportAxis1] + ((arenaRect[1][supportAxis1] - arenaRect[0][supportAxis1]) / float(supportCount1)) * (float(i) + 0.5);
			for (new j = 0; j < supportCount2; j++)
			{
				new Float:support2Pos = arenaRect[0][supportAxis2] + ((arenaRect[1][supportAxis2] - arenaRect[0][supportAxis2]) / float(supportCount2)) * (float(j) + 0.5);
				static Float:beamMin[3];
				static Float:beamMax[3];
				beamMin[dominantAxis] = arenaRect[0][dominantAxis] - boundsOffset;
				beamMax[dominantAxis] = arenaRect[1][dominantAxis] + boundsOffset;
				beamMin[supportAxis1] = beamMax[supportAxis1] = support1Pos;
				beamMin[supportAxis2] = beamMax[supportAxis2] = support2Pos;
				
				if (shouldDrawBeams)
					DB_SpawnBeam(gameIdx, false, beamMin, beamMax, beamRadius, BG_BeamColor[gameIdx], 1, beamWidthFactor < 1.0 ? DB_FLAG_HARMLESS : 0);
				
				if (spawnProjectilesAt == totalCount)
				{
					for (new blah = 0; blah < projectilesToSpawn; blah++)
					{
						static Float:spawnPos[3];
						spawnPos[dominantAxis] = GetRandomFloat(arenaRect[0][dominantAxis], arenaRect[1][dominantAxis]);
						spawnPos[supportAxis1] = support1Pos;
						spawnPos[supportAxis2] = support2Pos;
						static Float:heroPos[3];
						DR_GetHeroHitPosition(gameIdx, heroPos);
						static Float:angles[3];
						GetVectorAnglesTwoPoints(spawnPos, heroPos, angles);
	
						DR_SpawnRocketAt(gameIdx, false, spawnPos, angles, BG_ShotRadius[gameIdx], BG_ShotSpeed[gameIdx],
							BG_ShotColor[gameIdx], 1, BG_ShotType[gameIdx], BG_ShotParam1[gameIdx], BG_ShotParam2[gameIdx]);
					}
				}
				
				// total count increased, used for spawning the projectiles
				totalCount++;
			}
		}
	}
}

/**
 * Boss Ability: Follow Spawn Shot
 */
public FSS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		FSS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public FSS_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	FSS_AbilityEndsAt[gameIdx] = curTime + FSS_Duration[gameIdx] + FSS_StartDelay[gameIdx];
	FSS_LastTime[gameIdx] = curTime + FSS_StartDelay[gameIdx];
	DR_GetDefaultFiringPosition(FSS_Owner[gameIdx], FSS_LastPosition[gameIdx]);
	FSS_ProjectilesSpawned[gameIdx] = 0;
	
	if (FSS_AllowConcurrentAbilities[gameIdx])
		DG_BossAbilityEnded(gameIdx);
	else
		DG_SetBossMoveSpeed(gameIdx, FSS_BossMoveSpeed[gameIdx]);
}

FSS_Tick(gameIdx, Float:curTime)
{
	if (!FSS_ActiveThisGame[gameIdx] || FSS_AbilityEndsAt[gameIdx] == 0.0)
		return;
	
	if (curTime >= FSS_AbilityEndsAt[gameIdx])
	{
		FSS_AbilityEndsAt[gameIdx] = 0.0;
		if (!FSS_AllowConcurrentAbilities[gameIdx])
		{
			DG_BossAbilityEnded(gameIdx);
			DG_SetBossMoveSpeed(gameIdx, -1.0);
		}
		return;
	}
	
	// it makes no sense to spawn multiple projectiles at once
	new projectilesExpected = RoundFloat(FSS_ShotsPerSecond[gameIdx] * (FSS_Duration[gameIdx] - (FSS_AbilityEndsAt[gameIdx] - curTime)));
	if (projectilesExpected <= FSS_ProjectilesSpawned[gameIdx])
		return;
	FSS_ProjectilesSpawned[gameIdx] = projectilesExpected;
	
	// advance the position of our spawn location
	new Float:deltaTime = curTime - FSS_LastTime[gameIdx];
	static Float:spawnPos[3];
	static Float:heroPos[3];
	DR_GetHeroHitPosition(gameIdx, heroPos);
	static Float:angles[3];
	GetVectorAnglesTwoPoints(FSS_LastPosition[gameIdx], heroPos, angles);
	TR_TraceRayFilter(FSS_LastPosition[gameIdx], angles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(spawnPos);
	ConformLineDistance(spawnPos, FSS_LastPosition[gameIdx], spawnPos, FSS_StalkingSpeed[gameIdx] * deltaTime, true);
	
	// create the rocket and save our spawn position/time
	DR_SpawnRocketAt(gameIdx, false, spawnPos, angles, FSS_ShotRadius[gameIdx], FSS_ShotSpeed[gameIdx],
			FSS_ShotColor[gameIdx], 1, FSS_ShotType[gameIdx], FSS_ShotParam1[gameIdx], FSS_ShotParam2[gameIdx], 0.0, FSS_IsSilent[gameIdx] ? DR_FLAG_NO_SHOT_SOUND : 0);
	FSS_LastTime[gameIdx] = curTime;
	CopyVector(FSS_LastPosition[gameIdx], spawnPos);
}

/**
 * Boss Ability: Mapwide Ripple Shots
 */
public MRS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		MRS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public MRS_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	MRS_AbilityEndsAt[gameIdx] = curTime + MRS_Duration[gameIdx];
	if (MRS_BossRippleInterval[gameIdx] <= 0.0)
		MRS_NextBossRippleAt[gameIdx] = FAR_FUTURE;
	else
		MRS_NextBossRippleAt[gameIdx] = curTime + MRS_BossRippleInterval[gameIdx];

	if (MRS_RandomRippleInterval[gameIdx] <= 0.0)
		MRS_NextRandomRippleAt[gameIdx] = FAR_FUTURE;
	else
		MRS_NextRandomRippleAt[gameIdx] = curTime + MRS_RandomRippleInterval[gameIdx];
	
	DG_SetBossMoveSpeed(gameIdx, MRS_BossMoveSpeed[gameIdx]);
}

MRS_Tick(gameIdx, Float:curTime)
{
	if (!MRS_ActiveThisGame[gameIdx] || MRS_AbilityEndsAt[gameIdx] == 0.0)
		return;
		
	if (curTime >= MRS_AbilityEndsAt[gameIdx])
	{
		MRS_AbilityEndsAt[gameIdx] = 0.0;
		DG_BossAbilityEnded(gameIdx);
		DG_SetBossMoveSpeed(gameIdx, -1.0);
		return;
	}
		
	new bool:randomRipple = curTime >= MRS_NextRandomRippleAt[gameIdx];
	new bool:bossRipple = curTime >= MRS_NextBossRippleAt[gameIdx];
	if (!randomRipple && !bossRipple)
		return;
	
	if (randomRipple)
		MRS_NextRandomRippleAt[gameIdx] = curTime + MRS_RandomRippleInterval[gameIdx];
	if (bossRipple)
		MRS_NextBossRippleAt[gameIdx] = curTime + MRS_BossRippleInterval[gameIdx];
		
	// going in two passes for code efficiency
	for (new pass = 0; pass < 2; pass++)
	{
		static Float:centerPos[3];
		if (pass == 0)
		{
			if (!bossRipple)
				continue;
				
			DR_GetDefaultFiringPosition(MRS_Owner[gameIdx], centerPos);
		}
		else
		{
			if (!randomRipple)
				continue;
				
			// try up to (sanity limit) to spawn a ripple far enough from the hero, fall back to the owner
			static Float:heroPos[3];
			DR_GetHeroHitPosition(gameIdx, heroPos);
			new bool:found = false;
			
			// arena rect has to be adjusted
			static Float:arenaRect[2][3];
			DG_GetArenaRectangle(gameIdx, arenaRect);
			new Float:boundsOffset = (DC_DESPAWN_RANGE + 10);
			arenaRect[0][0] += boundsOffset;
			arenaRect[0][1] += boundsOffset;
			arenaRect[0][2] += boundsOffset;
			arenaRect[1][0] -= boundsOffset;
			arenaRect[1][1] -= boundsOffset;
			arenaRect[1][2] -= boundsOffset;
			new Float:distanceSquared = MRS_RandomMinDistance[gameIdx] * MRS_RandomMinDistance[gameIdx];
			for (new sanity = 0; sanity < 50; sanity++)
			{
				centerPos[0] = GetRandomFloat(arenaRect[0][0], arenaRect[1][0]);
				centerPos[1] = GetRandomFloat(arenaRect[0][1], arenaRect[1][1]);
				centerPos[2] = GetRandomFloat(arenaRect[0][2], arenaRect[1][2]);
				
				if (GetVectorDistance(heroPos, centerPos, true) >= distanceSquared)
				{
					found = true;
					break;
				}
			}
			
			if (!found)
			{
				if (PRINT_DEBUG_INFO)
					PrintToServer("[df_default_abilities] %s sanity limit reached. Falling back on boss pos.", MRS_STRING);
				DR_GetDefaultFiringPosition(MRS_Owner[gameIdx], centerPos);
			}
		}
		
		// now just get the ideal angle for the first shot and go around the yaw
		static Float:angles[3];
		DG_GetAngleToHero(gameIdx, centerPos, angles);
		for (new shot = 0; shot < MRS_ShotsPerRipple[gameIdx]; shot++)
		{
			if (shot > 0)
				angles[1] += 360 / float(MRS_ShotsPerRipple[gameIdx]);
			
			// must randomly offset slightly or rockets will explode on each other
			static Float:tmpPos[3];
			tmpPos[0] = centerPos[0] + GetRandomFloat(-1.0, 1.0);
			tmpPos[1] = centerPos[1] + GetRandomFloat(-1.0, 1.0);
			tmpPos[2] = centerPos[2] + GetRandomFloat(-1.0, 1.0);

			DR_SpawnRocketAt(gameIdx, false, tmpPos, angles, MRS_ShotRadius[gameIdx], MRS_ShotSpeed[gameIdx],
					MRS_ShotColor[gameIdx], 1, MRS_ShotType[gameIdx], MRS_ShotParam1[gameIdx], MRS_ShotParam2[gameIdx]);
		}
	}
}

/**
 * Boss Ability: Rotating Beam Wall
 */
public RBW_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		RBW_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public RBW_OnUse(gameIdx, Float:curTime)
{
	// typical for boss abilities, will just trigger the beginning. the managed game frame will pick it up from there.
	RBW_RotationStartsAt[gameIdx] = curTime + RBW_SetupDuration[gameIdx];
	RBW_RampUpRedrawAt[gameIdx] = curTime + DB_STANDARD_INTERVAL;
	RBW_RotationEndsAt[gameIdx] = RBW_RotationStartsAt[gameIdx] + RBW_RotateDuration[gameIdx];
	RBW_NextRedrawAt[gameIdx] = RBW_RotationStartsAt[gameIdx];
	RBW_ProjectilesSpawned[gameIdx] = 0;
	DG_SetBossMoveSpeed(gameIdx, RBW_BOSS_MOVE_SPEED);

	// starting yaw depends on boss eye angles
	static Float:eyeAngles[3];
	GetClientEyeAngles(RBW_Owner[gameIdx], eyeAngles);
	RBW_StartingYaw[gameIdx] = eyeAngles[1];
}

RBW_Tick(gameIdx, Float:curTime)
{
	if (!RBW_ActiveThisGame[gameIdx] || RBW_RotationEndsAt[gameIdx] == 0.0)
		return;
		
	if (curTime >= RBW_RotationEndsAt[gameIdx])
	{
		RBW_RotationEndsAt[gameIdx] = 0.0;
		DG_BossAbilityEnded(gameIdx);
		DG_SetBossMoveSpeed(gameIdx, -1.0);

		// set up the next alternation
		if (RBW_RotationDirection[gameIdx] == RBW_DIR_ALTERNATING)
			RBW_LastWasCCW[gameIdx] = !RBW_LastWasCCW[gameIdx];

		return;
	}
	
	// first, draw the main harmless beam
	static Float:arenaRect[2][3];
	DG_GetArenaRectangle(gameIdx, arenaRect);
	new Float:boundsOffset = (DC_DESPAWN_RANGE + DC_RECOMMENDED_BUFFER);
	arenaRect[0][2] += boundsOffset;
	arenaRect[1][2] -= boundsOffset;
	new Float:firstBeamZ = arenaRect[0][2] + (RBW_BeamRadius[gameIdx] * 0.5);
	static Float:startPos[3];
	static Float:endPos[3];
	static Float:angles[3];
	angles[0] = angles[2] = 0.0;
	angles[1] = RBW_StartingYaw[gameIdx];
	GetEntPropVector(RBW_Owner[gameIdx], Prop_Send, "m_vecOrigin", startPos);
	startPos[2] = firstBeamZ;
	if (curTime < RBW_RotationStartsAt[gameIdx])
	{
		if (RBW_SetupDuration[gameIdx] <= 0.0 || curTime < RBW_RampUpRedrawAt[gameIdx])
			return;
			
		new Float:beamWidthMultiplier = (1.0 - (RBW_RotationStartsAt[gameIdx] - curTime)) / RBW_SetupDuration[gameIdx];
		if (beamWidthMultiplier <= 0.0)
			return;

		TR_TraceRayFilter(startPos, angles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
		TR_GetEndPosition(endPos);
		ConformLineDistance(endPos, startPos, endPos, RBW_BeamDistance[gameIdx], true);
		for (new i = 0; i < RBW_BeamsToSpawn[gameIdx]; i++)
		{
			DB_SpawnBeam(gameIdx, false, startPos, endPos, RBW_BeamRadius[gameIdx] * beamWidthMultiplier, RBW_BeamColor[gameIdx], 1, DB_FLAG_HARMLESS);
			startPos[2] += RBW_BeamRadius[gameIdx] * 2;
			endPos[2] += RBW_BeamRadius[gameIdx] * 2;
		}
		RBW_RampUpRedrawAt[gameIdx] = curTime + DB_STANDARD_INTERVAL;
		return;
	}
	
	// how many projectiles do we spawn from this redraw?
	new bool:shouldDraw = false;
	if (curTime >= RBW_NextRedrawAt[gameIdx])
	{
		RBW_NextRedrawAt[gameIdx] = curTime + RBW_REDRAW_INTERVAL;
		shouldDraw = true;
	}
	
	// angle depends on rotation direction
	new Float:deltaAngle = 360.0 * (1.0 - ((RBW_RotationEndsAt[gameIdx] - curTime) / RBW_RotateDuration[gameIdx]));
	new bool:isCCW = RBW_RotationDirection[gameIdx] == RBW_DIR_CCW || (RBW_RotationDirection[gameIdx] == RBW_DIR_ALTERNATING && !RBW_LastWasCCW[gameIdx]);
	if (isCCW)
		angles[1] = fixAngle(angles[1] + deltaAngle);
	else
		angles[1] = fixAngle(angles[1] - deltaAngle);

	// draw the harmful, full sized beams
	TR_TraceRayFilter(startPos, angles, (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE), RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	ConformLineDistance(endPos, startPos, endPos, RBW_BeamDistance[gameIdx], true);
	for (new i = 0; i < RBW_BeamsToSpawn[gameIdx]; i++)
	{
		DB_SpawnBeam(gameIdx, false, startPos, endPos, RBW_BeamRadius[gameIdx], RBW_BeamColor[gameIdx], 1, shouldDraw ? 0 : DB_FLAG_NO_RENDER);
		startPos[2] += RBW_BeamRadius[gameIdx] * 2;
		endPos[2] += RBW_BeamRadius[gameIdx] * 2;
	}
	
	// finally, make the shots that come from them
	new projectilesExpected = RoundFloat(RBW_ProjectilesPerSecond[gameIdx] * (RBW_RotateDuration[gameIdx] - (RBW_RotationEndsAt[gameIdx] - curTime)));
	if (projectilesExpected <= RBW_ProjectilesSpawned[gameIdx])
		return;
	new shotCount = projectilesExpected - RBW_ProjectilesSpawned[gameIdx];
	RBW_ProjectilesSpawned[gameIdx] = projectilesExpected;
	
	for (new i = 0; i < shotCount; i++)
	{
		static Float:shotAngle[3];
		CopyVector(shotAngle, angles);
		shotAngle[1] += GetRandomFloat(-RBW_AngleVariance[gameIdx], RBW_AngleVariance[gameIdx]);
		if (isCCW)
			shotAngle[1] += 90.0;
		else
			shotAngle[1] -= 90.0;
		
		new Float:lineCut = GetRandomFloat(0.0, 1.0);
		static Float:spawnPoint[3];
		spawnPoint[0] = startPos[0] + ((endPos[0] - startPos[0]) * lineCut);
		spawnPoint[1] = startPos[1] + ((endPos[1] - startPos[1]) * lineCut);
		spawnPoint[2] = GetRandomFloat(arenaRect[0][2], arenaRect[1][2]);

		DR_SpawnRocketAt(gameIdx, false, spawnPoint, shotAngle, RBW_ShotRadiusStatic[gameIdx], RBW_ShotSpeed[gameIdx],
				RBW_ShotColor[gameIdx], 1, RBW_ShotType[gameIdx], RBW_ShotParam1[gameIdx], RBW_ShotParam2[gameIdx], 0.0, DR_FLAG_OOB_NO_WARN);
	}
}

/**
 * Boss Ability: Expanding Rotating Radial
 */
public ERR_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		ERR_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public ERR_OnUse(gameIdx, Float:curTime)
{
	DG_BossAbilityEnded(gameIdx);

	static Float:spawnPos[3];
	DR_GetDefaultFiringPosition(ERR_Owner[gameIdx], spawnPos);
	static Float:eyeAngles[3];
	GetClientEyeAngles(ERR_Owner[gameIdx], eyeAngles);
	if (ERR_IgnorePitch[gameIdx])
		eyeAngles[0] = 0.0;
	if (ERR_ApexYawVariance[gameIdx] > 0.0)
		eyeAngles[1] = fixAngle(eyeAngles[1] + GetRandomFloat(-ERR_ApexYawVariance[gameIdx], ERR_ApexYawVariance[gameIdx]));
		
	// spawn rows and columns of projectiles, much like with Cirno's ability
	new Float:startZ = spawnPos[2] - (float(ERR_ShotsZ[gameIdx]) * ERR_RowZOffset[gameIdx] * 0.5);
	for (new i = 0; i < ERR_ShotsXY[gameIdx]; i++)
	{
		spawnPos[2] = startZ;
		new Float:yawOffset = fixAngle(360.0 * float(i) / float(ERR_ShotsXY[gameIdx]));
		yawOffset += eyeAngles[1];
		yawOffset = (yawOffset < 0.0) ? (yawOffset + 360.0) : yawOffset;
		new Float:timeOffset = (yawOffset / 360.0) * (360.0 / ERR_ShotParam1[gameIdx]);
		for (new j = 0; j < ERR_ShotsZ[gameIdx]; j++)
		{
			DR_SpawnRocketAt(gameIdx, false, spawnPos, eyeAngles, ERR_ShotRadius[gameIdx], ERR_ShotSpeed[gameIdx], ERR_ShotColor[gameIdx], 1,
					ERR_ShotType[gameIdx], ERR_ShotParam1[gameIdx], ERR_ShotParam2[gameIdx], 0.0, ERR_RotateCCW[gameIdx] ? DR_FLAG_ANGLE_CCW : 0);
			spawnPos[2] += ERR_RowZOffset[gameIdx];
			
			// need one additional variable for rocket angle: time in current rotation
			// without this, the apexes will always be synchronized for all projectiles in the ring (the ring will bounce up and down)
			DR_SetInternalParams(gameIdx, timeOffset);
		}
	}
}

/**
 * Boss Ability: Drop One Spawner
 */
public DOS_Cleanup(gameIdx)
{
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		if (gameIdx != -1 && gameIdx != i)
			continue;
		DOS_ActiveThisGame[i] = false; // that's all, folks
	}
}
 
public DOS_OnUse(gameIdx, Float:curTime)
{
	DG_BossAbilityEnded(gameIdx);
	
	static Float:spawnPos[3];
	DR_GetDefaultFiringPosition(DOS_Owner[gameIdx], spawnPos);
	static Float:angles[3];
	GetClientEyeAngles(DOS_Owner[gameIdx], angles);

	new spawner = DS_SpawnSpawnerAt(gameIdx, false, spawnPos, angles, DOS_SpawnerSpeed[gameIdx], DOS_SpawnerModelIdx[gameIdx], DOS_SpawnerMovePattern[gameIdx],
			DOS_SpawnerMoveParam1[gameIdx], DOS_SpawnerMoveParam2[gameIdx], DOS_SpawnerSpawnPattern[gameIdx], DOS_SpawnerSpawnInterval[gameIdx], DOS_SpawnerSpawnParam1[gameIdx],
			DOS_SpawnerLifetime[gameIdx], DOS_IsBombProof[gameIdx] ? DR_FLAG_BOMB_PROOF : 0);
	if (spawner != -1)
		DS_SetSpawnerProjectileParams(gameIdx, DOS_ShotRadius[gameIdx], DOS_ShotColor[gameIdx], DOS_ShotSpeed[gameIdx], 0);
}
