////////////////////////////////////////////////////////////////////////////////
//
//  Z O M B I E - F O R T R E S S - [TF2]
//
//  ZF Utility Base File
//
//  Includes stock routines for team, class, weapons, attributes, ammo,
//  spawning, and damage logic.
//
////////////////////////////////////////////////////////////////////////////////

// TODO
// m_flMaxSpeed appears to be reset/recalculated when:
// + after switching weapons and before next prethinkpost
// + (soldier holding equalizer) every 17-19 frames

#if defined _ZF_UTIL_BASE_INC
  #endinput
#endif
#define _ZF_UTIL_BASE_INC

//
// ZF Damage Constants
//
#define TF2_DMGTYPE_BLEED         0x4
#define TF2_DMGTYPE_FALL          0x20
#define TF2_DMGTYPE_EXPLOSIVE     0x40
#define TF2_DMGTYPE_BLUDGEON      0x80
#define TF2_DMGTYPE_FIRE          0x800
#define TF2_DMGTYPE_CRIT          0x100000

#define ZF_DMGTYPE_POISON         0x8000_0000 // Should be unused

#define ZF_DAMAGERADIUS_NAME      "zfdmgrad"

//
// ZF Weapon Constants / Objects
// Bits 31-16 : Flags
// Bits 15-08 : Max clip ammo
// Bits 07-00 : Max reserve ammo
//
#define M_MAXRESAMMO    0x000000FF
#define S_MAXRESAMMO    0
#define M_MAXCLIPAMMO   0x0000FF00
#define S_MAXCLIPAMMO   8
#define F_ISAUTO        0x00010000
#define F_ISBULLET      0x00020000
#define F_NOSTRIP       0x00040000

#define MAX_ZF_WEAPONS 512
static ZF_WEAPON_DATA[MAX_ZF_WEAPONS] = {0, ...};

// Scout
#define ZFWEAP_SCATTERGUN   13
#define ZFWEAP_FORCEANATURE 45
#define ZFWEAP_SHORTSTOP    220
#define ZFWEAP_SCOUTPISTOL  23
#define ZFWEAP_BONK         46
#define ZFWEAP_LUGERMORPH   160 // Scout, Engineer
#define ZFWEAP_CRITACOLA    163
#define ZFWEAP_MADMILK      222
#define ZFWEAP_BAT          0
#define ZFWEAP_SANDMAN      44
#define ZFWEAP_HOLYMACKAREL 221
#define ZFWEAP_CANDYCANE    317
#define ZFWEAP_BOSTONBASHER 325 
#define ZFWEAP_SUNONASTICK  349
#define ZFWEAP_FANOWAR      355
#define ZFWEAP_SCATTERGUN_UPGRADE 200
#define ZFWEAP_PISTOL_UPGRADE     209 // Scout, Engineer
#define ZFWEAP_BAT_UPGRADE        190

// Sniper
#define ZFWEAP_SNIPERRIFLE   14
#define ZFWEAP_HUNTSMAN      56
#define ZFWEAP_SYDNEYSLEEPER 230
#define ZFWEAP_SMG           16
#define ZFWEAP_RAZORBACK     57
#define ZFWEAP_JARATE        58
#define ZFWEAP_DANGERSHIELD  231
#define ZFWEAP_KUKRI         3
#define ZFWEAP_SHIV          171
#define ZFWEAP_BUSHWACKA     232
#define ZFWEAP_SNIPERRIFLE_UPGRADE 201
#define ZFWEAP_SMG_UPGRADE         203
#define ZFWEAP_KUKRI_UPGRADE       193

// Soldier  
#define ZFWEAP_ROCKETLAUNCHER  18
#define ZFWEAP_DIRECTHIT       127
#define ZFWEAP_BLACKBOX        228
#define ZFWEAP_ROCKETJUMPER    237
#define ZFWEAP_SOLDIERSHOTGUN  10
#define ZFWEAP_BUFFBANNER      129
#define ZFWEAP_GUNBOATS        133
#define ZFWEAP_BATTALIONBACKUP 226
#define ZFWEAP_CONCHEROR       354
#define ZFWEAP_SHOVEL          6
#define ZFWEAP_EQUALIZER       128
#define ZFWEAP_PAINTRAIN       154 // Soldier, Demoman
#define ZFWEAP_FRYINGPAN       264 // Soldier, Demoman
#define ZFWEAP_HALFZATOICHI    357 // Soldier, Demoman
#define ZFWEAP_ROCKETLAUNCHER_UPGRADE 205
#define ZFWEAP_SHOTGUN_UPGRADE        199 // Soldier, Pyro, Heavy, Engineer
#define ZFWEAP_SHOVEL_UPGRADE         196

// Demoman
#define ZFWEAP_GRENADELAUNCHER    19
#define ZFWEAP_LOCHNLOAD          308
#define ZFWEAP_STICKYLAUNCHER     20
#define ZFWEAP_SCOTTISHRESISTANCE 130
#define ZFWEAP_CHARGINTARGE       131
#define ZFWEAP_STICKYJUMPER       265
#define ZFWEAP_BOTTLE             1
#define ZFWEAP_EYELANDER          132
#define ZFWEAP_SKULLCUTTER        172
#define ZFWEAP_HHHHEADTAKER       266
#define ZFWEAP_ULLAPOOLCABER      307
#define ZFWEAP_CLAIDHEAMOHMOR     327
#define ZFWEAP_GRENADELAUNCHER_UPGRADE 206
#define ZFWEAP_STICKYLAUNCHER_UPGRADE  207
#define ZFWEAP_BOTTLE_UPGRADE          191

// Medic
#define ZFWEAP_SYRINGEGUN        17
#define ZFWEAP_BLUTSAUGER        36
#define ZFWEAP_CRUSADERSCROSSBOW 305
#define ZFWEAP_MEDIGUN           29
#define ZFWEAP_KRITZKRIEG        35
#define ZFWEAP_BONESAW           8
#define ZFWEAP_UBERSAW           37
#define ZFWEAP_VITASAW           173
#define ZFWEAP_AMPUTATOR         304
#define ZFWEAP_SYRINGEGUN_UPGRADE 204
#define ZFWEAP_MEDIGUN_UPGRADE    211
#define ZFWEAP_BONESAW_UPGRADE    198

