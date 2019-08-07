/**
* ===============================================================
* Admin Funcommands Limiter | Version: 1.2 | NefariousDomination |
* ===============================================================
* Credit To Guys on the IRC for neverending help :)
* Big Credit to Javalia and Tsunami - always big help from them.
*
* Thanks loads to Dr. McKay :) - The whole reason this plugins improves lol
*/

#include <sourcemod>

#define PLUGIN_VERSION "1.3"

new CurrentKickAmount[MAXPLAYERS+1];
new CurrentBanAmount[MAXPLAYERS+1];
new CurrentSlapAmount[MAXPLAYERS+1];
new CurrentBeaconAmount[MAXPLAYERS+1];
new CurrentBlindAmount[MAXPLAYERS+1];
new CurrentTimebombAmount[MAXPLAYERS+1];
new CurrentBurnAmount[MAXPLAYERS+1];
new CurrentFirebombAmount[MAXPLAYERS+1];
new CurrentFreezeAmount[MAXPLAYERS+1];
new CurrentFreezebombAmount[MAXPLAYERS+1];
new CurrentGravityAmount[MAXPLAYERS+1];
new CurrentDrugAmount[MAXPLAYERS+1];
new CurrentNoclipAmount[MAXPLAYERS+1];
new CurrentSlayAmount[MAXPLAYERS+1];

new Handle:KickCV = INVALID_HANDLE;
new Handle:BanCV = INVALID_HANDLE;
new Handle:SlapCV = INVALID_HANDLE;
new Handle:BeaconCV = INVALID_HANDLE;
new Handle:BlindCV = INVALID_HANDLE;
new Handle:TimebombCV = INVALID_HANDLE;
new Handle:BurnCV = INVALID_HANDLE;
new Handle:FirebombCV = INVALID_HANDLE;
new Handle:FreezeCV = INVALID_HANDLE;
new Handle:FreezebombCV = INVALID_HANDLE;
new Handle:GravityCV = INVALID_HANDLE;
new Handle:DrugCV = INVALID_HANDLE;
new Handle:NoclipCV = INVALID_HANDLE;
new Handle:SlayCV = INVALID_HANDLE;
new Handle:ResultCV = INVALID_HANDLE;
new Handle:BantimeCV = INVALID_HANDLE;
new Handle:AdminControlType = INVALID_HANDLE;
new Handle:WarningCV = INVALID_HANDLE;

new String:Logfile[PLATFORM_MAX_PATH];

public Plugin:myinfo =
{
	name = "Fun Commands Admin Control",
	author = "Ewan Cook",
	description = "A Plugin That Controls the Usage of Funcommands for Sourcemod",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/member.php?u=227123",
};

