// script name - e_npc_hostile_dam
/*
	Description: custom onDamaged event
   
	Sends event message to area controller 

	
*/

#include "inc_ai_hostile"

void main (){

//	LocalDebug("Creature Damaged"); 
	
	object oCreature = OBJECT_SELF;
	
	// Coward creatures should flee
	if( GetLocalInt ( oCreature, CREATURE_FLAGS ) & AI_FLAG_WILD ){
		ActionFlee( oCreature, GetLastDamager() );
	}
	
	int nCurHP =  GetCurrentHitPoints();
	if( nCurHP < 0 )
		nCurHP = 0;

	
	// We want to get the difference of HP with last update : : positive if creature healed 
	 int  nDiffHP = nCurHP - GetLocalInt( oCreature, CREATURE_HP_CURRENT) ;
	
	// We want to get the creature team array
	string sTeam = GetLocalString ( oCreature, CREATURE_TEAM);
LocalDebug("Lost " + IntToString(nDiffHP) + " HP on my " + IntToString(GetLocalInt(oCreature,CREATURE_HP_MAX) ) + " Current HP : " + IntToString( GetLocalInt( oCreature, CREATURE_HP_CURRENT ) ), oCreature ) ;

	// We want to update the Team and the Creature CurrentHP variable
	UpdateTeamCurrentHP( sTeam, nDiffHP );
	SetLocalInt( oCreature, CREATURE_HP_CURRENT, GetCurrentHitPoints() );


}