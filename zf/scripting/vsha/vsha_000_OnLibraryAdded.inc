// vsha_000_OnLibraryAdded.inc

public void OnLibraryAdded(const char[] name) //:D
{
#if defined _steamtools_included
	if (strcmp(name, "SteamTools", false) == 0) steamtools = true;
#endif
}
