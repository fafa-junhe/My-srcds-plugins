// vsha_SDKHooks_OnEntityCreated.inc

public void OnEntityCreated(int entity, const char[] classname)
{
	if ( StrContains(classname, "tf_weapon_") != -1 ) CreateTimer( 0.4, OnWeaponSpawned, EntIndexToEntRef(entity) );
}
