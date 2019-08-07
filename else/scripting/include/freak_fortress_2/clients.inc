enum ClientValues
{
	Client_Index = 0,
    Client_Damage,
    Client_Assist,
    Client_GlowTime,
    Client_Flags,
    Client_SpecialAttackCount, // NOTE: This is array.
    Client_MusicData, // TODO: This is array?

	ClientValues_Last
};

/*
    Create when client is connented.
    Deleted when client is disconnected.
*/


methodmap FF2Client < ArrayList {
	public FF2Client(int client)
	{
		int arraySize = (view_as<int>(ClientValues_Last));
		ArrayList clientValues = new ArrayList(MAX_BOSS_SLOT_COUNT, arraySize);

		return view_as<FF2Client>(clientValues);
	}
}
