/**
 * Danmaku Fortress
 *
 * A simple one-on-mode code where the boss tons of projectiles but has weak mobility and a life bar.
 * The player (ala Reimu Hakurei) has fewer projectiles, a score counter, and other features straight from Touhou.
 *
 * Depends:
 * - SDKHooks
 * - morecolors.inc
 *
 * Interacts well with these plugins:
 * - Thirdperson so veterans from other mods can use the /tp and /fp commands. Third person is highly recommended for heroes.
 *
 * Interacts badly with these plugins:
 * - Instant respawn (absolutely will screw up this plugin), however TF2's not-so-instant respawn should be fine, since it's actually a 4 or so second delay.
 * - Any aggressive auto-balance plugin which also targets the living (will cause players to forfeit), TF2's autobalance is already disabled for this reason.
 * - Class limit plugins could be a problem, since all combatants are forced pyro.
 * - Any plugin that prevents OnMapStart() from executing. (i.e. a quarantine system -- not needed for this plugin, it auto-quarantines)
 * - Freak Fortress 2 needs to be quarantined as it can interfere with the spawn/team assignment code and stop matches before they can start.
 *
 * Main Credits:
 * - Code and concept by sarysa
 * - Heavily influenced by SHADoW and his Blitzkrieg FF2 boss, plus I got the idea for this while we "dueled" flying around in noclip.
 * - Also influenced to a small degree by Freak Fortress 2, most notably with the config file designs, Kv code, and some of my stocks.
 * - Rocket spawning code derived from Asherkin's from his Dodgeball plugin, with contributions from voogru
 * - Beam spawning code derived from JasonFrog's IonAttack for FF2. (at least I think it was, specific bits of Phat Rages are unsigned)
 * - Obviously also heavily influenced by Touhou Project by ZUN
 *
 * Asset Credits:
 * - Dart Mann added a fix to my crappy demo map (touhou_duel) which prevents players from spawning in the player_clip area.
 *           (sadly it still breaks after one person spawns in, so I had to include a code solution as well which kicks in after the pre-round)
 * - Reimu model by Nya
 * - Cirno model also by Nya
 * - Flandre model by Ciel
 * - All models so far were ported to GMod by 1337gamer15 (I grabbed them from Kenji-kun's collection)
 * - sarysa made Reimu's crappy gohei which looks more like a staff with a pennant at the end.
 * - sarysa also added basic animated poses to Cirno and Reimu, and fixed some of the seam and bad texture param issues. (those not directly caused by UV mapping)
 * - Music by ZUN and various remixers of his work.
 *
 * Special Thanks:
 * - BBG community for allowing me use of their development server for playtesting.
 *
 * Known Issues:
 * - Very rarely, players might get stuck under the map. (usually happens when changing teams) Switching in and out of spectate can fix this.
 * - People with a sharp eye might notice the hero's projectiles have a larger hitbox than they should. This is by design, to make it easier for the hero to see. It's also a cvar.
 * - DO NOT ADD TF2 MUSIC to the music player unless you rip it and give it a new path. Some TF2 songs are hardcoded to automatically loop on their own, which will cause songs to quickly stack.
 *
 * ConVars Changed:
 * - mp_autoteambalance and mp_teams_unbalance_limit are changed so TF2's autobalance doesn't render DF unusable, but only on maps where DF is active.
 */

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0"

#include <danmaku_fortress>
#include <clientprefs>

new bool:PRINT_DEBUG_INFO = true;
new bool:PRINT_DEBUG_SPAM = true;

// if the below is true, any server admin can do things like force their opponent to use their ability
new bool:DEBUG_MODE_ENABLED = false;

public Plugin:myinfo = {
	name = "Danmaku Fortress",
	description = "3D Bullet Hell near-TC mod for TF2",
	author = "sarysa",
	version = PLUGIN_VERSION,
}

/**
 * Commands
 */
#define CMD_NEVER "df_never"
#define CMD_WANT_BOSS "df_wantboss"
#define CMD_WANT_HERO "df_wanthero"
#define CMD_WANT_ANY "df_wantany"
#define CMD_BOSS "df_boss"
#define CMD_HERO "df_hero"
#define CMD_QUEUE "df_queue"
#define CMD_MUSIC "df_music"
#define CMD_TP "df_tp"
#define CMD_FP "df_fp"
#define CMD_HELP "df"
#define CMD_TUTORIAL "df_tutorial"
#define CMD_DIFFICULTY "df_difficulty"
#define CMD_AUTOFIRE "df_autofire"
// admin commands
#define CMD_CVARS "df_cvars"
#define CMD_BOTLOGIC "df_botlogic"
#define CMD_ADDPOINTS "df_addpoints"
#define CMD_ADMINWORKAROUND "df_amianadmin" // this is absolutely ridiculous, but user bits (ADMFLAG_xxxxx) and CheckCommandAccess don't work properly. gah.
#define CMD_FORCEHERO "df_forcehero"
#define CMD_FORCEBOSS "df_forceboss"
// debug mode commands
#define CMD_FORCEFIRE "df_forceenemyfire"
#define CMD_ITERATE "df_forceiterate"
// aliases for existing commands
#define DF_GENERIC1 "df_help"
#define DF_GENERIC2 "danmaku"
#define DF_GENERIC3 "touhou"

/**
 * Character Config
 *
 * Note that character configs are loaded as needed. However, the character lists are loaded at startup.
 */
#define CC_MAX_ABILITIES 16
new String:CC_PARAM_NAME[MAX_KEY_NAME_LENGTH] = "name";
new String:CC_PARAM_TYPE[MAX_KEY_NAME_LENGTH] = "type";
new String:CC_PARAM_HITBOX[MAX_KEY_NAME_LENGTH] = "boss_hitbox";
new String:CC_PARAM_HEALTH[MAX_KEY_NAME_LENGTH] = "boss_health";
new String:CC_PARAM_PHASES[MAX_KEY_NAME_LENGTH] = "boss_phases";
new String:CC_PARAM_ABILITY_DELAY[MAX_KEY_NAME_LENGTH] = "ability_delay";
new String:CC_PARAM_LIVES[MAX_KEY_NAME_LENGTH] = "hero_lives";
new String:CC_PARAM_BOMBS[MAX_KEY_NAME_LENGTH] = "hero_bombs";
new String:CC_PARAM_MODEL[MAX_KEY_NAME_LENGTH] = "model";
new String:CC_PARAM_MOVE_SPEED[MAX_KEY_NAME_LENGTH] = "movespeed";
new String:CC_PARAM_ACCESS[MAX_KEY_NAME_LENGTH] = "access_limit";
new String:CC_PARAM_MUSIC[MAX_KEY_NAME_LENGTH] = "music";
new String:CC_PARAM_POINT_ADJUST[MAX_KEY_NAME_LENGTH] = "point_adjust";
#define CC_PARAM_RESDIR_FORMAT "resdir%d"

/**
 * Character Abilities
 */
new String:CA_PARAM_NAME[MAX_KEY_NAME_LENGTH] = "ability_name";
new String:CA_PARAM_FILENAME[MAX_KEY_NAME_LENGTH] = "source";
new String:CA_PARAM_AESTHETIC_NAME[MAX_KEY_NAME_LENGTH] = "name";
new String:CA_PARAM_DESCRIPTION[MAX_KEY_NAME_LENGTH] = "desc";
new String:CA_PARAM_COOLDOWN[MAX_KEY_NAME_LENGTH] = "cooldown";
new String:CA_PARAM_IS_BOMB[MAX_KEY_NAME_LENGTH] = "is_bomb";
new String:CA_PARAM_PHASES[MAX_KEY_NAME_LENGTH] = "phases";

/**
 * TF2 Settings
 */
#define CVAR_AUTOBALANCE "mp_autoteambalance"
#define CVAR_AUTOBALANCE_LIMIT "mp_teams_unbalance_limit"
new Handle:TF2_CvarAutoBalance = INVALID_HANDLE;
new Handle:TF2_CvarAutoBalanceLimit = INVALID_HANDLE;

/**
 * Danmaku Core (and map settings)
 */
#define DC_PLUGIN_NAME "Danmaku Fortress"
#define DC_NUM_PREFIXES 3
new String:DC_PROJECTILE_MODEL[MAX_MODEL_FILE_LENGTH] = "models/danmaku_fortress/danmaku.mdl";
new String:DC_PROJECTILE_MATERIAL_DIR[PLATFORM_MAX_PATH] = "materials/danmaku_fortress";
#define DC_PROJECTILE_MODEL_RADIUS 10.0
#define DC_CVAR_CONFIG "danmaku_fortress"
new DC_PROJECTILE_MODEL_INDEX = -1;
new String:DC_Prefixes[DC_NUM_PREFIXES][15] = { "touhou_", "danmaku_", "df_" };
new bool:DC_IsEnabled = false;
new DC_RoundStarts = 0;
new bool:DC_RoundBegan = false;
// this variable below probably needs some explanation
// if everything is to operate from single game frame, calls to GetEngineTime() should be restricted to exactly 1, at least as game logic is concerned.
// the problem is GetEngineTime() can change over a particularly long frame, i.e. one with a lot of code that operates on it.
// this can cause obscure errors if events are triggered in the slight future, while later these future objects are manipulated in the synchronized engine time.
// this issue was particularly problematic with the OnAbilityUsed() calls to the subplugins, where events from now get their first tick "in the past", or so they think.
new Float:DC_SynchronizedTime;
// all these below have cvars
new Float:DC_TutorialInterval = 60.0;
new Float:DC_StartDelay = 10.0;
new Float:DC_InvincibilityDurationNewLife = 3.0;
new Float:DC_InvincibilityDurationBomb = 1.0;
new Float:DC_VerticalMultiplier = 0.35; // for movement
new Float:DC_PostgameDelay = 10.0; // this is also used for 
new bool:DC_UseParticle = false; // probably deprecating this
new DC_MaxGamesAdminSetting = 5;
new Float:DC_QueuePointGraceTime = 25.0; // grace period before queue points are lost if someone forfeits against you
new DC_QueuePointsWait = 10;
new DC_QueuePointsWin = 9;
new DC_QueuePointsLose = 8;
new DC_QueuePointsStalemate = 300;
new Float:DC_QueuePointsEarlyForfeitMultiplier = 0.0;
new Float:DC_QueuePointsForfeittedAgainstMultiplier = 0.5;
new Float:DC_HeroNormalMaxScore = 25.0;
new Float:DC_HeroHardMaxScore = 50.0;
new Float:DC_HeroLunaticMaxScore = 100.0;
new Float:DC_BossNormalMaxScore = 100.0;
new Float:DC_BossHardMaxScore = 50.0;
new Float:DC_BossLunaticMaxScore = 25.0;
new String:DC_HeroAbilityTerminology[MAX_AESTHETIC_NAME_LENGTH];
new String:DC_BossAbilityTerminology[MAX_AESTHETIC_NAME_LENGTH];
new Float:DC_HeroProjectileResize = 0.7;
// and here they are
new Handle:DC_CvarTutorialInterval = INVALID_HANDLE;
new Handle:DC_CvarStartDelay = INVALID_HANDLE;
new Handle:DC_CvarNewLifeInvincible = INVALID_HANDLE;
new Handle:DC_CvarBombInvincible = INVALID_HANDLE;
new Handle:DC_CvarVerticalMultiplier = INVALID_HANDLE;
new Handle:DC_CvarPostgameDelay = INVALID_HANDLE;
new Handle:DC_CvarUseParticle = INVALID_HANDLE;
new Handle:DC_CvarMaxGames = INVALID_HANDLE;
new Handle:DC_CvarQueuePointGraceTime = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsWait = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsWin = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsLose = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsStalemate = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsEarlyForfeitMultiplier = INVALID_HANDLE;
new Handle:DC_CvarQueuePointsForfeittedAgainstMultiplier = INVALID_HANDLE; // supercalitastic!
new Handle:DC_CvarHeroNormalMaxScore = INVALID_HANDLE;
new Handle:DC_CvarHeroHardMaxScore = INVALID_HANDLE;
new Handle:DC_CvarHeroLunaticMaxScore = INVALID_HANDLE;
new Handle:DC_CvarBossNormalMaxScore = INVALID_HANDLE;
new Handle:DC_CvarBossHardMaxScore = INVALID_HANDLE;
new Handle:DC_CvarBossLunaticMaxScore = INVALID_HANDLE;
new Handle:DC_CvarHeroAbilityTerminology = INVALID_HANDLE;
new Handle:DC_CvarBossAbilityTerminology = INVALID_HANDLE;
new Handle:DC_CvarHeroProjectileResize = INVALID_HANDLE;
// and their strings
#define CVAR_TUTORIAL_INTERVAL "df_tutorial_interval"
#define CVAR_START_DELAY "df_start_delay"
#define CVAR_NEW_LIFE_INVINCIBLE "df_new_life_invincibility_duration"
#define CVAR_BOMB_INVINCIBLE "df_bomb_invincibility_duration"
#define CVAR_VERTICAL_MULTIPLIER "df_vertical_multiplier"
#define CVAR_POSTGAME_DELAY "df_postgame_delay"
#define CVAR_USE_PARTICLE "df_use_particle"
#define CVAR_MAX_GAMES "df_max_games"
#define CVAR_QUEUE_POINT_GRACE_TIME "df_queue_point_grace_time"
#define CVAR_QUEUE_POINTS_WAIT "df_queue_points_wait"
#define CVAR_QUEUE_POINTS_WIN "df_queue_points_win"
#define CVAR_QUEUE_POINTS_LOSE "df_queue_points_lose"
#define CVAR_QUEUE_POINTS_STALEMATE "df_queue_points_stalemate"
#define CVAR_QUEUE_POINTS_EARLY_FORFEIT "df_queue_points_early_forfeit_mult"
#define CVAR_QUEUE_POINTS_FORFEITTED_AGAINST "df_queue_points_forfetted_against_mult"
#define CVAR_HERO_NORMAL_MAX_SCORE "df_hero_normal_max_score"
#define CVAR_HERO_HARD_MAX_SCORE "df_hero_hard_max_score"
#define CVAR_HERO_LUNATIC_MAX_SCORE "df_hero_lunatic_max_score"
#define CVAR_BOSS_NORMAL_MAX_SCORE "df_boss_normal_max_score"
#define CVAR_BOSS_HARD_MAX_SCORE "df_boss_hard_max_score"
#define CVAR_BOSS_LUNATIC_MAX_SCORE "df_boss_lunatic_max_score"
#define CVAR_HERO_ABILITY_TERMINOLOGY "df_hero_ability_terminology"
#define CVAR_BOSS_ABILITY_TERMINOLOGY "df_boss_ability_terminology"
#define CVAR_HERO_PROJECTILE_RESIZE "df_hero_projectile_resize"
// special: the version cvar
new Handle:DC_CvarVersion = INVALID_HANDLE;
#define CVAR_VERSION "danmaku_fortress_version"

/**
 * Danmaku Fortress Player
 */
#define DFP_ROLE_NONE 0
#define DFP_ROLE_HERO 1
#define DFP_ROLE_BOSS 2
#define DFP_ROLE_SURVIVOR 3 // placeholder for future mode which I might use to solve the waiting boredom problem
#define DFP_INVALID_GAME -1
#define DFP_ALPHA_NONE 0
#define DFP_ALPHA_HERO 255 //231
#define DFP_ALPHA_BOSS 255
#define DFP_ALPHA_SURVIVOR 255 //231
#define DFP_PARTICLE "superrare_purpleenergy"
#define DFP_HIT_SOUND "ui/hitsound.wav"
#define DFP_PLAYBACK_DONOTWANT -1
#define DFP_PLAYBACK_NONE 0
#define DFP_PLAYBACK_INTRO 1
#define DFP_PLAYBACK_SONG 2
#define DFP_PLAYBACK_NEXT_PENDING 3
#define DFP_RESPAWN_DELAY 1.0
#define DFP_DIFFICULTY_NORMAL 0
#define DFP_DIFFICULTY_HARD 1
#define DFP_DIFFICULTY_LUNATIC 2
new DFP_AccessLevel[MAX_PLAYERS_ARRAY]; // normal, donator, admin
new DFP_Difficulty[MAX_PLAYERS_ARRAY]; // difficulty level
new bool:DFP_AutoFire[MAX_PLAYERS_ARRAY]; // if this is set, the client must hold M1 to not fire.
new bool:DFP_WasInPreRound[MAX_PLAYERS_ARRAY]; // was player in the pre-round? has minor interface effects if so.
new bool:DFP_PlayerJustSpawned[MAX_PLAYERS_ARRAY]; // delays actions to perform on spawn until next frame, to ensure they properly perform
new bool:DFP_PlayerSpawnedOnce[MAX_PLAYERS_ARRAY]; // used for timing of first help message, may be used for other things
new DFP_ParticleEntRef[MAX_PLAYERS_ARRAY]; // hit point particle
new DFP_Role[MAX_PLAYERS_ARRAY]; // spec, hero, or boss
new DFP_PreferredRole[MAX_PLAYERS_ARRAY]; // no preference, hero, or boss
new DFP_PreferredHero[MAX_PLAYERS_ARRAY]; // specific character preference
new DFP_PreferredBoss[MAX_PLAYERS_ARRAY]; // specific character preference
new bool:DFP_HeroPickAdminOverride[MAX_PLAYERS_ARRAY]; // admin forced a hero on this user
new bool:DFP_BossPickAdminOverride[MAX_PLAYERS_ARRAY]; // admin forced a boss on this user
new DFP_GameNum[MAX_PLAYERS_ARRAY]; // which game are they in?
new bool:DFP_OptOut[MAX_PLAYERS_ARRAY]; // player has opted out
new DFP_QueuePoints[MAX_PLAYERS_ARRAY]; // a random player with the most queue points is automatically selected to be whatever's available
new Float:DFP_NextTutorialMessageAt[MAX_PLAYERS_ARRAY];
new DFP_NextTutorialMessage[MAX_PLAYERS_ARRAY];
new bool:DFP_PlayerIsHooked[MAX_PLAYERS_ARRAY]; // is player properly SDKHooked?
new DFP_MusicState[MAX_PLAYERS_ARRAY];
new DFP_MusicIdx[MAX_PLAYERS_ARRAY]; // the array index, not the song index in the config file
new bool:DFP_MusicWasRandom[MAX_PLAYERS_ARRAY];
new Float:DFP_AdvanceStateAt[MAX_PLAYERS_ARRAY];
new Float:DFP_RespawnAt[MAX_PLAYERS_ARRAY]; // so much for instant respawn, too bug ridden
new Float:DFP_AvailableForGameAt[MAX_PLAYERS_ARRAY]; // give breathing room between games
new DFP_LifetimeScore[MAX_PLAYERS_ARRAY]; // right now it doesn't do anything, but in the long run it'll be used for leaderboards. may as well begin tracking now.

