void main() {

ExecuteScript("x2_plc_used_act", GetItemActivated() );

SpeakString("activated");

/*
location locWP1 = GetLocation( GetObjectByTag( "wp1") );
location locWP2 = GetLocation( GetObjectByTag( "wp2") );

object oSpawned1 = CreateObject( 
	OBJECT_TYPE_CREATURE, 
	"test_creature", 
	locWP1,
	FALSE,
	"spawned1" );

	
object oSpawned2 = CreateObject( 
	OBJECT_TYPE_CREATURE, 
	"test_creature", 
	locWP1,
	FALSE,
	"spawned2" );
	
SetFirstName( oSpawned1, "standard");
SetFirstName( oSpawned2, "custom");
SetCreatureScriptsToSet( oSpawned2, 11);							

AssignCommand( oSpawned1, ActionMoveToLocation( locWP2, TRUE ) );
AssignCommand( oSpawned2, ActionMoveToLocation( locWP2, TRUE ) );
*/

object oPC = GetLastUsedBy();
LevelUpHenchman( oPC );
}