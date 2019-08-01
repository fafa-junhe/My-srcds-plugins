// vsha_CreateTimer_CalcScores.inc

public Action CalcScores(Handle timer, int data)
{
	int j, damage;
	for (int i = 1; i <= MaxClients; i++)
	{
		if ( IsValidClient(i) && IsOnBlueOrRedTeam(i) )
		{
			damage = iDamage[i];

			Event aevent = CreateEvent("player_escort_score", true);
			aevent.SetInt("player", i);

			for (j = 0; damage-600 > 0; damage -= 600, j++) {}
			aevent.SetInt("points", j);
			aevent.Fire();

			if ( bIsBoss[i] )
			{
				SetClientQueuePoints(i, 0);
				CPrintToChat(i, "{olive}[VSHA Engine]{default} You now have %i queue points.", GetClientQueuePoints(i));
			}
			else
			{
				CPrintToChat(i, "{olive}[VSHA Engine]{default} You get %i+ queue points.", QueueIncrement.IntValue); //GetConVarInt(QueueIncrement));
				SetClientQueuePoints( i, (GetClientQueuePoints(i)+QueueIncrement.IntValue) );
				CPrintToChat(i, "{olive}[VSHA Engine]{default} You now have %i queue points.", GetClientQueuePoints(i));
			}
		}
	}
}