// Heavy
#define ZFWEAP_SASHA          15
#define ZFWEAP_NATASCHA       41
#define ZFWEAP_IRONCURTAIN    298
#define ZFWEAP_BRASSBEAST     312
#define ZFWEAP_HEAVYSHOTGUN   11
#define ZFWEAP_SANDVICH       42
#define ZFWEAP_DALOKOHSBAR    159
#define ZFWEAP_BUFFALOSTEAK   311
#define ZFWEAP_FISTS          5
#define ZFWEAP_KGB            43
#define ZFWEAP_GRU            239
#define ZFWEAP_WARRIORSSPIRIT 310
#define ZFWEAP_FISTSOFSTEEL   331
#define ZFWEAP_SASHA_UPGRADE 202
#define ZFWEAP_FISTS_UPGRADE 195

// Pyro
#define ZFWEAP_FLAMETHROWER    21
#define ZFWEAP_BACKBURNER      40
#define ZFWEAP_DEGREASER       215
#define ZFWEAP_PYROSHOTGUN     12
#define ZFWEAP_FLAREGUN        39
#define ZFWEAP_FIREAXE         2
#define ZFWEAP_AXETINGUSIHER   38
#define ZFWEAP_HOMEWRECKER     153
#define ZFWEAP_POWERJACK       214
#define ZFWEAP_BACKSCRATCHER   326
#define ZFWEAP_VOLCANOFRAGMENT 348
#define ZFWEAP_FLAMETHROWER_UPGRADE 208
#define ZFWEAP_FIREAXE_UPGRADE      192

// Spy
#define ZFWEAP_REVOLVER       24
#define ZFWEAP_AMBASSADOR     61
#define ZFWEAP_BIGKILL        161
#define ZFWEAP_LETRANGER      224
#define ZFWEAP_KNIFE          4
#define ZFWEAP_ETERNALREWARD  225
#define ZFWEAP_CONNIVERSKUNAI 356
#define ZFWEAP_INVISWATCH     30
#define ZFWEAP_DEADRINGER     59
#define ZFWEAP_CLOAKANDDAGGER 60
#define ZFWEAP_TTGWATCH       297
#define ZFWEAP_REVOLVER_UPGRADE   210
#define ZFWEAP_KNIFE_UPGRADE      194
#define ZFWEAP_INVISWATCH_UPGRADE 212

// Engineer
#define ZFWEAP_ENGINEERSHOTGUN     9
#define ZFWEAP_FRONTIERJUSTICE     141
#define ZFWEAP_ENGINEERPISTOL      22
#define ZFWEAP_WRANGLER            140
#define ZFWEAP_WRENCH              7
#define ZFWEAP_GUNSLINGER          142
#define ZFWEAP_SOUTHERNHOSPITALITY 155
#define ZFWEAP_GOLDENWRENCH        169
#define ZFWEAP_JAG                 329
#define ZFWEAP_BUILDPDA            25
#define ZFWEAP_DESTROYPDA          26
#define ZFWEAP_WRENCH_UPGRADE      197
  
//
// Offsets
//
static oActiveWeapon;
static oCloakMeter;
static oMaxspeed;
static oResAmmo[3];

static oClipAmmo;
static oNextPriAttack;
static oNextSecAttack;

//
// ZF Class Objects
//
static const TFClassType:ZF_SURVIVORS[9] = {
  TFClass_Sniper, TFClass_Soldier, TFClass_DemoMan, 
  TFClass_Medic,  TFClass_Pyro,    TFClass_Engineer, TFClass_Scout,  TFClass_Heavy,   TFClass_Spy};
static const TFClassType:ZF_ZOMBIES[9] = {
  TFClass_Scout,  TFClass_Heavy,   TFClass_Spy,  TFClass_Sniper, TFClass_Soldier, TFClass_DemoMan, 
  TFClass_Medic,  TFClass_Pyro,    TFClass_Engineer};
static const ZF_VALIDSURVIVOR[10] = {1,1,1,1,1,1,1,1,1,1};
static const ZF_VALIDZOMBIE[10]   = {1,1,1,1,1,1,1,1,1,1};

//
// ZF Team / Round State
//
enum ZFRoundState
{
  RoundInit1,
  RoundInit2,
  RoundGrace,
  RoundActive,
  RoundPost
}
static ZFRoundState:zf_roundState = RoundInit1;
static zf_zomTeam = _:TFTeam_Blue;
static zf_surTeam = _:TFTeam_Red;

