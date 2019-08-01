// vsha_Engine_OnWeaponSpawned.inc

public Action OnWeaponSpawned(Handle timer, any ref)
{
	int wep = EntRefToEntIndex(ref);
	if ( IsValidEntity(wep) && IsValidEdict(wep) )
	{
		int client = GetOwner(wep);
		if (!IsValidClient(client)) return Plugin_Continue;
		AmmoTable[wep] = GetWeaponAmmo(wep);
		ClipTable[wep] = GetWeaponClip(wep);
	}
	return Plugin_Continue;
}

