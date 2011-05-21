
/// Party data structure
struct PARTY_DATA {
    /// strongest party member in range
    int nStrongestHD;
    /// weakest party member in range
    int nWeakestHD;
    /// average party level
    float  fAverageLevel;
    /// total number of levels in party (in range)
    float  fTotalPartyLevel;
    /// How many party members in range
    int    nMembersInRange;
    /// Total party members
    int    nPCMembers;
    /// How many NPC (summoned, henchman, etc) members?
    int    nNPCMembers;
};


/** Get a PARTY_DATA structure containing data about the current party.
 * Returns PARTY_DATA containing information about the party based
 * on the limits specified
 * @param oPartyMember: party member in question
 * @param fMaxDistance: max distance away from oPartyMember that other members may be.
 *                      use -1.0 to ignore distance
 * @param bPCOnly only include PCs in calculation, ignoring henchment, summoned, etc.
 *                if TRUE, nNPCMembers of the returned structure will be 0
 * @param bSameZoneOnly: only count creatures within the same area as oPartyMember as
 *                       being members of that party
 * @return structure containing party information
 */
struct PARTY_DATA xp_getPartyData(object oPartyMember, float fMaxDistance, int bPCOnly = TRUE, int bSameZoneOnly = TRUE);


/** Awards appropriate kill experience to PC and party members.
 * Gives appropriate XP to PC and party members for killing oDead. In doing so,
 * this takes into account server settings for base kill XP, party member levels,
 * relative CR, party size, etc.
 * @param oKiller is a valid PC, henchman, familiar, summoning, or animal companion.
 * @param oDead is a valid creature
 */
void xp_AwardPartyMembers(object oAwarded, int nXPAward, float fDistance);



struct PARTY_DATA xp_getPartyData(object oPartyMember, float fMaxDistance, int bPCOnly = TRUE, int bSameZoneOnly = TRUE)
{

    struct PARTY_DATA ret;
    ret.nPCMembers = 0;
    ret.nNPCMembers = 0;
    ret.nMembersInRange = 0;
    ret.fTotalPartyLevel = 0.0;
    ret.nStrongestHD = GetHitDice(oPartyMember); //  + GetECL(oPartyMember, TRUE);
    ret.nWeakestHD = ret.nStrongestHD;
    object oArea = GetArea(oPartyMember);
    int iHD = GetHitDice(oPartyMember);

    object oNext = GetFirstFactionMember(oPartyMember, FALSE);
    while (GetIsObjectValid(oNext)) {
        int bIsPC  = GetIsPC(oNext); // || GetIsPossessedFamiliar(oNext);
        float fDistance = GetDistanceBetween(oPartyMember, oNext);
        int iECL = 0;
        // MaxDist of -1 means to ignore max distance
        if (fMaxDistance == -1.0 || ((GetArea(oNext) == oArea || !bSameZoneOnly) && fDistance < fMaxDistance)) {
            int iHD = GetHitDice(oNext) + iECL;
            if ((bIsPC || !bPCOnly) && iHD > ret.nStrongestHD)
                ret.nStrongestHD = iHD;
            if ((bIsPC || !bPCOnly) && iHD < ret.nWeakestHD)
                ret.nWeakestHD = iHD;

            if (bIsPC) {
                ret.nMembersInRange = ret.nMembersInRange + 1;
                ret.fTotalPartyLevel += IntToFloat(iHD);
                ret.nPCMembers = ret.nPCMembers + 1;
            } else {
                if (!bPCOnly) {
                    ret.nMembersInRange = ret.nMembersInRange + 1;
                    ret.fTotalPartyLevel = ret.fTotalPartyLevel + IntToFloat(iHD);
                }
                ret.nNPCMembers = ret.nNPCMembers + 1;
            }
        }

        oNext = GetNextFactionMember(oPartyMember, FALSE);
    }
    //  LogObjectMessage(oPartyMember, " Calculating inclusive average level, first converting " + IntToString(ret.nMembersInRange) + " to float.", LOGLEVEL_DEBUG);
    // THIS SHOULD ALWAYS BE A MIN OF 1!!
    ret.fAverageLevel = ret.fTotalPartyLevel / IntToFloat(ret.nMembersInRange);
    return ret;
}


void xp_AwardPartyMembers(object oAwarded, int nXPAward, float fDistance)
{
    object oMaster = GetMaster(oAwarded);
    // QUick check: If killer is an NPC, skip all this (and avoid a divide by zero error in getpartydata)
    if (!GetIsPC(oAwarded) && !GetIsPC(oMaster) && !GetIsPossessedFamiliar(oAwarded)) {
        return;
    }
    if (GetIsPC(oMaster)) {
        oAwarded = oMaster;
    }
	object oArea = GetArea( oAwarded );
	

    // Award XP to each party member.
    object oNext = GetFirstFactionMember(oAwarded, TRUE);
    while (GetIsObjectValid(oNext)) {

        // Only party members in range
        if (oArea != GetArea(oNext) || GetDistanceBetween(oAwarded, oNext) > fDistance ) {
            oNext = GetNextFactionMember(oAwarded, TRUE);
            continue;
        }

 		GiveXPToCreature( oNext, nXPAward );
        oNext = GetNextFactionMember(oAwarded, TRUE);
    }
}