// key states and other variables related to movement
#define DFP_SPEC_MAX_SPEED 500.0
#define DFP_VEL_PER_TICK 0.2
#define DFP_MOVEMENT_TICK_RATE 0.05
new Float:DFP_MaxSpeed[MAX_PLAYERS_ARRAY];
new Float:DFP_RelativeMaxVel[MAX_PLAYERS_ARRAY][3]; 
new Float:DFP_NextMovementTickAt[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Forward[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Back[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Left[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Right[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_UseAbility[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Iterate[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_ReverseIterate[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Down[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Up[MAX_PLAYERS_ARRAY];
new bool:DFP_KS_Precision[MAX_PLAYERS_ARRAY];

// related to third person
new bool:DFP_ThirdPersonSmxExists = false;
new bool:DFP_ThirdPerson[MAX_PLAYERS_ARRAY];

/**
 * Bot Logic
 */
#define BL_COMBAT_NONE 0
#define BL_COMBAT_USE_ABILITY 1
#define BL_COMBAT_ITERATE 2
#define BL_FB_FORWARD 0
#define BL_FB_BACK 1
#define BL_LR_LEFT 0
#define BL_LR_RIGHT 1
#define BL_UD_UP 0
#define BL_UD_DOWN 1
new bool:BL_IsEnabled = false;
new bool:BL_IsAffected[MAX_PLAYERS_ARRAY];
new Float:BL_NextChangeAt[MAX_PLAYERS_ARRAY];
new BL_CurrentCombatKey[MAX_PLAYERS_ARRAY];
new BL_CurrentFBKey[MAX_PLAYERS_ARRAY];
new BL_CurrentLRKey[MAX_PLAYERS_ARRAY];
new BL_CurrentUDKey[MAX_PLAYERS_ARRAY];

/**
 * Client Preferences
 */
new Handle:CP_CookieHandle = INVALID_HANDLE;
new bool:CP_PrefsLoaded[MAX_PLAYERS_ARRAY]; // seems to be a concern

/**
 * Danmaku Games
 */
#define DG_RESULT_WIN 0
#define DG_RESULT_LOSE 1
#define DG_RESULT_STALEMATE 2
#define DG_HUD_Y 0.775
#define DG_HUD_INTERVAL 0.1
#define DG_WARNING_HUD_Y 0.25
#define DG_WARNING_HUD_DURATION 5.0
#define DG_DEFAULT_WARNING_SOUND "vo/announcer_warning.mp3"
#define DG_MAX_SONGS 5
new DG_MaxGames = 1; // max games map-specific, will often be below the hard maximum
// general
new Float:DG_StartPairingAt = 0.0;
new Handle:DG_HudHandle = INVALID_HANDLE;
new Handle:DG_CornerHudHandle = INVALID_HANDLE;
new Handle:DG_WarningHudHandle = INVALID_HANDLE;
new bool:DG_Active[DG_MAX_GAMES];
new Float:DG_UpdateHUDAt[DG_MAX_GAMES];
new Float:DG_WarningHUDUntil[DG_MAX_GAMES];
new String:DG_WarningText[DG_MAX_GAMES][MAX_CENTER_TEXT_LENGTH];
new Float:DG_BossAlertHUDUntil[DG_MAX_GAMES];
new String:DG_BossAlertText[DG_MAX_GAMES][MAX_CENTER_TEXT_LENGTH];
new Float:DG_RoundBeginsAt[DG_MAX_GAMES];
new DG_CountdownHUD[DG_MAX_GAMES];
new Float:DG_HeroSpawns[DG_MAX_GAMES][3];
new Float:DG_BossSpawns[DG_MAX_GAMES][3];
new Float:DG_HeroSpawnAngles[DG_MAX_GAMES][3];
new Float:DG_BossSpawnAngles[DG_MAX_GAMES][3];
static bool:DG_XYIsForwardBack[DG_MAX_GAMES];
new Float:DG_WholeMapRect[DG_MAX_GAMES][2][3];
new Float:DG_RecycleBoundsRect[DG_MAX_GAMES][2][3];
new Float:DG_MapHeroWallRect[DG_MAX_GAMES][2][3];
new Float:DG_MapBossWallRect[DG_MAX_GAMES][2][3];
new Float:DG_MapHeroLeftWallRect[DG_MAX_GAMES][2][3];
new Float:DG_MapHeroRightWallRect[DG_MAX_GAMES][2][3];
new Float:DG_MapCeilingRect[DG_MAX_GAMES][2][3];
new Float:DG_MapFloorRect[DG_MAX_GAMES][2][3];
new bool:DG_RadiusBombActive[DG_MAX_GAMES];
new Float:DG_BombRadius[DG_MAX_GAMES];
new Float:DG_BombPos[DG_MAX_GAMES][3];
new bool:DG_RectangleBombActive[DG_MAX_GAMES];
new Float:DG_BombRect[DG_MAX_GAMES][2][3];
new Float:DG_QueuePointGraceEndsAt[DG_MAX_GAMES];
new bool:DG_BeamBombActive[DG_MAX_GAMES];
new Float:DG_BeamBombPoint1[DG_MAX_GAMES][3];
new Float:DG_BeamBombPoint2[DG_MAX_GAMES][3];
new Float:DG_BeamBombRadius[DG_MAX_GAMES];
new DG_Difficulty[DG_MAX_GAMES];
// hero
new DG_HeroCharacterIdx[DG_MAX_GAMES]; // character index
new bool:DG_HeroAbilityPending[DG_MAX_GAMES];
new DG_HeroAbilitySelection[DG_MAX_GAMES];
new DG_HeroAbilityCount[DG_MAX_GAMES];
new bool:DG_AbilityIsBomb[DG_MAX_GAMES][CC_MAX_ABILITIES];
new Float:DG_HeroAbilityOnCooldownUntil[DG_MAX_GAMES][CC_MAX_ABILITIES];
new String:DG_HeroAbilityNames[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_ABILITY_NAME_LENGTH];
new String:DG_HeroAbilityFilenames[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_PLUGIN_NAME_LENGTH];
new String:DG_HeroAbilityAestheticName[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_AESTHETIC_NAME_LENGTH];
new String:DG_HeroAbilityDescription[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_DESCRIPTION_LENGTH];
new Float:DG_HeroAbilityCooldown[DG_MAX_GAMES][CC_MAX_ABILITIES]; // rare as it is, I'm adding this for Epic Scout in the future
new bool:DG_HeroFilenameIsUnique[DG_MAX_GAMES][CC_MAX_ABILITIES]; // used for efficiency in managed game frame calls
new DG_HeroLives[DG_MAX_GAMES];
new DG_HeroMaxLives[DG_MAX_GAMES];
new DG_HeroBombs[DG_MAX_GAMES];
new DG_HeroBombsPerLife[DG_MAX_GAMES];
new bool:DG_HeroBombPending[DG_MAX_GAMES];
new Float:DG_HeroInvincibleUntil[DG_MAX_GAMES];
new Float:DG_HeroMoveSpeed[DG_MAX_GAMES];
new DG_HeroClient[DG_MAX_GAMES];
new bool:DG_HeroHitPending[DG_MAX_GAMES];
new DG_HeroModelFixesRemaining[DG_MAX_GAMES];
new Float:DG_NextHeroModelFix[DG_MAX_GAMES];
new DG_PendingHeroSong[DG_MAX_GAMES];
new bool:DG_HeroAutoBomb[DG_MAX_GAMES];
new bool:DG_HeroBombsOnLife[DG_MAX_GAMES];
new Float:DG_HeroScoreMultiplier[DG_MAX_GAMES];
// boss
new DG_BossCharacterIdx[DG_MAX_GAMES]; // character index
new bool:DG_BossAbilityPending[DG_MAX_GAMES];
new DG_BossAbilitySelection[DG_MAX_GAMES];
new Float:DG_NextBossAbilityAt[DG_MAX_GAMES];
new bool:DG_BossUsingAbility[DG_MAX_GAMES];
new DG_BossAbilityCount[DG_MAX_GAMES];
new Float:DG_BossAbilityOnCooldownUntil[DG_MAX_GAMES][CC_MAX_ABILITIES];
new String:DG_BossAbilityNames[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_ABILITY_NAME_LENGTH];
new String:DG_BossAbilityFilenames[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_PLUGIN_NAME_LENGTH];
new String:DG_BossAbilityAestheticName[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_AESTHETIC_NAME_LENGTH];
new String:DG_BossAbilityDescription[DG_MAX_GAMES][CC_MAX_ABILITIES][MAX_DESCRIPTION_LENGTH];
new Float:DG_BossAbilityCooldown[DG_MAX_GAMES][CC_MAX_ABILITIES];
new bool:DG_BossFilenameIsUnique[DG_MAX_GAMES][CC_MAX_ABILITIES]; // used for efficiency in managed game frame calls
new DG_BossAbilityPhases[DG_MAX_GAMES][CC_MAX_ABILITIES];
new DG_BossHealth[DG_MAX_GAMES];
new DG_BossMaxHealth[DG_MAX_GAMES];
new Float:DG_BossAbilityDelay[DG_MAX_GAMES]; // universal delay between abilities, supercedes cooldown
new Float:DG_BossMoveSpeed[DG_MAX_GAMES];
new DG_BossClient[DG_MAX_GAMES];
new Float:DG_BossHitbox[DG_MAX_GAMES][2][3]; // based on origin
new DG_BossDamagePending[DG_MAX_GAMES];
new DG_BossModelFixesRemaining[DG_MAX_GAMES];
new Float:DG_NextBossModelFix[DG_MAX_GAMES];
new DG_PendingBossSong[DG_MAX_GAMES];
new DG_BossPhase[DG_MAX_GAMES];
new DG_BossNumPhases[DG_MAX_GAMES];
new Float:DG_BossScoreMultiplier[DG_MAX_GAMES];

/**
 * Danmaku Beams
 *
 * And the oversized arrays keep on coming.
 * What do you do when the rocket limit becomes a concern? Spawn tempent beams, of course! There's literally no limit, not even 2048.
 * Plus fewer are needed to cover a larger area.
 */
#define DB_MAX_BEAMS 100
#define DB_WIDTH_MODIFIER 1.28 // this factor is necessary because the visual width of the beam does not match the damage width
#define DB_DAMAGE_BOSS_INTERVAL 0.05 // due to the inconsistencies of frame intervals, using a 50ms interval for boss damage
new DB_Laser;
new DB_Glow;
new Float:DB_NextDamageBossAt = 0.0;
new DB_Flags[DG_MAX_GAMES][DB_MAX_BEAMS];
new Float:DB_BeamExpireTime[DG_MAX_GAMES][DB_MAX_BEAMS];
new Float:DB_Starts[DG_MAX_GAMES][DB_MAX_BEAMS][3];
new Float:DB_Ends[DG_MAX_GAMES][DB_MAX_BEAMS][3];
new Float:DB_Radius[DG_MAX_GAMES][DB_MAX_BEAMS];
new DB_Victim[DG_MAX_GAMES][DB_MAX_BEAMS];
new DB_Damage[DG_MAX_GAMES][DB_MAX_BEAMS];
new DB_LastToSpawn[DG_MAX_GAMES];

/**
 * Danmaku Rockets
 *
 * Oh, but if I could shrink these arrays. I'm guessing around 70% of the data size comes from these few arrays.
 * But I need time efficiency over space efficiency. I hope I don't hit a limit.
 */
#define DR_MAX_ROCKETS 350
#define DR_DEFAULT_LIFETIME 10.0
new Float:DR_ReorientAt = 0.0;
new Float:DR_CacheRocketsAt = FAR_FUTURE;
new DR_Flags[DG_MAX_GAMES][DR_MAX_ROCKETS]; // was originally DR_RocketActive, need to combine booleans to control this ballooning data size
new DR_EntRef[DG_MAX_GAMES][DR_MAX_ROCKETS];
new DR_Victim[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_Radius[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_StartRadius[DG_MAX_GAMES][DR_MAX_ROCKETS]; // needed for resizing, sadly
new Float:DR_Speed[DG_MAX_GAMES][DR_MAX_ROCKETS];
new DR_Pattern[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_Param1[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_Param2[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_RocketSpawnTime[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_RocketExpireTime[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_RocketSpawnAngle[DG_MAX_GAMES][DR_MAX_ROCKETS][2]; // yes, this eats a lot of data. so much that I'm opting to not store the roll.
new Float:DR_OldRocketPos[DG_MAX_GAMES][DR_MAX_ROCKETS][3];
new DR_Damage[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_FrozenUntil[DG_MAX_GAMES][DR_MAX_ROCKETS];
new Float:DR_InternalParam1[DG_MAX_GAMES][DR_MAX_ROCKETS]; // I'm so going to hit a limit.
new DR_LastToSpawn[DG_MAX_GAMES]; // fixes an interpolation glitch, but also usable to set special params on the previous rocket

/**
 * Danmaku Spawners -- Literally a subset of rocket (since spawners by necessity use rocket entities)
 *
 * This one also has patterns, but fewer than rockets. Also, much simpler.
 * It is assumed that many will be managed by the subplugin instead, since they're already an uncommon feature.
 */
#define DS_MAX_SPAWNERS 10
new Float:DS_ReorientAt = 0.0;
new DS_EntRef[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new bool:DS_IsHero[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_RocketIdx[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_MovePattern[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_MoveParam1[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_MoveParam2[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_NextSpawnAt[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_SpawnPattern[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnInterval[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnParam1[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnTime[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_ChildRadius[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_ChildColor[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_ChildSpeed[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_ChildDamage[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_LastToSpawn[DG_MAX_GAMES]; // usable to set special params to last spawner, plus speeds up searches for next available

/**
 * Character Lists
 */
#define CL_MAX_HEROES 32
#define CL_MAX_BOSSES 96
#define CL_ACCESS_NORMAL 0
#define CL_ACCESS_DONATOR_CHOICE 1 // donators can choose, anyone can random
#define CL_ACCESS_DONATOR 2
#define CL_ACCESS_ADMIN 3
new String:CL_FILENAME[MAX_CONFIG_NAME_LENGTH] = "characters";
new String:NULL_STRUCT[MAX_KEY_NAME_LENGTH] = "";
new CL_NumHeroes = 0;
new String:CL_HeroNames[CL_MAX_HEROES][MAX_AESTHETIC_NAME_LENGTH];
new String:CL_HeroConfigNames[CL_MAX_HEROES][MAX_CONFIG_NAME_LENGTH];
new CL_HeroAccess[CL_MAX_HEROES];
new CL_NumBosses = 0;
new String:CL_BossNames[CL_MAX_BOSSES][MAX_AESTHETIC_NAME_LENGTH];
new String:CL_BossConfigNames[CL_MAX_BOSSES][MAX_CONFIG_NAME_LENGTH];
new CL_BossAccess[CL_MAX_BOSSES];

/**
 * Music List
 */
#define ML_MAX_SONGS 100
#define ML_SONG_FORMAT "song%d"
#define ML_SONG_LENGTH_FORMAT "songlength%d"
#define ML_INTRO_FORMAT "intro%d"
#define ML_INTRO_LENGTH_FORMAT "introlength%d"
new String:ML_FILENAME[MAX_CONFIG_NAME_LENGTH] = "music";
new ML_NumSongs;
new String:ML_Song[ML_MAX_SONGS][MAX_SOUND_FILE_LENGTH];
new Float:ML_SongLength[ML_MAX_SONGS];
new String:ML_Intro[ML_MAX_SONGS][MAX_SOUND_FILE_LENGTH];
new Float:ML_IntroLength[ML_MAX_SONGS];
new ML_SongIdx[ML_MAX_SONGS]; // only used by boss configs which specify song index
// special audio
#define ML_MAX_SPECIALS 5
#define ML_SPECIAL_WIN 0
#define ML_SPECIAL_LOSE 1
#define ML_SPECIAL_START_5S 2
#define ML_SPECIAL_START_10S 3
#define ML_SPECIAL_START_15S 4
#define ML_WIN_FORMAT "win%d"
#define ML_LOSE_FORMAT "lose%d"
#define ML_START_5S_FORMAT "start_5s_%d"
#define ML_START_10S_FORMAT "start_10s_%d"
#define ML_START_15S_FORMAT "start_15s_%d"
new String:ML_WinSounds[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH];
new ML_NumWinSounds = 0;
new String:ML_LoseSounds[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH];
new ML_NumLoseSounds = 0;
new String:ML_StartSounds5s[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH];
new ML_NumStartSounds5s = 0;
new String:ML_StartSounds10s[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH];
new ML_NumStartSounds10s = 0;
new String:ML_StartSounds15s[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH];
new ML_NumStartSounds15s = 0;
// sound effects. debated giving them its own prefix, but people might misread it as SEX (ala lion king :P )
new String:ML_PARAM_ROCKET_SOUND[MAX_KEY_NAME_LENGTH] = "rocket_sound";
new String:ML_PARAM_ROCKET_INTERVAL[MAX_KEY_NAME_LENGTH] = "rocket_interval";
new String:ML_PARAM_BEAM_SOUND[MAX_KEY_NAME_LENGTH] = "beam_sound";
new String:ML_PARAM_BEAM_INTERVAL[MAX_KEY_NAME_LENGTH] = "beam_interval";
new String:ML_PARAM_HIT_SOUND[MAX_KEY_NAME_LENGTH] = "hit_sound";
new String:ML_PARAM_HIT_INTERVAL[MAX_KEY_NAME_LENGTH] = "hit_interval";
new String:ML_PARAM_HERO_DEATH_SOUND[MAX_KEY_NAME_LENGTH] = "hero_death_sound";
new Float:ML_NextRocketSoundAt[DG_MAX_GAMES];
new String:ML_RocketSound[MAX_SOUND_FILE_LENGTH];
new Float:ML_RocketSoundInterval;
new Float:ML_NextBeamSoundAt[DG_MAX_GAMES];
new String:ML_BeamSound[MAX_SOUND_FILE_LENGTH];
new Float:ML_BeamSoundInterval;
new Float:ML_NextHitSoundAt[DG_MAX_GAMES];
new String:ML_HitSound[MAX_SOUND_FILE_LENGTH];
new Float:ML_HitSoundInterval;
new String:ML_HeroDeathSound[MAX_SOUND_FILE_LENGTH];

/**
 * Lifecycle events and management
 */
public OnPluginStart()
{
	// cvars before all
	DC_CvarTutorialInterval = CreateConVar(CVAR_TUTORIAL_INTERVAL, "60.0", "Interval between tutorial messages.", FCVAR_PLUGIN);
	DC_CvarStartDelay = CreateConVar(CVAR_START_DELAY, "10.0", "Delay before game actually begins, after two people are brought into said game.", FCVAR_PLUGIN);
	DC_CvarNewLifeInvincible = CreateConVar(CVAR_NEW_LIFE_INVINCIBLE, "5.0", "Duration of invincibility when hero uses a life.", FCVAR_PLUGIN);
	DC_CvarBombInvincible = CreateConVar(CVAR_BOMB_INVINCIBLE, "3.0", "Duration of invincibility when bomb is used.", FCVAR_PLUGIN);
	DC_CvarVerticalMultiplier = CreateConVar(CVAR_VERTICAL_MULTIPLIER, "0.35", "Vertical speed multiplier. Vertical speed is recommended slower than horizontal speed, mainly for balance reasons.", FCVAR_PLUGIN);
	DC_CvarPostgameDelay = CreateConVar(CVAR_POSTGAME_DELAY, "10.0", "Delay before someone can enter one game after leaving another. Also the duration of win/lose sounds, before other sounds start playing.", FCVAR_PLUGIN);
	DC_CvarUseParticle = CreateConVar(CVAR_USE_PARTICLE, "0", "Particle effect at hero's damage point? [0/1] (deprecated)", FCVAR_PLUGIN);
	DC_CvarMaxGames = CreateConVar(CVAR_MAX_GAMES, "5", "Admin-set limit for number of max games. (5 is the hard maximum, but you can set it lower)", FCVAR_PLUGIN);
	DC_CvarQueuePointGraceTime = CreateConVar(CVAR_QUEUE_POINT_GRACE_TIME, "25.0", "Grace period before queue points are lost if someone forfeits against you.", FCVAR_PLUGIN);
	DC_CvarQueuePointsWait = CreateConVar(CVAR_QUEUE_POINTS_WAIT, "10", "Queue points for people waiting in line.", FCVAR_PLUGIN);
	DC_CvarQueuePointsWin = CreateConVar(CVAR_QUEUE_POINTS_WIN, "9", "Queue points for winner of a match.", FCVAR_PLUGIN);
	DC_CvarQueuePointsLose = CreateConVar(CVAR_QUEUE_POINTS_LOSE, "8", "Queue points for loser of a match.", FCVAR_PLUGIN);
	DC_CvarQueuePointsStalemate = CreateConVar(CVAR_QUEUE_POINTS_STALEMATE, "300", "Queue points for a stalemate. Keep in mind that unless admins go around slaying everyone, this is an incredibly rare event. You'll probably never see one occur naturally.", FCVAR_PLUGIN);
	DC_CvarQueuePointsEarlyForfeitMultiplier = CreateConVar(CVAR_QUEUE_POINTS_EARLY_FORFEIT, "0.0", "Early forfeit multiplier for the forfeitter. (intended as a penalty, the victim loses no points) [0.0 to 1.0]", FCVAR_PLUGIN);
	DC_CvarQueuePointsForfeittedAgainstMultiplier = CreateConVar(CVAR_QUEUE_POINTS_FORFEITTED_AGAINST, "0.5", "If someone is forfeitted against after the grace period, they lose this amount of their queue points instead of all of them. [0.0 to 1.0]", FCVAR_PLUGIN);
	DC_CvarHeroNormalMaxScore = CreateConVar(CVAR_HERO_NORMAL_MAX_SCORE, "25.0", "Max scoreboard points for the hero, if the hero is on normal difficulty.", FCVAR_PLUGIN);
	DC_CvarHeroHardMaxScore = CreateConVar(CVAR_HERO_HARD_MAX_SCORE, "50.0", "Max scoreboard points for the hero, if the hero is on hard difficulty.", FCVAR_PLUGIN);
	DC_CvarHeroLunaticMaxScore = CreateConVar(CVAR_HERO_LUNATIC_MAX_SCORE, "100.0", "Max scoreboard points for the hero, if the hero is on lunatic difficulty.", FCVAR_PLUGIN);
	DC_CvarBossNormalMaxScore = CreateConVar(CVAR_BOSS_NORMAL_MAX_SCORE, "100.0", "Max scoreboard points for the boss, if the hero is on normal difficulty.", FCVAR_PLUGIN);
	DC_CvarBossHardMaxScore = CreateConVar(CVAR_BOSS_HARD_MAX_SCORE, "50.0", "Max scoreboard points for the boss, if the hero is on hard difficulty.", FCVAR_PLUGIN);
	DC_CvarBossLunaticMaxScore = CreateConVar(CVAR_BOSS_LUNATIC_MAX_SCORE, "25.0", "Max scoreboard points for the boss, if the hero is on lunatic difficulty.", FCVAR_PLUGIN);
	DC_CvarHeroAbilityTerminology = CreateConVar(CVAR_HERO_ABILITY_TERMINOLOGY, "Desperation Ability", "Aesthetic name for hero bomb ability. You might change it to Spell Card if you're running a Touhou themed server.", FCVAR_PLUGIN);
	DC_CvarBossAbilityTerminology = CreateConVar(CVAR_BOSS_ABILITY_TERMINOLOGY, "Boss Ability", "Aesthetic name for boss ability. You might change it to Spell Card if you're running a Touhou themed server.", FCVAR_PLUGIN);
	DC_CvarHeroProjectileResize = CreateConVar(CVAR_HERO_PROJECTILE_RESIZE, "0.7", "Projectile resize for hero. Hit area is unaffected, but making the projectiles smaller makes it easy for the hero to see.", FCVAR_PLUGIN);

	HookConVarChange(DC_CvarTutorialInterval, DC_OnConVarChanged);
	HookConVarChange(DC_CvarStartDelay, DC_OnConVarChanged);
	HookConVarChange(DC_CvarNewLifeInvincible, DC_OnConVarChanged);
	HookConVarChange(DC_CvarBombInvincible, DC_OnConVarChanged);
	HookConVarChange(DC_CvarVerticalMultiplier, DC_OnConVarChanged);
	HookConVarChange(DC_CvarPostgameDelay, DC_OnConVarChanged);
	HookConVarChange(DC_CvarUseParticle, DC_OnConVarChanged);
	HookConVarChange(DC_CvarMaxGames, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointGraceTime, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsWait, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsWin, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsLose, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsStalemate, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsEarlyForfeitMultiplier, DC_OnConVarChanged);
	HookConVarChange(DC_CvarQueuePointsForfeittedAgainstMultiplier, DC_OnConVarChanged);
	HookConVarChange(DC_CvarHeroNormalMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarHeroHardMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarHeroLunaticMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarBossNormalMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarBossHardMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarBossLunaticMaxScore, DC_OnConVarChanged);
	HookConVarChange(DC_CvarHeroAbilityTerminology, DC_OnConVarChanged);
	HookConVarChange(DC_CvarBossAbilityTerminology, DC_OnConVarChanged);
	HookConVarChange(DC_CvarHeroProjectileResize, DC_OnConVarChanged);
	
	// special cvar
	DC_CvarVersion = CreateConVar(CVAR_VERSION, PLUGIN_VERSION, "Danmaku Fortress Version", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_DONTRECORD);

	AutoExecConfig(true, DC_CVAR_CONFIG);

	// initialize all players as none (effectively spectator)
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
		DFP_Role[clientIdx] = DFP_ROLE_NONE;
		
	// register events
	HookEvent("player_spawn", OnPlayerSpawned);
	HookEvent("teamplay_round_start", OnRoundStart);
	
	// register player commands
	RegConsoleCmd(CMD_NEVER, CmdNever); // toggle never be boss or hero, always residing in spectator
	RegConsoleCmd(CMD_WANT_BOSS, CmdWantBoss); // set preference to be boss
	RegConsoleCmd(CMD_WANT_HERO, CmdWantHero); // set preference to be hero
	RegConsoleCmd(CMD_WANT_ANY, CmdWantAny); // set preference to be hero
	RegConsoleCmd(CMD_BOSS, CmdBoss); // if player is boss, allows them to select which boss
	RegConsoleCmd(CMD_HERO, CmdHero); // if player is hero, allows them to select which hero
	RegConsoleCmd(CMD_QUEUE, CmdQueue); // print queue to chat
	RegConsoleCmd(CMD_MUSIC, CmdMusic); // music chooser, including random and none
	RegConsoleCmd(CMD_TP, CmdTP); // third person (only used if the common mod is missing)
	RegConsoleCmd(CMD_FP, CmdFP); // first person (only used if the common mod is missing)
	RegConsoleCmd(CMD_HELP, CmdHelp); // help menu
	RegConsoleCmd(DF_GENERIC1, CmdHelp); // intuitive alias for help menu
	RegConsoleCmd(DF_GENERIC2, CmdHelp); // another intuitive alias for help menu
	RegConsoleCmd(DF_GENERIC3, CmdHelp); // yet another intuitive alias for help menu
	RegConsoleCmd(CMD_TUTORIAL, CmdTutorial); // third person (only used if the common mod is missing)
	RegConsoleCmd(CMD_DIFFICULTY, CmdDifficulty);
	RegConsoleCmd(CMD_AUTOFIRE, CmdAutoFire);
	AddCommandListener(KillCommands, "kill");
	AddCommandListener(KillCommands, "explode");
	AddCommandListener(MedicCommand, "voicemenu");
	
	// register admin commands
	RegAdminCmd(CMD_CVARS, CmdCvars, ADMFLAG_GENERIC); // music chooser, including random and none
	RegAdminCmd(CMD_BOTLOGIC, CmdBotLogic, ADMFLAG_GENERIC); // decided to demote this from "debug mode", since it doesn't have disruption potential
	RegAdminCmd(CMD_ADDPOINTS, CmdAddPoints, ADMFLAG_GENERIC); // another influence from FF2
	RegAdminCmd(CMD_FORCEHERO, CmdForceHero, ADMFLAG_GENERIC); // this and the below allow admins to temporarily grant a restricted character
	RegAdminCmd(CMD_FORCEBOSS, CmdForceBoss, ADMFLAG_GENERIC);
	RegAdminCmd(CMD_ADMINWORKAROUND, CmdAdminWorkaround, ADMFLAG_GENERIC); // stupid hack
	
	// register debug mode commands
	if (DEBUG_MODE_ENABLED)
	{
		RegAdminCmd(CMD_FORCEFIRE, CmdForceFire, ADMFLAG_GENERIC);
		RegAdminCmd(CMD_ITERATE, CmdIterate, ADMFLAG_GENERIC);
	}
	
	// register client cookie
	CP_CookieHandle = RegClientCookie("df_userprefs", "How are you reading this?", CookieAccess_Private);
	
	// TF2 cvars
	TF2_CvarAutoBalance = FindConVar(CVAR_AUTOBALANCE);
	TF2_CvarAutoBalanceLimit = FindConVar(CVAR_AUTOBALANCE_LIMIT);
	
	// had to test to ensure I didn't mess up porting this
	//static Float:point[3];
	//static Float:start[3];
	//static Float:end[3];
	//start[0] = -3.5; start[1] = 12.7; start[2] = 4.1;
	//end[0] = 7.3; end[1] = 5.2; end[2] = 5.2;
	//point[0] = -2.5; point[1] = 6.1; point[2] = 4.3;
	//PrintToServer("distance with point %f,%f,%f: %f", point[0], point[1], point[2], dist_Point_to_Segment(point, start, end));
	//point[0] = -12.7; point[1] = 26.5; point[2] = 7.1;
	//PrintToServer("distance with point %f,%f,%f: %f", point[0], point[1], point[2], dist_Point_to_Segment(point, start, end));
	//point[0] = 35.2; point[1] = 14.3; point[2] = -1.5;
	//PrintToServer("distance with point %f,%f,%f: %f", point[0], point[1], point[2], dist_Point_to_Segment(point, start, end));
}

public OnConfigsExecuted()
{
	if (DC_CvarVersion != INVALID_HANDLE)
		SetConVarString(DC_CvarVersion, PLUGIN_VERSION);
}

public ReadMusicList(&musicCount, String:configName[MAX_CONFIG_NAME_LENGTH], bool:isCharacterConfig)
{
	new maxSongs = isCharacterConfig ? (ML_MAX_SONGS - musicCount) : ML_MAX_SONGS;
	for (new i = 0; i < maxSongs; i++)
	{
		new songIdx = i + 1;
		static String:songKey[MAX_KEY_NAME_LENGTH];
		static String:songLengthKey[MAX_KEY_NAME_LENGTH];
		static String:introKey[MAX_KEY_NAME_LENGTH];
		static String:introLengthKey[MAX_KEY_NAME_LENGTH];
		Format(songKey, MAX_KEY_NAME_LENGTH, ML_SONG_FORMAT, songIdx);
		Format(songLengthKey, MAX_KEY_NAME_LENGTH, ML_SONG_LENGTH_FORMAT, songIdx);
		Format(introKey, MAX_KEY_NAME_LENGTH, ML_INTRO_FORMAT, songIdx);
		Format(introLengthKey, MAX_KEY_NAME_LENGTH, ML_INTRO_LENGTH_FORMAT, songIdx);

		// bring in the song, fail if its settings are invalid
		ML_Song[musicCount][0] = 0;
		KV_ReadString(configName, NULL_STRUCT, songKey, ML_Song[musicCount], MAX_SOUND_FILE_LENGTH);
		if (strlen(ML_Song[musicCount]) <= 3)
		{
			if (isCharacterConfig)
				break;
			else
				continue;
		}
		ML_SongLength[musicCount] = KV_ReadFloat(configName, NULL_STRUCT, songLengthKey, 0.0);
		if (ML_SongLength[musicCount] <= 0.0)
		{
			ML_Song[musicCount][0] = 0;
			continue;
		}
		
		// determine if it's a repeat, which are more likely with songs specified in character config
		if (isCharacterConfig)
			for (new j = 0; j < musicCount; j++)
				if (StrEqual(ML_Song[musicCount], ML_Song[j]))
					continue;
		
		// bring in the intro, which is completely optional
		ML_Intro[musicCount][0] = 0;
		KV_ReadString(configName, NULL_STRUCT, introKey, ML_Intro[musicCount], MAX_SOUND_FILE_LENGTH);
		ML_IntroLength[musicCount] = KV_ReadFloat(configName, NULL_STRUCT, introLengthKey, 0.0);
		if (ML_IntroLength[musicCount] <= 0.0)
			ML_Intro[musicCount][0] = 0;
		
		// precaches and download list
		PrecacheSound(ML_Song[musicCount]);
		AddSoundToDownloadsTable(ML_Song[musicCount]);
		if (strlen(ML_Intro[musicCount]) > 3)
		{
			PrecacheSound(ML_Intro[musicCount]);
			AddSoundToDownloadsTable(ML_Intro[musicCount]);
		}
		ML_SongIdx[musicCount] = songIdx;
			
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] Found song at index %d, song (len=%.1f) is %s, intro (len=%.1f) is %s", 
					ML_SongIdx[musicCount], ML_SongLength[musicCount], ML_Song[musicCount], ML_IntroLength[musicCount], ML_Intro[musicCount]);
		musicCount++;
	}
}

public OnMapStart()
{
	// do we manage third person, or do we let another plugin handle it?
	DFP_ThirdPersonSmxExists = PluginExists("thirdperson.smx");
	if (!DFP_ThirdPersonSmxExists)
		PrintToServer("[danmaku_fortress] Thirdperson plugin not found. This plugin will manage third person mode.");
	else
		PrintToServer("[danmaku_fortress] Thirdperson plugin found. It will manage third person mode.");

	// load cvars before all
	AutoExecConfig(true, DC_CVAR_CONFIG);
	DC_OnConVarChanged(INVALID_HANDLE, "", "");

	static String:mapName[64];
	GetCurrentMap(mapName, 64);
	DC_IsEnabled = false;
	DC_RoundBegan = false;
	DC_RoundStarts = 0;
	for (new i = 0; i < DC_NUM_PREFIXES; i++)
		DC_IsEnabled = DC_IsEnabled || StrContains(mapName, DC_Prefixes[i]) == 0;
	
	if (!DC_IsEnabled)
	{
		if (PRINT_DEBUG_SPAM)
		{
			CPrintToChatAll("%s is disabled on this map. Must have one of these prefixes:", DC_PLUGIN_NAME);
			PrintToServer("%s is disabled on this map. Must have one of these prefixes:", DC_PLUGIN_NAME);
			for (new i = 0; i < DC_NUM_PREFIXES; i++)
			{
				CPrintToChatAll(DC_Prefixes[i]);
				PrintToServer(DC_Prefixes[i]);
			}
		}
		
		return;
	}
	
	// init players
	CPrintToChatAll("%s is enabled on this map.", DC_PLUGIN_NAME);
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		DFP_PlayerIsHooked[clientIdx] = false;
		DFP_ParticleEntRef[clientIdx] = INVALID_ENTREF;
		DFP_PlayerJustSpawned[clientIdx] = false;
		DFP_ThirdPerson[clientIdx] = false;
	}
		
	// init games and rockets
	DC_PROJECTILE_MODEL_INDEX = PrecacheModel(DC_PROJECTILE_MODEL);
	for (new i = 0; i < DG_MAX_GAMES; i++)
	{
		DG_Active[i] = false;
		for (new j = 0; j < DR_MAX_ROCKETS; j++)
			DR_EntRef[i][j] = INVALID_ENTREF;
		for (new j = 0; j < DS_MAX_SPAWNERS; j++)
			DS_EntRef[i][j] = INVALID_ENTREF;
	}
	
	// read in the music before the characters, since characters can now append the music list
	new musicCount = 0;
	ReadMusicList(musicCount, ML_FILENAME, false);

	// while we've got the music config file open, lets also bring in special sounds
	ML_InitSpecial(ML_WIN_FORMAT, ML_WinSounds, ML_NumWinSounds);
	ML_InitSpecial(ML_LOSE_FORMAT, ML_LoseSounds, ML_NumLoseSounds);
	ML_InitSpecial(ML_START_5S_FORMAT, ML_StartSounds5s, ML_NumStartSounds5s);
	ML_InitSpecial(ML_START_10S_FORMAT, ML_StartSounds10s, ML_NumStartSounds10s);
	ML_InitSpecial(ML_START_15S_FORMAT, ML_StartSounds15s, ML_NumStartSounds15s);
	
	// sound effects are also in the same file
	KV_ReadString(ML_FILENAME, NULL_STRUCT, ML_PARAM_ROCKET_SOUND, ML_RocketSound, MAX_SOUND_FILE_LENGTH);
	if (strlen(ML_RocketSound) > 3)
	{
		PrecacheSound(ML_RocketSound);
		ML_RocketSoundInterval = KV_ReadFloat(ML_FILENAME, NULL_STRUCT, ML_PARAM_ROCKET_INTERVAL, 0.0);
		if (ML_RocketSoundInterval <= 0.0)
			ML_RocketSoundInterval = 0.1;
	}
	else
		ML_RocketSound[0] = 0;
	KV_ReadString(ML_FILENAME, NULL_STRUCT, ML_PARAM_BEAM_SOUND, ML_BeamSound, MAX_SOUND_FILE_LENGTH);
	if (strlen(ML_BeamSound) > 3)
	{
		PrecacheSound(ML_BeamSound);
		ML_BeamSoundInterval = KV_ReadFloat(ML_FILENAME, NULL_STRUCT, ML_PARAM_BEAM_INTERVAL, 0.0);
		if (ML_BeamSoundInterval <= 0.0)
			ML_BeamSoundInterval = 0.1;
	}
	else
		ML_BeamSound[0] = 0;
	KV_ReadString(ML_FILENAME, NULL_STRUCT, ML_PARAM_HIT_SOUND, ML_HitSound, MAX_SOUND_FILE_LENGTH);
	if (strlen(ML_HitSound) > 3)
	{
		PrecacheSound(ML_HitSound);
		ML_HitSoundInterval = KV_ReadFloat(ML_FILENAME, NULL_STRUCT, ML_PARAM_HIT_INTERVAL, 0.0);
		if (ML_HitSoundInterval <= 0.0)
			ML_HitSoundInterval = 0.1;
	}
	else
		ML_HitSound[0] = 0;
	KV_ReadString(ML_FILENAME, NULL_STRUCT, ML_PARAM_HERO_DEATH_SOUND, ML_HeroDeathSound, MAX_SOUND_FILE_LENGTH);
	if (strlen(ML_HeroDeathSound) > 3)
		PrecacheSound(ML_HeroDeathSound);
		
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		ML_NextRocketSoundAt[gameIdx] = (ML_RocketSound[0] == 0) ? FAR_FUTURE : GetEngineTime();
		ML_NextBeamSoundAt[gameIdx] = (ML_BeamSound[0] == 0) ? FAR_FUTURE : GetEngineTime();
		ML_NextHitSoundAt[gameIdx] = (ML_HitSound[0] == 0) ? FAR_FUTURE : GetEngineTime();
	}
	
	// init character list
	for (new i = 0; i < CL_MAX_HEROES; i++)
		CL_HeroNames[i][0] = 0;
	for (new i = 0; i < CL_MAX_BOSSES; i++)
		CL_BossNames[i][0] = 0;
		
	// read character list
	new heroCount = 0;
	new bossCount = 0;
	for (new i = 1; i <= (CL_MAX_HEROES + CL_MAX_BOSSES); i++)
	{
		static String:intS[MAX_KEY_NAME_LENGTH];
		IntToString(i, intS, sizeof(intS));
		static String:configName[MAX_CONFIG_NAME_LENGTH];
		configName[0] = 0;
		KV_ReadString(CL_FILENAME, NULL_STRUCT, intS, configName, MAX_CONFIG_NAME_LENGTH);
		
		if (IsEmptyString(configName))
			continue;
		static String:aestheticName[MAX_AESTHETIC_NAME_LENGTH];
		aestheticName[0] = 0;
		KV_ReadString(configName, NULL_STRUCT, CC_PARAM_NAME, aestheticName, MAX_AESTHETIC_NAME_LENGTH);
		if (IsEmptyString(aestheticName))
		{
			PrintToServer("[danmaku_fortress] ERROR: Character %s has no \"name\" parameter. This probably means the config is missing. Won't load.", configName);
			continue;
		}
		
		// must precache the model now, and add to download lists
		static String:modelName[MAX_MODEL_FILE_LENGTH];
		KV_ReadString(configName, NULL_STRUCT, CC_PARAM_MODEL, modelName, MAX_MODEL_FILE_LENGTH);
		if (strlen(modelName) > 3)
		{
			PrecacheModel(modelName);
			AddModelToDownloadsTable(modelName); // it's complicated.
		}
		
		// go through any resource dirs
		static String:resdirKey[MAX_KEY_NAME_LENGTH];
		static String:resdir[PLATFORM_MAX_PATH];
		new bool:validKey;
		new resdirCount = 1;
		do {
			Format(resdirKey, MAX_KEY_NAME_LENGTH, CC_PARAM_RESDIR_FORMAT, resdirCount);
			resdirCount++;
			validKey = KV_ReadString(configName, NULL_STRUCT, resdirKey, resdir, PLATFORM_MAX_PATH);
			if (validKey)
				AddDirectoryToDownloadsTable(resdir);
		} while (validKey);
		
		new type = KV_ReadInt(configName, NULL_STRUCT, CC_PARAM_TYPE, -1);
		new access = KV_ReadInt(configName, NULL_STRUCT, CC_PARAM_ACCESS, -1);
		if (type == 0)
		{
			// add it to hero array, if possible
			if (heroCount == CL_MAX_HEROES)
				PrintToServer("[danmaku_fortress] ERROR: Hit the limit for hero characters. Character %s will not load.", configName);
			else
			{
				strcopy(CL_HeroNames[heroCount], MAX_AESTHETIC_NAME_LENGTH, aestheticName);
				strcopy(CL_HeroConfigNames[heroCount], MAX_CONFIG_NAME_LENGTH, configName);
				CL_HeroAccess[heroCount] = access;
				if (PRINT_DEBUG_INFO)
					PrintToServer("[danmaku_fortress] Successfully found Hero character %s (config: %s, access: %d)", CL_HeroNames[heroCount], CL_HeroConfigNames[heroCount], CL_HeroAccess[heroCount]);
				heroCount++;
			}
		}
		else if (type == 1)
		{
			// add it to boss array, if possible
			if (bossCount == CL_MAX_BOSSES)
				PrintToServer("[danmaku_fortress] ERROR: Hit the limit for boss characters. Character %s will not load.", configName);
			else
			{
				strcopy(CL_BossNames[bossCount], MAX_AESTHETIC_NAME_LENGTH, aestheticName);
				strcopy(CL_BossConfigNames[bossCount], MAX_CONFIG_NAME_LENGTH, configName);

				// special for bosses, read in songs that aren't in music.cfg
				ReadMusicList(musicCount, configName, true);
		
				CL_BossAccess[bossCount] = access;
				if (PRINT_DEBUG_INFO)
					PrintToServer("[danmaku_fortress] Successfully found Boss character %s (config: %s, access: %d)", CL_BossNames[bossCount], CL_BossConfigNames[bossCount], CL_BossAccess[bossCount]);
				bossCount++;
			}
		}
		else if (type == 2)
			PrintToServer("[danmaku_fortress] WARNING: Ignoring survivor type character %s. This is for internal use only and should not be included in %s.cfg.", configName, CL_FILENAME);
		else
			PrintToServer("[danmaku_fortress] ERROR: Character %s has no type specified. Will not load.", configName);
	}
	KV_Cleanup(); // must ensure the last open handle is closed
	
	// set counts and ensure valid
	CL_NumHeroes = heroCount;
	CL_NumBosses = bossCount;
	if (heroCount == 0 || bossCount == 0)
	{
		PrintToServer("[danmaku_fortress] ERROR: Character file must list at least one hero and one boss. Disabling %s.", DC_PLUGIN_NAME);
		DC_IsEnabled = false;
		return;
	}
	
	// ensure validity of music
	ML_NumSongs = musicCount;
	if (ML_NumSongs == 0)
		PrintToServer("[danmaku_fortress] WARNING: You have no music. The plugin will continue, but no music is boring.");

	// iterate through team spawns to determine just how many games there are
	new gameCount = 0;
	new spawn = -1;
	new spawnTotal = (DG_MAX_GAMES * 2);
	static spawns[(DG_MAX_GAMES * 2)];
	for (new i = 0; i < spawnTotal; i++)
		spawns[i] = INVALID_ENTREF;
	
	new spawnCount = 0;
	while ((spawn = FindEntityByClassname(spawn, "info_player_teamspawn")) != -1 && spawnCount < spawnTotal)
	{
		spawns[spawnCount] = spawn;
		spawnCount++;
	}
	
	for (new i = 0; i < spawnCount; i++)
	{
		if (spawns[i] == INVALID_ENTREF)
			continue;
		static Float:spawn1Pos[3];
		static Float:spawn1Angle[3];
		GetEntPropVector(spawns[i], Prop_Send, "m_vecOrigin", spawn1Pos);
		GetEntPropVector(spawns[i], Prop_Data, "m_angRotation", spawn1Angle);
		new nearestIdx = -1;
		new Float:nearestDistance = -1.0;
		static Float:nearestPos[3];
		static Float:nearestAngle[3];
		for (new j = i + 1; j < spawnCount; j++)
		{
			if (spawns[j] == INVALID_ENTREF)
				continue;
			static Float:spawn2Pos[3];
			GetEntPropVector(spawns[j], Prop_Send, "m_vecOrigin", spawn2Pos);
			new Float:distance = GetVectorDistance(spawn1Pos, spawn2Pos, true);
			if (nearestDistance == -1.0 || distance < nearestDistance)
			{
				if (GetEntProp(spawns[i], Prop_Send, "m_iTeamNum") != GetEntProp(spawns[j], Prop_Send, "m_iTeamNum"))
				{
					nearestIdx = j;
					nearestDistance = distance;
					nearestPos[0] = spawn2Pos[0];
					nearestPos[1] = spawn2Pos[1];
					nearestPos[2] = spawn2Pos[2];
					GetEntPropVector(spawns[j], Prop_Data, "m_angRotation", nearestAngle);
				}
			}
		}
		
		if (nearestIdx != -1)
		{
			new bool:firstIsBlue = ((GetEntProp(spawns[i], Prop_Send, "m_iTeamNum") % 2) == 1);
			spawns[i] = INVALID_ENTREF;
			spawns[nearestIdx] = INVALID_ENTREF;
			DG_HeroSpawns[gameCount][0] = firstIsBlue ? nearestPos[0] : spawn1Pos[0];
			DG_HeroSpawns[gameCount][1] = firstIsBlue ? nearestPos[1] : spawn1Pos[1];
			DG_HeroSpawns[gameCount][2] = firstIsBlue ? nearestPos[2] : spawn1Pos[2];
			DG_BossSpawns[gameCount][0] = !firstIsBlue ? nearestPos[0] : spawn1Pos[0];
			DG_BossSpawns[gameCount][1] = !firstIsBlue ? nearestPos[1] : spawn1Pos[1];
			DG_BossSpawns[gameCount][2] = !firstIsBlue ? nearestPos[2] : spawn1Pos[2];
			DG_HeroSpawnAngles[gameCount][0] = firstIsBlue ? nearestAngle[0] : spawn1Angle[0];
			DG_HeroSpawnAngles[gameCount][1] = firstIsBlue ? nearestAngle[1] : spawn1Angle[1];
			DG_HeroSpawnAngles[gameCount][2] = firstIsBlue ? nearestAngle[2] : spawn1Angle[2];
			DG_BossSpawnAngles[gameCount][0] = !firstIsBlue ? nearestAngle[0] : spawn1Angle[0];
			DG_BossSpawnAngles[gameCount][1] = !firstIsBlue ? nearestAngle[1] : spawn1Angle[1];
			DG_BossSpawnAngles[gameCount][2] = !firstIsBlue ? nearestAngle[2] : spawn1Angle[2];
			
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] Successfully determined game #%d coordinates. Hero=%f,%f,%f   Boss=%f,%f,%f", gameCount + 1,
						DG_HeroSpawns[gameCount][0], DG_HeroSpawns[gameCount][1], DG_HeroSpawns[gameCount][2],
						DG_BossSpawns[gameCount][0], DG_BossSpawns[gameCount][1], DG_BossSpawns[gameCount][2]);
						
			// now that we have valid spawn points, lets find the map's dimensions
			DG_CalculateWallPositions(gameCount);
			
			gameCount++;
			if (gameCount == DG_MAX_GAMES)
			{
				if (PRINT_DEBUG_INFO)
					PrintToServer("[danmaku_fortress] Game limit reached. If map has more than %d game areas, they will be ignored.", gameCount);
				break;
			}
		}
	}
	
	// set max and ensure valid
	DG_MaxGames = gameCount;
	DG_MaxGames = min(DG_MaxGames, DC_MaxGamesAdminSetting);
	if (DG_MaxGames <= 0)
	{
		PrintToServer("[danmaku_fortress] ERROR: Map is lacking necessary spawn points to auto-configure. (or admin setting for max games is too low) Disabling %s.", DC_PLUGIN_NAME);
		DC_IsEnabled = false;
		return;
	}
	
	// create HUD synchronizer
	DG_HudHandle = CreateHudSynchronizer();
	DG_CornerHudHandle = CreateHudSynchronizer();
	DG_WarningHudHandle = CreateHudSynchronizer();
	
	// precache sounds
	PrecacheSound(DFP_HIT_SOUND);
	PrecacheSound(DG_DEFAULT_WARNING_SOUND);
	
	// precache beam materials
	DB_Laser = PrecacheModel("materials/sprites/laser.vmt");
	DB_Glow = PrecacheModel("sprites/glow02.vmt", true);
	
	// add special files to download list
	AddModelToDownloadsTable(DC_PROJECTILE_MODEL);
	AddDirectoryToDownloadsTable(DC_PROJECTILE_MATERIAL_DIR);
	
	// change TF2 convars to fit our needs
	if (TF2_CvarAutoBalance != INVALID_HANDLE)
		SetConVarBool(TF2_CvarAutoBalance, false);
	if (TF2_CvarAutoBalanceLimit != INVALID_HANDLE)
		SetConVarInt(TF2_CvarAutoBalanceLimit, 32);
}

public TF2_OnWaitingForPlayersStart()
{
	if (!DC_IsEnabled)
		return;

	DC_RoundBegan = false;
		
	// since this could happen more than once, clear any existing games and players
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		DG_Active[gameIdx] = false;
	}
	
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		DFP_Role[clientIdx] = DFP_ROLE_NONE;
	}
}

public TF2_OnWaitingForPlayersEnd()
{
	if (!DC_IsEnabled)
		return;
		
	DC_RoundBegan = true;
	DG_StartPairingAt = GetEngineTime() + 5.0;
	DR_CacheRocketsAt = GetEngineTime() + 2.0;
	PrintToServer("[danmaku_fortress] Round has begun and %s is enabled. Matchups should begin in %.0f seconds.", DC_PLUGIN_NAME, (DG_StartPairingAt - GetEngineTime()));
	CPrintToChatAll("Round has begun and %s is enabled. Matchups should begin in %.0f seconds.", DC_PLUGIN_NAME, (DG_StartPairingAt - GetEngineTime()));
}

public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!DC_IsEnabled)
		return;

	// kind of a relic, but it might eventually serve a purpose again		
}

public OnClientConnected(clientIdx)
{
	// since we're not quarantining this lifecycle method, only inits should occur here, no actual code
	if (clientIdx > 0 && clientIdx < MAX_PLAYERS)
	{
		DFP_Role[clientIdx] = DFP_ROLE_NONE;
		DFP_PreferredRole[clientIdx] = DFP_ROLE_NONE;
		DFP_OptOut[clientIdx] = false;
		DFP_NextTutorialMessageAt[clientIdx] = GetEngineTime() + 60.0; // short interval to first message
		DFP_NextTutorialMessage[clientIdx] = 0;
		DFP_NextMovementTickAt[clientIdx] = 0.0;
		DFP_PreferredHero[clientIdx] = -1;
		DFP_PreferredBoss[clientIdx] = -1;
		DFP_HeroPickAdminOverride[clientIdx] = false;
		DFP_BossPickAdminOverride[clientIdx] = false;
		DFP_MusicState[clientIdx] = DFP_PLAYBACK_NONE;
		DFP_RespawnAt[clientIdx] = FAR_FUTURE;
		DFP_AvailableForGameAt[clientIdx] = 0.0;
		DFP_ThirdPerson[clientIdx] = false;
		DFP_PlayerSpawnedOnce[clientIdx] = false;
		DFP_Difficulty[clientIdx] = DFP_DIFFICULTY_NORMAL;
		DFP_WasInPreRound[clientIdx] = false;
		DFP_AccessLevel[clientIdx] = CL_ACCESS_NORMAL;
		DFP_AutoFire[clientIdx] = false;
		DFP_QueuePoints[clientIdx] = 0;
		DFP_LifetimeScore[clientIdx] = 0;
		CP_PrefsLoaded[clientIdx] = false;
		BL_IsAffected[clientIdx] = false;
	}
}

public OnPlayerSpawned(Handle:event, const String:name[], bool:dontBroadcast)
{
	// need to remove weapons etc even if we're in the pre-round.
	// otherwise certain race conditions could cause players to have weapons or normal collision immediately after the pre-round.
	if (!DC_IsEnabled)
		return;

	new clientIdx = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidPlayer(clientIdx))
		return;
	
	DFP_PlayerJustSpawned[clientIdx] = true;

	// if their first spawn, delay their first game by N seconds so they can read the help menu in peace
	if (DC_RoundStarts <= 1) // but not folks who were in the preround, as they are probably veterans
		DFP_WasInPreRound[clientIdx] = true;
	if (!DFP_WasInPreRound[clientIdx] && !DFP_PlayerSpawnedOnce[clientIdx])
		DFP_AvailableForGameAt[clientIdx] = GetEngineTime() + DC_PostgameDelay;
}

public FinishPlayerSpawned(clientIdx)
{
	// strip all weapons except for melee
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Primary);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Secondary);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Grenade);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Building);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_PDA);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Item1);
	TF2_RemoveWeaponSlot(clientIdx, TFWeaponSlot_Item2);

	// since civilian mode leaves a broken viewmodel, just need to ensure melee is never usable
	new melee = GetPlayerWeaponSlot(clientIdx, TFWeaponSlot_Melee);
	if (IsValidEntity(melee))
	{
		SetEntPropEnt(clientIdx, Prop_Send, "m_hActiveWeapon", melee);
		SetEntityRenderMode(melee, RENDER_TRANSCOLOR);
		SetEntityRenderColor(melee, 255, 255, 255, 0);
		SetEntPropFloat(melee, Prop_Send, "m_flNextPrimaryAttack", GetGameTime() + 999999.0);
	}
	
	// need to hook damage, which is heavily regulated
	if (!DFP_PlayerIsHooked[clientIdx])
	{
		SDKHook(clientIdx, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(clientIdx, SDKHook_GetMaxHealth, DFP_GetMaxHealth);
		DFP_PlayerIsHooked[clientIdx] = true;
	}
	
	// need gravity set to 0.0
	SetEntityGravity(clientIdx, 0.00001);
	
	// move them to the debris collision group
	SetEntProp(clientIdx, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
	
	// move spectators to the appropriate spawn point, a workaround if maps lack Dart Mann's map fix
	// don't do this for heroes or bosses since it's probably already been done by DG_TryStartGame()
	if (DFP_Role[clientIdx] == DFP_ROLE_NONE)
	{
		if (GetClientTeam(clientIdx) == HeroTeam)
			TeleportEntity(clientIdx, DG_HeroSpawns[0], NULL_VECTOR, NULL_VECTOR);
		else
			TeleportEntity(clientIdx, DG_BossSpawns[0], NULL_VECTOR, NULL_VECTOR);
	}
	
	// give them a help popup if this is their first spawn
	if (!DFP_PlayerSpawnedOnce[clientIdx])
	{
		DFP_PlayerSpawnedOnce[clientIdx] = true;
		if (!IsFakeClient(clientIdx))
			FakeClientCommand(clientIdx, CMD_HELP);
	}
}

public OnClientDisconnect(clientIdx)
{
	if (!DC_RoundBegan)
		return;

	if (clientIdx <= 0 || clientIdx >= MAX_PLAYERS)
		return;
		
	DFP_PlayerIsHooked[clientIdx] = false;
}

/**
 * Player Commands
 */
public Action:CmdNever(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	DFP_OptOut[clientIdx] = !DFP_OptOut[clientIdx];
	if (DFP_OptOut[clientIdx])
		CReplyToCommand(clientIdx, "Set to never be Hero or Boss.");
	else
		CReplyToCommand(clientIdx, "Set to be Hero or Boss.");
	
	// don't let tutorial message get in the way of the above
	DFP_NextTutorialMessageAt[clientIdx] += 10.0;
		
	return Plugin_Handled;
}
 
public Action:CmdWantBoss(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	DFP_OptOut[clientIdx] = false;
	if (DFP_PreferredRole[clientIdx] == DFP_ROLE_BOSS)
	{
		DFP_PreferredRole[clientIdx] = DFP_ROLE_NONE;
		CReplyToCommand(clientIdx, "Cleared preferred role.");
	}
	else
	{
		DFP_PreferredRole[clientIdx] = DFP_ROLE_BOSS;
		CReplyToCommand(clientIdx, "Set preferred role to Boss.");
	}
	
	// don't let tutorial message get in the way of the above
	DFP_NextTutorialMessageAt[clientIdx] += 10.0;
		
	return Plugin_Handled;
}
 
public Action:CmdWantHero(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	DFP_OptOut[clientIdx] = false;
	if (DFP_PreferredRole[clientIdx] == DFP_ROLE_HERO)
	{
		DFP_PreferredRole[clientIdx] = DFP_ROLE_NONE;
		CReplyToCommand(clientIdx, "Cleared preferred role.");
	}
	else
	{
		DFP_PreferredRole[clientIdx] = DFP_ROLE_HERO;
		CReplyToCommand(clientIdx, "Set preferred role to Hero.");
	}
	
	// don't let tutorial message get in the way of the above
	DFP_NextTutorialMessageAt[clientIdx] += 10.0;

	return Plugin_Handled;
}

public Action:CmdWantAny(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	DFP_OptOut[clientIdx] = false;
	DFP_PreferredRole[clientIdx] = DFP_ROLE_NONE;
	CReplyToCommand(clientIdx, "Cleared preferred role.");
	
	// don't let tutorial message get in the way of the above
	DFP_NextTutorialMessageAt[clientIdx] += 10.0;

	return Plugin_Handled;
}

public Action:CmdHero(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	new Handle:menu = CreateMenu(Handler_HeroMenu);
	if (DFP_PreferredHero[clientIdx] == -1)
		SetMenuTitle(menu, "Choose a hero! (currently Random)");
	else
		SetMenuTitle(menu, "Choose a hero! (currently %s)", CL_HeroNames[DFP_PreferredHero[clientIdx]]);

	for (new heroIdx = -1; heroIdx < CL_NumHeroes; heroIdx++)
	{
		static String:intS[5];
		IntToString(heroIdx, intS, sizeof(intS));
		if (heroIdx == -1)
			AddMenuItem(menu, intS, "Random hero", ITEMDRAW_DEFAULT);
		else
			AddMenuItem(menu, intS, CL_HeroNames[heroIdx], (DFP_AccessLevel[clientIdx] < CL_HeroAccess[heroIdx]) ? (CL_HeroAccess[heroIdx] >= CL_ACCESS_ADMIN ? ITEMDRAW_IGNORE : ITEMDRAW_DISABLED) : ITEMDRAW_DEFAULT);
	}
	DisplayMenu(menu, clientIdx, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Handler_HeroMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		choice -= 1;
		if (choice >= -1 && choice < CL_NumHeroes)
		{
			DFP_PreferredHero[clientIdx] = choice;
			if (choice == -1)
				CPrintToChat(clientIdx, "Next time you're hero, you'll be a random pick.");
			else
				CPrintToChat(clientIdx, "Next time you're hero, you'll be %s", CL_HeroNames[choice]);
			CP_SavePrefs(clientIdx);
		}
		else
		{
			PrintToServer("[danmaku_fortress] ERROR: Somehow invalid hero choice got through on the chooser: %s", choice);
			CPrintToChat(clientIdx, "Preferred hero pick encountered an error. Your choice has not changed.");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
 
public Action:CmdBoss(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	new Handle:menu = CreateMenu(Handler_BossMenu);
	if (DFP_PreferredBoss[clientIdx] == -1)
		SetMenuTitle(menu, "Choose a boss! (currently Random)");
	else
		SetMenuTitle(menu, "Choose a boss! (currently %s)", CL_BossNames[DFP_PreferredBoss[clientIdx]]);

	for (new bossIdx = -1; bossIdx < CL_NumBosses; bossIdx++)
	{
		static String:intS[5];
		IntToString(bossIdx, intS, sizeof(intS));
		if (bossIdx == -1)
			AddMenuItem(menu, intS, "Random boss", ITEMDRAW_DEFAULT);
		else
			AddMenuItem(menu, intS, CL_BossNames[bossIdx], (DFP_AccessLevel[clientIdx] < CL_BossAccess[bossIdx]) ? (CL_BossAccess[bossIdx] >= CL_ACCESS_ADMIN ? ITEMDRAW_IGNORE : ITEMDRAW_DISABLED) : ITEMDRAW_DEFAULT);
	}
	DisplayMenu(menu, clientIdx, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Handler_BossMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		choice -= 1;
		if (choice >= -1 && choice < CL_NumBosses)
		{
			DFP_PreferredBoss[clientIdx] = choice;
			if (choice == -1)
				CPrintToChat(clientIdx, "Next time you're boss, you'll be a random pick.");
			else
				CPrintToChat(clientIdx, "Next time you're boss, you'll be %s", CL_BossNames[choice]);
			CP_SavePrefs(clientIdx);
		}
		else
		{
			PrintToServer("[danmaku_fortress] ERROR: Somehow invalid boss choice got through on the chooser: %s", choice);
			CPrintToChat(clientIdx, "Preferred boss pick encountered an error. Your choice has not changed.");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
 
public Action:CmdQueue(clientIdx, args)
{
	if (clientIdx <= 0)
	{
		PrintToServer("This command is not available from the server console.");
		return Plugin_Handled;
	}

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	static bool:listed[MAX_PLAYERS_ARRAY];
	new stillUnlisted = 0;
	for (new player = 1; player < MAX_PLAYERS; player++)
	{
		if (!IsLivingPlayer(player) || DFP_QueuePoints[player] < 0)
			listed[player] = true;
		else if (DFP_OptOut[player])
			listed[player] = true;
		else if (DFP_Role[player] == DFP_ROLE_HERO || DFP_Role[player] == DFP_ROLE_BOSS)
			listed[player] = true;
		else
		{
			listed[player] = false;
			stillUnlisted++;
		}
	}
	
	// list the ones worth listing
	new totalListed = stillUnlisted;
	new clientPosition = -1;
	while (stillUnlisted > 0)
	{
		new currentMax = -1;
		new maxPlayer = 1;
		for (new player = 1; player < MAX_PLAYERS; player++)
		{
			if (!listed[player] && DFP_QueuePoints[player] > currentMax)
			{
				currentMax = DFP_QueuePoints[player];
				maxPlayer = player;
			}
		}
		
		
		static String:playerName[65];
		GetClientName(maxPlayer, playerName, sizeof(playerName));
		CReplyToCommand(clientIdx, "%s - %d", playerName, currentMax);
		stillUnlisted--;
		listed[maxPlayer] = true;
		
		if (maxPlayer == clientIdx)
			clientPosition = totalListed - stillUnlisted;
	}
	
	// ending with the player's own points and position in line, since that's what users mainly care about
	if (clientPosition == -1)
	{
		CReplyToCommand(clientIdx, "You have %d queue points. You are currently not in line.", DFP_QueuePoints[clientIdx]);
		if (DFP_OptOut[clientIdx])
			CReplyToCommand(clientIdx, "You are currently set to opt-out. Type %s to change this setting.", CMD_NEVER);
		else if (!IsLivingPlayer(clientIdx))
			CReplyToCommand(clientIdx, "You cannot become boss or hero while in spectate.");
		else if (DFP_Role[clientIdx] == DFP_ROLE_HERO || DFP_Role[clientIdx] == DFP_ROLE_BOSS)
			CReplyToCommand(clientIdx, "You cannot obtain queue points while you're in a match.");
	}
	else
		CReplyToCommand(clientIdx, "You have %d queue points. You are at position %d in line.", DFP_QueuePoints[clientIdx], clientPosition);

	// don't let tutorial message get in the way of the above
	DFP_NextTutorialMessageAt[clientIdx] += 30.0; // longer than the others since this one's a bit of a read

	return Plugin_Handled;
}

public Action:CmdMusic(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}
	else if (!DC_RoundBegan)
	{
		CReplyToCommand(clientIdx, "%s is still in the pre-round. You can set music once that's over.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	static String:unparsedArgs[10];
	unparsedArgs[0] = 0;
	GetCmdArgString(unparsedArgs, sizeof(unparsedArgs));
	
	if (IsEmptyString(unparsedArgs) || StrContains(unparsedArgs, "p") == 0)
	{
		new Handle:menu = CreateMenu(Handler_MusicMenu);
		SetMenuTitle(menu, "Choose a song!");
		
		for (new songIdx = -2; songIdx < ML_NumSongs; songIdx++)
		{
			static String:intS[5];
			IntToString(songIdx, intS, sizeof(intS));
			
			if (songIdx == -2)
				AddMenuItem(menu, intS, "Never play music", ITEMDRAW_DEFAULT);
			else if (songIdx == -1)
				AddMenuItem(menu, intS, "Random shuffle", ITEMDRAW_DEFAULT);
			else
			{
				static String:songName[40];
				new len = strlen(ML_Song[songIdx]);
				new dotPos = len - 1;
				for (; ML_Song[songIdx][dotPos] != '.'; dotPos--)
					if (dotPos < 0)
						break;
				new slashPos = dotPos;
				for (; ML_Song[songIdx][slashPos] != '\\' && ML_Song[songIdx][slashPos] != '/'; slashPos--)
					if (slashPos < 0)
						break;
				
				// get substring if possible
				if (slashPos >= 0)
					substr(songName, sizeof(songName), ML_Song[songIdx], slashPos + 1, dotPos);
				else
					strcopy(songName, sizeof(songName), ML_Song[songIdx]);
				AddMenuItem(menu, intS, songName, ITEMDRAW_DEFAULT);
			}
		}
		
		DisplayMenu(menu, clientIdx, MENU_TIME_FOREVER); // so uh...is this integer seconds? milliseconds? going with forever I guess.
		return Plugin_Handled;
	}
	
	OnCmdMusicResult(clientIdx, StringToInt(unparsedArgs));
		
	return Plugin_Handled;
}

public Handler_MusicMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		OnCmdMusicResult(clientIdx, choice - 2);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public OnCmdMusicResult(clientIdx, choice)
{
	if (choice == -2) // never
		DFP_DisableMusic(clientIdx);
	else if (choice == -1) // random
		DFP_PlayMusic(clientIdx, -1, true);
	else if (choice >= 0 && choice < ML_NumSongs) // specific choice
		DFP_PlayMusic(clientIdx, choice, false);
}

public Action:CmdTP(clientIdx, args)
{
	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	if (DFP_ThirdPersonSmxExists)
	{
		CReplyToCommand(clientIdx, "Your server already has the thirdperson plugin. Use {yellow}/tp{default} instead.");
		return Plugin_Handled;
	}
	
	DFP_ThirdPerson[clientIdx] = true;
	return Plugin_Handled;
}

public Action:CmdFP(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}

	if (DFP_ThirdPersonSmxExists)
	{
		CReplyToCommand(clientIdx, "Your server already has the thirdperson plugin. Use {yellow}/fp{default} instead.");
		return Plugin_Handled;
	}

	DFP_ThirdPerson[clientIdx] = false;
	return Plugin_Handled;
}

public Action:CmdHelp(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}
	
	new Handle:menu = CreateMenu(Handler_HelpMenu);
	SetMenuTitle(menu, "Welcome to %s! (main menu: /%s)", DC_PLUGIN_NAME, CMD_HELP);
	AddMenuItem(menu, "one", "Print a list of controls.", ITEMDRAW_DEFAULT);

	if (DFP_OptOut[clientIdx])
		AddMenuItem(menu, "two", "Playing preferences (currently opting out)", ITEMDRAW_DEFAULT);
	else if (DFP_PreferredRole[clientIdx] == DFP_ROLE_HERO)
		AddMenuItem(menu, "two", "Playing preferences (currently prefer hero)", ITEMDRAW_DEFAULT);
	else if (DFP_PreferredRole[clientIdx] == DFP_ROLE_BOSS)
		AddMenuItem(menu, "two", "Playing preferences (currently prefer boss)", ITEMDRAW_DEFAULT);
	else
		AddMenuItem(menu, "two", "Playing preferences (currently no preferences)", ITEMDRAW_DEFAULT);

	if (DFP_AutoFire[clientIdx])
		AddMenuItem(menu, "thr", "Disable autofire: /df_autofire", ITEMDRAW_DEFAULT);
	else
		AddMenuItem(menu, "thr", "Enable autofire: /df_autofire", ITEMDRAW_DEFAULT);
		
	AddMenuItem(menu, "fou", "Select a hero: /df_hero", ITEMDRAW_DEFAULT);
	AddMenuItem(menu, "fiv", "Select a boss: /df_boss", ITEMDRAW_DEFAULT);
	AddMenuItem(menu, "six", "Change difficulty: /df_difficulty", ITEMDRAW_DEFAULT);
	DisplayMenu(menu, clientIdx, MENU_TIME_FOREVER); // so uh...is this integer seconds? milliseconds? going with forever I guess.
	return Plugin_Handled;
}

public Handler_HelpMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		if (choice == 0)
			PrintHelp(clientIdx);
		else if (choice == 1)
		{
			new Handle:newMenu = CreateMenu(Handler_PPMenu);
			SetMenuTitle(newMenu, "Playing Preferences", DC_PLUGIN_NAME, CMD_HELP);
			AddMenuItem(newMenu, "one", "Clear preference: /df_wantany", ITEMDRAW_DEFAULT);
			AddMenuItem(newMenu, "two", "Prefer hero: /df_wanthero", ITEMDRAW_DEFAULT);
			AddMenuItem(newMenu, "thr", "Prefer boss: /df_wantboss", ITEMDRAW_DEFAULT);
			if (DFP_OptOut[clientIdx])
				AddMenuItem(newMenu, "fou", "Disable opt out: /df_never", ITEMDRAW_DEFAULT);
			else
				AddMenuItem(newMenu, "fou", "Never be hero or boss: /df_never", ITEMDRAW_DEFAULT);
			DisplayMenu(newMenu, clientIdx, MENU_TIME_FOREVER); // so uh...is this integer seconds? milliseconds? going with forever I guess.
		}
		else if (choice == 2)
			FakeClientCommand(clientIdx, CMD_AUTOFIRE);
		else if (choice == 3)
			FakeClientCommand(clientIdx, CMD_HERO);
		else if (choice == 4)
			FakeClientCommand(clientIdx, CMD_BOSS);
		else if (choice == 5)
			FakeClientCommand(clientIdx, CMD_DIFFICULTY);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public PrintHelp(clientIdx)
{
	CPrintToChat(clientIdx, "Welcome to {aqua}%s{default} v%s, coded by sarysa", DC_PLUGIN_NAME, PLUGIN_VERSION);
	CPrintToChat(clientIdx, "Basic controls: WASD to move around, hold JUMP to move up, RIGHT MOUSE to move down.");
	CPrintToChat(clientIdx, "LEFT MOUSE to attack. (hero can hold)");
	CPrintToChat(clientIdx, "RELOAD to set abilities. (usually boss only)");
	CPrintToChat(clientIdx, "E to use bomb. (hard/lunatic only)");
	CPrintToChat(clientIdx, "MIDDLE MOUSE or CROUCH for slow movement.");
	CPrintToChat(clientIdx, "Mode is based on Bullet Hell, play as hero or boss.");
	CPrintToChat(clientIdx, "Type {yellow}/%s{default} to open the help menu again.", CMD_HELP);
}

public Handler_PPMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		if (choice == 0)
			FakeClientCommand(clientIdx, CMD_WANT_ANY);
		else if (choice == 1)
			FakeClientCommand(clientIdx, CMD_WANT_HERO);
		else if (choice == 2)
			FakeClientCommand(clientIdx, CMD_WANT_BOSS);
		else if (choice == 3)
			FakeClientCommand(clientIdx, CMD_NEVER);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:CmdTutorial(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}
	
	new originalIdx = DFP_NextTutorialMessage[clientIdx];
	do
	{
		DFP_PrintTutorial(clientIdx);
	} while (originalIdx != DFP_NextTutorialMessage[clientIdx]);
	return Plugin_Handled;
}

public Action:CmdDifficulty(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}
	
	new Handle:menu = CreateMenu(Handler_DifficultyMenu);
	SetMenuTitle(menu, "Difficulty Menu: /%s", CMD_DIFFICULTY);
	AddMenuItem(menu, "one", "Normal - bombs save you", ITEMDRAW_DEFAULT);
	AddMenuItem(menu, "two", "Hard - must use bombs manually", ITEMDRAW_DEFAULT);
	AddMenuItem(menu, "thr", "Lunatic - manual bombs and gain none on death", ITEMDRAW_DEFAULT);
	DisplayMenu(menu, clientIdx, MENU_TIME_FOREVER); // so uh...is this integer seconds? milliseconds? going with forever I guess.
	
	return Plugin_Handled;
}

public Handler_DifficultyMenu(Handle:menu, MenuAction:action, clientIdx, choice)
{
	if (action == MenuAction_Select)
	{
		DFP_Difficulty[clientIdx] = choice;
		CP_SavePrefs(clientIdx);
		if (DFP_Difficulty[clientIdx] == DFP_DIFFICULTY_HARD)
			CPrintToChat(clientIdx, "{orange}Hard Mode{default} enabled. Must press {green}E{default} to activate bomb. Will take effect when your next match begins. Type {aqua}/%s{default} to change.", CMD_DIFFICULTY);
		else if (DFP_Difficulty[clientIdx] == DFP_DIFFICULTY_LUNATIC)
			CPrintToChat(clientIdx, "{red}Lunatic Mode{default} enabled. Must press {green}E{default} to activate bomb, and you get none on new life. Will take effect when your next match begins. Type {aqua}/%s{default} to change.", CMD_DIFFICULTY);
		else
			CPrintToChat(clientIdx, "{green}Normal Mode enabled. Bombs will save you if you're hit. Will take effect when your next match begins. Type {aqua}/%s{default} to change.", CMD_DIFFICULTY);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:CmdAutoFire(clientIdx, args)
{
	if (clientIdx <= 0)
		return Plugin_Handled;

	if (!DC_IsEnabled)
	{
		CReplyToCommand(clientIdx, "%s is not currently enabled.", DC_PLUGIN_NAME);
		return Plugin_Handled;
	}
	
	DFP_AutoFire[clientIdx] = !DFP_AutoFire[clientIdx];
	CP_SavePrefs(clientIdx);
	if (DFP_AutoFire[clientIdx])
		CReplyToCommand(clientIdx, "Auto-fire is now {green}ON{default}. Hold LMB to stop firing. It is only enabled for the hero.");
	else
		CReplyToCommand(clientIdx, "Auto-fire is now {red}OFF{default}. Hold LMB to fire. It is only enabled for the hero.");
	return Plugin_Handled;
}

public Action:KillCommands(clientIdx, const String:command[], argc)
{
	if (!DC_IsEnabled)
		return Plugin_Continue;

	new bool:isHero;
	new gameIdx = DFP_FindCurrentGame(clientIdx, isHero);
	if (gameIdx >= 0)
	{
		if (isHero && IsValidPlayer(DG_BossClient[gameIdx]))
		{
			RemoveInvincibility(DG_HeroClient[gameIdx]);
			SDKHooks_TakeDamage(DG_HeroClient[gameIdx], DG_BossClient[gameIdx], DG_BossClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
			return Plugin_Handled;
		}
		else if (!isHero && IsValidPlayer(DG_HeroClient[gameIdx]))
		{
			RemoveInvincibility(DG_BossClient[gameIdx]);
			SDKHooks_TakeDamage(DG_BossClient[gameIdx], DG_HeroClient[gameIdx], DG_HeroClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:MedicCommand(clientIdx, const String:command[], argc)
{
	if (!DC_RoundBegan)
		return Plugin_Continue;
		
	new String:unparsedArgs[4];
	GetCmdArgString(unparsedArgs, 4);
	if (strcmp(unparsedArgs, "0 0") != 0)
		return Plugin_Continue;
	
	new bool:isHero = false;
	new gameIdx = DFP_FindCurrentGame(clientIdx, isHero);
	if (gameIdx < 0)
		return Plugin_Continue;
	else if (DG_CountdownHUD[gameIdx] > 0) // translation: game hasn't fully started yet
	{
		return Plugin_Continue;
	}
	else if (!isHero)
	{
		CPrintToChat(clientIdx, "The boss doesn't have any E ability. Press LEFT MOUSE to use abilities.");
		return Plugin_Continue;
	}
	else if (DG_HeroAutoBomb[gameIdx])
	{
		CPrintToChat(clientIdx, "You can only manually activate bombs on Hard or Lunatic modes.");
		return Plugin_Continue;
	}

	if (DG_HeroBombs[gameIdx] <= 0)
		CPrintToChat(clientIdx, "Out of bombs!");
	else
	{
		DG_UseBomb(gameIdx);

		// to avoid any race condition, remove pending hit against hero
		DG_HeroHitPending[gameIdx] = false;
	}
	
	return Plugin_Continue;
}

/**
 * Admin Commands
 */
public Action:CmdCvars(clientIdx, args)
{
	AutoExecConfig(true, DC_CVAR_CONFIG);
	CReplyToCommand(clientIdx, "%s cvars reloaded.", DC_PLUGIN_NAME);
}

public Action:CmdBotLogic(clientIdx, args)
{
	if (!DC_IsEnabled)
		return Plugin_Handled;

	BL_IsEnabled = !BL_IsEnabled;
	if (!BL_IsEnabled)
	{
		CReplyToCommand(clientIdx, "Bot logic disabled.");
	}
	else
	{
		new Float:curTime = GetEngineTime();
	
		CReplyToCommand(clientIdx, "Bot logic enabled.");
		for (new bot = 1; bot < MAX_PLAYERS; bot++)
		{
			if (!IsValidPlayer(bot))
				continue;
				
			BL_IsAffected[bot] = IsFakeClient(bot);
			if (BL_IsAffected[bot])
			{
				BL_NextChangeAt[bot] = curTime;
				BL_CurrentCombatKey[bot] = -1;
				BL_CurrentFBKey[bot] = -1;
				BL_CurrentLRKey[bot] = -1;
				BL_CurrentUDKey[bot] = -1;
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:CmdAddPoints(clientIdx, args)
{
	static String:partialName[65];
	GetCmdArg(1, partialName, sizeof(partialName));
	static String:intS[12];
	GetCmdArg(2, intS, sizeof(intS));
	new points = StringToInt(intS);
	
	new targetClient = FindUser(partialName, sizeof(partialName), clientIdx);
	if (!IsValidPlayer(targetClient))
		return Plugin_Handled;

	// yes, this version deliberately allows negatives
	GetClientName(targetClient, partialName, sizeof(partialName));
	DFP_QueuePoints[targetClient] += points;
	if (points >= 0)
		CReplyToCommand(clientIdx, "Gave %d queue points to %s", points, partialName);
	else
		CReplyToCommand(clientIdx, "Took %d queue points from %s", abs(points), partialName);

	// save changes to the points
	CP_SavePrefs(targetClient);
		
	return Plugin_Handled;
}

// used by the two commands below
public FindCharacter(clientIdx, String:search[MAX_AESTHETIC_NAME_LENGTH], String:nameArray[][MAX_AESTHETIC_NAME_LENGTH], String:cfgArray[][MAX_CONFIG_NAME_LENGTH], maxCharacters)
{
	new foundCount = 0;
	static bool:found[200];
	new lastFound = -1;
	for (new i = 0; i < maxCharacters; i++)
	{
		PrintToServer("%s vs %s and %s", search, nameArray[i], cfgArray[i]);
		found[i] = StrContains(nameArray[i], search, false) != -1 || StrContains(cfgArray[i], search, false) != -1;
		if (found[i])
		{
			foundCount++;
			lastFound = i;
		}
	}
	
	if (foundCount > 1)
	{
		CReplyToCommand(clientIdx, "Found %d characters that match: %s", foundCount, search);
		for (new i = 0; i < maxCharacters; i++)
			if (found[i])
				CReplyToCommand(clientIdx, "%s (%s)", nameArray, cfgArray);
		return -1;
	}
	else if (foundCount == 0)
		CReplyToCommand(clientIdx, "No character match found for %s (out of %d characters total)", search, maxCharacters);
	
	return lastFound;
}

public Action:CmdForceHero(clientIdx, args)
{
	static String:partialName[65];
	GetCmdArg(1, partialName, sizeof(partialName));
	static String:characterName[MAX_AESTHETIC_NAME_LENGTH];
	GetCmdArg(2, characterName, sizeof(characterName));
	
	new targetClient = FindUser(partialName, sizeof(partialName), clientIdx);
	if (!IsValidPlayer(targetClient))
		return Plugin_Handled;
		
	new character = FindCharacter(clientIdx, characterName, CL_HeroNames, CL_HeroConfigNames, CL_NumHeroes);
	if (character == -1)
		return Plugin_Handled;
		
	GetClientName(targetClient, partialName, sizeof(partialName));
	DFP_PreferredHero[targetClient] = character;
	DFP_HeroPickAdminOverride[targetClient] = true;
	CReplyToCommand(clientIdx, "Next time %s is hero, they will be %s (%s)", partialName, CL_HeroNames[character], CL_HeroConfigNames[character]);
	return Plugin_Handled;
}

public Action:CmdForceBoss(clientIdx, args)
{
	static String:partialName[65];
	GetCmdArg(1, partialName, sizeof(partialName));
	static String:characterName[MAX_AESTHETIC_NAME_LENGTH];
	GetCmdArg(2, characterName, sizeof(characterName));
	
	new targetClient = FindUser(partialName, sizeof(partialName), clientIdx);
	if (!IsValidPlayer(targetClient))
		return Plugin_Handled;
		
	new character = FindCharacter(clientIdx, characterName, CL_BossNames, CL_BossConfigNames, CL_NumBosses);
	if (character == -1)
		return Plugin_Handled;
		
	GetClientName(targetClient, partialName, sizeof(partialName));
	DFP_PreferredBoss[targetClient] = character;
	DFP_BossPickAdminOverride[targetClient] = true;
	CReplyToCommand(clientIdx, "Next time %s is boss, they will be %s (%s)", partialName, CL_BossNames[character], CL_BossConfigNames[character]);
	return Plugin_Handled;
}

public Action:CmdAdminWorkaround(clientIdx, args)
{
	PrintToConsole(clientIdx, "[danmaku_fortress] Oh hey, you found the hidden command. Doesn't matter, you're already authorized as an admin for this session.");
	DFP_AccessLevel[clientIdx] = CL_ACCESS_ADMIN;
	if (PRINT_DEBUG_SPAM)
		PrintToServer("[danmaku_fortress] Client %d is an admin, and will have access to admin-only characters.", clientIdx);
	return Plugin_Handled;
}

/**
 * Debug Mode Commands
 */
public Action:CmdForceFire(clientIdx, args)
{
	if (!DC_IsEnabled)
		return Plugin_Handled;

	new bool:isHero;
	new gameIdx = DFP_FindCurrentGame(clientIdx, isHero);
	if (gameIdx < 0)
		CPrintToChat(clientIdx, "You aren't in a game.");
	else
	{
		CPrintToChat(clientIdx, "Forcing enemy to fire.");
		if (isHero)
			DG_BossAbilityPending[gameIdx] = true;
		else
			DG_HeroAbilityPending[gameIdx] = true;
	}
	
	return Plugin_Handled;
}

public Action:CmdIterate(clientIdx, args)
{
	if (!DC_IsEnabled)
		return Plugin_Handled;

	new bool:isHero;
	new gameIdx = DFP_FindCurrentGame(clientIdx, isHero);
	if (gameIdx < 0)
		CPrintToChat(clientIdx, "You aren't in a game.");
	else
	{
		CPrintToChat(clientIdx, "Forcing enemy to iterate to the next ability.");
		DG_IterateAbilityPressed(gameIdx, !isHero, false);
	}
	
	return Plugin_Handled;
}

/**
 * Danmaku Core
 */
public DC_OnConVarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	// just reload em all.
	DC_TutorialInterval = GetConVarFloat(DC_CvarTutorialInterval);
	DC_StartDelay = GetConVarFloat(DC_CvarStartDelay);
	DC_InvincibilityDurationNewLife = GetConVarFloat(DC_CvarNewLifeInvincible);
	DC_InvincibilityDurationBomb = GetConVarFloat(DC_CvarBombInvincible);
	DC_VerticalMultiplier = GetConVarFloat(DC_CvarVerticalMultiplier);
	DC_PostgameDelay = GetConVarFloat(DC_CvarPostgameDelay);
	DC_UseParticle = GetConVarBool(DC_CvarUseParticle);
	DC_MaxGamesAdminSetting = GetConVarInt(DC_CvarMaxGames);
	DC_QueuePointGraceTime = GetConVarFloat(DC_CvarQueuePointGraceTime);
	DC_QueuePointsWait = GetConVarInt(DC_CvarQueuePointsWait);
	DC_QueuePointsWin = GetConVarInt(DC_CvarQueuePointsWin);
	DC_QueuePointsLose = GetConVarInt(DC_CvarQueuePointsLose);
	DC_QueuePointsStalemate	= GetConVarInt(DC_CvarQueuePointsStalemate);
	DC_QueuePointsEarlyForfeitMultiplier = GetConVarFloat(DC_CvarQueuePointsEarlyForfeitMultiplier);
	DC_QueuePointsForfeittedAgainstMultiplier = GetConVarFloat(DC_CvarQueuePointsForfeittedAgainstMultiplier);
	DC_HeroNormalMaxScore = GetConVarFloat(DC_CvarHeroNormalMaxScore);
	DC_HeroHardMaxScore = GetConVarFloat(DC_CvarHeroHardMaxScore);
	DC_HeroLunaticMaxScore = GetConVarFloat(DC_CvarHeroLunaticMaxScore);
	DC_BossNormalMaxScore = GetConVarFloat(DC_CvarBossNormalMaxScore);
	DC_BossHardMaxScore = GetConVarFloat(DC_CvarBossHardMaxScore);
	DC_BossLunaticMaxScore = GetConVarFloat(DC_CvarBossLunaticMaxScore);
	GetConVarString(DC_CvarHeroAbilityTerminology, DC_HeroAbilityTerminology, MAX_AESTHETIC_NAME_LENGTH);
	GetConVarString(DC_CvarBossAbilityTerminology, DC_BossAbilityTerminology, MAX_AESTHETIC_NAME_LENGTH);
	DC_HeroProjectileResize = GetConVarFloat(DC_CvarHeroProjectileResize);

	// warn whoever's using the console
	if (cvar != INVALID_HANDLE)
	{
		PrintToServer("[danmaku_fortress] Please note that the convar change you just made is only temporary. To make permanent changes, edit [serverdir]/tf2/tf/cfg/sourcemod/%s.cfg and then type %s in console.", DC_CVAR_CONFIG, CMD_CVARS);
		if (cvar == DC_CvarMaxGames)
			PrintToServer("[danmaku_fortress] Also, %s can't be changed once the map has started. You'll have to change the map to change the number of games.", CVAR_MAX_GAMES);
	}
}

/**
 * Bot "Logic" (putting it here since it's a subset of DFP below)
 */
public BL_TickBot(bot, Float:curTime)
{
	if (!BL_IsAffected[bot] || !BL_IsEnabled)
		return;
	
	new bool:isHero;
	new gameIdx = DFP_FindCurrentGame(bot, isHero);
	if (gameIdx < 0)
		return;

	// hero always fires
	if (isHero)
		BL_CurrentCombatKey[bot] = BL_COMBAT_USE_ABILITY;
		
	if (curTime >= BL_NextChangeAt[bot])
	{
		BL_NextChangeAt[bot] = curTime + (GetRandomFloat(0.75, 1.5));
		if (!isHero)
			BL_CurrentCombatKey[bot] = GetRandomInt(0, 2);
		BL_CurrentFBKey[bot] = GetRandomInt(0, 3); // 50% chance of moving on this axis
		BL_CurrentLRKey[bot] = GetRandomInt(0, 3); // 50% chance of moving on this axis
		BL_CurrentUDKey[bot] = GetRandomInt(0, 5); // 33% chance of moving on this axis
		
		// need to make logic bias keeping on their side
		if (BL_CurrentFBKey[bot] == BL_FB_FORWARD && GetRandomInt(0, 1) != 0)
			BL_CurrentFBKey[bot] = BL_FB_BACK;
	}
}

public BL_AdjustBotButtons(bot, &buttons)
{
	if (!BL_IsAffected[bot] || !BL_IsEnabled)
		return;
		
	// clear buttons even on those in spectate
	buttons = 0;
	if (DFP_Role[bot] != DFP_ROLE_BOSS && DFP_Role[bot] != DFP_ROLE_HERO)
		return;
		
	// combat keys are expended each frame
	if (BL_CurrentCombatKey[bot] == BL_COMBAT_USE_ABILITY)
		buttons |= IN_ATTACK;
	else if (BL_CurrentCombatKey[bot] == BL_COMBAT_ITERATE)
		buttons |= IN_RELOAD;
	BL_CurrentCombatKey[bot] = BL_COMBAT_NONE;
	
	// movement keys are not
	if (BL_CurrentFBKey[bot] == BL_FB_FORWARD)
		buttons |= IN_FORWARD;
	else if (BL_CurrentFBKey[bot] == BL_FB_BACK)
		buttons |= IN_BACK;
	if (BL_CurrentLRKey[bot] == BL_LR_LEFT)
		buttons |= IN_MOVELEFT;
	else if (BL_CurrentLRKey[bot] == BL_LR_RIGHT)
		buttons |= IN_MOVERIGHT;
	if (BL_CurrentUDKey[bot] == BL_UD_UP)
		buttons |= IN_JUMP;
	else if (BL_CurrentUDKey[bot] == BL_UD_DOWN)
		buttons |= IN_ATTACK2;
}

/**
 * Client Preferences
 */
// I'm opting to make it as plaintext as possible. Plus I don't think I have a choice, seeing how 0 terminates the string.
// Easy enough since most options are booleans and ints.
new String:CP_TmpPrefs[256];
public OnClientCookiesCached(clientIdx)
{
	CP_PrefsLoaded[clientIdx] = true;
	CP_LoadPrefs(clientIdx);

	if (DC_IsEnabled && PRINT_DEBUG_SPAM)
	{
		PrintToServer("%d has connected and preferences have loaded. (admin=%d) difficulty %d, autofire %d, hero %d, boss %d", clientIdx, DFP_AccessLevel[clientIdx], DFP_Difficulty[clientIdx], DFP_AutoFire[clientIdx], DFP_PreferredHero[clientIdx], DFP_PreferredBoss[clientIdx]);
		PrintToServer("prefs str: %s", CP_TmpPrefs);
	}
}

CP_ReadInt(&pos, const digits)
{
	new bool:isNegative = CP_TmpPrefs[pos] == '-';
	pos++;
	
	new ret = 0;
	for (new remaining = digits - 1; remaining >= 0; remaining--)
	{
		new part = CP_TmpPrefs[pos] - '0';
		pos++;
		for (new i = 0; i < remaining; i++)
			part *= 10;
		ret += part;
	}
	return isNegative ? -ret : ret;
}

CP_WriteInt(&pos, const digits, contents)
{
	CP_TmpPrefs[pos] = (contents < 0 ? '-' : ' ');
	pos++;
	contents = abs(contents);
	
	for (new remaining = digits - 1; remaining >= 0; remaining--)
	{
		new divisor = 1;
		for (new i = 0; i < remaining; i++)
			divisor *= 10;
		new part = (contents / divisor) % 10;
		CP_TmpPrefs[pos] = part + '0';
		pos++;
	}
}

CP_LoadPrefs(clientIdx)
{
	if (!CP_PrefsLoaded[clientIdx])
		return;
		
	for (new i = 0; i < sizeof(CP_TmpPrefs); i++)
		CP_TmpPrefs[i] = 0;
		
	GetClientCookie(clientIdx, CP_CookieHandle, CP_TmpPrefs, sizeof(CP_TmpPrefs));
	
	new pos = 0;
	if (CP_TmpPrefs[pos] == 0) return;
	DFP_Difficulty[clientIdx] = CP_TmpPrefs[pos] - '0';		pos++;	if (CP_TmpPrefs[pos] == 0) return;
	DFP_AutoFire[clientIdx] = CP_TmpPrefs[pos] == '1';		pos++;	if (CP_TmpPrefs[pos] == 0) return;
	DFP_PreferredHero[clientIdx] = CP_ReadInt(pos, 3);
	if (DFP_PreferredHero[clientIdx] >= CL_NumHeroes)
		DFP_PreferredHero[clientIdx] = -1;
	if (CP_TmpPrefs[pos] == 0) return;
	DFP_PreferredBoss[clientIdx] = CP_ReadInt(pos, 3);
	if (DFP_PreferredBoss[clientIdx] >= CL_NumBosses)
		DFP_PreferredBoss[clientIdx] = -1;
	if (CP_TmpPrefs[pos] == 0) return;
	DFP_QueuePoints[clientIdx] = CP_ReadInt(pos, 3);
	if (CP_TmpPrefs[pos] == 0) return;
	DFP_LifetimeScore[clientIdx] = CP_ReadInt(pos, 9);
	if (CP_TmpPrefs[pos] == 0) return;
}

CP_SavePrefs(clientIdx)
{
	if (!CP_PrefsLoaded[clientIdx])
		return;

	for (new i = 0; i < sizeof(CP_TmpPrefs); i++)
		CP_TmpPrefs[i] = 0;
		
	new pos = 0;
	CP_TmpPrefs[pos] = DFP_Difficulty[clientIdx] + '0';		pos++;
	CP_TmpPrefs[pos] = (DFP_AutoFire[clientIdx] ? '1' : '0');	pos++;
	CP_WriteInt(pos, 3, DFP_PreferredHero[clientIdx]);
	CP_WriteInt(pos, 3, DFP_PreferredBoss[clientIdx]);
	clamp(DFP_QueuePoints[clientIdx], -999, 999);
	CP_WriteInt(pos, 3, DFP_QueuePoints[clientIdx]);
	CP_WriteInt(pos, 9, DFP_LifetimeScore[clientIdx]);
	CP_TmpPrefs[pos] = 0; // no more preferences. yet.
	
	SetClientCookie(clientIdx, CP_CookieHandle, CP_TmpPrefs);
}

public OnClientPostAdminCheck(clientIdx)
{
	FakeClientCommand(clientIdx, CMD_ADMINWORKAROUND);
}

/**
 * Danmaku Fortress Player
 */
// this method is only called by external plugins. it's used to allow setting clients as donators for DF once they've been authorized.
public DFP_ClientIsDonator(clientIdx)
{
	if (!IsClientInGame(clientIdx))
		return;
		
	DFP_AccessLevel[clientIdx] = max(DFP_AccessLevel[clientIdx], CL_ACCESS_DONATOR);
	CPrintToChat(clientIdx, "Your donator has loaded. You should now have access to %s donator bosses.", DC_PLUGIN_NAME);
}
 
public Action:DFP_GetMaxHealth(clientIdx, &maxHealth)
{
	if (!DC_RoundBegan)
		return Plugin_Continue;
		
	if (!IsLivingPlayer(clientIdx))
		return Plugin_Continue;

	if (DFP_Role[clientIdx] == DFP_ROLE_NONE)
		maxHealth = 1;
	else if (DFP_Role[clientIdx] == DFP_ROLE_HERO)
		maxHealth = 1;
	else if (DFP_Role[clientIdx] == DFP_ROLE_BOSS)
	{
		new bool:dummy;
		new gameIdx = DFP_FindCurrentGame(clientIdx, dummy);
		maxHealth = gameIdx == -1 ? 1 : DG_BossMaxHealth[gameIdx];
	}
	else if (DFP_Role[clientIdx] == DFP_ROLE_SURVIVOR)
		maxHealth = 1;
	return Plugin_Changed;
}

public DFP_VerifyPickAllowed(clientIdx, bool:isHero)
{
	if (isHero)
	{
		if (DFP_PreferredHero[clientIdx] >= 0 && CL_HeroAccess[DFP_PreferredHero[clientIdx]] > DFP_AccessLevel[clientIdx])
			DFP_PreferredHero[clientIdx] = -1;
	}
	else if (!isHero)
	{
		if (DFP_PreferredBoss[clientIdx] >= 0 && CL_BossAccess[DFP_PreferredBoss[clientIdx]] > DFP_AccessLevel[clientIdx])
			DFP_PreferredBoss[clientIdx] = -1;
	}
}
 
public DFP_HandleMovementInput(clientIdx, buttons, Float:curTime)
{
	if (curTime < DFP_NextMovementTickAt[clientIdx])
		return;
		
	DFP_NextMovementTickAt[clientIdx] = curTime + DFP_MOVEMENT_TICK_RATE;
	
	// before the complicated stuff, are we in precision mode?
	DFP_KS_Precision[clientIdx] = (buttons & (IN_DUCK | IN_ATTACK3)) != 0;
	
	// state changes for these are currently unimportant
	DFP_KS_Forward[clientIdx] = (buttons & IN_FORWARD) != 0;
	DFP_KS_Back[clientIdx] = (buttons & IN_BACK) != 0;
	DFP_KS_Left[clientIdx] = (buttons & IN_MOVELEFT) != 0;
	DFP_KS_Right[clientIdx] = (buttons & IN_MOVERIGHT) != 0;
	
	// get angle for movement. restricted to 45 degree intervals.
	new bool:isMovingSide = false;
	new Float:angOffset = 0.0;
	if (DFP_KS_Forward[clientIdx])
	{
		angOffset = 0.0;
		isMovingSide = true;
	}
	else if (DFP_KS_Back[clientIdx])
	{
		angOffset = 180.0;
		isMovingSide = true;
	}
	
	if (DFP_KS_Left[clientIdx])
	{
		angOffset = isMovingSide ? (DFP_KS_Forward[clientIdx] ? 45.0 : 135.0) : 90.0;
		isMovingSide = true;
	}
	else if (DFP_KS_Right[clientIdx])
	{
		angOffset = isMovingSide ? (DFP_KS_Forward[clientIdx] ? 315.0 : 225.0) : 270.0;
		isMovingSide = true;
	}
	
	// gonna do it like this for simplicity, movement has instant starts and turns, but sliding stops
	// anything else is waaaay too complicated
	// calculate our old velocity
	static Float:oldVel[3];
	new Float:linearVelocity = SquareRoot(fsquare(DFP_RelativeMaxVel[clientIdx][0]) + fsquare(DFP_RelativeMaxVel[clientIdx][1]));
	if (isMovingSide || linearVelocity <= DFP_VEL_PER_TICK)
	{
		oldVel[0] = 0.0;
		oldVel[1] = 0.0;
	}
	else
	{
		oldVel[0] = DFP_RelativeMaxVel[clientIdx][0] * (linearVelocity - DFP_VEL_PER_TICK) / linearVelocity;
		oldVel[1] = DFP_RelativeMaxVel[clientIdx][1] * (linearVelocity - DFP_VEL_PER_TICK) / linearVelocity;
	}
	
	// and now the velocity to add on
	static Float:velTweak[3];
	if (isMovingSide)
	{
		static Float:angles[3];
		GetClientEyeAngles(clientIdx, angles);
		angles[1] += angOffset;
		angles[0] = 0.0; // toss out pitch
		GetAngleVectors(angles, velTweak, NULL_VECTOR, NULL_VECTOR);
	}
	else
	{
		velTweak[0] = 0.0;
		velTweak[1] = 0.0;
	}
	
	// add em together, and ensure linear velocity doesn't exceed 1
	DFP_RelativeMaxVel[clientIdx][0] = oldVel[0] + velTweak[0];
	DFP_RelativeMaxVel[clientIdx][1] = oldVel[1] + velTweak[1];
	linearVelocity = SquareRoot(fsquare(DFP_RelativeMaxVel[clientIdx][0]) + fsquare(DFP_RelativeMaxVel[clientIdx][1]));
	if (linearVelocity > 1.0)
	{
		DFP_RelativeMaxVel[clientIdx][0] /= linearVelocity;
		DFP_RelativeMaxVel[clientIdx][1] /= linearVelocity;
	}
	
	// the Z axis is independent, but much slower
	DFP_KS_Down[clientIdx] = (buttons & IN_ATTACK2) != 0;
	DFP_KS_Up[clientIdx] = (buttons & IN_JUMP) != 0;
	if (DFP_KS_Down[clientIdx])
		DFP_RelativeMaxVel[clientIdx][2] = -1.0;
	else if (DFP_KS_Up[clientIdx])
		DFP_RelativeMaxVel[clientIdx][2] = 1.0;
	else if (DFP_RelativeMaxVel[clientIdx][2] < 0.0)
		DFP_RelativeMaxVel[clientIdx][2] = fmin(0.0, DFP_RelativeMaxVel[clientIdx][2] + DFP_VEL_PER_TICK);
	else if (DFP_RelativeMaxVel[clientIdx][2] > 0.0)
		DFP_RelativeMaxVel[clientIdx][2] = fmax(0.0, DFP_RelativeMaxVel[clientIdx][2] - DFP_VEL_PER_TICK);
		
	// now adjust their velocity
	static Float:velocity[3];
	velocity[0] = DFP_RelativeMaxVel[clientIdx][0];
	velocity[1] = DFP_RelativeMaxVel[clientIdx][1];
	velocity[2] = DFP_RelativeMaxVel[clientIdx][2] * DC_VerticalMultiplier; // up/down is slower than left/right
	new Float:speed = (DFP_Role[clientIdx] == DFP_ROLE_NONE) ? DFP_SPEC_MAX_SPEED : DFP_MaxSpeed[clientIdx];
	if (DFP_KS_Precision[clientIdx])
		speed *= 0.5;
	ScaleVector(velocity, speed);
	if (GetEntityFlags(clientIdx) & FL_ONGROUND)
		velocity[2] = fmax(velocity[2], 280.0); // need to get off the ground
	TeleportEntity(clientIdx, NULL_VECTOR, NULL_VECTOR, velocity);
	
	// don't allow zero players to move. I'm allowing speed to be below zero since you could use it to reverse player controls.
	if (speed == 0.0)
		SetEntityMoveType(clientIdx, MOVETYPE_NONE);
	else
		SetEntityMoveType(clientIdx, MOVETYPE_WALK);
}

public DFP_FindCurrentGame(clientIdx, &bool:isHero)
{
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		if (DG_HeroClient[gameIdx] == clientIdx)
		{
			isHero = true;
			return gameIdx;
		}
		else if (DG_BossClient[gameIdx] == clientIdx)
		{
			isHero = false;
			return gameIdx;
		}
	}
	
	return -1;
}

public DFP_SpectatorTeleport(clientIdx)
{
	static bool:isValid[MAX_PLAYERS_ARRAY];
	new validCount = 0;
	for (new target = 1; target < MAX_PLAYERS; target++)
	{
		if (!IsLivingPlayer(target))
		{
			isValid[target] = false;
			continue;
		}
		
		isValid[target] = (DFP_Role[target] == DFP_ROLE_HERO || DFP_Role[target] == DFP_ROLE_BOSS);
		if (isValid[target])
			validCount++;
	}

	new randomPlayer = GetRandomInt(0, validCount - 1);
	if (validCount > 0)
	{
		for (new target = 1; target < MAX_PLAYERS; target++)
		{
			if (!isValid[target])
				continue;
				
			validCount--;
			if (validCount == randomPlayer)
			{
				static Float:targetPos[3];
				GetEntPropVector(target, Prop_Send, "m_vecOrigin", targetPos);
				TeleportEntity(clientIdx, targetPos, NULL_VECTOR, Float:{0.0, 0.0, 0.0});
				break;
			}
		}
	}
}

public DFP_HandleCombatInput(clientIdx, buttons, Float:curTime)
{
	// spectators get no combat input
	if (DFP_Role[clientIdx] == DFP_ROLE_NONE)
	{
		// except to move from target to target
		new bool:useAbilityPressed = (buttons & IN_ATTACK) != 0;
		if (useAbilityPressed && !DFP_KS_UseAbility[clientIdx])
			DFP_SpectatorTeleport(clientIdx);
		DFP_KS_UseAbility[clientIdx] = useAbilityPressed;
		return;
	}
	
	// find their game
	new bool:isHero = false;
	new gameIdx = DFP_FindCurrentGame(clientIdx, isHero);
	if (gameIdx == -1)
		return; // shouldn't really happen, but better safe than sorry
	
	// iteration first
	new bool:iteratePressed = (buttons & IN_RELOAD) != 0;
	if (iteratePressed && !DFP_KS_Iterate[clientIdx])
		DG_IterateAbilityPressed(gameIdx, isHero, false);
	DFP_KS_Iterate[clientIdx] = iteratePressed;
	new bool:reverseIteratePressed = (buttons & IN_USE) != 0;
	if (reverseIteratePressed && !DFP_KS_ReverseIterate[clientIdx])
		DG_IterateAbilityPressed(gameIdx, isHero, true);
	DFP_KS_ReverseIterate[clientIdx] = reverseIteratePressed;
	
	// use ability next, which is far simpler. if IN_ATTACK is down, they're using it.
	new bool:useAbilityPressed = (buttons & IN_ATTACK) != 0;
	if (isHero && DFP_AutoFire[clientIdx])
		useAbilityPressed = !useAbilityPressed;
	if (useAbilityPressed)
		DG_UseAbilityPressed(gameIdx, isHero);
	DFP_KS_UseAbility[clientIdx] = useAbilityPressed;
}

public DFP_DisableMusic(clientIdx)
{
	// stop any currently playing sound
	if (DFP_MusicState[clientIdx] != DFP_PLAYBACK_DONOTWANT)
	{
		if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_INTRO)
			StopSound(clientIdx, SNDCHAN_AUTO, ML_Intro[DFP_MusicIdx[clientIdx]]);
		else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_SONG)
			StopSound(clientIdx, SNDCHAN_AUTO, ML_Song[DFP_MusicIdx[clientIdx]]);
		
		DFP_MusicState[clientIdx] = DFP_PLAYBACK_DONOTWANT;
		CPrintToChat(clientIdx, "Disabled the music.");
	}
	else
	{
		DFP_MusicState[clientIdx] = DFP_PLAYBACK_NONE;
		CPrintToChat(clientIdx, "Enabled the music.");
	}
}

public DFP_PlaySpecial(clientIdx, specialType)
{
	if (!IsValidPlayer(clientIdx) || DFP_MusicState[clientIdx] == DFP_PLAYBACK_DONOTWANT)
		return;

	// stop any currently playing sound
	if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_INTRO)
		StopSound(clientIdx, SNDCHAN_AUTO, ML_Intro[DFP_MusicIdx[clientIdx]]);
	else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_SONG)
		StopSound(clientIdx, SNDCHAN_AUTO, ML_Song[DFP_MusicIdx[clientIdx]]);
		
	// this playback is off the record, and can overlap if the user manually sets a song to play
	static String:soundFile[MAX_SOUND_FILE_LENGTH];
	soundFile[0] = 0;
	new Float:duration = 0.0;
	if (specialType == ML_SPECIAL_WIN && ML_NumWinSounds > 0)
	{
		strcopy(soundFile, MAX_SOUND_FILE_LENGTH, ML_WinSounds[GetRandomInt(0, ML_NumWinSounds - 1)]);
		duration = DC_PostgameDelay;
	}
	else if (specialType == ML_SPECIAL_LOSE && ML_NumLoseSounds > 0)
	{
		strcopy(soundFile, MAX_SOUND_FILE_LENGTH, ML_LoseSounds[GetRandomInt(0, ML_NumLoseSounds - 1)]);
		duration = DC_PostgameDelay;
	}
	else if (specialType == ML_SPECIAL_START_5S && ML_NumStartSounds5s > 0)
	{
		strcopy(soundFile, MAX_SOUND_FILE_LENGTH, ML_StartSounds5s[GetRandomInt(0, ML_NumStartSounds5s - 1)]);
		duration = 5.0;
	}
	else if (specialType == ML_SPECIAL_START_10S && ML_NumStartSounds10s > 0)
	{
		strcopy(soundFile, MAX_SOUND_FILE_LENGTH, ML_StartSounds10s[GetRandomInt(0, ML_NumStartSounds10s - 1)]);
		duration = 10.0;
	}
	else if (specialType == ML_SPECIAL_START_15S && ML_NumStartSounds15s > 0)
	{
		strcopy(soundFile, MAX_SOUND_FILE_LENGTH, ML_StartSounds15s[GetRandomInt(0, ML_NumStartSounds15s - 1)]);
		duration = 15.0;
	}
	
	// get out now if there's nothing to play
	if (strlen(soundFile) <= 3 || duration <= 0.0)
		return;
	
	// pad the duration a little to avoid rapid sound changes, i.e. only two players on and a game's about to start
	duration += 1.0;
	
	// change state and play our special sound
	DFP_MusicState[clientIdx] = DFP_PLAYBACK_NEXT_PENDING;
	DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + duration;
	EmitSoundToClient(clientIdx, soundFile);
}

public DFP_PlayMusic(clientIdx, musicArrayIdx, bool:random)
{
	if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_DONOTWANT)
		return;

	if (musicArrayIdx == -1)
		random = true;
	if (random)
		musicArrayIdx = GetRandomInt(0, ML_NumSongs - 1);
	
	if (musicArrayIdx == DFP_MusicIdx[clientIdx] && (DFP_MusicState[clientIdx] == DFP_PLAYBACK_INTRO || DFP_MusicState[clientIdx] == DFP_PLAYBACK_SONG))
		return; // don't start the same song over.

	// so I can write less secure calls...
	if (musicArrayIdx < 0 || musicArrayIdx >= ML_NumSongs)
		return;
	
	// stop any currently playing sound
	if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_INTRO)
		StopSound(clientIdx, SNDCHAN_AUTO, ML_Intro[DFP_MusicIdx[clientIdx]]);
	else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_SONG)
		StopSound(clientIdx, SNDCHAN_AUTO, ML_Song[DFP_MusicIdx[clientIdx]]);
	
	if (strlen(ML_Intro[musicArrayIdx]) > 3)
	{
		DFP_MusicState[clientIdx] = DFP_PLAYBACK_INTRO;
		DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + ML_IntroLength[musicArrayIdx];
		DFP_MusicIdx[clientIdx] = musicArrayIdx;
		EmitSoundToClient(clientIdx, ML_Intro[DFP_MusicIdx[clientIdx]]);
	}
	else
	{
		DFP_MusicState[clientIdx] = DFP_PLAYBACK_SONG;
		DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + ML_SongLength[musicArrayIdx];
		DFP_MusicIdx[clientIdx] = musicArrayIdx;
		EmitSoundToClient(clientIdx, ML_Song[DFP_MusicIdx[clientIdx]]);
	}
	DFP_MusicWasRandom[clientIdx] = random;
}

public DFP_PrintTutorial(clientIdx)
{
	DFP_NextTutorialMessageAt[clientIdx] = GetEngineTime() + DC_TutorialInterval;
	switch (DFP_NextTutorialMessage[clientIdx])
	{
		case 0:
			CPrintToChat(clientIdx, "{aqua}Welcome to %s{default} v%s. While others are playing, you will able to fly around like the normal players. You can press {green}FIRE {default}to teleport to a random active player.", DC_PLUGIN_NAME, PLUGIN_VERSION);
		case 1:
			CPrintToChat(clientIdx, "Since dodging projectiles is a huge part of danmaku (bullet hell), you might have difficulties playing with a high ping. Unfortunately there is nothing that can be done about it.");
		case 2:
			CPrintToChat(clientIdx, "Future versions of this mod will have an arena specific to queued up people just to mess around with basic pewpew lasers. For now, all you can do is spectate.");
		case 3:
		{
			if (DFP_ThirdPersonSmxExists)
				CPrintToChat(clientIdx, "You can play in third person if your admin has enabled the thirdperson mod. Type {yellow}/tp{default} to play in third person, {yellow}/fp{default} for first person.");
			else
				CPrintToChat(clientIdx, "You can play in third person. Type {yellow}/%s{default} to play in third person, {yellow}/%s{default} for first person.", CMD_TP, CMD_FP);
		}
		case 4:
			CPrintToChat(clientIdx, "Type {yellow}/%s{default} to prefer being boss, {yellow}/%s{default} to prefer being hero, and {yellow}/%s{default} to never be either.", CMD_WANT_BOSS, CMD_WANT_HERO, CMD_NEVER);
		case 5:
			CPrintToChat(clientIdx, "Type {yellow}/%s{default} to view your queue points.", CMD_QUEUE);
		case 6:
			CPrintToChat(clientIdx, "Type {yellow}/%s{default} to select which boss you'll be, if you're selected as boss. {yellow}/%s{default} to select which hero, if you're selected as hero.", CMD_BOSS, CMD_HERO);
		case 7:
			CPrintToChat(clientIdx, "Type {yellow}/%s{default} to select specific music or remove the music entirely. Your choice (except for OFF) will still be overriden when a round begins, but you can override it again.", CMD_MUSIC);
		case 8:
			CPrintToChat(clientIdx, "If you hold {green}MIDDLE MOUSE{default}, you'll move at half speed, giving you more precise movement. If you don't have a middle mouse (i.e. Mac users) you'll need to go into TF2 settings and bind it. (it's called \"{aqua}Special{default}\")");
		case 9:
			CPrintToChat(clientIdx, "You can also use {green}CROUCH{default} for precision mode, but this is only recommended if you play in third person. In first person, your view height will be wrong if you crouch.");
		case 10:
			CPrintToChat(clientIdx, "Advanced users can type {yellow}/%s{default} 0-%d to pick specific songs, for example {yellow}/%s 2{default}. If you like certain songs, you can bind this to a key via the console and play a song with a single button press.", CMD_MUSIC, (ML_NumSongs - 1), CMD_MUSIC);
		case 11:
			CPrintToChat(clientIdx, "Bosses too easy for you? Type {yellow}/%s{default} to change the difficulty. Higher difficulties force you to activate bombs and/or don't give you bombs on death, but they also award more scoreboard points.", CMD_DIFFICULTY);
		case 12:
		{
			CPrintToChat(clientIdx, "{aqua}%s{default} version %s, coded by sarysa.", DC_PLUGIN_NAME, PLUGIN_VERSION);

			// KEEP THIS AT THE END OF THE SWITCH STATEMENT!
			DFP_NextTutorialMessage[clientIdx] = -1;
		}
	}
	DFP_NextTutorialMessage[clientIdx]++;
}

public DFP_Tick(Float:curTime)
{
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		// start with things requiring only a connected player
		if (!IsValidPlayer(clientIdx))
		{
			if (DFP_ParticleEntRef[clientIdx] != INVALID_ENTREF)
			{
				RemoveEntity(INVALID_HANDLE, DFP_ParticleEntRef[clientIdx]);
				DFP_ParticleEntRef[clientIdx] = INVALID_ENTREF;
			}
			continue;
		}
	
		// tutorial messages
		if (curTime >= DFP_NextTutorialMessageAt[clientIdx])
			DFP_PrintTutorial(clientIdx);
		
		// music
		if (ML_NumSongs > 0 && GetClientTeam(clientIdx) > 0)
		{
			if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_NONE)
			{
				// pick a random tune
				DFP_PlayMusic(clientIdx, -1, true);
			}
			else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_INTRO)
			{
				if (curTime >= DFP_AdvanceStateAt[clientIdx])
				{
					DFP_MusicState[clientIdx] = DFP_PLAYBACK_SONG;
					DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + ML_SongLength[DFP_MusicIdx[clientIdx]];
					EmitSoundToClient(clientIdx, ML_Song[DFP_MusicIdx[clientIdx]]);
				}
			}
			else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_SONG)
			{
				if (curTime >= DFP_AdvanceStateAt[clientIdx])
				{
					if (DFP_MusicWasRandom[clientIdx])
					{
						// pick another random tune if the previous was random
						DFP_MusicState[clientIdx] = DFP_PLAYBACK_NEXT_PENDING;
						DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + 5.0; // 5 second fade out time
					}
					else
					{
						// loop non-random music
						DFP_MusicState[clientIdx] = DFP_PLAYBACK_SONG;
						DFP_AdvanceStateAt[clientIdx] = GetEngineTime() + ML_SongLength[DFP_MusicIdx[clientIdx]];
						EmitSoundToClient(clientIdx, ML_Song[DFP_MusicIdx[clientIdx]]);
					}
				}
			}
			else if (DFP_MusicState[clientIdx] == DFP_PLAYBACK_NEXT_PENDING)
			{
				if (curTime >= DFP_AdvanceStateAt[clientIdx])
				{
					// pick a random tune
					DFP_MusicState[clientIdx] = DFP_PLAYBACK_NONE;
					DFP_PlayMusic(clientIdx, -1, true);
				}
			}
		}
		
		// manage the dead
		if (!IsLivingPlayer(clientIdx) || (GetClientTeam(clientIdx) != HeroTeam && GetClientTeam(clientIdx) != BossTeam))
		{
			if (DFP_ParticleEntRef[clientIdx] != INVALID_ENTREF)
			{
				RemoveEntity(INVALID_HANDLE, DFP_ParticleEntRef[clientIdx]);
				DFP_ParticleEntRef[clientIdx] = INVALID_ENTREF;
			}
			
			// instant respawn anyone not in spectator who isn't in a game, but don't do anything to them this frame
			if ((GetClientTeam(clientIdx) == BossTeam || GetClientTeam(clientIdx) == HeroTeam) && DFP_Role[clientIdx] != DFP_ROLE_HERO && DFP_Role[clientIdx] != DFP_ROLE_BOSS)
			{
				if (DFP_RespawnAt[clientIdx] == FAR_FUTURE)
					DFP_RespawnAt[clientIdx] = curTime + DFP_RESPAWN_DELAY;
				else if (curTime >= DFP_RespawnAt[clientIdx])
				{
					DFP_RespawnAt[clientIdx] = FAR_FUTURE;
					TF2_RespawnPlayer(clientIdx);
				}
			}
			continue;
		}
		
		// handle newly spawned players
		if (DFP_PlayerJustSpawned[clientIdx])
		{
			DFP_PlayerJustSpawned[clientIdx] = false;
			FinishPlayerSpawned(clientIdx);
		}
		
		// fix broken health on non-combatants
		if (DFP_Role[clientIdx] != DFP_ROLE_HERO && DFP_Role[clientIdx] != DFP_ROLE_HERO)
		{
			if (GetEntProp(clientIdx, Prop_Data, "m_iHealth") > 1)
			{
				SetEntProp(clientIdx, Prop_Data, "m_iHealth", 1);
				SetEntProp(clientIdx, Prop_Send, "m_iHealth", 1);
			}
		}
		
		// now for things requiring a living player, such as...
		// particle management
		if (DC_UseParticle && (DFP_Role[clientIdx] == DFP_ROLE_HERO || DFP_Role[clientIdx] == DFP_ROLE_SURVIVOR))
		{
			// these roles need to have a particle
			if (DFP_ParticleEntRef[clientIdx] != INVALID_ENTREF)
			{
				new particle = EntRefToEntIndex(DFP_ParticleEntRef[clientIdx]);
				if (!IsValidEntity(particle))
					DFP_ParticleEntRef[clientIdx] = INVALID_ENTREF;
			}
			
			if (DFP_ParticleEntRef[clientIdx] == INVALID_ENTREF)
			{
				new particle = AttachParticle(clientIdx, DFP_PARTICLE, DC_HERO_HIT_SPOT_Z_OFFSET);
				if (IsValidEntity(particle))
					DFP_ParticleEntRef[clientIdx] = EntIndexToEntRef(particle);
			}
		}
		else
		{
			// remove any existing particle for boss and none
			if (DFP_ParticleEntRef[clientIdx] != INVALID_ENTREF)
			{
				RemoveEntity(INVALID_HANDLE, DFP_ParticleEntRef[clientIdx]);
				DFP_ParticleEntRef[clientIdx] = INVALID_ENTREF;
			}
		}
		
		// ensure player is in the correct "person" mode
		if (!DFP_ThirdPersonSmxExists)
		{
			if (GetEntProp(clientIdx, Prop_Send, "m_nForceTauntCam") == 0 && DFP_ThirdPerson[clientIdx])
			{
				SetVariantInt(1);
				AcceptEntityInput(clientIdx, "SetForcedTauntCam");
			}
			else if (GetEntProp(clientIdx, Prop_Send, "m_nForceTauntCam") == 1 && !DFP_ThirdPerson[clientIdx])
			{
				SetVariantInt(0);
				AcceptEntityInput(clientIdx, "SetForcedTauntCam");
			}
		}

		// if hero is in third person mode, switch to uber skin and add an outline
		if (DFP_Role[clientIdx] == DFP_ROLE_HERO && GetEntProp(clientIdx, Prop_Send, "m_nForceTauntCam") != 0)
		{
			if (!TF2_IsPlayerInCondition(clientIdx, TFCond_Ubercharged))
			{
				TF2_AddCondition(clientIdx, TFCond_Ubercharged, -1.0);
				RemoveUberOverlay(clientIdx);
			}
			if (GetEntProp(clientIdx, Prop_Send, "m_bGlowEnabled") == 0)
				SetEntProp(clientIdx, Prop_Send, "m_bGlowEnabled", 1);
		}
		else
		{
			if (TF2_IsPlayerInCondition(clientIdx, TFCond_Ubercharged))
				TF2_RemoveCondition(clientIdx, TFCond_Ubercharged);
			if (GetEntProp(clientIdx, Prop_Send, "m_bGlowEnabled") != 0)
				SetEntProp(clientIdx, Prop_Send, "m_bGlowEnabled", 0);
		}
		
		// alpha management
		SetEntityRenderMode(clientIdx, RENDER_TRANSCOLOR);
		if (DFP_Role[clientIdx] == DFP_ROLE_NONE)
			SetEntityRenderColor(clientIdx, 255, 255, 255, DFP_ALPHA_NONE);
		else if (DFP_Role[clientIdx] == DFP_ROLE_HERO)
		{
			new gameIdx = DG_FindPlayerGame(clientIdx);
			new rgb = 255;
			if (gameIdx != -1 && DG_HeroInvincibleUntil[gameIdx] > curTime)
			{
				new Float:flashValue = getFloatDecimalComponent(DG_HeroInvincibleUntil[gameIdx] - curTime);
				if (flashValue > 0.5)
					flashValue = 1.0 - flashValue;
				flashValue *= 2.0;
				rgb = 255 - RoundFloat(flashValue * 255.0);
			}
			SetEntityRenderColor(clientIdx, rgb, rgb, rgb, DFP_ALPHA_HERO);
		}
		else if (DFP_Role[clientIdx] == DFP_ROLE_BOSS)
			SetEntityRenderColor(clientIdx, 255, 255, 255, DFP_ALPHA_BOSS);
		else if (DFP_Role[clientIdx] == DFP_ROLE_SURVIVOR)
			SetEntityRenderColor(clientIdx, 255, 255, 255, DFP_ALPHA_SURVIVOR);
			
		// don't let scouts spam particles. it might be local, but still trying to avoid this
		SetEntProp(clientIdx, Prop_Send, "m_iAirDash", 9999);
		
		// bot logic
		BL_TickBot(clientIdx, curTime);
	}
}

/**
 * Danmaku Games
 */
DG_CalculateWallPositions(gameIdx)
{
	new bool:heroForwardIsX = false;

	// I've opted not to index these six, to reduce reading confusion
	new Float:heroForward;
	new Float:heroBack;
	new Float:heroLeft;
	new Float:heroRight;
	new Float:heroUp;
	new Float:heroDown;
	static Float:endPos[3];
	static Float:tmpAngle[3];
	tmpAngle[0] = tmpAngle[2] = 0.0;
	tmpAngle[1] = DG_HeroSpawnAngles[gameIdx][1]; // only need to preserve yaw
	
	// forward first
	new collisionMask = (CONTENTS_SOLID | CONTENTS_WINDOW | CONTENTS_GRATE);
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	if (fabs(DG_HeroSpawns[gameIdx][0] - endPos[0]) > 1.0)
	{
		heroForwardIsX = true;
		heroForward = endPos[0] - DG_HeroSpawns[gameIdx][0];
	}
	else
		heroForward = endPos[1] - DG_HeroSpawns[gameIdx][1];
		
	// next, back
	tmpAngle[1] = fixAngle(tmpAngle[1] + 180.0);
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	if (heroForwardIsX)
		heroBack = endPos[0] - DG_HeroSpawns[gameIdx][0];
	else
		heroBack = endPos[1] - DG_HeroSpawns[gameIdx][1];
		
	// then left
	tmpAngle[1] = fixAngle(tmpAngle[1] + 90.0);
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	if (heroForwardIsX)
		heroLeft = endPos[1] - DG_HeroSpawns[gameIdx][1];
	else
		heroLeft = endPos[0] - DG_HeroSpawns[gameIdx][0];

	// then right
	tmpAngle[1] = fixAngle(tmpAngle[1] + 180.0);
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	if (heroForwardIsX)
		heroRight = endPos[1] - DG_HeroSpawns[gameIdx][1];
	else
		heroRight = endPos[0] - DG_HeroSpawns[gameIdx][0];
		
	// then up, which is simpler because yaw rotation doesn't matter
	tmpAngle[0] = -90.0;
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	heroUp = endPos[2] - DG_HeroSpawns[gameIdx][2];
	
	// finally, down
	tmpAngle[0] = 90.0;
	TR_TraceRayFilter(DG_HeroSpawns[gameIdx], tmpAngle, collisionMask, RayType_Infinite, TraceWallsOnly);
	TR_GetEndPosition(endPos);
	heroDown = endPos[2] - DG_HeroSpawns[gameIdx][2];
	
	// get full map coords first
	new forwardBackIdx = heroForwardIsX ? 0 : 1;
	new leftRightIdx = heroForwardIsX ? 1 : 0;
	DG_WholeMapRect[gameIdx][0][0] = DG_HeroSpawns[gameIdx][forwardBackIdx] + fmin(heroBack, heroForward);
	DG_WholeMapRect[gameIdx][0][1] = DG_HeroSpawns[gameIdx][leftRightIdx] + fmin(heroLeft, heroRight);
	DG_WholeMapRect[gameIdx][0][2] = DG_HeroSpawns[gameIdx][2] + fmin(heroUp, heroDown);
	DG_WholeMapRect[gameIdx][1][0] = DG_HeroSpawns[gameIdx][forwardBackIdx] + fmax(heroBack, heroForward);
	DG_WholeMapRect[gameIdx][1][1] = DG_HeroSpawns[gameIdx][leftRightIdx] + fmax(heroLeft, heroRight);
	DG_WholeMapRect[gameIdx][1][2] = DG_HeroSpawns[gameIdx][2] + fmax(heroUp, heroDown);
	DG_RecycleBoundsRect[gameIdx][0][0] = DG_WholeMapRect[gameIdx][0][0] + DC_DESPAWN_RANGE;
	DG_RecycleBoundsRect[gameIdx][0][1] = DG_WholeMapRect[gameIdx][0][1] + DC_DESPAWN_RANGE;
	DG_RecycleBoundsRect[gameIdx][0][2] = DG_WholeMapRect[gameIdx][0][2] + DC_DESPAWN_RANGE;
	DG_RecycleBoundsRect[gameIdx][1][0] = DG_WholeMapRect[gameIdx][1][0] - DC_DESPAWN_RANGE;
	DG_RecycleBoundsRect[gameIdx][1][1] = DG_WholeMapRect[gameIdx][1][1] - DC_DESPAWN_RANGE;
	DG_RecycleBoundsRect[gameIdx][1][2] = DG_WholeMapRect[gameIdx][1][2] - DC_DESPAWN_RANGE;
	if (PRINT_DEBUG_INFO)
	{
		PrintToServer("[danmaku_fortress] Whole map bounds (gameIdx=%d): %f,%f,%f --> %f,%f,%f", gameIdx,
				DG_WholeMapRect[gameIdx][0][0], DG_WholeMapRect[gameIdx][0][1], DG_WholeMapRect[gameIdx][0][2],
				DG_WholeMapRect[gameIdx][1][0], DG_WholeMapRect[gameIdx][1][1], DG_WholeMapRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Recycle map bounds (gameIdx=%d): %f,%f,%f --> %f,%f,%f", gameIdx,
				DG_RecycleBoundsRect[gameIdx][0][0], DG_RecycleBoundsRect[gameIdx][0][1], DG_RecycleBoundsRect[gameIdx][0][2],
				DG_RecycleBoundsRect[gameIdx][1][0], DG_RecycleBoundsRect[gameIdx][1][1], DG_RecycleBoundsRect[gameIdx][1][2]);
	}
	
	// with these six dimensions we can provide coordinates to everything else, which we're deliberately setting to be min/max
	// first, lets do Z which is universal
	DG_MapBossWallRect[gameIdx][0][2] = DG_MapHeroWallRect[gameIdx][0][2] = DG_MapHeroRightWallRect[gameIdx][0][2] = 
		DG_MapHeroLeftWallRect[gameIdx][0][2] = DG_MapFloorRect[gameIdx][0][2] = DG_MapFloorRect[gameIdx][1][2] = 
		DG_HeroSpawns[gameIdx][2] + heroDown;
	DG_MapBossWallRect[gameIdx][1][2] = DG_MapHeroWallRect[gameIdx][1][2] = DG_MapHeroRightWallRect[gameIdx][1][2] = 
		DG_MapHeroLeftWallRect[gameIdx][1][2] = DG_MapCeilingRect[gameIdx][0][2] = DG_MapCeilingRect[gameIdx][1][2] = 
		DG_HeroSpawns[gameIdx][2] + heroUp;
		
	// next, do X/Y, which is far more complicated
	// start with hero back wall
	DG_MapHeroWallRect[gameIdx][0][forwardBackIdx] = DG_MapHeroWallRect[gameIdx][1][forwardBackIdx] = DG_HeroSpawns[gameIdx][forwardBackIdx] + heroBack; // flat
	DG_MapHeroWallRect[gameIdx][0][leftRightIdx] = DG_HeroSpawns[gameIdx][leftRightIdx] + fmin(heroLeft, heroRight);
	DG_MapHeroWallRect[gameIdx][1][leftRightIdx] = DG_HeroSpawns[gameIdx][leftRightIdx] + fmax(heroLeft, heroRight);
	
	// next is boss back wall (hero's forward wall)
	DG_MapBossWallRect[gameIdx][0][forwardBackIdx] = DG_MapBossWallRect[gameIdx][1][forwardBackIdx] = DG_HeroSpawns[gameIdx][forwardBackIdx] + heroForward; // flat
	DG_MapBossWallRect[gameIdx][0][leftRightIdx] = DG_MapHeroWallRect[gameIdx][0][leftRightIdx];
	DG_MapBossWallRect[gameIdx][1][leftRightIdx] = DG_MapHeroWallRect[gameIdx][1][leftRightIdx];
	
	// next is hero's left wall
	DG_MapHeroLeftWallRect[gameIdx][0][leftRightIdx] = DG_MapHeroLeftWallRect[gameIdx][1][leftRightIdx] = DG_HeroSpawns[gameIdx][leftRightIdx] + heroLeft;
	DG_MapHeroLeftWallRect[gameIdx][0][forwardBackIdx] = DG_HeroSpawns[gameIdx][forwardBackIdx] + fmin(heroForward, heroBack);
	DG_MapHeroLeftWallRect[gameIdx][1][forwardBackIdx] = DG_HeroSpawns[gameIdx][forwardBackIdx] + fmax(heroForward, heroBack);
	
	// next is hero's right wall
	DG_MapHeroRightWallRect[gameIdx][0][leftRightIdx] = DG_MapHeroRightWallRect[gameIdx][1][leftRightIdx] = DG_HeroSpawns[gameIdx][leftRightIdx] + heroRight;
	DG_MapHeroRightWallRect[gameIdx][0][forwardBackIdx] = DG_MapHeroLeftWallRect[gameIdx][0][forwardBackIdx];
	DG_MapHeroRightWallRect[gameIdx][1][forwardBackIdx] = DG_MapHeroLeftWallRect[gameIdx][1][forwardBackIdx];
	
	// now for some neutrality: the ceiling!
	DG_MapCeilingRect[gameIdx][0][forwardBackIdx] = fmin(DG_MapHeroWallRect[gameIdx][0][forwardBackIdx], DG_MapBossWallRect[gameIdx][0][forwardBackIdx]);
	DG_MapCeilingRect[gameIdx][1][forwardBackIdx] = fmax(DG_MapHeroWallRect[gameIdx][0][forwardBackIdx], DG_MapBossWallRect[gameIdx][0][forwardBackIdx]);
	DG_MapCeilingRect[gameIdx][0][leftRightIdx] = DG_MapHeroWallRect[gameIdx][0][leftRightIdx];
	DG_MapCeilingRect[gameIdx][1][leftRightIdx] = DG_MapHeroWallRect[gameIdx][1][leftRightIdx];
	
	// floor is same as ceiling. just didn't want the above's code to be mind bendingly long
	DG_MapFloorRect[gameIdx][0][0] = DG_MapCeilingRect[gameIdx][0][0];
	DG_MapFloorRect[gameIdx][0][1] = DG_MapCeilingRect[gameIdx][0][1];
	DG_MapFloorRect[gameIdx][1][0] = DG_MapCeilingRect[gameIdx][1][0];
	DG_MapFloorRect[gameIdx][1][1] = DG_MapCeilingRect[gameIdx][1][1];
	
	// store if X/Y is forward/back
	DG_XYIsForwardBack[gameIdx] = heroForwardIsX;
	
	// gotta print this out to ensure this math is accurate
	if (PRINT_DEBUG_INFO)
	{
		PrintToServer("[danmaku_fortress] Detected and stored map boundaries for game #%d", gameIdx);
		PrintToServer("[danmaku_fortress] Behind Hero: %f,%f,%f -> %f,%f,%f",
			DG_MapHeroWallRect[gameIdx][0][0], DG_MapHeroWallRect[gameIdx][0][1], DG_MapHeroWallRect[gameIdx][0][2],
			DG_MapHeroWallRect[gameIdx][1][0], DG_MapHeroWallRect[gameIdx][1][1], DG_MapHeroWallRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Behind Boss: %f,%f,%f -> %f,%f,%f",
			DG_MapBossWallRect[gameIdx][0][0], DG_MapBossWallRect[gameIdx][0][1], DG_MapBossWallRect[gameIdx][0][2],
			DG_MapBossWallRect[gameIdx][1][0], DG_MapBossWallRect[gameIdx][1][1], DG_MapBossWallRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Hero's Left: %f,%f,%f -> %f,%f,%f",
			DG_MapHeroLeftWallRect[gameIdx][0][0], DG_MapHeroLeftWallRect[gameIdx][0][1], DG_MapHeroLeftWallRect[gameIdx][0][2],
			DG_MapHeroLeftWallRect[gameIdx][1][0], DG_MapHeroLeftWallRect[gameIdx][1][1], DG_MapHeroLeftWallRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Hero's Right: %f,%f,%f -> %f,%f,%f",
			DG_MapHeroRightWallRect[gameIdx][0][0], DG_MapHeroRightWallRect[gameIdx][0][1], DG_MapHeroRightWallRect[gameIdx][0][2],
			DG_MapHeroRightWallRect[gameIdx][1][0], DG_MapHeroRightWallRect[gameIdx][1][1], DG_MapHeroRightWallRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Map Ceiling: %f,%f,%f -> %f,%f,%f",
			DG_MapCeilingRect[gameIdx][0][0], DG_MapCeilingRect[gameIdx][0][1], DG_MapCeilingRect[gameIdx][0][2],
			DG_MapCeilingRect[gameIdx][1][0], DG_MapCeilingRect[gameIdx][1][1], DG_MapCeilingRect[gameIdx][1][2]);
		PrintToServer("[danmaku_fortress] Map Floor: %f,%f,%f -> %f,%f,%f",
			DG_MapFloorRect[gameIdx][0][0], DG_MapFloorRect[gameIdx][0][1], DG_MapFloorRect[gameIdx][0][2],
			DG_MapFloorRect[gameIdx][1][0], DG_MapFloorRect[gameIdx][1][1], DG_MapFloorRect[gameIdx][1][2]);
	}
}

public DG_GetFurthestSpawnPattern(gameIdx, axis) // implied: from hero (since boss is supposed to be easily wailed on)
{
	static Float:heroPos[3];
	GetEntPropVector(DG_HeroClient[gameIdx], Prop_Send, "m_vecOrigin", heroPos);
	
	// up/down axis is the easiest
	if (axis == DG_AXIS_UP_DOWN)
	{
		if (fabs(heroPos[0] - DG_MapCeilingRect[gameIdx][1][0]) > fabs(heroPos[0] - DG_MapCeilingRect[gameIdx][0][0]))
			return DG_WALL_CEILING;
		else
			return DG_WALL_FLOOR;
	}
	else if (axis == DG_AXIS_FORWARD_BACK)
	{
		new XorY = DG_XYIsForwardBack[gameIdx] ? 0 : 1;
		if (fabs(heroPos[XorY] - DG_MapHeroWallRect[gameIdx][0][XorY]) > fabs(heroPos[XorY] - DG_MapBossWallRect[gameIdx][0][XorY]))
			return DG_WALL_BEHIND_HERO;
		else
			return DG_WALL_BEHIND_BOSS;
	}
	else if (axis == DG_AXIS_LEFT_RIGHT)
	{
		new XorY = DG_XYIsForwardBack[gameIdx] ? 1 : 0;
		if (fabs(heroPos[XorY] - DG_MapHeroLeftWallRect[gameIdx][0][XorY]) > fabs(heroPos[XorY] - DG_MapHeroRightWallRect[gameIdx][0][XorY]))
			return DG_WALL_HERO_LEFT;
		else
			return DG_WALL_HERO_RIGHT;
	}
	
	PrintToServer("[danmaku_fortress] Invalid axis specified. Returning garbage.");
	return DG_WALL_BEHIND_HERO;
}

public DG_GetWallMinMaxAndFiringAngle(gameIdx, wallType, Float:min[3], Float:max[3], Float:firingAngle[3])
{
	// simply copy over the min/max for each wall type
	if (wallType == DG_WALL_BEHIND_HERO)
	{
		CopyVector(min, DG_MapHeroWallRect[gameIdx][0]);
		CopyVector(max, DG_MapHeroWallRect[gameIdx][1]);
	}
	else if (wallType == DG_WALL_BEHIND_BOSS)
	{
		CopyVector(min, DG_MapBossWallRect[gameIdx][0]);
		CopyVector(max, DG_MapBossWallRect[gameIdx][1]);
	}
	else if (wallType == DG_WALL_HERO_LEFT)
	{
		CopyVector(min, DG_MapHeroLeftWallRect[gameIdx][0]);
		CopyVector(max, DG_MapHeroLeftWallRect[gameIdx][1]);
	}
	else if (wallType == DG_WALL_HERO_RIGHT)
	{
		CopyVector(min, DG_MapHeroRightWallRect[gameIdx][0]);
		CopyVector(max, DG_MapHeroRightWallRect[gameIdx][1]);
	}
	else if (wallType == DG_WALL_CEILING)
	{
		CopyVector(min, DG_MapCeilingRect[gameIdx][0]);
		CopyVector(max, DG_MapCeilingRect[gameIdx][1]);
	}
	else if (wallType == DG_WALL_FLOOR)
	{
		CopyVector(min, DG_MapFloorRect[gameIdx][0]);
		CopyVector(max, DG_MapFloorRect[gameIdx][1]);
	}
	else
	{
		PrintToServer("[danmaku_fortress] Invalid wall type specified. Going with behind hero.");
		CopyVector(min, DG_MapHeroWallRect[gameIdx][0]);
		CopyVector(max, DG_MapHeroWallRect[gameIdx][1]);
	}

	// determine firing angle. pitch is easy, and pitch doesn't care what yaw is
	firingAngle[0] = firingAngle[1] = firingAngle[2] = 0.0;
	if (wallType == DG_WALL_CEILING)
		firingAngle[0] = 90.0;
	else if (wallType == DG_WALL_FLOOR)
		firingAngle[0] = -90.0;
	else // yaw is more complicated
	{
		firingAngle[0] = 0.0;
		firingAngle[1] = DG_HeroSpawnAngles[gameIdx][1]; // if behind hero, this need not change
		if (wallType == DG_WALL_HERO_LEFT)
			firingAngle[1] = fixAngle(firingAngle[1] + 90.0);
		else if (wallType == DG_WALL_BEHIND_BOSS)
			firingAngle[1] = fixAngle(firingAngle[1] + 180.0);
		else if (wallType == DG_WALL_HERO_RIGHT)
			firingAngle[1] = fixAngle(firingAngle[1] + 270.0);
	}
}

public DG_GetArenaRectangle(gameIdx, Float:min[3], Float:max[3])
{
	CopyVector(min, DG_WholeMapRect[gameIdx][0]);
	CopyVector(max, DG_WholeMapRect[gameIdx][1]);
}

public DG_SetBossAlert(gameIdx, const String:warningText[])
{
	strcopy(DG_BossAlertText[gameIdx], MAX_CENTER_TEXT_LENGTH, warningText);
	DG_BossAlertHUDUntil[gameIdx] = DC_SynchronizedTime + DG_WARNING_HUD_DURATION;
}

public DG_SetHeroAlert(gameIdx, const String:warningText[])
{
	strcopy(DG_WarningText[gameIdx], MAX_CENTER_TEXT_LENGTH, warningText);
	DG_WarningHUDUntil[gameIdx] = DC_SynchronizedTime + DG_WARNING_HUD_DURATION;
}

public DG_SetWarningMessage(gameIdx, String:warningText[MAX_CENTER_TEXT_LENGTH], String:warningSound[MAX_SOUND_FILE_LENGTH])
{
	// this can be done instantly, no storage required
	if (PRINT_DEBUG_SPAM)
		PrintToServer("Displaying warning message to %d at y=%f for %f seconds: %s", DG_HeroClient[gameIdx], DG_WARNING_HUD_Y, DG_WARNING_HUD_DURATION, warningText);
	strcopy(DG_WarningText[gameIdx], MAX_CENTER_TEXT_LENGTH, warningText);
	DG_WarningHUDUntil[gameIdx] = DC_SynchronizedTime + DG_WARNING_HUD_DURATION;
	
	// if the warning sound is unavailable, play the administrator WARNING sound
	if (strlen(warningSound) > 3)
		EmitSoundToClient(DG_HeroClient[gameIdx], warningSound);
	else
		EmitSoundToClient(DG_HeroClient[gameIdx], DG_DEFAULT_WARNING_SOUND);
}
 
public DG_OnHeroHit(gameIdx)
{
	// just do this for now. queueing it allows stalemates and prevents double jeopardy.
	if (!(DG_HeroInvincibleUntil[gameIdx] > DC_SynchronizedTime))
		DG_HeroHitPending[gameIdx] = true;
}

public DG_OnBossHit(gameIdx, damage)
{
	// queueing it so everyone gets hit at the end of the tick
	DG_BossDamagePending[gameIdx] += damage;
}

public DG_RadiusBombEffect(gameIdx, Float:radius, Float:centerPos[3])
{
	DG_RadiusBombActive[gameIdx] = true;
	DG_BombRadius[gameIdx] = radius;
	CopyVector(DG_BombPos[gameIdx], centerPos);
	
	//PrintToServer("radius bomb effect, radius=%f    pos=%f,%f,%f", radius, centerPos[0], centerPos[1], centerPos[2]);
}

public DG_RectangleBombEffect(gameIdx, Float:point1[3], Float:point2[3])
{
	DG_RectangleBombActive[gameIdx] = true;
	DG_BombRect[gameIdx][0][0] = fmin(point1[0], point2[0]);
	DG_BombRect[gameIdx][0][1] = fmin(point1[1], point2[1]);
	DG_BombRect[gameIdx][0][2] = fmin(point1[2], point2[2]);
	DG_BombRect[gameIdx][1][0] = fmax(point1[0], point2[0]);
	DG_BombRect[gameIdx][1][1] = fmax(point1[1], point2[1]);
	DG_BombRect[gameIdx][1][2] = fmax(point1[2], point2[2]);
}

public DG_BeamBombEffect(gameIdx, Float:point1[3], Float:point2[3], Float:beamRadius)
{
	DG_BeamBombActive[gameIdx] = true;
	CopyVector(DG_BeamBombPoint1[gameIdx], point1);
	CopyVector(DG_BeamBombPoint2[gameIdx], point2);
	DG_BeamBombRadius[gameIdx] = beamRadius;
}

public DG_RegisterPlayerResult(clientIdx, resultType)
{
	if (resultType == DG_RESULT_WIN)
	{
		DFP_PlaySpecial(clientIdx, ML_SPECIAL_WIN);
		// TODO, more recording, etc
	}
	else if (resultType == DG_RESULT_LOSE)
	{
		DFP_PlaySpecial(clientIdx, ML_SPECIAL_LOSE);
		// TODO, more recording, etc
	}
	else if (resultType == DG_RESULT_STALEMATE)
	{
		DFP_PlaySpecial(clientIdx, ML_SPECIAL_LOSE);
		// TODO, more recording, etc
	}
}

public DG_FindPlayerGame(clientIdx)
{
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		if (!DG_Active[gameIdx])
			continue;
			
		if (clientIdx == DG_HeroClient[gameIdx] || clientIdx == DG_BossClient[gameIdx])
			return gameIdx;
	}
	
	return -1;
}

public bool:DG_TryStartGame(gameIdx)
{
	// iterate through players once and find the top two
	new topPoints = -1;
	new secondBestPoints = -1;
	new topPlayer = -1;
	new secondBestPlayer = -1;
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (!IsLivingPlayer(clientIdx) || DFP_OptOut[clientIdx])
			continue;
		else if (DFP_Role[clientIdx] == DFP_ROLE_HERO || DFP_Role[clientIdx] == DFP_ROLE_BOSS)
			continue; // they're already in a game (yes, somehow I missed this one and ended up in 5 games during my first multi-map :p )
		else if (DC_SynchronizedTime < DFP_AvailableForGameAt[clientIdx])
			continue; // they just got out of a game. give them a break.
			
		if (DFP_QueuePoints[clientIdx] > topPoints)
		{
			secondBestPoints = topPoints;
			secondBestPlayer = topPlayer;
			topPoints = DFP_QueuePoints[clientIdx];
			topPlayer = clientIdx;
		}
		else if (DFP_QueuePoints[clientIdx] > secondBestPoints)
		{
			secondBestPoints = DFP_QueuePoints[clientIdx];
			secondBestPlayer = clientIdx;
		}
	}
	
	if (topPlayer == -1 || secondBestPlayer == -1)
		return false;
		
	// hooray, we now have enough to start the game. lets check player preferences.
	if (DFP_PreferredRole[topPlayer] == DFP_PreferredRole[secondBestPlayer])
	{
		// random assignment if both have same preference
		new bool:topIsHero = GetRandomInt(0, 1) == 1;
		DG_HeroClient[gameIdx] = topIsHero ? topPlayer : secondBestPlayer;
		DG_BossClient[gameIdx] = !topIsHero ? topPlayer : secondBestPlayer;
	}
	else if (DFP_PreferredRole[topPlayer] == DFP_ROLE_NONE) // one player doesn't care
	{
		DG_HeroClient[gameIdx] = DFP_PreferredRole[secondBestPlayer] == DFP_ROLE_BOSS ? topPlayer : secondBestPlayer;
		DG_BossClient[gameIdx] = DFP_PreferredRole[secondBestPlayer] == DFP_ROLE_BOSS ? secondBestPlayer : topPlayer;
	}
	else if (DFP_PreferredRole[secondBestPlayer] == DFP_ROLE_NONE) // the other player doesn't care
	{
		DG_HeroClient[gameIdx] = DFP_PreferredRole[topPlayer] == DFP_ROLE_HERO ? topPlayer : secondBestPlayer;
		DG_BossClient[gameIdx] = DFP_PreferredRole[topPlayer] == DFP_ROLE_HERO ? secondBestPlayer : topPlayer;
	}
	else // serendipity. both players get what they want.
	{
		DG_HeroClient[gameIdx] = DFP_PreferredRole[topPlayer] == DFP_ROLE_HERO ? topPlayer : secondBestPlayer;
		DG_BossClient[gameIdx] = DFP_PreferredRole[secondBestPlayer] == DFP_ROLE_HERO ? topPlayer : secondBestPlayer;
	}
	
	// clear preferred roles
	DFP_PreferredRole[topPlayer] = DFP_ROLE_NONE;
	DFP_PreferredRole[secondBestPlayer] = DFP_ROLE_NONE;

	// move their teams now, make them the forced class, and respawn
	ChangeClientTeam(DG_HeroClient[gameIdx], HeroTeam);
	ChangeClientTeam(DG_BossClient[gameIdx], BossTeam);
	TF2_SetPlayerClass(DG_HeroClient[gameIdx], DC_PLAYERS_FORCED_CLASS);
	TF2_SetPlayerClass(DG_BossClient[gameIdx], DC_PLAYERS_FORCED_CLASS);
	TF2_RespawnPlayer(DG_HeroClient[gameIdx]);
	TF2_RespawnPlayer(DG_BossClient[gameIdx]);
	
	// so far so good, now which boss are they?
	if (DFP_HeroPickAdminOverride[DG_HeroClient[gameIdx]])
		DFP_HeroPickAdminOverride[DG_HeroClient[gameIdx]] = false;
	else
		DFP_VerifyPickAllowed(DG_HeroClient[gameIdx], true);
	if (DFP_BossPickAdminOverride[DG_BossClient[gameIdx]])
		DFP_BossPickAdminOverride[DG_BossClient[gameIdx]] = false;
	else
		DFP_VerifyPickAllowed(DG_BossClient[gameIdx], false);
	new heroPick = DFP_PreferredHero[DG_HeroClient[gameIdx]];
	new bossPick = DFP_PreferredBoss[DG_BossClient[gameIdx]];
	if (heroPick == -1)
	{
		// anyone can random a donator choice, but no one can random an admin character 
		// the reason I'm doing it this way is because admins don't want to be stuck with worthless debug characters by random chance
		// or worse, get an overpowered character and need to forfeit
		new actualAccess = min(max(DFP_AccessLevel[DG_HeroClient[gameIdx]], CL_ACCESS_DONATOR_CHOICE), CL_ACCESS_DONATOR);
		static bool:canAccess[CL_MAX_HEROES];
		new numAccess = 0;
		for (new i = 0; i < CL_NumHeroes; i++)
		{
			canAccess[i] = actualAccess >= CL_HeroAccess[i];
			if (canAccess[i])
				numAccess++;
		}

		if (numAccess <= 0)
		{
			PrintToServer("[danmaku_fortress] ERROR: No accessible heroes. This is not supported. Giving client access to hero #0.");
			heroPick = 0;
		}
		else
		{
			new randAccess = GetRandomInt(0, numAccess - 1);
			for (new i = 0; i < CL_NumHeroes; i++)
			{
				if (canAccess[i])
				{
					if (randAccess == 0)
					{
						heroPick = i;
						break;
					}
					randAccess--;
				}
			}
		}
	}
	if (bossPick == -1)
	{
		new actualAccess = min(max(DFP_AccessLevel[DG_BossClient[gameIdx]], CL_ACCESS_DONATOR_CHOICE), CL_ACCESS_DONATOR);
		static bool:canAccess[CL_MAX_BOSSES];
		new numAccess = 0;
		for (new i = 0; i < CL_NumBosses; i++)
		{
			canAccess[i] = actualAccess >= CL_BossAccess[i];
			if (canAccess[i])
				numAccess++;
		}

		if (numAccess <= 0)
		{
			PrintToServer("[danmaku_fortress] ERROR: No accessible bosses. This is not supported. Giving client access to boss #0.");
			bossPick = 0;
		}
		else
		{
			new randAccess = GetRandomInt(0, numAccess - 1);
			for (new i = 0; i < CL_NumBosses; i++)
			{
				if (canAccess[i])
				{
					if (randAccess == 0)
					{
						bossPick = i;
						break;
					}
					randAccess--;
				}
			}
		}
	}
	
	// initialize the hero, which also requires getting some config props
	DFP_Role[DG_HeroClient[gameIdx]] = DFP_ROLE_HERO;
	DFP_Role[DG_BossClient[gameIdx]] = DFP_ROLE_BOSS;
	DG_HeroScoreMultiplier[gameIdx] = KV_ReadFloat(CL_HeroConfigNames[heroPick], NULL_STRUCT, CC_PARAM_POINT_ADJUST, 1.0);
	if (DG_HeroScoreMultiplier[gameIdx] <= 0.0)
		DG_HeroScoreMultiplier[gameIdx] = 1.0;
	DG_HeroCharacterIdx[gameIdx] = heroPick;
	DG_HeroMaxLives[gameIdx] = DG_HeroLives[gameIdx] = KV_ReadInt(CL_HeroConfigNames[heroPick], NULL_STRUCT, CC_PARAM_LIVES, 1);
	DG_HeroBombsPerLife[gameIdx] = DG_HeroBombs[gameIdx] = KV_ReadInt(CL_HeroConfigNames[heroPick], NULL_STRUCT, CC_PARAM_BOMBS, 1);
	DG_HeroBombPending[gameIdx] = false;
	DG_HeroMoveSpeed[gameIdx] = KV_ReadFloat(CL_HeroConfigNames[heroPick], NULL_STRUCT, CC_PARAM_MOVE_SPEED, 300.0);
	DG_HeroInvincibleUntil[gameIdx] = DC_SynchronizedTime + DC_StartDelay;
	DG_HeroHitPending[gameIdx] = false;
	DG_HeroAbilityPending[gameIdx] = false;
	DG_HeroAbilitySelection[gameIdx] = 0;
	DG_HeroAbilityCount[gameIdx] = 0;
	new bool:nonBombFound = false;
	for (new i = 1; i <= CC_MAX_ABILITIES; i++)
	{
		static String:structName[MAX_KEY_NAME_LENGTH];
		Format(structName, sizeof(structName), "ability%d", i);
		if (!KV_HasStruct(CL_HeroConfigNames[heroPick], structName))
			continue;
			
		new abilityIdx = DG_HeroAbilityCount[gameIdx];
		KV_ReadString(CL_HeroConfigNames[heroPick], structName, CA_PARAM_NAME, DG_HeroAbilityNames[gameIdx][abilityIdx], MAX_ABILITY_NAME_LENGTH);
		KV_ReadString(CL_HeroConfigNames[heroPick], structName, CA_PARAM_FILENAME, DG_HeroAbilityFilenames[gameIdx][abilityIdx], MAX_PLUGIN_NAME_LENGTH);
		KV_ReadString(CL_HeroConfigNames[heroPick], structName, CA_PARAM_AESTHETIC_NAME, DG_HeroAbilityAestheticName[gameIdx][abilityIdx], MAX_AESTHETIC_NAME_LENGTH);
		KV_ReadString(CL_HeroConfigNames[heroPick], structName, CA_PARAM_DESCRIPTION, DG_HeroAbilityDescription[gameIdx][abilityIdx], MAX_DESCRIPTION_LENGTH);
		DG_HeroAbilityCooldown[gameIdx][abilityIdx] = KV_ReadFloat(CL_HeroConfigNames[heroPick], structName, CA_PARAM_COOLDOWN, 0.0);
		DG_AbilityIsBomb[gameIdx][abilityIdx] = KV_ReadInt(CL_HeroConfigNames[heroPick], structName, CA_PARAM_IS_BOMB, 0) == 1;
		InitAbility(DG_HeroAbilityFilenames[gameIdx][abilityIdx], gameIdx, DG_HeroClient[gameIdx], DG_BossClient[gameIdx],
					DG_HeroAbilityNames[gameIdx][abilityIdx], CL_HeroConfigNames[heroPick], i);
					
		// determine if ability filename is unique
		DG_HeroFilenameIsUnique[gameIdx][abilityIdx] = true;
		for (new j = 0; j < abilityIdx; j++)
		{
			if (StrEqual(DG_HeroAbilityFilenames[gameIdx][abilityIdx], DG_HeroAbilityFilenames[gameIdx][j]))
			{
				DG_HeroFilenameIsUnique[gameIdx][abilityIdx] = false;
				break;
			}
		}
					
		// ensure default hero selection isn't a bomb ability
		if (!nonBombFound && !DG_AbilityIsBomb[gameIdx][abilityIdx])
		{
			nonBombFound = true;
			DG_HeroAbilitySelection[gameIdx] = DG_HeroAbilityCount[gameIdx];
		}
		DG_HeroAbilityOnCooldownUntil[gameIdx][abilityIdx] = DC_SynchronizedTime;
		DG_HeroAbilityCount[gameIdx]++;
	}
	if (!nonBombFound)
		PrintToServer("[danmaku_fortress] ERROR: %s has no normal ability, only bombs. User has been assigned a bomb as their default ability.", CL_HeroConfigNames[heroPick]);
	
	// same goes for the boss. this is also where we grab the songs.
	new songCount = 0;
	static songs[DG_MAX_SONGS];
	for (new i = 0; i < DG_MAX_SONGS; i++)
		songs[i] = 0;
	static String:songStr[DG_MAX_SONGS * 5];
	static String:songStrs[DG_MAX_SONGS][5];
	DG_BossCharacterIdx[gameIdx] = bossPick;
	DG_BossMaxHealth[gameIdx] = DG_BossHealth[gameIdx] = KV_ReadInt(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_HEALTH, 1);
	if (!KV_ReadRectangle(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_HITBOX, DG_BossHitbox[gameIdx]))
	{
		DG_BossHitbox[gameIdx][0][0] = -25.0;
		DG_BossHitbox[gameIdx][0][1] = -25.0;
		DG_BossHitbox[gameIdx][0][2] = 0.0;
		DG_BossHitbox[gameIdx][1][0] = 25.0;
		DG_BossHitbox[gameIdx][1][1] = 25.0;
		DG_BossHitbox[gameIdx][1][2] = 82.0;
	}
	DG_BossDamagePending[gameIdx] = 0;
	DG_BossAbilitySelection[gameIdx] = 0;
	DG_BossAbilityCount[gameIdx] = 0;
	DG_BossUsingAbility[gameIdx] = false;
	DG_NextBossAbilityAt[gameIdx] = 0.0;
	DG_BossAbilityPending[gameIdx] = false;
	DG_BossNumPhases[gameIdx] = KV_ReadInt(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_PHASES, 1);
	DG_BossScoreMultiplier[gameIdx] = KV_ReadFloat(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_POINT_ADJUST, 1.0);
	if (DG_BossScoreMultiplier[gameIdx] <= 0.0)
		DG_BossScoreMultiplier[gameIdx] = 1.0;
	DG_BossPhase[gameIdx] = 1;
	DG_BossMoveSpeed[gameIdx] = KV_ReadFloat(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_MOVE_SPEED, 300.0);
	DG_BossAbilityDelay[gameIdx] = KV_ReadFloat(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_ABILITY_DELAY, 0.0);
	KV_ReadString(CL_BossConfigNames[bossPick], NULL_STRUCT, CC_PARAM_MUSIC, songStr, sizeof(songStr));
	ExplodeString(songStr, ";", songStrs, DG_MAX_SONGS, 5);
	for (new s = 0; s < DG_MAX_SONGS; s++)
	{
		if (IsEmptyString(songStrs[s]))
			break;
		songs[s] = ML_SongIndexToArrayIndex(StringToInt(songStrs[s]));
		songCount++;
	}
	
	// also check to see if there's any boss config-declared music
	static String:songKey[MAX_KEY_NAME_LENGTH];
	for (new i = 0; songCount < DG_MAX_SONGS && i < ML_MAX_SONGS; i++)
	{
		Format(songKey, MAX_KEY_NAME_LENGTH, ML_SONG_FORMAT, i + 1);

		// bring in the song, fail if its settings are invalid
		static String:soundFile[MAX_SOUND_FILE_LENGTH];
		KV_ReadString(CL_BossConfigNames[bossPick], NULL_STRUCT, songKey, soundFile, MAX_SOUND_FILE_LENGTH);
		PrintToServer("soundFile=%s  songKey=%s", soundFile, songKey);
		if (strlen(soundFile) <= 3)
			break;
			
		for (new songIdx = ML_NumSongs - 1; songIdx >= 0; songIdx--)
		{
			PrintToServer("soundFile=%s  vs  %s", soundFile, ML_Song[songIdx]);
			if (StrEqual(ML_Song[songIdx], soundFile))
			{
				songs[songCount] = songIdx;
				songCount++;
				break;
			}
		}
		
		if (PRINT_DEBUG_SPAM && i == DG_MAX_SONGS - 1)
			PrintToServer("[danmaku_fortress] Warning: Sanity limit reached grabbing boss config declared songs.");
	}
	
	for (new i = 1; i <= CC_MAX_ABILITIES; i++)
	{
		static String:structName[MAX_KEY_NAME_LENGTH];
		Format(structName, sizeof(structName), "ability%d", i);
		if (!KV_HasStruct(CL_BossConfigNames[bossPick], structName))
			continue;
		
		new abilityIdx = DG_BossAbilityCount[gameIdx];
		KV_ReadString(CL_BossConfigNames[bossPick], structName, CA_PARAM_NAME, DG_BossAbilityNames[gameIdx][abilityIdx], MAX_ABILITY_NAME_LENGTH);
		KV_ReadString(CL_BossConfigNames[bossPick], structName, CA_PARAM_FILENAME, DG_BossAbilityFilenames[gameIdx][abilityIdx], MAX_PLUGIN_NAME_LENGTH);
		KV_ReadString(CL_BossConfigNames[bossPick], structName, CA_PARAM_AESTHETIC_NAME, DG_BossAbilityAestheticName[gameIdx][abilityIdx], MAX_AESTHETIC_NAME_LENGTH);
		KV_ReadString(CL_BossConfigNames[bossPick], structName, CA_PARAM_DESCRIPTION, DG_BossAbilityDescription[gameIdx][abilityIdx], MAX_DESCRIPTION_LENGTH);
		DG_BossAbilityCooldown[gameIdx][abilityIdx] = KV_ReadFloat(CL_BossConfigNames[bossPick], structName, CA_PARAM_COOLDOWN, 30.0);

		// determine if ability filename is unique
		DG_BossFilenameIsUnique[gameIdx][abilityIdx] = true;
		for (new j = 0; j < abilityIdx; j++)
		{
			if (StrEqual(DG_BossAbilityFilenames[gameIdx][abilityIdx], DG_BossAbilityFilenames[gameIdx][j]))
			{
				DG_BossFilenameIsUnique[gameIdx][abilityIdx] = false;
				break;
			}
		}
					
		static String:phasesStr[97];
		static String:phasesStrs[32][3];
		KV_ReadString(CL_BossConfigNames[bossPick], structName, CA_PARAM_PHASES, phasesStr, sizeof(phasesStr));
		if (DG_BossNumPhases[gameIdx] <= 1 || IsEmptyString(phasesStr) || (phasesStr[0] == '0' && phasesStr[1] == 0))
			DG_BossAbilityPhases[gameIdx][abilityIdx] = 0xffffffff;
		else
		{
			DG_BossAbilityPhases[gameIdx][abilityIdx] = 0;
			ExplodeString(phasesStr, ";", phasesStrs, 32, 3);
			for (new blah = 0; blah < 32; blah++)
			{
				new phase = StringToInt(phasesStrs[blah]);
				if (phase <= 0)
					break;
				DG_BossAbilityPhases[gameIdx][abilityIdx] |= (1<<(phase-1));
			}
			
			// something went wrong if this is true
			if (DG_BossAbilityPhases[gameIdx][abilityIdx] == 0)
			{
				PrintToServer("[danmaku_fortress] Error parsing phases for boss %s ability %s. Setting to all phases.", CL_BossConfigNames[bossPick], DG_BossAbilityAestheticName[gameIdx][abilityIdx]);
				DG_BossAbilityPhases[gameIdx][abilityIdx] = 0xffffffff;
			}
		}
		InitAbility(DG_BossAbilityFilenames[gameIdx][abilityIdx], gameIdx, DG_BossClient[gameIdx], DG_HeroClient[gameIdx],
					DG_BossAbilityNames[gameIdx][abilityIdx], CL_BossConfigNames[bossPick], i);
		DG_BossAbilityOnCooldownUntil[gameIdx][abilityIdx] = DC_SynchronizedTime;
		DG_BossAbilityCount[gameIdx]++;
	}
	
	// model fixing for both (I deliberately didn't load it yet)
	DG_BossModelFixesRemaining[gameIdx] = DG_HeroModelFixesRemaining[gameIdx] = 3;
	DG_NextBossModelFix[gameIdx] = DG_NextHeroModelFix[gameIdx] = DC_SynchronizedTime;
	
	// start the countdown (and countdown HUD)
	DG_RoundBeginsAt[gameIdx] = DC_SynchronizedTime + DC_StartDelay;
	DG_CountdownHUD[gameIdx] = RoundFloat(DC_StartDelay);
	DG_UpdateHUDAt[gameIdx] = DC_SynchronizedTime;
	DG_WarningHUDUntil[gameIdx] = 0.0;
	DG_BossAlertHUDUntil[gameIdx] = 0.0;
	
	// set hero and boss speeds
	DFP_MaxSpeed[DG_HeroClient[gameIdx]] = DG_HeroMoveSpeed[gameIdx];
	DFP_MaxSpeed[DG_BossClient[gameIdx]] = DG_BossMoveSpeed[gameIdx];
	
	// teleport players to the appropriate coordinates
	TeleportEntity(DG_HeroClient[gameIdx], DG_HeroSpawns[gameIdx], DG_HeroSpawnAngles[gameIdx], Float:{0.0, 0.0, 0.0});
	TeleportEntity(DG_BossClient[gameIdx], DG_BossSpawns[gameIdx], DG_BossSpawnAngles[gameIdx], Float:{0.0, 0.0, 0.0});
	
	// this might be important
	DG_Active[gameIdx] = true;
	
	// play the intro sound if applicable
	new specialType = ML_SPECIAL_START_5S;
	if (DC_StartDelay >= 15.0)
		specialType = ML_SPECIAL_START_15S;
	else if (DC_StartDelay >= 10.0)
		specialType = ML_SPECIAL_START_10S;
	DFP_PlaySpecial(DG_HeroClient[gameIdx], specialType);
	DFP_PlaySpecial(DG_BossClient[gameIdx], specialType);
	
	// queue the next song to play
	if (songCount <= 0)
	{
		DG_PendingHeroSong[gameIdx] = -1;
		DG_PendingBossSong[gameIdx] = -1;
	}
	else
	{
		DG_PendingHeroSong[gameIdx] = songs[GetRandomInt(0, songCount - 1)];
		DG_PendingBossSong[gameIdx] = songs[GetRandomInt(0, songCount - 1)];
	}
	
	// don't let old bombs take effect
	DG_RadiusBombActive[gameIdx] = false;
	DG_RectangleBombActive[gameIdx] = false;
	DG_BeamBombActive[gameIdx] = false;
	
	// start grace period for queue point loss
	DG_QueuePointGraceEndsAt[gameIdx] = DC_SynchronizedTime + DC_QueuePointGraceTime;
	
	// fix an interpolation glitch (but also it just speeds up finding "next to spawn", which is why I'm using it with the beam)
	DR_LastToSpawn[gameIdx] = DR_MAX_ROCKETS - 1;
	DB_LastToSpawn[gameIdx] = DB_MAX_BEAMS - 1;
	DS_LastToSpawn[gameIdx] = DS_MAX_SPAWNERS - 1;
	
	return true;
}

public DG_FixModel(gameIdx, bool:isHero)
{
	static String:modelName[MAX_MODEL_FILE_LENGTH];
	new clientIdx = -1;
	if (isHero)
	{
		clientIdx = DG_HeroClient[gameIdx];
		KV_ReadString(CL_HeroConfigNames[DG_HeroCharacterIdx[gameIdx]], NULL_STRUCT, CC_PARAM_MODEL, modelName, MAX_MODEL_FILE_LENGTH);
	}
	else
	{
		clientIdx = DG_BossClient[gameIdx];
		KV_ReadString(CL_BossConfigNames[DG_BossCharacterIdx[gameIdx]], NULL_STRUCT, CC_PARAM_MODEL, modelName, MAX_MODEL_FILE_LENGTH);
	}
	
	if (IsLivingPlayer(clientIdx) && strlen(modelName) > 3)
	{
		SetVariantString(modelName);
		AcceptEntityInput(clientIdx, "SetCustomModel");
		SetEntProp(clientIdx, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public DG_UseBomb(gameIdx)
{
	DG_HeroBombPending[gameIdx] = true;
	DG_HeroBombs[gameIdx]--;
	DG_HeroInvincibleUntil[gameIdx] = DC_SynchronizedTime + DC_InvincibilityDurationBomb;
}

// player's dead, not in game, or somehow team switched in a mere single frame
public bool:DG_PlayerForfeit(clientIdx)
{
	if (!IsClientInGame(clientIdx) || !IsLivingPlayer(clientIdx))
		return true;
	else if (DFP_Role[clientIdx] == DFP_ROLE_HERO && GetClientTeam(clientIdx) != HeroTeam)
		return true;
	else if (DFP_Role[clientIdx] == DFP_ROLE_BOSS && GetClientTeam(clientIdx) != BossTeam)
		return true;
	return false;
}

public DG_Cleanup(gameIdx)
{
	DG_Active[gameIdx] = false;
	
	// cleanup for rockets
	DR_Cleanup(gameIdx);
	
	// call cleanup for subplugins
	for (new abilityIdx = 0; abilityIdx < DG_HeroAbilityCount[gameIdx]; abilityIdx++)
		GameCleanup(DG_HeroAbilityFilenames[gameIdx][abilityIdx], gameIdx);
	for (new abilityIdx = 0; abilityIdx < DG_BossAbilityCount[gameIdx]; abilityIdx++)
		GameCleanup(DG_BossAbilityFilenames[gameIdx][abilityIdx], gameIdx);
	
	// set players to no role and give them a restart delay
	if (DG_HeroClient[gameIdx] > 0)
	{
		DFP_Role[DG_HeroClient[gameIdx]] = DFP_ROLE_NONE;
		DFP_AvailableForGameAt[DG_HeroClient[gameIdx]] = DC_SynchronizedTime + DC_PostgameDelay;
	}
	if (DG_BossClient[gameIdx] > 0)
	{
		DFP_Role[DG_BossClient[gameIdx]] = DFP_ROLE_NONE;
		DFP_AvailableForGameAt[DG_BossClient[gameIdx]] = DC_SynchronizedTime + DC_PostgameDelay;
	}
}

public DG_HandleQueuePoints(gameIdx, bool:heroWin, bool:isForfeit, bool:isStalemate)
{
	new heroClient = DG_HeroClient[gameIdx];
	new bossClient = DG_BossClient[gameIdx];
	static String:heroName[65];
	static String:bossName[65];
	if (IsValidPlayer(heroClient))
		GetClientName(heroClient, heroName, sizeof(heroName));
	else
		strcopy(heroName, sizeof(heroName), "[unknown]");
	if (IsValidPlayer(bossClient))
		GetClientName(bossClient, bossName, sizeof(bossName));
	else
		strcopy(bossName, sizeof(bossName), "[unknown]");
	
	// no points are lost for the winnerif a certain grace period is not completed
	if (isForfeit && DC_SynchronizedTime < DG_QueuePointGraceEndsAt[gameIdx])
	{
		if (IsValidPlayer(heroClient))
		{
			if (heroWin)
				CPrintToChat(heroClient, "{yellow}%s{default} has forfeitted against you early on in the match. You lose no queue points.", bossName);
			else
			{
				CPrintToChat(heroClient, "You have forfeitted against {yellow}%s{default} early on in the match. They lose no queue points, but you lose %.0f%% of yours.", bossName, (1.0 - DC_QueuePointsEarlyForfeitMultiplier) * 100.0);
				DFP_QueuePoints[heroClient] = RoundFloat(float(DFP_QueuePoints[heroClient]) * DC_QueuePointsEarlyForfeitMultiplier);

				// save changes to the points
				CP_SavePrefs(heroClient);
			}
		}

		if (IsValidPlayer(bossClient))
		{
			if (!heroWin)
				CPrintToChat(bossClient, "{yellow}%s{default} has forfeitted against you early on in the match. You lose no queue points.", heroName);
			else
			{
				CPrintToChat(bossClient, "You have forfeitted against {yellow}%s{default} early on in the match. They lose no queue points, but you lose %.0f%% of yours.", heroName, (1.0 - DC_QueuePointsEarlyForfeitMultiplier) * 100.0);
				DFP_QueuePoints[bossClient] = RoundFloat(float(DFP_QueuePoints[bossClient]) * DC_QueuePointsEarlyForfeitMultiplier);

				// save changes to the points
				CP_SavePrefs(bossClient);
			}
		}
		
		return; // nothing left to do. no one else gets queue points for an aborted match
	}
	
	static String:winnerName[80];
	static String:loserName[80];
	Format(winnerName, sizeof(winnerName), "%s (%s)", (heroWin ? heroName : bossName), (heroWin ? "Hero" : "Boss"));
	Format(loserName, sizeof(loserName), "%s (%s)", (!heroWin ? heroName : bossName), (!heroWin ? "Hero" : "Boss"));
	if (isStalemate)
		CPrintToChatAll("{yellow}%s{default} and {yellow}%s{default} have stalemated!", loserName, winnerName);
	else if (isForfeit)
		CPrintToChatAll("{yellow}%s{default} has forfeitted to {yellow}%s{default}!", loserName, winnerName);
	else
		CPrintToChatAll("{yellow}%s{default} has defeated {yellow}%s{default}!", winnerName, loserName);
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		if (!IsValidPlayer(clientIdx))
			continue;
		
		if (clientIdx == heroClient)
		{
			if (isStalemate)
			{
				DFP_QueuePoints[clientIdx] = DC_QueuePointsStalemate;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for stalemating.", DC_QueuePointsStalemate);
				if (DC_QueuePointsStalemate > DC_QueuePointsWait)
					CPrintToChat(clientIdx, "That was amazing! Now it's time to settle the score, eh?");
			}
			else if (heroWin)
			{
				if (isForfeit && DC_QueuePointsForfeittedAgainstMultiplier > 0.0)
				{
					CPrintToChat(clientIdx, "Because your opponent forfeitted after the grace period, you only lose {aqua}%.0f%%{default} of your original queue points.", (1.0 - DC_QueuePointsForfeittedAgainstMultiplier) * 100.0);
					DFP_QueuePoints[clientIdx] = RoundFloat(float(DFP_QueuePoints[clientIdx]) * DC_QueuePointsForfeittedAgainstMultiplier);
					DFP_QueuePoints[clientIdx] += DC_QueuePointsWin;
				}
				else
					DFP_QueuePoints[clientIdx] = DC_QueuePointsWin;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for winning.", DC_QueuePointsWin);
			}
			else
			{
				DFP_QueuePoints[clientIdx] = DC_QueuePointsLose;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for losing.", DC_QueuePointsLose);
			}
		}
		else if (clientIdx == bossClient)
		{
			if (isStalemate)
			{
				DFP_QueuePoints[clientIdx] = DC_QueuePointsStalemate;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for stalemating.", DC_QueuePointsStalemate);
				if (DC_QueuePointsStalemate > DC_QueuePointsWait)
					CPrintToChat(clientIdx, "That was amazing! Now it's time to settle the score, eh?");
			}
			else if (!heroWin)
			{
				if (isForfeit && DC_QueuePointsForfeittedAgainstMultiplier > 0.0)
				{
					CPrintToChat(clientIdx, "Because your opponent forfeitted after the grace period, you only lose {aqua}%.0f%%{default} of your original queue points.", (1.0 - DC_QueuePointsForfeittedAgainstMultiplier) * 100.0);
					DFP_QueuePoints[clientIdx] = RoundFloat(float(DFP_QueuePoints[clientIdx]) * DC_QueuePointsForfeittedAgainstMultiplier);
					DFP_QueuePoints[clientIdx] += DC_QueuePointsWin;
				}
				else
					DFP_QueuePoints[clientIdx] = DC_QueuePointsWin;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for winning.", DC_QueuePointsWin);
			}
			else
			{
				DFP_QueuePoints[clientIdx] = DC_QueuePointsLose;
				CPrintToChat(clientIdx, "You earned {aqua}%d queue points{default} for losing.", DC_QueuePointsLose);
			}
		}
		else if (DFP_Role[clientIdx] != DFP_ROLE_BOSS && DFP_Role[clientIdx] != DFP_ROLE_HERO)
		{
			DFP_QueuePoints[clientIdx] += DC_QueuePointsWait;
			CPrintToChat(clientIdx, "You've earned {aqua}%d queue points{default} for waiting patiently.", DC_QueuePointsWait);
		}
		
		// save changes to the points
		CP_SavePrefs(clientIdx);
	}
		
	// determine and add scoreboard points
	new heroPoints = 0;
	new bossPoints = 0;
	DG_HeroLives[gameIdx]++;
	DG_HeroMaxLives[gameIdx]++;
	DG_HeroBombs[gameIdx]++;
	DG_HeroBombsPerLife[gameIdx]++;
	new Float:lifeBombFactor = 1.0 - (float(DG_HeroLives[gameIdx]) / float(DG_HeroMaxLives[gameIdx]));
	lifeBombFactor += (1.0 / float(DG_HeroMaxLives[gameIdx])) * (1.0 - (float(DG_HeroBombs[gameIdx]) / float(DG_HeroBombsPerLife[gameIdx])));
	if (heroWin)
	{
		if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_HARD)
		{
			heroPoints = RoundFloat(DC_HeroHardMaxScore);
			if (!isForfeit)
				bossPoints = RoundFloat(DC_BossHardMaxScore * (1.0 - (float(DG_HeroLives[gameIdx]) / float(DG_HeroMaxLives[gameIdx]))));
		}
		else if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_LUNATIC)
		{
			heroPoints = RoundFloat(DC_HeroLunaticMaxScore);
			if (!isForfeit)
				bossPoints = RoundFloat(DC_BossLunaticMaxScore * (1.0 - (float(DG_HeroLives[gameIdx]) / float(DG_HeroMaxLives[gameIdx]))));
		}
		else
		{
			heroPoints = RoundFloat(DC_HeroNormalMaxScore);
			if (!isForfeit)
				bossPoints = RoundFloat(DC_BossNormalMaxScore * lifeBombFactor);
		}
	}
	else if (!isStalemate)
	{
		if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_HARD)
		{
			bossPoints = RoundFloat(DC_BossHardMaxScore);
			if (!isForfeit)
				heroPoints = RoundFloat(DC_HeroHardMaxScore * (1.0 - (float(DG_BossHealth[gameIdx]) / float(DG_BossMaxHealth[gameIdx]))));
		}
		else if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_LUNATIC)
		{
			bossPoints = RoundFloat(DC_BossLunaticMaxScore);
			if (!isForfeit)
				heroPoints = RoundFloat(DC_HeroLunaticMaxScore * (1.0 - (float(DG_BossHealth[gameIdx]) / float(DG_BossMaxHealth[gameIdx]))));
		}
		else
		{
			bossPoints = RoundFloat(DC_BossNormalMaxScore);
			if (!isForfeit)
				heroPoints = RoundFloat(DC_HeroNormalMaxScore * (1.0 - (float(DG_BossHealth[gameIdx]) / float(DG_BossMaxHealth[gameIdx]))));
		}
	}

	heroPoints = max(0, heroPoints);
	bossPoints = max(0, bossPoints);
	heroPoints = RoundFloat(float(heroPoints) * DG_HeroScoreMultiplier[gameIdx]);
	if (DG_BossScoreMultiplier[gameIdx] < 1.0)
		heroPoints = RoundFloat(float(heroPoints) / DG_BossScoreMultiplier[gameIdx]);
	bossPoints = RoundFloat(float(bossPoints) * DG_BossScoreMultiplier[gameIdx]);
	if (DG_HeroScoreMultiplier[gameIdx] < 1.0)
		bossPoints = RoundFloat(float(bossPoints) / DG_HeroScoreMultiplier[gameIdx]);
	
	if (IsValidPlayer(DG_HeroClient[gameIdx]))
	{
		CPrintToChat(DG_HeroClient[gameIdx], "You have earned {yellow}%d scoreboard points{default} this round, while your opponent earned %d. Points are affected by the hero's difficulty setting and boss pick.", heroPoints, bossPoints);
		//new Handle:event = CreateEvent("player_bonuspoints", true);
		//SetEventInt(event, "player_entindex", DG_HeroClient[gameIdx]);
		//SetEventInt(event, "source_entindex", DG_HeroClient[gameIdx]);
		//SetEventInt(event, "points", heroPoints);
		new Handle:event = CreateEvent("player_escort_score", true);
		SetEventInt(event, "player", DG_HeroClient[gameIdx]);
		SetEventInt(event, "points", heroPoints / 2);
		FireEvent(event);
		
		DFP_LifetimeScore[DG_HeroClient[gameIdx]] += heroPoints;
		CP_SavePrefs(DG_HeroClient[gameIdx]);
	}
	if (IsValidPlayer(DG_BossClient[gameIdx]))
	{
		CPrintToChat(DG_BossClient[gameIdx], "You have earned {yellow}%d scoreboard points{default} this round, while your opponent earned %d. Points are affected by the hero's difficulty setting and boss pick.", bossPoints, heroPoints);
		new Handle:event = CreateEvent("player_escort_score", true);
		SetEventInt(event, "player", DG_BossClient[gameIdx]);
		SetEventInt(event, "points", bossPoints / 2);
		FireEvent(event);

		DFP_LifetimeScore[DG_BossClient[gameIdx]] += bossPoints;
		CP_SavePrefs(DG_BossClient[gameIdx]);
	}
		
}

public DG_HandleWin(gameIdx, bool:heroWin, bool:isForfeit)
{
	// winner gets the killfeed kill
	if (!isForfeit)
	{
		// TODO printout
		if (heroWin)
		{
			RemoveInvincibility(DG_BossClient[gameIdx]);
			SDKHooks_TakeDamage(DG_BossClient[gameIdx], DG_HeroClient[gameIdx], DG_HeroClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
		}
		else
		{
			RemoveInvincibility(DG_HeroClient[gameIdx]);
			SDKHooks_TakeDamage(DG_HeroClient[gameIdx], DG_BossClient[gameIdx], DG_BossClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
		}
	}
	
	// time to change queue points
	DG_HandleQueuePoints(gameIdx, heroWin, isForfeit, false);

	// do cleanup
	DG_Cleanup(gameIdx);
}

public DG_SetBossMoveSpeed(gameIdx, Float:moveSpeed)
{
	DFP_MaxSpeed[DG_BossClient[gameIdx]] = (moveSpeed == -1.0 ? DG_BossMoveSpeed[gameIdx] : moveSpeed);
}

public DG_BossAbilityEnded(gameIdx)
{
	DG_BossUsingAbility[gameIdx] = false;
	DG_NextBossAbilityAt[gameIdx] = DC_SynchronizedTime + DG_BossAbilityDelay[gameIdx];
}

public DG_UseAbilityPressed(gameIdx, bool:isHero)
{
	if (isHero)
		DG_HeroAbilityPending[gameIdx] = true;
	else
	{
		if (DG_BossUsingAbility[gameIdx] || GetEngineTime() < DG_NextBossAbilityAt[gameIdx])
			return;
			
		DG_BossAbilityPending[gameIdx] = true;
	}
}

public DG_IterateAbilityPressed(gameIdx, bool:isHero, bool:reverse)
{
	if (!reverse)
	{
		if (isHero)
		{
			new original = DG_HeroAbilitySelection[gameIdx];
			do
			{
				DG_HeroAbilitySelection[gameIdx]++;
				DG_HeroAbilitySelection[gameIdx] %= DG_HeroAbilityCount[gameIdx];
			} while (DG_AbilityIsBomb[gameIdx][DG_HeroAbilitySelection[gameIdx]] && DG_HeroAbilitySelection[gameIdx] != original);
		}
		else
		{
			new original = DG_BossAbilitySelection[gameIdx];
			do
			{
				DG_BossAbilitySelection[gameIdx]++;
				DG_BossAbilitySelection[gameIdx] %= DG_BossAbilityCount[gameIdx];
			} while ((DG_BossAbilityPhases[gameIdx][DG_BossAbilitySelection[gameIdx]] & (1<<(DG_BossPhase[gameIdx]-1))) == 0 && DG_BossAbilitySelection[gameIdx] != original);
		}
	}
	else
	{
		if (isHero)
		{
			new original = DG_HeroAbilitySelection[gameIdx];
			do
			{
				DG_HeroAbilitySelection[gameIdx]--;
				if (DG_HeroAbilitySelection[gameIdx] < 0)
					DG_HeroAbilitySelection[gameIdx] = DG_HeroAbilityCount[gameIdx] - 1;
			} while (DG_AbilityIsBomb[gameIdx][DG_HeroAbilitySelection[gameIdx]] && DG_HeroAbilitySelection[gameIdx] != original);
		}
		else
		{
			new original = DG_BossAbilitySelection[gameIdx];
			do
			{
				DG_BossAbilitySelection[gameIdx]--;
				if (DG_BossAbilitySelection[gameIdx] < 0)
					DG_BossAbilitySelection[gameIdx] = DG_BossAbilityCount[gameIdx] - 1;
			} while ((DG_BossAbilityPhases[gameIdx][DG_BossAbilitySelection[gameIdx]] & (1<<(DG_BossPhase[gameIdx]-1))) == 0 && DG_BossAbilitySelection[gameIdx] != original);
		}
	}
}

public DG_Tick(Float:curTime)
{
	if (curTime < DG_StartPairingAt)
		return; // too soon, let everyone properly load/refresh

	new bool:gameStartFail = false;
	static String:centerText[MAX_CENTER_TEXT_LENGTH];
	for (new gameIdx = 0; gameIdx < DG_MaxGames; gameIdx++)
	{
		// lets check dead games before active games
		// this ensures a tiny window of breathing before one ends and another begins (and vice versa)
		if (!DG_Active[gameIdx])
		{
			if (gameStartFail)
				continue; // no sense failing again.

			gameStartFail = DG_TryStartGame(gameIdx);
			continue;
		}
		
		// move onto the active games. try and get all the possible fail conditions out of the way.
		// first, the possible forefeit conditions
		if (DG_PlayerForfeit(DG_HeroClient[gameIdx]) && DG_PlayerForfeit(DG_BossClient[gameIdx]))
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] A game just ended with both clients quitting simultaneously");
			DG_HandleQueuePoints(gameIdx, false, true, true);
			DG_Cleanup(gameIdx);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_LOSE);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_LOSE);
			continue;
		}
		else if (DG_PlayerForfeit(DG_HeroClient[gameIdx]))
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] %d just forfeitted. (hero)", DG_HeroClient[gameIdx]);
			DG_HandleWin(gameIdx, false, true);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_LOSE);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_WIN);
			continue;
		}
		else if (DG_PlayerForfeit(DG_BossClient[gameIdx]))
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] %d just forfeitted. (boss)", DG_BossClient[gameIdx]);
			DG_HandleWin(gameIdx, true, true);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_WIN);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_LOSE);
			continue;
		}
		
		// get boss health right
		SetEntProp(DG_BossClient[gameIdx], Prop_Data, "m_iHealth", DG_BossHealth[gameIdx]);
		SetEntProp(DG_BossClient[gameIdx], Prop_Send, "m_iHealth", DG_BossHealth[gameIdx]);
		
		// model fixes, do it even if we're in countdown
		if (DG_HeroModelFixesRemaining[gameIdx] > 0 && curTime >= DG_NextHeroModelFix[gameIdx])
		{
			DG_HeroModelFixesRemaining[gameIdx]--;
			DG_NextHeroModelFix[gameIdx] = curTime + 1.0;
			DG_FixModel(gameIdx, true);
		}
		if (DG_BossModelFixesRemaining[gameIdx] > 0 && curTime >= DG_NextBossModelFix[gameIdx])
		{
			DG_BossModelFixesRemaining[gameIdx]--;
			DG_NextBossModelFix[gameIdx] = curTime + 1.0;
			DG_FixModel(gameIdx, false);
		}
		
		// still in countdown?
		if (curTime < DG_RoundBeginsAt[gameIdx])
		{
			PrintCenterText(DG_HeroClient[gameIdx], "Round begins in %.1f seconds", (DG_RoundBeginsAt[gameIdx] - curTime) + 0.1);
			PrintCenterText(DG_BossClient[gameIdx], "Round begins in %.1f seconds", (DG_RoundBeginsAt[gameIdx] - curTime) + 0.1);
			if (float(DG_CountdownHUD[gameIdx] - 1) > (DG_RoundBeginsAt[gameIdx] - curTime))
				DG_CountdownHUD[gameIdx]--; // may use this variable for something later...like this in fact
			continue;
		}
		else if (DG_CountdownHUD[gameIdx] > 0)
		{
			// though truth be told I'd still like to use it for something more substantial, like admin sounds playing.
			PrintCenterText(DG_HeroClient[gameIdx], "");
			PrintCenterText(DG_BossClient[gameIdx], "");
			
			// clear any pre-round key presses
			DG_HeroAbilityPending[gameIdx] = false;
			DG_BossAbilityPending[gameIdx] = false;
			DG_CountdownHUD[gameIdx] = 0;

			// start the music, after tricking it to avoid dead air
			if (DG_PendingHeroSong[gameIdx] != -1)
				DFP_PlayMusic(DG_HeroClient[gameIdx], DG_PendingHeroSong[gameIdx], false);
			if (DG_PendingBossSong[gameIdx] != -1)
				DFP_PlayMusic(DG_BossClient[gameIdx], DG_PendingBossSong[gameIdx], false);
				
			// lock in hard/lunatic mode
			DG_Difficulty[gameIdx] = DFP_Difficulty[DG_HeroClient[gameIdx]];
			if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_LUNATIC)
			{
				DG_HeroBombsOnLife[gameIdx] = false;
				DG_HeroAutoBomb[gameIdx] = false;
				CPrintToChat(DG_HeroClient[gameIdx], "Locked into {red}LUNATIC MODE{default} for the duration of the round: You must activate bombs with {green}E{default} and you get no bombs on death. Type {aqua}/%s{default} to change in future games.", CMD_DIFFICULTY);
				CPrintToChat(DG_BossClient[gameIdx], "Hero is playing on {red}LUNATIC MODE{default} for the duration of the round, meaning they must activate bombs manually. Make them pay for their insolence!");
			}
			else if (DG_Difficulty[gameIdx] == DFP_DIFFICULTY_HARD)
			{
				DG_HeroBombsOnLife[gameIdx] = true;
				DG_HeroAutoBomb[gameIdx] = false;
				CPrintToChat(DG_HeroClient[gameIdx], "Locked into {orange}HARD MODE{default} for the duration of the round: You must activate bombs with {green}E{default}. Type {aqua}/%s{default} to change in future games.", CMD_DIFFICULTY);
				CPrintToChat(DG_BossClient[gameIdx], "Hero is playing on {orange}HARD MODE{default} for the duration of the round, meaning they must activate bombs manually. Try to catch them off-guard!");
			}
			else
			{
				DG_HeroBombsOnLife[gameIdx] = true;
				DG_HeroAutoBomb[gameIdx] = true;
				CPrintToChat(DG_HeroClient[gameIdx], "Locked into {green}NORMAL MODE{default} for the duration of the round: Bombs activate when you're hit. Type {aqua}/%s{default} to change in future games.", CMD_DIFFICULTY);
				CPrintToChat(DG_BossClient[gameIdx], "Hero is playing on {green}NORMAL MODE{default} for the duration of the round, meaning they must activate bombs manually. On the bright side, you'll win more points the more you whittle them down.");
			}

			// warning messages telling who the enemy character is
			static String:warningText[MAX_CENTER_TEXT_LENGTH];
			Format(warningText, sizeof(warningText), "Your opponent is %s", CL_BossNames[DG_BossCharacterIdx[gameIdx]]);
			DG_SetHeroAlert(gameIdx, warningText);
			Format(warningText, sizeof(warningText), "Your opponent is %s", CL_HeroNames[DG_HeroCharacterIdx[gameIdx]]);
			DG_SetBossAlert(gameIdx, warningText);
		}
		
		// register any hits simultaneously
		if (DG_HeroHitPending[gameIdx])
		{
			EmitSoundToClient(DG_BossClient[gameIdx], DFP_HIT_SOUND);
			EmitSoundToClient(DG_BossClient[gameIdx], DFP_HIT_SOUND);
			DG_HeroHitPending[gameIdx] = false;
			if (DG_HeroBombs[gameIdx] > 0 && DG_HeroAutoBomb[gameIdx])
			{
				DG_UseBomb(gameIdx);
			}
			else
			{
				DG_SetHeroAlert(gameIdx, "You lost a life!");
				Format(centerText, MAX_CENTER_TEXT_LENGTH, "%s lost a life!", CL_HeroNames[DG_HeroCharacterIdx[gameIdx]]);
				DG_SetBossAlert(gameIdx, centerText);
				DG_HeroLives[gameIdx]--;
				if (DG_HeroBombsOnLife[gameIdx])
					DG_HeroBombs[gameIdx] = DG_HeroBombsPerLife[gameIdx];
				TeleportEntity(DG_HeroClient[gameIdx], DG_HeroSpawns[gameIdx], DG_HeroSpawnAngles[gameIdx], NULL_VECTOR);
				DG_HeroInvincibleUntil[gameIdx] = curTime + DC_InvincibilityDurationNewLife;

				if (DG_HeroLives[gameIdx] >= 0 && strlen(ML_HeroDeathSound) > 3)
				{
					EmitSoundToClient(DG_HeroClient[gameIdx], ML_HeroDeathSound);
					EmitSoundToClient(DG_BossClient[gameIdx], ML_HeroDeathSound);
				}
			}
		}
		if (DG_BossDamagePending[gameIdx] > 0)
		{
			if (curTime >= ML_NextHitSoundAt[gameIdx])
			{
				ML_NextHitSoundAt[gameIdx] = curTime + ML_HitSoundInterval;
				EmitSoundToClient(DG_HeroClient[gameIdx], ML_HitSound);
			}
			DG_BossHealth[gameIdx] -= DG_BossDamagePending[gameIdx];
			DG_BossDamagePending[gameIdx] = 0;
		}

		// handle win conditions
		if (DG_HeroLives[gameIdx] < 0 && DG_BossHealth[gameIdx] <= 0)
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] Match ended in a full on stalemate.");
		
			// stalemate!
			SDKHooks_TakeDamage(DG_HeroClient[gameIdx], DG_BossClient[gameIdx], DG_BossClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
			SDKHooks_TakeDamage(DG_BossClient[gameIdx], DG_HeroClient[gameIdx], DG_HeroClient[gameIdx], 99999.0, DMG_ALWAYSGIB, -1);
			CPrintToChatAll("Stalemate!");
			PrintToServer("Stalemate!");
			DG_HandleQueuePoints(gameIdx, false, false, true);
			DG_Cleanup(gameIdx);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_LOSE);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_LOSE);
			continue;
		}
		else if (DG_HeroLives[gameIdx] < 0)
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] Match ended with boss victory.");
		
			DG_HandleWin(gameIdx, false, false);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_LOSE);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_WIN);
			continue;
		}
		else if (DG_BossHealth[gameIdx] <= 0)
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] Match ended with hero victory.");
		
			DG_HandleWin(gameIdx, true, false);
			DG_RegisterPlayerResult(DG_HeroClient[gameIdx], DG_RESULT_WIN);
			DG_RegisterPlayerResult(DG_BossClient[gameIdx], DG_RESULT_LOSE);
			continue;
		}
		
		// handle phase changes
		new heroAbilityIdx = DG_HeroAbilitySelection[gameIdx];
		new bossAbilityIdx = DG_BossAbilitySelection[gameIdx];
		if (DG_BossNumPhases[gameIdx] > 1)
		{
			new expectedPhase = 1 + ((DG_BossMaxHealth[gameIdx] - DG_BossHealth[gameIdx]) / (DG_BossMaxHealth[gameIdx] / DG_BossNumPhases[gameIdx]));
			if (expectedPhase > DG_BossPhase[gameIdx] && DG_BossPhase[gameIdx] < DG_BossNumPhases[gameIdx])
			{
				DG_BossPhase[gameIdx] = expectedPhase;
				
				static String:tmpText[MAX_CENTER_TEXT_LENGTH];
				Format(tmpText, MAX_CENTER_TEXT_LENGTH, "You have entered phase %d!", DG_BossPhase[gameIdx]);
				DG_SetBossAlert(gameIdx, tmpText);
				Format(tmpText, MAX_CENTER_TEXT_LENGTH, "%s has entered phase %d!", CL_BossNames[DG_BossCharacterIdx[gameIdx]], DG_BossPhase[gameIdx]);
				DG_SetHeroAlert(gameIdx, tmpText);

				// if current ability is unavailable, iterate
				if ((DG_BossAbilityPhases[gameIdx][bossAbilityIdx] & (1<<(DG_BossPhase[gameIdx]-1))) == 0)
					DG_IterateAbilityPressed(gameIdx, false, false);
			}
		}
		
		// handle pending attacks
		new heroFlags = (DFP_KS_Precision[DG_HeroClient[gameIdx]] ? DG_USER_FLAG_FOCUSED : 0);
		new bossFlags = (DFP_KS_Precision[DG_BossClient[gameIdx]] ? DG_USER_FLAG_FOCUSED : 0);
		if (DG_HeroAbilityPending[gameIdx] && curTime >= DG_HeroAbilityOnCooldownUntil[gameIdx][heroAbilityIdx])
		{
			DG_HeroAbilityPending[gameIdx] = false;
			OnAbilityUsed(DG_HeroAbilityFilenames[gameIdx][heroAbilityIdx], gameIdx, DG_HeroAbilityNames[gameIdx][heroAbilityIdx], curTime, 1.0, heroFlags);
			DG_HeroAbilityOnCooldownUntil[gameIdx][heroAbilityIdx] = curTime + DG_HeroAbilityCooldown[gameIdx][heroAbilityIdx];
		}
		if (DG_BossAbilityPending[gameIdx] && curTime >= DG_BossAbilityOnCooldownUntil[gameIdx][bossAbilityIdx] && !DG_BossUsingAbility[gameIdx])
		{
			Format(centerText, MAX_CENTER_TEXT_LENGTH, "%s: %s", DC_BossAbilityTerminology, DG_BossAbilityAestheticName[gameIdx][bossAbilityIdx]);
			DG_SetHeroAlert(gameIdx, centerText);
			DG_BossUsingAbility[gameIdx] = true;
			OnAbilityUsed(DG_BossAbilityFilenames[gameIdx][bossAbilityIdx], gameIdx, DG_BossAbilityNames[gameIdx][bossAbilityIdx], curTime, 1.0, bossFlags);
			DG_BossAbilityOnCooldownUntil[gameIdx][bossAbilityIdx] = curTime + DG_BossAbilityCooldown[gameIdx][bossAbilityIdx];
		}
		DG_BossAbilityPending[gameIdx] = false;
		
		// if bomb is pending, call OnAbilityUsed for the hero's bomb ability/abilities
		if (DG_HeroBombPending[gameIdx])
		{
			for (new bombAbilityIdx = 0; bombAbilityIdx < DG_HeroAbilityCount[gameIdx]; bombAbilityIdx++)
			{
				if (DG_AbilityIsBomb[gameIdx][bombAbilityIdx])
				{
					Format(centerText, MAX_CENTER_TEXT_LENGTH, "%s: %s", DC_HeroAbilityTerminology, DG_HeroAbilityAestheticName[gameIdx][bombAbilityIdx]);
					DG_SetBossAlert(gameIdx, centerText);

					OnAbilityUsed(DG_HeroAbilityFilenames[gameIdx][bombAbilityIdx], gameIdx, DG_HeroAbilityNames[gameIdx][bombAbilityIdx], curTime, 1.0, heroFlags);
				}
			}
		}
			
		// call bomb and game frame for abilities. it's specially set up to handle the excess calls per frame.
		for (new abilityIdx = 0; abilityIdx < DG_HeroAbilityCount[gameIdx]; abilityIdx++)
		{
			if (DG_HeroFilenameIsUnique[gameIdx][abilityIdx])
				ManagedGameFrame(DG_HeroAbilityFilenames[gameIdx][abilityIdx], gameIdx, true, curTime);
		}
		for (new abilityIdx = 0; abilityIdx < DG_BossAbilityCount[gameIdx]; abilityIdx++)
		{
			if (DG_BossFilenameIsUnique[gameIdx][abilityIdx])
				ManagedGameFrame(DG_BossAbilityFilenames[gameIdx][abilityIdx], gameIdx, false, curTime);
		}
			
		// NOW we can set this to false
		DG_HeroBombPending[gameIdx] = false;
			
		// after all that, all that remains is HUD work. player HUD first.
		if (curTime >= DG_UpdateHUDAt[gameIdx])
		{
			DG_UpdateHUDAt[gameIdx] = curTime + DG_HUD_INTERVAL;
		
			if (DG_HudHandle == INVALID_HANDLE)
				DG_HudHandle = CreateHudSynchronizer();
			if (DG_CornerHudHandle == INVALID_HANDLE)
				DG_CornerHudHandle = CreateHudSynchronizer();
			if (DG_WarningHudHandle == INVALID_HANDLE)
				DG_WarningHudHandle = CreateHudSynchronizer();
			
			// hero's ability HUD is minor, but their corner HUD has more information
			static String:bombStatus[MAX_CENTER_TEXT_LENGTH];
			new bombIdx = -1;
			for (new i = 0; i < DG_HeroAbilityCount[gameIdx]; i++)
			{
				if (DG_AbilityIsBomb[gameIdx][i])
				{
					bombIdx = i;
					break;
				}
			}
			if (bombIdx == -1)
				Format(bombStatus, MAX_CENTER_TEXT_LENGTH, "You have no bomb.");
			else if (DG_HeroAutoBomb[gameIdx])
				Format(bombStatus, MAX_CENTER_TEXT_LENGTH, "%s (automatic on hit): %s", DG_HeroAbilityAestheticName[gameIdx][bombIdx], DG_HeroAbilityDescription[gameIdx][bombIdx]);
			else
				Format(bombStatus, MAX_CENTER_TEXT_LENGTH, "%s (E to use): %s", DG_HeroAbilityAestheticName[gameIdx][bombIdx], DG_HeroAbilityDescription[gameIdx][bombIdx]);
			SetHudTextParams(-1.0, DG_HUD_Y, DG_HUD_INTERVAL + 0.5, 255, 255, 255, 255);
			ShowSyncHudText(DG_HeroClient[gameIdx], DG_HudHandle, "%s\nAbility (RELOAD changes): %s\n%s\n%s", CL_HeroNames[DG_HeroCharacterIdx[gameIdx]], 
					DG_HeroAbilityAestheticName[gameIdx][heroAbilityIdx], DG_HeroAbilityDescription[gameIdx][heroAbilityIdx],
					bombStatus);
			static String:bossHPBar[53];
			bossHPBar[0] = '[';
			bossHPBar[51] = ']';
			bossHPBar[52] = 0;
			for (new i = 0; i < 50; i++)
			{
				if ((DG_BossMaxHealth[gameIdx] / 50) * i < DG_BossHealth[gameIdx])
					bossHPBar[i+1] = '|';
				else
					bossHPBar[i+1] = ' ';
			}
			static String:phaseStr[50];
			if (DG_BossNumPhases[gameIdx] <= 1)
				phaseStr[0] = 0;
			else
				Format(phaseStr, sizeof(phaseStr), "Boss Phase: %d", DG_BossPhase[gameIdx]);
			SetHudTextParams(0.03, 0.05, DG_HUD_INTERVAL + 0.5, 255, 255, 255, 255);
			ShowSyncHudText(DG_HeroClient[gameIdx], DG_CornerHudHandle, "Lives: %d\nBombs: %d\nBoss: %s\n%s", DG_HeroLives[gameIdx],
					DG_HeroBombs[gameIdx], bossHPBar, phaseStr);
					
			// hero warning HUD, which can't be a one-off for X seconds. because Valve? I dunno. bah.
			SetHudTextParams(-1.0, DG_WARNING_HUD_Y, DG_HUD_INTERVAL + 0.5, 64, 255, 64, 255);
			if (curTime < DG_WarningHUDUntil[gameIdx])
				ShowSyncHudText(DG_HeroClient[gameIdx], DG_WarningHudHandle, DG_WarningText[gameIdx]);
			else
				ShowSyncHudText(DG_HeroClient[gameIdx], DG_WarningHudHandle, "");

			// finally, boss HUDs
			static String:usabilityStatus[MAX_CENTER_TEXT_LENGTH];
			new bool:usable = false;
			if (DG_BossUsingAbility[gameIdx])
				Format(usabilityStatus, MAX_CENTER_TEXT_LENGTH, "Currently using an ability.");
			else if (curTime < DG_BossAbilityOnCooldownUntil[gameIdx][bossAbilityIdx])
				Format(usabilityStatus, MAX_CENTER_TEXT_LENGTH, "On cooldown for another %.1f seconds.", DG_BossAbilityOnCooldownUntil[gameIdx][bossAbilityIdx] - curTime);
			else if (curTime < DG_NextBossAbilityAt[gameIdx])
				Format(usabilityStatus, MAX_CENTER_TEXT_LENGTH, "All abilities on cooldown for %.1f seconds.", DG_NextBossAbilityAt[gameIdx] - curTime);
			else
			{
				usable = true;
				Format(usabilityStatus, MAX_CENTER_TEXT_LENGTH, "Ability is usable!");
			}
			SetHudTextParams(-1.0, DG_HUD_Y, DG_HUD_INTERVAL + 0.5, 255, usable ? 255 : 0, usable ? 255 : 0, 255);
			ShowSyncHudText(DG_BossClient[gameIdx], DG_HudHandle, "%s\nAbility (RELOAD changes): %s\n%s\n%s", CL_BossNames[DG_BossCharacterIdx[gameIdx]], 
					DG_BossAbilityAestheticName[gameIdx][bossAbilityIdx], DG_BossAbilityDescription[gameIdx][bossAbilityIdx],
					usabilityStatus);
			if (DG_BossNumPhases[gameIdx] > 1)
				Format(phaseStr, sizeof(phaseStr), "Current Phase: %d", DG_BossPhase[gameIdx]);
			SetHudTextParams(0.03, 0.05, DG_HUD_INTERVAL + 0.5, 255, 255, 255, 255);
			ShowSyncHudText(DG_BossClient[gameIdx], DG_CornerHudHandle, "Opponent's Lives: %d\nOpponent's Bombs: %d\nHealth: %d / %d\n%s",
					DG_HeroLives[gameIdx], DG_HeroBombs[gameIdx], DG_BossHealth[gameIdx], DG_BossMaxHealth[gameIdx], phaseStr);
					
			// because I'm trying to figure out why I'm getting screwed over by sync hud
			SetHudTextParams(-1.0, DG_WARNING_HUD_Y, DG_HUD_INTERVAL + 0.5, 64, 255, 64, 255);
			if (curTime >= DG_BossAlertHUDUntil[gameIdx])
				ShowSyncHudText(DG_BossClient[gameIdx], DG_WarningHudHandle, "");
			else
				ShowSyncHudText(DG_BossClient[gameIdx], DG_WarningHudHandle, DG_BossAlertText[gameIdx]);
		}
	}
}

