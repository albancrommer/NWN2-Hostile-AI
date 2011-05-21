// script name - e_npc_hostile_dea
/*
	Description: custom onDeath event
  	
*/


#include "inc_ai_hostile"


void main (){
	
	object oCreature = OBJECT_SELF;
	

	LocalDebug("####### Creature Dead :: " , oCreature ); 

	// We want to get the creature team array
	string sTeam = GetLocalString ( oCreature, CREATURE_TEAM);

	// We want to get the morale modifier related to hierarchic flag
	int nFlags = GetLocalInt( oCreature, CREATURE_FLAGS);
	int  nCreatureHierarchicFlag = GetCreatureHierarchicFlag( nFlags );
	int  nMoraleModifier = GetMoraleModifierOnCreatureDeath ( nCreatureHierarchicFlag );

		// We want to update TeamMorale 
	UpdateTeamMorale(sTeam, nMoraleModifier);

	
LocalDebug( "****** Morale modifier on death : " + IntToString( nMoraleModifier ), oCreature );


	// We want to give the remaining xp of creature capital
	object oKiller = GetLastKiller();

	if( !GetIsObjectValid( oKiller ) )
	LocalDebug( "!!!!!! Invalid Killer : XP Distribution failed !!!  ", oCreature );

//	int nXP = GetLocalInt( oCreature, CREATURE_XP_TOTAL ) - GetLocalInt( oCreature, CREATURE_XP_REWARDED );
//	GiveXPToCreature( oKiller, nXP );
	GiveXPForDeath( oKiller );	
	

//	object oController = GetObjectByTag(AREA_CONTROLLER_TAG);
//	event eEvent =  EventUserDefined(EVENT_HOSTILE_CREATURE_DEAD);
//	SignalEvent( oController, eEvent);
	


}