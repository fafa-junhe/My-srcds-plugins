#if defined _ZF_PERK_INC
#endinput
#endif
#define _ZF_PERK_INC

#include "zf_util_base.inc"
#include "zf_util_fx.inc"
#include "zf_util_pref.inc"

//
// Perk Objects
//
#define ZF_PERK_NONE            0
  
// Survivor perks
#define TOTAL_SUR_PERKS 23
#define ZF_PERK_ATHLETIC        1
#define ZF_PERK_CARPENTER       2
#define ZF_PERK_CHARITABLE      3 
#define ZF_PERK_COWARDLY        4 
#define ZF_PERK_FRIEND          5 
#define ZF_PERK_HEROIC          6 
#define ZF_PERK_HOLY            7
#define ZF_PERK_JUGGERNAUT      8
#define ZF_PERK_LEADER          9 
#define ZF_PERK_NINJA           10
#define ZF_PERK_NONLETHAL       11
#define ZF_PERK_RESOURCEFUL     12
#define ZF_PERK_SELFLESS        13
#define ZF_PERK_STASH           14
#define ZF_PERK_STIRCRAZY       15
#define ZF_PERK_SUPPLIER        16
#define ZF_PERK_TANTRUM         17
#define ZF_PERK_TRAITOR         18
#define ZF_PERK_TRAPPER         19
#define ZF_PERK_TURTLE          20
#define ZF_PERK_WISE            21
#define ZF_PERK_ZENLIKE         22

new String:ZF_SURPERK_NAME[TOTAL_SUR_PERKS][] = 
{ "不选择",
  "运动员", "木工", "慈善家", "懦夫", "同伴", "英雄", "牧师",
  "守护神", "指挥官", "忍者", "猛男", "拾荒者", "圣徒",
  "资本家", "狂人", "供应商", "暴怒", "叛徒", "猎人", "石兽",
  "智者", "禅师" };

new String:ZF_SURPERK_SHORTDESC[TOTAL_SUR_PERKS][] =
{  
  "不选择",
  "运动员: 游刃有余，移动、攻击速度更高.",
  "木工: 天工开物，修筑路障.",
  "慈善家: 慷慨解囊，杀敌后获得礼物.",
  "懦夫: 知难而退，受伤获得加速.",
  "同伴: 同舟共济，共同获得增益.",
  "英雄: 孤军奋战，存活到最后以获收益.",
  "牧师: 心虔志诚，祈祷以获得生命值",
  "守护神: 呼神护卫，用低速换取高攻.",
  "指挥官: 运筹帷幄，设置军旗获得群体加成.",
  "忍者: 飞檐走壁，获得跳跃加成与闪回.",
  "猛男：不怒自威，以低攻子弹换取击退效果.",
  "拾荒者: 生生不息，可以从杀人和拾取中获得再补给.",
  "圣徒: 无私奉献，死亡时引爆自己.",
  "资本家: 深谋远虑，隐藏物资获得后期补给.",
  "狂人: 雷厉风行，速度就是力量.",
  "供应商: 后勤援助，可以放置补给箱.",
  "暴怒: 义愤填膺，倾泄怒火获得增益.",
  "叛徒: 笑里藏刀，背叛你的团队.",
  "猎人: 守株待兔，放置地雷.",
  "石兽: 勇敢无畏，以低速换取高防.",
  "智者: 厚积薄发，可以通过战斗升级.",
  "禅师: 参禅悟道，可以通过冥想回血."
  };
//"0xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx2xxxxxxxxxxxxxxx\n3xxxxxxxxxxxxxxx4xxxxxxxxxxxxxxx5xxxxxxxxxxxxxxx\n6xxxxxxxxxxxxxxx7xxxxxxxxxxxxxxx8xxxxxxxxxxxxxxx\n9xxxxxxxxxxxxxxxAxxxxxxxxxxxxxxxBxxxxxxxxxxxxxxx\nCxxxxxxxxxxxxxxxDxxxxxxxxxxxxxxxExxxxxxxxxxxxxxx\nFxxxxxxxxxxxxxxxGxxxxxxxxxxxxxxxHxxxxxxxxxxxxxxx\nIxxxxxxxxxxxxxxxJxxxxxxxxxxxxxxxKxxxxxxxxxxxxxxx\nLxxxxxxxxxxxxxxxMxxxxxxxxxxxxxxxNxxxxxxxxxxxxxxx\n",
new String:ZF_SURPERK_LONGDESC[TOTAL_SUR_PERKS][] = 
{
  "",
  "你有移动速度和攻击速度加成. \n你的攻击力减弱，而且没有暴击.",
  "你有防御加成。   \n你的攻击力减弱. 发医生语音，来建造一个\n有 350 血量的路障，敌我均可破坏\n 技能冷却时间为25秒.",
  "每个击杀和助攻都可转为 '礼物点数.' 发医生语音  \n来兑换一个礼物给其他的幸存者   \n礼物能给予不同的临时奖励.",  
  "你有被动技能 '恐慌'，当你被攻击时,   \n你能获得额外的速度加成和防御加成.   \n恐慌能力持续10秒，冷却时间25秒.",  
  "发医生语音以设置同伴   \n(在准备时间内看着目标).  \n否则随机选择一人成为同伴. \n当你靠近同伴时，你会获得攻击和生命回复加成. \n当你和同伴击杀或助攻时，你就会增加暴击时间. \n同伴死亡时，你就会暴击",
  "你有防御和攻击加成。\n你的暴击时间由你的击杀数和助攻数决定. \n当你是最后一个幸存者时,暴击就会激活", 
  "你的攻击力减弱. \n当蹲下不移动时,你可以治疗自己和周围的幸存者.",
  "你有防御和攻击加成, 你的移动速度被削弱. \n你对掉落伤害免疫. \n如果你在僵尸附近掉落时    \n僵尸会受到轻微的伤害和击退以及击晕.",
  "你有暴击加成,也会给附近的幸存者提供防御和攻击提升. \n发医生语音，来放置一个集会点. \n所有幸存者靠近你的集合点时都会获得攻击和防御加成. \n集会点持续60秒，冷却时间为120秒.",
  "你有速度和跳跃加成，你的攻击力被削弱. \n发医生语言来放置一个撤退点. \n当你受到攻击, 你将会被传送到撤退点. \n撤退点会保留15秒，冷却时间为30秒.", 
  "你的攻击力被削弱，\n当使用子弹类武器时，伤害减少，击退效果增加.",
  "你能从击杀中获取弹药, 生命, 和金属.  \n你能获取从弹药包获取临时攻击加成 \n从医疗包获取临时防御加成.",
  "你死后会爆炸.",
  "发医生语音来放置藏身处. \n藏身处不可以靠近幸存者或其他藏身处放置.\n藏身处给予弹药,生命,和临时加成. \n持续时间30秒，冷却时间30秒.",
  "你得到一个与你移动速度成正比的攻击加成.",
  "你的弹药会周期性的补充,并拥有两倍弹夹   \n发医生语音来放置补给箱. \n其他幸存者可以从中补给弹药. \n冷却时间为10秒.",
  "发医生语音来倾斜怒火. \n发怒给予 15秒 的必然暴击.\n冷却时间为30秒,效果结束后移速削弱.",
  "你的暴击几率被削弱. \n你给予暴击加成给附近的僵尸. \n当还剩2名幸存者时, 你会使另外一个幸存者中毒.", 
  "发医生语音来放置地雷.\n最多放3个地雷.\n技能有30s的冷却时间.", 
  "你有防御值加成.\n你的攻击力减弱，而且没有暴击.\n你免疫背刺.",
  "你每个击杀或者助攻都能使你的伤害永久提高. \n你的近战击中能使你的防御提高.",
  "当你蹲着不动时, 你会回血并积攒暴击几率.\n每个击杀后都会减少暴击几率."
};

// Zombie perks
#define TOTAL_ZOM_PERKS 19
#define ZF_PERK_ALPHA           1 
#define ZF_PERK_COMBUSTIBLE     2 
#define ZF_PERK_HORRIFYING      3
#define ZF_PERK_HUNTER          4 
#define ZF_PERK_LEAP            5 
#define ZF_PERK_MAGNETIC        6
#define ZF_PERK_MARKED          7
#define ZF_PERK_RAGE            8
#define ZF_PERK_ROAR            9 
#define ZF_PERK_SCORCHING       10
#define ZF_PERK_SICK            11
#define ZF_PERK_SWARMING        12
#define ZF_PERK_TARRED          13
#define ZF_PERK_THIEVING        14
#define ZF_PERK_TOXIC           15
#define ZF_PERK_VAMPIRIC        16
#define ZF_PERK_VINDICTIVE      17
#define ZF_PERK_TANK      18

new String:ZF_ZOMPERK_NAME[TOTAL_ZOM_PERKS][] =
{ "不选择",
  "零号病人", "自爆者", "梦魇", "捕食者", "飞跃者", "魅影", "鹰隼",
  "屠夫", "猛兽", "自燃者", "腐蚀者", "招魂人", "黏虫", "盗贼",
  "瘟疫", "吸血鬼", "杀人狂" ,"Tank"};

new String:ZF_ZOMPERK_SHORTDESC[TOTAL_ZOM_PERKS][] =
{
  "不选择",
  "零号病人：位尊权贵，召唤仆人辅助战斗。",
  "自爆者：以命相搏，被远程击杀后自爆。",
  "梦魇：狰狞恫吓，削弱敌人的攻击。",
  "捕食者：饿虎擒羊，放置你的重生点。",
  "飞跃者：蓄势待发，获得飞跃技能。",
  "魅影：狡黠诡诈，使地雷和建筑失效。",
  "鹰隼：倾力直击，设置目标集中火力。",
  "屠夫：凶残血腥，获得移速与血量加成。",
  "猛兽：咆哮雷霆，震慑你的敌人。",
  "自燃者：引火自焚，使你的敌人着火.",
  "腐蚀者：腐溃糜烂，吐出腐蚀性液体。",
  "招魂人：本职业已废。",
  "黏虫：粘黏捆缚，吐出粘液减缓敌人移速。",
  "盗贼：偷取子弹和武器。",
  "瘟疫：疠疫弥散，使敌人中毒。",
  "吸血鬼：纵享腥甜，获得吸血加成。",
  "杀人狂：嗜血成性，通过击杀获得加成。",
  "Tank：舍身为人，用膜法提升友军防御。"
  };
//"0xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx2xxxxxxxxxxxxxxx\n3xxxxxxxxxxxxxxx4xxxxxxxxxxxxxxx5xxxxxxxxxxxxxxx\n6xxxxxxxxxxxxxxx7xxxxxxxxxxxxxxx8xxxxxxxxxxxxxxx\n9xxxxxxxxxxxxxxxAxxxxxxxxxxxxxxxBxxxxxxxxxxxxxxx\nCxxxxxxxxxxxxxxxDxxxxxxxxxxxxxxxExxxxxxxxxxxxxxx\nFxxxxxxxxxxxxxxxGxxxxxxxxxxxxxxxHxxxxxxxxxxxxxxx\nIxxxxxxxxxxxxxxxJxxxxxxxxxxxxxxxKxxxxxxxxxxxxxxx\nLxxxxxxxxxxxxxxxMxxxxxxxxxxxxxxxNxxxxxxxxxxxxxxx\n",
new String:ZF_ZOMPERK_LONGDESC[TOTAL_ZOM_PERKS][] = 
{
  "",  
  "你能通过击杀幸存者或为奴仆助攻来召唤新的奴仆 \n当你靠近其他僵尸或者奴仆时，能获得生命恢复和攻击加成 \n发医生语音来召唤最多4个奴仆，冷却时间15秒。",
  "你的防御力减弱。\n被远程武器击杀时，你将自爆造成伤害。 \n你不可以使用隐身手表或者原子能饮料！",
  "你的近战攻击附带减弱射速与防御力的效果。 \n你死亡后，技能效果消失。",
  "发医生语音来放置你的下一个出生点 \n于出生点重生时获得临时攻击加成与重生时间减免 \n技能在每次重生后可使用一次。",
  "你的攻击力与防御力减弱，但免受坠落伤害 \n发医生语音来执行飞跃，技能冷却时间为4秒。",
  "你能使附近的步哨和地雷失效.",
  "随机选择一名幸存者作为你的目标。\n你将增加对目标的伤害，削减对他人的伤害。 \n当前目标死亡后，若剩余的幸存者超过2个，将自动选择新目标。",
  "发医生语音激活杀意。 \n杀意使你获得150％生命和速度加成， \n生命低于80％，杀意无效。",
  "发医生语音来发出咆哮。 \n咆哮造成击退与临时防御削弱，冷却时间为15秒。",
  "你的攻击力减弱。你有速度加成，并对火焰伤害免疫。\n幸存者撞到你或被你近战命中时会着火。 \n你不可以使用原子能饮料。",
  "你的防御力减弱。发医生语音来吐出酸液。\n酸液持续35s或直到你死亡。 \n造成的伤害与你和酸液之间的距离成正比。",
  "你有移速加成。你的攻击和防御力减弱。 \n你能使自己与身边队友快速重生。[由于这服务器已经开启快速重生了所以没必要选这一个]",
  "发医生语音来吐出粘液。 \n粘液有减速效果，持续30秒或直到你死亡。 \n你的近战攻击附带减速效果。",
  "你的攻击力减弱。\n你的近战攻击可以偷取敌人弹药、金属与uber。 \n如果目标主武器没有弹药，你就可以偷走并使用有部分弹药的主武器。",
  "你的攻击力减弱。 \n当你造成近战伤害或被近战攻击时，对方将染毒。 \n当你不移动时, 你会对附近的幸存者造成伤害。",
  "你有回血加成。 \n你的攻击附带吸血效果。",
  "你的击杀与助攻能使你获得永久性攻击和防御加成。",
  "你的防御+50％ \n 你的伤害削弱至34% \n 你的移速削弱至30％ \n 释放技能以设置青蛙，为附近友军提升防御但会降低移速。"
};
  
//
// Perk Bonus Objects
//

//
// Perk Gameplay Objects
//
const ZF_CRIPPLE_DURATION = 45;             // Amount of time cripple condition lasts.
const ZF_DAZE_DEFEND = -40;                 // Defense penalty when dazed.
const ZF_POISON_DAMAGE = 5;                 // Amount of poison damage (per sec).
const ZF_POISON_HEAL_MEDIC = 3;             // Amount of poison healed (per sec) by medic healing.
const ZF_POISON_HEAL_MEDPACK = 5;           // Amount of poison healed by medpack pickup.
const ZF_POISON_HEAL_UBER = 100;            // Amount of poison healed when ubered.

// Survivor perks
const ZF_ATHLETIC_ATTACK = -33;             // Innate attack penalty.
const ZF_ATHLETIC_CRIT = -100;              // Innate crit penalty.
const ZF_ATHLETIC_ROF = 100;                // Innate rate of fire bonus.
const ZF_ATHLETIC_SPEED = 100;              // Innate speed bonus.
const CARPENTER_ATTACK = -50;               // Innate attack penalty.
const CARPENTER_DEFEND = 25;                // Innate defense bonus.
const CARPENTER_BARRICADE_HEALTH = 350;     // Health of each barricade.
const CARPENTER_COOLDOWN = 25;              // Duration after barricade is placed before a new one can be placed.
const CARPENTER_MAX_ITEMS = 3;              // Maximum number of barricades that can be active at one time.
const CARPENTER_DROP_RADSQ_BARRICADE = (250 * 250); // Radius (squared) inwhich no barricades must be to place barricade.
const CARPENTER_DROP_RADSQ_CLIENT = (150 * 150);    // Radius (squared) inwhich no other players must be to place barricade.
const ZF_CHARITABLE_MAX_ITEMS = 5;          // Maximum number of gifts that can be active at one time.
const ZF_CHARITABLE_POINTS_ASSIST = 1;      // Points earned per assist.
const ZF_CHARITABLE_POINTS_KILL = 3;        // Points earned per kill.
const ZF_CHARITABLE_POINTS_GIFT = 6;        // Points needed to toss gift.
const ZF_CHARITABLE_GIFT_BONUS_HEALTH = 50; // Health gained by gift owner when gift is picked up.
const ZF_CHARITABLE_GIFT_BONUS_MIN = 25;    // Minimum gift bonus strength.
const ZF_CHARITABLE_GIFT_BONUS_MAX = 75;    // Maximum gift bonus strength.
const ZF_CHARITABLE_GIFT_DURATION = 30;     // Duration of gift bonuses.
const ZF_COWARDLY_DEFEND = 85;              // Defense bonus when scared.
const ZF_COWARDLY_SPEED = 100;              // Speed bonus when scared.
const ZF_COWARDLY_DURATION_SCARED = 10;     // Duration of scared state after being hit.
const ZF_COWARDLY_DURATION_COOLDOWN = 25;   // Duration after scared state ends before scared state is again possible.
const ZF_FRIEND_ATTACK = 50;                // Attack bonus when near friend.
const ZF_FRIEND_REGEN = 10;                 // Regen bonus when near friend.
const ZF_FRIEND_CRITTIME_INIT = 5;          // Starting crit time.
const ZF_FRIEND_CRITTIME_KILL = 8;          // Crit time added per kill.
const ZF_FRIEND_CRITTIME_ASSIST = 5;        // Crit time added per assist.
const ZF_FRIEND_RADIUSSQ = (400 * 400);     // Radius (squared) inwhich passive bonuses apply.
const HEROIC_COMBAT = 25;                   // Combat bonus when using perk.
const HEROIC_CRITTIME_INIT = 20;            // Starting crit time.
const HEROIC_CRITTIME_KILL = 10;            // Crit time added per kill.
const HEROIC_CRITTIME_KILL_ACTIVE = 2;      // Crit time added per kill when crittime is active.
const HEROIC_CRITTIME_ASSIST = 5;           // Crit time added per assist.
const HEROIC_CRITTIME_ASSIST_ACTIVE = 1;    // Crit time added per assist when crittime is active.
const ZF_HOLY_ATTACK = -50;                 // Attack penalty when using perk.
const ZF_HOLY_RADIUSSQ = (400 * 400);       // Radius (squared) inwhich regen bonuses apply.
const ZF_HOLY_REGEN = 5;                    // Regen bonus for nearby survivors.
const ZF_JUGGERNAUT_ATTACK = 25;            // Attack bonus when using perk.
const ZF_JUGGERNAUT_DEFEND = 50;            // Defense bonus when using perk.
const Float:ZF_JUGGERNAUT_FORCE = 500.0;    // Knockback force for nearby zombies when fall damage taken / on melee hit.
const ZF_JUGGERNAUT_RADIUS = 250;           // Radius inwhich fall damage causes stun.
const ZF_JUGGERNAUT_SPEED = -100;           // Speed penalty when using perk.
const Float:ZF_JUGGERNAUT_STUN_DURATION = 2.0; // Duration of stun on melee hit or when fall damage taken.
const Float:ZF_JUGGERNAUT_STUN_SLOWDOWN = 0.5; // Slowdown of stun on melee hit or when fall damage taken.
const ZF_LEADER_SELF_CRIT = 25;                // Crit bonus when using perk.
const ZF_LEADER_OTHERS_ATTACK = 25;            // Attack bonus for survivors near perk user.
const ZF_LEADER_OTHERS_RADIUSSQ = (350 * 350); // Radius (squared) inwhich passive bonuses are applied.
const ZF_LEADER_RALLY_SELF_ATTACK = 10;        // Attack bonus for user per survivor near rally point.
const ZF_LEADER_RALLY_SELF_DEFEND = 5;         // Defense bonus for user per survivor near rally point.
const ZF_LEADER_RALLY_OTHERS_ATTACK = 25;      // Attack bonus for survivors near rally point.
const ZF_LEADER_RALLY_OTHERS_DEFEND = 20;      // Defense bonus for user per survivor near rally point.
const ZF_LEADER_RALLY_DURATION = 60;           // Duration after rally is placed before it expires.
const ZF_LEADER_RALLY_COOLDOWN = 120;          // Duration after rally is placed before it can be replaced.
const ZF_LEADER_RALLY_RADIUSSQ = (400 * 400);  // Radius (squared) inwhich rally bonuses apply.
const ZF_NINJA_ATTACK = -33;                // Attack penalty when using perk.
const ZF_NINJA_SPEED = 50;                  // Speed bonus using perk.
const ZF_NINJA_DURATION_DECOY_ACTIVE = 15;  // Duration of decoy retreat point lifetime.
const ZF_NINJA_DURATION_DECOY_DECAY = 5;    // Duration of decoy before it poofs.
const ZF_NINJA_DURATION_COOLDOWN = 30;      // Duration after decoy before new decoy can be used.
const ZF_NINJA_FALLDMG_RESIST = 50;         // Percentage of fall damage resistance.
const Float:ZF_NINJA_FORCE = 600.0;         // Jump force.
const ZF_NONLETHAL_ATTACK_BULLET = -75;     // Attack penalty when using perk and bullet-based weapon.
const Float:ZF_NONLETHAL_FORCE = 25.0;      // Base force applied per bullet-based attack.
const Float:ZF_RESOURCEFUL_AMMOPCT = 0.20;  // Percent of ammo received per kill.
const ZF_RESOURCEFUL_ATTACK = 25;           // Attack bonus (temporary) when grabbing an ammopack.
const ZF_RESOURCEFUL_DEFEND = 25;           // Defense bonus (temporary) when grabbing a medpack.
const ZF_RESOURCEFUL_HEALTH = 25;           // Health gained per kill (up to max).
const ZF_RESOURCEFUL_HEALTH_OVERHEAL = 15;  // Additional health gained per kill (overheal possible).
const ZF_RESOURCEFUL_METAL = 25;            // Amount of metal received per kill.
const ZF_RESOURCEFUL_PICKUP_DURATION = 10;  // Duration of temporary bonuses from pickups.
const ZF_SELFLESS_DAMAGE = 1000;            // Explosion damage applied to zombies on death.
const ZF_SELFLESS_RADIUS = 500;             // Radius of explosion.
const STASH_GRAB_ATTACK_DURATION = 45;      // Duration of temporary bonuses from grabbing stash.
const STASH_GRAB_ATTACK_PERM = 10;          // Permanent attack bonus from grabbing stash.
const STASH_GRAB_ATTACK_TEMP = 100;         // Temporary attack bonus from grabbing stash.
const STASH_GRAB_HEALTH = 200;              // Health bonus from grabbing stash.
const STASH_COOLDOWN = 30;                  // Duration after stash becomes ready before a new stash can be placed.
const STASH_WARMUP = 40;                    // Duration after placing stash before it becomes ready.
const STASH_GRAB_RADSQ = (50 * 50);         // Radius (squared) inwhich you must be to grab stash.
const STASH_DROP_RADSQ_STASH = (200 * 200); // Radius (squared) inwhich no other stashes must exist in order to place new stash.
const STASH_DROP_RADSQ_CLIENT = (800 * 800);// Radius (squared) inwhich no other survivors must exist in order to place new stash.
const ZF_STIRCRAZY_MAX_POINTS = 5;          // Number of previous positions used to calculate average position.
const ZF_STIRCRAZY_DIST_MIN = 150;          // Minimum distance from average of last X positions overwhich bonuses apply.
const ZF_STIRCRAZY_DIST_MAX = 750;          // Maximum distance from average of last X positions overwhich no further bonuses apply.
const ZF_STIRCRAZY_ATTACK = 200;            // Attack bonus when ZF_STIRCRAZY_DIST_MAX is reached.
const ZF_SUPPLIER_MAX_ITEMS = 2;            // Maximum number of supply boxes that can be active at once.
const ZF_SUPPLIER_TIMER = 10;               // Duration after supplies are placed before supplies can be placed again.          
const ZF_SUPPLIER_RADIUSSQ = (75 * 75);     // Radius (squared) inwhich supplies are picked up.
const ZF_SUPPLIER_UPDATERATE = 10;          // Period (in s) of self-resupply.
const Float:ZF_SUPPLIER_AMMOPCT_RESLIMIT = 2.0; // Primary and secondary ammo reserve limit.
const Float:ZF_SUPPLIER_AMMOPCT_SELF = 0.10;    // Percent of ammo (of standard maximum) received per self-resupply.
const Float:ZF_SUPPLIER_AMMOPCT_OTHER = 0.25;   // Percent of ammo (of standard maximum) received per resupply.
const ZF_SUPPLIER_RESUPPLY_COUNT = 4;       // Number of resupplies from each supply box.
const ZF_SUPPLIER_ATTACK = 25;              // Attack bonus for supplier when supplies picked up.
const ZF_SUPPLIER_DURATION = 10;            // Duration of bonuses for suppliers when supplies picked up.
const ZF_TANTRUM_ACTIVE = 15;               // Duration of anger (100% crit) state.
const ZF_TANTRUM_COOLDOWN = 30;             // Duration of tired (speed penalty) state.
const ZF_TANTRUM_SPEED = -100;              // Speed penalty given after perk use.
const ZF_TRAITOR_CRIT = -100;               // Crit penalty when using this perk.
const ZF_TRAITOR_CRIT_ZOM = 25;             // Crit bonus for nearby zombies.
const ZF_TRAITOR_POISON = 3;                // Poison damage applied per/s to other remaining survivor.
const ZF_TRAITOR_RADIUSSQ = (500 * 500);    // Radius (squared) inwhich zombie crit bonus applies.
const ZF_TRAPPER_MAX_ITEMS = 3;             // Maximum number of mines that can be active at once.
const ZF_TRAPPER_DAMAGE = 50;               // Damage done by trapper mines.
const ZF_TRAPPER_RADIUS = 200;              // Radius inwhich mines trigger and cause damage.
const ZF_TRAPPER_RADIUSSQ = (200 * 200);    // Radius (squared) inwhich mines trigger and cause damage.
const ZF_TRAPPER_TIMER = 15;                // Time between use of perk.
const ZF_TURTLE_ATTACK = -50;               // Attack penalty when using this perk.
const ZF_TURTLE_DEFEND = 50;                // Defense bonus when using this perk.
const ZF_TURTLE_SPEED = -100;               // Speed penalty when using perk.
const Float:ZF_TURTLE_STUN_DURATION = 0.5;  // Stun time when zombie backstabs perk user.
const ZF_WISE_ATTACK_KILL = 1;              // Attack bonus when killing a zombie.
const ZF_WISE_ATTACK_ASSIST = 1;            // Attack bonus when assisting in killing a zombie.
const ZF_WISE_DEFEND = 1;                   // Defense bonus when hit by a zombie.
const ZF_WISE_DEFEND_LIMIT = 10;            // Defense bonus threshold above which no defense bonus is granted.
const ZF_ZENLIKE_CRIT_INC = 1;              // Crit bonus gained when crouched and not moving.
const ZF_ZENLIKE_CRIT_DEC = 25;             // Crit bonus lost per shot.
const ZF_ZENLIKE_HEAL = 1;                  // Poison healed when crouched and not moving.
const ZF_ZENLIKE_REGEN = 1;                // Health regen bonus when crouched and not moving.

