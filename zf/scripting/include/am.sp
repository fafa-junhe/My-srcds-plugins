public Action Command_Enable(int client, int args)
{
CreateTimer(200.0, automessage, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public Action automessage(Handle hTimer)
{

PrintToChatAll("\x01[\x07FF0000α����\x01] QQȺ�ĺ��룺392651398");
return Plugin_Continue;
}