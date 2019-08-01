////////////////////////////////////////////////////////////////////////////////
//
//  Z O M B I E - F O R T R E S S - [TF2]
//
//  ZF Utility Effects (FX) File
//
//  Includes stock routines for particle systems, sounds, and models.
//
////////////////////////////////////////////////////////////////////////////////

// TODO
// Change how to set an entity parent using "!activator" instead of changing targetname?

#if defined _ZF_UTIL_FX_INC
  #endinput
#endif
#define _ZF_UTIL_FX_INC

#include "zf_util_base.inc"

//
// ZF Offset Objects
//
static oMyWeapons;

//
// ZF Model Objects
//
// HL2 models
stock String:ZFMDL_SUPPLYCRATE[]      = "models/items/item_item_crate.mdl";
stock String:ZFMDL_MINE[]             = "models/props_combine/combine_mine01.mdl";

// Standard models
stock String:ZFMDL_HAYBALE[]          = "models/props_farm/haypile001.mdl";
stock String:ZFMDL_FLAG[]             = "models/flag/flag.mdl";
stock String:ZFMDL_FENCE[]            = "models/props_coalmines/wood_fence_short_128.mdl";
stock String:ZFMDL_FROG[]            = "models/props_2fort/frog.mdl";

stock String:ZFMDL_TOTEM[2][] = {
  "models/props_badlands/rock001_skybox.mdl",
  "models/props_badlands/rock002_skybox.mdl"
};
stock String:ZFMDL_TOTEMCLIP[2][] = {
  "models/props_swamp/buoy_ref.mdl",
  "models/props_2fort/trainwheel003.mdl"
};

// Physics models
stock String:ZFMDL_PRESENT[3][] = {
  "models/effects/bday_gib01.mdl", // Box
  "models/effects/bday_gib02.mdl", // Box
  "models/effects/bday_gib04.mdl"  // Disc
};
stock String:ZFMDL_CUTOUT[10][] = { // Index with TFClassType
  "models/props_training/target_scout.mdl", // Need something other than "" here, crash on PrecacheModel("", ...
  "models/props_training/target_scout.mdl",
  "models/props_training/target_sniper.mdl",
  "models/props_training/target_soldier.mdl",
  "models/props_training/target_demoman.mdl",
  "models/props_training/target_medic.mdl",
  "models/props_training/target_heavy.mdl",
  "models/props_training/target_pyro.mdl",
  "models/props_training/target_spy.mdl",
  "models/props_training/target_engineer.mdl"
};

//
// ZF Particle Objects
//
enum ZFParticleAttachStyle
{
  AttachNone = 0, // Do not attach
  AttachBase,     // Attach to entity
  AttachHead,     // Attach to entity point "head"
  AttachBack      // Attach to entity point "flag"
}

// Persistent particle systems
stock String:ZFPART_AURA00RED[]         = "teleporter_red_floorglow";
stock String:ZFPART_AURA00BLU[]         = "teleporter_blue_floorglow";
stock String:ZFPART_AURA01RED[]         = "player_glowred";
stock String:ZFPART_AURA01BLU[]         = "player_glowblue";
stock String:ZFPART_AURA02RED[]         = "teleporter_red_charged_hotplate";
stock String:ZFPART_AURA02BLU[]         = "teleporter_blue_charged_hotplate";
stock String:ZFPART_AURAINRED[]         = "soldierbuff_red_spikes";
stock String:ZFPART_AURAINBLU[]         = "soldierbuff_blue_spikes";
stock String:ZFPART_AURAOUTRED[]        = "soldierbuff_red_spirial";
stock String:ZFPART_AURAOUTBLU[]        = "soldierbuff_blue_spiral";
stock String:ZFPART_AURAHALO[]          = "halopoint";
stock String:ZFPART_AURASPARKLE[]       = "community_sparkle";
stock String:ZFPART_AURAVORTEXBLU[]     = "coin_blue";
stock String:ZFPART_AURAGLOW[]          = "superrare_beam1_glow";
stock String:ZFPART_AURAGLOWBEAMS[]     = "superrare_beams1";
stock String:ZFPART_AURABURNINGORANGE[] = "superrare_burning1";
stock String:ZFPART_AURABURNINGGREEN[]  = "superrare_burning2";
stock String:ZFPART_AURAFLIES[]         = "superrare_flies";
stock String:ZFPART_AURAENERGYGREEN[]   = "superrare_greenenergy";
stock String:ZFPART_AURAENERGYPURPLE[]  = "superrare_purpleenergy";