// Zombie perks
const ZF_ALPHA_RADIUSSQ = (500 * 500);      // Radius (squared) inwhich zombies provide attack and regen bonuses.
const ZF_ALPHA_ATTACK = 10;                 // Attack bonus per nearby non-minioned zombie.
const ZF_ALPHA_ATTACK_MINION = 25;          // Attack bonus per nearby minioned zombie.
const ZF_ALPHA_REGEN = 4;                   // Regen bonus per nearby non-minioned zombie.
const ZF_ALPHA_REGEN_MINION = 12;           // Regen bonus per nearby minioned zombie.
const ZF_ALPHA_SUMMON_LIMIT = 4;            // Maximum number of minions that can be summoned at once.
const ZF_ALPHA_TIMER_MINION = 15;           // Time between use of perk per zombie summoned.
const ZF_COMBUSTIBLE_DAMAGE = 100;          // Explosion damage done on death.
const ZF_COMBUSTIBLE_DAMAGE_HEAVY = 150;    // Explosion damage done on death for heavies. 
const ZF_COMBUSTIBLE_DEFEND = -200;         // Defense penalty for using perk.
const ZF_COMBUSTIBLE_RADIUS = 250;          // Radius of explosion.
const Float:ZF_COMBUSTIBLE_RESPAWNTIME = 4.5; // Respawn time when using perk.
const HORRIFYING_ATTACK = -20;              // Attack penalty per hit (non-heavies).
const HORRIFYING_ATTACK_HEAVY = -30;        // Attack penalty per hit (heavies).
const HORRIFYING_DEFEND = -10;              // Defense penalty per hit (non-heavies).
const HORRIFYING_DEFEND_HEAVY = -20;        // Defense penalty per hit (heavies).
const HORRIFYING_ROF_HEAVY = -10;           // Rate of fire penalty per hit (heavies).
const Float:HORRIFYING_PENALTYPCT_KILL = 0.75;   // Temp stat penalty reduction when killing perk user.
const Float:HORRIFYING_PENALTYPCT_ASSIST = 0.25; // Temp stat penalty reduction when assisting in killing perk user.
const HORRIFYING_DURATION = 15;             // Duration of per-hit penalties.
const HORRIFYING_DURATION_HEAVY = 30;       // Duration of per-hit penalties.
const ZF_HUNTER_ATTACK = 66;                // Attack bonus given when spawning on mark.
const ZF_HUNTER_DURATION = 10;              // Duration of spawn bonuses.
const ZF_HUNTER_RADIUSSQ = (85 * 85);       // Radius (squared) inwhich survivors will destroy a spawn mark.
const Float:ZF_HUNTER_RESPAWNTIME = 5.5;    // Respawn time when using perk.
const ZF_LEAP_COMBAT = -33;                 // Combat penalty when using perk.
const ZF_LEAP_COOLDOWN = 4;                 // Duration after leap before ability is ready.
const Float:ZF_LEAP_FORCE = 800.0;          // Leap force.
const Float:ZF_LEAP_FORCE_SCOUT = 1500.0;   // Leap force for scouts.
const ZF_MAGNETIC_RADIUSSQ = (500 * 500);   // Radius (squared) inwhich sentries are disabled.
const ZF_MARKED_ATTACK_ON_MARK = 200;       // Attack bonus when hitting marked target.
const ZF_MARKED_ATTACK_OFF_MARK = -25;      // Attack penalty when hitting non-marked target.
const ZF_MARKED_MIN_SURVIVORS = 3;          // The minimum amount of survivors that must be alive to select a mark.
const ZF_MARKED_TIMER = 15;                 // Time between old target death and new target selection.
const ZF_RAGE_COOLDOWN = 20;                // Duration after rage ends before ability is ready.
const ZF_RAGE_SPEED = 100;                  // Speed bonus when ability is active.
const Float:ZF_RAGE_HEALTHPCT_TOUSE = 0.80; // Percent of health above which ability can be activated.
const Float:ZF_RAGE_HEALTHPCT_ONUSE = 0.50; // Percent of health added when ability is activated.
const ZF_ROAR_COOLDOWN = 15;                // Time between use of perk.
const ZF_ROAR_DURATION = 20;                // Base duration of DAZED condition (non-heavies).
const ZF_ROAR_DURATION_HEAVY = 60;          // Base duration of DAZED condition (heavies).
const Float:ZF_ROAR_FORCE = 600.0;          // Knockback force for nearby survivors (non-heavies).
const Float:ZF_ROAR_FORCE_HEAVY = 1000.0;   // Knockback force for nearby survivors (heavies).
const ZF_ROAR_RADIUS = 450;                 // Radius inwhich knockback and defense penalties are applied.
const ZF_SCORCHING_ATTACK = -50;            // Attack penalty when using perk.
const ZF_SCORCHING_SPEED = 50;              // Speed bonus when using perk.
const ZF_SICK_MAX_ITEMS = 5;                // Maximum number of acid projectiles / puddles active at once.
const ZF_SICK_DEFEND = -50;                 // Defense penalty when using perk.
const ZF_SICK_DAMAGE = 6;                   // Base acid damage done to nearby survivors.
const ZF_SICK_DAMAGE_RADIUS = 125;           // Radius inwhich acid causes damamge.
const ZF_SICK_TIMER = 15;                   // Time between use of perk.
const ZF_SWARMING_COMBAT = -33;             // Combat penalty when using perk.
const ZF_SWARMING_RADIUSSQ = (200 * 200);   // Radius (squared) inwhich nearby zombies, when killed, get instant respawn.
const ZF_SWARMING_SPEED = 100;              // Speed bonus when using perk.
const Float:ZF_SWARMING_RESPAWNTIME = 0.5;  // Respawn time when using perk.
const ZF_TARRED_MAX_ITEMS = 5;              // Maximum number of oil projectiles / slicks active at once.
const ZF_TARRED_DURATION_MELEE = 10;        // Duration of slowing penalties for melee hits.
const ZF_TARRED_DURATION_SLICK = 30;        // Duration of slowing penalties for oil slick hits.
const ZF_TARRED_ROF = -20;                  // Rate of fire penalty on hit / when hit.
const ZF_TARRED_SPEED_MELEE = -50;          // Speed penalty on hit / when hit.
const ZF_TARRED_SPEED_SLICK = -3;           // Speed penalty on oil slick hit.
const ZF_TARRED_SPEED_LIMIT = -200;         // Speed penalty threshold below which no further speed penalties are granted.
const ZF_TARRED_TIMER = 30;                 // Time between use of perk.
const ZF_TARRED_RADIUS = 75;                // Radius inwhich oil causes slowing effects.
const Float:ZF_THIEVING_AMMOPCT = 0.30;     // Percent of current ammo reserve stolen per hit.
const ZF_THIEVING_ATTACK = -66;             // Attack penalty when using perk.
const ZF_THIEVING_METAL = 100;              // Metal stolen per hit.
const Float:ZF_THIEVING_UBERPCT = 0.50;     // Percent of ubercharge stolen per hit.
const ZF_TOXIC_ATTACK = -100;               // Attack penalty when using perk.
const ZF_TOXIC_DURATION_POISON = 12;        // Time each regen penalty lasts.
const ZF_TOXIC_DAMAGE_PASSIVE = 3;          // Damage per/s for survivors nearby stationary zombie.
const ZF_TOXIC_RADIUSSQ = (400 * 400);      // Radius (squared) inwhich toxic passive poison is applied.
const Float:ZF_VAMPIRIC_HEALTHPCT = 0.75;   // Percent of damage leeched when hit.
const ZF_VAMPIRIC_REGEN = 10;               // Regeneration bonus when using perk.
const ZF_VINDICTIVE_ATTACK = 20;            // Attack bonus per kill.
const ZF_VINDICTIVE_ATTACK_ASSIST = 5;      // Attack bonus per assist.
const ZF_VINDICTIVE_DEFEND = 8;             // Defense bonus per kill.
const ZF_VINDICTIVE_DEFEND_ASSIST = 2;      // Defense bonus per assist.
const ZF_TANK_ATTACK = -66;
const ZF_TANK_DEFEND = 50;
const ZF_TANK_SPEED = -30;
const ZF_TANK_FROG_DEFEND = 30;
const ZF_TANK_FROG_SPEED = -30;
const ZF_TANK_FROG_DURATION = 60;           // Duration after rally is placed before it expires.
const ZF_TANK_FROG_COOLDOWN = 70;          // Duration after rally is placed before it can be replaced.
const ZF_TANK_FROG_RADIUSSQ = (400 * 400);  // Radius (squared) inwhich rally bonuses apply.
//
// Perk Vars
//

// State
new zf_frameCounter;
new zf_surPerksEnabled;
new zf_zomPerksEnabled;
new zf_surPerksLimit[TOTAL_SUR_PERKS];
new zf_zomPerksLimit[TOTAL_ZOM_PERKS];
new zf_perkMode;
new zf_perkPendingMode;
new zf_perkRandSurPerk;
new zf_perkRandZomPerk;
new zf_perkTeamSurPerk;
new zf_perkTeamZomPerk;
new zf_menuPerk[MAXPLAYERS+1];

// Logic
new zf_lastAttack[MAXPLAYERS+1];
new zf_lastButtons[MAXPLAYERS+1];
new zf_lastHealth[MAXPLAYERS+1];
new zf_lastKiller[MAXPLAYERS+1];
new zf_lastPoison[MAXPLAYERS+1];
new zf_lastTeam[MAXPLAYERS+1];

new zf_perkTimer[MAXPLAYERS+1];           // Timer shared by many perks
new zf_perkState[MAXPLAYERS+1];           // State shared by many perks
new Float:zf_perkPos[MAXPLAYERS+1][5][3]; // Position array shared by many perks
new String:zf_perkStr[MAXPLAYERS+1][32];  // String shared by many perks

new zf_perkAlphaMaster[MAXPLAYERS+1];     // Perk-specific var. Didn't want to use it, but had no choice.

// Stats
#define TOTAL_ZFSTATS 5
#define TOTAL_ZFSTAT_TYPES 4
#define TOTAL_ZFCONDS 4
enum ZFStat { 
  ZFStatAtt = 0,    // TODO Desc
  ZFStatCrit,       // TODO Desc
  ZFStatDef,        // TODO Desc
  ZFStatRof,        // TODO Desc
  ZFStatSpeed       // TODO Desc
}
enum ZFStatType { 
  ZFStatTypePerm = 0,        // TODO Desc
  ZFStatTypeCond,            // TODO Desc
  ZFStatTypeTemp,            // TODO Desc
  ZFStatTypeTempDuration     // TODO Desc
}
enum ZFCond { 
  ZFCondCrippled = 0, // TODO Desc
  ZFCondIntimidated,  // TODO Desc
  ZFCondPoisoned,     // TODO Desc
  ZFCondTracked       // TODO Desc
}
new zf_stat[MAXPLAYERS+1][ZFStat][ZFStatType];
new zf_cond[MAXPLAYERS+1][ZFCond];

// FX.Entities
new zf_aura[MAXPLAYERS+1];

#define ICON_SPR 0
#define ICON_ANC 1
new zf_icon[MAXPLAYERS+1][2];

#define MAX_ITEMS 5
new zf_item[MAXPLAYERS+1][MAX_ITEMS];

// FX.HUD
new Handle:zf_hudLine0;
new Handle:zf_hudLine1;
new Handle:zf_hudLine2;

// Menus
new Handle:zf_menuSurPerkList;
new Handle:zf_menuZomPerkList;

// CVARS
new Handle:zf_cvCripple;

////////////////////////////////////////////////////////////
//
// Perk Init
//
////////////////////////////////////////////////////////////
public perkInit()
{  
  // Initialize game state
  zf_frameCounter = 0;
  zf_surPerksEnabled = 0xFFFF_FFFF;
  zf_zomPerksEnabled = 0xFFFF_FFFF;
  for(new i = 0; i < TOTAL_SUR_PERKS; i++)
    zf_surPerksLimit[i] = -1;
  for(new i = 0; i < TOTAL_ZOM_PERKS; i++)
    zf_zomPerksLimit[i] = -1;
  zf_perkMode = 0;
  zf_perkPendingMode = 0;
  zf_perkRandSurPerk = ZF_PERK_NONE;
  zf_perkRandZomPerk = ZF_PERK_NONE;  
  zf_perkTeamSurPerk = ZF_PERK_NONE;
  zf_perkTeamZomPerk = ZF_PERK_NONE;

  // Initialize client perk state
  resetAllClients();
  
  // Initialize HUD synchronizers
  zf_hudLine0 = CreateHudSynchronizer();
  zf_hudLine1 = CreateHudSynchronizer();
  zf_hudLine2 = CreateHudSynchronizer();
  
  // Initialize menu handles
  zf_menuSurPerkList = perk_buildSurPerkListMenu();
  zf_menuZomPerkList = perk_buildZomPerkListMenu();
    
  // Admin Commands
  // [0|normal|1|randplayer|2|randteam|3|cvarteam]
  RegAdminCmd("sm_zf_perk_setmode", command_zfPerkSetMode, ADMFLAG_GENERIC, "Sets ZF perk mode. 0 = Normal, 1 = Random per player, 2 = Random per team, 3 = CVAR per team.");
  // [<surperk>]
  RegAdminCmd("sm_zf_perk_setteamsurperk", command_zfPerkSetTeamSurPerk, ADMFLAG_GENERIC, "Sets survivor perk for CVAR per team mode.");
  // [<zomperk>]
  RegAdminCmd("sm_zf_perk_setteamzomperk", command_zfPerkSetTeamZomPerk, ADMFLAG_GENERIC, "Sets zombie perk for CVAR per team mode.");
  // [all|allsur|allzom]
  RegAdminCmd("sm_zf_perk_list", command_zfPerkList, ADMFLAG_GENERIC, "Lists current perks and status.");
  // [all|allsur|allzom|<perk>]
  RegAdminCmd("sm_zf_perk_enable", command_zfPerkEnable, ADMFLAG_GENERIC, "Enables specified perk. Changes apply on new round.");
  // [all|allsur|allzom|<perk>]
  RegAdminCmd("sm_zf_perk_disable", command_zfPerkDisable, ADMFLAG_GENERIC, "Disables specified perk. Changes apply on new round.");
  // [all|allsur|allzom|<perk>] [<limit>]
  RegAdminCmd("sm_zf_perk_limit", command_zfPerkLimit, ADMFLAG_GENERIC, "Sets limit for specified perk. -1 = Unlimited, 0 = None, >0 = Limit. Changes fully apply on new round.");
  
  // Client Commands
  // [<perk>]
  AddCommandListener(hook_zfSelectPerk, "zf_perk_select");
  
  // Register CVARS
  zf_cvCripple = CreateConVar("sm_zf_cripple", "0", "0 = Crippling backstab disabled, 1 = Crippling backstab enabled.", FCVAR_PLUGIN, true, 0.0, true, 1.0); 
}

////////////////////////////////////////////////////////////
//
// Admin Command Handlers
//
///////////////////////////////////////////////////////////
public Action:command_zfPerkSetMode(client, args)
{
  decl String:cmd[32];
  
  if(args == 0)
  {
    //
    // Display current mode.
    //
    ReplyToCommand(client, "Current game mode: %d", zf_perkMode);
    return Plugin_Handled;
  }  
  else if(args == 1)
  {
    //
    // Set game mode for next round.
    //
    GetCmdArg(1, cmd, sizeof(cmd));
    if(StrEqual(cmd, "0", false) || StrEqual(cmd, "normal", false))
    {
      zf_perkPendingMode = 0;
      ReplyToCommand(client, "Game mode set to 0 (Normal). Changes apply on new round.");
      return Plugin_Handled;
    }
    if(StrEqual(cmd, "1", false) || StrEqual(cmd, "randplayer", false))
    {
      zf_perkPendingMode = 1;
      ReplyToCommand(client, "Game mode set to 1 (Random perks per player). Changes apply on new round.");
      return Plugin_Handled;
    }
    if(StrEqual(cmd, "2", false) || StrEqual(cmd, "randteam", false))
    {
      zf_perkPendingMode = 2;
      ReplyToCommand(client, "Game mode set to 2 (Random perks per team). Changes apply on new round.");
      return Plugin_Handled;
    } 
    if(StrEqual(cmd, "3", false) || StrEqual(cmd, "cvarteam", false))
    {
      zf_perkPendingMode = 3;
      ReplyToCommand(client, "Game mode set to 3 (CVAR perks per team). Changes apply on new round.");
      return Plugin_Handled;
    }      
  }

  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [0|normal|1|randplayer|2|randteam|3|cvarteam]", cmd);    
  return Plugin_Handled;
}

public Action:command_zfPerkSetTeamSurPerk(client, args)
{
  decl String:cmd[32];
  
  if(args == 1)
  {
    GetCmdArg(1, cmd, sizeof(cmd));
    
    for(new i = 0; i < TOTAL_SUR_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_SURPERK_NAME[i], false))
      {
        zf_perkTeamSurPerk = i;
        ReplyToCommand(client, "Selected %s as survivor perk for CVAR per team mode.", ZF_SURPERK_NAME[i]);
        return Plugin_Handled;
      }
    }  
  }
  
  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [<surperk>]", cmd);    
  return Plugin_Handled;  
}

public Action:command_zfPerkSetTeamZomPerk(client, args)
{
  decl String:cmd[32];
  
  if(args == 1)
  {
    GetCmdArg(1, cmd, sizeof(cmd));
    
    for(new i = 0; i < TOTAL_ZOM_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_ZOMPERK_NAME[i], false))
      {
        zf_perkTeamZomPerk = i;
        ReplyToCommand(client, "Selected %s as zombie perk for CVAR per team mode.", ZF_ZOMPERK_NAME[i]);
        return Plugin_Handled;
      }
    }  
  }
  
  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [<zomperk>]", cmd);    
  return Plugin_Handled;  
}

public Action:command_zfPerkList(client, args)
{
  decl String:cmd[32];
  
  if(args == 1)
  {
    GetCmdArg(1, cmd, sizeof(cmd));
    
    new bool:listSur = StrEqual(cmd, "all", false) || StrEqual(cmd, "allsur", false);
    new bool:listZom = StrEqual(cmd, "all", false) || StrEqual(cmd, "allzom", false);
    if(listSur)
    {
      ReplyToCommand(client, "Survivor Perks (enabled unless specified):");
      for(new i = 1; i < TOTAL_SUR_PERKS; i++)
        if(surPerkEnabled(i))
          ReplyToCommand(client, " > %s (Limit: %d)", ZF_SURPERK_NAME[i], zf_surPerksLimit[i]);
        else
          ReplyToCommand(client, " [Disabled] > %s (Limit: %d)", ZF_SURPERK_NAME[i], zf_surPerksLimit[i]);
    } 
    if(listZom)
    {
      ReplyToCommand(client, "Zombie Perks (enabled unless specified):");
      for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
        if(zomPerkEnabled(i))
          ReplyToCommand(client, " > %s (Limit: %d)", ZF_ZOMPERK_NAME[i], zf_zomPerksLimit[i]);
        else
          ReplyToCommand(client, " [Disabled] > %s (Limit: %d)", ZF_ZOMPERK_NAME[i], zf_zomPerksLimit[i]);
    }
    
    if(listSur | listZom)
      return Plugin_Handled;
  }
  
  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [all|allsur|allzom]", cmd);    
  return Plugin_Handled;
}

public Action:command_zfPerkEnable(client, args)
{
  command_perkUpdate(client, args, true);
  return Plugin_Handled;
}

public Action:command_zfPerkDisable(client, args)
{
  command_perkUpdate(client, args, false);
  return Plugin_Handled;
}

public Action:command_perkUpdate(client, args, bool:doEnable)
{
  decl String:cmd[32];
  
  if(args == 1)
  {
    GetCmdArg(1, cmd, sizeof(cmd));

    new bool:setSur = StrEqual(cmd, "all", false) || StrEqual(cmd, "allsur", false);
    new bool:setZom = StrEqual(cmd, "all", false) || StrEqual(cmd, "allzom", false);
    decl String:strState[16];
    strState = doEnable ? "Enabled" : "Disabled";
    
    //
    // Enable/Disable groups of perks.
    //
    if(setSur)
    {
      zf_surPerksEnabled = doEnable ? 0xFFFF_FFFF : 0x0000_0001;
      ReplyToCommand(client, "%s all survivor perks. Changes apply on new round.", strState);      
    }    
    if(setZom)
    {
      zf_zomPerksEnabled = doEnable ? 0xFFFF_FFFF : 0x0000_0001;
      ReplyToCommand(client, "%s all zombie perks. Changes apply on new round.", strState);        
    }
    if(setSur || setZom)
    {
      return Plugin_Handled;
    }

    //
    // Enable/Disable single perk.
    //
    for(new i = 1; i < TOTAL_SUR_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_SURPERK_NAME[i], false))
      {
        zf_surPerksEnabled = doEnable ? (zf_surPerksEnabled | (1 << i)) : (zf_surPerksEnabled & ~(1 << i));
        ReplyToCommand(client, "%s %s. Changes apply on new round.", strState, ZF_SURPERK_NAME[i]);
        return Plugin_Handled;
      }
    }
    for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_ZOMPERK_NAME[i], false))
      {
        zf_zomPerksEnabled = doEnable ? (zf_zomPerksEnabled | (1 << i)) : (zf_zomPerksEnabled & ~(1 << i));
        ReplyToCommand(client, "%s %s. Changes apply on new round.", strState, ZF_ZOMPERK_NAME[i]);
        return Plugin_Handled;
      }
    }
    
    ReplyToCommand(client, "\"%s\" is not a valid perk!", cmd);
    return Plugin_Handled;
  }

  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [all|allsur|allzom|<perk>]", cmd);    
  return Plugin_Handled;  
}