/**
 * Danmaku Beams
 */
Float:DB_ClampBeamWidth(Float:w)
{
	return w > 128.0 ? 128.0 : w;
}
 
public DB_SpawnBeam(gameIdx, bool:isHero, Float:start[3], Float:end[3], Float:radius, color, damage, flags)
{
	// find a free beam, fail if not possible
	new beamIdx = -1;
	new bool:processedOriginal = false;
	DB_LastToSpawn[gameIdx]++;
	if (DB_LastToSpawn[gameIdx] >= DB_MAX_BEAMS)
		DB_LastToSpawn[gameIdx] = 0;
	for (new i = DB_LastToSpawn[gameIdx]; !(DB_LastToSpawn[gameIdx] == i && processedOriginal); i++)
	{
		if (i >= DB_MAX_BEAMS)
		{
			i = 0;
			if (DB_LastToSpawn[gameIdx] == 0)
				break;
		}
	
		if ((DB_Flags[gameIdx][i] & DB_FLAG_ACTIVE) == 0)
		{
			beamIdx = i;
			break;
		}
		
		if (DB_LastToSpawn[gameIdx] == i)
			processedOriginal = true;
	}
	if (beamIdx == -1)
	{
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] WARNING: Max beams reached in game %d. Will not spawn beam.", gameIdx);
		return;
	}

	// clamp radius to 50, and warn
	if (radius > 50.0)
	{
		PrintToServer("[danmaku_fortress] ERROR: Beam radius clamped to 50. Anything above that will not render correctly.");
		radius = 50.0;
	}
	
	// set variables before render
	DB_Flags[gameIdx][beamIdx] = flags | DB_FLAG_ACTIVE;
	DB_BeamExpireTime[gameIdx][beamIdx] = DC_SynchronizedTime + DB_STANDARD_INTERVAL;
	CopyVector(DB_Starts[gameIdx][beamIdx], start);
	CopyVector(DB_Ends[gameIdx][beamIdx], end);
	DB_Radius[gameIdx][beamIdx] = radius;
	DB_Victim[gameIdx][beamIdx] = isHero ? DG_BossClient[gameIdx] : DG_HeroClient[gameIdx];
	DB_Damage[gameIdx][beamIdx] = damage;

	// create the tempent beam last, this code is derived from PhatRages' IonAttack
	// with my main contribution being support for recoloring
	if (DB_Flags[gameIdx][beamIdx] & DB_FLAG_NO_RENDER)
		return;
		
	// play the beam sound. intentionally below the above since non-rendering beams shouldn't play sfx. (they're purely to ensure damage consistency)
	if ((flags & DB_FLAG_NO_SOUND) == 0 && ML_BeamSound[0] != 0 && DC_SynchronizedTime >= ML_NextBeamSoundAt[gameIdx])
	{
		EmitSoundToClient(DG_HeroClient[gameIdx], ML_BeamSound);
		EmitSoundToClient(DG_BossClient[gameIdx], ML_BeamSound);
		ML_NextBeamSoundAt[gameIdx] = DC_SynchronizedTime + ML_BeamSoundInterval;
	}
	
	new r = GetR(color);
	new g = GetG(color);
	new b = GetB(color);
	new Float:diameter = radius * 2.0;
	static colorLayer4[4]; SetColorRGBA(colorLayer4, r, g, b, 255);
	//static colorLayer3[4]; SetColorRGBA(colorLayer3,  (((colorLayer4[0] * 7) + (255 * 1)) / 8),
	//						  (((colorLayer4[1] * 7) + (255 * 1)) / 8),
	//						  (((colorLayer4[2] * 7) + (255 * 1)) / 8),
	//						  255);
	static colorLayer2[4]; SetColorRGBA(colorLayer2,  (((colorLayer4[0] * 6) + (255 * 2)) / 8),
							  (((colorLayer4[1] * 6) + (255 * 2)) / 8),
							  (((colorLayer4[2] * 6) + (255 * 2)) / 8),
							  255);
	//static colorLayer1[4]; SetColorRGBA(colorLayer1,  (((colorLayer4[0] * 5) + (255 * 3)) / 8),
	//						  (((colorLayer4[1] * 5) + (255 * 3)) / 8),
	//						  (((colorLayer4[2] * 5) + (255 * 3)) / 8),
	//						  255);
	//TE_SetupBeamPoints(start, end, DB_Laser, 0, 0, 0, DB_FREQUENCY, DB_ClampBeamWidth(0.3 * diameter * DB_WIDTH_MODIFIER), DB_ClampBeamWidth(0.3 * diameter * DB_WIDTH_MODIFIER), 0, 0.5, colorLayer1, 3);
	//TE_SendToAll();
	TE_SetupBeamPoints(start, end, DB_Laser, 0, 0, 0, DB_FREQUENCY, DB_ClampBeamWidth(0.5 * diameter * DB_WIDTH_MODIFIER), DB_ClampBeamWidth(0.5 * diameter * DB_WIDTH_MODIFIER), 0, 0.5, colorLayer2, 3);
	TE_SendToAll();
	//TE_SetupBeamPoints(start, end, DB_Laser, 0, 0, 0, DB_FREQUENCY, DB_ClampBeamWidth(0.8 * diameter * DB_WIDTH_MODIFIER), DB_ClampBeamWidth(0.8 * diameter * DB_WIDTH_MODIFIER), 0, 0.5, colorLayer3, 3);
	//TE_SendToAll();
	TE_SetupBeamPoints(start, end, DB_Laser, 0, 0, 0, DB_FREQUENCY, DB_ClampBeamWidth(diameter * DB_WIDTH_MODIFIER), DB_ClampBeamWidth(diameter * DB_WIDTH_MODIFIER), 0, 0.5, colorLayer4, 3); // amp was 1.0, now 0.5 (plus 3 above)
	TE_SendToAll();

	// the glow color is just one static color, since the glow has to be a pair of points
	// the way it was done in IonCannon only allowed a purely vertical glow
	if (DB_Glow == 99999) { } // I'll delete this variable when I damn well want to, pesky warning
	//static glowColor[4]; SetColorRGBA(glowColor, r, g, b, 255);
	//TE_SetupBeamPoints(start, end, DB_Glow, 0, 0, 0, DB_FREQUENCY, DB_ClampBeamWidth(diameter * DB_WIDTH_MODIFIER), DB_ClampBeamWidth(diameter * DB_WIDTH_MODIFIER), 0, 1.0, glowColor, 0); // amp was 5.0, now 1.0
	//TE_SendToAll();
}

