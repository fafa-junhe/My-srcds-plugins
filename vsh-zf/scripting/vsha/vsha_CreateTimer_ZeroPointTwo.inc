// vsha_CreateTimer_ZeroPointTwo.inc
public Action ZeroPointTwo(Handle timer, int data)
{
	Action result = HaleTimer(null);
	if(result == Plugin_Stop) return Plugin_Stop;
	return BossTimer(null);
}