public Action:command_zfPerkLimit(client, args)
{
  decl String:cmd[32];
  decl String:cmd2[32];
  
  if(args == 2)
  {
    GetCmdArg(1, cmd, sizeof(cmd));
    GetCmdArg(2, cmd2, sizeof(cmd2));

    new bool:setSur = StrEqual(cmd, "all", false) || StrEqual(cmd, "allsur", false);
    new bool:setZom = StrEqual(cmd, "all", false) || StrEqual(cmd, "allzom", false);
    new limit = StringToInt(cmd2);
        
    //
    // Limit groups of perks.
    //
    if(setSur)
    {
      for(new i = 1; i < TOTAL_SUR_PERKS; i++)
        zf_surPerksLimit[i] = limit;
      ReplyToCommand(client, "Survivor perk limits set to %d. Changes fully apply on new round.", limit);      
    }    
    if(setZom)
    {
      for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
        zf_zomPerksLimit[i] = limit;
      ReplyToCommand(client, "Zombie perk limits set to %d. Changes fully apply on new round.", limit);      
    }
    if(setSur || setZom)
    {
      return Plugin_Handled;
    }

    //
    // Limit single perk.
    //
    for(new i = 1; i < TOTAL_SUR_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_SURPERK_NAME[i], false))
      {
        zf_surPerksLimit[i] = limit;
        ReplyToCommand(client, "%s perk limit set to %d. Changes fully apply on new round.", ZF_SURPERK_NAME[i], limit);
        return Plugin_Handled;
      }
    }
    for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_ZOMPERK_NAME[i], false))
      {
        zf_zomPerksLimit[i] = limit;
        ReplyToCommand(client, "%s perk limit set to %d. Changes fully apply on new round.", ZF_ZOMPERK_NAME[i], limit);
        return Plugin_Handled;
      }
    }
    
    ReplyToCommand(client, "\"%s\" is not a valid perk!", cmd);
    return Plugin_Handled;
  }

  //
  // Error in command format, display usage.
  //
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [all|allsur|allzom|<perk>] [<limit>]", cmd);    
  return Plugin_Handled;    
}

////////////////////////////////////////////////////////////
//
// Client Command Handlers
//
///////////////////////////////////////////////////////////
public Action:hook_zfSelectPerk(client, const String:command[], argc)
{
  decl String:cmd[32];

  //
  // Select a single survivor/zombie perk.
  //
  if(argc == 1)
  {
    GetCmdArg(1, cmd, sizeof(cmd));
    
    for(new i = 1; i < TOTAL_SUR_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_SURPERK_NAME[i], false))
      {
        selectSurPerk(client, i);       
        return Plugin_Handled;
      }
    }
    
    for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
    {
      if(StrEqual(cmd, ZF_ZOMPERK_NAME[i], false))
      {
        selectZomPerk(client, i);       
        return Plugin_Handled;      
      }
    }
    
    if(StrEqual(cmd, ZF_SURPERK_NAME[0], false) || StrEqual(cmd, ZF_ZOMPERK_NAME[0], false))
    {
      selectSurPerk(client, 0);
      selectZomPerk(client, 0);
      return Plugin_Handled;
    }
  }
  
  GetCmdArg(0, cmd, sizeof(cmd));
  ReplyToCommand(client, "Usage: %s [<perk>]", cmd);    
  return Plugin_Handled;
}

////////////////////////////////////////////////////////////
//
// Perk Stat Routines
//
////////////////////////////////////////////////////////////
stock getStat(client, ZFStat:stat)
{ return zf_stat[client][stat][ZFStatTypePerm] + zf_stat[client][stat][ZFStatTypeCond] + zf_stat[client][stat][ZFStatTypeTemp]; }

stock getStatType(client, ZFStat:stat, ZFStatType:type)
{ return zf_stat[client][stat][type]; }

stock addStat(client, ZFStat:stat, ZFStatType:type, val)
{ zf_stat[client][stat][type] += val; }

// Temporary setters
stock addStatTempStack(client, ZFStat:stat, newStr, newDur)
{ 
  // Note on result:
  // + Strength is averaged across maximum duration (stacks).
  // Note on use:
  // + newStr can be negative or positive.
  // + newDur must be positive.
  if((newStr != 0) && (newDur > 0))
  {
    new oldStr = zf_stat[client][stat][ZFStatTypeTemp];
    new oldDur = zf_stat[client][stat][ZFStatTypeTempDuration]; 
    new total = (oldStr * oldDur) + (newStr * newDur);
    new finalDur = max(oldDur, newDur);
    new finalStr = RoundToCeil(total / float(finalDur));
    
    // Set new temp stats
    zf_stat[client][stat][ZFStatTypeTemp] = finalStr;
    zf_stat[client][stat][ZFStatTypeTempDuration] = finalDur;
  }
  else
  {
    LogError("[VSH-ZF] - addStatTempStack() - Invalid newStr (%d) or newDur (%d)", newStr, newDur);
  }
}
stock addStatTempExtend(client, ZFStat:stat, newStr, newDur)
{
  // Note on result:
  // + Strength is averaged across sum of durations (extends).  
  // Note on use:
  // + newStr must be positive.
  // + newDur must be positive.
  if((newStr > 0) && (newDur > 0))
  {
    new oldStr = zf_stat[client][stat][ZFStatTypeTemp];
    new oldDur = zf_stat[client][stat][ZFStatTypeTempDuration]; 
    new total = (oldStr * oldDur) + (newStr * newDur);    
    new finalDur = oldDur + newDur;
    new finalStr = RoundToCeil(total / float(finalDur));
    
    // Set new temp stats
    zf_stat[client][stat][ZFStatTypeTemp] = finalStr;
    zf_stat[client][stat][ZFStatTypeTempDuration] = finalDur;    
  }
  else
  {
    LogError("[VSH-ZF] - addStatTempExtend() - Invalid newStr (%d) or newDur (%d)", newStr, newDur);  
  }
}

stock scaleStatTempPct(client, ZFStat:stat, Float:strPct, Float:durPct = 1.0)
{
  zf_stat[client][stat][ZFStatTypeTemp] = RoundToCeil(float(zf_stat[client][stat][ZFStatTypeTemp]) * strPct);
  zf_stat[client][stat][ZFStatTypeTempDuration] = RoundToCeil(float(zf_stat[client][stat][ZFStatTypeTempDuration]) * durPct);
}

////////////////////////////////////////////////////////////
//
// Perk Cond Routines
//
////////////////////////////////////////////////////////////
stock bool:getCond(client, ZFCond:cond)
{ return zf_cond[client][cond] > 0; }

stock addCond(client, ZFCond:cond, val)
{ zf_cond[client][cond] += val; }

stock subCond(client, ZFCond:cond, val)
{ zf_cond[client][cond] = max(0, zf_cond[client][cond] - val); }

////////////////////////////////////////////////////////////
//
// Perk Reset Logic
// + Used to clear variables with no regard to game state.
//
////////////////////////////////////////////////////////////
stock resetAllClients()
{
  for(new i = 0; i <= MAXPLAYERS; i++)
    resetClient(i);
}

stock resetClient(client)
{  
  // State
  zf_lastAttack[client] = 0;
  zf_lastButtons[client] = 0;
  zf_lastHealth[client] = 0;
  zf_lastKiller[client] = 0;
  zf_lastPoison[client] = 0;
  zf_lastTeam[client] = 0;
  zf_perkTimer[client] = 0;
  zf_perkState[client] = 0;
  for(new i = 0; i < 5; i++)
    for(new j = 0; j < 3; j++)
      zf_perkPos[client][i][j] = 0.0;
  zf_perkStr[client] = "";
  zf_perkAlphaMaster[client] = 0;
  
  // Bonuses
  resetClientStats(client);
  resetClientConds(client);
  
  // FX
  removeAura(client);
  removeIcon(client);
  removeItems(client); 
}

stock resetClientStats(client)
{
  for(new stat = 0; stat < TOTAL_ZFSTATS; stat++)
    for(new type = 0; type < TOTAL_ZFSTAT_TYPES; type++)
      zf_stat[client][stat][type] = 0;
}

stock resetStatType(ZFStatType:type)
{
  for(new i = 0; i <= MAXPLAYERS; i++)
    resetClientStatType(i, type);
}

stock resetClientStatType(client, ZFStatType:type)
{
  for(new stat = 0; stat < TOTAL_ZFSTATS; stat++)
    zf_stat[client][stat][type] = 0;
}

stock resetClientConds(client)
{  
  for(new cond = 0; cond < TOTAL_ZFCONDS; cond++)
    zf_cond[client][cond] = 0;
}

////////////////////////////////////////////////////////////
//
// Perk Selection Utilities
//
////////////////////////////////////////////////////////////
stock bool:surPerkEnabled(perk)
{ return (zf_surPerksEnabled & (1 << perk)) != 0; }
stock bool:zomPerkEnabled(perk)
{ return (zf_zomPerksEnabled & (1 << perk)) != 0; }
stock bool:usingSurPerk(client, perk)
{ return (prefGet(client, SurPerk) == perk); }
stock bool:usingZomPerk(client, perk)
{ return (prefGet(client, ZomPerk) == perk); } 

//
// Called by client when he selects a survivor perk (either from menu or by command).
//
stock selectSurPerk(client, perk)
{
  // Do not select invalid perk.
  if((perk < 0) || (perk >= TOTAL_SUR_PERKS))
    PrintToChat(client, "\x05[VSH-ZF]\x01 Can't select perk: Invalid perk.");  
  // Do not select disabled perk.
  else if(!surPerkEnabled(perk))
    PrintToChat(client, "\x05[VSH-ZF]\x01 Can't select %s as survivor perk: Disabled by server.", ZF_SURPERK_NAME[perk]);
  // Do not select perk during non-standard game modes.
  else if(zf_perkMode > 0)
    PrintToChat(client, "\x05[VSH-ZF]\x01 Can't select %s as survivor perk: Non-standard game mode active.", ZF_SURPERK_NAME[perk]);
  // Do not select perk if selecting it violate perk limit.
  else if(surPerkAtLimit(client, perk))
    PrintToChat(client, "\x05[VSH-ZF]\x01 Can't select %s as survivor perk: Perk limit reached (%d).", ZF_SURPERK_NAME[perk], zf_surPerksLimit[perk]);
  // Select perk.
  else
  {
    prefSet(client, SurPendPerk, perk);
    prefSet(client, PerkSelectMode, zf_perkMode);
    
    // Defer perk selection for non-survivors.
    if(!isSur(client))
      PrintToChat(client, "\x05[VSH-ZF]\x01 选择 %s 作为幸存者职业. 将会在下一次僵尸生成时切换.", ZF_SURPERK_NAME[perk]);
    // Defer perk selection during active rounds.
    else if(roundState() > RoundGrace)
      PrintToChat(client, "\x05[VSH-ZF]\x01 选择 %s 作为幸存者职业. 将会在下一次僵尸生成时切换", ZF_SURPERK_NAME[perk]);
    // Respawn client. This will trigger new perk selection.
    else
      TF2_RespawnPlayer(client);
  }
}

//
// Called by client when he selects a zombie perk (either from menu or by command).
//
stock selectZomPerk(client, perk)
{
    prefSet(client, ZomPendPerk, perk);
    prefSet(client, PerkSelectMode, zf_perkMode);
}

////////////////////////////////////////////////////////////
//
// Perk Limit Utilities
//
////////////////////////////////////////////////////////////
stock bool:surPerkAtLimit(client, perk)
{
  // Perk limit of -1 means no limit.
  if(zf_surPerksLimit[perk] == -1)
  {
    return false;
  }
  // Perk limit of 0 means a limit of 0.
  else if(zf_surPerksLimit[perk] == 0)
  {
    return true;
  }
  // Tally up perk use for all survivors (alive or not).
  // Do not include current client in tally.
  else
  {
    new total = 0;
    for(new i = 1; i <= MaxClients; i++)
      if((i != client) && IsClientInGame(i) && isSur(i) && usingSurPerk(i, perk))
          total++;
  
    return (total >= zf_surPerksLimit[perk]);
  }
}

stock bool:zomPerkAtLimit(client, perk)
{
  // Perk limit of -1 means no limit.
  if(zf_zomPerksLimit[perk] == -1)
  {
    return false;
  }
  // Perk limit of 0 means a limit of 0.
  else if(zf_zomPerksLimit[perk] == 0)
  {
    return true;
  }
  // Tally up perk use for all zombies (alive or not).
  // Do not include current client in tally.
  else
  {
    new total = 0;
    for(new i = 1; i <= MaxClients; i++)
      if((i != client) && IsClientInGame(i) && isZom(i) && usingZomPerk(i, perk))
          total++;
  
    return (total >= zf_zomPerksLimit[perk]);
  }
}

////////////////////////////////////////////////////////////
//
// Perk HUD Logic
//
////////////////////////////////////////////////////////////
updateHud(client)
{
  decl String:strHudPerk[48];
  decl String:strHudBonuses[32];
  
  if(IsClientInGame(client) && !(zf_lastButtons[client] & IN_SCORE))
  {
    if(isSur(client) || isZom(client))
    {
      if(IsPlayerAlive(client))
      {  
        // HUD Element: Perk Selection
        if(isSur(client))
          Format(strHudPerk, sizeof(strHudPerk), "职业: %s", ZF_SURPERK_NAME[prefGet(client, SurPerk)]);
        else if(isZom(client))
          Format(strHudPerk, sizeof(strHudPerk), "职业: %s", ZF_ZOMPERK_NAME[prefGet(client, ZomPerk)]);      
        else
          strHudPerk = "";
        SetHudTextParams(0.15, 0.90, 2.1, 200, 200, 200, 150);
        ShowSyncHudText(client, zf_hudLine0, "%s %s", strHudPerk, zf_perkStr[client]);
        
        // HUD Element: Bonuses 1 (Attack, Defense)
        Format(strHudBonuses, sizeof(strHudBonuses), "攻击: %d%s, 防御: %d%s", getStat(client, ZFStatAtt), "\%", getStat(client, ZFStatDef), "\%"); 
        SetHudTextParams(0.15, 0.93, 2.1, 150, 150, 150, 150);
        ShowSyncHudText(client, zf_hudLine1, "%s", strHudBonuses);
        
        // HUD Element: Bonuses 2 (Crit, Speed)
        Format(strHudBonuses, sizeof(strHudBonuses), "暴击率: %d%s, 速度: %d", getStat(client, ZFStatCrit), "\%", getStat(client, ZFStatSpeed)); 
        SetHudTextParams(0.15, 0.96, 2.1, 150, 150, 150, 150);
        ShowSyncHudText(client, zf_hudLine2, "%s", strHudBonuses);      
      }
      else
      {
        // HUD Element: Killer's perk
        new killer = zf_lastKiller[client];
        if(validClient(killer) && (killer != client))
        {
          if(isSur(killer))
            Format(strHudPerk, sizeof(strHudPerk), "你被 %s 职业杀死", ZF_SURPERK_NAME[prefGet(killer, SurPerk)]);
          else if(isZom(killer))
            Format(strHudPerk, sizeof(strHudPerk), "你被 %s 职业杀死", ZF_ZOMPERK_NAME[prefGet(killer, ZomPerk)]);
          else
            strHudPerk = "";
          SetHudTextParams(0.15, 0.90, 2.1, 250, 200, 200, 150);
          ShowSyncHudText(client, zf_hudLine0, "%s", strHudPerk);            
        }
      }
    }
    else
    {
      // HUD Element: Specator target's perk
      new spectate = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
      if(validClient(spectate))
      {
        if(isSur(spectate))
          Format(strHudPerk, sizeof(strHudPerk), "观察目标职业为 %s ", ZF_SURPERK_NAME[prefGet(spectate, SurPerk)]);
        else if(isZom(spectate))
          Format(strHudPerk, sizeof(strHudPerk), "观察目标职业为 %s ", ZF_ZOMPERK_NAME[prefGet(spectate, ZomPerk)]);
        else
          strHudPerk = "";
        SetHudTextParams(0.15, 0.90, 2.1, 250, 200, 200, 150);
        ShowSyncHudText(client, zf_hudLine0, "%s", strHudPerk);            
      }
    }
  }     
}

////////////////////////////////////////////////////////////
//
// Aura Effect Routines
//
////////////////////////////////////////////////////////////
stock createAura(client, const String:strPart[], ZFParticleAttachStyle:attachStyle, const Float:offset[3] = {0.0, 0.0, 0.0})
{
  removeAura(client);
  zf_aura[client] = fxCreateParticle(strPart, client, attachStyle, 0.0, offset);
}

stock removeAura(client)
{
  fxDeleteParticle(zf_aura[client]);
  zf_aura[client] = -1;
}

stock bool:validAura(client)
{ return fxIsParticleValid(zf_aura[client]); }

stock showAura(client)
{ fxStartParticle(zf_aura[client]); }

stock hideAura(client)
{ fxStopParticle(zf_aura[client]); }

////////////////////////////////////////////////////////////
//
// Icons Effect Routines
//
////////////////////////////////////////////////////////////
stock createIcon(ownerClient, targetClient, const String:strSprite[])
{
  removeIcon(ownerClient);
  fxCreateSprite(strSprite, targetClient, zf_icon[ownerClient][ICON_SPR], zf_icon[ownerClient][ICON_ANC]);
}

stock removeIcon(client)
{
  fxDeleteSprite(zf_icon[client][ICON_SPR], zf_icon[client][ICON_ANC]);
  zf_icon[client][ICON_SPR] = -1;
  zf_icon[client][ICON_ANC] = -1;
}

stock bool:validIcon(client)
{ return fxIsSpriteValid(zf_icon[client][ICON_SPR], zf_icon[client][ICON_ANC]); }

stock showIcon(client)
{ fxShowSprite(zf_icon[client][ICON_SPR], zf_icon[client][ICON_ANC]); }

stock hideIcon(client)
{ fxHideSprite(zf_icon[client][ICON_SPR], zf_icon[client][ICON_ANC]); }

////////////////////////////////////////////////////////////
//
// Items Effect Routines
//
////////////////////////////////////////////////////////////
stock removeItem(client, item)
{
  if(validItem(client, item))
    fxPuffSmall(zf_item[client][item]);
  fxDeleteModel(zf_item[client][item]);
  zf_item[client][item] = -1;
}

stock removeItems(client)
{
  for(new i = 0; i < MAX_ITEMS; i++)
    removeItem(client, i);
}

stock bool:validItem(client, itemIndex)
{ return fxIsModelValid(zf_item[client][itemIndex]); }

stock getItemMetadata(item)
{
  // Utilizes an entity prop that is, in theory, not used.
  return GetEntProp(item, Prop_Send, "m_hEffectEntity");
}

stock setItemMetadata(item, value)
{
  // Utilizes an entity prop that is, in theory, not used.
  SetEntProp(item, Prop_Send, "m_hEffectEntity", value);
}

stock getFreeItemIndex(client, maxItems)
{
  // Return first item index in range [0, maxItems-1] that is free (i.e. not valid).
  // Return -1 if no item in range is free.
  for(new i = 0; i < maxItems; i++)
  {
    if(!validItem(client, i))
      return i;
  }
  return -1;
}

////////////////////////////////////////////////////////////
//
// Perk Utility Helpers
//
////////////////////////////////////////////////////////////
stock addHealth(client, health, bool:doOverheal = false)
{
  // Add health up to max (or overheal max [500]).
  new cur = GetClientHealth(client);
  new lim = doOverheal ? 500 : clientMaxHealth(client);
  if(cur < lim)
  {
    SetEntityHealth(client, min((cur+health),lim));
    if(!isCloaked(client)) 
      fxHealthGained(client);
  }
}

////////////////////////////////////////////////////////////
//
// Perk Logic Helpers
//
////////////////////////////////////////////////////////////
stock bool:doItemCollide(
  ent, 
  const Float:prevPos[3], 
  Float:hitPos[3], 
  Float:hitVec[3])
{
  new bool:didHit = false;
  decl Float:thisPos[3];
  decl Float:diffPos[3];
  decl Float:nextPos[3];
  
  // Use current position(thisPos) and previous position(prevPos)
  // to calculate a difference (diffPos). Normalize and scale
  // difference to compute predicted next position (nextPos).
  getEntityPos(ent, thisPos);
  SubtractVectors(thisPos, prevPos, diffPos);      
  NormalizeVector(diffPos, diffPos);
  ScaleVector(diffPos, 35.0);              
  AddVectors(thisPos, diffPos, nextPos);

  // Trace from current to next position, checking for impacts.
  new Handle:TraceEx = TR_TraceRayFilterEx(thisPos, nextPos, MASK_SOLID, RayType_EndPoint, TraceFilter);
  if(TR_DidHit(TraceEx))
  {
    TR_GetEndPosition(hitPos, TraceEx);
    TR_GetPlaneNormal(TraceEx, hitVec);
    if(!TR_PointOutsideWorld(hitPos))
    {
      didHit = true;
    }
  }
  CloseHandle(TraceEx);

  return didHit;     
}

public bool:TraceFilter(ent, contentMask)
{
  return false;
}

stock doItemImpact(
  client, 
  const Float:hitPos[3], 
  const Float:hitVec[3], 
  const color[3])
{
  decl Float:hitAng[3];   
  GetVectorAngles(hitVec, hitAng);
  hitAng[0] += 90.0; // Adjust for ZFMDL_HAYBALE
    
  // Place item at hitPos, oriented based on hitVec.
  return fxCreateModelStatic(ZFMDL_HAYBALE, client, true, false, hitPos, hitAng, color); 
}

stock doItemPlace(client, const String:strModel[])
{
  decl Float:pos[3];
  decl Float:ang[3]; 
  
  GetClientAbsOrigin(client, pos); 
  GetClientAbsAngles(client, ang);    

  // Place item at client's feet.
  return fxCreateModelStatic(strModel, client, true, false, pos, ang);
}

stock doItemThrow(
  client, 
  const String:strModel[], 
  Float:force, 
  const color[3] = {255, ...})
{
  decl Float:pos[3];
  decl Float:ang[3];
    
  GetClientEyePosition(client, pos);  
  GetClientEyeAngles(client, ang);
  ang[0] += GetRandomFloat(-20.0, -10.0); // Pitch (-90.0 is up, 90.0 is down)
  ang[1] += GetRandomFloat(-6.0, 6.0);    // Yaw

  // Throw item from client's eye position and along look vector.
  return fxCreateModelThrown(strModel, client, pos, ang, force, color);  
}

////////////////////////////////////////////////////////////
//
// Perk Logic Helpers
//
////////////////////////////////////////////////////////////
stock doAlphaSummon(client)
{ 
  decl summonCount;
  decl validMinionCount;
  decl validMinions[MAXPLAYERS+1];
  decl Float:clientPos[3];
  decl Float:clientAng[3];
  decl Float:summonVel[3];
  
  GetClientAbsOrigin(client, clientPos);  
  GetClientAbsAngles(client, clientAng);
  
  // Determine which clients to summon.
  validMinionCount = 0;
  for(new i = 1; i <= MaxClients; i++)
  {
    if(i == client) continue;
    if(IsClientInGame(i) && IsPlayerAlive(i) && isZom(i))
      if((zf_perkAlphaMaster[i] == client) && (isScout(i) || isHeavy(i)))
        validMinions[validMinionCount++] = i;
  }
   
  // Summon valid minions.
  summonCount = 0;
  SortIntegers(validMinions, validMinionCount, Sort_Random); 
  for(new i = 0; i < validMinionCount; i++)
  {
    if(i == ZF_ALPHA_SUMMON_LIMIT) break;
    
    summonVel[0] = GetRandomFloat(-100.0, 100.0);
    summonVel[1] = GetRandomFloat(-100.0, 100.0);
    summonVel[2] = GetRandomFloat(300.0, 400.0);
    TeleportEntity(validMinions[i], clientPos, clientAng, summonVel);
    ClientCommand(validMinions[i], "voicemenu 1 0");
    PrintHintText(validMinions[i], "你的主人 召唤了你!");
    fxTeleportTrail(validMinions[i], 5.0);
    ++summonCount;
  }
  
  if(summonCount == 1)
    PrintHintText(client, "你 召唤了 %d 个仆人!", summonCount);
  else if(summonCount > 1)
    PrintHintText(client, "你 召唤了 %d 个仆人!", summonCount);    
    
  return summonCount; 
}