public DB_DeactivateBeam(gameIdx, beamIdx)
{
	DB_Flags[gameIdx][beamIdx] = 0;
}

public DB_Tick(Float:curTime)
{
	// cache everyone's position, whether they're playing or not
	static Float:playerPos[MAX_PLAYERS_ARRAY][3];
	static bool:playerValid[MAX_PLAYERS_ARRAY];
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		playerValid[clientIdx] = IsLivingPlayer(clientIdx);
		if (playerValid[clientIdx])
		{
			GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", playerPos[clientIdx]);
			if (DFP_Role[clientIdx] == DFP_ROLE_HERO)
				playerPos[clientIdx][2] += DC_HERO_HIT_SPOT_Z_OFFSET;
		}
	}

	// tempents are outside of our control. all we can do is tick to see if it's time to do damage.
	for (new gameIdx = 0; gameIdx < DG_MAX_GAMES; gameIdx++)
	{
		// ensure this game is actually active and registered hits are valid
		if (!DG_Active[gameIdx] || DG_CountdownHUD[gameIdx] > 0)
			continue;
	
		for (new beamIdx = 0; beamIdx < DB_MAX_BEAMS; beamIdx++)
		{
			if ((DB_Flags[gameIdx][beamIdx] & DB_FLAG_ACTIVE) == 0)
				continue;
			else if (curTime >= DB_BeamExpireTime[gameIdx][beamIdx])
			{
				DB_DeactivateBeam(gameIdx, beamIdx);
				continue;
			}

			// should this beam destroy projectiles?
			if ((DB_Flags[gameIdx][beamIdx] & DB_FLAG_DESTROY_PROJECTILES) != 0)
			{
				PrintToServer("TODO implement DB_FLAG_DESTROY_PROJECTILES");
			}

			// if the beam is harmless to the enemy, stop now
			if ((DB_Flags[gameIdx][beamIdx] & DB_FLAG_HARMLESS) != 0)
				continue;

			// finally, deal with the victim
			new victim = DB_Victim[gameIdx][beamIdx];
			if (!playerValid[victim])
				continue;
				
			if (victim == DG_HeroClient[gameIdx])
			{
				if (BeamIntersectsWithPoint(DB_Starts[gameIdx][beamIdx], DB_Ends[gameIdx][beamIdx], DB_Radius[gameIdx][beamIdx], playerPos[victim]))
					DG_OnHeroHit(gameIdx); // that's it. unlike rocket, beam doesn't despawn. (it can't besides)
			}
			else if (curTime >= DB_NextDamageBossAt)
			{
				// boss hitbox is way bigger than the player's hitbox (point)
				static Float:hitbox[2][3];
				hitbox[0][0] = DG_BossHitbox[gameIdx][0][0] + playerPos[victim][0];
				hitbox[0][1] = DG_BossHitbox[gameIdx][0][1] + playerPos[victim][1];
				hitbox[0][2] = DG_BossHitbox[gameIdx][0][2] + playerPos[victim][2];
				hitbox[1][0] = DG_BossHitbox[gameIdx][1][0] + playerPos[victim][0];
				hitbox[1][1] = DG_BossHitbox[gameIdx][1][1] + playerPos[victim][1];
				hitbox[1][2] = DG_BossHitbox[gameIdx][1][2] + playerPos[victim][2];
			
				// there's a lot of math in this call below...
				if (BeamIntersectsWithRectangle(DB_Starts[gameIdx][beamIdx], DB_Ends[gameIdx][beamIdx], DB_Radius[gameIdx][beamIdx], hitbox))
					DG_OnBossHit(gameIdx, DB_Damage[gameIdx][beamIdx]);
			}
		}
	}

	if (curTime >= DB_NextDamageBossAt)
		DB_NextDamageBossAt = curTime + DB_DAMAGE_BOSS_INTERVAL;
}

