// script name - e_npc_hostile_blo
/*
	Description: custom On Blocked
	
	

*/

void main() {


//	    SpeakString("Oh noes ! I'm blocked !");

} 

/*

#include "inc_helper"

void main()
{
    if (ExecuteHookScript("BlockedScript")) {
        return;
    }

    object oDoor = GetBlockingDoor();
    if (GetObjectType(oDoor) == OBJECT_TYPE_CREATURE)
    {
        // * Increment number of times blocked
        /*SetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED", GetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED") + 1);
        if (GetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED") > 3)
        {
            SpeakString("Blocked by creature");
            SetLocalInt(OBJECT_SELF, "X2_NUMTIMES_BLOCKED",0);
            ClearAllActions();
            object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
            if (GetIsObjectValid(oEnemy) == TRUE)
            {
                ActionEquipMostDamagingRanged(oEnemy);
                ActionAttack(oEnemy);
            }
            return;
        }   */ /*
        return;
    }
    if(GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 5)
    {
        if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) && GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 7 )
        {
            DoDoorAction(oDoor, DOOR_ACTION_OPEN);
        }
        else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH))
        {
            DoDoorAction(oDoor, DOOR_ACTION_BASH);
        }
    }
}
*/