stock doCarpenterBuild(client, Float:physPos[3])
{
  decl Float:pos[3];
  decl Float:ang[3]; 
  decl Float:vecFwd[3];
  decl Float:vecRgt[3];
  GetClientAbsOrigin(client, pos); 
  GetClientAbsAngles(client, ang);   
     
  // Move item in front of client.
  GetAngleVectors(ang, vecFwd, vecRgt, NULL_VECTOR); 
  ScaleVector(vecFwd, 45.0);
  ScaleVector(vecRgt, -30.0);           // Adjust for ZFMDL_FENCE
  AddVectors(pos, vecFwd, pos);         // Adjust for ZFMDL_FENCE
  AddVectors(pos, vecRgt, pos);         // Adjust for ZFMDL_FENCE
  pos[2] += 120.0; 
  ang[0] += GetRandomFloat(-4.0, 4.0);  // Adjust for ZFMDL_FENCE
  ang[1] += GetRandomFloat(85.0, 95.0); // Adjust for ZFMDL_FENCE

  // Calculate physical position (used for distance calculations)
  physPos[0] = pos[0];
  physPos[1] = pos[1];
  physPos[2] = pos[2] - 120.0;
  SubtractVectors(physPos, vecRgt, physPos);
    
  // Barricade build effects
  new Float:off[3] = {0.0,...};
  AddVectors(off, vecFwd, off);
  fxCreateParticle(ZFPART_PUFFBIG, client, AttachNone, 4.0, off);    
   
  ScaleVector(vecRgt, 1.3);
  AddVectors(vecFwd, vecRgt, off);
  fxCreateParticle(ZFPART_PUFFBIG, client, AttachNone, 4.0, off);  
  SubtractVectors(vecFwd, vecRgt, off);
  fxCreateParticle(ZFPART_PUFFBIG, client, AttachNone, 4.0, off);  

  ScaleVector(vecRgt, 1.3);
  AddVectors(vecFwd, vecRgt, off);
  fxCreateParticle(ZFPART_PUFFBIG, client, AttachNone, 4.0, off);  
  SubtractVectors(vecFwd, vecRgt, off);
  fxCreateParticle(ZFPART_PUFFBIG, client, AttachNone, 4.0, off);  
  
  fxCreateSoundToAll(ZFSND_WOOD_HIT[GetRandomInt(0,1)], client);
    
  // Build solid item in front of client.
  return fxCreateModelStatic(ZFMDL_FENCE, client, false, true, pos, ang);  
}

stock doFriendSelect(client, desiredFriend = 0)
{
  decl validSurCount;
  decl validSurs[MAXPLAYERS+1];
  new selectedFriend = desiredFriend;
  
  // Find random friend (if no friend is desired already).
  if(selectedFriend == 0)
  {
    validSurCount = 0;
    for(new i = 1; i <= MaxClients; i++)
    {
      if((client != i) && validLivingSur(i)) 
        validSurs[validSurCount++] = i;
    }
   
    if(validSurCount > 0)
    {
      selectedFriend = validSurs[GetRandomInt(0, validSurCount - 1)];
    }
  }
  
  // Select friend.
  if(selectedFriend == 0)
  {
    zf_perkState[client] = 0;
    zf_perkTimer[client] = 0;
    PrintHintText(client, "你没有朋友.");    
  }  
  else
  {
    zf_perkState[client] = selectedFriend;
    zf_perkTimer[client] = ZF_FRIEND_CRITTIME_INIT;        
    PrintHintText(client, "你 的朋友是: %N.", zf_perkState[client]);
    createIcon(client, zf_perkState[client], ZFSPR_DOMINATED);    
  }
}

stock doMarkedSelect(client)
{
  decl validSurCount;
  decl validSurs[MAXPLAYERS+1];
 
  // Build common state information.
  validSurCount = 0;
  for(new i = 1; i <= MaxClients; i++)
  {
    if(validLivingSur(i)) 
      validSurs[validSurCount++] = i;
  }

  // Handle mark select logic.
  if(validSurCount < ZF_MARKED_MIN_SURVIVORS)
  {
    zf_perkState[client] = -1;

    PrintHintText(client, "没有足够的幸存者可以标记.");
  }
  else
  {
    zf_perkState[client] = validSurs[GetRandomInt(0,(validSurCount-1))];

    createIcon(client, zf_perkState[client], ZFSPR_EXCLAMATION);
    PrintHintText(client, "你标记了一个新的目标, %N!", zf_perkState[client]);
    PrintHintText(zf_perkState[client], "你被标记了!!");
  }
}

stock doNinjaDecoyPlace(client)
{  
  // Create decoy at client.
  fxPuffSmall(client);
  zf_item[client][0] = doItemPlace(client, ZFMDL_CUTOUT[_:TF2_GetPlayerClass(client)]);
    
  // Move client to retreat position.
  decl Float:retreatPos[3];
  getEntityPos(zf_aura[client], retreatPos);
  TeleportEntity(client, retreatPos, NULL_VECTOR, NULL_VECTOR);
  fxPuffSmall(client);  
  
  // Remove retreat point.
  removeAura(client);
}

stock doNinjaDecoyPoof(client)
{
  // Remove decoy, if it exists.
  if(validItem(client, 0))
  {
    fxPuffBig(zf_item[client][0]);
    removeItem(client, 0);
  }
}

stock doThievingLimit(client)
{
  // Enforce ammo limit.

}

stock doThievingSteal(attacker, victim, slot)
{
 
}

////////////////////////////////////////////////////////////
//
// Perk Bonus Update Logic
//
////////////////////////////////////////////////////////////
stock updateClientPermStats(client)
{  
  resetClientStatType(client, ZFStatTypePerm);

  //
  // Apply permanent bonuses for survivors.
  // (Survivors must be alive)
  //
  if(validLivingSur(client))
  {        
    // Handle Perk (S): ATHLETIC
    if(usingSurPerk(client, ZF_PERK_ATHLETIC))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_ATHLETIC_ATTACK);
      addStat(client, ZFStatCrit, ZFStatTypePerm, ZF_ATHLETIC_CRIT);
      addStat(client, ZFStatRof, ZFStatTypePerm, ZF_ATHLETIC_ROF);
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_ATHLETIC_SPEED);
    }
    // Handle Perk (S): CARPENTER
    else if(usingSurPerk(client, ZF_PERK_CARPENTER))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, CARPENTER_ATTACK);
      addStat(client, ZFStatDef, ZFStatTypePerm, CARPENTER_DEFEND);
    }
    // Handle Perk (S): HEROIC
    else if(usingSurPerk(client, ZF_PERK_HEROIC))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, HEROIC_COMBAT);
      addStat(client, ZFStatDef, ZFStatTypePerm, HEROIC_COMBAT);
      zf_perkTimer[client] = HEROIC_CRITTIME_INIT;
    } 
    // Handle Perk (S): JUGGERNAUT
    else if(usingSurPerk(client, ZF_PERK_JUGGERNAUT))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_JUGGERNAUT_ATTACK);
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_JUGGERNAUT_DEFEND);
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_JUGGERNAUT_SPEED);
    }
    // Handle Perk (S): LEADER
    else if(usingSurPerk(client, ZF_PERK_LEADER))
    {
      addStat(client, ZFStatCrit, ZFStatTypePerm, ZF_LEADER_SELF_CRIT);
    }
    // Handle Perk (S): NINJA
    else if(usingSurPerk(client, ZF_PERK_NINJA))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_NINJA_ATTACK);        
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_NINJA_SPEED);      
    }
    // Handle Perk (S): TRAITOR
    else if(usingSurPerk(client, ZF_PERK_TRAITOR))
    {
      addStat(client, ZFStatCrit, ZFStatTypePerm, ZF_TRAITOR_CRIT);
    }
    // Handle Perk (S): TURTLE
    else if(usingSurPerk(client, ZF_PERK_TURTLE))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_TURTLE_ATTACK);
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_TURTLE_DEFEND);
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_TURTLE_SPEED);
    }
  }
    
  //
  // Apply permanent bonuses for zombies.
  // (Zombies can be dead or alive)
  //
  else if(validZom(client))
  {
    // Handle Perk (Z): COMBUSTIBLE
    if(usingZomPerk(client, ZF_PERK_COMBUSTIBLE))
    {
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_COMBUSTIBLE_DEFEND);
    }
    // Handle Perk (Z): LEAP
    else if(usingZomPerk(client, ZF_PERK_LEAP))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_LEAP_COMBAT);
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_LEAP_COMBAT);
    }
    // Handle Perk (Z): SICK
    else if(usingZomPerk(client, ZF_PERK_SICK))
    {
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_SICK_DEFEND);          
    }
    // Handle Perk (Z): SCORCHING
    else if(usingZomPerk(client, ZF_PERK_SCORCHING))
    {
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_SCORCHING_SPEED);      
    }
    // Handle Perk (Z): SWARMING
    else if(usingZomPerk(client, ZF_PERK_SWARMING))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_SWARMING_COMBAT);
      addStat(client, ZFStatDef, ZFStatTypePerm, ZF_SWARMING_COMBAT);  
      addStat(client, ZFStatSpeed, ZFStatTypePerm, ZF_SWARMING_SPEED);   
    }
    // Handle Perk (Z): THIEVING
    else if(usingZomPerk(client, ZF_PERK_THIEVING))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_THIEVING_ATTACK);
    }
    // Handle Perk (Z): TOXIC
    else if(usingZomPerk(client, ZF_PERK_TOXIC))
    {
      addStat(client, ZFStatAtt, ZFStatTypePerm, ZF_TOXIC_ATTACK);
    }  
    else if(usingZomPerk(client, ZF_PERK_TANK))
    {
      addStat(client,ZFStatAtt, ZFStatTypePerm,ZF_TANK_ATTACK);
      addStat(client,ZFStatDef, ZFStatTypePerm,ZF_TANK_DEFEND);
      addStat(client,ZFStatSpeed, ZFStatTypePerm,ZF_TANK_SPEED);
    }
  }       
}

stock updateClientPermEffects(client)
{
  new Float:headOffset[3] = {0.0, 0.0, 15.0};
  
  // Handle survivor effects.
  if(validLivingSur(client))
  {            
    if(usingSurPerk(client, ZF_PERK_HOLY))
      createAura(client, ZFPART_AURAGLOWBEAMS, AttachHead, headOffset);
    else if(usingSurPerk(client, ZF_PERK_LEADER))
      createAura(client, ZFPART_AURAINRED, AttachBase);
  }
  
  // Handle zombie effects.
  else if(validZom(client))
  {
    if(usingZomPerk(client, ZF_PERK_ALPHA))
      createAura(client, ZFPART_AURAINBLU, AttachBase);
    else if(usingZomPerk(client, ZF_PERK_HORRIFYING))
      createAura(client, ZFPART_AURAOUTBLU, AttachBase);
    else if(usingZomPerk(client, ZF_PERK_SWARMING))
      createAura(client, ZFPART_AURAFLIES, AttachHead, headOffset);      
  }         
}