/**
 * Danmaku Rockets
 */
// create our rocket. no matter what, it's going to spawn, even if it ends up being out of map
#define DR_ROCKET_CLASSNAME "CTFProjectile_Rocket"
#define DR_ROCKET_ENTNAME "tf_projectile_rocket"
	
public DR_GetDefaultFiringPosition(clientIdx, Float:pos[3])
{
	// IMPORTANT: Do not add anything here that is specific to TFPlayer. This can also be used by clones, which are just rockets.
	GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", pos);
	pos[2] += 41.0;
}

public DR_GetHeroHitPosition(gameIdx, Float:pos[3])
{
	GetEntPropVector(DG_HeroClient[gameIdx], Prop_Send, "m_vecOrigin", pos);
	pos[2] += DC_HERO_HIT_SPOT_Z_OFFSET;
}

public DR_GetUnusedRocketPos(gameIdx, rocketIdx, Float:spawnPos[3])
{
	spawnPos[0] = 10000.0 + (float(gameIdx) * 1.0);
	spawnPos[1] = 10000.0 + (float(rocketIdx / 20) * 1.0);
	spawnPos[2] = 10000.0 + (float(rocketIdx % 20) * 1.0);
}

// implied, boss rockets only. makes no sense to freeze hero rockets.
public DR_FreezeAllRockets(gameIdx, Float:duration)
{
	new Float:freezeUntil = DC_SynchronizedTime + duration;
	for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
	{
		if ((DR_Flags[gameIdx][rocketIdx] & DR_FLAG_ACTIVE) == 0 || DR_EntRef[gameIdx][rocketIdx] == INVALID_ENTREF || DR_Victim[gameIdx][rocketIdx] == DG_BossClient[gameIdx])
			continue;
		
		new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
		if (!IsValidEntity(rocket))
			continue;
			
		if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_NONE)
			SetEntityMoveType(rocket, MOVETYPE_NONE);
		DR_FrozenUntil[gameIdx][rocketIdx] = freezeUntil;
	}
}