// Non-persistent particle systems
stock String:ZFPART_REDPOWERUP[]    = "teleportedin_red";
stock String:ZFPART_BLUPOWERUP[]    = "teleportedin_blue";
stock String:ZFPART_HEALTHGAINRED[] = "healthgained_red";
stock String:ZFPART_HEALTHGAINBLU[] = "healthgained_blu";
stock String:ZFPART_HEALTHLOSTRED[] = "healthlost_red";
stock String:ZFPART_HEALTHLOSTBLU[] = "healthlost_blu";
stock String:ZFPART_HEALTHMISTRED[] = "healhuff_red_mist";
stock String:ZFPART_HEALTHMISTBLU[] = "healhuff_blu_mist";
stock String:ZFPART_BLOODBURST[]    = "blood_impact_red_01";
stock String:ZFPART_BLOODMIST[]     = "env_sawblood_mist";
stock String:ZFPART_BLOODSPRAY[]    = "blood_spray_red_01";
stock String:ZFPART_CONFETTIBIG[]   = "bday_confetti";
stock String:ZFPART_CONFETTISMALL[] = "bday_blood";
stock String:ZFPART_CONFETTIBITS1[] = "superrare_confetti_green";
stock String:ZFPART_CONFETTIBITS2[] = "superrare_confetti_purple";
stock String:ZFPART_EXPLOSION0[]    = "ExplosionCore_MidAir";
stock String:ZFPART_EXPLOSION1[]    = "Explosions_MA_FloatieEmbers";
stock String:ZFPART_EXPLOSION2[]    = "Explosions_UW_Debris001";
stock String:ZFPART_FIREWORKS[]     = "mini_fireworks";
stock String:ZFPART_PUFFSMALL[]     = "doublejump_smoke";
stock String:ZFPART_PUFFBIG[]       = "target_break_child_puff";
stock String:ZFPART_SPARKS[]        = "sapper_flyingembers";
stock String:ZFPART_SMOKE[]         = "sapper_smoke";
stock String:ZFPART_YIKES[]         = "yikes_text";
stock String:ZFPART_PUMPKINBITS[]   = "pumpkin_bits";

//
// ZF Sound Objects
//
stock String:ZFSND_PICKUPAMMO[]        = "items/gunpickup2.wav";
stock String:ZFSND_PICKUPMED[]         = "items/smallmedkit1.wav";           // HL2
stock String:ZFSND_PICKUPSPAWN[]       = "items/spawn_item.wav";
stock String:ZFSND_EXPLOSION[]         = "weapons/pipe_bomb1.wav";
stock String:ZFSND_BIRTHDAY[]          = "misc/happy_birthday.wav";
stock String:ZFSND_PUSHBACK[]          = "player/pl_impact_airblast2.wav";
stock String:ZFSND_PACKPICKUP[]        = "ui/item_pack_pickup.wav";
stock String:ZFSND_PACKDROP[]          = "ui/item_pack_drop.wav";
stock String:ZFSND_SPLASH[]            = "player/footsteps/mud1.wav";
stock String:ZFSND_CRITXMIT[]          = "player/crit_hit2.wav";
stock String:ZFSND_CRITRECV[]          = "player/crit_received1.wav";
stock String:ZFSND_CRITMINI[]          = "player/crit_hit_mini.wav";
stock String:ZFSND_TICK[]              = "player/taunt_cig_flick.wav";
stock String:ZFSND_KRITZSTART[]        = "weapons/boxing_gloves_crit_enabled.wav";
stock String:ZFSND_KRITZSTOP[]         = "weapons/weapon_crit_charged_off.wav";
stock String:ZFSND_THUD[]              = "player/taunt_chest_thump.wav";
stock String:ZFSND_SPARK[]             = "ambient/energy/spark4.wav";         // HL2
stock String:ZFSND_BOING[]             = "weapons/sentry_damage2.wav";

stock String:ZFSND_WOOD_HIT[8][] = {
  "physics/wood/wood_crate_break1.wav",     // HL2
  "physics/wood/wood_crate_break2.wav",     // HL2
  "physics/wood/wood_furniture_break1.wav", // HL2
  "physics/wood/wood_furniture_break2.wav", // HL2
  "physics/wood/wood_plank_break1.wav",     // HL2
  "physics/wood/wood_plank_break2.wav",     // HL2
  "physics/wood/wood_plank_break3.wav",     // HL2
  "physics/wood/wood_plank_break4.wav"      // HL2
}; 