stock updateCondStats()
{  
  decl i,j,k;
  decl validSurCount;
  decl validZomCount;
  decl validSurs[MAXPLAYERS+1];
  decl validZoms[MAXPLAYERS+1];  
  decl Float:validSursPos[MAXPLAYERS+1][3];
  decl Float:validZomsPos[MAXPLAYERS+1][3];
  
  // Clear conditional bonuses
  resetStatType(ZFStatTypeCond);
  
  // Build common state information. 
  // + Survivors must be in game and alive.
  // + Zombies must be in game and alive.
  validSurCount = 0;
  validZomCount = 0;  
  for(i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i))
    {
      if(isSur(i))
      {
        validSurs[validSurCount] = i;
        GetClientAbsOrigin(i, validSursPos[validSurCount]);
        validSurCount++;
      }
      else if(isZom(i))
      {
        validZoms[validZomCount] = i;
        GetClientAbsOrigin(i, validZomsPos[validZomCount]);
        validZomCount++;
      }
    }
  }
  
  // 3. Apply conditional bonuses for survivors.
  for(i = 0; i < validSurCount; i++)
  {   
    new thisSur = validSurs[i];
    
    // DEBUG
    // PrintToChat(thisSur, "PrCl %d, PrRs %d, SeCl %d, SeRs %d", getClipAmmo(thisSur, 0), getResAmmo(thisSur, 0), getClipAmmo(thisSur, 1), getResAmmo(thisSur, 1));
       
    // Handle Perk (S): CARPENTER
    // + Update cooldown timer.
    // + Update HUD info (ability ready).
    if(usingSurPerk(thisSur, ZF_PERK_CARPENTER))
    {
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你可以放置一个新的路障..");
        }        
      }
      
      if(getFreeItemIndex(thisSur, CARPENTER_MAX_ITEMS) >= 0)
        Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(路障准备好了)" : ""));
      else
        Format(zf_perkStr[thisSur], 32, "(你已经放置了足够多的路障)");
    }    
    // Handle Perk (S): CHARITABLE
    // + Update HUD info (gifts ready).
    else if(usingSurPerk(thisSur, ZF_PERK_CHARITABLE))
    {
      if(getFreeItemIndex(thisSur, ZF_CHARITABLE_MAX_ITEMS) >= 0)
        Format(zf_perkStr[thisSur], 32, "(礼物个数: %d)", (zf_perkState[thisSur] / ZF_CHARITABLE_POINTS_GIFT));
      else
        Format(zf_perkStr[thisSur], 32, "(拥有最大数量的礼物)");
    }    
    // Handle Perk (S): COWARDLY
    // + Apply scared bonuses.
    // + Update scared timer.
    // + Update HUD info (ability ready).
    else if(usingSurPerk(thisSur, ZF_PERK_COWARDLY))
    {      
      if(zf_perkTimer[thisSur] > ZF_COWARDLY_DURATION_COOLDOWN)
      {
        addStat(thisSur, ZFStatDef, ZFStatTypeCond, ZF_COWARDLY_DEFEND);
        addStat(thisSur, ZFStatSpeed, ZFStatTypeCond, ZF_COWARDLY_SPEED);
      }
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == ZF_COWARDLY_DURATION_COOLDOWN)
        {
          PrintHintText(thisSur, "你不再恐惧.");
        }
        else if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你能被再次恐惧.");
        }
      }
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(恐惧准备好了)" : ""));
    }

    // Handle Perk (S): FRIEND
    else if(usingSurPerk(thisSur, ZF_PERK_FRIEND))
    {
      if(validLivingSur(zf_perkState[thisSur]))
      {
        // Handle passive friend bonus.
        decl Float:friendPos[3];
        GetClientAbsOrigin(zf_perkState[thisSur], friendPos);
        if(GetVectorDistance(validSursPos[i], friendPos, true) <= ZF_FRIEND_RADIUSSQ)
        {          
          addHealth(thisSur, ZF_FRIEND_REGEN);
          addHealth(zf_perkState[thisSur], ZF_FRIEND_REGEN);
          addStat(thisSur, ZFStatAtt, ZFStatTypeCond, ZF_FRIEND_ATTACK);
          addStat(zf_perkState[thisSur], ZFStatAtt, ZFStatTypeCond, ZF_FRIEND_ATTACK);    
        }
      }
      else
      {
        // Handle friend death crit time bonus.
        if(zf_perkState[thisSur] > 0)
        {
          zf_perkState[thisSur] = 0;
          PrintHintText(thisSur, "你的朋友死了!");
    
          addCondKritz(thisSur, float(zf_perkTimer[thisSur]));
          fxKritzStart(thisSur);
          fxDeathScream(thisSur);
          createAura(thisSur, ZFPART_AURAOUTRED, AttachBase);
          removeIcon(thisSur);
        }
        else
        {
          if(zf_perkTimer[thisSur] > 0)
          {
            zf_perkTimer[thisSur]--;
            if(zf_perkTimer[thisSur] == 0)
            {
              removeAura(thisSur);
              fxKritzStop(thisSur);
            }
            else
            {
              addCondKritz(thisSur, float(zf_perkTimer[thisSur]));
            }
          }
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, "(暴击时间: %d)", zf_perkTimer[thisSur]);
    }    
        
    // Handle Perk (S): HEROIC
    else if(usingSurPerk(thisSur, ZF_PERK_HEROIC))
    {
      if(validSurCount == 1)
      {
        // Activate bonus
        if(zf_perkState[thisSur] == 0)
        {
          zf_perkState[thisSur] = 1;
          PrintHintText(thisSur, "你是最后一位幸存者了!");

          addCondKritz(thisSur, float(zf_perkTimer[thisSur]));
          fxKritzStart(thisSur);
          createAura(thisSur, ZFPART_AURAOUTRED, AttachBase);
        }
        // Continue bonus
        else
        {
          if(zf_perkTimer[thisSur] > 0)
          {            
            zf_perkTimer[thisSur]--;
            if(zf_perkTimer[thisSur] == 0)
            {
              remCondKritz(thisSur);
              fxKritzStop(thisSur);
            }
            else
              addCondKritz(thisSur, float(zf_perkTimer[thisSur]));
          }
        }        
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, "(暴击时间: %d)", zf_perkTimer[thisSur]);  
    }
    
    // Handle Perk (S): HOLY
    else if(usingSurPerk(thisSur, ZF_PERK_HOLY))
    {
      if(isGrounded(thisSur) && isCrouching(thisSur) && isNotMoving(thisSur))
      {
        for(j = 0; j < validSurCount; j++)
        {
          if(GetVectorDistance(validSursPos[i], validSursPos[j], true) <= ZF_HOLY_RADIUSSQ)
          {
            addHealth(validSurs[j], ZF_HOLY_REGEN);
          }
        }
        showAura(thisSur);
      }      
      else
      {
        hideAura(thisSur);
      }
    }
    
    // Handle Perk (S): LEADER
    else if(usingSurPerk(thisSur, ZF_PERK_LEADER))
    {
      // Handle passive bonuses.
      for(j = 0; j < validSurCount; j++)
      {
        if(i == j) continue;
        if(GetVectorDistance(validSursPos[i], validSursPos[j], true) <= ZF_LEADER_OTHERS_RADIUSSQ)
        {          
          addStat(validSurs[j], ZFStatAtt, ZFStatTypeCond, ZF_LEADER_OTHERS_ATTACK);
        }
      }
      
      // Handle rally bonuses.
      new rallyCount = 0;
      decl Float:rallyPos[3];            
      if(validItem(thisSur, 0))
      {
        getEntityPos(zf_item[thisSur][0], rallyPos);
        for(j = 0; j < validSurCount; j++)
        {
          if(i == j) continue;
          if(GetVectorDistance(rallyPos, validSursPos[j], true) <= ZF_LEADER_RALLY_RADIUSSQ)
          {
            ++rallyCount;
            addStat(validSurs[j], ZFStatAtt, ZFStatTypeCond, ZF_LEADER_RALLY_OTHERS_ATTACK);
            addStat(validSurs[j], ZFStatDef, ZFStatTypeCond, ZF_LEADER_RALLY_OTHERS_DEFEND);
          }
        }
        
        addStat(validSurs[i], ZFStatAtt, ZFStatTypeCond, (rallyCount * ZF_LEADER_RALLY_SELF_ATTACK));
        addStat(validSurs[i], ZFStatDef, ZFStatTypeCond, (rallyCount * ZF_LEADER_RALLY_SELF_DEFEND));
      }
      
      // Handle timer logic.
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == ZF_LEADER_RALLY_DURATION)
        {
          PrintHintText(thisSur, "你的 集会点 消失了.");
          removeItem(thisSur, 0);
        }
        else if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你 可以 放置新的集会点.");
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(集会点准备好了)" : ""));        
    }
     
    // Handle Perk (S): NINJA
    else if(usingSurPerk(thisSur, ZF_PERK_NINJA))
    {
      // Handle timer logic.
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == ZF_NINJA_DURATION_COOLDOWN)
        {
          if(zf_perkState[thisSur] == 1)
          {
            zf_perkState[thisSur] = 0;
            removeAura(thisSur);
            PrintHintText(thisSur, "你的 诱饵能力 消失了.");
          }
        }
        else if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你的 诱饵能力 准备好了.");
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(诱饵准备好了)" : ""));         
    }
    
    // Handle Perk (S): STASH
    else if(usingSurPerk(thisSur, ZF_PERK_STASH))
    {
      // Handle pickup logic.
      if(validItem(thisSur, 0))
      {
        if(zf_perkTimer[thisSur] <= STASH_COOLDOWN)
        {
          decl Float:stashPos[3];          
          getEntityPos(zf_item[thisSur][0], stashPos);
          
          if(GetVectorDistance(validSursPos[i], stashPos, true) <= STASH_GRAB_RADSQ)
          {
            addResAmmoPct(thisSur, 0, 1.0);
            addResAmmoPct(thisSur, 1, 1.0);
            addMetal(thisSur, 200);
            addHealth(thisSur, STASH_GRAB_HEALTH, true);            
            addStatTempStack(thisSur, ZFStatAtt, STASH_GRAB_ATTACK_TEMP, STASH_GRAB_ATTACK_DURATION);
            addStat(thisSur, ZFStatAtt, ZFStatTypePerm, STASH_GRAB_ATTACK_PERM);
            
            fxEvilLaughToAll(thisSur);
            fxCreateSoundToClient(ZFSND_PACKPICKUP, thisSur);            
            removeItem(thisSur, 0);
          }
        }
      }   
      
      // Handle timer logic.
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == STASH_COOLDOWN)
        {
          PrintHintText(thisSur, "你的 藏身处准备好了.");
        }
        else if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你 可以 放置新的藏身处了.");
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(藏身)" : ""));        
    }
            
    // Handle Perk (S): STIR-CRAZY
    else if(usingSurPerk(thisSur, ZF_PERK_STIRCRAZY))
    {
      // Update rotating position buffer.
      GetClientAbsOrigin(thisSur, zf_perkPos[thisSur][zf_frameCounter % ZF_STIRCRAZY_MAX_POINTS]);
      
      // Calculate average position of previous player positions.
      new Float:avgPos[3] = {0.0, 0.0, 0.0};
      for(j = 0; j < ZF_STIRCRAZY_MAX_POINTS; j++)        
        AddVectors(avgPos, zf_perkPos[thisSur][j], avgPos);
      ScaleVector(avgPos, (1 / float(ZF_STIRCRAZY_MAX_POINTS)));
   
      // Calculate distance between current position and average position.
      // Note: Max distance (when running in a straight line is ~600).
      new dist = RoundToCeil(GetVectorDistance(avgPos, zf_perkPos[thisSur][zf_frameCounter % ZF_STIRCRAZY_MAX_POINTS], false));
      if(dist >= ZF_STIRCRAZY_DIST_MIN)
      {
        new Float:factor = fMin(1.0, dist / float(ZF_STIRCRAZY_DIST_MAX));
        addStat(thisSur, ZFStatAtt, ZFStatTypeCond, RoundToCeil(ZF_STIRCRAZY_ATTACK * factor));
      }
    }
    
    // Handle Perk (S): SUPPLIER
    else if(usingSurPerk(thisSur, ZF_PERK_SUPPLIER))
    {
      // Handle timer logic.
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "你 可以 放置 新的补给了.");
        }
      }
      
      // Handle self-resupply logic.
      if((zf_frameCounter % ZF_SUPPLIER_UPDATERATE) == 0)
      {
        addResAmmoPct(thisSur, 0, ZF_SUPPLIER_AMMOPCT_SELF, ZF_SUPPLIER_AMMOPCT_RESLIMIT);
        addResAmmoPct(thisSur, 1, ZF_SUPPLIER_AMMOPCT_SELF, ZF_SUPPLIER_AMMOPCT_RESLIMIT);
        addMetalPct(thisSur, ZF_SUPPLIER_AMMOPCT_SELF, ZF_SUPPLIER_AMMOPCT_RESLIMIT);
      }
      
      // Handle resupply logic.
      decl resupplyCount;
      decl Float:supplyPos[3];
      for(j = 0; j < ZF_SUPPLIER_MAX_ITEMS; j++)
      {        
        if(validItem(thisSur, j))
        {
          // Get resupply count.
          resupplyCount = getItemMetadata(zf_item[thisSur][j]);
          
          getEntityPos(zf_item[thisSur][j], supplyPos);
          for(k = 0; k < validSurCount; k++)
          {
            if(i == k) continue;
            if(GetVectorDistance(supplyPos, validSursPos[k], true) <= ZF_SUPPLIER_RADIUSSQ)
            {
              if((getResAmmoPct(validSurs[k], 0) < 1.0) ||
                 (getResAmmoPct(validSurs[k], 1) < 1.0))
              {
                addResAmmoPct(validSurs[k], 0, ZF_SUPPLIER_AMMOPCT_OTHER);
                addResAmmoPct(validSurs[k], 1, ZF_SUPPLIER_AMMOPCT_OTHER);
                addMetalPct(validSurs[k], ZF_SUPPLIER_AMMOPCT_OTHER);
                addStatTempStack(thisSur, ZFStatAtt, ZF_SUPPLIER_ATTACK, ZF_SUPPLIER_DURATION);
                fxCreateSoundToClient(ZFSND_PACKPICKUP, validSurs[k]);
                
                resupplyCount--;
                if(resupplyCount == 0) break;
              }
            }
          }
          
          // Set resupply count.
          setItemMetadata(zf_item[thisSur][j], resupplyCount);
                      
          if(resupplyCount == 0)
            removeItem(thisSur, j);
        }
      }
      
      // Handle HUD string.
      if(getFreeItemIndex(thisSur, ZF_SUPPLIER_MAX_ITEMS) >= 0)
        Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(补给箱准备好了)" : ""));
      else
        Format(zf_perkStr[thisSur], 32, "(你 放置了最大数量的补给箱了)");
    }
    
    // Handle Perk (S): TANTRUM
    else if(usingSurPerk(thisSur, ZF_PERK_TANTRUM))
    {
      // Handle timer logic.      
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;  
        if(zf_perkTimer[thisSur] == 0)
        {
          PrintHintText(thisSur, "发怒准备好了!");
        }
        else if(zf_perkTimer[thisSur] == ZF_TANTRUM_COOLDOWN)
        {      
          fxKritzStop(thisSur);
          PrintHintText(thisSur, " 你疲惫了!");
        }
      }
      
      // Handle state logic.
      if(zf_perkTimer[thisSur] > ZF_TANTRUM_COOLDOWN) // Tantrum active
      {
         addCondKritz(thisSur, float(zf_perkTimer[thisSur] - ZF_TANTRUM_COOLDOWN));
      }
      else if(zf_perkTimer[thisSur] > 0) // Tantrum cooldown
      {
        addStat(thisSur, ZFStatSpeed, ZFStatTypeCond, ZF_TANTRUM_SPEED);
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(能力准备好了)" : ""));
    }
            
    // Handle Perk (S): TRAITOR
    else if(usingSurPerk(thisSur, ZF_PERK_TRAITOR))
    {
      for(j = 0; j < validZomCount; j++)
      {
        if(GetVectorDistance(validSursPos[i], validZomsPos[j], true) <= ZF_TRAITOR_RADIUSSQ)
        {
          addStat(validZoms[j], ZFStatCrit, ZFStatTypeCond, ZF_TRAITOR_CRIT_ZOM);
        }
      }

      if(validSurCount == 2)
      { 
        SDKHooks_TakeDamage(validSurs[1-i], 0, 0, float(ZF_TRAITOR_POISON), ZF_DMGTYPE_POISON);          
        zf_lastPoison[validSurs[1-i]] = 0;

        if(zf_perkState[thisSur] == 0)
        { 
          zf_perkState[thisSur] = 1;
          PrintHintText(thisSur, "你背叛了 %N!", validSurs[1-i]);
          PrintHintText(validSurs[1-i], "%N 背叛了 你!", thisSur);
          fxEvilLaughToClient(thisSur, validSurs[1-i]);
        }
      }
    }
    
    // Handle Perk (S): TRAPPER
    else if(usingSurPerk(thisSur, ZF_PERK_TRAPPER))
    {
      // Handle mine detection and detonation.
      for(j = 0; j < ZF_TRAPPER_MAX_ITEMS; j++)
      {
        if(validItem(thisSur, j))
        {        
          decl bool:mineDisabled;
          decl bool:mineTriggered;
          decl mineTarget;
          decl Float:minePos[3]; 
          
          // Determine whether mine has detonated or is disabled.
          mineDisabled = false;
          mineTriggered = false;
          getEntityPos(zf_item[thisSur][j], minePos);
          for(k = 0; k < validZomCount; k++)
          {        
            if(GetVectorDistance(minePos, validZomsPos[k], true) <= ZF_TRAPPER_RADIUSSQ)
            {
              if(usingZomPerk(validZoms[k], ZF_PERK_MAGNETIC))
              {
                mineDisabled = true;
              }
              else
              {
                mineTriggered = true;
                mineTarget = validZoms[k];
              }
              break;
            }   
          }
          
          // Detonate or disable mine.
          if(mineTriggered && !mineDisabled)
          {
            TF2_IgnitePlayer(mineTarget, thisSur);
            minePos[2] += 8.0;
            applyDamageRadial(thisSur, ZF_TRAPPER_DAMAGE, minePos, ZF_TRAPPER_RADIUS, true);  
            fxExplosionBig(zf_item[thisSur][j]);
            removeItem(thisSur, j);          
          }
          else if(mineDisabled)
          {
            fxSpark(zf_item[thisSur][j]);
          }
          else
          {
            fxCreateSoundToAll(ZFSND_TICK, zf_item[thisSur][j]);
          }
        }
      }
      
      // Handle timer
      if(zf_perkTimer[thisSur] > 0)
      {
        zf_perkTimer[thisSur]--;
        if(zf_perkTimer[thisSur] == 0)
          PrintHintText(thisSur, "你 可以 放置 另一个地雷了!");
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisSur], 32, (zf_perkTimer[thisSur] == 0 ? "(地雷准备好了)" : ""));        
    }
    
    // Handle Perk (S): ZENLIKE
    else if(usingSurPerk(thisSur, ZF_PERK_ZENLIKE))
    { 
      if(isGrounded(thisSur) && isCrouching(thisSur) && isNotMoving(thisSur))
      {
        zf_perkState[thisSur] += ZF_ZENLIKE_CRIT_INC;
        if(zf_perkState[thisSur] > 100) 
          zf_perkState[thisSur] = 100;
          
        addHealth(thisSur, ZF_ZENLIKE_REGEN);
        subCond(thisSur, ZFCondPoisoned, ZF_ZENLIKE_HEAL);        
      }
      addStat(thisSur, ZFStatCrit, ZFStatTypeCond, zf_perkState[thisSur]);
    }
  }
   
  // 4. Apply conditional bonuses for zombies.
  for(i = 0; i < validZomCount; i++)
  {
    new thisZom = validZoms[i];
         
    // Handle Perk (Z): ALPHA
    if(usingZomPerk(thisZom, ZF_PERK_ALPHA))
    {
      // Handle timer
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == 0)
          PrintHintText(thisZom, "阿尔法准备好了!");
      }
    
      // Handle bonuses
      new attBonus = 0;
      new regBonus = 0;
      for(j = 0; j < validZomCount; j++)
      {
        if(i == j) continue;
        if(GetVectorDistance(validZomsPos[i], validZomsPos[j], true) <= ZF_ALPHA_RADIUSSQ)
        {
          if(zf_perkAlphaMaster[validZoms[j]] > 0)
          {
            attBonus += ZF_ALPHA_ATTACK_MINION;
            regBonus += ZF_ALPHA_REGEN_MINION;
          }
          else
          {
            attBonus += ZF_ALPHA_ATTACK;
            regBonus += ZF_ALPHA_REGEN;            
          }
        }
      }
      addStat(thisZom, ZFStatAtt, ZFStatTypeCond, attBonus);
      addHealth(thisZom, regBonus);
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(传送准备好了)" : ""));          
    }     
         
    // Handle Perk (Z): COMBUSTIBLE
    else if(usingZomPerk(thisZom, ZF_PERK_COMBUSTIBLE))
    {
      fxExplosionTiny(thisZom);
    }

    // Handle Perk (Z): HUNTER
    else if(usingZomPerk(thisZom, ZF_PERK_HUNTER))
    {
      Format(zf_perkStr[thisZom], 32, (validAura(thisZom) ? "(激活)" : "(没有激活)"));              
    }
    
    // Handle Perk (Z): LEAP
    else if(usingZomPerk(thisZom, ZF_PERK_LEAP))
    {
      // Handle timer.
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == 0)
          PrintHintText(thisZom, "飞跃准备好了!");
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(能力准备好了)" : ""));         
    }
    
    // Handle Perk (Z): MARKED
    else if(usingZomPerk(thisZom, ZF_PERK_MARKED))
    {
      //
      // No mark exists.
      // Do not attempt to select a mark.
      //
      if(zf_perkState[thisZom] == -1)
      {
        // Do nothing.
      }
      //
      // No mark exists. 
      // Wait until timer reaches zero before selecting new mark.
      //
      else if(zf_perkState[thisZom] == 0)
      {
        if(zf_perkTimer[thisZom] > 0)
        {
          zf_perkTimer[thisZom]--;
        }
        else
        {
          doMarkedSelect(thisZom);
        }
      }
      //
      // Mark exists. 
      // Monitor mark until he dies, then initiate timer.
      //
      else
      {
        if(!validLivingSur(zf_perkState[thisZom]))
        {            
          zf_perkState[thisZom] = 0;
          zf_perkTimer[thisZom] = ZF_MARKED_TIMER;
          removeIcon(thisZom);
          PrintHintText(thisZom, "寻找新的标记中...");
        }
      }
    }
  
    // Handle Perk (Z): RAGE
    else if(usingZomPerk(thisZom, ZF_PERK_RAGE))
    {
      // Handle cooldown when rage is not active.
      if(zf_perkState[thisZom] == 0)
      {
        if(zf_perkTimer[thisZom] > 0)
        {
          zf_perkTimer[thisZom]--;
          if(zf_perkTimer[thisZom] == 0)
            PrintHintText(thisZom, "愤怒准备好了!");
        }
      }
      // Handle logic when rage is active.
      else
      {
        if(getHealthPct(thisZom) >= ZF_RAGE_HEALTHPCT_TOUSE)
        {
          addStat(thisZom, ZFStatSpeed, ZFStatTypeCond, ZF_RAGE_SPEED);
        }
        else
        {
          zf_perkState[thisZom] = 0;
          removeAura(thisZom);
          PrintHintText(thisZom, "愤怒消失了.");
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(能力准备好了)" : ""));      
    }
    
    // Handle Perk (Z): ROAR
    else if(usingZomPerk(thisZom, ZF_PERK_ROAR))
    {
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == 0)
          PrintHintText(thisZom, "狂怒准备好了!");
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(能力准备好了)" : ""));   
    }    
    
    // Handle Perk (Z): SCORCHING
    else if(usingZomPerk(thisZom, ZF_PERK_SCORCHING))
    {    
      if(!isInWater(thisZom))
        TF2_IgnitePlayer(thisZom, thisZom);
    }
    
    // Handle Perk (Z): SICK
    else if(usingZomPerk(thisZom, ZF_PERK_SICK))
    {
      // Handle timer events
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == 0)
        {
          removeItems(thisZom);
          PrintHintText(thisZom, "吐痰准备好了!");
        }
      }
            
      // Handle bonus logic
      for(j = 0; j < ZF_SICK_MAX_ITEMS; j++)
      {
        if(validItem(thisZom, j))
        {
          if(getItemMetadata(zf_item[thisZom][j]) == 1)
          {
            applyDamageRadial(thisZom, ZF_SICK_DAMAGE, zf_perkPos[thisZom][j], ZF_SICK_DAMAGE_RADIUS);
          }
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(吐痰准备好了)" : ""));      
    }

    // Handle Perk (Z): TARRED
    else if(usingZomPerk(thisZom, ZF_PERK_TARRED))
    {
      // Handle timer events
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == 0)
        {
          removeItems(thisZom);
          PrintHintText(thisZom, "吐焦油准备好了!");
        }
      }
            
      // Handle bonus logic
      for(j = 0; j < ZF_TARRED_MAX_ITEMS; j++)
      {
        if(validItem(thisZom, j))
        {
          if(getItemMetadata(zf_item[thisZom][j]) == 1)
          {
            applyDamageRadial(thisZom, 1, zf_perkPos[thisZom][j], ZF_TARRED_RADIUS);
          }
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(吐痰准备好了)" : ""));  
      
      // Render color.
      fxSetClientColor(thisZom, 25, 25, 25, 255);
    }
        // Handle Perk (S): TANK
    else if(usingZomPerk(thisZom, ZF_PERK_TANK))
    {
      // Handle FROG bonuses.
      new frogCount = 0;
      decl Float:frogPos[3];
      if(validItem(thisZom, 0))
      {
        getEntityPos(zf_item[thisZom][0], frogPos);
        for(j = 0; j < validZomCount; j++)
        {
          if(i == j) continue;
          if(GetVectorDistance(frogPos, validZomsPos[j], true) <= ZF_TANK_FROG_RADIUSSQ)
          {
            ++frogCount;
            addStat(validZoms[j], ZFStatDef, ZFStatTypeCond, ZF_TANK_FROG_DEFEND);
            addStat(validZoms[j], ZFStatSpeed, ZFStatTypeCond, ZF_TANK_FROG_SPEED);
          }
        }
      }
      
      // Handle timer logic.
      if(zf_perkTimer[thisZom] > 0)
      {
        zf_perkTimer[thisZom]--;
        if(zf_perkTimer[thisZom] == ZF_TANK_FROG_DURATION)
        {
          PrintHintText(thisZom, "你的 青蛙 消失了.");
          removeItem(thisZom, 0);
        }
        else if(zf_perkTimer[thisZom] == 0)
        {
          PrintHintText(thisZom, "你 可以 放置新的青蛙.");
        }
      }
      
      // Handle HUD string.
      Format(zf_perkStr[thisZom], 32, (zf_perkTimer[thisZom] == 0 ? "(青蛙准备好了)" : ""));        
    }
     
    // Handle Perk (Z): TOXIC
    else if(usingZomPerk(thisZom, ZF_PERK_TOXIC))
    {
      // Apply poison to nearby survivors.
      if(isNotMoving(thisZom) && !isCloaked(thisZom))
      {
        for(j = 0; j < validSurCount; j++)
        {
          if(isUbered(validSurs[j])) continue;
          if(GetVectorDistance(validZomsPos[i], validSursPos[j], true) <= ZF_TOXIC_RADIUSSQ)
          {
            SDKHooks_TakeDamage(validSurs[j], thisZom, thisZom, float(ZF_TOXIC_DAMAGE_PASSIVE), ZF_DMGTYPE_POISON); 
            zf_lastPoison[validSurs[j]] = thisZom;
          }
        }        
      }
      
      // Render color.
      fxSetClientColor(thisZom, 50, 200, 50, 255);
    }
    
    // Handle Perk (Z): VAMPIRIC
    else if(usingZomPerk(thisZom, ZF_PERK_VAMPIRIC))
    {
      addHealth(thisZom, ZF_VAMPIRIC_REGEN);
    }       
    
    //
    // Handle general zombie logic.
    //
    
    // Hide auras on cloaked zombies.
    isCloaked(thisZom) ? hideAura(thisZom) : showAura(thisZom);
  }

  // Handle Perk (Z): HUNTER
  // * Destroy spawn marks near survivors
  for(i = 1; i <= MaxClients; i++)
  {
    if(validZom(i) && usingZomPerk(i, ZF_PERK_HUNTER) && validAura(i))
    {
      decl Float:spawnPos[3];
      getEntityPos(zf_aura[i], spawnPos);
        
      for(j = 0; j < validSurCount; j++)
      {
        if(GetVectorDistance(spawnPos, validSursPos[j], true) <= ZF_HUNTER_RADIUSSQ)
        {
          PrintHintText(i, "你的出生标记被破坏了!");
          PrintHintText(validSurs[j], "你破坏了僵尸的出生标记!");
          removeAura(i);
          break;
        }
      }
    }
  }
      
  // Handle Perk (Z): MAGNETIC
  // * Disable all sentries that are near a zombie using the MAGNETIC perk.
  new index = -1;
  while ((index = FindEntityByClassname(index, "obj_sentrygun")) != -1)
  {  
    decl Float:sentPos[3];
    getEntityPos(index, sentPos);
    
    // Determine if sentry is disabled.
    new bool:sentryDisabled = false;
    for(i = 0; i < validZomCount; i++)
    {
      if(usingZomPerk(validZoms[i], ZF_PERK_MAGNETIC)) 
      {
        if(GetVectorDistance(sentPos, validZomsPos[i], true) <= ZF_MAGNETIC_RADIUSSQ)
        {
          sentryDisabled = true;
          break;
        }
      }
    }

    // Handle sentry disable logic.
    if(sentryDisabled)
    {
      SetEntProp(index, Prop_Send, "m_bDisabled", 1);
      fxSpark(index);
    }
    else
    {
      SetEntProp(index, Prop_Send, "m_bDisabled", 0);
    }
  }  
}

stock updateTempStats()
{  
  for(new i = 0; i < MAXPLAYERS; i++)
  {
    for(new j = 0; j < TOTAL_ZFSTATS; j++)
    {
      // Clear temp bonus if duration reaches zero.
      zf_stat[i][j][ZFStatTypeTempDuration]--;
      if(zf_stat[i][j][ZFStatTypeTempDuration] <= 0)
      {
        zf_stat[i][j][ZFStatTypeTemp] = 0;
        zf_stat[i][j][ZFStatTypeTempDuration] = 0;
      }
    }
  }
}

stock updateConds()
{
  for(new i = 0; i < MAXPLAYERS; i++)
  {
    for(new j = 0; j < TOTAL_ZFCONDS; j++)
    {
      if(zf_cond[i][j] > 0)
        zf_cond[i][j]--;
    }
  }
}

////////////////////////////////////////////////////////////
//
// Perk Event Logic, Timing / Round State Events
//
////////////////////////////////////////////////////////////
public perk_OnPeriodic() // 1Hz
{ 
  decl i;
  decl validCount;
  decl validClients[MAXPLAYERS+1];
    
  zf_frameCounter++;

  // 
  // Update conditional and temporary bonuses.
  //
  updateConds();
  updateTempStats();  
  updateCondStats();
    
  //
  // Build common state information. 
  // + Clients must be in game and alive.
  //
  validCount = 0;
  for(i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i))
    {
      if(isSur(i) || isZom(i)) 
        validClients[validCount++] = i;      
    }
  }
      
  for(i = 0; i < validCount; i++)
  {  
    new thisClient = validClients[i];

    //
    // Apply Condition: Crippled
    // + Create blood effects.
    //
    if(getCond(thisClient, ZFCondCrippled))
    {
      if(GetRandomInt(0,3) == 1)
        fxBloodBurst(thisClient);
      if(GetRandomInt(0,3) == 1)
        fxBloodSpray(thisClient);
      if(GetRandomInt(0,3) == 1)
        fxPain(thisClient);      
    }
    
    //
    // Apply Condition: Intimidated
    // + Apply defense penalty.
    //
    if(getCond(thisClient, ZFCondIntimidated))
    {
      addStat(thisClient, ZFStatDef, ZFStatTypeCond, ZF_DAZE_DEFEND);
    }
        
    //
    // Apply Condition: Poisoned
    // + Apply poison damage.
    //
    if(getCond(thisClient, ZFCondPoisoned))
    {
      if(isBeingHealed(thisClient))
        subCond(thisClient, ZFCondPoisoned, ZF_POISON_HEAL_MEDIC);
      if(isUbered(thisClient))
        subCond(thisClient, ZFCondPoisoned, ZF_POISON_HEAL_UBER);

      SDKHooks_TakeDamage(thisClient, zf_lastPoison[thisClient], zf_lastPoison[thisClient], float(ZF_POISON_DAMAGE), ZF_DMGTYPE_POISON); 
      fxHealthLost(thisClient);      
    }
       
    //
    // Handle Condition: Tracked
    // + Reveal glow around client.
    //
    setGlow(thisClient, getCond(thisClient, ZFCondTracked));
  }
  
  //
  // Handle HUD updates. 
  // Do not update at end of round.
  //
  if(roundState() != RoundPost)
  {
    for(i = 1; i <= MaxClients; i++)
    {
      updateHud(i);
    }
  }
}

public perk_OnGameFrame()
{
  decl Float:collidePos[3];
  decl Float:collideVec[3];
  
  for(new i = 1; i <= MaxClients; i++)
  {
    if(IsClientInGame(i) && IsPlayerAlive(i))
    {
      //
      // Handle Condition: Crippled
      // + Prevent health gain.
      //
      if(getCond(i, ZFCondCrippled))
      {
        zf_lastHealth[i] = min(GetClientHealth(i), zf_lastHealth[i]);
        zf_lastHealth[i] = max(1, zf_lastHealth[i]);
        SetEntityHealth(i, zf_lastHealth[i]);
      }
      
      //
      // Handle rate of fire calculations.
      // 
      if(zf_lastAttack[i] == 1)
      {
        zf_lastAttack[i] = 0;
        if((getStat(i, ZFStatRof) != 0) && !isWieldingAuto(i))
        {
          setWeaponRof(activeWeapon(i), getStat(i, ZFStatRof));
        }        
      } 
    
      //
      // Handle zombie logic.
      //
      if(isZom(i))
      {
        // Handle Perk (Z): SICK
        if(usingZomPerk(i, ZF_PERK_SICK))
        {
          for(new j = 0; j < ZF_SICK_MAX_ITEMS; j++)
          {
            if(validItem(i, j))
            {
              // Check for collision for projectiles only.
              if(getItemMetadata(zf_item[i][j]) == 0)
              {
                if(doItemCollide(zf_item[i][j], zf_perkPos[i][j], collidePos, collideVec))
                {
                  removeItem(i, j);
                  zf_item[i][j] = doItemImpact(i, collidePos, collideVec, {100, 200, 100});
                  setItemMetadata(zf_item[i][j], 1);
                  fxBits(zf_item[i][j]);
                }

                getEntityPos(zf_item[i][j], zf_perkPos[i][j]);
              }
            }
          }
        }

        // Handle Perk (Z): TARRED
        else if(usingZomPerk(i, ZF_PERK_TARRED))
        {
          for(new j = 0; j < ZF_TARRED_MAX_ITEMS; j++)
          {
            if(validItem(i, j))
            {
              // Check for collision for projectiles only.
              if(getItemMetadata(zf_item[i][j]) == 0)
              {
                if(doItemCollide(zf_item[i][j], zf_perkPos[i][j], collidePos, collideVec))
                {
                  removeItem(i, j);
                  zf_item[i][j] = doItemImpact(i, collidePos, collideVec, {25, 25, 25});
                  setItemMetadata(zf_item[i][j], 1);
                  fxBits(zf_item[i][j]);
                }
                
                getEntityPos(zf_item[i][j], zf_perkPos[i][j]);
              }
            }
          }
        }
        
        // Handle Perk (Z): THIEVING
        else if(usingZomPerk(i, ZF_PERK_THIEVING))
        {
          if(zf_perkState[i] > 0)
          {
            doThievingLimit(i);
          }
        }
                
      } // isZom(i)
    } // Client in game and alive.
  } // for i
}

