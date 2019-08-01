// vsha_Engine_UpdateHealthBar.inc

public void UpdateHealthBar()
{
	if(!AllowHealthBar)
	{
		if (iHealthBar != -1)
		{
			if (IsValidEntity(iHealthBar))
			{
				iHealthBar = -1;
				AcceptEntityInput(iHealthBar, "Kill");
			}
		}
		return;
	}

	int bossHP = 0, bossMaxHealth = 0, bosscount = 0;
	//int bosscount = 0;
	LoopIngameClients(target)
	{
		if ( !IsClientValid(target) || !bIsBoss[target] ) continue;

		//dohealth += iBossHealth[i]-iBossMaxHealth[i];
		bossHP += iBossHealth[target];
		bossMaxHealth += iBossMaxHealth[target];

		// Take the lowest boss health
		//if( iBossHealth[target] < iLowestBossHP)
		//{
			//iLowestBossHP = iBossHealth[target];
		//}
		bosscount++;
	}
	if ( bosscount >= 1 )
	{
		if(iHealthBar == -1)
		{
			FindHealthBar();
			if(iHealthBar == -1) return;
		}
		int BossIndex = GetFirstBossIndex();

		int percentage = 1;
		if (ValidPlayer(BossIndex,true))
		{
			//int maxHP = GetEntProp(BossIndex, Prop_Data, "m_iMaxHealth");
			//int HP = GetEntProp(BossIndex, Prop_Data, "m_iHealth");

			//int HP = iBossHealth[BossIndex];
			//int maxHP = iBossMaxHealth[BossIndex];

			if (bossHP <= 0)
			{
				percentage = 1;
			}
			else
			{
				float fHP = float(bossHP);
				float fmaxHP = float(bossMaxHealth);
				float fHEALTHBAR = float(HEALTHBAR_MAX);

				//PrintToChatAll("fHP %f fmaxHP %f fHEALTHBAR %f",fHP,fmaxHP,fHEALTHBAR);
				//percentage = RoundToCeil(FloatMul(FloatDiv(fHP,fmaxHP),fHEALTHBAR));
				percentage = RoundToCeil((fHP / fmaxHP) * fHEALTHBAR);

				//PrintToChatAll("percentage %d",percentage);

				if(percentage>HEALTHBAR_MAX)
				{
					percentage=HEALTHBAR_MAX;
				}
			}
		}
		else
		{
			percentage = 1;
		}
		SetEntProp(iHealthBar, Prop_Send, HEALTHBAR_PROPERTY, percentage);

		/*
		int percenthp = RoundFloat( float(dohealth) / float(domaxhealth) * 255.0 );
		if (percenthp > 255) percenthp = 255;
		else if (percenthp <= 0) percenthp = 1;
		SetEntProp(iHealthBar, Prop_Send, "m_iBossHealthPercentageByte", percenthp);*/

		//DP("UPDATE HEALTH BAR %i",percentage);
	}
	else if ( bosscount <= 0 && iHealthBar != -1)
	{
		if (IsValidEntity(iHealthBar))
		{
			iHealthBar = -1;
			AcceptEntityInput(iHealthBar, "Kill");
		}
	}
}