public DR_FreezeAllRocketsRadius(gameIdx, Float:duration, Float:point[3], Float:radius)
{
	new Float:freezeUntil = DC_SynchronizedTime + duration;
	radius *= radius;
	for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
	{
		if ((DR_Flags[gameIdx][rocketIdx] & DR_FLAG_ACTIVE) == 0 || DR_EntRef[gameIdx][rocketIdx] == INVALID_ENTREF || DR_Victim[gameIdx][rocketIdx] == DG_BossClient[gameIdx])
			continue;
		
		new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
		if (!IsValidEntity(rocket))
			continue;
		
		static Float:rocketPos[3];
		GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketPos);
		if (GetVectorDistance(rocketPos, point) < radius)
		{
			if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_NONE)
				SetEntityMoveType(rocket, MOVETYPE_NONE);
			DR_FrozenUntil[gameIdx][rocketIdx] = freezeUntil;
		}
	}
}

public DR_FreezeAllRocketsRectangle(gameIdx, Float:duration, Float:min[3], Float:max[3])
{
	new Float:freezeUntil = DC_SynchronizedTime + duration;
	for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
	{
		if ((DR_Flags[gameIdx][rocketIdx] & DR_FLAG_ACTIVE) == 0 || DR_EntRef[gameIdx][rocketIdx] == INVALID_ENTREF || DR_Victim[gameIdx][rocketIdx] == DG_BossClient[gameIdx])
			continue;
		
		new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
		if (!IsValidEntity(rocket))
			continue;
		
		static Float:rocketPos[3];
		GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketPos);
		if (rocketPos[0] >= min[0] && rocketPos[0] <= max[0] && rocketPos[1] >= min[1] && rocketPos[1] <= max[1] && rocketPos[2] >= min[2] && rocketPos[2] <= max[2])
		{
			if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_NONE)
				SetEntityMoveType(rocket, MOVETYPE_NONE);
			DR_FrozenUntil[gameIdx][rocketIdx] = freezeUntil;
		}
	}
}