////////////////////////////////////////////////////////////
//
// Util Init
//
////////////////////////////////////////////////////////////
utilBaseInit()
{
  //
  // Initialize offsets.
  //
  oActiveWeapon = FindSendPropInfo("CTFPlayer", "m_hActiveWeapon");
  oCloakMeter   = FindSendPropInfo("CTFPlayer", "m_flCloakMeter");
  oMaxspeed     = FindSendPropInfo("CTFPlayer", "m_flMaxspeed");  
  oResAmmo[0]   = FindSendPropInfo("CTFPlayer", "m_iAmmo") + 4;
  oResAmmo[1]   = FindSendPropInfo("CTFPlayer", "m_iAmmo") + 8;
  oResAmmo[2]   = FindSendPropInfo("CTFPlayer", "m_iAmmo") + 12;

  oClipAmmo      = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
  oNextPriAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack");
  oNextSecAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack"); 

  //
  // Initialize weapon data.
  //
  // Scout
  ZF_WEAPON_DATA[ZFWEAP_SCATTERGUN]   = F_ISBULLET          | (6 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_FORCEANATURE] = F_ISBULLET          | (2 << 8) | (32 << 0);  
  ZF_WEAPON_DATA[ZFWEAP_SHORTSTOP]    = F_ISBULLET          | (4 << 8) | (36 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SCOUTPISTOL]  = F_ISAUTO|F_ISBULLET | (12 << 8) | (36 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BONK]         = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_LUGERMORPH]   = F_ISAUTO|F_ISBULLET | (12 << 8) | (36 << 0);
  ZF_WEAPON_DATA[ZFWEAP_CRITACOLA]    = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_MADMILK]      = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BAT]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SANDMAN]      = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_HOLYMACKAREL] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_CANDYCANE]    = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BOSTONBASHER] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SUNONASTICK]  = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_FANOWAR]      = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SCATTERGUN_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_SCATTERGUN];  
  ZF_WEAPON_DATA[ZFWEAP_PISTOL_UPGRADE]     = ZF_WEAPON_DATA[ZFWEAP_SCOUTPISTOL];
  ZF_WEAPON_DATA[ZFWEAP_BAT_UPGRADE]        = ZF_WEAPON_DATA[ZFWEAP_BAT];

  // Sniper
  ZF_WEAPON_DATA[ZFWEAP_SNIPERRIFLE]   = F_ISBULLET          | (0 << 8) | (25 << 0);
  ZF_WEAPON_DATA[ZFWEAP_HUNTSMAN]      =                       (1 << 8) | (12 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SYDNEYSLEEPER] = F_ISBULLET          | (0 << 8) | (25 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SMG]           = F_ISAUTO|F_ISBULLET | (25 << 8) | (75 << 0);
  ZF_WEAPON_DATA[ZFWEAP_RAZORBACK]     = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_JARATE]        = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_DANGERSHIELD]  = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_KUKRI]         = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SHIV]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BUSHWACKA]     = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SNIPERRIFLE_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_SNIPERRIFLE];
  ZF_WEAPON_DATA[ZFWEAP_SMG_UPGRADE]         = ZF_WEAPON_DATA[ZFWEAP_SMG]; 
  ZF_WEAPON_DATA[ZFWEAP_KUKRI_UPGRADE]       = ZF_WEAPON_DATA[ZFWEAP_KUKRI];
  
  // Soldier
  ZF_WEAPON_DATA[ZFWEAP_ROCKETLAUNCHER]  =              (4 << 8) | (20 << 0);
  ZF_WEAPON_DATA[ZFWEAP_DIRECTHIT]       =              (4 << 8) | (20 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BLACKBOX]        =              (3 << 8) | (20 << 0);
  ZF_WEAPON_DATA[ZFWEAP_ROCKETJUMPER]    =              (4 << 8) | (60 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SOLDIERSHOTGUN]  = F_ISBULLET | (6 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BUFFBANNER]      = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BATTALIONBACKUP] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_CONCHEROR]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SHOVEL]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_EQUALIZER]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_PAINTRAIN]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_FRYINGPAN]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_HALFZATOICHI]    = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_ROCKETLAUNCHER_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_ROCKETLAUNCHER];
  ZF_WEAPON_DATA[ZFWEAP_SHOTGUN_UPGRADE]        = ZF_WEAPON_DATA[ZFWEAP_SOLDIERSHOTGUN];  
  ZF_WEAPON_DATA[ZFWEAP_SHOVEL_UPGRADE]         = ZF_WEAPON_DATA[ZFWEAP_SHOVEL];
  
  // Demoman
  ZF_WEAPON_DATA[ZFWEAP_GRENADELAUNCHER]    =             (4 << 8) | (16 << 0);
  ZF_WEAPON_DATA[ZFWEAP_LOCHNLOAD]          =             (2 << 8) | (16 << 0);  
  ZF_WEAPON_DATA[ZFWEAP_STICKYLAUNCHER]     =             (8 << 8) | (24 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SCOTTISHRESISTANCE] =             (8 << 8) | (36 << 0);
  ZF_WEAPON_DATA[ZFWEAP_CHARGINTARGE]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_STICKYJUMPER]       =             (8 << 8) | (48 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BOTTLE]             = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_EYELANDER]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SKULLCUTTER]        = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_HHHHEADTAKER]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_ULLAPOOLCABER]      = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_CLAIDHEAMOHMOR]     = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_GRENADELAUNCHER_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_GRENADELAUNCHER];
  ZF_WEAPON_DATA[ZFWEAP_STICKYLAUNCHER_UPGRADE]  = ZF_WEAPON_DATA[ZFWEAP_STICKYLAUNCHER];
  ZF_WEAPON_DATA[ZFWEAP_BOTTLE_UPGRADE]          = ZF_WEAPON_DATA[ZFWEAP_BOTTLE];
  
  // Medic
  ZF_WEAPON_DATA[ZFWEAP_SYRINGEGUN]        = F_ISAUTO | (40 << 8) | (150 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BLUTSAUGER]        = F_ISAUTO | (40 << 8) | (150 << 0);
  ZF_WEAPON_DATA[ZFWEAP_CRUSADERSCROSSBOW] =            (1 << 8) | (38 << 0);
  ZF_WEAPON_DATA[ZFWEAP_MEDIGUN]           = 0;
  ZF_WEAPON_DATA[ZFWEAP_KRITZKRIEG]        = 0;
  ZF_WEAPON_DATA[ZFWEAP_BONESAW]           = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_UBERSAW]           = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_VITASAW]           = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_AMPUTATOR]         = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SYRINGEGUN_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_SYRINGEGUN];
  ZF_WEAPON_DATA[ZFWEAP_MEDIGUN_UPGRADE]    = ZF_WEAPON_DATA[ZFWEAP_MEDIGUN];
  ZF_WEAPON_DATA[ZFWEAP_BONESAW_UPGRADE]    = ZF_WEAPON_DATA[ZFWEAP_BONESAW];
  
  // Heavy
  ZF_WEAPON_DATA[ZFWEAP_SASHA]          = F_ISAUTO|F_ISBULLET | (0 << 8) | (200 << 0);
  ZF_WEAPON_DATA[ZFWEAP_NATASCHA]       = F_ISAUTO|F_ISBULLET | (0 << 8) | (200 << 0);
  ZF_WEAPON_DATA[ZFWEAP_IRONCURTAIN]    = F_ISAUTO|F_ISBULLET | (0 << 8) | (200 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BRASSBEAST]     = F_ISAUTO|F_ISBULLET | (0 << 8) | (200 << 0);
  ZF_WEAPON_DATA[ZFWEAP_HEAVYSHOTGUN]   = F_ISBULLET          | (6 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_SANDVICH]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_DALOKOHSBAR]    = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BUFFALOSTEAK]   = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_FISTS]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_KGB]            = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_GRU]            = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_WARRIORSSPIRIT] = F_NOSTRIP; // speed pen
  ZF_WEAPON_DATA[ZFWEAP_FISTSOFSTEEL]   = F_NOSTRIP; // speed pen
  ZF_WEAPON_DATA[ZFWEAP_SASHA_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_SASHA];
  ZF_WEAPON_DATA[ZFWEAP_FISTS_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_FISTS];
  
  // Pyro
  ZF_WEAPON_DATA[ZFWEAP_FLAMETHROWER]    = F_ISAUTO   | (0 << 8) | (125 << 0); // Normal limit 200
  ZF_WEAPON_DATA[ZFWEAP_BACKBURNER]      = F_ISAUTO   | (0 << 8) | (125 << 0); // Normal limit 200
  ZF_WEAPON_DATA[ZFWEAP_DEGREASER]       = F_ISAUTO   | (0 << 8) | (125 << 0); // Normal limit 200
  ZF_WEAPON_DATA[ZFWEAP_PYROSHOTGUN]     = F_ISBULLET | (6 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_FLAREGUN]        =              (0 << 8) | (16 << 0);
  ZF_WEAPON_DATA[ZFWEAP_FIREAXE]         = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_AXETINGUSIHER]   = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_HOMEWRECKER]     = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_POWERJACK]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BACKSCRATCHER]   = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_VOLCANOFRAGMENT] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_FLAMETHROWER_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_FLAMETHROWER];
  ZF_WEAPON_DATA[ZFWEAP_FIREAXE_UPGRADE]      = ZF_WEAPON_DATA[ZFWEAP_FIREAXE];
  
  // Spy
  ZF_WEAPON_DATA[ZFWEAP_REVOLVER]       = F_ISBULLET | (6 << 8) | (24 << 0);
  ZF_WEAPON_DATA[ZFWEAP_AMBASSADOR]     = F_ISBULLET | (6 << 8) | (24 << 0);
  ZF_WEAPON_DATA[ZFWEAP_BIGKILL]        = F_ISBULLET | (6 << 8) | (24 << 0);
  ZF_WEAPON_DATA[ZFWEAP_LETRANGER]      = F_ISBULLET | (6 << 8) | (24 << 0);
  ZF_WEAPON_DATA[ZFWEAP_KNIFE]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_ETERNALREWARD]  = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_CONNIVERSKUNAI] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_INVISWATCH]     = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_DEADRINGER]     = 0;
  ZF_WEAPON_DATA[ZFWEAP_CLOAKANDDAGGER] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_TTGWATCH]       = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_REVOLVER_UPGRADE]   = ZF_WEAPON_DATA[ZFWEAP_REVOLVER];
  ZF_WEAPON_DATA[ZFWEAP_KNIFE_UPGRADE]      = ZF_WEAPON_DATA[ZFWEAP_KNIFE];
  ZF_WEAPON_DATA[ZFWEAP_INVISWATCH_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_INVISWATCH];
    
  // Engineer
  ZF_WEAPON_DATA[ZFWEAP_ENGINEERSHOTGUN]     = F_ISBULLET          | (6 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_FRONTIERJUSTICE]     = F_ISBULLET          | (3 << 8) | (32 << 0);
  ZF_WEAPON_DATA[ZFWEAP_ENGINEERPISTOL]      = F_ISAUTO|F_ISBULLET | (12 << 8) | (200 << 0);
  ZF_WEAPON_DATA[ZFWEAP_WRANGLER]            = 0;
  ZF_WEAPON_DATA[ZFWEAP_WRENCH]              = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_GOLDENWRENCH]        = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_GUNSLINGER]          = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_SOUTHERNHOSPITALITY] = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_JAG]                 = F_NOSTRIP;
  ZF_WEAPON_DATA[ZFWEAP_BUILDPDA]            = 0;
  ZF_WEAPON_DATA[ZFWEAP_DESTROYPDA]          = 0;
  ZF_WEAPON_DATA[ZFWEAP_WRENCH_UPGRADE] = ZF_WEAPON_DATA[ZFWEAP_WRENCH];
}