public perk_OnMapStart()
{ 
  utilFxPrecache(); 
  resetAllClients();
}

public perk_OnMapEnd()
{
  resetAllClients();
}

public perk_OnClientConnect(client)
{
  resetClient(client);
  if(prefGet(client, PerkSelectMode) > 1)
    prefSet(client, PerkSelectMode, 0);
}

public perk_OnClientDisconnect(client)
{
  resetClient(client);
}

public perk_OnRoundStart()
{
  resetAllClients();
 
  //
  // Handle ZF Mode Selection
  //
  zf_perkMode = zf_perkPendingMode;

  //
  // Reset perk select mode.
  //
  for(new i = 1; i <= MaxClients; i++)
    prefSet(i, PerkSelectMode, 0);
        
  //
  // Select random team perks.
  //
  if(zf_perkMode == 2)
  {
    new validSurPerkCount = 0;
    new validZomPerkCount = 0;   
    decl validSurPerks[TOTAL_SUR_PERKS];
    decl validZomPerks[TOTAL_ZOM_PERKS];
       
    for(new i = 1; i < TOTAL_SUR_PERKS; i++)
      if(surPerkEnabled(i))
        validSurPerks[validSurPerkCount++] = i;
    zf_perkRandSurPerk = (validSurPerkCount == 0) ? ZF_PERK_NONE : validSurPerks[GetRandomInt(0, validSurPerkCount - 1)];

    for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
      if(zomPerkEnabled(i))
        validZomPerks[validZomPerkCount++] = i;
    zf_perkRandZomPerk = (validZomPerkCount == 0) ? ZF_PERK_NONE : validZomPerks[GetRandomInt(0, validZomPerkCount - 1)];
  }
}

public perk_OnGraceEnd()
{
  for(new i = 1; i <= MaxClients; i++)
  {
    //
    // Handle survivor logic. 
    // Survivors must be alive, otherwise they will respawn as a zombie.
    //
    if(validLivingSur(i))
    {
      // Handle Perk (S): FRIEND
      // + Select random friend unless friend al准备好了 selected.
      if(usingSurPerk(i, ZF_PERK_FRIEND))
      {
        if(zf_perkState[i] == 0)
          doFriendSelect(i);
      }
    }
    
    //
    // Handle zombie logic.
    //
    else if(validZom(i))
    {
      // Handle Perk (Z): MARKED
      if(usingZomPerk(i, ZF_PERK_MARKED))
        doMarkedSelect(i);
    }
  }
}

public perk_OnRoundEnd()
{    
  resetAllClients();
}

////////////////////////////////////////////////////////////
//
// Perk Event Logic, Entity Events
//
////////////////////////////////////////////////////////////
public perk_OnEntityCreated(entity, const String:classname[])
{
  if(StrEqual(classname, "env_sprite"))
    SDKHook(entity, SDKHook_Spawn, perk_OnEntitySpawn);
}

public perk_OnEntitySpawn(entity)
{
  // TODO consider use of m_hEffectEntity for sprites to further filter?
  SDKHook(entity, SDKHook_SetTransmit, perk_OnSetTransmit);
}

public Action:perk_OnSetTransmit(entity, client)
{
  if(isSur(client))
  {
    // Handle Perk (S): FRIEND
    // Show entity to client iff this is client's friend icon.
    // (This icon appears over client's friend)
    if(usingSurPerk(client, ZF_PERK_FRIEND))
    {
      if(zf_icon[client][ICON_SPR] == entity)
        return Plugin_Continue;
    }
  }
  else if(isZom(client))
  {
    // Handle Perk (Z): MARKED
    // Show entity to client iff this is client's marked icon.
    // (This icon appears over client's mark)    
    if(usingZomPerk(client, ZF_PERK_MARKED))
    {
      if(zf_icon[client][ICON_SPR] == entity)
        return Plugin_Continue;
    }
  }
  return Plugin_Handled;
}

public perk_OnCharitableGiftTouched(entity, other)
{
  static String:zf_statStr[ZFStat][16] = { "Attack", "Crit", "Defense", "Rate of Fire", "Speed" };
  
  //
  // Determine gift owner.
  //
  new giftOwner = -1;  
  new giftIndex = -1;
  for(new i = 1; i <= MaxClients; i++)
  {
    for(new j = 0; j < ZF_CHARITABLE_MAX_ITEMS; j++)
      if(zf_item[i][j] == entity)
      {
        giftOwner = i;
        giftIndex = j;
      }
  }
   
  // 
  // Handle gift bonus generation and pickup.
  // + Gift owner can't pick up gift.
  // + Other survivors receive stat bonus.
  //
  if(validLivingClient(other))
  {
    if(other == giftOwner) return;
      
    // Calculate gift bonus.
    new randStat = GetRandomInt(0, (TOTAL_ZFSTATS - 1));
    new randBonus = GetRandomInt(ZF_CHARITABLE_GIFT_BONUS_MIN, ZF_CHARITABLE_GIFT_BONUS_MAX);
    
    // Apply gift bonus.
    if(isSur(other))
    {
      PrintHintText(other, "%s 加成了 %d!", zf_statStr[ZFStat:randStat], randBonus);    
      addStatTempStack(other, ZFStat:randStat, randBonus, ZF_CHARITABLE_GIFT_DURATION);    
      addHealth(giftOwner, ZF_CHARITABLE_GIFT_BONUS_HEALTH, true);
    }
    
    fxExplosionParty(entity);     
    removeItem(giftOwner, giftIndex);
  }
}

////////////////////////////////////////////////////////////
//
// Perk Event Logic, Player Gameplay Events
//
////////////////////////////////////////////////////////////
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon) 
{ 
  new prevButtons = buttons;
  
  if(isSur(client))
  {
    // Handle Perk (S): NINJA
    if(usingSurPerk(client, ZF_PERK_NINJA))
    {
      if((buttons & IN_JUMP) && !(zf_lastButtons[client] & IN_JUMP))
      {
        if(isGrounded(client) && !isDazed(client))
        {
          fxJump(client, ZF_NINJA_FORCE, true); 
          fxPuffSmall(client);                  
        }
      }
    }
  }
  else if(isZom(client))
  {
    // Handle Perk (Z): COMBUSTIBLE
    if(usingZomPerk(client, ZF_PERK_COMBUSTIBLE))
    {
      if(isScout(client) && (buttons & IN_ATTACK) && isWielding(client, ZFWEAP_BONK))
      {
        buttons &= ~IN_ATTACK;
        if(!(zf_lastButtons[client] & IN_ATTACK))
          PrintHintText(client, "当使用易燃人时 不可以喝原子能饮料! .");       
      }
      
      if(isSpy(client) && (buttons & IN_ATTACK2))
      {
        buttons &= ~IN_ATTACK2;
        if(!(zf_lastButtons[client] & IN_ATTACK2))
          PrintHintText(client, "当使用易燃人时 不可以伪装.");
      }
    }
    
    // Handle Perk (Z): SCORCHING
    else if(usingZomPerk(client, ZF_PERK_SCORCHING))
    {
      if(isScout(client) && (buttons & IN_ATTACK) && isWielding(client, ZFWEAP_BONK))
      {
        buttons &= ~IN_ATTACK;
        if(!(zf_lastButtons[client] & IN_ATTACK))
          PrintHintText(client, "当使用极热时  不可以喝原子能饮料."); 
      }
    }    
  }
  
  // Save buttons for next call.
  zf_lastButtons[client] = prevButtons;
  return Plugin_Continue;
}

public perk_OnCalcIsAttackCritical(client)
{
  // DEBUG
  //PrintToChatAll("[VSH-ZF] CalcCrit (%d, slot %d)", client, activeWeaponSlot(client));
  
  if(validLivingSur(client))
  {
    // Handle Perk (S): ZENLIKE
    if(usingSurPerk(client, ZF_PERK_ZENLIKE))
    {
      CreateTimer(0.1, perk_tZenlikeAttack, client, TIMER_FLAG_NO_MAPCHANGE);
    }
  }
  
  // Handle general RoF logic.
  zf_lastAttack[client] = 1;
}

public Action:perk_OnFenceTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
//    // DEBUG
//    decl String:inflictorClass[32];
//    GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass));
//    PrintToChatAll("\x05[ZF DEBUG]\x01 Vic %d, Att %d, Inf %d (%s), Dmg %f, DTp %x", victim, attacker, inflictor, inflictorClass, damage, damagetype);

  new fenceOwner = -1;
  new fenceIndex = -1;
  new fenceHP;
  new fenceFx;
  new Float:off[3];
  
  //
  // Determine fence owner and index.
  //
  for(new i = 1; i <= MaxClients; i++)
  {
    for(new j = 0; j < CARPENTER_MAX_ITEMS; j++)
    {
      if(victim == zf_item[i][j])
      {
        fenceOwner = i;
        fenceIndex = j;
        fenceHP = getItemMetadata(zf_item[i][j]);
        fenceFx = (fenceHP * 255) / CARPENTER_BARRICADE_HEALTH;
      }
    }
  }
  
  //
  // Adjust fence health.
  //
  if(fenceOwner != -1)
  {
    fenceHP -= RoundToCeil(damage);
    if(fenceHP <= 0)
    {
      // Barricade destruction effects
      off[2] -= 120.0; // Adjust for ZFMDL_FENCE
      fxCreateParticle(ZFPART_PUFFBIG, victim, AttachNone, 4.0, off); 
      fxCreateSoundToAll(ZFSND_WOOD_HIT[GetRandomInt(2,3)], victim);
        
      removeItem(fenceOwner, fenceIndex);
    }
    else
    {     
      setItemMetadata(zf_item[fenceOwner][fenceIndex], fenceHP);
      SetEntityRenderMode(zf_item[fenceOwner][fenceIndex], RENDER_TRANSCOLOR);
      SetEntityRenderColor(zf_item[fenceOwner][fenceIndex], 255, fenceFx, fenceFx, 255); 
    }
  }
  else
  {
    // Remove fence.
    LogError("[VSH-ZF] - perk_OnFenceTakeDamage() - Invalid owner of fence (%d)", victim);
    AcceptEntityInput(victim, "Kill");
  }
}

public Action:perk_OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{ 
//   // DEBUG
//   decl String:inflictorClass[32];
//   GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass));
//   PrintToChatAll("\x05[ZF DEBUG]\x01 Vic %d, Att %d, Inf %d (%s), Dmg %f, DTp %x", victim, attacker, inflictor, inflictorClass, damage, damagetype);

  new localAttAdjust = 0;
  new localDefAdjust = 0;
  
  //
  // Ignore perk damage events for ubered victims.
  // 
  if(validClient(victim) && isUbered(victim))
    return Plugin_Continue;

  //
  // Attribute poison damage.
  //
  if(damagetype & ZF_DMGTYPE_POISON)
  {
    if(validClient(victim) && (validSur(zf_lastPoison[victim]) || validZom(zf_lastPoison[victim])))
    {
      attacker = zf_lastPoison[victim];      
    }
    return Plugin_Changed;
  }
   
  //
  // Calculate attack (from attacker) and defense (from victim) damage adjustments.
  //
  if(validLivingClient(attacker) && (victim != attacker))
    localAttAdjust = getStat(attacker, ZFStatAtt);
  if(validLivingClient(victim) && (victim != attacker))
    localDefAdjust = getStat(victim, ZFStatDef);
  
  //
  // Reduce sentry attack bonuses by half.
  //
  if(entIsSentry(inflictor))
    localAttAdjust /= 2;
    
  //
  // Survivor is taking damage from zombie.
  //
  if(validSur(victim) && validZom(attacker))
  {
    //
    // Melee attacks.    
    //
    if(attackWasMelee(attacker, inflictor, damagetype))
    {
      // Handle Perk (S): COWARDLY
      // + Scare victim on melee hit.
      if(usingSurPerk(victim, ZF_PERK_COWARDLY))
      {
        if(zf_perkTimer[victim] == 0)
        {
          zf_perkTimer[victim] = ZF_COWARDLY_DURATION_SCARED + ZF_COWARDLY_DURATION_COOLDOWN;
  
          addStat(victim, ZFStatDef, ZFStatTypeCond, ZF_COWARDLY_DEFEND);
          addStat(victim, ZFStatSpeed, ZFStatTypeCond, ZF_COWARDLY_SPEED);
  
          PrintHintText(victim, "你被打了! 快跑吧!");
          fxYikes(victim);
          
          damage = 0.0;
        }          
      }
      // Handle Perk (S): NINJA
      // + Activate decoy on melee hit.
      else if(usingSurPerk(victim, ZF_PERK_NINJA))
      {
        if(zf_perkState[victim] == 1)
        {
          zf_perkState[victim] = 0;
          CreateTimer(float(ZF_NINJA_DURATION_DECOY_DECAY), perk_tNinjaDecoyPoof, victim, TIMER_FLAG_NO_MAPCHANGE);
  
          doNinjaDecoyPlace(victim);        
          fxCreateSoundToClient(ZFSND_BOING, victim);
          fxCreateSoundToClient(ZFSND_BOING, attacker);          
          
          PrintHintText(victim, "诱饵激活了.");
          PrintHintText(attacker, "你被诱饵糊弄了.");
          
          damage = 0.0;      
        }
      }
      // Handle Perk (S): TURTLE
      // + Block backstabs.
      else if(usingSurPerk(victim, ZF_PERK_TURTLE))
      {
        if(attackWasBackstab(attacker, inflictor, damagetype))
        {
          TF2_StunPlayer(attacker, ZF_TURTLE_STUN_DURATION, 0.0, TF_STUNFLAGS_NORMALBONK, victim);        
          PrintHintText(attacker, "你的背刺被禁止了!");
          
          fxSpark(victim);   
          PrintHintText(victim, "你禁止了一次背刺!");
     
          damage = 0.0;
        } 
      }
      // Handle Perk (S): WISE
      // + Increase defense with each melee hit.
      else if(usingSurPerk(victim, ZF_PERK_WISE))
      {
        if(getStatType(victim, ZFStatDef, ZFStatTypePerm) < ZF_WISE_DEFEND_LIMIT)
          addStat(victim, ZFStatDef, ZFStatTypePerm, ZF_WISE_DEFEND);
      }

      // Handle Perk (Z): HORRIFYING
      // + Apply penalties with each melee hit.
      if(usingZomPerk(attacker, ZF_PERK_HORRIFYING))
      {
        if(isHeavy(attacker))
        {
          addStatTempStack(victim, ZFStatAtt, HORRIFYING_ATTACK_HEAVY, HORRIFYING_DURATION_HEAVY);
          addStatTempStack(victim, ZFStatDef, HORRIFYING_DEFEND_HEAVY, HORRIFYING_DURATION_HEAVY);
          addStatTempStack(victim, ZFStatRof, HORRIFYING_ROF_HEAVY, HORRIFYING_DURATION_HEAVY);
        }
        else
        {
          addStatTempStack(victim, ZFStatAtt, HORRIFYING_ATTACK, HORRIFYING_DURATION);
          addStatTempStack(victim, ZFStatDef, HORRIFYING_DEFEND, HORRIFYING_DURATION);       
        }
      }
      // Handle Perk (Z): MARKED
      // + Adjust damage on/off mark with each melee hit.
      else if(usingZomPerk(attacker, ZF_PERK_MARKED))
      {
        if(zf_perkState[attacker] == victim)
          localAttAdjust += ZF_MARKED_ATTACK_ON_MARK;
        else
          localAttAdjust += ZF_MARKED_ATTACK_OFF_MARK;
      }
      // Handle Perk (Z): SCORCHING
      // + Ignite victim on melee hit.
      // + Adjust damage for melee attacks.
      else if(usingZomPerk(attacker, ZF_PERK_SCORCHING))
      {
        if(!isPyro(victim))
          TF2_IgnitePlayer(victim, attacker);
        localAttAdjust += ZF_SCORCHING_ATTACK;        
      }
      // Handle Perk (Z): TARRED
      // + Slow victim on melee hit.
      else if(usingZomPerk(attacker, ZF_PERK_TARRED))
      {
        if(getStat(victim, ZFStatSpeed) > ZF_TARRED_SPEED_LIMIT)      
          addStatTempStack(victim, ZFStatSpeed, ZF_TARRED_SPEED_MELEE, ZF_TARRED_DURATION_MELEE);
      }
      // Handle Perk (Z): THIEVING
      // + Steal from victim with each melee hit.
      else if(usingZomPerk(attacker, ZF_PERK_THIEVING))
      {
        new slot = activeWeaponSlot(victim);
        if(slot == 0) // Primary weapon
        {
          subResAmmoPct(victim, slot, ZF_THIEVING_AMMOPCT);
          if(getResAmmoPct(victim, slot) == 0.0)
            doThievingSteal(attacker, victim, slot);
        }
        else if(slot == 1) // Secondary weapon
        {
          subUber(victim, ZF_THIEVING_UBERPCT);
          subResAmmoPct(victim, slot, ZF_THIEVING_AMMOPCT);
        }
        else if(slot == 2) // Melee
        {
          subMetal(victim, ZF_THIEVING_METAL);
        }
  
        // Effects
        fxSpark(victim);       
      }
      // Handle Perk (Z): TOXIC
      // + Poison victim on melee hit.
      else if(usingZomPerk(attacker, ZF_PERK_TOXIC))
      {
        addCond(victim, ZFCondPoisoned, ZF_TOXIC_DURATION_POISON);
        zf_lastPoison[victim] = attacker;
      }
    }
    //
    // Non-melee attacks.
    //      
    else
    {
      // Handle Perk (Z): ROAR
      // + Handle env_explosion damage (i.e. roar).
      if(usingZomPerk(attacker, ZF_PERK_ROAR))
      {
        if(attackWasEnvExplosion(damagetype))
        {     
          decl Float:attPos[3];
          decl Float:vicPos[3];
          GetClientAbsOrigin(attacker, attPos);
          GetClientAbsOrigin(victim, vicPos);
   
          new Float:factor = fMax(0.0, 1.0 - GetVectorDistance(attPos, vicPos, false) / float(ZF_ROAR_RADIUS));        
          new Float:force = factor * (isHeavy(attacker) ? ZF_ROAR_FORCE_HEAVY : ZF_ROAR_FORCE);
          new duration = RoundToCeil(factor * (isHeavy(attacker) ? ZF_ROAR_DURATION_HEAVY : ZF_ROAR_DURATION));
             
          fxKnockback(victim, attacker, force);
          if(!getCond(victim, ZFCondIntimidated))
          {
            addCond(victim, ZFCondIntimidated, duration);
          }
        }
      }
      // Handle Perk (Z): SCORCHING
      // + Negate innate attack penalty on scorching afterburn.
      else if(usingZomPerk(attacker, ZF_PERK_SCORCHING))
      {
        if(!attackWasFire(damagetype))
          localAttAdjust += ZF_SCORCHING_ATTACK; 
      }
      // Handle Perk (Z): TARRED
      // + Handle env_explosion damage (i.e. oil slick proximity).
      else if(usingZomPerk(attacker, ZF_PERK_TARRED))
      {
        if(attackWasEnvExplosion(damagetype))
        {        
          if(getStat(victim, ZFStatSpeed) > ZF_TARRED_SPEED_LIMIT)
            addStatTempStack(victim, ZFStatSpeed, ZF_TARRED_SPEED_SLICK, ZF_TARRED_DURATION_SLICK);
          damage = 0.0;
        }
      }
      // Handle Perk (Z): THIEVING
      // + Negate innate attack penalty on non-melee attacks.
      else if(usingZomPerk(attacker, ZF_PERK_THIEVING))
      {
        localAttAdjust -= ZF_THIEVING_ATTACK;          
      }        
    }
  }

  //
  // Survivor is taking damage from non-zombie.
  //
  else if(validSur(victim) && !validZom(attacker))
  {
    // Handle Perk (S): JUGGERNAUT 
    // + No self damage, no fall damage, handle fall damage impact.
    if(usingSurPerk(victim, ZF_PERK_JUGGERNAUT))
    {
      if(victim == attacker)
        damage = 0.0;
      if(attackWasSelfFall(inflictor, damagetype))
      {
        applyDamageRadialAtClient(victim, 1, ZF_JUGGERNAUT_RADIUS); 
        fxPuffBig(victim);
        damage = 0.0;
      }
    }
    
    // Handle Perk (S): NINJA
    // + Reduced fall damage.
    else if(usingSurPerk(victim, ZF_PERK_NINJA))
    {
      if(attackWasSelfFall(inflictor, damagetype))
      {
        localDefAdjust += ZF_NINJA_FALLDMG_RESIST;
      }        
    }
  }
  
  //
  // Zombie is taking damage from survivor.
  //
  else if(validZom(victim) && validSur(attacker))
  {
    //
    // Melee attacks.
    //
    if(attackWasMelee(attacker, inflictor, damagetype))
    {
      // Handle Perk (S): JUGGERNAUT
      // + Knockback victim with melee hit.
      if(usingSurPerk(attacker, ZF_PERK_JUGGERNAUT))
      {
        fxKnockback(victim, attacker, ZF_JUGGERNAUT_FORCE);       
      }
      // Handle Perk (Z): TARRED
      // + Apply penalties with each melee hit.
      if(usingZomPerk(victim, ZF_PERK_TARRED))
      {
        if(!isUbered(attacker))
        {
          if(getStat(attacker, ZFStatSpeed) > ZF_TARRED_SPEED_LIMIT)
          {
            addStatTempStack(attacker, ZFStatRof, ZF_TARRED_ROF, ZF_TARRED_DURATION_MELEE);
            addStatTempStack(attacker, ZFStatSpeed, ZF_TARRED_SPEED_MELEE, ZF_TARRED_DURATION_MELEE);
          }
        }
      }
      // Handle Perk (Z): TOXIC
      // + Poison attacker who is attacking with melee.
      else if(usingZomPerk(victim, ZF_PERK_TOXIC))
      {
        if(!isUbered(attacker))
        {
          addCond(attacker, ZFCondPoisoned, ZF_TOXIC_DURATION_POISON);
          zf_lastPoison[victim] = attacker;
        }
      }
    }
    //
    // Non-melee attacks.
    //
    else
    {
      // Handle Perk (S): JUGGERNAUT
      // + Handle env_explosion damage (i.e. fall damage impact).
      if(usingSurPerk(attacker, ZF_PERK_JUGGERNAUT))
      {
        if(attackWasEnvExplosion(damagetype))
        {
          TF2_StunPlayer(victim, ZF_JUGGERNAUT_STUN_DURATION, ZF_JUGGERNAUT_STUN_SLOWDOWN, TF_STUNFLAGS_SMALLBONK, attacker);      
          fxKnockback(victim, attacker, ZF_JUGGERNAUT_FORCE);
        }
      }
      // Handle Perk (S): NONLETHAL
      // + Apply innate bullet damage attack penalty.
      else if(usingSurPerk(attacker, ZF_PERK_NONLETHAL))
      {
        if(attackWasBullet(attacker, inflictor))
        {
          localAttAdjust += ZF_NONLETHAL_ATTACK_BULLET;
        }
      }
      
      // Handle Perk (Z): SCORCHING
      // + No fire damage.
      if(usingZomPerk(victim, ZF_PERK_SCORCHING))
      {
        if(!(validSur(attacker) && isMedic(attacker)) && attackWasFire(damagetype))
          damage = 0.0;
      }        
    }
  }
    
  //
  // Zombie is taking damage from non-survivor.
  //
  else if(validZom(victim) && !validSur(attacker))
  {
    // Handle Perk (Z): LEAP
    // + No fall damage.
    if(usingZomPerk(victim, ZF_PERK_LEAP))
    {
      if(attackWasSelfFall(inflictor, damagetype))
        damage = 0.0;
    }
    // Handle Perk (Z): SCORCHING
    // + No fire damage.
    else if(usingZomPerk(victim, ZF_PERK_SCORCHING))
    {
      if(attackWasFire(damagetype))
        damage = 0.0;
    }
  }
  
  // 
  // Adjust damage based on attacker attack bonus and vicitm defense bonus.
  //
  if(damage > 0.0)
  {
    new Float:dmgFactor = ((100 + localAttAdjust) * (100 - localDefAdjust)) / 10000.0;        
    damage *= fMax(dmgFactor, 0.0);
    
    // Handle special effects (crit, minicrit) for sufficient dmgFactor.
    if(dmgFactor >= 3.0)
    {
      if(validClient(attacker)) fxCreateSoundToClient(ZFSND_CRITXMIT, attacker);
      if(validClient(victim)) fxCreateSoundToClient(ZFSND_CRITRECV, victim);
    }
    else if(dmgFactor >= 1.35)
    {
      if(validClient(attacker)) fxCreateSoundToClient(ZFSND_CRITMINI, attacker);
      if(validClient(victim)) fxCreateSoundToClient(ZFSND_CRITMINI, victim);
    }
  }
  
  //
  // Cripple on backstab.
  //
  if(GetConVarBool(zf_cvCripple))
  {
    if((damage > 0.0) && validSur(victim) && validZom(attacker))
    {
      if(attackWasBackstab(attacker, inflictor, damagetype))
      {
        if(!getCond(victim, ZFCondCrippled))
        {
          zf_lastHealth[victim] = GetClientHealth(victim);
          
          PrintHintText(attacker, "你使 %N! 残废了", victim);
          PrintHintText(victim, "%N 使你残废了 你!", attacker);          
          addCond(victim, ZFCondCrippled, ZF_CRIPPLE_DURATION);
          addCond(victim, ZFCondTracked, ZF_CRIPPLE_DURATION);          
          fxDeathScream(victim);
          fxBloodBurst(victim);
          fxBloodSpray(victim);
          setGlow(victim, true);
        }
        damage = 0.0;
      }
    }
  }
     
  return Plugin_Changed;  
}

