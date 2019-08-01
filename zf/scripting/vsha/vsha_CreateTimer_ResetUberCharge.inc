// vsha_CreateTimer_ResetUberCharge.inc

public Action ResetUberCharge(Handle timer, int medigunid)
{
	int medigun = EntRefToEntIndex(medigunid);
	if ( IsValidEntity(medigun) ) SetMediCharge(medigun, GetMediCharge(medigun)+MedigunReset.FloatValue); //GetConVarFloat(MedigunReset)); //40.0
}
