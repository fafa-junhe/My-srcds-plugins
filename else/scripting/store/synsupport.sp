#if defined STANDALONE_BUILD
#include <sourcemod>
#include <sdktools>

#include <store>
#include <zephstocks>
#endif

#if defined STANDALONE_BUILD
public OnPluginStart()
#else
public SYNSupport_OnPluginStart()
#endif
{
#if defined STANDALONE_BUILD
	new String:m_szGameDir[32];
	GetGameFolderName(m_szGameDir, sizeof(m_szGameDir));
	
	if(strcmp(m_szGameDir, "synergy")==0)
		GAME_SYN = true;
#endif
	if(!GAME_SYN)
		return;	

	HookEvent("entity_killed", SYN_Entity_Death);
}

public Action SYN_Entity_Death(Event event, const char[] name, bool dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "entindex_killed"));
	new attacker = GetClientOfUserId(GetEventInt(event, "entindex_attacker"));

	if(!attacker || !IsClientInGame(attacker) || IsFakeClient(attacker) || !IsNPC(victim))
		return Plugin_Continue;

	if(g_eCvars[g_cvarCreditAmountKill][aCache])
	{
		g_eClients[attacker][iCredits] += GetMultipliedCredits(attacker, g_eCvars[g_cvarCreditAmountKill][aCache]);
		if(g_eCvars[g_cvarCreditMessages][aCache])
			Chat(attacker, "%t", "Credits Earned For Killing", g_eCvars[g_cvarCreditAmountKill][aCache], "NPC");
		Store_LogMessage(attacker, g_eCvars[g_cvarCreditAmountKill][aCache], "Earned for killing");
	}
		
	return Plugin_Continue;
}

stock bool IsNPC(monster)
{
	if (IsValidEdict(monster) && IsValidEntity(monster))
	{
		new String:edictname[32];
		GetEdictClassname(monster, edictname, 32);
		
		if (StrContains(edictname, "npc_") == 0)
			return (true);
	}
	
	return (false);
}