stock String:ZFSND_SPIT[3][] = {
  "player/drown1.wav",
  "player/drown2.wav",
  "player/drown3.wav"
};
stock String:ZFSND_TUNE[3][] = {
  "ui/tv_tune.wav",
  "ui/tv_tune2.wav",
  "ui/tv_tune3.wav"
};
stock String:ZFSND_SCREAM[10][] = { // Index with TFClassType
  "vo/halloween_scream3.wav",
  "vo/scout_paincrticialdeath01.wav",
  "vo/sniper_paincrticialdeath01.wav",
  "vo/soldier_paincrticialdeath01.wav",
  "vo/demoman_paincrticialdeath01.wav",
  "vo/medic_paincrticialdeath01.wav",
  "vo/heavy_paincrticialdeath01.wav",
  "vo/pyro_paincrticialdeath01.wav",
  "vo/spy_paincrticialdeath01.wav",
  "vo/engineer_paincrticialdeath01.wav"
};
stock String:ZFSND_EVILLAUGH[10][] = { // Index with TFClassType
  "vo/scout_laughevil01.wav", // Need something other than "" here, crash on PrecacheSound("", ...
  "vo/scout_laughevil01.wav",
  "vo/sniper_laughevil01.wav",
  "vo/soldier_laughevil01.wav",
  "vo/demoman_laughevil03.wav",
  "vo/medic_laughevil03.wav",
  "vo/heavy_laughevil03.wav",
  "vo/pyro_laughevil04.wav",
  "vo/spy_laughevil02.wav",
  "vo/engineer_laughevil04.wav"
};
stock String:ZFSND_PAINSHARP[10][] = { // Index with TFClassType
  "vo/scout_painsharp01.wav", // Need something other than "" here, crash on PrecacheSound("", ...
  "vo/scout_painsharp01.wav",
  "vo/sniper_painsharp01.wav",
  "vo/soldier_painsharp01.wav",
  "vo/demoman_painsharp01.wav",
  "vo/medic_painsharp01.wav",
  "vo/heavy_painsharp01.wav",
  "vo/pyro_painsharp01.wav",
  "vo/spy_painsharp01.wav",
  "vo/engineer_painsharp01.wav"  
};


//
// ZF Sprite Objects
//
stock String:ZFSPR_EXCLAMATION[] = "materials/sprites/minimap_icons/voiceicon.vmt";
stock String:ZFSPR_DEATH[]       = "materials/sprites/minimap_icons/death.vmt";
stock String:ZFSPR_DOMINATED[]   = "materials/HUD/leaderboard_dominated.vmt";
stock String:ZFSPR_CROSSHAIR[]   = "materials/HUD/leaderboard_class_sniper.vmt";
   
////////////////////////////////////////////////////////////
//
// Util Init
//
////////////////////////////////////////////////////////////
stock utilFxInit()
{
  utilFxPrecache();
  
  // Initialize offsets
  oMyWeapons = FindSendPropOffs("CBasePlayer", "m_hMyWeapons");
}

stock utilFxPrecache()
{
  // Precache models.
  PrecacheModel(ZFMDL_SUPPLYCRATE, true);
  PrecacheModel(ZFMDL_MINE, true);
  PrecacheModel(ZFMDL_HAYBALE, true);
  PrecacheModel(ZFMDL_FLAG, true);
  PrecacheModel(ZFMDL_FROG, true);
  PrecacheModel(ZFMDL_FENCE, true);
  for(new i = 0; i < 1; i++)
    PrecacheModel(ZFMDL_TOTEM[i], true);
  for(new i = 0; i < 1; i++)    
    PrecacheModel(ZFMDL_TOTEMCLIP[i], true);
  for(new i = 0; i < 3; i++)
    PrecacheModel(ZFMDL_PRESENT[i], true);
  for(new i = 0; i < 10; i++)
    PrecacheModel(ZFMDL_CUTOUT[i], true);
        
  // Precache sounds.
  PrecacheSound(ZFSND_PICKUPAMMO, true);
  PrecacheSound(ZFSND_PICKUPMED, true);
  PrecacheSound(ZFSND_PICKUPSPAWN, true);
  PrecacheSound(ZFSND_EXPLOSION, true);
  PrecacheSound(ZFSND_BIRTHDAY, true);
  PrecacheSound(ZFSND_PUSHBACK, true);
  PrecacheSound(ZFSND_PACKPICKUP, true);
  PrecacheSound(ZFSND_PACKDROP, true);
  PrecacheSound(ZFSND_SPLASH, true);
  PrecacheSound(ZFSND_CRITXMIT, true);
  PrecacheSound(ZFSND_CRITRECV, true);
  PrecacheSound(ZFSND_CRITMINI, true);
  PrecacheSound(ZFSND_TICK, true);
  PrecacheSound(ZFSND_KRITZSTART, true);
  PrecacheSound(ZFSND_KRITZSTOP, true);
  PrecacheSound(ZFSND_THUD, true);
  PrecacheSound(ZFSND_SPARK, true);
  PrecacheSound(ZFSND_BOING, true);
  for(new i = 0; i < 8; i++)
    PrecacheSound(ZFSND_WOOD_HIT[i], true);
  for(new i = 0; i < 3; i++)
    PrecacheSound(ZFSND_SPIT[i], true);
  for(new i = 0; i < 3; i++)
    PrecacheSound(ZFSND_TUNE[i], true);
  for(new i = 0; i < 10; i++)
    PrecacheSound(ZFSND_SCREAM[i], true);
  for(new i = 0; i < 10; i++)
    PrecacheSound(ZFSND_EVILLAUGH[i], true);
}

