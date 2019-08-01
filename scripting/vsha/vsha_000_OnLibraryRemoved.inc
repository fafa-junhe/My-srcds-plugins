// vsha_000_OnLibraryRemoved.inc

public void OnLibraryRemoved(const char[] name)
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = false;
#endif
}