public perk_OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype)
{
//   // DEBUG
//   decl String:inflictorClass[32];
//   GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass));
//   PrintToChatAll("\x05[ZF DEBUG]\x01 Vic %d, Att %d, Inf %d (%s), Dmg %f, DTp %x", victim, attacker, inflictor, inflictorClass, damage, damagetype);
     
  //
  // Survivor is taking damage from zombie.
  //
  if(validSur(victim) && validZom(attacker))
  {
    // Handle Perk (Z): VAMPIRIC
    // + Leech health with each melee hit.
    if(usingZomPerk(attacker, ZF_PERK_VAMPIRIC))
    {
      if(attackWasMelee(attacker, inflictor, damagetype))
      {
        addHealth(attacker, RoundToCeil(damage * ZF_VAMPIRIC_HEALTHPCT));
        fxBloodBurst(victim);
      }
    }
  }
  //
  // Zombie is taking damage from survivor.
  //
  else if(validZom(victim) && validSur(attacker))
  {
    // Handle Perk (S): NONLETHAL
    // + Knockback victim on bullet-based hit.
    if(usingSurPerk(attacker, ZF_PERK_NONLETHAL))
    {
      if(attackWasBullet(attacker, inflictor))
      {
        fxKnockback(victim, attacker, (ZF_NONLETHAL_FORCE * damage));
      }
    }
  }
}

public perk_OnTouch(toucher, touchee)
{ 
  if(validLivingZom(toucher) && validLivingSur(touchee))
  {
    // Handle Perk (Z): SCORCHING
    // + Ignite touchee on touch.
    if(usingZomPerk(toucher, ZF_PERK_SCORCHING))
    {
      if(isOnFire(toucher) && !isPyro(touchee))
        TF2_IgnitePlayer(touchee, toucher);
    }
  }
}

public perk_OnPlayerSpawn(client)
{
  if(validClient(client))
  { 
    //
    // Handle spawn menu presentation.
    //
    if(zf_perkMode == 0)
    {
      new js = prefGet(client, JoinState);
      if(validSur(client))
      {
        if((js & ZF_JOINSTATE_SUR) == 0)
        {
          DisplayMenu(zf_menuSurPerkList, client, MENU_TIME_FOREVER);

        }
      }
      else if(validZom(client))
      {
        if((js & ZF_JOINSTATE_ZOM) == 0)
        {   
          DisplayMenu(zf_menuZomPerkList, client, MENU_TIME_FOREVER);     
        }
      }
    }

    //
    // Change perks if they were not selected during current game mode.
    //      
    if(prefGet(client, PerkSelectMode) != zf_perkMode)
    {      
      //
      // Clear perks.
      //
      if(zf_perkMode == 0)
      {
        PrintToChat(client, "\x05[VSH-ZF]\x01 Perks have been cleared. You must reselect your perks.");
      }
      //
      // Select random perks.
      //
      else if(zf_perkMode == 1)
      {
        new validSurPerkCount = 0;
        new validZomPerkCount = 0;   
        decl validSurPerks[TOTAL_SUR_PERKS];
        decl validZomPerks[TOTAL_ZOM_PERKS];
           
        for(new i = 1; i < TOTAL_SUR_PERKS; i++)
          if(surPerkEnabled(i))
            validSurPerks[validSurPerkCount++] = i;
        if(validSurPerkCount == 0)
          validSurPerks[validSurPerkCount++] = 0;
    
        for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
          if(zomPerkEnabled(i))
            validZomPerks[validZomPerkCount++] = i;
        if(validZomPerkCount == 0)
          validZomPerks[validZomPerkCount++] = 0;


        PrintToChat(client, "\x05[VSH-ZF]\x01 Random perks: %s (Survivor) / %s (Zombie)", ZF_SURPERK_NAME[prefGet(client, SurPendPerk)], ZF_ZOMPERK_NAME[prefGet(client, ZomPendPerk)]);      
      }
      //
      // Use random team perks.
      //   
      else if(zf_perkMode == 2)
      {

        PrintToChat(client, "\x05[VSH-ZF]\x01 Random team perks: %s (Survivors) vs. %s (Zombies)", ZF_SURPERK_NAME[zf_perkRandSurPerk], ZF_ZOMPERK_NAME[zf_perkRandZomPerk]); 
      }
      //
      // Use CVAR team perks.
      //
      else if(zf_perkMode == 3)
      {

        PrintToChat(client, "\x05[VSH-ZF]\x01 CVAR team perks: %s (Survivors) vs. %s (Zombies)", ZF_SURPERK_NAME[zf_perkTeamSurPerk], ZF_ZOMPERK_NAME[zf_perkTeamZomPerk]);
      }

    }
    
    //
    // Apply new perk if client changed teams or if desired perk
    // (accounting for those disabled) differs from current perk.
    // Account for perk limits (only during normal game mode).
    //
    new nextPerk = ZF_PERK_NONE;
    new bool:perkChange = false;
    new bool:teamChange = (GetClientTeam(client) != zf_lastTeam[client]);     
    if(isSur(client))
    {
      if(surPerkEnabled(prefGet(client, SurPendPerk)))
        nextPerk = prefGet(client, SurPendPerk);      
      else if(surPerkEnabled(prefGet(client, SurPerk)))
        nextPerk = prefGet(client, SurPerk);
      
      if((zf_perkMode == 0) && surPerkAtLimit(client, nextPerk))
      {
        PrintToChat(client, "\x05[VSH-ZF]\x01 Desired perk (%s) al准备好了 at limit (%d).", ZF_SURPERK_NAME[nextPerk], zf_surPerksLimit[nextPerk]);
        nextPerk = ZF_PERK_NONE;
      }
        
      if(teamChange || (nextPerk != prefGet(client, SurPerk)))
      {
        perkChange = true;  
        prefSet(client, SurPerk, nextPerk);
      }
      prefSet(client, SurPendPerk, nextPerk);
    }
    else if(isZom(client))
    {      
      if(zomPerkEnabled(prefGet(client, ZomPendPerk)))
        nextPerk = prefGet(client, ZomPendPerk);      
      else if(zomPerkEnabled(prefGet(client, ZomPerk)))
        nextPerk = prefGet(client, ZomPerk);

      if((zf_perkMode == 0) && zomPerkAtLimit(client, nextPerk))
      {
        PrintToChat(client, "\x05[VSH-ZF]\x01 Desired perk (%s) al准备好了 at limit (%d).", ZF_ZOMPERK_NAME[nextPerk], zf_zomPerksLimit[nextPerk]);
        nextPerk = ZF_PERK_NONE;
      }
                        
      if(teamChange || (nextPerk != prefGet(client, ZomPerk)))
      {
        perkChange = true;         
        prefSet(client, ZomPerk, nextPerk);
      }  
      prefSet(client, ZomPendPerk, nextPerk);
    }

    //
    // Cleanup client state based on whether perk changed.
    //
    if(perkChange)
    {
      // State
      zf_lastAttack[client] = 0;
      zf_lastButtons[client] = 0;
      zf_lastHealth[client] = 0;
      zf_lastKiller[client] = 0;
      zf_lastPoison[client] = 0;
      zf_lastTeam[client] = GetClientTeam(client);
            
      // Logic
      zf_perkTimer[client] = 0;
      zf_perkState[client] = 0;
      for(new i = 0; i < 5; i++)
        for(new j = 0; j < 3; j++)
          zf_perkPos[client][i][j] = 0.0;
      zf_perkStr[client] = "";

      // FX
      removeAura(client);
      removeIcon(client);
      removeItems(client);
      fxSetClientColor(client, 255, 255, 255, 255);
      setGlow(client, false);
            
      // Implement new bonuses and effects.
      resetClientStats(client);
      resetClientConds(client);
      updateClientPermStats(client);
      updateClientPermEffects(client);
    }
    else
    {      
      // State
      zf_lastAttack[client] = 0;
      zf_lastButtons[client] = 0;
      zf_lastHealth[client] = 0;
      zf_lastKiller[client] = 0;
      zf_lastPoison[client] = 0;
      zf_lastTeam[client] = GetClientTeam(client);
      
      // Bonuses
      resetClientStatType(client, ZFStatTypeCond);
      resetClientStatType(client, ZFStatTypeTemp);
      resetClientStatType(client, ZFStatTypeTempDuration);
      resetClientConds(client);
      
      // FX
      showAura(client);
      showIcon(client);
      fxSetClientColor(client, 255, 255, 255, 255);
      setGlow(client, false);
      
      // Reset permanent effects.
      updateClientPermEffects(client);
    }
    
    // HUD
    updateHud(client);
  }

  if(validSur(client))
  {
    if(usingSurPerk(client, ZF_PERK_FRIEND))
    {
      zf_perkState[client] = 0;
    }
    else if(usingSurPerk(client, ZF_PERK_LEADER))
    {
      zf_perkTimer[client] = 0;
    }
    else if(usingSurPerk(client, ZF_PERK_NINJA))
    {
      zf_perkState[client] = 0;
      zf_perkTimer[client] = 0;
    }     
    else if(usingSurPerk(client, ZF_PERK_STASH))
    {
      zf_perkTimer[client] = 0;
      removeItems(client);
    }
    else if(usingSurPerk(client, ZF_PERK_STIRCRAZY))
    {
      for(new i = 0; i < ZF_STIRCRAZY_MAX_POINTS; i++)
        GetClientAbsOrigin(client, zf_perkPos[client][i]);
    }
    else if(usingSurPerk(client, ZF_PERK_SUPPLIER))
    {
      zf_perkState[client] = 0;
      zf_perkTimer[client] = 0;      
    }
    else if(usingSurPerk(client, ZF_PERK_TRAPPER))
    {
      zf_perkTimer[client] = 0;
    }
    else if(usingSurPerk(client, ZF_PERK_TANTRUM))
    {
      zf_perkTimer[client] = 0;
    }
    else if(usingSurPerk(client, ZF_PERK_ZENLIKE))
    {
      zf_perkState[client] = 0;
    }
  }
  
  else if(validZom(client))
  {                   
    if(usingZomPerk(client, ZF_PERK_HUNTER))
    {    
      zf_perkState[client] = 0;  
      if(validAura(client))
      {
        decl Float:spawnPos[3];
        getEntityPos(zf_aura[client], spawnPos);
        TeleportEntity(client, spawnPos, zf_perkPos[client][0], NULL_VECTOR);
        
        addStatTempStack(client, ZFStatAtt, ZF_HUNTER_ATTACK, ZF_HUNTER_DURATION);          
        
        //
        // Remove spawn protection. This is a giant hack to 
        // fix compatibility issues with spawn protection mods.
        //
        remInvincibility(client);
        fxSetClientColor(client, 255, 255, 255, 255);
                  
        ClientCommand(client, "voicemenu 1 0");
        fxTeleportTrail(client, 10.0);
      }
    }
    else if(usingZomPerk(client, ZF_PERK_LEAP))
    {
      zf_perkTimer[client] = 0;  
    }
    else if(usingZomPerk(client, ZF_PERK_MARKED))
    {
      if(roundState() <= RoundGrace)
        zf_perkState[client] = -1;
    }
    else if(usingZomPerk(client, ZF_PERK_MAGNETIC))
    {
      addFlagNoTarget(client);
    }
    else if(usingZomPerk(client, ZF_PERK_RAGE))
    {
      zf_perkState[client] = 0;
      zf_perkTimer[client] = 0;
    }  
    else if(usingZomPerk(client, ZF_PERK_ROAR))
    {
      zf_perkTimer[client] = 0;  
    }    
    else if(usingZomPerk(client, ZF_PERK_SCORCHING))
    {
      TF2_IgnitePlayer(client, client);
    }
    else if(usingZomPerk(client, ZF_PERK_SICK))
    {
      zf_perkTimer[client] = 0;
      removeItems(client);
    }      
    else if(usingZomPerk(client, ZF_PERK_TARRED))
    {
      zf_perkTimer[client] = 0;
      removeItems(client);
    }
    else if(usingZomPerk(client, ZF_PERK_THIEVING))
    {
      zf_perkState[client] = 0;
    }
  }          
}

public perk_OnPlayerDeath(victim, killer, assist, inflictor, damagetype)
{
//   // DEBUG
//   LogMessage("[ZF DEBUG] Vic %d, Klr %d, Ast %d, Inf %d, DTp %x", victim, killer, assist, inflictor, damagetype);
  
  if(validClient(victim))
  {  
    //
    // Set last killer.
    //
    zf_lastKiller[victim] = killer;
             
    //
    // Clear conditions.
    //
    resetClientConds(victim);
    
    //
    // Handle effects.
    //
    hideAura(victim);
    hideIcon(victim);
    removeItems(victim);      
    setGlow(victim, false);
  }

  //
  // Survivor killed.
  //
  if(validSur(victim))
  {
    //
    // Survivor killed by zombie.
    //        
    if(validZom(killer))
    {
      // Handle Perk (S): SELFLESS
      // + Explode on death.
      if(usingSurPerk(victim, ZF_PERK_SELFLESS))
      {
        applyDamageRadialAtClient(victim, ZF_SELFLESS_DAMAGE, ZF_SELFLESS_RADIUS, true);
        fxExplosionBig(victim);  
      }
          
      // Handle Perk (Z): ALPHA
      // + Add minion.
      if(usingZomPerk(killer, ZF_PERK_ALPHA))
      {      
        zf_perkAlphaMaster[victim] = killer;      
        PrintHintText(killer, "%N 现在是你的仆人了!", victim);
      }
      // Handle Perk (Z): VINDICTIVE
      else if(usingZomPerk(killer, ZF_PERK_VINDICTIVE))
      {
        addStat(killer, ZFStatAtt, ZFStatTypePerm, ZF_VINDICTIVE_ATTACK);
        addStat(killer, ZFStatDef, ZFStatTypePerm, ZF_VINDICTIVE_DEFEND);
      }
    }
    
    //
    // Survivor killed, assisted by zombie.
    //
    if(validZom(assist))
    {
      // Handle Perk (Z): ALPHA
      // + Add minion.
      if(usingZomPerk(assist, ZF_PERK_ALPHA))
      {
        if(!(validZom(killer) && usingZomPerk(killer, ZF_PERK_ALPHA)))
        {
          zf_perkAlphaMaster[victim] = assist;
          PrintHintText(assist, "%N 已经是你的仆人了!", victim);
        }
      }
      // Handle Perk (Z): VINDICTIVE
      else if(usingZomPerk(assist, ZF_PERK_VINDICTIVE))
      {
        addStat(assist, ZFStatAtt, ZFStatTypePerm, ZF_VINDICTIVE_ATTACK_ASSIST);
        addStat(assist, ZFStatDef, ZFStatTypePerm, ZF_VINDICTIVE_DEFEND_ASSIST);
      }
    }
  }
  //
  // Zombie killed.
  // 
  else if(validZom(victim))
  {  
    // Handle Perk (Z): HUNTER
    if(usingZomPerk(victim, ZF_PERK_HUNTER))
    {
      showAura(victim);
    }
    // Handle Perk (Z): RAGE
    else if(usingZomPerk(victim, ZF_PERK_RAGE))
    {
      removeAura(victim);
    }
          
    //
    // Zombie killed by survivor.
    //     
    if(validSur(killer))
    {    
      // Handle Perk (S): CHARITABLE
      if(usingSurPerk(killer, ZF_PERK_CHARITABLE))
      {
        zf_perkState[killer] += ZF_CHARITABLE_POINTS_KILL;
      }
      // Handle Perk (S): FRIEND
      else if(usingSurPerk(killer, ZF_PERK_FRIEND))
      {
        if(validSur(assist) && (zf_perkState[killer] == assist))
          zf_perkTimer[killer] += ZF_FRIEND_CRITTIME_KILL;
      }
      // Handle Perk (S): HEROIC
      else if(usingSurPerk(killer, ZF_PERK_HEROIC))
      {
        if(zf_perkTimer[killer] > 0)
        {
          if(zf_perkState[killer] == 0)
            zf_perkTimer[killer] += HEROIC_CRITTIME_KILL;
          else
            zf_perkTimer[killer] += HEROIC_CRITTIME_KILL_ACTIVE;
        }
      }
      // Handle Perk (S): RESOURCEFUL
      else if(usingSurPerk(killer, ZF_PERK_RESOURCEFUL))
      {
        addHealth(killer, ZF_RESOURCEFUL_HEALTH);
        addHealth(killer, ZF_RESOURCEFUL_HEALTH_OVERHEAL, true);
              
        addResAmmoPct(killer, 0, ZF_RESOURCEFUL_AMMOPCT);
        addResAmmoPct(killer, 1, ZF_RESOURCEFUL_AMMOPCT);
        addMetal(killer, ZF_RESOURCEFUL_METAL);
        fxCreateSoundToClient(ZFSND_PICKUPAMMO, killer);        
      }      
      // Handle Perk (S): WISE
      else if(usingSurPerk(killer, ZF_PERK_WISE))
      {
        addStat(killer, ZFStatAtt, ZFStatTypePerm, ZF_WISE_ATTACK_KILL);
      }

      // Handle Perk (Z): COMBUSTIBLE 
      if(usingZomPerk(victim, ZF_PERK_COMBUSTIBLE))
      {
        if(!attackWasMelee(killer, inflictor, damagetype))
        {
          new damage = isHeavy(victim) ? ZF_COMBUSTIBLE_DAMAGE_HEAVY : ZF_COMBUSTIBLE_DAMAGE;
          applyDamageRadialAtClient(victim, damage, ZF_COMBUSTIBLE_RADIUS, true);             
          fxExplosionBig(victim);
          CreateTimer(ZF_COMBUSTIBLE_RESPAWNTIME, perk_tSpawnClient, victim, TIMER_FLAG_NO_MAPCHANGE);
        }
      }
      // Handle Perk (Z): HORRIFYING
      // + Reduce temporary stat penalties.
      else if(usingZomPerk(victim, ZF_PERK_HORRIFYING))
      {
        if(getStatType(killer, ZFStatAtt, ZFStatTypeTemp) < 0)
          scaleStatTempPct(killer, ZFStatAtt, (1.0 - HORRIFYING_PENALTYPCT_KILL));
        if(getStatType(killer, ZFStatDef, ZFStatTypeTemp) < 0)
          scaleStatTempPct(killer, ZFStatDef, (1.0 - HORRIFYING_PENALTYPCT_KILL));
        if(getStatType(killer, ZFStatRof, ZFStatTypeTemp) < 0)
          scaleStatTempPct(killer, ZFStatRof, (1.0 - HORRIFYING_PENALTYPCT_KILL));
      }      
      // Handle Perk (Z): HUNTER
      else if(usingZomPerk(victim, ZF_PERK_HUNTER))
      {
        CreateTimer(ZF_HUNTER_RESPAWNTIME, perk_tSpawnClient, victim, TIMER_FLAG_NO_MAPCHANGE);
      }   
      // Handle Perk (Z): SWARMING
      else if(usingZomPerk(victim, ZF_PERK_SWARMING))
      {
        CreateTimer(ZF_SWARMING_RESPAWNTIME, perk_tSpawnClient, victim, TIMER_FLAG_NO_MAPCHANGE);
      }
      // Handle Perk (Z): SWARMING
      // + Instant respawn for those killed near a SWARMING zombie.      
      else
      {
        decl Float:iPos[3];
        decl Float:victimPos[3];        
        GetClientAbsOrigin(victim, victimPos);
        for(new i = 1; i <= MaxClients; i++)
        {
          if(validLivingZom(i) && usingZomPerk(i, ZF_PERK_SWARMING))
          {         
            GetClientAbsOrigin(i, iPos);
            if(GetVectorDistance(iPos, victimPos, true) <= ZF_SWARMING_RADIUSSQ)
            {
              CreateTimer(ZF_SWARMING_RESPAWNTIME, perk_tSpawnClient, victim, TIMER_FLAG_NO_MAPCHANGE);
              break;
            }
          }
        }
      }
    }
    
    //
    // Zombie killed, assisted by survivor.
    //
    if(validSur(assist))
    {
      // Handle Perk (S): CHARITABLE
      if(usingSurPerk(assist, ZF_PERK_CHARITABLE))
      {
        zf_perkState[assist] += ZF_CHARITABLE_POINTS_ASSIST;
      }
      // Handle Perk (S): FRIEND
      else if(usingSurPerk(assist, ZF_PERK_FRIEND))
      {
        if(validSur(killer) && (zf_perkState[assist] == killer))
          zf_perkTimer[assist] += ZF_FRIEND_CRITTIME_ASSIST;
      }
      // Handle Perk (S): HEROIC
      else if(usingSurPerk(assist, ZF_PERK_HEROIC))
      {
        if(zf_perkTimer[assist] > 0)
        {
          if(zf_perkState[assist] == 0)
            zf_perkTimer[assist] += HEROIC_CRITTIME_ASSIST;
          else
            zf_perkTimer[assist] += HEROIC_CRITTIME_ASSIST_ACTIVE;        
        }
      }
      // Handle Perk (S): WISE
      else if(usingSurPerk(assist, ZF_PERK_WISE))
      {
        addStat(assist, ZFStatAtt, ZFStatTypePerm, ZF_WISE_ATTACK_ASSIST);
      }
      
      // Handle Perk (Z): HORRIFYING
      // + Reduce temporary stat penalties.
      if(usingZomPerk(victim, ZF_PERK_HORRIFYING))
      {
        if(getStatType(assist, ZFStatAtt, ZFStatTypeTemp) < 0)
          scaleStatTempPct(assist, ZFStatAtt, (1.0 - HORRIFYING_PENALTYPCT_ASSIST));
        if(getStatType(assist, ZFStatDef, ZFStatTypeTemp) < 0)
          scaleStatTempPct(assist, ZFStatDef, (1.0 - HORRIFYING_PENALTYPCT_ASSIST));
        if(getStatType(assist, ZFStatRof, ZFStatTypeTemp) < 0)
          scaleStatTempPct(assist, ZFStatRof, (1.0 - HORRIFYING_PENALTYPCT_ASSIST));
      }      
    }
  }
}