////////////////////////////////////////////////////////////
//
// Render Effects
//
////////////////////////////////////////////////////////////
stock fxSetClientColor(client, r, g, b, a, bool:colorWeapons = false, bool:colorWearables = false)
{
  // Set client alpha.
  SetEntityRenderMode(client, RENDER_TRANSCOLOR);
  SetEntityRenderColor(client, r, g, b, a); 
  
  // Set client weapon alpha.
  if(colorWeapons)
  {
    for(new i = 0; i < 47; i += 4)
    {
      new weapon = GetEntDataEnt2(client, oMyWeapons + i);      
      if(weapon != -1)
      {
        SetEntityRenderMode(weapon, RENDER_TRANSCOLOR);
        SetEntityRenderColor(weapon, r, g, b, a);
      }
    }
  }
  
  // Set client wearable alpha.
  if(colorWearables)
  {
    new index = -1;
    while((index = FindEntityByClassname(index, "tf_wearable_item")) != -1)
    {
      if(GetEntPropEnt(index, Prop_Data, "m_hOwnerEntity") == client)
      {
        SetEntityRenderMode(index, RENDER_TRANSCOLOR);
        SetEntityRenderColor(index, r, g, b, a);        
      }
    }
  }
}

////////////////////////////////////////////////////////////
//
// Client Effects
//
////////////////////////////////////////////////////////////
stock fxBloodBurst(client)
{
  fxCreateParticle(ZFPART_BLOODBURST, client, AttachBack, 2.0);
  fxCreateParticle(ZFPART_BLOODMIST, client, AttachBack, 2.0);
}

stock fxBloodSpray(client)
{
  fxCreateParticle(ZFPART_BLOODSPRAY, client, AttachBack, 2.0);
}

stock fxDeathScream(client)
{
  new clientClass = _:TF2_GetPlayerClass(client);
  fxCreateSoundToAll(ZFSND_SCREAM[clientClass], client);
}

stock fxEvilLaughToAll(client)
{
  new clientClass = _:TF2_GetPlayerClass(client);
  fxCreateSoundToAll(ZFSND_EVILLAUGH[clientClass], client);
}

stock fxEvilLaughToClient(evilClient, otherClient)
{
  new evilClientClass = _:TF2_GetPlayerClass(evilClient);
  fxCreateSoundToClient(ZFSND_EVILLAUGH[evilClientClass], evilClient);
  fxCreateSoundToClient(ZFSND_EVILLAUGH[evilClientClass], otherClient);
}

stock fxHealthGained(client)
{
  if(GetClientTeam(client) == _:TFTeam_Red)
    fxCreateParticle(ZFPART_HEALTHGAINRED, client, AttachHead, 2.0);
  else if(GetClientTeam(client) == _:TFTeam_Blue)
    fxCreateParticle(ZFPART_HEALTHGAINBLU, client, AttachHead, 2.0);
}

stock fxHealthLost(client)
{
  if(GetClientTeam(client) == _:TFTeam_Red)
    fxCreateParticle(ZFPART_HEALTHLOSTRED, client, AttachHead, 2.0);
  else if(GetClientTeam(client) == _:TFTeam_Blue)
    fxCreateParticle(ZFPART_HEALTHLOSTBLU, client, AttachHead, 2.0);
}

stock fxHealthMist(client)
{
  if(GetClientTeam(client) == _:TFTeam_Red)
    fxCreateParticle(ZFPART_HEALTHMISTRED, client, AttachHead, 4.0);
  else if(GetClientTeam(client) == _:TFTeam_Blue)
    fxCreateParticle(ZFPART_HEALTHMISTBLU, client, AttachHead, 4.0);
}

stock fxKritzStart(client)
{
  fxPowerup(client);
  fxCreateSoundToAll(ZFSND_KRITZSTART, client);
}

stock fxKritzStop(client)
{
  fxCreateSoundToAll(ZFSND_KRITZSTOP, client);
}

stock fxPain(client)
{
  new clientClass = _:TF2_GetPlayerClass(client);    
  fxCreateSoundToAll(ZFSND_PAINSHARP[clientClass], client);
}

stock fxPowerup(client)
{
  if(GetClientTeam(client) == _:TFTeam_Red)
  {
    fxCreateParticle(ZFPART_REDPOWERUP, client, AttachBase, 2.0);
    ClientCommand(client, "voicemenu 2 1");
  }
  else if(GetClientTeam(client) == _:TFTeam_Blue)
  {
    fxCreateParticle(ZFPART_BLUPOWERUP, client, AttachBase, 2.0);
    ClientCommand(client, "voicemenu 2 1");
  }
}

stock fxTeleportTrail(client, Float:duration)
{
  if(GetClientTeam(client) == _:TFTeam_Red)
    fxCreateParticle(ZFPART_AURA01RED, client, AttachBase, duration);
  else if(GetClientTeam(client) == _:TFTeam_Blue)
    fxCreateParticle(ZFPART_AURA01BLU, client, AttachBase, duration);
}

stock fxYikes(client)
{
  fxCreateParticle(ZFPART_YIKES, client, AttachHead, 4.0);  
  fxCreateSoundToAll(ZFSND_SCREAM[0], client);
}