public OnPluginStart()
{
	BuildPath(Path_SM, Logfile, sizeof(Logfile), "logs/AdminControl.log");
	
	AddCommandListener(Kick, "sm_kick");
	AddCommandListener(Ban, "sm_ban");
	AddCommandListener(Slap, "sm_slap");
	AddCommandListener(Beacon, "sm_beacon");
	AddCommandListener(Blind, "sm_blind");
	AddCommandListener(Timebomb, "sm_timebomb");
	AddCommandListener(Burn, "sm_burn");
	AddCommandListener(Firebomb, "sm_firebomb");
	AddCommandListener(Freeze, "sm_freeze");
	AddCommandListener(Freezebomb, "freezebomb");
	AddCommandListener(Gravity, "sm_gravity");
	AddCommandListener(Drug, "sm_drug");
	AddCommandListener(Noclip, "sm_noclip");
	AddCommandListener(Slay, "sm_slay");
	KickCV = CreateConVar("sm_admincontrol_kick", "5", "Max Amount of Times an Admin can Kick a player");
	BanCV = CreateConVar("sm_admincontrol_ban", "3", "Max Amount of Times an Admin can Ban a player");
	SlapCV = CreateConVar("sm_admincontrol_slap", "0" ,"Max Amount of Times an Admin can Slap a player");
	BeaconCV = CreateConVar("sm_admincontrol_beacon", "3", "Max Amount of Times an Admin can Beacon a player");
	BlindCV = CreateConVar("sm_admincontrol_blind", "0", "Max Amount of Times an Admin can Blind a player");
	TimebombCV = CreateConVar("sm_admincontrol_timebomb", "0", "Max Amount of Times an Admin can Timebomb a player");
	BurnCV = CreateConVar("sm_admincontrol_burn", "0", "Max Amount of Times an Admin can Burn a player");
	FirebombCV = CreateConVar("sm_admincontrol_firebomb", "0", "Max Amount of Times an Admin can Firebomb a player");
	FreezeCV = CreateConVar("sm_admincontrol_freeze", "1", "Max Amount of Times an Admin can Freeze a player");
	FreezebombCV = CreateConVar("sm_admincontrol_freezebomb", "0", "Max Amount of Times an Admin can Freezebomb a player");
	GravityCV = CreateConVar("sm_admincontrol_gravity", "0", "Max Amount of Times an Admin can Gravity a player");
	DrugCV = CreateConVar("sm_admincontrol_drug", "0", "Max Amount of Times an Admin can Drug a player");
	NoclipCV = CreateConVar("sm_admincontrol_noclip", "0", "Max Amount of Times an Admin can Noclip a player");
	SlayCV = CreateConVar("sm_admincontrol_slay", "1", "Max Amount of Times an Admin can Slay a player");
	ResultCV = CreateConVar("sm_admincontrol_result", "1", "Kick Or Ban a client for their offence: 1 = Kick 2 = Ban");
	BantimeCV = CreateConVar("sm_admincontrol_bantime", "0", "If sm_admincontrol_result = 2, amount of time to ban a client");
	AdminControlType = CreateConVar("sm_admincontrol_controltype", "0", "If 1, only clients without rcon access are limited");
	WarningCV = CreateConVar("sm_admincontrol_warning", "0", "If 1, doesn't print warnings to clients or log file.");
	AutoExecConfig(true, "admincontrol_cfg");
	
	CreateConVar("sm_admincontrol_version", PLUGIN_VERSION, "version of the plugin", FCVAR_DONTRECORD|FCVAR_NOTIFY);	
	PrintToServer("[SM] Current Version of Admin Funcommands Limiter is: %f", PLUGIN_VERSION);

}

public OnClientConnected(client)
{
	CurrentKickAmount[client] = 0;
	CurrentBanAmount[client] = 0;
	CurrentSlapAmount[client] = 0;
	CurrentBeaconAmount[client] = 0;
	CurrentBlindAmount[client] = 0;
	CurrentTimebombAmount[client] = 0;
	CurrentBurnAmount[client] = 0;
	CurrentFirebombAmount[client] = 0;
	CurrentFreezeAmount[client] = 0;
	CurrentFreezebombAmount[client] = 0;
	CurrentGravityAmount[client] = 0;
	CurrentDrugAmount[client] = 0;
	CurrentNoclipAmount[client] = 0;
	CurrentSlayAmount[client] = 0;
	
}

bool:CheckMonitor(client)
{
	if(CheckCommandAccess(client, "sm_addban", ADMFLAG_RCON, true) && GetConVarInt(AdminControlType) == 1)
	{
		return true;
	}	
	else
	{
		return false;
	}
}

