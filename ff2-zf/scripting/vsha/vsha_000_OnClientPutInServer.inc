// vsha_000_OnClientPutInServer.inc

public void OnClientPutInServer(int client)
{
	//SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
	Storage[client] = null;
	BossArrayListIndex[client] = -1;
	iBoss[client] = -1;
	iPresetBoss[client] = -1;
	bIsBoss[client] = false;
	iDifficulty[client] = 0;
	iDamage[client] = 0;
	iBossesKilled[client] = 0;
	iPlayerKilled[client][0] = 0;
	iPlayerKilled[client][1] = 1;
	iHits[client] = 0;
	bNoTaunt[client] = false;
	OnPreventCoreOnTakeDamageChanges[client] = false;
}