////////////////////////////////////////////////////////////
//
// Client Force Effects
//
////////////////////////////////////////////////////////////
stock fxJump(client, Float:force, bool:doVert = false)
{
  decl Float:ang[3];
  GetClientEyeAngles(client, ang);
  
  // Get jump direction vector. Do vertical jump if specified.
  decl Float:vec[3];
  GetAngleVectors(ang, vec, NULL_VECTOR, NULL_VECTOR); 
  NormalizeVector(vec, vec);
  if(doVert) vec[2] = 5.0;
  
  fxApplyForce(client, vec, force);
}

// Apply knockback to targetClient from sourceEntity with specified force.
stock fxKnockback(targetClient, sourceEntity, Float:force)
{  
  decl Float:targetPos[3];
  decl Float:sourcePos[3];
  GetClientAbsOrigin(targetClient, targetPos);
  GetEntPropVector(sourceEntity, Prop_Send, "m_vecOrigin", sourcePos);
  
  // Get vector from sourceClient to targetClient.
  decl Float:vec[3];
  MakeVectorFromPoints(sourcePos, targetPos, vec);
  
  fxApplyForce(targetClient, vec, force);
  fxCreateSoundToClient(ZFSND_THUD, targetClient);
}

// Apply force to an entity along the specified vector.
stock fxApplyForce(entity, const Float:direction[3], Float:force, bool:forceMinVert = true)
{
  decl Float:vel[3];
  GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vel);  
  
  // Get unit vector along direction vector.
  decl Float:vec[3];
  NormalizeVector(direction, vec);
  
  // Calculate force to apply (enforce minimum vertical velocity, if specified).
  ScaleVector(vec, force);
  if(forceMinVert && (vec[2] < 300.0)) vec[2] = 300.0;
  AddVectors(vec, vel, vec);
  
  TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vec);
}

////////////////////////////////////////////////////////////
//
// Explosion Effects
//
////////////////////////////////////////////////////////////
stock fxBits(entity)
{
  fxCreateParticle(ZFPART_PUMPKINBITS, entity, AttachNone, 2.0);
  fxCreateSoundToAll(ZFSND_SPLASH, entity);
}

stock fxExplosionBig(entity)
{
  fxCreateParticle(ZFPART_EXPLOSION0, entity, AttachNone, 2.0);
  fxCreateSoundToAll(ZFSND_EXPLOSION, entity);
}

stock fxExplosionTiny(entity)
{
  new Float:offset[3] = {0.0, 0.0, 40.0};
  fxCreateParticle(ZFPART_EXPLOSION1, entity, AttachNone, 4.0, offset);
  fxCreateParticle(ZFPART_SMOKE, entity, AttachNone, 4.0, offset);
}

stock fxExplosionParty(entity)
{
  fxCreateParticle(ZFPART_CONFETTISMALL, entity, AttachNone, 4.0);
  fxCreateSoundToAll(ZFSND_BIRTHDAY, entity);
}

stock fxPuffBig(entity)
{
  // Create main puff.  
  fxCreateParticle(ZFPART_PUFFBIG, entity, AttachNone, 4.0); 

  // Create smaller, surrounding puffs.
  new Float:offset[3] = {0.0, 0.0, 0.0};
  offset[0] = 50.0; offset[1] = 0.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset); 
  offset[0] = 25.0; offset[1] = 43.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset);  
  offset[0] = -25.0; offset[1] = 43.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset); 
  offset[0] = -50.0; offset[1] = 0.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset); 
  offset[0] = -25.0; offset[1] = -43.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset);   
  offset[0] = 25.0; offset[1] = -43.0; offset[2] = 4.0;
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0, offset); 
  
  // Create sound.
  fxCreateSoundToAll(ZFSND_THUD, entity);
}

stock fxPuffSmall(entity)
{
  fxCreateParticle(ZFPART_PUFFSMALL, entity, AttachNone, 4.0);
}

stock fxSmoke(entity)
{
  new Float:offset[3] = {0.0, 0.0, 40.0};
  fxCreateParticle(ZFPART_SMOKE, entity, AttachNone, 4.0, offset);
}

stock fxSpark(entity)
{
  new Float:offset[3] = {0.0, 0.0, 40.0};
  fxCreateParticle(ZFPART_SPARKS, entity, AttachBase, 2.0, offset);
  fxCreateSoundToAll(ZFSND_SPARK, entity);  
}

stock fxTrailConfetti(entity, Float:duration)
{
  fxCreateParticle(ZFPART_CONFETTIBITS1, entity, AttachBase, duration);
  fxCreateParticle(ZFPART_CONFETTIBITS2, entity, AttachBase, duration);
}