////////////////////////////////////////////////////////////
//
// Math Utils
//
////////////////////////////////////////////////////////////
stock max(a,b) { return (a > b) ? a : b; }
stock min(a,b) { return (a < b) ? a : b; }
stock Float:fMax(Float:a, Float:b) { return (a > b) ? a : b; }
stock Float:fMin(Float:a, Float:b) { return (a < b) ? a : b; }

////////////////////////////////////////////////////////////
//
// ZF Team Utils
//
////////////////////////////////////////////////////////////
stock zomTeam()
{ return zf_zomTeam; }
stock surTeam()
{ return zf_surTeam; }
stock setZomTeam(team)
{ zf_zomTeam = team; }
stock setSurTeam(team)
{ zf_surTeam = team; }
stock isZom(client)
{ return (GetClientTeam(client) == zf_zomTeam); }
stock isSur(client)
{ return (GetClientTeam(client) == zf_surTeam); }

////////////////////////////////////////////////////////////
//
// Client Validity Utils
//
////////////////////////////////////////////////////////////
stock bool:validClient(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client); }
stock bool:validSur(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client) && isSur(client); }
stock bool:validZom(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client) && isZom(client); }
stock bool:validLivingClient(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client) && IsPlayerAlive(client); }
stock bool:validLivingSur(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client) && IsPlayerAlive(client) && isSur(client); }
stock bool:validLivingZom(client)
{ return (client > 0) && (client <= MaxClients) && IsClientInGame(client) && IsPlayerAlive(client) && isZom(client); }

////////////////////////////////////////////////////////////
//
// ZF Class Utils
//
////////////////////////////////////////////////////////////
stock bool:validZombie(TFClassType:class)   
{ return (ZF_VALIDZOMBIE[class] == 1); }
stock bool:validSurvivor(TFClassType:class) 
{ return (ZF_VALIDSURVIVOR[class] == 1); }
stock TFClassType:randomZombie()   
{ return ZF_ZOMBIES[GetRandomInt(0,8)]; }
stock TFClassType:randomSurvivor() 
{ return ZF_SURVIVORS[GetRandomInt(0,8)]; }

stock bool:isEngineer(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Engineer); }
stock bool:isHeavy(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Heavy); }
stock bool:isMedic(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Medic); }
stock bool:isPyro(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Pyro); }
stock bool:isScout(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Scout); }
stock bool:isSpy(client)
{ return (TF2_GetPlayerClass(client) == TFClass_Spy); }

////////////////////////////////////////////////////////////
//
// Map Utils
//
////////////////////////////////////////////////////////////
stock bool:mapIsZF()
{
  decl String:mapname[4];
  GetCurrentMap(mapname, sizeof(mapname));
  return strncmp(mapname, "zf_", 3, false) == 0;
}

stock bool:mapIsPL()
{
  decl String:mapname[4];
  GetCurrentMap(mapname, sizeof(mapname));
  return strncmp(mapname, "pl_", 3, false) == 0;
}

stock bool:mapIsCP()
{
  decl String:mapname[4];
  GetCurrentMap(mapname, sizeof(mapname));
  return strncmp(mapname, "cp_", 3, false) == 0;
}

////////////////////////////////////////////////////////////
//
// Round Utils
//
////////////////////////////////////////////////////////////
stock setRoundState(ZFRoundState:_state)
{ zf_roundState = _state; }

