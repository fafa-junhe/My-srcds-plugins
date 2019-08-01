// vsha_CreateTimer_BossResponse.inc

public Action BossResponse(Handle timer, int data)
{
	VSHA_OnBossIntroTalk();

	hBossResponse = null;
	return Plugin_Continue;
}