////////////////////////////////////////////////////////////
//
// Model Utils
//
////////////////////////////////////////////////////////////
stock fxCreateModelThrown(
  const String:strModel[],
  client,
  // bool:isOwned,
  // bool:isSolid,
  const Float:pos[3] = {0.0, ...},
  const Float:ang[3] = {0.0, ...},
  Float:force = 0.0,
  const color[3] = {255, ...})
{
  new ent = CreateEntityByName("prop_physics_multiplayer");
  if(IsValidEntity(ent))
  {   
    // Pre-configure prop.
    SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
    SetEntProp(ent, Prop_Send, "m_hEffectEntity", 0); // Hijack prop to store custom state.
    SetEntProp(ent, Prop_Data, "m_CollisionGroup", 1);
    SetEntProp(ent, Prop_Data, "m_usSolidFlags", 0x18);
    SetEntProp(ent, Prop_Data, "m_nSolidType", 6);
    SetEntPropFloat(ent, Prop_Data, "m_flFriction", 10000.0);
    SetEntPropFloat(ent, Prop_Data, "m_massScale", 100.0); // Keep low to prevent physics damage
    SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
    SetEntityModel(ent, strModel);
    SetEntityRenderColor(ent, color[0], color[1], color[2], 255);
           
    // Spawn prop.
    DispatchSpawn(ent);
    
    // Post-configure prop.
    AcceptEntityInput(ent, "DisableDamageForces");
    AcceptEntityInput(ent, "DisableShadow");
    
    // Orient and teleport prop.
    decl Float:vec[3];
    GetAngleVectors(ang, vec, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(vec, force);
    TeleportEntity(ent, pos, ang, vec);
  }  
  else
  {
    LogError("[VSH-ZF] fxCreateModelThrown (%s, %d) failed.", strModel, client);  
  }
  
  return ent;
}

stock fxCreateModelStatic(
  const String:strModel[],
  client,
  bool:isOwned = true,
  bool:isSolid = false,  
  const Float:pos[3] = {0.0, ...},
  const Float:ang[3] = {0.0, ...},
  const color[3] = {255, ...})
{
  new ent = CreateEntityByName("prop_dynamic_override");
  if(IsValidEntity(ent))
  {   
    // Pre-configure prop.
    SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", (isOwned ? client : -1));
    SetEntProp(ent, Prop_Send, "m_hEffectEntity", 0); // Hijack prop to store custom state.
    DispatchKeyValue(ent, "Solid", (isSolid ? "6" : "0"));
    SetEntPropFloat(ent, Prop_Data, "m_flFriction", 10000.0);
    SetEntityModel(ent, strModel);
    SetEntityRenderColor(ent, color[0], color[1], color[2], 255);
           
    // Spawn prop.
    DispatchSpawn(ent);
    
    // Post-configure prop.
    AcceptEntityInput(ent, "DisableDamageForces");
    AcceptEntityInput(ent, "DisableShadow");    
    
    // Orient and teleport prop.
    TeleportEntity(ent, pos, ang, NULL_VECTOR);
  }  
  else
  {
    LogError("[VSH-ZF] fxCreateModelStatic (%s, %d) failed.", strModel, client);  
  }
  
  return ent;
}

stock fxDeleteModel(ent)
{
  if(fxIsModelValid(ent))
    AcceptEntityInput(ent, "Kill");
}

stock bool:fxIsModelValid(ent)
{
  return (ent > 0) && IsValidEdict(ent) && IsValidEntity(ent) && 
    (entClassnameContains(ent, "prop_physics_multiplayer") || 
     entClassnameContains(ent, "prop_dynamic")); 
}

////////////////////////////////////////////////////////////
//
// Particle Utils
// (Original Code by J-Factor)
//
////////////////////////////////////////////////////////////
stock fxCreateParticle(
  const String:strPart[], 
  target, 
  ZFParticleAttachStyle:attachStyle,
  Float:duration = 0.0,
  const Float:posOffset[3] = {0.0, ...})
{
  new ent = CreateEntityByName("info_particle_system");
  if(IsValidEntity(ent))
  {
    // Get target position and add offset.
    decl Float:pos[3];
    GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
    AddVectors(pos, posOffset, pos);    

    // Configure particle system.
    TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
    DispatchKeyValue(ent, "effect_name", strPart);

    // Attach particle system according to attachStyle.
    if(attachStyle != AttachNone)
    {
      SetVariantString("!activator");
      AcceptEntityInput(ent, "SetParent", target, ent, 0);            
      
      if(attachStyle == AttachHead)
      {
        SetVariantString("head");
        AcceptEntityInput(ent, "SetParentAttachmentMaintainOffset", ent, ent, 0);                
      }
      if(attachStyle == AttachBack)
      {
        SetVariantString("flag");
        AcceptEntityInput(ent, "SetParentAttachmentMaintainOffset", ent, ent, 0);              
      }
    }

    // Spawn and activate particle system.
    DispatchSpawn(ent);
    ActivateEntity(ent);
    AcceptEntityInput(ent, "Start");

    // Handle delayed removal. Non-positive duration implies infinite lifespan.
    if(duration > 0.0)
    {
      decl String:strAddOutput[64];
      Format(strAddOutput, sizeof(strAddOutput), "OnUser1 !self:kill::%f:1", duration);
      SetVariantString(strAddOutput);
      AcceptEntityInput(ent, "AddOutput");
      AcceptEntityInput(ent, "FireUser1");    
    }
  }
  else
  {
    LogError("[VSH-ZF] fxCreateParticle (%s, %d) failed.", strPart, target);  
  }

  return ent;  
}

stock fxDeleteParticle(ent)
{
  if(fxIsParticleValid(ent))
    AcceptEntityInput(ent, "Kill");
}

stock fxStartParticle(ent)
{
  if(fxIsParticleValid(ent))
    AcceptEntityInput(ent, "Start");
}

stock fxStopParticle(ent)
{
  if(fxIsParticleValid(ent))
    AcceptEntityInput(ent, "Stop");
}

stock bool:fxIsParticleValid(ent)
{ return (ent > 0) && IsValidEdict(ent) && IsValidEntity(ent) && entClassnameContains(ent, "info_particle_system"); }

////////////////////////////////////////////////////////////
//
// Sprite Utils
// (Original Code by Nut)
//
////////////////////////////////////////////////////////////
stock fxCreateSprite(
  const String:strSprite[], 
  target, 
  &entSpr, 
  &entAnc)
{
  //
  // Create a networked sprite attached to a player's head.
  // This is done by parenting a sprite to a false 'anchor' prop, and then
  // parenting the anchor to a target. While the anchor will not be visible,
  // the sprite will be. Furthermore, since the sprite is parented to a 
  // networked entity, an extension like SDKHooks can be used to selectively
  // display the sprite to an arbitrary set of clients.
  //
  entSpr = CreateEntityByName("env_sprite");
  if(IsValidEntity(entSpr))
  {  
    entAnc = CreateEntityByName("prop_physics_multiplayer");
    if(IsValidEntity(entAnc))
    {
      decl String:strSprTargetname[32]; 
      decl String:strAncTargetname[32];
      decl String:strTgtTargetname[32];
      Format(strSprTargetname, sizeof(strSprTargetname), "zfspr%i", entSpr);
      Format(strAncTargetname, sizeof(strAncTargetname), "zfanc%i", entAnc);
      Format(strTgtTargetname, sizeof(strTgtTargetname), "zftgt%i", target);
      
      // Retrieve target's position
      decl Float:posTgt[3];
      GetEntPropVector(target, Prop_Send, "m_vecOrigin", posTgt);
      posTgt[2] += 12.0;
         
      // Configure target.
      DispatchKeyValue(target, "targetname", strTgtTargetname);
        
      // Configure and spawn anchor.
      DispatchKeyValue(entAnc, "targetname", strAncTargetname);
      DispatchKeyValue(entAnc, "parentname", strTgtTargetname);
      SetEntityMoveType(entAnc, MOVETYPE_NOCLIP);
      SetEntityModel(entAnc, ZFMDL_PRESENT[0]);
      SetEntityRenderMode(entAnc, RENDER_TRANSCOLOR);
      SetEntityRenderColor(entAnc, 0, 0, 0, 0);     
      DispatchSpawn(entAnc);
      
      // Configure and spawn sprite.
      DispatchKeyValue(entSpr, "targetname", strSprTargetname);
      DispatchKeyValue(entSpr, "parentname", strAncTargetname);    
      DispatchKeyValue(entSpr, "model", strSprite);
      DispatchKeyValue(entSpr, "classname", "env_sprite");
      DispatchKeyValue(entSpr, "spawnflags", "1");
      DispatchKeyValue(entSpr, "scale", "0.1");
      DispatchKeyValue(entSpr, "rendermode", "1");
      DispatchKeyValue(entSpr, "rendercolor", "255 255 255");
      DispatchSpawn(entSpr);
      
      // Teleport sprite and anchor to target.
      TeleportEntity(entSpr, posTgt, NULL_VECTOR, NULL_VECTOR);
      TeleportEntity(entAnc, posTgt, NULL_VECTOR, NULL_VECTOR);
      
      // Parent sprite to anchor.
      SetVariantString(strAncTargetname);
      AcceptEntityInput(entSpr, "SetParent", entSpr, entSpr, 0);
      
      // Parent anchor to target.
      AcceptEntityInput(entAnc, "DisableMotion");
      AcceptEntityInput(entAnc, "DisableShadow");
      SetVariantString(strTgtTargetname);
      AcceptEntityInput(entAnc, "SetParent", entAnc, entAnc, 0);
      SetVariantString("head");
      AcceptEntityInput(entAnc, "SetParentAttachmentMaintainOffset", entAnc, entAnc, 0);
    }
    else
    {
      LogError("[VSH-ZF] fxCreateSprite(entAnc) (%s, %d) failed.", strSprite, target);  
    }
  }
  else
  {
    LogError("[VSH-ZF] fxCreateSprite(entSpr) (%s, %d) failed.", strSprite, target);
  }
}

stock fxDeleteSprite(entSpr, entAnc)
{
  if(fxIsSpriteValid(entSpr, entAnc))
  { 
    AcceptEntityInput(entSpr, "Kill");
    AcceptEntityInput(entAnc, "Kill");
  }
}

stock fxShowSprite(entSpr, entAnc)
{
  if(fxIsSpriteValid(entSpr, entAnc))
    AcceptEntityInput(entSpr, "ShowSprite");    
}

stock fxHideSprite(entSpr, entAnc)
{
  if(fxIsSpriteValid(entSpr, entAnc))
    AcceptEntityInput(entSpr, "HideSprite");    
} 

stock bool:fxIsSpriteValid(entSpr, entAnc)
{ 
  return (entSpr > 0) && IsValidEdict(entSpr) && IsValidEntity(entSpr) && entClassnameContains(entSpr, "env_sprite") &&
         (entAnc > 0) && IsValidEdict(entAnc) && IsValidEntity(entAnc) && entClassnameContains(entAnc, "prop_physics_multiplayer");
}

////////////////////////////////////////////////////////////
//
// Sound Base Utils
//
////////////////////////////////////////////////////////////
stock fxCreateSoundToAll(const String:strSound[], entity)
{ 
  EmitSoundToAll(strSound, entity); 
}

stock fxCreateSoundToClient(const String:strSound[], client)
{
  EmitSoundToClient(client, strSound);
}


////////////////////////////////////////////////////////////
// enum SolidFlags_t
// {
//     FSOLID_CUSTOMRAYTEST        = 0x0001,    // Ignore solid type + always call into the entity for ray tests
//     FSOLID_CUSTOMBOXTEST        = 0x0002,    // Ignore solid type + always call into the entity for swept box tests
//     FSOLID_NOT_SOLID            = 0x0004,    // Are we currently not solid?
//     FSOLID_TRIGGER              = 0x0008,    // This is something may be collideable but fires touch functions
//                                              //   even when it's not collideable (when the FSOLID_NOT_SOLID flag is set)
//     FSOLID_NOT_STANDABLE        = 0x0010,    // You can't stand on this
//     FSOLID_VOLUME_CONTENTS      = 0x0020,    // Contains volumetric contents (like water)
//     FSOLID_FORCE_WORLD_ALIGNED  = 0x0040,    // Forces the collision rep to be world-aligned even if it's SOLID_BSP or SOLID_VPHYSICS
//     FSOLID_USE_TRIGGER_BOUNDS   = 0x0080,    // Uses a special trigger bounds separate from the normal OBB
//     FSOLID_ROOT_PARENT_ALIGNED  = 0x0100,    // Collisions are defined in root parent's local coordinate space
//     FSOLID_TRIGGER_TOUCH_DEBRIS = 0x0200,    // This trigger will touch debris objects
// 
//     FSOLID_MAX_BITS    = 10
// };
// 
// /**
//  * Gets the solid flags of the entity
//  *
//  * @param entity            Entity index.
//  * @return                    Solid Flags.
//  */
// stock SolidFlags_t:Entity_GetSolidFlags(entity)
// {
//     return SolidFlags_t:GetEntProp(entity, Prop_Send, "m_usSolidFlags", 2);
// }
// 
// /**
//  * Checks whether certain solid flags are set on th entity.
//  *
//  * @param entity            Entity index.
//  * @param flags                Solid Flags.
//  * @return                    True if the specified flags are set, false otherwise.
//  */
// stock bool:Entity_SolidFlagsSet(entity, SolidFlags_t:flagMask)
// {
//     return bool:(Entity_GetSolidFlags(entity) & flagMask);
// }
// 
// enum SolidType_t
// {
//     SOLID_NONE           = 0,    // no solid model
//     SOLID_BSP            = 1,    // a BSP tree
//     SOLID_BBOX           = 2,    // an AABB
//     SOLID_OBB            = 3,    // an OBB (not implemented yet)
//     SOLID_OBB_YAW        = 4,    // an OBB, constrained so that it can only yaw
//     SOLID_CUSTOM         = 5,    // Always call into the entity for tests
//     SOLID_VPHYSICS       = 6,    // solid vphysics object, get vcollide from the model and collide with that
//     SOLID_LAST,
// };
// 
// /**
//  * Gets the solidity type of the entity
//  *
//  * @param entity            Entity index.
//  * @return                    Solid Type
//  */
// stock SolidType_t:Entity_GetSolidType(entity)
// {
//     return SolidType_t:GetEntProp(entity, Prop_Send, "m_nSolidType", 1);
// }
// 
// /**
//  * Checks whether the entity is solid or not.
//  *
//  * @param entity            Entity index.
//  * @return                    True if the entity is solid, false otherwise.
//  */
// stock bool:Entity_IsSolid(entity)
// {
//     return (Entity_GetSolidType(entity) != SOLID_NONE &&
//             !Entity_SolidFlagsSet(entity, FSOLID_NOT_SOLID));
// }  
////////////////////////////////////////////////////////////