stock ZFRoundState:roundState()
{ return zf_roundState; }

stock endRound(winningTeam)
{
  new index = FindEntityByClassname(-1, "team_control_point_master");
  if(index == -1)
  {   
    index = CreateEntityByName("team_control_point_master");
    DispatchSpawn(index);
  }

  if(index == -1)
  {
    LogError("[VSH-ZF] Can't create 'team_control_point_master,' can't end round!");
  }
  else
  {
    AcceptEntityInput(index, "Enable");
    SetVariantInt(winningTeam);
    AcceptEntityInput(index, "SetWinner"); 
  }  
}

////////////////////////////////////////////////////////////
//
// Weapon State Utils
//
////////////////////////////////////////////////////////////
stock activeWeapon(client)
{ return GetEntDataEnt2(client, oActiveWeapon); }

stock activeWeaponId(client)
{
  new weapon = activeWeapon(client);
  return (weapon > 0) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
}

stock slotWeaponId(client, slot)
{
  new weapon = GetPlayerWeaponSlot(client, slot);
  return (weapon > 0) ? GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") : -1;
}

stock activeWeaponSlot(client)
{
  new weapon = activeWeapon(client);
  if(weapon > 0)
  {
    for(new i = 0; i < 5; i++)
      if(GetPlayerWeaponSlot(client, i) == weapon) 
        return i;
  }
  return -1;
}

stock bool:isEquipped(client, weaponId)
{
  for(new i = 0; i < 5; i++)
    if(slotWeaponId(client, i) == weaponId)
      return true;
  return false;
}

stock bool:isWielding(client, weaponId)
{ return (activeWeaponId(client) == weaponId); }

stock bool:isWieldingMelee(client)
{ return (activeWeaponSlot(client) == 2); }

stock bool:isWieldingAuto(client)
{
  new weaponId = activeWeaponId(client);
  if(weaponId >= 0)
  {
    if(weaponId >= MAX_ZF_WEAPONS)
      LogError("[VSH-ZF] - isWieldingAuto() - Invalid weaponId: %d", weaponId);
    else
      return ((ZF_WEAPON_DATA[weaponId] & F_ISAUTO) != 0);
  }
  return false;
}

stock bool:isWieldingBullet(client)
{  
  new weaponId = activeWeaponId(client);
  if(weaponId >= 0)
  {
    if(weaponId >= MAX_ZF_WEAPONS)
      LogError("[VSH-ZF] - isWieldingBullet() - Invalid weaponId: %d", weaponId);
    else
      return ((ZF_WEAPON_DATA[weaponId] & F_ISBULLET) != 0);
  }
  return false;
}

////////////////////////////////////////////////////////////
//
// Weapon Action Utils
//
////////////////////////////////////////////////////////////
stock switchToSlot(client, slot)
{
  new weapon = GetPlayerWeaponSlot(client, slot);
  if(weapon > 0)
    EquipPlayerWeapon(client, weapon);
}

stock stripWeapons(client, bool:keepPri = false)
{
  //
  // Strip weapons.
  // Remove weapon if it exists and F_NOSTRIP flag is not set.
  // Do not remove primary weapons if keepPri flag is set.
  //
  new bool:doStrip;
  new weaponId;
  for(new i = 0; i < 5; i++)
  {
    weaponId = slotWeaponId(client, i);
    if(weaponId > 0)
    {
      if(weaponId >= MAX_ZF_WEAPONS)
      {
        LogError("[VSH-ZF] - stripToMelee() - Invalid weaponId: %d", weaponId);
        TF2_RemoveWeaponSlot(client, i);
      }
      else
      {
        doStrip = ((ZF_WEAPON_DATA[weaponId] & F_NOSTRIP) == 0);
        if((i == 0) && keepPri)
          doStrip = false;
        if(doStrip)
          TF2_RemoveWeaponSlot(client, i);
      }
    }
  }

  //
  // Switch to melee slot.
  //
  switchToSlot(client, 2);
}

stock stripWeaponSlot(client, slot)
{
  if(GetPlayerWeaponSlot(client, slot) > 0) 
    TF2_RemoveWeaponSlot(client, slot);
}

stock setWeaponRof(weapon, rateScale)
{
  new Float:factor;
  new Float:tAttack;
  new Float:tEngine;    

  factor = (rateScale <= -100) ? 100.0 : 100 / float(100 + rateScale);
  tEngine = GetGameTime();
  tAttack = (GetEntDataFloat(weapon, oNextPriAttack) - tEngine) * factor;
  SetEntDataFloat(weapon, oNextPriAttack, (tAttack + tEngine), true);
  tAttack = (GetEntDataFloat(weapon, oNextSecAttack) - tEngine) * factor;
  SetEntDataFloat(weapon, oNextSecAttack, (tAttack + tEngine), true);
}

////////////////////////////////////////////////////////////
//
// Weapon Attack/Damage Utils
//
////////////////////////////////////////////////////////////
stock bool:attackWasBackstab(attacker, inflictor, damagetype)
{
  // Backstab attack defined as:
  // + attacker equals inflictor (i.e. not a projectile), AND
  // + attacker is a spy, AND
  // + attacker is wielding a melee weapon, AND
  // + damagetype (masked) equals 0x100000 (which indicates crit, thus backstab, through testing)
  return (attacker == inflictor) && isSpy(attacker) && isWieldingMelee(attacker) && ((damagetype & TF2_DMGTYPE_CRIT) != 0);
}

stock bool:attackWasMelee(attacker, inflictor, damagetype)
{
  // Melee attack defined as:
  // + damagetype includes bludgeon damage, AND
  // + attacker does not equal inflictor (i.e. projectile)
  return attackWasBludgeon(damagetype) && !attackWasProjectile(attacker, inflictor);
}

stock bool:attackWasBullet(attacker, inflictor)
{
  // Bullet attack defined as:
  // + attacker equals inflictor (i.e. not a projectile), AND
  // + attacker is wielding bullet-based weapon
  // OR
  // + inflictor is sentry gun
  return (attacker == inflictor) ? isWieldingBullet(attacker) : entIsSentry(inflictor);
}

stock bool:attackWasProjectile(attacker, inflictor)
{
  // Projectile attack defined as:
  // + attacker does not equal inflictor (i.e. projectile)
  return (attacker != inflictor);
}

stock bool:attackWasSelfFall(inflictor, damagetype)
{
  // Self-fall damage defined as:
  // + inflictor is 0, AND
  // + attackWasFall is true.
  return (inflictor == 0) && attackWasFall(damagetype);
}

