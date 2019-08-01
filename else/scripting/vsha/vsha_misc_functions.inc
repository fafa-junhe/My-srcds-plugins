// vsha_misc_functions.inc

public void FindHealthBar()
{
	iHealthBar = FindEntityByClassname2(-1, HEALTHBAR_CLASS);
	if (iHealthBar == -1)
	{
		iHealthBar = CreateEntityByName(HEALTHBAR_CLASS);
		if (iHealthBar != -1) DispatchSpawn(iHealthBar);
	}
}

public void CheckArena()
{
	if (PointType) SetArenaCapEnableTime(view_as<float>(45+PointDelay.IntValue*(iPlaying-1)));
	else
	{
		SetArenaCapEnableTime(0.0);
		SetControlPoint(false);
	}
}

public int GetClientQueuePoints(int client)
{
	if (!IsValidClient(client)) return 0;
	if (!AreClientCookiesCached(client))
	{
		return iQueuePoints[client];
	}
	else
	{
		char strPoints[32]; GetClientCookie(client, PointCookie, strPoints, sizeof(strPoints));
		return StringToInt(strPoints);
	}
}
public void SetClientQueuePoints(int client, int points)
{
	if (!IsValidClient(client)) return;
	if (!AreClientCookiesCached(client))
	{
		iQueuePoints[client]=points;
	}
	else
	{
		char strPoints[32]; IntToString(points, strPoints, sizeof(strPoints));
		SetClientCookie(client, PointCookie, strPoints);
	}
}

public bool OnlyScoutsLeft()
{
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) break;
			return true;
		}
	}
	return false;
}
public int CountScoutsLeft()
{
	int scunts = 0;
	for (int client; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client) && !bIsBoss[client])
		{
			if (TF2_GetPlayerClass(client) != TFClass_Scout) continue;
			scunts++;
		}
	}
	return scunts;
}

public bool GetRJFlag(int client)
{
	return (IsValidClient(client, false) && IsPlayerAlive(client) ? bInJump[client] : false);
}
public void SetRJFlag(int client, bool bState)
{
	if (IsValidClient(client, false)) bInJump[client] = bState;
}