public Action:perk_OnCallForMedic(client)
{  
  if(validLivingSur(client))
  {
    // Handle Perk (S): CARPENTER
    // + Place barricade.
    if(usingSurPerk(client, ZF_PERK_CARPENTER))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能设置路障.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须一直蹲在地上才能设置路障.");
        }
        else
        {          
          new bool:clientsNearby = false;
          new bool:barricadesNearby = false;
          decl Float:clientPos[3];
          decl Float:otherPos[3];
                              
          GetClientAbsOrigin(client, clientPos);
          for(new i = 1; i <= MaxClients; i++)
          {
            if(IsClientInGame(i) && IsPlayerAlive(i))
            {
              // Check for nearby barricades.
              if(isSur(i) && usingSurPerk(i, ZF_PERK_CARPENTER))
              {
                for(new j = 0; j < CARPENTER_MAX_ITEMS; j++)
                {
                  if(validItem(i, j))
                  {
                    if(GetVectorDistance(clientPos, zf_perkPos[i][j], true) <= CARPENTER_DROP_RADSQ_BARRICADE)
                    {
                      barricadesNearby = true;
                      break;
                    }
                  }
                }
                if(barricadesNearby)
                  break;
              }
              
              // Check for other nearby clients.
              if(i == client) continue;
              GetClientAbsOrigin(i, otherPos);
              if(GetVectorDistance(clientPos, otherPos, true) <= CARPENTER_DROP_RADSQ_CLIENT)
              {
                clientsNearby = true;
                break;
              }
            }
          }
          
          // Place barricade.
          if(clientsNearby)
          {
            PrintHintText(client, "无法设置路障 - 附近有其他玩家.");
          }
          else if(barricadesNearby)
          {
            PrintHintText(client, "无法设置路障 - 附近有其他玩家的路障.");
          }
          else          
          {
            new itemIndex = getFreeItemIndex(client, CARPENTER_MAX_ITEMS);
            if(itemIndex >= 0)
            {
              zf_perkTimer[client] = CARPENTER_COOLDOWN;
              
              removeItem(client, itemIndex);
              zf_item[client][itemIndex] = doCarpenterBuild(client, zf_perkPos[client][itemIndex]);
              setItemMetadata(zf_item[client][itemIndex], CARPENTER_BARRICADE_HEALTH);   
              SDKHook(zf_item[client][itemIndex], SDKHook_OnTakeDamage, perk_OnFenceTakeDamage);
            }
          }
          return Plugin_Handled; 
        }
      }      
    }
    
    // Handle Perk (S): CHARITABLE
    else if(usingSurPerk(client, ZF_PERK_CHARITABLE))
    {
      if((zf_perkState[client] / ZF_CHARITABLE_POINTS_GIFT) > 0)
      {
        // Toss present.
        new itemIndex = getFreeItemIndex(client, ZF_CHARITABLE_MAX_ITEMS);
        if(itemIndex >= 0)
        {
          zf_perkState[client] -= ZF_CHARITABLE_POINTS_GIFT;
          zf_item[client][itemIndex] = doItemThrow(client, ZFMDL_PRESENT[GetRandomInt(0,2)], 600.0);
          SDKHook(zf_item[client][itemIndex], SDKHook_Touch, perk_OnCharitableGiftTouched);
        }
        else
        {
          PrintHintText(client, "你不能扔掉那个礼物!");
        }
        return Plugin_Handled;        
      }
    }
      
    // Handle Perk (S): FRIEND
    // + Select friend (grace period or earlier only).
    else if(usingSurPerk(client, ZF_PERK_FRIEND))
    {
      if(roundState() <= RoundGrace)
      {
        new desiredFriend = GetClientAimTarget(client);
        if(validLivingSur(desiredFriend))
        {
          doFriendSelect(client, desiredFriend);
          return Plugin_Handled;
        }
      }
    }
    
    // Handle Perk (S): LEADER
    else if(usingSurPerk(client, ZF_PERK_LEADER))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能设置集合点.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须一直蹲在地上才能设置集合点.");
        }
        else
        {
          zf_perkTimer[client] = ZF_LEADER_RALLY_COOLDOWN;
          removeItem(client, 0);            
          zf_item[client][0] = doItemPlace(client, ZFMDL_FLAG);

          fxCreateSoundToAll(ZFSND_PACKDROP, client);
          return Plugin_Handled;
        }        
      }
    }
    
    // Handle Perk (S): NINJA
    else if(usingSurPerk(client, ZF_PERK_NINJA))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能设置诱饵.");
        }
        else if(isCrouching(client))
        {
          PrintHintText(client, "你不需要蹲着来设置诱饵.");
        }
        else
        {
          // Place retreat point.
          // Retreat point is valid for ZF_NINJA_DURATION_DECOY_ACTIVE seconds.
          // Retreat point poofs after ZF_NINJA_DURATION_DECOY_ACTIVE seconds.
          // New retreat point can be placed after (ZF_NINJA_DURATION_DECOY_ACTIVE + ZF_NINJA_DURATION_COOLDOWN) seconds.
          zf_perkState[client] = 1;
          zf_perkTimer[client] = (ZF_NINJA_DURATION_DECOY_ACTIVE + ZF_NINJA_DURATION_COOLDOWN);
          
          createAura(client, ZFPART_AURAHALO, AttachNone);
          return Plugin_Handled;
        }        
      }
    }
     
    // Handle Perk (S): STASH
    else if(usingSurPerk(client, ZF_PERK_STASH))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你需要在地上放置藏身处.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须站在地上才能布置藏身处(不能蹲).");
        }
        else
        {
          new bool:stashNearby = false;
          new bool:survivorsNearby = false;
          decl Float:clientPos[3];
          decl Float:otherPos[3];
          
          GetClientAbsOrigin(client, clientPos);
          for(new i = 1; i <= MaxClients; i++)
          {
            if(i == client) continue;
            if(IsClientInGame(i) && IsPlayerAlive(i) && isSur(i))
            {
              // Check for other nearby survivors.
              GetClientAbsOrigin(i, otherPos);
              if(GetVectorDistance(clientPos, otherPos, true) <= STASH_DROP_RADSQ_CLIENT)
              {
                survivorsNearby = true;
                break;
              }
              
              // Check for nearby stashes from other survivors.
              if(usingSurPerk(i, ZF_PERK_STASH) && validItem(i, 0))
              {      
                getEntityPos(zf_item[i][0], otherPos);
                if(GetVectorDistance(clientPos, otherPos, true) <= STASH_DROP_RADSQ_STASH)
                {
                  stashNearby = true;
                  break;
                }
              }
            }            
          }        
     
          // Place stash.
          if(survivorsNearby)
          {
            PrintHintText(client, "无法布置藏身处 - 附近有其他幸存者.");
          }
          else if(stashNearby)
          {
            PrintHintText(client, "无法布置藏身处 - 附近有其他藏身处.");
          }
          else
          {
            zf_perkTimer[client] = STASH_WARMUP + STASH_COOLDOWN;
            removeItem(client, 0);            
            zf_item[client][0] = doItemPlace(client, ZFMDL_SUPPLYCRATE);
          
            fxCreateSoundToAll(ZFSND_PACKDROP, client);
          }
          return Plugin_Handled; 
        }      
      }
    }
    
    // Handle Perk (S): SUPPLIER
    else if(usingSurPerk(client, ZF_PERK_SUPPLIER))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能放置补给.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须一直蹲在地上才能放置补给.");
        }
        else
        {
          // Handle supplies placement.
          new itemIndex = getFreeItemIndex(client, ZF_SUPPLIER_MAX_ITEMS);
          if(itemIndex >= 0)
          {
            zf_perkTimer[client] = ZF_SUPPLIER_TIMER;
            
            removeItem(client, itemIndex);
            zf_item[client][itemIndex] = doItemPlace(client, ZFMDL_SUPPLYCRATE);
            setItemMetadata(zf_item[client][itemIndex], ZF_SUPPLIER_RESUPPLY_COUNT);
            
            fxCreateSoundToAll(ZFSND_PACKDROP, client);               
          }
          else
          {
            PrintHintText(client, "你无法再放置补给.");
          }
          return Plugin_Handled;          
        }        
      }
    }
    
    // Handle Perk (S): TRAPPER
    else if(usingSurPerk(client, ZF_PERK_TRAPPER))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能布置地雷.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须一直蹲在地上才能布置地雷.");
        }
        else
        {
          // Handle mine placement.
          new itemIndex = getFreeItemIndex(client, ZF_TRAPPER_MAX_ITEMS);
          if(itemIndex >= 0)
          {
            zf_perkTimer[client] = ZF_TRAPPER_TIMER;
            removeItem(client, itemIndex);
            zf_item[client][itemIndex] = doItemPlace(client, ZFMDL_MINE);

            fxCreateSoundToAll(ZFSND_PACKDROP, client);            
          }
          else
          {
            PrintHintText(client, "你无法再放置地雷.");
          }
          return Plugin_Handled;
        }        
      }
    }
    
    // Handle Perk (S): TANTRUM
    else if(usingSurPerk(client, ZF_PERK_TANTRUM))
    {
      if(zf_perkTimer[client] == 0)
      {
        zf_perkTimer[client] = ZF_TANTRUM_ACTIVE + ZF_TANTRUM_COOLDOWN;
        addCondKritz(client, float(ZF_TANTRUM_ACTIVE));
        fxKritzStart(client);
        
        return Plugin_Handled;
      }      
    }
    
  }
  else if(validLivingZom(client))
  {        
    // Handle Perk (Z): ALPHA
    if(usingZomPerk(client, ZF_PERK_ALPHA))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能召唤你的仆人们.");
          ClientCommand(client, "voicemenu 2 5");
        }
        else if(isCrouching(client))
        {
          PrintHintText(client, "你不需要蹲着来召唤仆人们.");
          ClientCommand(client, "voicemenu 2 5");
        }
        else if(isCloaked(client))
        {
          PrintHintText(client, "你必须要解除隐身才能召唤仆人.");
          ClientCommand(client, "voicemenu 2 5");
        }
        else
        {
          new summonCount = doAlphaSummon(client);
          if(summonCount > 0)
          {
            zf_perkTimer[client] = ZF_ALPHA_TIMER_MINION * summonCount;
            ClientCommand(client, "voicemenu 2 1");
          }
          else
          {
            PrintHintText(client, "你没有仆人来召唤!");
            ClientCommand(client, "voicemenu 2 5");            
          }          
        }
      }
      else
      {
        PrintHintText(client, "阿尔法 没准备好.");
        ClientCommand(client, "voicemenu 2 5");
      }      
    }
    
    // Handle Perk (Z): HUNTER
    else if(usingZomPerk(client, ZF_PERK_HUNTER))
    {
      if(zf_perkState[client] == 1)
      {
        PrintHintText(client, "你已经放过了你的重生标记.");
        ClientCommand(client, "voicemenu 2 5");
      }
      else if(!isGrounded(client))
      {
        PrintHintText(client, "你必须站在地上才能布置重生点.");
        ClientCommand(client, "voicemenu 2 5");        
      }
      else if(isCrouching(client))
      {
        PrintHintText(client, "你不需要蹲着来布置重生点.");
        ClientCommand(client, "voicemenu 2 5");
      }  
      else
      {
        zf_perkState[client] = 1;
        createAura(client, ZFPART_AURAVORTEXBLU, AttachNone);
        GetClientEyeAngles(client, zf_perkPos[client][0]);
        ClientCommand(client, "voicemenu 0 6");
      }
    }

    // Handle Perk (Z): LEAP 
    else if(usingZomPerk(client, ZF_PERK_LEAP))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能飞跃.");
          ClientCommand(client, "voicemenu 2 5");
        }
        else if(isCloaked(client))
        {
          PrintHintText(client, "你必须解除隐身才能飞跃.");
          ClientCommand(client, "voicemenu 2 5");
        }
        else
        {
          zf_perkTimer[client] = ZF_LEAP_COOLDOWN;
          fxJump(client, (isScout(client) ? ZF_LEAP_FORCE_SCOUT : ZF_LEAP_FORCE));
          fxPuffBig(client); 
        }
      }
      else
      {
        PrintHintText(client, "飞跃没准备好.");
        ClientCommand(client, "voicemenu 2 5");      
      }        
    }    
    
    // Handle Perk (Z): RAGE  
    else if(usingZomPerk(client, ZF_PERK_RAGE))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(getHealthPct(client) >= ZF_RAGE_HEALTHPCT_TOUSE)
        {
          zf_perkState[client] = 1;
          zf_perkTimer[client] = ZF_RAGE_COOLDOWN;
                                 
          addStat(client, ZFStatSpeed, ZFStatTypeCond, ZF_RAGE_SPEED);    
          setHealthPct(client, (1.0 + ZF_RAGE_HEALTHPCT_ONUSE)); 

          fxPowerup(client);
          createAura(client, ZFPART_AURABURNINGORANGE, AttachHead);
        }
        else
        {
          PrintHintText(client, "生命值在80%以上才能狂暴.");
          ClientCommand(client, "voicemenu 2 5"); 
        }
      }
      else
      {
        PrintHintText(client, "狂暴 没准备好.");
        ClientCommand(client, "voicemenu 2 5");      
      }  
    }
       
    // Handle Perk (Z): ROAR
    else if(usingZomPerk(client, ZF_PERK_ROAR))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能狂怒.");
          ClientCommand(client, "voicemenu 2 5");           
        }
        else if(isCloaked(client))
        {
          PrintHintText(client, "你必须解除隐身才能狂怒.");
          ClientCommand(client, "voicemenu 2 5");           
        }
        else
        {
          zf_perkTimer[client] = ZF_ROAR_COOLDOWN;

          // Apply radial damage. Use damage hook to detect roar "explosion."
          applyDamageRadialAtClient(client, 1, ZF_ROAR_RADIUS);
          fxPuffBig(client);
          ClientCommand(client, "voicemenu 2 1");           
        }
      }
      else
      {
        PrintHintText(client, "狂怒 没准备好.");
        ClientCommand(client, "voicemenu 2 5");          
      }
    }
       
    // Handle Perk (Z): SICK  
    else if(usingZomPerk(client, ZF_PERK_SICK))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(isCloaked(client))
        {
          PrintHintText(client, "你必须解除隐身才能吐痰.");
          ClientCommand(client, "voicemenu 2 5"); 
        }  
        else
        {
          zf_perkTimer[client] = ZF_SICK_TIMER;

          new Float:time = 0.0;
          for(new entIdx = 0; entIdx < ZF_SICK_MAX_ITEMS; entIdx++)
          {
            removeItem(client, entIdx);
            new Handle:dataPack = CreateDataPack();
            WritePackCell(dataPack, client);
            WritePackCell(dataPack, entIdx);
            CreateTimer(time, perk_tSickSpit, dataPack, TIMER_FLAG_NO_MAPCHANGE);
            time += 0.15;
          }
        }
      }
      else
      {
        PrintHintText(client, "吐痰没有准备好.");
        ClientCommand(client, "voicemenu 2 5");      
      }  
    }    
     
    // Handle Perk (Z): TANK
    else if(usingZomPerk(client, ZF_PERK_TANK))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(!isGrounded(client))
        {
          PrintHintText(client, "你必须站在地上才能释放青蛙.");
        }
        else if(!isCrouching(client))
        {
          PrintHintText(client, "你必须一直蹲在地上才能释放青蛙.");
        }
        else
        {
          zf_perkTimer[client] = ZF_TANK_FROG_COOLDOWN;
          removeItem(client, 0);            
          zf_item[client][0] = doItemPlace(client, ZFMDL_FROG);

          fxCreateSoundToAll(ZFSND_PACKDROP, client);
          return Plugin_Handled;
        }        
      }
    }
    // Handle Perk (Z): TARRED
    else if(usingZomPerk(client, ZF_PERK_TARRED))
    {
      if(zf_perkTimer[client] == 0)
      {
        if(isCloaked(client))
        {
          PrintHintText(client, "你必须解除隐身才能吐油);");
          ClientCommand(client, "voicemenu 2 5"); 
        }  
        else
        {
          zf_perkTimer[client] = ZF_TARRED_TIMER;

          new Float:time = 0.0;
          for(new entIdx = 0; entIdx < ZF_TARRED_MAX_ITEMS; entIdx++)
          {
            removeItem(client, entIdx);
            new Handle:dataPack = CreateDataPack();
            WritePackCell(dataPack, client);
            WritePackCell(dataPack, entIdx);
            CreateTimer(time, perk_tTarredSpit, dataPack, TIMER_FLAG_NO_MAPCHANGE);
            time += 0.15;
          }
        }
      }
      else
      {
        PrintHintText(client, "吐油没有准备好.");
        ClientCommand(client, "voicemenu 2 5");
      }
    }

    return Plugin_Handled;
  }
    
  return Plugin_Continue;
}

public perk_OnAmmoPickup(client, pickup)
{
  if(validLivingSur(client))
  {
    // Handle Perk (S): RESOURCEFUL    
    if(usingSurPerk(client, ZF_PERK_RESOURCEFUL))
    {
      addResAmmoPct(client, 0, 1.0);
      addResAmmoPct(client, 1, 1.0);
      addMetal(client, 200);
      addStatTempStack(client, ZFStatAtt, ZF_RESOURCEFUL_ATTACK, ZF_RESOURCEFUL_PICKUP_DURATION);
    }
  }
}

public perk_OnMedPickup(client, pickup)
{
  if(validLivingSur(client))
  {
    // Handle general survivor logic
    subCond(client, ZFCondPoisoned, ZF_POISON_HEAL_MEDPACK);    
    
    // Handle Perk (S): RESOURCEFUL    
    if(usingSurPerk(client, ZF_PERK_RESOURCEFUL))
    {
      setHealthPct(client, 1.0);
      addStatTempStack(client, ZFStatDef, ZF_RESOURCEFUL_DEFEND, ZF_RESOURCEFUL_PICKUP_DURATION);
    }
  }
}

////////////////////////////////////////////////////////////
//
// Perk Event Logic, Timer Callbacks
//
////////////////////////////////////////////////////////////
public Action:perk_tSpawnClient(Handle:timer, any:client)
{
  if(validClient(client) && !IsPlayerAlive(client))
  {
    spawnClient(client, zomTeam());
  }
}

public Action:perk_tNinjaDecoyPoof(Handle:Timer, any:client)
{
  if(validClient(client))
  {
    doNinjaDecoyPoof(client);
  }
}
   
public Action:perk_tSickSpit(Handle:timer, Handle:dataPack)
{        
  ResetPack(dataPack);
  new client = ReadPackCell(dataPack);
  new entIdx = ReadPackCell(dataPack); 
  CloseHandle(dataPack);
    
  if(validLivingZom(client))
  {
    zf_item[client][entIdx] = doItemThrow(client, ZFMDL_PRESENT[2], 1200.0, {75,255,75});
    getEntityPos(zf_item[client][entIdx], zf_perkPos[client][entIdx]);
    fxCreateSoundToAll(ZFSND_SPIT[GetRandomInt(0,2)], client);   
  }  
}

public Action:perk_tTarredSpit(Handle:timer, Handle:dataPack)
{
  ResetPack(dataPack);
  new client = ReadPackCell(dataPack);
  new entIdx = ReadPackCell(dataPack); 
  CloseHandle(dataPack);
    
  if(validLivingZom(client))
  {
    zf_item[client][entIdx] = doItemThrow(client, ZFMDL_PRESENT[2], 900.0, {25,25,25});
    getEntityPos(zf_item[client][entIdx], zf_perkPos[client][entIdx]);
    fxCreateSoundToAll(ZFSND_SPIT[GetRandomInt(0,2)], client);
  }  
}

public Action:perk_tZenlikeAttack(Handle:timer, any:client)
{
  if(validLivingSur(client))
  {
    zf_perkState[client] -= ZF_ZENLIKE_CRIT_DEC;
    if(zf_perkState[client] < 0) 
      zf_perkState[client] = 0;
  }
}

////////////////////////////////////////////////////////////
//
// Perk Menu Functionality
//
////////////////////////////////////////////////////////////

//
// Survivor Perk List Menu
// (Menu item N is perk N+1)
//
Handle:perk_buildSurPerkListMenu()
{
  new Handle:menu = CreateMenu(perk_menuSurPerkList);  
  if(menu != INVALID_HANDLE)
  {
    // Title
    SetMenuTitle(menu, "Select Survivor Perk");
    
    // Perks
    for(new i = 1; i < TOTAL_SUR_PERKS; i++)
      AddMenuItem(menu, ZF_SURPERK_NAME[i], ZF_SURPERK_SHORTDESC[i]);  
  }
  return menu; 
}

public perk_menuSurPerkList(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  { 
    panel_PrintSurPerkSelect(param1, param2 + 1);
  }
}

//
// Zombie Perk List Menu
// (Menu item N is perk N+1)
//
Handle:perk_buildZomPerkListMenu()
{
  new Handle:menu = CreateMenu(perk_menuZomPerkList);  
  if(menu != INVALID_HANDLE)
  {
    // Title
    SetMenuTitle(menu, "Select Zombie Perk");
    
    // Perks
    for(new i = 1; i < TOTAL_ZOM_PERKS; i++)
      AddMenuItem(menu, ZF_ZOMPERK_NAME[i], ZF_ZOMPERK_SHORTDESC[i]);  

  }
  return menu; 
}

public perk_menuZomPerkList(Handle:menu, MenuAction:action, param1, param2)
{
  if(action == MenuAction_Select)
  {
    panel_PrintZomPerkSelect(param1, param2 + 1);
  }
}

// 
// Survivor Perk Select Menu
//
public panel_PrintSurPerkSelect(client, perk)
{
  new Handle:panel = CreatePanel();
  
  SetPanelTitle(panel, "技能选择");
  DrawPanelText(panel, ZF_SURPERK_NAME[perk]);
  DrawPanelText(panel, ZF_SURPERK_LONGDESC[perk]);
  if(surPerkEnabled(perk))
    DrawPanelItem(panel, "[选择]", ITEMDRAW_DEFAULT);
  else
    DrawPanelItem(panel, "(被服务器禁用)", ITEMDRAW_DISABLED);
  DrawPanelItem(panel, "[返回]");
  DrawPanelItem(panel, "[关闭]");
  
  zf_menuPerk[client] = perk;
  SendPanelToClient(panel, client, panel_HandleSurPerkSelect, MENU_TIME_FOREVER);
  CloseHandle(panel);
}

public panel_HandleSurPerkSelect(Handle:menu, MenuAction:action, param1, param2)
{ 
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: 
        selectSurPerk(param1, zf_menuPerk[param1]);
      case 2: 
      {
        new firstItem = (((zf_menuPerk[param1] - 1) / 7) * 7);
        DisplayMenuAtItem(zf_menuSurPerkList, param1, firstItem, MENU_TIME_FOREVER); 
      }
      default: 
        return;   
    } 
  }
}

// 
// Zombie Perk Select Menu
//
public panel_PrintZomPerkSelect(client, perk)
{
  new Handle:panel = CreatePanel();
  
  SetPanelTitle(panel, "技能选择");
  DrawPanelText(panel, ZF_ZOMPERK_NAME[perk]);
  DrawPanelText(panel, ZF_ZOMPERK_LONGDESC[perk]);
  if(zomPerkEnabled(perk))
    DrawPanelItem(panel, "[选择]", ITEMDRAW_DEFAULT);
  else
    DrawPanelItem(panel, "(被服务器禁用)", ITEMDRAW_DISABLED);
  DrawPanelItem(panel, "[返回]");
  DrawPanelItem(panel, "[关闭]");
  
  zf_menuPerk[client] = perk;
  SendPanelToClient(panel, client, panel_HandleZomPerkSelect, MENU_TIME_FOREVER);
  CloseHandle(panel);
}

public panel_HandleZomPerkSelect(Handle:menu, MenuAction:action, param1, param2)
{ 
  if(action == MenuAction_Select)
  {
    switch(param2)
    {
      case 1: 
        selectZomPerk(param1, zf_menuPerk[param1]);
      case 2: 
      {
        new firstItem = (((zf_menuPerk[param1] - 1) / 7) * 7);
        DisplayMenuAtItem(zf_menuZomPerkList, param1, firstItem, MENU_TIME_FOREVER); 
      }
      default: 
        return;   
    } 
  }
}