public Action:Kick(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentKickAmount[client] = CurrentKickAmount[client]+1;
		if((CurrentKickAmount[client] < GetConVarInt(KickCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentKickAmount[client], GetConVarInt(KickCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentKickAmount[client], GetConVarInt(KickCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;
}

public Action:Ban(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentBanAmount[client] = CurrentBanAmount[client]+1;
		if((CurrentBanAmount[client] < GetConVarInt(BanCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentBanAmount[client], GetConVarInt(BanCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentBanAmount[client], GetConVarInt(BanCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;
}

public Action:Slap(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentSlapAmount[client] = CurrentSlapAmount[client]+1;
		if((CurrentSlapAmount[client] < GetConVarInt(SlapCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentSlapAmount[client], GetConVarInt(SlapCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentSlapAmount[client], GetConVarInt(SlapCV));
		}
			else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;
}

public Action:Beacon(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentBeaconAmount[client] = CurrentBeaconAmount[client]+1;
		if((CurrentBeaconAmount[client] < GetConVarInt(BeaconCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentBeaconAmount[client], GetConVarInt(BeaconCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentBeaconAmount[client], GetConVarInt(BeaconCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}	
	}
	return Plugin_Continue;
}

public Action:Blind(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentBlindAmount[client] = CurrentBlindAmount[client]+1;
		if((CurrentBlindAmount[client] < GetConVarInt(BlindCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentBlindAmount[client], GetConVarInt(BlindCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentBlindAmount[client], GetConVarInt(BlindCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}	
	}
	return Plugin_Continue;
}

public Action:Timebomb(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentTimebombAmount[client] = CurrentTimebombAmount[client]+1;
		if((CurrentTimebombAmount[client] < GetConVarInt(TimebombCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentTimebombAmount[client], GetConVarInt(TimebombCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentTimebombAmount[client], GetConVarInt(TimebombCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;	
}

public Action:Burn(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentBurnAmount[client] = CurrentBurnAmount[client]+1;
		if((CurrentBurnAmount[client] < GetConVarInt(BurnCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentBurnAmount[client], GetConVarInt(BurnCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentBurnAmount[client], GetConVarInt(BurnCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Firebomb(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentFirebombAmount[client] = CurrentFirebombAmount[client]+1;
		if((CurrentFirebombAmount[client] < GetConVarInt(FirebombCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentFirebombAmount[client], GetConVarInt(FirebombCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentFirebombAmount[client], GetConVarInt(FirebombCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Freeze(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentFreezeAmount[client] = CurrentFreezeAmount[client]+1;
		if((CurrentFreezeAmount[client] < GetConVarInt(FreezeCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentFreezeAmount[client], GetConVarInt(FreezeCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentFreezeAmount[client], GetConVarInt(FreezeCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Freezebomb(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentFreezebombAmount[client] = CurrentFreezebombAmount[client]+1;
		if((CurrentFreezebombAmount[client] < GetConVarInt(FreezebombCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentFreezebombAmount[client], GetConVarInt(FreezebombCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentFreezebombAmount[client], GetConVarInt(FreezebombCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Gravity(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentGravityAmount[client] = CurrentGravityAmount[client]+1;
		if((CurrentGravityAmount[client] < GetConVarInt(GravityCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentGravityAmount[client], GetConVarInt(GravityCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentGravityAmount[client], GetConVarInt(GravityCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Drug(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentDrugAmount[client] = CurrentDrugAmount[client]+1;
		if((CurrentDrugAmount[client] < GetConVarInt(DrugCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentDrugAmount[client], GetConVarInt(DrugCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentDrugAmount[client], GetConVarInt(DrugCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Noclip(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentNoclipAmount[client] = CurrentNoclipAmount[client]+1;
		if((CurrentNoclipAmount[client] < GetConVarInt(NoclipCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentNoclipAmount[client], GetConVarInt(NoclipCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentNoclipAmount[client], GetConVarInt(NoclipCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}

public Action:Slay(client, const String:command[], args)
{
	if(CheckMonitor(client))
	{
		PrintToServer("%N 's commands are not being logged.", client);
	}
	else
	{
		CurrentSlayAmount[client] = CurrentSlayAmount[client]+1;
		if((CurrentSlayAmount[client] < GetConVarInt(SlayCV)) && GetConVarInt(WarningCV) == 0)
		{
			LogToFile(Logfile, "%N has had %d out of %d warnings", client, CurrentSlayAmount[client], GetConVarInt(SlayCV));
			PrintToChat(client, "You have had %d out of %d warnings", CurrentSlayAmount[client], GetConVarInt(SlayCV));
		}
		else
		{
			if(GetConVarInt(ResultCV) == 2)
			{
				LogToFile(Logfile, "%N was banned for abusing admin privileges", client);
				BanClient(client, GetConVarInt(BantimeCV), BANFLAG_AUTO, "You were banned for abusing admin privileges");
			}
			else
			{
				LogToFile(Logfile, "%N was kicked for abusing admin privileges", client);
				KickClient(client, "You were kicked for abusing admin privileges");
			}
		}
	}
	return Plugin_Continue;		
}