stock bool:attackWasBleed(damagetype)
{ return (damagetype == TF2_DMGTYPE_BLEED); }

stock bool:attackWasBludgeon(damagetype)
{ return (damagetype & TF2_DMGTYPE_BLUDGEON) != 0; }

stock bool:attackWasEnvExplosion(damagetype)
{ return (damagetype == TF2_DMGTYPE_EXPLOSIVE); }

stock bool:attackWasExplosive(damagetype)
{ return (damagetype & TF2_DMGTYPE_EXPLOSIVE) != 0; }

stock bool:attackWasFall(damagetype)
{ return (damagetype == TF2_DMGTYPE_FALL); }

stock bool:attackWasFire(damagetype)
{ return (damagetype & TF2_DMGTYPE_FIRE) != 0; } // Note: Does not account for medic syringe gun damage

////////////////////////////////////////////////////////////
//
// Attribute / Flags Utils (Simple)
//
////////////////////////////////////////////////////////////
stock addCondKritz(client, Float:duration)
{ TF2_AddCondition(client, TFCond_Kritzkrieged, duration); }
stock remCondKritz(client)
{ TF2_RemoveCondition(client, TFCond_Kritzkrieged); }

stock bool:isSlowed(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_SLOWED) != 0; }
stock bool:isKritzed(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_KRITZKRIEGED) != 0; }
stock bool:isBonked(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_BONKED) != 0; }
stock bool:isDazed(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_DAZED) != 0; }
stock bool:isCharging(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_CHARGING) != 0; }
stock bool:isBeingHealed(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_HEALING) != 0; }
stock bool:isCloaked(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_CLOAKED) != 0; }
stock bool:isUbered(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_UBERCHARGED) != 0; }
stock bool:isOnFire(client)
{ return (TF2_GetPlayerConditionFlags(client) & TF_CONDFLAG_ONFIRE) != 0; }

stock addFlagNoTarget(client)
{ SetEntityFlags(client, (GetEntityFlags(client) | FL_NOTARGET)); }
stock remFlagNoTarget(client)
{ SetEntityFlags(client, (GetEntityFlags(client) & ~FL_NOTARGET)); }

stock bool:isGrounded(client)
{ return (GetEntityFlags(client) & (FL_ONGROUND | FL_INWATER)) != 0; }
stock bool:isCrouching(client)
{ return (GetEntityFlags(client) & FL_DUCKING) != 0; }

stock addInvincibility(client)
{ SetEntProp(client, Prop_Data, "m_takedamage", 0, 1); }
stock remInvincibility(client)
{ SetEntProp(client, Prop_Data, "m_takedamage", 2, 1); }

////////////////////////////////////////////////////////////
//
// Attribute / Flags Utils (Complex)
//
////////////////////////////////////////////////////////////
stock bool:isInWater(client)
{ return GetEntProp(client, Prop_Send, "m_nWaterLevel") > 0; }

stock bool:isNotMoving(client)
{
  decl Float:vel[3];
  GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
  return (GetVectorLength(vel, true) == 0);  
}

stock getEntityPos(entity, Float:pos[3])
{ GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos); }

////////////////////////////////////////////////////////////
//
// Health Utils
//
////////////////////////////////////////////////////////////
stock Float:getHealthPct(client)
{
  return GetClientHealth(client) / float(clientMaxHealth(client));  
}

stock setHealthPct(client, Float:healthPct)
{
  new newHealth = RoundToCeil(clientMaxHealth(client)*healthPct);
  SetEntityHealth(client, newHealth);
}

stock clientMaxHealth(client)
{
  new mh = GetEntProp(client, Prop_Data, "m_iMaxHealth");  
  switch (TF2_GetPlayerClass(client))
  { 
    //
    // Handle demoman bonuses
    // + Headcount from Eyelander / HHHHeadtaker
    //
    case TFClass_DemoMan:
    {
      if(isEquipped(client, ZFWEAP_EYELANDER) || isEquipped(client, ZFWEAP_HHHHEADTAKER))
      {
        new heads = GetEntProp(client, Prop_Send, "m_iDecapitations");
        mh += min(heads, 4) * 15;
      }
    }    
  }
  
  return mh; 
}

////////////////////////////////////////////////////////////
//
// Speed Utils
//
////////////////////////////////////////////////////////////
stock setClientSpeed(client, Float:speed)
{ SetEntDataFloat(client, oMaxspeed, speed, true); }

stock Float:clientBaseSpeed(client)
{
  switch (TF2_GetPlayerClass(client))
  { 
    case TFClass_Soldier:  return 240.0;  // Default 240.0
    case TFClass_DemoMan:  return 280.0;  // Default 280.0
    case TFClass_Medic:    return 320.0;  // Default 320.0
    case TFClass_Pyro:     return 240.0;  // Default 300.0 <Slowed>
    case TFClass_Engineer: return 300.0;  // Default 300.0
    case TFClass_Sniper:   return 300.0;  // Default 300.0
    case TFClass_Scout:    return 350.0;  // Default 400.0 <Slowed>
    case TFClass_Spy:      return 280.0;  // Default 300.0 <Slowed>
    case TFClass_Heavy:    return 230.0;  // Default 230.0
  }
  return 0.0;
}

stock Float:clientBonusSpeed(client)
{
  switch (TF2_GetPlayerClass(client))
  { 
    //
    // Handle soldier bonuses
    // + Wielding Equalizer
    //
    case TFClass_Soldier:
    {      
      if(isWielding(client, ZFWEAP_EQUALIZER))
      {
        new curH = GetClientHealth(client);
        if(curH > 160) return 0.0;
        if(curH > 120) return 24.0;
        if(curH > 80)  return 48.0;
        if(curH > 40)  return 96.0;
        if(curH > 0)   return 144.0;
      }
    }

    //
    // Handle demoman bonuses
    // + Headcount from Eyelander / HHHHeadtaker
    // + Wielding Skullcutter
    //
    case TFClass_DemoMan:
    {
      if(isEquipped(client, ZFWEAP_EYELANDER) || isEquipped(client, ZFWEAP_HHHHEADTAKER))
      {
        new heads = GetEntProp(client, Prop_Send, "m_iDecapitations");
        return min(heads, 4) * 22.5;
      }
      else if(isEquipped(client, ZFWEAP_SKULLCUTTER))
      {
        return -42.0;
      }
    }

    //
    // Handle heavy bonuses
    // + Wielding GRU
    // + Equipping Warrior's Spirit (ZF-only penalty due to attack bonus)
    // + Equipping Fists of Steel (ZF-only penalty due to ranged defense bonus)
    //
    case TFClass_Heavy:
    {
      if(isWielding(client, ZFWEAP_GRU))
      {
        return 70.0;
      }
      else if(isEquipped(client, ZFWEAP_WARRIORSSPIRIT))
      {
        return -100.0;
      }
      else if(isEquipped(client, ZFWEAP_FISTSOFSTEEL))
      {
        return -50.0;
      }
    }

    // TODO Pyro
    // + Set Bonus (Degreaser / Powerjack / Attendant [hat]) (+10%)

    // TODO Heavy
    // + Effects of Buffalo Steak (+81 speed) (now no longer stacks w/ GRU)
  }
  
  return 0.0;
}

