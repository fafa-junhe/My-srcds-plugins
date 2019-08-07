#pragma semicolon 1

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <morecolors>
#include <menus>
#include <adminmenu>


#define PLUG_VER	"1.0.0"

public Plugin myinfo =
{
	name = "[TF2] Give Powerups",
	author = "aIM",
	description = "Gives Mannpower Powerups to a player.",
	version = PLUG_VER,
	url = ""
};

public OnPluginStart()
{
	/* Powerups */
	RegAdminCmd("sm_givestrength", Command_Strength, ADMFLAG_GENERIC, "Gives the powerup Strength to a player.");
	RegAdminCmd("sm_giveresistance", Command_Resistance, ADMFLAG_GENERIC, "Gives the powerup Resistance to a player.");
	RegAdminCmd("sm_givevampire", Command_Vampire, ADMFLAG_GENERIC, "Gives the powerup Vampire to a player.");
	RegAdminCmd("sm_givereflect", Command_Reflect, ADMFLAG_GENERIC, "Gives the powerup Reflect to a player.");
	RegAdminCmd("sm_givehaste", Command_Haste, ADMFLAG_GENERIC, "Gives the powerup Haste to a player.");
	RegAdminCmd("sm_giveregen", Command_Regeneration, ADMFLAG_GENERIC, "Gives the powerup Regeneration to a player.");
	RegAdminCmd("sm_giveprecision", Command_Precision, ADMFLAG_GENERIC, "Gives the powerup Precision to a player.");
	RegAdminCmd("sm_giveagility", Command_Agility, ADMFLAG_GENERIC, "Gives the powerup Agility to a player.");
	RegAdminCmd("sm_giveknockout", Command_Knockout, ADMFLAG_GENERIC, "Gives the powerup Knockout to a player.");
	
	/* Special Powerups */
	RegAdminCmd("sm_giveking", Command_King, ADMFLAG_GENERIC, "Gives the powerup King to a player.");
	RegAdminCmd("sm_giveplague", Command_Plague, ADMFLAG_GENERIC, "Gives the powerup Plague to a player.");
	RegAdminCmd("sm_givesupernova", Command_Supernova, ADMFLAG_GENERIC, "Gives the powerup Supernova to a player.");
	
	/* Powerup Variants */
	RegAdminCmd("sm_powermenu", Command_Powerups, ADMFLAG_GENERIC, "Opens the powerup menu.");
}

