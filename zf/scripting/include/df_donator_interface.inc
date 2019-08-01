/**
 * Danmaku Fortress Donator Interface
 *
 * DO NOT INCLUDE THIS WITH DF SUBPLUGINS.
 * It is only intended for donation management modules to have a way to report to Danmaku Fortress that someone's donor status has loaded.
 *
 * Since there are many different donation systems out there, this is really the only reasonable way to handle this use case.
 */

// reflective method calls
#define DF_MAIN_PLUGIN_FILENAME "danmaku_fortress.smx"
stock GetDFMethod(const String:methodName[], &Handle:retPlugin, &Function:retFunc)
{
	static String:buffer[256];
	new Handle:iter = GetPluginIterator();
	new Handle:plugin = INVALID_HANDLE;
	while (MorePlugins(iter))
	{
		plugin = ReadPlugin(iter);
		
		GetPluginFilename(plugin, buffer, sizeof(buffer));
		if (StrContains(buffer, DF_PLUGIN_FILENAME, false) != -1)
			break;
		else
			plugin = INVALID_HANDLE;
	}
	
	CloseHandle(iter);
	if (plugin != INVALID_HANDLE)
	{
		new Function:func = GetFunctionByName(plugin, methodName);
		if (func != INVALID_FUNCTION)
		{
			retPlugin = plugin;
			retFunc = func;
		}
		else
			PrintToServer("[danmaku_fortress] ERROR: Could not find %s:%s()", DF_MAIN_PLUGIN_FILENAME, methodName);
	}
	else
		PrintToServer("[danmaku_fortress] ERROR: Could not find %s. %s() failed.", DF_MAIN_PLUGIN_FILENAME, methodName);
}

stock DFP_ClientIsDonator(clientIdx)
{
	new Handle:plugin = INVALID_HANDLE;
	new Function:func = INVALID_FUNCTION;
	GetDFMethod("DFP_ClientIsDonator", plugin, func);
	if (plugin == INVALID_HANDLE || func == INVALID_FUNCTION)
		return;

	Call_StartFunction(plugin, func);
	Call_PushCell(clientIdx);
	Call_Finish();
	CloseHandle(plugin);
}