public DR_FreezeLastRocket(gameIdx, Float:duration)
{
	new rocketIdx = DR_LastToSpawn[gameIdx];
	if (DR_EntRef[gameIdx][rocketIdx] == INVALID_ENTREF)
		return;

	new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
	if (!IsValidEntity(rocket))
		return;

	if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_NONE)
		SetEntityMoveType(rocket, MOVETYPE_NONE);
	DR_FrozenUntil[gameIdx][rocketIdx] = DC_SynchronizedTime + duration;
}

public DR_SetInternalParams(gameIdx, Float:param1, Float:param2, Float:param3, Float:param4, Float:param5, Float:param6)
{
	// more specialized union variables, because I'm not adding 16k to data size for one pattern.
	new rocketIdx = DR_LastToSpawn[gameIdx];
	DR_InternalParam1[gameIdx][rocketIdx] = param1;
}

public DR_CacheRocket(gameIdx, rocketIdx)
{
	new rocket = CreateEntityByName(DR_ROCKET_ENTNAME);
	if (!IsValidEntity(rocket))
	{
		PrintToServer("[danmaku_fortress] Error: Invalid entity %s. Won't spawn rocket.", DR_ROCKET_ENTNAME);
		return -1;
	}
	
	static Float:spawnPos[3];
	DR_GetUnusedRocketPos(gameIdx, rocketIdx, spawnPos);

	//if (PRINT_DEBUG_SPAM)
	//	PrintToServer("caching rocket #%d for game #%d, at position %f,%f,%f", rocketIdx, gameIdx, spawnPos[0], spawnPos[1], spawnPos[2]);
			
	// deploy!
	TeleportEntity(rocket, spawnPos, Float:{0.0,0.0,0.0}, Float:{0.0,0.0,0.0});
	DispatchSpawn(rocket);
	
	// movetype none may improve performance? also perhaps making it not solid...
	SetEntityMoveType(rocket, MOVETYPE_NONE);
	SetEntProp(rocket, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID); // not solid
	SetEntProp(rocket, Prop_Send, "m_nSolidType", SOLID_NONE); // not solid
	
	// reskinning now, otherwise it'll get the unwanted trail
	SetEntProp(rocket, Prop_Send, "m_nModelIndex", DC_PROJECTILE_MODEL_INDEX);
		
	// change collision group, so actual player collisions can't happen
	SetEntProp(rocket, Prop_Send, "m_CollisionGroup", COLLISION_GROUP_DEBRIS);
	
	// store this rocket now
	DR_EntRef[gameIdx][rocketIdx] = EntIndexToEntRef(rocket);
	DR_Flags[gameIdx][rocketIdx] = 0;

	return rocket;
}

// these two used to actually spawn rockets, but now they recycle rockets. spawning happens in DR_CacheRocket()
// for more information, see: https://forums.alliedmods.net/showthread.php?t=265374
public DR_SpawnRocket(gameIdx, bool:isHero, Float:angles[3], Float:radius, Float:speed, color, damage, patternIdx, Float:param1, Float:param2, Float:lifetimeOverride, flags)
{
	new clientIdx = isHero ? DG_HeroClient[gameIdx] : DG_BossClient[gameIdx];

	static Float:spawnPos[3];
	DR_GetDefaultFiringPosition(clientIdx, spawnPos);
	
	// this is necessary to prevent spawn collisions
	spawnPos[0] += GetRandomFloat(-1.0, 1.0);
	spawnPos[1] += GetRandomFloat(-1.0, 1.0);
	spawnPos[2] += GetRandomFloat(-1.0, 1.0);
	
	return DR_SpawnRocketAt(gameIdx, isHero, spawnPos, angles, radius, speed, color, damage, patternIdx, param1, param2, lifetimeOverride, flags);
}

public bool:DR_IsAffectedByBomb(gameIdx, const Float:position[3], Float:targetRadius)
{
	if (DG_RadiusBombActive[gameIdx] && ArePointsInRange(DG_BombPos[gameIdx], position, DG_BombRadius[gameIdx] + targetRadius))
		return true;
	
	// note that rect and radius bomb can exist simultaneously. because why not.
	if (DG_RectangleBombActive[gameIdx] && IsSphereInRect(DG_BombRect[gameIdx], position, targetRadius))
		return true;
		
	// and now beam bomb joins the party
	if (DG_BeamBombActive[gameIdx])
	{
		// and it also has somewhat more complex logic. though most of it has been done for beam already.
		// since that operates with a beam versus a point, and this operates a beam versus a sphere, we combine both radii.
		new Float:radii = targetRadius + DG_BeamBombRadius[gameIdx];
		if (BeamIntersectsWithPoint(DG_BeamBombPoint1[gameIdx], DG_BeamBombPoint2[gameIdx], radii, position))
			return true;
	}
	
	return false;
}
 
public DR_SpawnRocketAt(gameIdx, bool:isHero, Float:spawnPos[3], Float:angles[3], Float:radius, Float:speed, color, damage, patternIdx, Float:param1, Float:param2, Float:lifetimeOverride, flags)
{
	// stop this before it starts if it's in the path of a bomb
	// only important for recycle mode, since the projectile is visible right away
	if (!isHero)
	{
		if ((flags & DR_FLAG_BOMB_PROOF) == 0 && DR_IsAffectedByBomb(gameIdx, spawnPos, radius))
			return -1;
			
		damage = 0; // set damage to a predictable 0 for boss rockets so they can be reappropriated
	}
	
	// don't allow spawning out of bounds
	if (!IsPointInRect(DG_RecycleBoundsRect[gameIdx], spawnPos))
	{
		if (PRINT_DEBUG_SPAM && (flags & DR_FLAG_OOB_NO_WARN) == 0)
			PrintToServer("[danmaku_fortress] WARNING: Attempted to spawn a projectile out of bounds. Check your ability's logic: %s (pos=%f,%f,%f)",
				isHero ? DG_HeroAbilityAestheticName[gameIdx][DG_HeroAbilitySelection[gameIdx]] : DG_BossAbilityAestheticName[gameIdx][DG_BossAbilitySelection[gameIdx]],
				spawnPos[0], spawnPos[1], spawnPos[2]);
		return -1;
	}

	new clientIdx = isHero ? DG_HeroClient[gameIdx] : DG_BossClient[gameIdx];
	new victim = isHero ? DG_BossClient[gameIdx] : DG_HeroClient[gameIdx];

	// find a free slot for this rocket. fail if no slot available.
	new rocketIdx = -1;
	new bool:processedOriginal = false;
	DR_LastToSpawn[gameIdx]++;
	if (DR_LastToSpawn[gameIdx] >= DR_MAX_ROCKETS)
		DR_LastToSpawn[gameIdx] = 0;
	for (new i = DR_LastToSpawn[gameIdx]; !(DR_LastToSpawn[gameIdx] == i && processedOriginal); i++)
	{
		if (i >= DR_MAX_ROCKETS)
		{
			i = 0;
			if (DR_LastToSpawn[gameIdx] == 0)
				break;
		}
	
		if ((DR_Flags[gameIdx][i] & DR_FLAG_ACTIVE) == 0)
		{
			rocketIdx = i;
			break;
		}
		
		if (DR_LastToSpawn[gameIdx] == i)
			processedOriginal = true;
	}
	if (rocketIdx == -1)
	{
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] WARNING: Max rockets reached in game %d. Will not spawn rocket.", gameIdx);
		return -1;
	}

	new rocket = (DR_EntRef[gameIdx][rocketIdx] == INVALID_ENTREF ? -1 : EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]));
	if (!IsValidEntity(rocket))
	{
		if (PRINT_DEBUG_INFO && DR_EntRef[gameIdx][rocketIdx] != INVALID_ENTREF)
			PrintToServer("[danmaku_fortress] WARNING: Rocket despawned on its own. Likely due to high projectile speed.");
		rocket = DR_CacheRocket(gameIdx, rocketIdx);
		if (!IsValidEntity(rocket))
		{
			PrintToServer("[danmaku_fortress] Error: Cannot make a valid substitute rocket. Giving up.");
			return -1;
		}
	}
	
	// adjust speed now, if it's -1.0, set it to owner move speed
	if (speed == -1.0)
		speed = DFP_MaxSpeed[clientIdx];
	
	// get starting velocity
	static Float:velocity[3];
	GetAngleVectors(angles, velocity, NULL_VECTOR, NULL_VECTOR);
	if (patternIdx == DR_PATTERN_LAZY_HOMING || patternIdx == DR_PATTERN_DELAYED_SEEKING || patternIdx == DR_PATTERN_SUBPLUGIN_DEFINED)
		ScaleVector(velocity, 0.0);
	else
		ScaleVector(velocity, speed);
		
	// do this early, because the angle will be corrupted
	DR_RocketSpawnAngle[gameIdx][rocketIdx][0] = angles[0];
	DR_RocketSpawnAngle[gameIdx][rocketIdx][1] = angles[1];
	if (flags & DR_FLAG_DISPOSE_PITCH)
		angles[0] = 0.0; // pitch is still used for motion, just not positioning
	
	// deploy!
	TeleportEntity(rocket, spawnPos, angles, velocity);
	// this will cause them to despawn with the client. no good
	//SetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity", clientIdx);
	
	// reskin if necessary, make scale appropriate to radius, and recolor
	if (GetEntProp(rocket, Prop_Send, "m_nModelIndex") != DC_PROJECTILE_MODEL_INDEX)
		SetEntProp(rocket, Prop_Send, "m_nModelIndex", DC_PROJECTILE_MODEL_INDEX);
	new Float:adjustedRadius = radius;
	if ((flags & DR_FLAG_SPAWNER) == 0 && isHero)
		adjustedRadius *= DC_HeroProjectileResize;
	new Float:modelScale = GetActualModelScale(DC_PROJECTILE_MODEL_RADIUS, adjustedRadius);
	SetEntPropFloat(rocket, Prop_Send, "m_flModelScale", modelScale);
	SetEntityRenderMode(rocket, RENDER_TRANSCOLOR);
	SetEntityRenderColor(rocket, GetR(color), GetG(color), GetB(color), 255);
	
	// store everything (except ent ref in this version, it's already stored)
	SetEntityMoveType(rocket, MOVETYPE_FLY);
	//SetEntProp(rocket, Prop_Send, "m_usSolidFlags", 0);
	DR_Damage[gameIdx][rocketIdx] = damage;
	DR_Victim[gameIdx][rocketIdx] = victim;
	DR_StartRadius[gameIdx][rocketIdx] = DR_Radius[gameIdx][rocketIdx] = radius;
	DR_Speed[gameIdx][rocketIdx] = speed;
	DR_Pattern[gameIdx][rocketIdx] = patternIdx;
	DR_Param1[gameIdx][rocketIdx] = param1;
	DR_Param2[gameIdx][rocketIdx] = param2;
	DR_RocketSpawnTime[gameIdx][rocketIdx] = DC_SynchronizedTime;
	DR_RocketExpireTime[gameIdx][rocketIdx] = DR_RocketSpawnTime[gameIdx][rocketIdx] + (lifetimeOverride > 0.0 ? lifetimeOverride : DR_DEFAULT_LIFETIME);
	// NOTE: the above is special in that the roll is not stored. (requires around 7500 bytes of data to store each axis)
	CopyVector(DR_OldRocketPos[gameIdx][rocketIdx], spawnPos); // unfortunately, I couldn't shrink this one.
	DR_Flags[gameIdx][rocketIdx] = (DR_FLAG_ACTIVE | flags);
	DR_FrozenUntil[gameIdx][rocketIdx] = FAR_FUTURE;
	DR_LastToSpawn[gameIdx] = rocketIdx;
	DR_InternalParam1[gameIdx][rocketIdx] = 0.0;
		
	// fixes
	if (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_WAVE || DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_VERTICAL_WAVE)
		if (DR_Param2[gameIdx][rocketIdx] <= 0.0)
			DR_Param2[gameIdx][rocketIdx] = 1.0;
	
	// since it was clearly successful, play the sound
	if ((flags & DR_FLAG_NO_SHOT_SOUND) == 0 && ML_RocketSound[0] != 0 && DC_SynchronizedTime >= ML_NextRocketSoundAt[gameIdx])
	{
		EmitAmbientSound(ML_RocketSound, spawnPos, rocket);
		ML_NextRocketSoundAt[gameIdx] = DC_SynchronizedTime + ML_RocketSoundInterval;
	}
	
	return rocket;
}

// this version is a wrapper. it doesn't destroy the rocket, it moves the rocket out of play.
public DR_DestroyRocket(gameIdx, rocketIdx, rocket)
{
	static Float:spawnPos[3];
	DR_GetUnusedRocketPos(gameIdx, rocketIdx, spawnPos);
	TeleportEntity(rocket, spawnPos, Float:{0.0,0.0,0.0}, Float:{0.0,0.0,0.0});
	if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_NONE)
		SetEntityMoveType(rocket, MOVETYPE_NONE);
	if (GetEntProp(rocket, Prop_Send, "m_nModelIndex") != DC_PROJECTILE_MODEL_INDEX) // some abilities will reskin the projectile
		SetEntProp(rocket, Prop_Send, "m_nModelIndex", DC_PROJECTILE_MODEL_INDEX);
	//SetEntProp(rocket, Prop_Send, "m_usSolidFlags", FSOLID_NOT_SOLID); // not solid
	
	// if it's a subplugin managed rocket, report this rocket's destruction
	if (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_SUBPLUGIN_DEFINED)
	{
		if (DS_IsHero[gameIdx][rocketIdx])
		{
			for (new abilityIdx = 0; abilityIdx < DG_HeroAbilityCount[gameIdx]; abilityIdx++)
				if (DG_HeroFilenameIsUnique[gameIdx][abilityIdx])
					SubpluginRocketDestroyed(DG_HeroAbilityFilenames[gameIdx][abilityIdx], gameIdx, DR_EntRef[gameIdx][rocketIdx]);
		}
		else
		{
			for (new abilityIdx = 0; abilityIdx < DG_BossAbilityCount[gameIdx]; abilityIdx++)
				if (DG_BossFilenameIsUnique[gameIdx][abilityIdx])
					SubpluginRocketDestroyed(DG_BossAbilityFilenames[gameIdx][abilityIdx], gameIdx, DR_EntRef[gameIdx][rocketIdx]);
		}
	}
	
	// if it's a spawner, report it to subplugins
	if (DR_Flags[gameIdx][rocketIdx] & DR_FLAG_SPAWNER)
		DS_OnSpawnerDestroyed(gameIdx, rocketIdx);
	DR_Flags[gameIdx][rocketIdx] = 0;
}

public DR_Cleanup(gameIdx)
{
	for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
	{
		new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
		if (!IsValidEntity(rocket))
		{
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] WARNING: Rocket despawned on its own. Likely due to high projectile speed.");
			DR_EntRef[gameIdx][rocketIdx] = INVALID_ENTREF;
		}
		else if ((DR_Flags[gameIdx][rocketIdx] & DR_FLAG_ACTIVE) != 0)
			DR_DestroyRocket(gameIdx, rocketIdx, rocket);
	}
}

DR_ManagedTeleport(gameIdx, rocketIdx, rocket, const Float:newPos[3], const Float:angle[3], Float:velocity[3], const Float:rocketPos[3], bool:isProtected = false)
{
	// prevent OOB if it's a "protected" pattern
	if (isProtected)
	{
		if (velocity[0] < 0.0 && (rocketPos[0] - DG_RecycleBoundsRect[gameIdx][0][0]) < 50.0)
			velocity[0] = 0.0;
		else if (velocity[0] > 0.0 && (DG_RecycleBoundsRect[gameIdx][1][0] - rocketPos[0]) < 50.0)
			velocity[0] = 0.0;
			
		if (velocity[1] < 0.0 && (rocketPos[1] - DG_RecycleBoundsRect[gameIdx][0][1]) < 50.0)
			velocity[1] = 0.0;
		else if (velocity[1] > 0.0 && (DG_RecycleBoundsRect[gameIdx][1][1] - rocketPos[1]) < 50.0)
			velocity[1] = 0.0;
		
		if (velocity[2] < 0.0 && (rocketPos[2] - DG_RecycleBoundsRect[gameIdx][0][2]) < 50.0)
			velocity[2] = 0.0;
		else if (velocity[2] > 0.0 && (DG_RecycleBoundsRect[gameIdx][1][2] - rocketPos[2]) < 50.0)
			velocity[2] = 0.0;
	}
	
	if (DR_Flags[gameIdx][rocketIdx] & DR_FLAG_DISPOSE_PITCH)
	{
		static Float:fixedAngle[3];
		fixedAngle[0] = fixedAngle[2] = 0.0;
		fixedAngle[1] = angle[1];
		TeleportEntity(rocket, newPos, fixedAngle, velocity);
	}
	else
		TeleportEntity(rocket, newPos, angle, velocity);
}

public DR_Tick(Float:curTime)
{
	// cache rockets if using the "storage" mode. this is only done once.
	if (curTime >= DR_CacheRocketsAt)
	{
		DR_CacheRocketsAt = FAR_FUTURE;
		for (new gameIdx = 0; gameIdx < DG_MaxGames; gameIdx++)
			for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
				DR_CacheRocket(gameIdx, rocketIdx);
	}

	// cache everyone's position, whether they're playing or not
	static Float:playerPos[MAX_PLAYERS_ARRAY][3];
	static bool:playerValid[MAX_PLAYERS_ARRAY];
	for (new clientIdx = 1; clientIdx < MAX_PLAYERS; clientIdx++)
	{
		playerValid[clientIdx] = IsLivingPlayer(clientIdx);
		if (playerValid[clientIdx])
		{
			GetEntPropVector(clientIdx, Prop_Send, "m_vecOrigin", playerPos[clientIdx]);
			if (DFP_Role[clientIdx] == DFP_ROLE_HERO)
				playerPos[clientIdx][2] += DC_HERO_HIT_SPOT_Z_OFFSET;
		}
	}

	for (new gameIdx = 0; gameIdx < DG_MaxGames; gameIdx++)
	{
		// ensure this game is actually active and registered hits are valid
		if (!DG_Active[gameIdx] || DG_CountdownHUD[gameIdx] > 0)
			continue;
	
		for (new rocketIdx = 0; rocketIdx < DR_MAX_ROCKETS; rocketIdx++)
		{
			new flags = DR_Flags[gameIdx][rocketIdx];
		
			// ensure rocket is valid
			if ((flags & DR_FLAG_ACTIVE) == 0)
				continue;
			new rocket = EntRefToEntIndex(DR_EntRef[gameIdx][rocketIdx]);
			if (!IsValidEntity(rocket))
			{
				if (PRINT_DEBUG_INFO)
					PrintToServer("[danmaku_fortress] WARNING: Rocket despawned on its own. Likely due to high projectile speed.");
				DR_EntRef[gameIdx][rocketIdx] = INVALID_ENTREF;
				DR_Flags[gameIdx][rocketIdx] = 0;
				continue;
			}
			
			// ensure victim is valid
			new victim = DR_Victim[gameIdx][rocketIdx];
			if (!playerValid[victim])
				continue;
				
			// unique to recycle method: if the rocket is out of bounds, return it to the pile
			static Float:rocketPos[3];
			GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", rocketPos);
			if (!IsPointInRect(DG_RecycleBoundsRect[gameIdx], rocketPos))
			{
				// again, not really destroy. it's the wrapper for both methods
				DR_DestroyRocket(gameIdx, rocketIdx, rocket);
				continue;
			}
				
			// regardless of if hero is invincible or not, see if projectile should be destroyed by a bomb
			if (victim == DG_HeroClient[gameIdx] && (flags & DR_FLAG_BOMB_PROOF) == 0)
			{
				if (DR_IsAffectedByBomb(gameIdx, rocketPos, DR_Radius[gameIdx][rocketIdx]))
				{
					DR_DestroyRocket(gameIdx, rocketIdx, rocket);
					continue;
				}
			}
				
			// first, collision test happens every frame
			if ((flags & DR_FLAG_NO_COLLIDE) == 0)
			{
				if (victim == DG_HeroClient[gameIdx])
				{
					if (IsLineInRangeOfPoint(playerPos[victim], DR_OldRocketPos[gameIdx][rocketIdx], rocketPos, DR_Radius[gameIdx][rocketIdx]))
					{
						DG_OnHeroHit(gameIdx);
							
						// destroy the rocket and move on
						DR_DestroyRocket(gameIdx, rocketIdx, rocket);
						continue;
					}
				}
				else if (victim == DG_BossClient[gameIdx])
				{
					// boss hitbox is way bigger than the player's hitbox (point)
					static Float:hitbox[2][3];
					hitbox[0][0] = DG_BossHitbox[gameIdx][0][0] + playerPos[victim][0];
					hitbox[0][1] = DG_BossHitbox[gameIdx][0][1] + playerPos[victim][1];
					hitbox[0][2] = DG_BossHitbox[gameIdx][0][2] + playerPos[victim][2];
					hitbox[1][0] = DG_BossHitbox[gameIdx][1][0] + playerPos[victim][0];
					hitbox[1][1] = DG_BossHitbox[gameIdx][1][1] + playerPos[victim][1];
					hitbox[1][2] = DG_BossHitbox[gameIdx][1][2] + playerPos[victim][2];
					
					// need rocket pos
					new Float:radius = DR_Radius[gameIdx][rocketIdx];
					
					// revamped hitbox code, it still sucks and will fail with fast projectiles, but it's better than the original
					// basically testing the old and new position of the projectile versus the rect
					// doesn't handle projectile motion much at all, but it's better than nothing.
					if (IsRectInRangeOfPointCheap(rocketPos, hitbox, radius) || IsRectInRangeOfPointCheap(DR_OldRocketPos[gameIdx][rocketIdx], hitbox, radius))
					{
						DG_OnBossHit(gameIdx, DR_Damage[gameIdx][rocketIdx]);
						DR_DestroyRocket(gameIdx, rocketIdx, rocket);
						continue;
					}
				}
			}
			CopyVector(DR_OldRocketPos[gameIdx][rocketIdx], rocketPos);
			
			// this last ditch effort of collision failed, so is it time to despawn the rocket?
			if (curTime >= DR_RocketExpireTime[gameIdx][rocketIdx])
			{
				if (PRINT_DEBUG_SPAM)
					PrintToServer("[danmaku_fortress] Rocket (game=%d, rocket=%d) reached end of life and will despawn.", gameIdx, rocketIdx);
				DR_DestroyRocket(gameIdx, rocketIdx, rocket);
				continue;
			}
			
			// frozen rockets have no logic
			if (DR_FrozenUntil[gameIdx][rocketIdx] != FAR_FUTURE)
			{
				if (curTime >= DR_FrozenUntil[gameIdx][rocketIdx])
				{
					DR_FrozenUntil[gameIdx][rocketIdx] = FAR_FUTURE;
					if (GetEntProp(rocket, Prop_Send, "movetype") != any:MOVETYPE_FLY)
						SetEntityMoveType(rocket, MOVETYPE_FLY);
				}
				else
					continue;
			}
			
			// rainbow recoloring
			if (flags & DR_FLAG_RAINBOW_COLORED)
			{
				new color = GetTimedRainbowColor(getFloatDecimalComponent(curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]));
				SetEntityRenderColor(rocket, GetR(color), GetG(color), GetB(color), 255);
			}
			
			// certain abilities are best off with their own synchronization
			if (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_SHARP_TURN || DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_REPEAT_TURNS)
			{
				static Float:rocketAngle[3];
				GetEntPropVector(rocket, Prop_Data, "m_angRotation", rocketAngle);

				// in the interest in keeping the variable count low, damage is being used as a counter
				// only bosses will use sharp turn. it makes no sense for heroes to use it.
				new turnCount = DR_Damage[gameIdx][rocketIdx];
				new turnsExpected = getWholeComponent((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) / DR_Param2[gameIdx][rocketIdx]);
				if (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_SHARP_TURN)
					turnsExpected = min(1, turnsExpected);

				if (turnsExpected > turnCount)
				{
					turnCount = turnsExpected;
					DR_RocketSpawnAngle[gameIdx][rocketIdx][1] += DR_Param1[gameIdx][rocketIdx];
					fixAngle(DR_RocketSpawnAngle[gameIdx][rocketIdx][1]);
					rocketAngle[0] = DR_RocketSpawnAngle[gameIdx][rocketIdx][0];
					rocketAngle[1] = DR_RocketSpawnAngle[gameIdx][rocketIdx][1];
					static Float:velocity[3];
					GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(velocity, DR_Speed[gameIdx][rocketIdx]);
					DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos);
				}

				// using this as a union variable
				DR_Damage[gameIdx][rocketIdx] = turnCount;
			}
			else if (curTime >= DR_ReorientAt) // typical rockets aren't reoriented every frame
			{
				new Float:deltaTime = fmin(DR_REORIENT_INTERVAL * 2, DR_REORIENT_INTERVAL + (curTime - DR_ReorientAt));
				static Float:rocketAngle[3];
				GetEntPropVector(rocket, Prop_Data, "m_angRotation", rocketAngle);
				switch (DR_Pattern[gameIdx][rocketIdx])
				{
					case DR_PATTERN_ANGLE:
					{
						new Float:pitchAtZeroYaw = DR_RocketSpawnAngle[gameIdx][rocketIdx][0];
						new Float:yawOffset = DR_RocketSpawnAngle[gameIdx][rocketIdx][1];
						new Float:fullRotationTime = 360.0 / DR_Param1[gameIdx][rocketIdx];
						new Float:timeInCurrentRotation = ((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) + DR_InternalParam1[gameIdx][rocketIdx]);
						timeInCurrentRotation = FloatModulus(timeInCurrentRotation, fullRotationTime);
						static Float:velocity[3];

						new Float:newYaw = fixAngle(-(360.0 * (timeInCurrentRotation / fullRotationTime)));
						if (flags & DR_FLAG_ANGLE_CCW)
							newYaw = -newYaw;
						new Float:newPitch = 0.0;
						if (newYaw >= -90.0 && newYaw <= 90.0)
							newPitch = (1.0 - (fabs(newYaw) / 90.0)) * pitchAtZeroYaw;
						else if (newYaw < -90.0 || newYaw > 90.0)
							newPitch = -((fabs(newYaw) - 90.0) / 90.0) * pitchAtZeroYaw;
						newYaw = fixAngle(newYaw + yawOffset);

						rocketAngle[0] = newPitch;
						rocketAngle[1] = newYaw;
						GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);

						// velocity scaling requires knowing how far into the rocket's lifetime we are
						new Float:scaleFactor = DR_Speed[gameIdx][rocketIdx] + (DR_Speed[gameIdx][rocketIdx] * (curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) * DR_Param2[gameIdx][rocketIdx]);
						ScaleVector(velocity, scaleFactor);

						DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos);
					}
					case DR_PATTERN_WAVE, DR_PATTERN_VERTICAL_WAVE:
					{
						// all wave rockets have a wavelength of 1 second, for simplicity sake
						new Float:axisOffset = 0.0;
						new Float:wavePosition = getFloatDecimalComponent((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) / DR_Param2[gameIdx][rocketIdx]);
						if (wavePosition < 0.25)
							axisOffset = wavePosition * DR_Param1[gameIdx][rocketIdx];
						else if (wavePosition < 0.5)
							axisOffset = (0.5 - wavePosition) * DR_Param1[gameIdx][rocketIdx];
						else if (wavePosition < 0.75)
							axisOffset = -((wavePosition - 0.5) * DR_Param1[gameIdx][rocketIdx]);
						else
							axisOffset = -((0.5 - (wavePosition - 0.5)) * DR_Param1[gameIdx][rocketIdx]);
						axisOffset *= 4.0; // adjust for the fact the above limits to a range of 0.0 to 0.25
						
						// change the yaw only
						rocketAngle[0] = DR_RocketSpawnAngle[gameIdx][rocketIdx][0] + (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_VERTICAL_WAVE ? axisOffset : 0.0);
						rocketAngle[1] = fixAngle(DR_RocketSpawnAngle[gameIdx][rocketIdx][1] + (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_WAVE ? axisOffset : 0.0));

						// recalculate velocity and spawn
						//PrintToServer("angle=%f,%f,%f", rocketAngle[0], rocketAngle[1], rocketAngle[2]);
						static Float:velocity[3];
						GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
						ScaleVector(velocity, DR_Speed[gameIdx][rocketIdx]);
						DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos);
					}
					case DR_PATTERN_HOMING: // adapted from my Thi Barrett FF2 boss
					{
						// need to get angles to intended victim
						static Float:tmpAngles[3];
						GetRayAngles(rocketPos, playerPos[victim], tmpAngles);
							
						new Float:maxAngleDeviation = DR_Param1[gameIdx][rocketIdx] * deltaTime;
						for (new i = 0; i < 2; i++)
						{
							if (fabs(rocketAngle[i] - tmpAngles[i]) <= 180.0)
							{
								if (rocketAngle[i] - tmpAngles[i] < 0.0)
									rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - rocketAngle[i]);
								else
									rocketAngle[i] -= fmin(maxAngleDeviation, rocketAngle[i] - tmpAngles[i]);
							}
							else // it wrapped around
							{
								new Float:tmpRocketAngle = rocketAngle[i];

								if (rocketAngle[i] - tmpAngles[i] < 0.0)
									tmpRocketAngle += 360.0;
								else
									tmpRocketAngle -= 360.0;

								if (tmpRocketAngle - tmpAngles[i] < 0.0)
									rocketAngle[i] += fmin(maxAngleDeviation, tmpAngles[i] - tmpRocketAngle);
								else
									rocketAngle[i] -= fmin(maxAngleDeviation, tmpRocketAngle - tmpAngles[i]);
							}

							rocketAngle[i] = fixAngle(rocketAngle[i]);
						}

						static Float:velocity[3];
						GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
						ScaleVector(velocity, DR_Speed[gameIdx][rocketIdx]);
						DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos);
					}
					case DR_PATTERN_CHAOTIC, DR_PATTERN_CHAOTIC_PROTECTED, DR_PATTERN_CHAOTIC_DELAYED:
					{
						if (DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_CHAOTIC_DELAYED)
							if (curTime < DR_RocketSpawnTime[gameIdx][rocketIdx] + DR_Param2[gameIdx][rocketIdx])
								continue;
								
						// chaotic is very easy. just complete RNG
						new Float:maxAngleDeviation = DR_Param1[gameIdx][rocketIdx] * deltaTime;
						DR_RocketSpawnAngle[gameIdx][rocketIdx][0] = fixAngle(DR_RocketSpawnAngle[gameIdx][rocketIdx][0] + GetRandomFloat(-maxAngleDeviation, maxAngleDeviation));
						DR_RocketSpawnAngle[gameIdx][rocketIdx][1] = fixAngle(DR_RocketSpawnAngle[gameIdx][rocketIdx][1] + GetRandomFloat(-maxAngleDeviation, maxAngleDeviation));
						rocketAngle[0] = DR_RocketSpawnAngle[gameIdx][rocketIdx][0];
						rocketAngle[1] = DR_RocketSpawnAngle[gameIdx][rocketIdx][1];

						static Float:velocity[3];
						GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
						ScaleVector(velocity, DR_Speed[gameIdx][rocketIdx]);
								
						DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos, DR_Pattern[gameIdx][rocketIdx] == DR_PATTERN_CHAOTIC_PROTECTED);
					}
					case DR_PATTERN_LAZY_HOMING:
					{
						// in the interest in keeping the variable count low, damage is being used as a counter
						// only bosses will use lazy homing. it makes no sense for heroes to use it.
						new deviationCount = DR_Damage[gameIdx][rocketIdx];
						new deviationsExpected = 1 + getWholeComponent((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) / DR_Param1[gameIdx][rocketIdx]);
						if (deviationsExpected > deviationCount)
						{
							GetVectorAnglesTwoPoints(rocketPos, playerPos[victim], rocketAngle);
							DR_RocketSpawnAngle[gameIdx][rocketIdx][0] = rocketAngle[0];
							DR_RocketSpawnAngle[gameIdx][rocketIdx][1] = rocketAngle[1];
							static Float:velocity[3];
							velocity[0] = velocity[1] = velocity[2] = 0.0;
							DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos);
							deviationCount = deviationsExpected;
						}
						else
						{
							rocketAngle[0] = DR_RocketSpawnAngle[gameIdx][rocketIdx][0];
							rocketAngle[1] = DR_RocketSpawnAngle[gameIdx][rocketIdx][1];
							
							// if we're in the speedup or slowdown phases, handle it
							new Float:speed = DR_Speed[gameIdx][rocketIdx];
							new Float:phaseVal = getFloatDecimalComponent((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) / DR_Param1[gameIdx][rocketIdx]);
							if (phaseVal < 0.15)
								speed *= phaseVal;
							else if (phaseVal > 0.85)
								speed *= 1.0 - phaseVal;
							
							// adjust the velocity
							static Float:velocity[3];
							GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
							ScaleVector(velocity, speed);
				
							// now we can push the rocket. it's protected, meaning we prevent OOB motion
							DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, NULL_VECTOR, velocity, rocketPos, true);
						}

						// using this as a union variable
						DR_Damage[gameIdx][rocketIdx] = deviationCount;
					}
					case DR_PATTERN_DELAYED_SEEKING:
					{
						if (curTime < DR_RocketSpawnTime[gameIdx][rocketIdx] + DR_Param1[gameIdx][rocketIdx])
							continue;
						
						if ((flags & DR_FLAG_ANGLE_LOCKED) == 0)
						{
							DR_Flags[gameIdx][rocketIdx] |= DR_FLAG_ANGLE_LOCKED;
							GetVectorAnglesTwoPoints(rocketPos, playerPos[victim], rocketAngle);
							DR_RocketSpawnAngle[gameIdx][rocketIdx][0] = rocketAngle[0];
							DR_RocketSpawnAngle[gameIdx][rocketIdx][1] = rocketAngle[1];
						}
						else
						{
							rocketAngle[0] = DR_RocketSpawnAngle[gameIdx][rocketIdx][0];
							rocketAngle[1] = DR_RocketSpawnAngle[gameIdx][rocketIdx][1];
						}
						
						// get speed based on time and push
						new Float:speed = DR_Speed[gameIdx][rocketIdx];
						if (curTime < DR_RocketSpawnTime[gameIdx][rocketIdx] + DR_Param1[gameIdx][rocketIdx] + DR_Param2[gameIdx][rocketIdx])
							speed *= 1.0 - ((curTime - (DR_RocketSpawnTime[gameIdx][rocketIdx] + DR_Param1[gameIdx][rocketIdx])) / DR_Param2[gameIdx][rocketIdx]);
						static Float:velocity[3];
						GetAngleVectors(rocketAngle, velocity, NULL_VECTOR, NULL_VECTOR);
						ScaleVector(velocity, speed);
						DR_ManagedTeleport(gameIdx, rocketIdx, rocket, NULL_VECTOR, rocketAngle, velocity, rocketPos, false);
					}
					case DR_PATTERN_RESIZING:
					{
						new Float:expectedSize = DR_StartRadius[gameIdx][rocketIdx];
						if (curTime - DR_RocketSpawnTime[gameIdx][rocketIdx] >= DR_Param2[gameIdx][rocketIdx])
							expectedSize *= DR_Param1[gameIdx][rocketIdx];
						else
							expectedSize *= DR_Param1[gameIdx][rocketIdx] * ((curTime - DR_RocketSpawnTime[gameIdx][rocketIdx]) / DR_Param2[gameIdx][rocketIdx]);
							
						// only do the more hardcore changes if necessary
						if (expectedSize != DR_Radius[gameIdx][rocketIdx])
						{
							DR_Radius[gameIdx][rocketIdx] = expectedSize;
							new Float:modelScale = GetActualModelScale(DC_PROJECTILE_MODEL_RADIUS, DR_Radius[gameIdx][rocketIdx]);
							SetEntPropFloat(rocket, Prop_Send, "m_flModelScale", modelScale);
						}
					}
				}
			}
		}

		// disable any bombs. subplugins are expected to refresh this on the managed game frame.
		DG_BeamBombActive[gameIdx] = false;
		DG_RadiusBombActive[gameIdx] = false;
		DG_RectangleBombActive[gameIdx] = false;
	}
	
	if (curTime >= DR_ReorientAt)
		DR_ReorientAt = curTime + DR_REORIENT_INTERVAL;
}

