// script name - e_npc_hostile_att
/*
	Description: custom onAttacked event
  	
*/


#include "inc_ai_hostile"


void main (){
	
	object oCreature = OBJECT_SELF;
	
	if( GetLocalInt ( oCreature, CREATURE_FLAGS ) & AI_FLAG_WILD )
		ActionFlee( oCreature, GetLastAttacker( oCreature ) );

	// We want to get the creature team array
	string sTeam = GetLocalString ( oCreature, CREATURE_TEAM);
	object oController = GetObjectByTag( sTeam );

	SetLocalObject( oController, CONTROLLER_TEAM_TARGET_CURRENT, GetLastAttacker() );
	
		
	// If the team is not yet at First Sight step, time to
	if( GetLocalInt( oController, CONTROLLER_TEAM_STATE ) < ACTION_TEAM_COMBAT ) {
//		LocalDebug("########### WAKING TEAM UP : ATTACKED ############" , oCreature ); 
	
		event eEvent =  EventUserDefined(EVENT_HOSTILE_CREATURE_TEAM_WAKE);
		SignalEvent( oController, eEvent);

		SetLocalInt( oController, CONTROLLER_TEAM_STATE, ACTION_TEAM_FIRST_SIGHT);	
	
	}
	


}