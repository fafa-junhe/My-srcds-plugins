// vsha_Events.inc


public void vsha_Events_AskPluginLoad2()
{
	CreateNative("VSHA_CreateEvent", Native_VSHA_CreateEvent);//foritems

	g_VSHA_GlobalEventFH = CreateGlobalForward("OnVSHAEvent",ET_Hook,Param_Cell,Param_Cell);
}

public int Native_VSHA_CreateEvent(Handle plugin, int numParams)
{
	VSHA_EVENT event=GetNativeCell(1);
	int client=GetNativeCell(2);

	Action result = Plugin_Continue;

	Call_StartForward(g_VSHA_GlobalEventFH);
	Call_PushCell(event);
	Call_PushCell(client);
	Call_Finish(result);

	return view_as<int>result;
}