/**
 * Danmaku Spawner -- A subset of rocket
 */
public DS_SpawnSpawnerAt(gameIdx, bool:isHero, Float:spawnPos[3], Float:angles[3], Float:speed, modelIdx, movePattern, Float:moveParam1, Float:moveParam2, spawnPattern, Float:spawnInterval, Float:spawnParam1, Float:lifetimeOverride, rocketFlags)
{
	// assumptions for spawners, mainly directed at reducing the number of parameters:
	// - radius is always 1.0. subplugins can override this.
	// - Color is always 0xffffff. subplugins can also override this.
	// - Spawners do not do damage themselves.
	// - patternidx, param1, and param2 are all usurped by the DS version. the rocket settings are static.
	
	// first, find a free spawner idx to use
	new spawnerIdx = -1;
	new bool:processedOriginal = false;
	DS_LastToSpawn[gameIdx]++;
	if (DS_LastToSpawn[gameIdx] >= DS_MAX_SPAWNERS)
		DS_LastToSpawn[gameIdx] = 0;
	for (new i = DS_LastToSpawn[gameIdx]; !(DS_LastToSpawn[gameIdx] == i && processedOriginal); i++)
	{
		if (i >= DS_MAX_SPAWNERS)
		{
			i = 0;
			if (DS_LastToSpawn[gameIdx] == 0)
				break;
		}
	
		if (DS_EntRef[gameIdx][i] == INVALID_ENTREF)
		{
			spawnerIdx = i;
			break;
		}
		
		if (DS_LastToSpawn[gameIdx] == i)
			processedOriginal = true;
	}
	if (spawnerIdx == -1)
	{
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] WARNING: Max spawners reached in game %d. Will not spawn spawner.", gameIdx);
		return -1;
	}
	
	// attempt to spawn a spawner, which is actually a rocket
	new rocketPattern = movePattern == DS_MOVE_CHAOTIC ? DR_PATTERN_CHAOTIC_PROTECTED : DR_PATTERN_SUBPLUGIN_DEFINED;
	new Float:rocketParam1 = movePattern == DS_MOVE_CHAOTIC ? moveParam1 : 0.0;
	new spawner = DR_SpawnRocketAt(gameIdx, isHero, spawnPos, angles, DC_PROJECTILE_MODEL_RADIUS, speed, 0xffffff, 0, rocketPattern, rocketParam1, 0.0, lifetimeOverride, rocketFlags | DR_FLAG_NO_COLLIDE | DR_FLAG_SPAWNER);
	if (spawner == -1)
	{
		PrintToServer("[danmaku_fortress] Note that it was actually a spawner that failed to spawn.");
		return -1;
	}
	
	// model reskin
	if (modelIdx != -1 && GetEntProp(spawner, Prop_Send, "m_nModelIndex") != modelIdx)
		SetEntProp(spawner, Prop_Send, "m_nModelIndex", modelIdx);

	// if successful, then there's really nothing left to do. set params now.
	DS_LastToSpawn[gameIdx] = spawnerIdx;
	DS_EntRef[gameIdx][spawnerIdx] = EntIndexToEntRef(spawner);
	DS_IsHero[gameIdx][spawnerIdx] = isHero;
	DS_RocketIdx[gameIdx][spawnerIdx] = DR_LastToSpawn[gameIdx]; // most useful DR variable ever.
	DS_MovePattern[gameIdx][spawnerIdx] = movePattern;
	DS_MoveParam1[gameIdx][spawnerIdx] = moveParam1;
	DS_MoveParam2[gameIdx][spawnerIdx] = moveParam2;
	DS_NextSpawnAt[gameIdx][spawnerIdx] = DC_SynchronizedTime + spawnInterval;
	DS_SpawnPattern[gameIdx][spawnerIdx] = spawnPattern;
	DS_SpawnInterval[gameIdx][spawnerIdx] = spawnInterval;
	DS_SpawnParam1[gameIdx][spawnerIdx] = spawnParam1;
	DS_SpawnTime[gameIdx][spawnerIdx] = DC_SynchronizedTime;
	
	return spawner;
}

public DS_SetSpawnerProjectileParams(gameIdx, Float:childRadius, childColor, Float:childSpeed, childDamage)
{
	new spawnerIdx = DS_LastToSpawn[gameIdx];
	DS_ChildRadius[gameIdx][spawnerIdx] = childRadius;
	DS_ChildColor[gameIdx][spawnerIdx] = childColor;
	DS_ChildSpeed[gameIdx][spawnerIdx] = childSpeed;
	DS_ChildDamage[gameIdx][spawnerIdx] = childDamage;
}

public DS_OnSpawnerDestroyed(gameIdx, rocketIdx)
{
	for (new spawnerIdx = 0; spawnerIdx < DS_MAX_SPAWNERS; spawnerIdx++)
	{
		if (DS_RocketIdx[gameIdx][spawnerIdx] == rocketIdx)
		{
			if (DS_IsHero[gameIdx][spawnerIdx])
			{
				for (new abilityIdx = 0; abilityIdx < DG_HeroAbilityCount[gameIdx]; abilityIdx++)
					if (DG_HeroFilenameIsUnique[gameIdx][abilityIdx])
						SubpluginSpawnerDestroyed(DG_HeroAbilityFilenames[gameIdx][abilityIdx], gameIdx, DR_EntRef[gameIdx][rocketIdx]);
			}
			else
			{
				for (new abilityIdx = 0; abilityIdx < DG_BossAbilityCount[gameIdx]; abilityIdx++)
					if (DG_BossFilenameIsUnique[gameIdx][abilityIdx])
						SubpluginSpawnerDestroyed(DG_BossAbilityFilenames[gameIdx][abilityIdx], gameIdx, DR_EntRef[gameIdx][rocketIdx]);
			}
			DS_EntRef[gameIdx][spawnerIdx] = INVALID_ENTREF;
			break;
		}
	}
}

public DS_Tick(Float:curTime)
{
	for (new gameIdx = 0; gameIdx < DG_MaxGames; gameIdx++)
	{
		// ensure this game is actually active and registered hits are valid
		if (!DG_Active[gameIdx] || DG_CountdownHUD[gameIdx] > 0)
			continue;
	
		for (new spawnerIdx = 0; spawnerIdx < DS_MAX_SPAWNERS; spawnerIdx++)
		{
			if (DS_EntRef[gameIdx][spawnerIdx] == INVALID_ENTREF)
				continue;
			new spawner = EntRefToEntIndex(DS_EntRef[gameIdx][spawnerIdx]);
			if (!IsValidEntity(spawner))
			{
				DS_EntRef[gameIdx][spawnerIdx] = INVALID_ENTREF;
				continue;
			}
			
			// tasks concerning the spawner's lifecycle are already handled in DR
			// all we do here is spawn rockets in an interval. lets handle spawn patterns, which DO NOT operate on a shared timer;
			static Float:spawnerPos[3];
			GetEntPropVector(spawner, Prop_Send, "m_vecOrigin", spawnerPos);
			static Float:spawnerAngle[3];
			GetEntPropVector(spawner, Prop_Data, "m_angRotation", spawnerAngle);
			spawnerAngle[0] = 0.0;
			static Float:tmpAngle[3];
			if (curTime >= DS_NextSpawnAt[gameIdx][spawnerIdx])
			{
				new patternIdx = DS_SpawnPattern[gameIdx][spawnerIdx];
				CopyVector(tmpAngle, spawnerAngle);
				DS_NextSpawnAt[gameIdx][spawnerIdx] = curTime + DS_SpawnInterval[gameIdx][spawnerIdx];
				switch (patternIdx)
				{
					case DS_SPAWN_STRAIGHT, DS_SPAWN_RADIAL:
					{
						new numToSpawn = (patternIdx == DS_SPAWN_RADIAL ? RoundFloat(DS_SpawnParam1[gameIdx][spawnerIdx]) : 1);
						for (new i = 0; i < numToSpawn; i++)
						{
							static Float:adjustedSpawnPos[3];
							CopyVector(adjustedSpawnPos, spawnerPos);
							adjustedSpawnPos[0] += GetRandomFloat(-1.0, 1.0);
							adjustedSpawnPos[1] += GetRandomFloat(-1.0, 1.0);
							adjustedSpawnPos[2] += GetRandomFloat(-1.0, 1.0);
							DR_SpawnRocketAt(gameIdx, DS_IsHero[gameIdx][spawnerIdx], adjustedSpawnPos, tmpAngle, DS_ChildRadius[gameIdx][spawnerIdx],
								DS_ChildSpeed[gameIdx][spawnerIdx], DS_ChildColor[gameIdx][spawnerIdx], DS_ChildDamage[gameIdx][spawnerIdx],
								DR_PATTERN_STRAIGHT, 0.0, 0.0, 0.0, 0);
							tmpAngle[1] = fixAngle(tmpAngle[1] + (360.0 / float(numToSpawn)));
						}
					}
					case DS_SPAWN_TARGET, DS_SPAWN_RADIAL_TARGET, DS_SPAWN_HOMING:
					{
						new numToSpawn = (patternIdx == DS_SPAWN_RADIAL_TARGET ? RoundFloat(DS_SpawnParam1[gameIdx][spawnerIdx]) : 1);
						for (new i = 0; i < numToSpawn; i++)
						{
							if (i == 0)
							{
								// the first one determines the spawn angle , as it must target the player
								static Float:dst[3];
								if (DS_IsHero[gameIdx][spawnerIdx])
								{
									if (IsLivingPlayer(DG_BossClient[gameIdx]))
										GetEntPropVector(DG_BossClient[gameIdx], Prop_Send, "m_vecOrigin", dst);
								}
								else
									DR_GetHeroHitPosition(gameIdx, dst);
								GetVectorAnglesTwoPoints(spawnerPos, dst, tmpAngle);
							}
							
							static Float:adjustedSpawnPos[3];
							CopyVector(adjustedSpawnPos, spawnerPos);
							adjustedSpawnPos[0] += GetRandomFloat(-1.0, 1.0);
							adjustedSpawnPos[1] += GetRandomFloat(-1.0, 1.0);
							adjustedSpawnPos[2] += GetRandomFloat(-1.0, 1.0);
							new rocketPattern = (patternIdx == DS_SPAWN_HOMING) ? DR_PATTERN_HOMING : DR_PATTERN_STRAIGHT;
							DR_SpawnRocketAt(gameIdx, DS_IsHero[gameIdx][spawnerIdx], adjustedSpawnPos, tmpAngle, DS_ChildRadius[gameIdx][spawnerIdx],
								DS_ChildSpeed[gameIdx][spawnerIdx], DS_ChildColor[gameIdx][spawnerIdx], DS_ChildDamage[gameIdx][spawnerIdx],
								rocketPattern, DS_SpawnParam1[gameIdx][spawnerIdx], 0.0, 0.0, 0);
							tmpAngle[1] = fixAngle(tmpAngle[1] + (360.0 / float(numToSpawn)));
						}
					}
				}
			}
			
			// move patterns
			if (curTime >= DS_ReorientAt)
			{
				static Float:velocity[3];
				new patternIdx = DS_MovePattern[gameIdx][spawnerIdx];
				switch (patternIdx)
				{
					case DS_MOVE_VERTICAL_CIRCLE:
					{
						new Float:rotationInterval = (DS_MoveParam1[gameIdx][spawnerIdx] <= 0.0) ? 1.0 : DS_MoveParam1[gameIdx][spawnerIdx];
						new Float:pitch = fixAngle((FloatModulus(curTime - DS_SpawnTime[gameIdx][spawnerIdx], rotationInterval) / rotationInterval) * 360.0);
						tmpAngle[0] = pitch;
						tmpAngle[1] = fixAngle(spawnerAngle[1] - 90.0); // spins perpendicular to its firing direction
						GetAngleVectors(tmpAngle, velocity, NULL_VECTOR, NULL_VECTOR);
						new Float:speed = DR_Speed[gameIdx][DS_RocketIdx[gameIdx][spawnerIdx]];
						ScaleVector(velocity, speed);
						TeleportEntity(spawner, NULL_VECTOR, NULL_VECTOR, velocity);
					}
				}
			}
		}
	}
	
	if (curTime >= DS_ReorientAt)
		DS_ReorientAt = curTime + DR_REORIENT_INTERVAL; // same reorient interval as rockets because spawners ARE rockets
}
/*
#define DS_MAX_SPAWNERS 10
new Float:DS_ReorientAt = 0.0;
new DS_EntRef[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new bool:DS_IsHero[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_RocketIdx[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_MovePattern[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_MoveParam1[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_MoveParam2[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_NextSpawnAt[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_SpawnPattern[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnInterval[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnParam1[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_SpawnTime[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_ChildRadius[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_ChildColor[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new Float:DS_ChildSpeed[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_ChildDamage[DG_MAX_GAMES][DS_MAX_SPAWNERS];
new DS_LastToSpawn[DG_MAX_GAMES]; // usable to set special params to last spawner, plus speeds up searches for next available
*/

/**
 * Music List
 */
public ML_SongIndexToArrayIndex(songIdx)
{
	for (new i = 0; i < ML_NumSongs; i++)
	{
		if (ML_SongIdx[i] == songIdx)
			return i;
	}
	
	PrintToServer("[danmaku_fortress] ERROR: Song at index %d not found. It may be invalid in your config file.", songIdx);
	return -1;
}

public ML_InitSpecial(const String:format[], String:soundList[ML_MAX_SPECIALS][MAX_SOUND_FILE_LENGTH], &count)
{
	count = 0;
	for (new i = 0; i < ML_MAX_SPECIALS; i++)
	{
		new specialIdx = i + 1;
		static String:specialKey[MAX_KEY_NAME_LENGTH];
		Format(specialKey, MAX_KEY_NAME_LENGTH, format, specialIdx);

		// bring in the special sound, fail if its settings are invalid
		soundList[count][0] = 0;
		KV_ReadString(ML_FILENAME, NULL_STRUCT, specialKey, soundList[count], MAX_SOUND_FILE_LENGTH);
		if (strlen(soundList[count]) <= 3)
			continue;
		PrecacheSound(soundList[count]);
		AddSoundToDownloadsTable(soundList[count]);
			
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] Found special sound at index %d, sound=%s", specialIdx, soundList[count]);
		count++;
	}
}

/**
 * Downloads Table
 */
public AddSoundToDownloadsTable(String:soundFileBase[MAX_SOUND_FILE_LENGTH])
{
	// yes, this corrupts the original. no, I don't care.
	ReplaceString(soundFileBase, MAX_SOUND_FILE_LENGTH, "\\", "/");
	static String:soundFile[MAX_SOUND_FILE_LENGTH + 6];
	Format(soundFile, sizeof(soundFile), "sound/%s", soundFileBase);
	AddFileToDownloadsTable(soundFile);
		
	// report it
	if (PRINT_DEBUG_INFO)
		PrintToServer("[danmaku_fortress] Adding %s to downloads table.", soundFile);
}

public AddModelToDownloadsTable(String:modelFileBase[MAX_MODEL_FILE_LENGTH])
{
	// yes, this corrupts the original. no, I don't care.
	ReplaceString(modelFileBase, MAX_MODEL_FILE_LENGTH, "\\", "/");
	static String:individualModelFile[MAX_MODEL_FILE_LENGTH + 5];
	strcopy(individualModelFile, sizeof(individualModelFile), modelFileBase);
	AddFileToDownloadsTable(individualModelFile);
	ReplaceString(individualModelFile, sizeof(individualModelFile), ".mdl", ".vvd");
	AddFileToDownloadsTable(individualModelFile);
	ReplaceString(individualModelFile, sizeof(individualModelFile), ".vvd", ".sw.vtx");
	AddFileToDownloadsTable(individualModelFile);
	ReplaceString(individualModelFile, sizeof(individualModelFile), ".sw.vtx", ".dx80.vtx");
	AddFileToDownloadsTable(individualModelFile);
	ReplaceString(individualModelFile, sizeof(individualModelFile), ".dx80.vtx", ".dx90.vtx");
	AddFileToDownloadsTable(individualModelFile);
	ReplaceString(individualModelFile, sizeof(individualModelFile), ".dx80.vtx", ".phy");
	
	// not all models have a .phy file
	new bool:phyExists = FileExists(individualModelFile, true);
	if (phyExists)
		AddFileToDownloadsTable(individualModelFile);
		
	// report it
	if (PRINT_DEBUG_INFO)
		PrintToServer("[danmaku_fortress] Adding %s and related files to downloads table. phyExists=%d", modelFileBase, phyExists);
}

public AddDirectoryToDownloadsTable(String:directory[PLATFORM_MAX_PATH])
{
	if (directory[0] == 0 || !DirExists(directory, true))
	{
		PrintToServer("[danmaku_fortress] ERROR: Directory not found, cannot add to downloads table: %s", directory);
		return;
	}
	ReplaceString(directory, PLATFORM_MAX_PATH, "\\", "/");
	
	static String:filename[PLATFORM_MAX_PATH];
	static String:usefulFilename[PLATFORM_MAX_PATH]; // argh
	new Handle:dirHandle = OpenDirectory(directory, true);
	if (dirHandle != INVALID_HANDLE)
	{
		if (PRINT_DEBUG_INFO)
			PrintToServer("[danmaku_fortress] Will iterate through directory for downloads: %s", directory);
		
		new FileType:fileType;
		while (ReadDirEntry(dirHandle, filename, PLATFORM_MAX_PATH, fileType))
		{
			new length = strlen(filename);
			if (filename[0] == '.' && (filename[1] == 0 || (filename[1] == '.' && filename[2] == 0)))
				continue; // skip . and ..
			else if (fileType != FileType_File)
				continue;
			else if (filename[0] == '.')
				continue; // skip linux hidden files
			else if (length <= 4 || filename[length - 4] != '.')
				continue; // all usable files have a 3 letter extension. this will also catch windows' Thumbs.db
				
			if (StrEndsWith(directory, "/"))
				Format(usefulFilename, PLATFORM_MAX_PATH, "%s%s", directory, filename);
			else
				Format(usefulFilename, PLATFORM_MAX_PATH, "%s/%s", directory, filename);
				
			AddFileToDownloadsTable(usefulFilename);
			if (PRINT_DEBUG_INFO)
				PrintToServer("[danmaku_fortress] Adding iterated file to download list: %s", usefulFilename);
		}
	}
		
}

/**
 * Anything Using KVs
 *
 * It's already dawned on me that this design will be very inefficient on map start. Luckily it's only map start that constant
 * switching between individual character configs and characters.cfg will occur, so I'm going to let it slide.
 * (unless it becomes a serious problem)
 */
new Handle:kvHandle = INVALID_HANDLE;
new String:kvConfig[MAX_PLUGIN_NAME_LENGTH] = "";
public KV_Cleanup()
{
	if (kvHandle != INVALID_HANDLE)
	{
		CloseHandle(kvHandle);
		kvHandle = INVALID_HANDLE;
		kvConfig[0] = 0;
	}
}

public KV_VerifyConfig(const String:configName[])
{
	if (kvHandle != INVALID_HANDLE && strcmp(kvConfig, configName) != 0)
		KV_Cleanup();
		
	if (kvHandle == INVALID_HANDLE)
	{
		static String:filePath[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, filePath, PLATFORM_MAX_PATH, "configs/danmaku_fortress/%s.cfg", configName);
		if (!FileExists(filePath))
		{
			PrintToServer("[danmaku_fortress] ERROR: Config file is missing: %s", filePath);
			if (strcmp(configName, CL_FILENAME) == 0)
				PrintToServer("[danmaku_fortress] You need a %s.cfg file! Get it from the installer zip.", CL_FILENAME);
			else
				PrintToServer("[danmaku_fortress] Check your %s.cfg file and ensure the character's FILE spelling is correct. Also, don't include .cfg -- this is done automatically.", CL_FILENAME);
			return;
		}

		// load kv file and start with the basic settings
		kvHandle = CreateKeyValues("");
		if (kvHandle == INVALID_HANDLE)
			return;
		FileToKeyValues(kvHandle, filePath);
		strcopy(kvConfig, MAX_PLUGIN_NAME_LENGTH, configName);
	}
}

public bool:KV_HasStruct(const String:configName[], const String:structName[])
{
	KV_VerifyConfig(configName);
	if (kvHandle == INVALID_HANDLE)
		return false;

	KvRewind(kvHandle);
	return KvJumpToKey(kvHandle, structName);
}

public KV_ReadInt(const String:configName[MAX_CONFIG_NAME_LENGTH], const String:structName[MAX_KEY_NAME_LENGTH], const String:keyName[MAX_KEY_NAME_LENGTH], defaultValue)
{
	KV_VerifyConfig(configName);
	if (kvHandle == INVALID_HANDLE)
		return defaultValue;

	KvRewind(kvHandle);
	if (!IsEmptyString(structName) && !KvJumpToKey(kvHandle, structName))
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[danmaku_fortress] %s doesn't exist or is malformed.", structName);
		return defaultValue;
	}
	static String:hexOrDecString[12];
	KvGetString(kvHandle, keyName, hexOrDecString, 12);
	if (IsEmptyString(hexOrDecString))
		return defaultValue;
	
	if (StrContains(hexOrDecString, "0x") == 0)
	{
		new result = 0;
		for (new i = 2; i < 10 && hexOrDecString[i] != 0; i++)
		{
			result = result<<4;
				
			if (hexOrDecString[i] >= '0' && hexOrDecString[i] <= '9')
				result += hexOrDecString[i] - '0';
			else if (hexOrDecString[i] >= 'a' && hexOrDecString[i] <= 'f')
				result += hexOrDecString[i] - 'a' + 10;
			else if (hexOrDecString[i] >= 'A' && hexOrDecString[i] <= 'F')
				result += hexOrDecString[i] - 'A' + 10;
		}
		
		return result;
	}
	else
		return StringToInt(hexOrDecString);
}

public Float:KV_ReadFloat(const String:configName[MAX_CONFIG_NAME_LENGTH], const String:structName[MAX_KEY_NAME_LENGTH], const String:keyName[MAX_KEY_NAME_LENGTH], Float:defaultValue)
{
	KV_VerifyConfig(configName);
	if (kvHandle == INVALID_HANDLE)
		return defaultValue;

	KvRewind(kvHandle);
	if (!IsEmptyString(structName) && !KvJumpToKey(kvHandle, structName))
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[danmaku_fortress] %s doesn't exist or is malformed.", structName);
		return defaultValue;
	}
	return KvGetFloat(kvHandle, keyName);
}

public bool:KV_ReadString(const String:configName[MAX_CONFIG_NAME_LENGTH], const String:structName[MAX_KEY_NAME_LENGTH], const String:keyName[MAX_KEY_NAME_LENGTH], String:str[], length)
{
	KV_VerifyConfig(configName);
	if (kvHandle == INVALID_HANDLE)
	{
		str[0] = 0;
		return false;
	}

	KvRewind(kvHandle);
	if (!IsEmptyString(structName) && !KvJumpToKey(kvHandle, structName))
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[danmaku_fortress] %s doesn't exist or is malformed.", structName);
		str[0] = 0;
		return false;
	}
	KvGetString(kvHandle, keyName, str, length);
	ReplaceString(str, length, "\\n", "\n");
	return str[0] != 0;
}

public bool:KV_ReadRectangleExternal(const String:configName[MAX_CONFIG_NAME_LENGTH], const String:structName[MAX_KEY_NAME_LENGTH], const String:keyName[MAX_KEY_NAME_LENGTH], Float:min[3], Float:max[3])
{
	static Float:rect[2][3];
	CopyVector(rect[0], min);
	CopyVector(rect[1], max);
	new bool:ret = KV_ReadRectangle(configName, structName, keyName, rect);
	CopyVector(min, rect[0]);
	CopyVector(max, rect[1]);
	return ret;
}

public bool:KV_ReadRectangle(const String:configName[MAX_CONFIG_NAME_LENGTH], const String:structName[MAX_KEY_NAME_LENGTH], const String:keyName[MAX_KEY_NAME_LENGTH], Float:rect[2][3])
{
	KV_VerifyConfig(configName);
	if (kvHandle == INVALID_HANDLE)
		return false;

	static String:hullStr[MAX_HULL_STRING_LENGTH];
	KvRewind(kvHandle);
	if (!IsEmptyString(structName) && !KvJumpToKey(kvHandle, structName))
	{
		if (PRINT_DEBUG_SPAM)
			PrintToServer("[danmaku_fortress] %s doesn't exist or is malformed.", structName);
		return false;
	}
	KvGetString(kvHandle, keyName, hullStr, MAX_HULL_STRING_LENGTH);
	ParseHull(hullStr, rect);
	
	return true;
}

/**
 * Subplugin Method Invocations
 */
new methodInvocations = 0;
stock LogMethodInvocation()
{
	methodInvocations++;
	if (methodInvocations % 25 == 0)
		PrintToServer("%d method invocations.", methodInvocations);
}
 
stock GetMethod(const String:pluginName[], const String:methodName[], &Handle:retPlugin, &Function:retFunc, bool:printFailure = true)
{
	static String:fullPluginName[MAX_PLUGIN_NAME_LENGTH + 4];
	Format(fullPluginName, sizeof(fullPluginName), "%s.smx", pluginName);

	static String:buffer[256];
	new Handle:iter = GetPluginIterator();
	new Handle:plugin = INVALID_HANDLE;
	while (MorePlugins(iter))
	{
		plugin = ReadPlugin(iter);
		
		GetPluginFilename(plugin, buffer, sizeof(buffer));
		if (StrContains(buffer, fullPluginName, false) != -1)
			break;
		else
			plugin = INVALID_HANDLE;
	}
	
	CloseHandle(iter);
	if (plugin != INVALID_HANDLE)
	{
		new Function:func = GetFunctionByName(plugin, methodName);
		if (func != INVALID_FUNCTION)
		{
			retPlugin = plugin;
			retFunc = func;
		}
		else if (printFailure)
			PrintToServer("[danmaku_fortress] ERROR: Could not find %s:%s()", fullPluginName, methodName);
	}
	else if (printFailure)
		PrintToServer("[danmaku_fortress] ERROR: Could not find %s. %s() failed.", fullPluginName, methodName);
}
 
InitAbility(const String:pluginName[], gameIdx, owner, victim, String:abilityName[MAX_ABILITY_NAME_LENGTH], String:characterName[MAX_CONFIG_NAME_LENGTH], abilityIdx)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_InitAbility", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(owner);
	Call_PushCell(victim);
	Call_PushStringEx(abilityName, MAX_ABILITY_NAME_LENGTH, 2, 1);
	Call_PushStringEx(characterName, MAX_CONFIG_NAME_LENGTH, 2, 1);
	Call_PushCell(abilityIdx);
	Call_Finish();
	CloseHandle(plugin);
}

ManagedGameFrame(const String:pluginName[], gameIdx, bool:hero, Float:curTime)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_ManagedGameFrame", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(hero);
	Call_PushFloat(curTime);
	Call_Finish();
	CloseHandle(plugin);
}

OnAbilityUsed(const String:pluginName[], gameIdx, String:abilityName[MAX_ABILITY_NAME_LENGTH], Float:curTime, Float:powerLevel, userFlags)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_OnAbilityUsed", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushStringEx(abilityName, MAX_ABILITY_NAME_LENGTH, 2, 1);
	Call_PushFloat(curTime);
	Call_PushFloat(powerLevel);
	Call_PushCell(userFlags);
	Call_Finish();
	CloseHandle(plugin);
}

GameCleanup(const String:pluginName[], gameIdx)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_GameCleanup", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_Finish();
	CloseHandle(plugin);
}

SubpluginRocketDestroyed(const String:pluginName[], gameIdx, rocketEntRef)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_OnRocketDestroyed", plugin, func, false); // false = don't print if missing from subplugin
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(rocketEntRef);
	Call_Finish();
	CloseHandle(plugin);
}

SubpluginSpawnerDestroyed(const String:pluginName[], gameIdx, rocketEntRef)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetMethod(pluginName, "DF_OnSpawnerDestroyed", plugin, func, false); // false = don't print if missing from subplugin
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;
		
	Call_StartFunction(plugin, func);
	Call_PushCell(gameIdx);
	Call_PushCell(rocketEntRef);
	Call_Finish();
	CloseHandle(plugin);
}

/**
 * OnTakeDamage, OnGameFrame, OnPlayerRunCmd
 */
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (!DC_RoundBegan)
		return Plugin_Continue;

	// no world interference (or fluke events from invalid/dead entities)
	if (!IsLivingPlayer(victim) || !IsLivingPlayer(attacker))
		return Plugin_Stop;

	// spectators tell no tales...also they don't interfere with the action
	if (DFP_Role[victim] == DFP_ROLE_NONE || DFP_Role[attacker] == DFP_ROLE_NONE)
		return Plugin_Stop;
		
	// I don't even...
	if (DFP_Role[victim] == DFP_ROLE_HERO && DFP_Role[attacker] == DFP_ROLE_HERO)
		return Plugin_Stop;
	else if (DFP_Role[victim] == DFP_ROLE_BOSS && DFP_Role[attacker] == DFP_ROLE_BOSS)
		return Plugin_Stop;
		
	// ensure both players are in the same game
	if (DFP_GameNum[victim] != DFP_GameNum[attacker])
		return Plugin_Stop;
	
	// it's all smoke and mirrors. no Source attacks ever take place in Danmaku Fortress.
	return Plugin_Stop;
}
 
public OnGameFrame()
{
	if (!DC_RoundBegan)
		return;

	DC_SynchronizedTime = GetEngineTime();
	DFP_Tick(DC_SynchronizedTime); // tick players and their movement first
	DB_Tick(DC_SynchronizedTime); // tick beams before rockets, since some beams can destroy rockets
	DR_Tick(DC_SynchronizedTime); // tick rockets before game, since rockets (and beams) damage the players
	DS_Tick(DC_SynchronizedTime); // spawners after rockets, since spawners _are_ rockets, but also create them. don't want two teleports of a rocket on one frame.
	DG_Tick(DC_SynchronizedTime); // game is ticked after all potential damage sources
	
	// and finally, DFL, clean up any open KV handle
	KV_Cleanup();
}

public Action:OnPlayerRunCmd(clientIdx, &buttons, &impulse, Float:vel[3], Float:unusedangles[3], &weapon)
{
	if (!DC_RoundBegan)
		return Plugin_Continue;

	// pretty much requires a living player
	if (!IsLivingPlayer(clientIdx))
		return Plugin_Continue;
	else if (GetClientTeam(clientIdx) != HeroTeam && GetClientTeam(clientIdx) != BossTeam)
		return Plugin_Continue;

	// bot logic, must be done before all
	BL_AdjustBotButtons(clientIdx, buttons);

	// movement input and combat input handled separately.
	new Float:curTime = GetEngineTime();
	DFP_HandleMovementInput(clientIdx, buttons, curTime);
	DFP_HandleCombatInput(clientIdx, buttons, curTime);
	
	// remove our movement buttons
	buttons &= ~(IN_FORWARD | IN_BACK | IN_MOVELEFT | IN_MOVERIGHT | IN_DUCK | IN_JUMP);
	return Plugin_Changed;
}

public OnEntityCreated(entity, const String:classname[])
{
	if (!DC_IsEnabled)
		return;
	
	// the only timers I'll ever use on DF are here...
	// and it's only because managing an unknown number of throwaway items to dispose of is best done with timers
	// also I don't want to iterate with FindEntityByClassname() because there are 1750 rockets to iterate through first
	if (StrEqual(classname, "tf_dropped_weapon"))
		CreateTimer(0.1, RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	else if (StrEqual(classname, "tf_wearable"))
		CreateTimer(0.1, RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	else if (StrEqual(classname, "tf_wearable_demoshield"))
		CreateTimer(0.1, RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	else if (StrEqual(classname, "tf_ammo_pack"))
		CreateTimer(0.1, RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	else if (StrEqual(classname, "tf_ragdoll"))
		CreateTimer(0.1, RemoveEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	//else
	//	CPrintToChatAll("on entity created: %s", classname);
}

/**
 * Stocks that don't belong in the inc
 */
stock ParseHull(String:hullStr[MAX_HULL_STRING_LENGTH], Float:hull[2][3])
{
	new String:hullStrs[2][MAX_HULL_STRING_LENGTH / 2];
	new String:vectorStrs[3][MAX_HULL_STRING_LENGTH / 6];
	ExplodeString(hullStr, ";", hullStrs, 2, MAX_HULL_STRING_LENGTH / 2);
	for (new i = 0; i < 2; i++)
	{
		ExplodeString(hullStrs[i], ",", vectorStrs, 3, MAX_HULL_STRING_LENGTH / 6);
		hull[i][0] = StringToFloat(vectorStrs[0]);
		hull[i][1] = StringToFloat(vectorStrs[1]);
		hull[i][2] = StringToFloat(vectorStrs[2]);
	}
}