////////////////////////////////////////////////////////////
//
// Entity Name Utils
//
////////////////////////////////////////////////////////////
stock bool:entClassnameContains(ent, const String:strRefClassname[])
{
  if(IsValidEdict(ent) && IsValidEntity(ent))
  {
    decl String:strName[32];
    GetEdictClassname(ent, strName, sizeof(strName));
    return (StrContains(strName, strRefClassname, false) != -1);
  }
  return false;
}

////////////////////////////////////////////////////////////
//
// Glow Utils
//
////////////////////////////////////////////////////////////
stock setGlow(client, bool:glowEnabled)
{
  SetEntProp(client, Prop_Send, "m_bGlowEnabled", (glowEnabled ? 1 : 0));
}

////////////////////////////////////////////////////////////
//
// Sentry Utils
//
////////////////////////////////////////////////////////////
stock bool:entIsSentry(ent)
{ return entClassnameContains(ent, "obj_sentrygun"); }

////////////////////////////////////////////////////////////
//
// Cloak Utils
// + Range 0.0 to 100.0
//
////////////////////////////////////////////////////////////
stock Float:getCloak(client)
{ 
  if(isSpy(client))
  {
    return GetEntDataFloat(client, oCloakMeter);
  }
  return 0.0;
}

stock setCloak(client, Float:cloakPct)
{ 
  if(isSpy(client)) 
  {
    SetEntDataFloat(client, oCloakMeter, cloakPct, true);
  }
}

////////////////////////////////////////////////////////////
//
// Uber Utils
// + Range 0.0 to 1.0
//
////////////////////////////////////////////////////////////
stock addUber(client, Float:uberPct)
{
  new weapon = GetPlayerWeaponSlot(client, 1);
  if(weapon > 0 && isMedic(client))
  {
    new Float:curPct = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
    SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", fMin((curPct + uberPct), 1.0));
  }
}

stock subUber(client, Float:uberPct)
{ 
  new weapon = GetPlayerWeaponSlot(client, 1);
  if(weapon > 0 && isMedic(client))
  {
    new Float:curPct = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
    SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", fMax((curPct - uberPct), 0.0));
  }
}

////////////////////////////////////////////////////////////
//
// Metal Add/Sub Utils
//
////////////////////////////////////////////////////////////
stock addMetalPct(client, Float:metalPct, Float:metalLimitPct = 1.0)
{
  if(isEngineer(client))
  {
    new curMetal = getMetal(client);
    new maxMetal = 200;
    new metal = RoundToCeil(maxMetal * metalPct);
    setMetal(client, min((curMetal + metal), RoundToCeil(maxMetal * metalLimitPct)));
  }
}