public Action Command_Strength(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_givestrenght {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneStrength);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}STRENGTH {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Resistance(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveresistance {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneResist);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}RESISTANCE {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Vampire(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_givevampire {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneVampire);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}VAMPIRE {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Reflect(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_givereflect {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneWarlock);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}REFLECT {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Haste(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_givehaste {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneHaste);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}HASTE {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Regeneration(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveregen {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneRegen);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}REGENERATION {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Precision(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveprecision {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RunePrecision);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}PRECISION {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Agility(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveagility {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneAgility);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}AGILITY {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Knockout(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveknockout {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_RuneKnockout);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}KNOCKOUT {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_King(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveking {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_KingRune);
		TF2_AddCondition(target_list[i], TFCond_KingAura);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}KING {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Plague(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_giveplague {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_Plague);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {red}PLAGUE {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Supernova(client, args)
{
	new String:arg1[32];
	if (!CheckCommandAccess(client, "givepowerups", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	if (args != 1)
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}Usage: sm_givesupernova {valve}<player>");
		return Plugin_Handled;
	}
	if (args == 1)
	{
		GetCmdArg(1, arg1, sizeof(arg1));
	}
	
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg1,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		/* This function replies to the admin with a failure message */
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	for (new i = 0; i < target_count; i++)
	{
		TF2_AddCondition(target_list[i], TFCond_SupernovaRune);
		TF2_AddCondition(target_list[i], TFCond_HasRune);
		CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave {yellow}SUPERNOVA {white}to player %s", client, target_name);
	}
	return Plugin_Handled;
}

public Action Command_Powerups(client, args)
{
	if (!CheckCommandAccess(client, "givepowerupsmenu", ADMFLAG_GENERIC))
	{
		CReplyToCommand(client, "{lawngreen}[= Powerups =] {white}No access.");
		return Plugin_Handled;
	}
	else
	{
		OpenPowerupMenu(client);
	}
	return Plugin_Handled;
}


/* POWERUP MENU HANDLER */

char selection[64];

public Action PowerupHandler(Handle:PowerupMenu, MenuAction:action, client, param1)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			GetMenuItem(PowerupMenu, param1, selection, sizeof(selection));
			OpenClientsMenu(client);
		}
	}
	return Plugin_Handled;
}

public Action PlayerListMenu(Handle:PlayerList, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			/* Thanks AlliedModders */
			decl String:info[32];
			new userid, target;
			
			GetMenuItem(PlayerList, param2, info, sizeof(info));
			userid = StringToInt(info);
			target = GetClientOfUserId(userid);
			
			if (StrEqual(selection, "strength"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				
				TF2_AddCondition(target, TFCond_RuneStrength);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}STRENGTH {white}to player %N", target);
			}
			else if (StrEqual(selection, "resist"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneResist);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}RESISTANCE {white}to player %N", target);
			}
			else if (StrEqual(selection, "vampire"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneVampire);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}VAMPIRE {white}to player %N", target);
			}
			else if (StrEqual(selection, "reflect"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneWarlock);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}REFLECT {white}to player %N", target);
			}
			else if (StrEqual(selection, "haste"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneHaste);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}HASTE {white}to player %N", target);
			}
			else if (StrEqual(selection, "regen"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneRegen);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}REGENERATION {white}to player %N", target);
			}
			else if (StrEqual(selection, "precision"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RunePrecision);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}PRECISION {white}to player %N", target);
			}
			else if (StrEqual(selection, "agility"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneAgility);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}AGILITY {white}to player %N", target);
			}
			else if (StrEqual(selection, "knockout"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_RuneKnockout);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}KNOCKOUT {white}to player %N", target);
			}
			else if (StrEqual(selection, "king"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_KingRune);
				TF2_AddCondition(target, TFCond_KingAura);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}KING {white}to player %N", target);
			}
			else if (StrEqual(selection, "plague"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_Plague);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}PLAGUE {white}to player %N", target);
			}
			else if (StrEqual(selection, "supernova"))
			{
				if (!IsPlayerAlive(target))
				{
					CPrintToChat(client, "{lawngreen}[= Powerups =] {white}This player is dead!");
					return Plugin_Handled;
				}
				TF2_AddCondition(target, TFCond_SupernovaRune);
				TF2_AddCondition(target, TFCond_HasRune);
				CPrintToChatAll("{lawngreen}[= Powerups =] {white}%N gave powerup {yellow}SUPERNOVA {white}to player %N", target);
			}
		}
	}
	return Plugin_Handled;
}

/* POWERUP MENU */



OpenPowerupMenu(client)
{
	new Handle:PowerupMenu = CreateMenu(MenuHandler:PowerupHandler);
	SetMenuTitle(PowerupMenu, "Powerups Menu");
	AddMenuItem(PowerupMenu, "strength", "Strength");
	AddMenuItem(PowerupMenu, "resist", "Resistance");
	AddMenuItem(PowerupMenu, "vampire", "Vampire");
	AddMenuItem(PowerupMenu, "reflect", "Reflect");
	AddMenuItem(PowerupMenu, "haste", "Haste");
	AddMenuItem(PowerupMenu, "regen", "Regeneration");
	AddMenuItem(PowerupMenu, "precision", "Precision");
	AddMenuItem(PowerupMenu, "agility", "Agility");
	AddMenuItem(PowerupMenu, "knockout", "Knockout");
	AddMenuItem(PowerupMenu, "king", "King");
	AddMenuItem(PowerupMenu, "plague", "Plague");
	AddMenuItem(PowerupMenu, "supernova", "Supernova");
	SetMenuExitButton(PowerupMenu, true);
	DisplayMenu(PowerupMenu, client, 30);
}

OpenClientsMenu(client)
{
	new Handle:PlayerList = CreateMenu(MenuHandler:PlayerListMenu);
	SetMenuTitle(PlayerList, "Select a player");
	
	AddTargetsToMenu(PlayerList, client, true, true);
	
	SetMenuExitButton(PlayerList, true);
	DisplayMenu(PlayerList, client, 30);
}