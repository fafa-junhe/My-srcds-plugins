#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <smlib>

#define PLUGIN_VERSION  "1.1"

public Plugin:myinfo = 
{
	name = "Engineer Bot Fix",
	author = "EfeDursun125",
	description = "Engineer bots now can upgrade teleporters and more fixes.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/EfeDursun91/"
}

Float:moveForward(Float:vel[3],Float:MaxSpeed)
{
	vel[0] = MaxSpeed;
	return vel;
}

Float:moveBackwards(Float:vel[3],Float:MaxSpeed)
{
	vel[0] = -MaxSpeed;
	return vel;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3]) // TO DO : Fix wranings
{
	if(IsValidClient(client))
	{
		if(IsFakeClient(client))
		{
			if(IsPlayerAlive(client))
			{
				new TFClassType:class = TF2_GetPlayerClass(client);
				if(class == TFClass_Engineer)
				{
					new iTeleporter = -1;
					new iDispenser = -1;
					new iSentry = -1;
					new iMySentry = -1;
					new iSpy = -1;
					new iNeedAmmo = -1;
					while((iTeleporter = FindEntityByClassname(iTeleporter, "obj_teleporter")) != INVALID_ENT_REFERENCE) // tRololo312312's plugins helped me on this line
					{
						new iTeamNumObj = GetEntProp(iTeleporter, Prop_Send, "m_iTeamNum");
						if(IsValidEntity(iTeleporter) && GetClientTeam(client) == iTeamNumObj)
						{
							new Float:clientOrigin[3];
							new Float:teleporterOrigin[3];
							GetClientAbsOrigin(client, clientOrigin);
							GetEntPropVector(iTeleporter, Prop_Send, "m_vecOrigin", teleporterOrigin);
							
							decl Float:camangle[3], Float:clientEyes[3], Float:fEntityLocation[3];
							GetClientEyePosition(client, clientEyes);
							decl Float:vec[3],Float:angle[3];
							GetEntPropVector(iTeleporter, Prop_Send, "m_vecOrigin", fEntityLocation);
							GetEntPropVector(iTeleporter, Prop_Data, "m_angRotation", angle);
							fEntityLocation[2] += 10.0;
							MakeVectorFromPoints(fEntityLocation, clientEyes, vec);
							GetVectorAngles(vec, camangle);
							camangle[0] *= -1.0;
							camangle[1] += 180.0;
							ClampAngle(camangle);

							new Float:chainDistance;
							chainDistance = GetVectorDistance(clientOrigin, teleporterOrigin);
							
							new iTeleporterLevel = GetEntProp(iTeleporter, Prop_Send, "m_iUpgradeLevel");
							new iTeleporterSapped = GetEntProp(iTeleporter, Prop_Send, "m_bHasSapper");
							new iTeleporterHealth = GetEntProp(iTeleporter, Prop_Send, "m_iHealth");
							new iTeleporterMaxHealth = GetEntProp(iTeleporter, Prop_Send, "m_iMaxHealth");

							if(GetHealth(client) >= 125.0 && GetMetal(client) > 130 && iTeleporterLevel < 3 || iTeleporterSapped == 1 || iTeleporterHealth <= (iTeleporterMaxHealth / 1.5)) // Save Metal For Build Sentry
							{
								if(IsPointVisibleTank(clientOrigin, teleporterOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 300.0 && chainDistance > 100.0)
									{
										TF2_LookAtBuilding(client, teleporterOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
									else if(chainDistance <= 100.0)
									{
										TeleportEntity(client, NULL_VECTOR, camangle, NULL_VECTOR);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 100.0)
									{
										buttons |= IN_DUCK;
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
						}
					}
					while((iDispenser = FindEntityByClassname(iDispenser, "obj_dispenser")) != INVALID_ENT_REFERENCE)
					{
						new iTeamNumObj = GetEntProp(iDispenser, Prop_Send, "m_iTeamNum");
						if(IsValidEntity(iDispenser) && GetClientTeam(client) == iTeamNumObj)
						{
							new Float:clientOrigin[3];
							new Float:dispenserOrigin[3];
							GetClientAbsOrigin(client, clientOrigin);
							GetEntPropVector(iDispenser, Prop_Send, "m_vecOrigin", dispenserOrigin);

							new Float:chainDistance;
							chainDistance = GetVectorDistance(clientOrigin, dispenserOrigin);
							
							new iDispenserLevel = GetEntProp(iDispenser, Prop_Send, "m_iUpgradeLevel");
							new iDispenserrSapped = GetEntProp(iDispenser, Prop_Send, "m_bHasSapper");
							new iDispenserHealth = GetEntProp(iDispenser, Prop_Send, "m_iHealth");
							new iDispenserMaxHealth = GetEntProp(iDispenser, Prop_Send, "m_iMaxHealth");
							
							if(iDispenserrSapped == 1 || GetMetal(client) > 130 && iDispenserHealth <= (iDispenserMaxHealth / 2) || GetMetal(client) > 100 && iDispenserHealth <= (iDispenserMaxHealth / 1.5) || GetMetal(client) >= 200 && iDispenserHealth <= (iDispenserMaxHealth / 1.1) || GetMetal(client) > 130 && iDispenserLevel < 3)
							{
								if(IsPointVisibleTank(clientOrigin, dispenserOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 1000.0)
									{
										TF2_LookAtBuilding(client, dispenserOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
							else if(GetHealth(client) >= 125.0 && GetMetal(client) >= 200 && iDispenserLevel < 3)
							{
								if(IsPointVisibleTank(clientOrigin, dispenserOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 400.0)
									{
										TF2_LookAtBuilding(client, dispenserOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
							else if(GetHealth(client) < 125.0 && GetMetal(client) >= 200 && iDispenserLevel < 3)
							{
								if(IsPointVisibleTank(clientOrigin, dispenserOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 200.0)
									{
										TF2_LookAtBuilding(client, dispenserOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 100.0)
									{
										buttons |= IN_DUCK;
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
						}
					}
					while((iSentry = FindEntityByClassname(iSentry, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
					{
						new iTeamNumObj = GetEntProp(iSentry, Prop_Send, "m_iTeamNum");
						if(IsValidEntity(iSentry) && GetClientTeam(client) == iTeamNumObj)
						{
							new Float:clientOrigin[3];
							new Float:sentryOrigin[3];
							GetClientAbsOrigin(client, clientOrigin);
							GetEntPropVector(iSentry, Prop_Send, "m_vecOrigin", sentryOrigin);

							new Float:chainDistance;
							chainDistance = GetVectorDistance(clientOrigin, sentryOrigin);
							
							new iSentryLevel = GetEntProp(iSentry, Prop_Send, "m_iUpgradeLevel");
							new iSentrySapped = GetEntProp(iSentry, Prop_Send, "m_bHasSapper");
							new iSentryHealth = GetEntProp(iSentry, Prop_Send, "m_iHealth");
							new iSentryMaxHealth = GetEntProp(iSentry, Prop_Send, "m_iMaxHealth");
							new iSentryAmmo = GetEntProp(iSentry, Prop_Send, "m_iAmmoShells");
							new iSentryRockets = GetEntProp(iSentry, Prop_Send, "m_iAmmoRockets");
							
							if(iSentryAmmo < 35 || iSentryRockets < 7 || iSentrySapped == 1 || GetMetal(client) > 130 && iSentryHealth <= (iSentryMaxHealth / 2) || GetMetal(client) > 100 && iSentryHealth <= (iSentryMaxHealth / 1.5) || GetMetal(client) >= 200 && iSentryHealth <= (iSentryMaxHealth / 1.1))
							{
								if(IsPointVisibleTank(clientOrigin, sentryOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 1000.0)
									{
										TF2_LookAtBuilding(client, sentryOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
							else if(GetHealth(client) >= 125.0 && GetMetal(client) >= 200 && iSentryLevel < 3)
							{
								if(IsPointVisibleTank(clientOrigin, sentryOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 400.0)
									{
										TF2_LookAtBuilding(client, sentryOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
							else if(GetHealth(client) < 125.0 && GetMetal(client) >= 200 && iSentryLevel < 3)
							{
								if(IsPointVisibleTank(clientOrigin, sentryOrigin) && IsWeaponSlotActive(client, 2))
								{
									if(chainDistance < 200.0)
									{
										TF2_LookAtBuilding(client, sentryOrigin, 0.055);
										buttons |= IN_ATTACK;
									}
								
									if(chainDistance < 60.0)
									{
										vel = moveBackwards(vel,300.0);
									}
								
									if(chainDistance > 80.0)
									{
										vel = moveForward(vel,300.0);
									}
								
									if(chainDistance < 100.0)
									{
										buttons |= IN_DUCK;
									}
								
									if(chainDistance < 150.0 && buttons & IN_FORWARD)
									{
										buttons &= ~IN_FORWARD;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVELEFT)
									{
										buttons &= ~IN_MOVELEFT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_MOVERIGHT)
									{
										buttons &= ~IN_MOVERIGHT;
									}
								
									if(chainDistance < 150.0 && buttons & IN_BACK)
									{
										buttons &= ~IN_BACK;
									}
								}
							}
						}
					}
					while((iMySentry = FindEntityByClassname(iMySentry, "obj_sentrygun")) != INVALID_ENT_REFERENCE)
					{
						new iTeamNumObj = GetEntProp(iMySentry, Prop_Send, "m_iTeamNum");
						if(IsValidEntity(iMySentry) && GetClientTeam(client) == iTeamNumObj)
						{
							new Float:clientOrigin[3];
							new Float:sentryOrigin[3];
							GetClientAbsOrigin(client, clientOrigin);
							GetEntPropVector(iMySentry, Prop_Send, "m_vecOrigin", sentryOrigin);

							new Float:chainDistance;
							chainDistance = GetVectorDistance(clientOrigin, sentryOrigin);
							
							new iMySentrySapped = GetEntProp(iMySentry, Prop_Send, "m_bHasSapper");
							
							if(iMySentrySapped == 1 && chainDistance < 1000.0)
							{
								while((iSpy = FindEntityByClassname(iSpy, "obj_attachment_sapper")) != INVALID_ENT_REFERENCE)
								{
									new iTeamNumObj2 = GetEntProp(iSpy, Prop_Send, "m_iTeamNum");
									if(IsValidEntity(iSpy) && GetClientTeam(client) != iTeamNumObj2)
									{
										new Float:clientOrigin2[3];
										new Float:spyOrigin[3];
										GetClientAbsOrigin(client, clientOrigin2);
										GetEntPropVector(iMySentry, Prop_Send, "m_vecOrigin", spyOrigin);

										new Float:SpyDistance;
										SpyDistance = GetVectorDistance(clientOrigin2, spyOrigin);
										
										if(SpyDistance < 1000.0 && IsPointVisibleTank(clientOrigin2, spyOrigin) && IsClientMoving(client) == 1)
										{
											TF2_LookAtBuilding(client, sentryOrigin, 0.075);
											Client_SetActiveWeapon(client, GetPlayerWeaponSlot(client, 0));
											buttons |= IN_ATTACK;
										}
										else if(SpyDistance < 500.0 && IsPointVisibleTank(clientOrigin2, spyOrigin))
										{
											TF2_LookAtBuilding(client, sentryOrigin, 0.075);
											Client_SetActiveWeapon(client, GetPlayerWeaponSlot(client, 0));
											buttons |= IN_ATTACK;
										}
									}
								}
							}
						}
					}
					if(GetMetal(client) <= 0)
					{
						while((iNeedAmmo = FindEntityByClassname(iNeedAmmo, "item_ammopack_full")) != INVALID_ENT_REFERENCE)
						{
							new Float:clientOrigin[3];
							new Float:ammoOrigin[3];
							GetClientAbsOrigin(client, clientOrigin);
							GetEntPropVector(iNeedAmmo, Prop_Send, "m_vecOrigin", ammoOrigin);
							
							new Float:chainDistance;
							chainDistance = GetVectorDistance(clientOrigin, ammoOrigin);
							
							if(GetHealth(client) >= 125.0 && IsPointVisibleTank(clientOrigin, ammoOrigin) && chainDistance < 250.0) // 1.1 Fix Stuck Bug
							{
								TF2_LookAtBuilding(client, ammoOrigin, 0.055);
								vel = moveForward(vel,300.0);
								if(buttons & IN_DUCK)
								{
									buttons &= ~IN_DUCK;
								}
							}
						}
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

stock void TF2_LookAtBuilding(int client, float flGoal[3], float flAimSpeed = 0.05) // Smooth Aim From Pelipoika
{
    float flPos[3];
    GetClientEyePosition(client, flPos);

    float flAng[3];
    GetClientEyeAngles(client, flAng);
	
	decl Float:FixBuildingAngle[3];
	FixBuildingAngle[1] += 180.0; // Fix For Aim Building's angle
    
    // get normalised direction from target to client
    float desired_dir[3];
    MakeVectorFromPoints(flPos, flGoal, desired_dir);
    GetVectorAngles(desired_dir, desired_dir);
    
    // ease the current direction to the target direction
    flAng[0] += AngleNormalize(desired_dir[0] - flAng[0]) * flAimSpeed;
    flAng[1] += AngleNormalize(desired_dir[1] - flAng[1]) + FixBuildingAngle[1] * flAimSpeed;
	
    TeleportEntity(client, NULL_VECTOR, flAng, NULL_VECTOR);
} 

stock float AngleNormalize(float angle)
{
    angle = fmodf(angle, 360.0);
    if (angle > 89) 
    {
        angle -= 360;
    }
    if (angle < -89)
    {
        angle += 360;
    }
    
    return angle;
}

stock float fmodf(float number, float denom)
{
    return number - RoundToFloor(number / denom) * denom;
}

bool IsClientMoving(int client)
{
    float buffer[3];
    GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", buffer);
    return (GetVectorLength(buffer) > 0.0);
}

stock ClampAngle(Float:fAngles[3])
{
	while(fAngles[0] > 89.0)  fAngles[0]-=360.0;
	while(fAngles[0] < -89.0) fAngles[0]+=360.0;
	while(fAngles[1] > 180.0) fAngles[1]-=360.0;
	while(fAngles[1] <-180.0) fAngles[1]+=360.0;
}

stock GetMetal(client)
{
	return GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3);
}

stock GetHealth(client)
{
	return GetEntProp(client, Prop_Send, "m_iHealth");
}

stock bool:IsWeaponSlotActive(iClient, iSlot)
{
    return GetPlayerWeaponSlot(iClient, iSlot) == GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
}

stock bool:IsPointVisibleTank(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint, TraceEntityFilterStuffTank);
	return TR_GetFraction() >= 0.9;
}

public bool:TraceEntityFilterStuffTank(entity, mask)
{
	new maxentities = GetMaxEntities();
	return entity > maxentities;
}

stock bool:IsPointVisible(const Float:start[3], const Float:end[3])
{
	TR_TraceRayFilter(start, end, MASK_PLAYERSOLID, RayType_EndPoint, TraceEntityFilterStuff);
	return TR_GetFraction() >= 0.9;
}

public bool:TraceEntityFilterStuff(entity, mask)
{
	return entity > MaxClients;
}

bool:IsValidClient( client ) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}
  