stock subMetalPct(client, Float:metalPct)
{
  if(isEngineer(client))
  {
    new curMetal = getMetal(client);
    new maxMetal = 200;
    new metal = RoundToCeil(maxMetal * metalPct);
    subMetal(client, max((curMetal - metal), 0);
  }
}

stock addMetal(client, metal)
{
  if(isEngineer(client))
  {
    new curMetal = getMetal(client);
    setMetal(client, min((curMetal + metal), 200)); 
  }
}

stock subMetal(client, metal)
{
  if(isEngineer(client))
  {
    new curMetal = getMetal(client);
    setMetal(client, max((curMetal - metal), 0)); 
  }
}

////////////////////////////////////////////////////////////
//
// Metal Get/Set Utils
//
////////////////////////////////////////////////////////////
stock getMetal(client)
{ return GetEntData(client, oResAmmo[2]); }

stock setMetal(client, metal)
{ SetEntData(client, oResAmmo[2], min(metal, 255), true); }

////////////////////////////////////////////////////////////
//
// Ammo Add/Sub Utils
//
////////////////////////////////////////////////////////////
stock addClipAmmoPct(client, slot, Float:ammoPct, Float:ammoLimitPct = 1.0)
{
  new curAmmo = getClipAmmo(client, slot);
  new maxAmmo = maxClipAmmo(client, slot);
  new ammo = RoundToCeil(maxAmmo * ammoPct);
  setClipAmmo(client, slot, min((curAmmo + ammo), RoundToCeil(maxAmmo * ammoLimitPct)));
}

stock subClipAmmoPct(client, slot, Float:ammoPct)
{
  new curAmmo = getClipAmmo(client, slot);
  new maxAmmo = maxClipAmmo(client, slot);
  new ammo = RoundToCeil(maxAmmo * ammoPct);
  setClipAmmo(client, slot, max(curAmmo - ammo, 0));
}

stock addResAmmoPct(client, slot, Float:ammoPct, Float:ammoLimitPct = 1.0)
{
  new curAmmo = getResAmmo(client, slot);
  new maxAmmo = maxResAmmo(client, slot);
  new ammo = RoundToCeil(maxAmmo * ammoPct);
  setResAmmo(client, slot, min((curAmmo + ammo), RoundToCeil(maxAmmo * ammoLimitPct)));
}

stock subResAmmoPct(client, slot, Float:ammoPct)
{
  new curAmmo = getResAmmo(client, slot);
  new maxAmmo = maxResAmmo(client, slot);
  new ammo = RoundToCeil(maxAmmo * ammoPct);
  setResAmmo(client, slot, max(curAmmo - ammo, 0));
}

stock addClipAmmo(client, slot, ammo)
{
  new curAmmo = getClipAmmo(client, slot);
  new maxAmmo = maxClipAmmo(client, slot);
  new newAmmo = min(curAmmo + ammo, maxAmmo);
  setClipAmmo(client, slot, newAmmo); 
}

stock subClipAmmo(client, slot, ammo)
{
  new curAmmo = getClipAmmo(client, slot);
  setClipAmmo(client, slot, max((curAmmo - ammo), 0));
}

stock addResAmmo(client, slot, ammo)
{
  new curAmmo = getResAmmo(client, slot);
  new maxAmmo = maxResAmmo(client, slot);
  new newAmmo = min(curAmmo + ammo, maxAmmo);
  setResAmmo(client, slot, newAmmo);
}

stock subResAmmo(client, slot, ammo)
{
  new curAmmo = getResAmmo(client, slot);
  setResAmmo(client, slot, max((curAmmo - ammo), 0));
}

////////////////////////////////////////////////////////////
//
// Ammo Set/Get Utils
//
//////////////////////////////////////////////////////////// 
stock Float:getClipAmmoPct(client, slot)
{
  new curAmmo = getClipAmmo(client, slot);
  new maxAmmo = maxClipAmmo(client, slot);
  return (maxAmmo == 0) ? 0.0 : float(curAmmo)/float(maxAmmo);
}

// TODO setClipAmmoPct

stock Float:getResAmmoPct(client, slot)
{
  new curAmmo = getResAmmo(client, slot);
  new maxAmmo = maxResAmmo(client, slot);
  return (maxAmmo == 0) ? 0.0 : float(curAmmo)/float(maxAmmo);  
}

// TODO setResAmmoPct

stock getClipAmmo(client, slot)
{
  new weapon = GetPlayerWeaponSlot(client, slot);
  return (weapon > 0) ? GetEntData(weapon, oClipAmmo) : 0;
}

stock setClipAmmo(client, slot, ammo)
{
  new weapon = GetPlayerWeaponSlot(client, slot);
  if(weapon > 0) SetEntData(weapon, oClipAmmo, min(ammo, 255), true);
}

stock getResAmmo(client, slot)
{
  return GetEntData(client, oResAmmo[slot]);
}

stock setResAmmo(client, slot, ammo)
{
  SetEntData(client, oResAmmo[slot], min(ammo, 255), true);
}

////////////////////////////////////////////////////////////
//
// Ammo Max Utils
//
//////////////////////////////////////////////////////////// 
stock maxClipAmmo(client, slot)
{
  new weaponId = slotWeaponId(client, slot);
  if(weaponId >= 0)
  {
    if(weaponId >= MAX_ZF_WEAPONS)
      LogError("[VSH-ZF] - maxClipAmmo() - Invalid weaponId: %d", weaponId);
    else
      return ((ZF_WEAPON_DATA[weaponId] & M_MAXCLIPAMMO) >> S_MAXCLIPAMMO);
  }
  return 0;
}

stock maxResAmmo(client, slot)
{
  new weaponId = slotWeaponId(client, slot);
  if(weaponId >= 0)
  {
    if(weaponId >= MAX_ZF_WEAPONS)
      LogError("[VSH-ZF] - maxResAmmo() - Invalid weaponId: %d", weaponId);
    else
      return ((ZF_WEAPON_DATA[weaponId] & M_MAXRESAMMO) >> S_MAXRESAMMO);
  }
  return 0;
}

////////////////////////////////////////////////////////////
//
// Spawn Utils
//
////////////////////////////////////////////////////////////
stock spawnClient(client, nextClientTeam)
{
//   // DEBUG
//   PrintToChat(client, "[VSH-ZF] spawnClient %d %d", client, _:TF2_GetPlayerClass(client));
      

    TF2_RespawnPlayer(client);      
  }

setTeamRespawnTime(team, Float:time)
{
  new index = FindEntityByClassname(-1, "tf_gamerules");
  if(index != -1)
  {
    SetVariantFloat(time/2.0);
    if(team == _:TFTeam_Blue)
      AcceptEntityInput(index, "SetBlueTeamRespawnWaveTime", -1, -1, 0);
    if(team == _:TFTeam_Red)
      AcceptEntityInput(index, "SetRedTeamRespawnWaveTime", -1, -1, 0);
  }       
}

////////////////////////////////////////////////////////////
//
// Damage Utils
//
////////////////////////////////////////////////////////////
stock applyDamageRadialAtClient(
  client, 
  damage, 
  radius, 
  bool:doFx = false)
{
  decl Float:pos[3];
  GetClientEyePosition(client, pos);
  applyDamageRadial(client, damage, pos, radius, doFx);  
}

stock applyDamageRadial(
  attacker, 
  damage, 
  const Float:pos[3],
  radius, 
  bool:doFx = false)
{
  if((damage <= 0) || (radius <= 0) || !validClient(attacker))
    return;

  // Apply explosion damage.
  new ent = CreateEntityByName("env_explosion");
  if(IsValidEntity(ent))
  {
    decl String:strTargetName[16];
    decl String:strAddOutput[64];
    Format(strTargetName, sizeof(strTargetName), "%s%d", ZF_DAMAGERADIUS_NAME, ent);

    // Config, create env_explosion
    DispatchKeyValue(ent, "targetname", strTargetName); 
    SetEntProp(ent, Prop_Data, "m_iMagnitude", damage);
    SetEntProp(ent, Prop_Data, "m_iRadiusOverride", radius);
    SetEntProp(ent, Prop_Data, "m_spawnflags", (doFx ? 0x0 : 0x3FC));
    SetEntPropEnt(ent, Prop_Data, "m_hInflictor", attacker);
    SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", attacker); 
    SetEntPropEnt(ent, Prop_Data, "m_hEntityIgnore", attacker); // Prevent self-damage
    SetEntPropFloat(ent, Prop_Data, "m_flDamageForce", 100.0);  // TODO Why is this here?
    DispatchSpawn(ent);

    // Teleport env_explosion
    TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
        
    // Explode in 0.01s.
    Format(strAddOutput, sizeof(strAddOutput), "OnUser1 !self:explode::%f:1", 0.01);
    SetVariantString(strAddOutput);
    AcceptEntityInput(ent, "AddOutput");
    AcceptEntityInput(ent, "FireUser1");
    
    // Kill in 0.02s.
    Format(strAddOutput, sizeof(strAddOutput), "OnUser2 !self:kill::%f:1", 0.02);
    SetVariantString(strAddOutput);
    AcceptEntityInput(ent, "AddOutput");
    AcceptEntityInput(ent, "FireUser2");
  }
  else
  {
    LogError("[VSH-ZF] applyDamageRadial (%d, %d, [%2.2f,%2.2f,%2.2f], %d) failed.", attacker, damage, pos[0], pos[1], pos[2], radius); 
  }
  
  return;  
}
