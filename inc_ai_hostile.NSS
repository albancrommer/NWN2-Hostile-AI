 //:://////////////////////////////////////////////////
//:: inc_npc_ai
//:://////////////////////////////////////////////////
/*
	Description: library for npc AI management
*/
//:://////////////////////////////////////////////////
// 080102 Alban 
//:://////////////////////////////////////////////////
/*

CREATURE LINES : 
Flag:BitWise|SpawnMin:0|SpawnMax:xx|Resref:string|CR:float|NumberOfWaypoints|WP_team_1|WP_team_2|etc.		

*/
 

// These libraries either switch to standard or Khalidine 
//#include "inc_ai_hostile_khalidine"
#include "inc_ai_hostile_standard"


// These libraries are part of nwnx xp_hashset 
// and appear courtesy of GrinningFool
#include "nwnx_hashset"
#include "nwnx_util"

// These libraries are distributed 
// and appear courtesy of their authors
// #include "inc_helper" 
#include "inc_vectors"


// These libraries are standard NWN2 distribution
#include "ginc_debug"
#include "ginc_behavior"
#include "nw_i0_generic"
#include "nw_i0_plot"
#include "x0_i0_spawncond"
#include "x0_i0_enemy"
#include "x0_i0_talent"
#include "x0_i0_position"




// :: ----------------------------------------------------------------------------------------------------
// :: CONSTANTS
// :: ----------------------------------------------------------------------------------------------------

// Some objects tags and name
const string CONTROLLER_RESREF 			= "combataicontroller";
const string FINAL_SPAWN_ARRAY_NAME		= "FINAL_SPAWN_ARRAY_NAME";
const string POOL_BASE_ARRAY_NAME 		= "POOL_BASE_ARRAY_NAME";
const string POOL_BASE_ARRAY_COUNT 		= "POOL_BASE_ARRAY_COUNT";
const string TEMP_ARRAY_NAME 			= "TEMP_ARRAY_NAME";
const string WAYPOINT_ARRAY_NAME 		= "WAYPOINT_ARRAY_NAME";


// These parameters are what you'll want to tweak to adapt to a module
const float TARGET_CR_GLOBAL_MODIFIER = 	1.0; // defines general difficulty at module level
const float XP_FOR_FLEE_MODIFIER = 			0.5; // defines how much xp gets distributed when creatures flee
const int MAX_FLEE_ROUNDS = 				10; // defines the numbers of round to wait before despawning escaping creatures
const int MAX_FLEE_ROUNDS_WILDLIFE = 		20; // same as upper, but for wildlife
const float DISTANCE_DISAPPEAR_FLEEING = 	30.0; // above this distance from next pc, escaping creatures aren't despawned
const int S_MAX_LOC_SEARCH_DEPTH = 				10; // defines the depth of search when fleeing


// Some more parameters
const int CUSTOM_CREATURE_SCRIPTSET_NUMBER = 		11; // the custom line in nwn2_scriptsets.2da
const float DISTANCE_ARCHER_RETREAT = 9.0;
const float DISTANCE_DEFAULT_RETREAT = 10.0;
const float DISTANCE_FLEE_RETREAT = 37.0; // considered safe distance by fleeing creatures
const float DISTANCE_PARTY_SCAN = 30.0; // Used to calculate the PC party facts
const float DISTANCE_SCOUT_RANGE = 60.0; // defines the scouts perception range
const float DISTANCE_PERCEPTION_DEFAULT = 50.0; 
const float DISTANCE_SAFE_LOCATION_MED = 10.0; // used to get valid locations, performance tweak setting
const float DISTANCE_SAFE_LOCATION_LOW = 3.0; // used to get valid locations, performance setting


// The AI bounds 
const int AI_CUSTOM_HIGH 		= 15;
const int AI_CUSTOM_NORMAL 		= 10;
const int AI_CUSTOM_LOW 	= 6;			



// The available events 
const int EVENT_HOSTILE_CREATURE_SPAWN = 	74840;
const int EVENT_HOSTILE_CREATURE_DAMAGED= 	74841;
const int EVENT_HOSTILE_CREATURE_DEAD = 	74842;
const int EVENT_HOSTILE_CREATURE_TEAM_WAKE = 	74843;


// The variables set on Module 
// const string HOSTILE_SPAWN_COUNTER = "HOSTILE_SPAWN_COUNTER"; 


// The hostile teams array indexes 
const string CONTROLLER_TEAM_FEAR_FACTOR  		= "CONTROLLER_TEAM_FEAR_FACTOR";
const string CONTROLLER_TEAM_HAS_BOSS  			= "CONTROLLER_TEAM_HAS_BOSS";
const string CONTROLLER_TEAM_HP_CURRENT  		= "CONTROLLER_TEAM_HP_CURRENT";
const string CONTROLLER_TEAM_HP_TOTAL 			= "CONTROLLER_TEAM_HP_TOTAL";
const string CONTROLLER_TEAM_MORALE_CURRENT  	= "CONTROLLER_TEAM_MORALE_CURRENT";
const string CONTROLLER_TEAM_ROUND_COUNT  		= "CONTROLLER_TEAM_ROUND_COUNT";
const string CONTROLLER_TEAM_STATE  			= "CONTROLLER_TEAM_STATE";
const string CONTROLLER_TEAM_TARGET_CURRENT  	= "CONTROLLER_TEAM_TARGET_CURRENT";



// The hostile teams array indexes 
const int INDEX_CREATURE_SPAWN_FLAGS = 		0;
const int INDEX_CREATURE_SPAWN_MIN = 	1;
const int INDEX_CREATURE_SPAWN_MAX = 	2;			
const int INDEX_CREATURE_SPAWN_RESREF = 	3;
const int INDEX_CREATURE_SPAWN_CR	= 4;			
const int INDEX_CREATURE_SPAWN_WAYPOINT_NUMBER	= 5;			
const int INDEX_CREATURE_SPAWN_FIRST_WAYPOINT	= 6; // 6+ indexes are waypoints tags



// The variables set on hostiles creatures 
const string CREATURE_AI_LEVEL = 		"CREATURE_AI_LEVEL";
const string CREATURE_HP_CURRENT  = 	"CREATURE_HP_CURRENT";
const string CREATURE_HP_MAX  = 		"CREATURE_HP_MAX";
const string CREATURE_FLAGS  = 			"CREATURE_FLAGS";
const string CREATURE_FLEE_COUNT = 		"CREATURE_FLEE_COUNT";
const string CREATURE_FLEE_WAYPOINT = 	"CREATURE_FLEE_WAYPOINT";
const string CREATURE_LAST_LOCATION = 	"CREATURE_LAST_LOCATION";
const string CREATURE_STATE = 			"CREATURE_STATE";
const string CREATURE_TARGET = 			"CREATURE_TARGET";
const string CREATURE_TEAM = 			"CREATURE_TEAM";
const string CREATURE_XP_REWARDED  = 	"CREATURE_XP_REWARDED";
const string CREATURE_XP_TOTAL = 		"CREATURE_XP_TOTAL";


// The variables set on triggers
const string TRIGGER_CREATURE =			"CREATURE_"; 
const string TRIGGER_DELAY =			"DELAY";
const string TRIGGER_DIFFICULTY =		"DIFFICULTY";
const string TRIGGER_FEAR_FACTOR =		"FEAR_FACTOR";
const string TRIGGER_FLEE_WAYPOINT	= 	"FLEE_WAYPOINT";
const string TRIGGER_LEVEL_MIN =		"MIN";
const string TRIGGER_LEVEL_MAX =		"MAX";
const string TRIGGER_NAME =				"NAME";
const string TRIGGER_STATE =			"TRIGGER_STATE";
const string TRIGGER_TEAM_STATE =		"TEAM_STATE";
const string TRIGGER_TIMESTAMP =		"TIMESTAMP";
const string TRIGGER_TAG_ENTERED =		"TAG_ENTERED";
const string TRIGGER_TOD  		= 		"TOD";



// The available flags for creatures behaviour
///@ This needs to be reworked
const int AI_FLAG_WILD 			= 0x00000001;
const int AI_FLAG_AGRESSIVE 		= 0x00000002; // Not used
const int AI_FLAG_STEALTH			= 0x00000004;
const int AI_FLAG_SEARCH			= 0x00000008; // Not used
const int AI_FLAG_BOSS				= 0x00000010; // 16
const int AI_FLAG_RIGHTHAND			= 0x00000020; // 32
const int AI_FLAG_UNIQUE			= 0x00000040; // 64
const int AI_FLAG_TWO				= 0x00000080; // 128
const int AI_FLAG_ARCHER			= 0x00000100; // 256
const int AI_FLAG_BUFFER			= 0x00000200; // 512
const int AI_FLAG_CASTER			= 0x00000400; // 1024
const int AI_FLAG_HEALER			= 0x00000800; // 2048
const int AI_FLAG_COWARD			= 0x00001000; // 4096
const int AI_FLAG_SCOUT			= 0x00002000; // 8192



// Time Of Day 
// TOD_0 means : encounter active from 00h00 to 01h59

const int TOD_0 			= 0x00000001;
const int TOD_2 			= 0x00000002;
const int TOD_4				= 0x00000004;
const int TOD_6				= 0x00000008;
const int TOD_8				= 0x00000010; // 16
const int TOD_10			= 0x00000020; // 32
const int TOD_12			= 0x00000040; // 64
const int TOD_14			= 0x00000080; // 128
const int TOD_16			= 0x00000100; // 256
const int TOD_18			= 0x00000200; // 512
const int TOD_20			= 0x00000400; // 1024
const int TOD_22			= 0x00000800; // 2048
// Max sum : 4095 => always spawn



// The Morale factors
const int MORALE_BONUS_PER_NEW_MEMBER 	= 3;
const int MORALE_MALUS_PER_DEAD_BOSS 	= 8;
const int MORALE_MALUS_PER_DEAD_RIGHTHAND = 4;
const int MORALE_MALUS_PER_DEAD_MEMBER 	= 2;
const float MORALE_MALUS_FOR_RETREATING 	= 0.3;
const int MORALE_MALUS_20_PERCENT_HP_LEFT 	= 15;
const int MORALE_MALUS_40_PERCENT_HP_LEFT = 9;
const int MORALE_MALUS_60_PERCENT_HP_LEFT 	= 6;
const int MORALE_MALUS_80_PERCENT_HP_LEFT 	= 3;
const int MORALE_MALUS_100_PERCENT_HP_LEFT 	= 0;
const int MORALE_BASE_AMOUNT				= 20;

// The Trigger / Encounter Action flags
const int ACTION_TRIGGER_WAITING 		= 1;
const int ACTION_TRIGGER_REQUESTING_SPAWN 	= 2;
const int ACTION_TRIGGER_IN_PROGRESS 		= 3;
const int ACTION_TRIGGER_FLEE			= 4;



// The Creature Action flags
const int ACTION_CREATURE_WANDER		= 1;
const int ACTION_CREATURE_COMBAT 		= 2;
const int ACTION_CREATURE_RETREAT 		= 3;
// TODO : implement those
const int ACTION_CREATURE_PATROL 		= 4;
const int ACTION_CREATURE_HIDE 			= 5;
const int ACTION_CREATURE_AMBUSH 		= 6;
const int ACTION_CREATURE_ROUTED 		= 7;
const int ACTION_CREATURE_DRAWING_INTO_TRAP 	= 8;

// The Team Action flags
const int ACTION_TEAM_WANDER		= 0;
const int ACTION_TEAM_FIRST_SIGHT	= 1; // This isn't used anymore
const int ACTION_TEAM_COMBAT 		= 2; 
// TODO : implement those
const int ACTION_TEAM_RETREAT 		= 3; 
const int ACTION_TEAM_PATROL 		= 4;
const int ACTION_TEAM_HIDE 			= 5;
const int ACTION_TEAM_AMBUSH 		= 6;
const int ACTION_TEAM_ROUTED 		= 7;
const int ACTION_TEAM_DRAWING_INTO_TRAP 	= 8;


// Some variables names
const string VAR_XP_FLEE_DISTRIBUTED 	= "XP_FLEE_DISTRIBUTED";

// :: ----------------------------------------------------------------------------------------------------
// :: FUNCTION PROTOTYPES
// :: ----------------------------------------------------------------------------------------------------


// Returns the creature hierarchic flag or 0 if none set
int  GetCreatureHierarchicFlag (  int nFlags );

// Updates team morale value 
void UpdateTeamMorale( string sControllerTag, int nMoraleModifier );

// Updates team morale and destroys creature
int DestroyTeamCreature( object oCreature );


// Returns a CR Modifier for party members amount 
float _getCRModifierMembers( int nMembers );


// Returns a relative CR
// fBase is greater than fAdd and the difference 
float _getRelativeCR( float fBase, float fAdd );


// Returns the expected CR for encounter
float GetTargetCR( float fAverageLevel, int nMembers, float fDifficulty, float fLocalModifier);


// Returns the Updated CR
float GetUpdatedReachedCR( float fReachedCR, float fCR);

// Returns TRUE if probability says spawn happens
///@ TODO : determine eventually a good formula
int RollSpawnProbability( float fTargetCR, float fPotentialCR, int nToSpawn, int nMembers );


// This will create a Controller if required
object InstantiateController( string sControllerTag, location lLoc );


// Adds a team array
void CreateTeamArray( string sArrayName );


// Updates team current HP value 
void UpdateTeamCurrentHP(string sControllerTag, int nDiffHP);


// Returns a custom AI Level
int GetCustomAILevel( object oCreature );


// Returns TRUE if target is valid
int GetIsValidTarget( object oTarget );


// Returns TRUE if a valid target object has been set on oCreature
// Probably too much params assigned, migth require cleanup
// Intelligent creature get better targets
// This also checks if current target (or personal) target is alive to skip
// TODO : For the moment, all creatures look for nearest
// We might want to store the spellcasters using onCastSpellAt
// PLUS, they don't see you in plain sight
int GetTarget( object oCreature );


// Will remove the actual target if the creature is a fleeing boss
// The more intelligent the creature AI level is, the more it will 
// choose an interesting target, the lesser a close target
// This also checks if current target (or personal) target is alive to skip
void SuppressTeamTarget( int nHierarchicFlag, int nHasBoss );


// Returns TRUE if AI_LEVEL roll fails and not a leader
int GetHasNotUnderstoodOrders( int nCreatureAILevel, int nFlags ); 


// Makes creature flee from closer enemy or last recorded target.
int ActionFlee( object oCreature, object oTarget = OBJECT_INVALID );


// Actions a an attack at target
void ActionCustomAttack( object oCreature, object oTarget );


// Returns TRUE if creature's too close from enemy 
int RetreatFromMelee( object oCreature, float fDistance =  DISTANCE_DEFAULT_RETREAT );


// Returns the morale modifier for creature death
int  GetMoraleModifierOnCreatureDeath ( int CreatureHierarchicFlag );


// Returns TRUE if creatures succeeds a d20 roll against a difficulty number 
// that is the result of a formula including various team and self factors
int GetCreatureMoraleRollResult( float fFearFactor, int nMoraleCurrent, int nPercentHPRemainingTeam, int nPercentHPRemainingCreature, float fRetreatMultiplierMalus );


// Returns the XP to reward to PC / PARTY
int GetCreatureXPReward( string sCR, int  nPartyAverageLevel );


// Gives partial XP for creature fleeing
void GiveXPForFlee( object oAttacker, object oAttacked );


// Gives remaining XP of creature to killer team
void GiveXPForDeath( object oKiller, object oKilled = OBJECT_SELF );


// Returns TRUE if the encounter is within the bounds
int GetIsEncounterSpawnable( int nPartyAverageLevel, int nLevelMin, int nLevelMax );


// Returns TRUE if creature has special function tags attached
int GetCreatureHasFunction( int nFlags );


// Reads creature flags and runs the right function command
int GetCreatureHasBuffing( int nFlags );


// Summons a Creature relevant to nLevel enemy
void CustomSummonAllies ( object oCreature, int nLevel = 9, int bInstantSpell = TRUE );


// Sets flags for creature oCreature depending on its flags and 
void SetSpawnFlag( object oCreature, int nCondition,  int nFlags, string sGlobalSpawnVar = sSpawnCondVarname );


// Used to manage archers behaviour
void DetermineArcherCombatRound( object oCreature, object oTarget ); 


// Used to manage buffers behavior
void DetermineBufferCombatRound( object oCreature, object oTarget ); 


// Used to manage casters behavior
void DetermineCasterCombatRound( object oCreature, object oTarget ); 


// Used to manage healers behavior
void DetermineHealerCombatRound( object oCreature, object oTarget ); 


// Reads creature flags and runs the right function command
void UseFunctionInCombat( object oCreature, object oTarget, int nFlags);


// Buffs creature
void UseFunctionBuff( object oCreature );

// Returns a location opposite from oTarget at distance fDist from oCreature 
// Angle receives a small random input and optional angle :
// -90 means right from oTarget, 90 left from it
location GetFleeLocation( object oCreature, object oTarget, float fDist, float fOptionalAngle = 0.0 );

// :: ==================================================================================
// :: UTILITIES
// :: ==================================================================================

// Local debug
void LocalDebug(string strMsg, object oObject = OBJECT_INVALID ) {

	strMsg = GetTag( oObject ) + " :: " + strMsg;
//	object oPC = GetFirstPC(  );
//	SendMessageToPC(oPC, strMsg);
	WriteTimestampedLogEntry( strMsg );
	
}


// Spawns a vfx at given location
void LocalDebugPosition( location lLocation ) {
/*
	effect eEffect = EffectNWN2SpecialEffectFile( "fx_gem_energy_yellow" );
	ApplyEffectAtLocation( DURATION_TYPE_TEMPORARY, eEffect, lLocation, 6.0);
 */
}



// :: ==================================================================================
// :: TIME
// :: ==================================================================================

// Returns time elapsed in hours since 0/0/0 00:00
int GetHourStamp( ) { return ( ( GetCalendarYear(  ) * 12 + GetCalendarMonth(  ) ) * 28 + GetCalendarDay(  ) ) * 24 + GetTimeHour(  ); }

// Returns the TOD tage
int _getTODTag(){

	switch( GetTimeHour() ){
	
		case 0: 	case 1:		return TOD_0; break;
		case 2: 	case 3:		return TOD_2; break;
		case 4: 	case 5:		return TOD_4; break;
		case 6: 	case 7:		return TOD_6; break;
		case 8: 	case 9:		return TOD_8; break;
		case 10: 	case 11:	return TOD_10; break;
		case 12: 	case 13:	return TOD_12; break;
		case 14: 	case 15:	return TOD_14; break;
		case 16: 	case 17:	return TOD_16; break;
		case 18: 	case 19:	return TOD_18; break;
		case 20: 	case 21:	return TOD_20; break;
		case 22: 	case 23:	return TOD_22; break;
	
	}
	return 0;
}

// Returns TRUE if the trigger flags match current hour or if param not set
int CheckTODTag( int nToD ){

	if( nToD & _getTODTag() || 0 == nToD ) return TRUE;
	else return FALSE;

}


// :: ==================================================================================
// :: POSITIONS
// :: ==================================================================================



location GetFleeLocation( object oCreature, object oTarget, float fDist, float fOptionalAngle = 0.0 ) {
	float fAngle = GetAngleBetweenObjects( oTarget , oCreature ) + Random( 75 ) + fOptionalAngle;
	vector vRef = GetPosition( oCreature );
	vector vPosition =   VAtAngleToV( vRef, fDist, fAngle); 
	location locFlee = Location( GetArea( oCreature ), vPosition, fAngle );
	return locFlee;
}


/**
 * Used by GetFleeLocation
 **/ 
location _getFleeLocation( object oCreature, object oTarget, float fDist, float fOptionalAngle = 0.0 ) {

//	float fAngle 			= GetAngleBetweenObjects( oTarget , oCreature ) + fOptionalAngle;
	float fAngle 			= GetAngleBetweenObjects( oTarget , oCreature ) + Random( 45 ) + fOptionalAngle;
	//
	vector vRef 			= GetPosition( oCreature );
	//
	vector vPosition 		=   VAtAngleToV( vRef, fDist, fAngle); 
	//
	location lFlee 			= Location( GetArea( oCreature ), vPosition, fAngle );
	//
DebugLocation( lFlee, "blue" );
	return lFlee;
	
}

/**
 * Returns a valid location  
 * (caution: this is ported from Planner AI, name there is GetValidFleeLocation 
 *  with different parameters )
 */ 
location GetFleeLocation( object oCreature, object oTarget, float fDist, float fOptionalAngle = 0.0  ) {

	//
	int nSearchDepth;
	//
	float fDepthParam;
	//
	float fOptAngle = -30.0;
	//
	location lFlee 	;
	
	while( ! GetIsLocationValid( lFlee ) && nSearchDepth < S_MAX_LOC_SEARCH_DEPTH ) {

		nSearchDepth++;
		//
		fDepthParam 	-= 3.0;
		//
		fOptAngle 		+= 60.0;
		//
		lFlee = _getFleeLocation( oCreature, oTarget, fDist + fDepthParam, fOptAngle + fDepthParam );

	}
	
	return lFlee;
}





// :: ==================================================================================
// :: CR MANAGEMENT
// :: ==================================================================================


float _getCRModifierMembers( int nMembers ){

	float _fModifier;
	
	switch( nMembers ) 
	{
	    case 1:
            _fModifier = 0.5 ;
            break;
        case 2:
           _fModifier = 1.0;
            break;
        case 3:
           _fModifier = 1.5;
            break;
        case 4:
           _fModifier = 2.0;
            break;
        case 5:
            _fModifier = 2.25;
            break;
        case 6:
           _fModifier = 2.5;
            break;
        case 7:
           _fModifier = 2.75;
            break;
        default:
            _fModifier = 3.0;
	}
	return _fModifier;

}


float _getRelativeCR( float fBase, float fAdd ) {

	float fDiff = fBase - fAdd;
	float _fModifier = 0.0;

	// Low level CR get a special rule
	if( fBase <= 1.0 )	{
	
		_fModifier = fBase + fAdd ;
LocalDebug("::_getRelativeCR Low CR  : " + FloatToString( fBase ) + " / " + FloatToString( fBase ) + " > " + FloatToString( _fModifier ));
		return _fModifier;
 	}
	else if( fDiff <= 2.0 ) 
        _fModifier = 0.66;
	else if( fDiff <= 4.0 ) 
        _fModifier = 0.33;
	else if( fDiff <= 8.0 ) 
        _fModifier = 0.25;
	else  _fModifier = 0.00;
	return _fModifier;
}

float GetTargetCR( float fAverageLevel, int nMembers, float fDifficulty, float fLocalModifier){

LocalDebug("****** fAverageLevel  : " + FloatToString( fAverageLevel ));
LocalDebug("****** nMembers  : " +IntToString( nMembers ));
LocalDebug("****** nMembers modifier  : " + FloatToString( _getCRModifierMembers( nMembers ) ));
LocalDebug("****** fDifficulty  : " + FloatToString( fDifficulty ));
LocalDebug("****** fLocalModifier  : " + FloatToString( fLocalModifier ));

	return( ( fAverageLevel + _getCRModifierMembers( nMembers ) ) * fDifficulty * fLocalModifier );

}

float GetUpdatedReachedCR( float fReachedCR, float fCR ){
	

	float fBase, fAdd;
	
	if( 0.0 == fReachedCR ) return fCR;

	else if( fReachedCR >= fCR) {
		fBase = fReachedCR;
		fAdd = fCR;
		
	}else{
		fBase = fCR;
		fAdd = fReachedCR;
		fReachedCR = fCR;
	}



	return fReachedCR + _getRelativeCR( fBase, fAdd );

}



int RollSpawnProbability( float fTargetCR, float fPotentialCR, int nToSpawn, int nMembers ){

	if( Random(10)>3)
	return TRUE;
	else
	return FALSE;
}
							






// :: ==================================================================================
// :: CONTROLLER CREATING AND DELETING
// :: ==================================================================================

object InstantiateController( string sControllerTag, location lLoc ) {

	object oController = GetObjectByTag( sControllerTag );
	if( oController == OBJECT_INVALID ) {
		oController = CreateObject( OBJECT_TYPE_PLACEABLE, CONTROLLER_RESREF, lLoc, FALSE, sControllerTag );				
	}
	// We want to reset Team Morale to default
	SetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT, MORALE_BASE_AMOUNT);
LocalDebug("Activating controller with tag : " + sControllerTag, oController); 	

	return oController;


}







// :: ==================================================================================
// :: CONTROLLER UPDATING
// :: ==================================================================================

void UpdateTeamCurrentHP(string sControllerTag, int nDiffHP) {

	object oController = GetObjectByTag( sControllerTag );
	SetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT,  GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT ) + nDiffHP  );

LocalDebug("Team Current HP : " + IntToString( GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT ) ) + " on " + IntToString( GetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL ) ) );
}

void UpdateTeamMorale( string sControllerTag, int nMoraleModifier ){

	object oController = GetObjectByTag( sControllerTag );
	SetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT,  GetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT ) - nMoraleModifier  );

LocalDebug("Team Current Morale : " + IntToString( GetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT ) ) + " decreased by " + IntToString( nMoraleModifier) );

}






// :: ==================================================================================
// :: AI FUNCTIONS
// :: ==================================================================================

int GetCustomAILevel( object  oCreature ) {

	if( GetAbilityScore( oCreature, ABILITY_INTELLIGENCE ) >= 15 ) return AI_CUSTOM_HIGH;
	else if( GetAbilityScore( oCreature, ABILITY_INTELLIGENCE ) >= 9 )    return AI_CUSTOM_NORMAL;
	else return AI_CUSTOM_LOW;
	
}

int GetIsValidTarget( object oTarget ) {

	int nHP = GetCurrentHitPoints( oTarget );

	if( !GetIsObjectValid( oTarget ) || GetIsDead( oTarget )){
			LocalDebug(":: GetIsValidTarget : Invalid Target " );
		return FALSE;
	}
	if ( nHP < 1 ) {
			LocalDebug(":: GetIsValidTarget : Target HP ( " + IntToString( nHP ) + " ) < 1 " );
		return FALSE;
	}
	 else { 
			LocalDebug(":: GetIsValidTarget : Valid Target = " + GetResRef( oTarget ) );
	 return TRUE; }

}



int GetTarget( object oCreature ) {
	object oTarget;
	int nNth = 1;
	int bSkip = FALSE;
	
	while( !GetIsValidTarget( oTarget) && !bSkip ){
	
		 oTarget = GetNearestCreature( CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, nNth );
 		 LocalDebug(":: GetTarget : Looking for creature " + IntToString( nNth ) + " = " + GetTag( oTarget ), oCreature );
		 // 
		 if( !GetIsObjectValid( oTarget ) ){
		 	bSkip = TRUE;
			LocalDebug(":: GetTarget : Not a valid object ", oCreature );
		 }
		 if( GetDistanceBetween( oCreature, oTarget) > DISTANCE_PERCEPTION_DEFAULT ) {
		 	oTarget = OBJECT_INVALID;
			LocalDebug(":: GetTarget : too far for perception", oCreature );
		}
		 nNth++;
	}
	
	// Presumably, we don't see a new target
	if( bSkip ){
			LocalDebug(":: GetTarget : I couldn't find a target", oCreature );
		SetLocalObject( oCreature, CREATURE_TARGET, OBJECT_INVALID );
		return FALSE;
	} 
	else {	
		SetLocalObject( oCreature, CREATURE_TARGET, oTarget );
			LocalDebug(":: GetTarget : I found a target : " + GetTag (GetLocalObject( oCreature, CREATURE_TARGET) ), oCreature );
		return TRUE;
	}
	

}


void SuppressTeamTarget( int nHierarchicFlag, int nHasBoss ) {


}



int GetHasNotUnderstoodOrders( int nCreatureAILevel, int nFlags ) {

	if( ( nFlags & AI_FLAG_BOSS || nFlags & AI_FLAG_RIGHTHAND) )
		return FALSE;

	int nD20Roll = d20();
	if( nD20Roll > ( nCreatureAILevel + 5 ) ) return TRUE;
	else return FALSE;


} 










// :: ==================================================================================
// :: FLEEING AND ACTIONS
// :: ==================================================================================

int ActionFlee( object oCreature, object oTarget = OBJECT_INVALID ) {


//	AssignCommand( oCreature, ClearAllActions( ) );
	SetLocalInt( oCreature, CREATURE_STATE, ACTION_CREATURE_RETREAT );

	// We're safe if no one around
	int nInSafeLocation = FALSE;
	if( !GetIsValidTarget ( oTarget ) ) {
		int nHasTarget = GetTarget( oCreature );
			if( !nHasTarget ) nInSafeLocation = TRUE;
			else oTarget = GetLocalObject ( oCreature, CREATURE_TARGET );

	}
	
	
	// Aren't we safe ? 
	if( !nInSafeLocation ) {
	
		LocalDebug( "I'm fleeing from " + GetName( oTarget ), oCreature );
	
		// Get eventual Flee waypoint
		string szFleePoint = GetLocalString( oCreature, CREATURE_FLEE_WAYPOINT);
		object oFleePoint = GetNearestObjectByTag( szFleePoint );
		if( GetIsObjectValid( oFleePoint ) && szFleePoint != "" ) {
		
			// Are we despawning
			if( GetDistanceBetween( oFleePoint, oCreature ) < 3.0 ) 
			{
				DestroyTeamCreature( oCreature );
				LocalDebug( "I'm getting destroyed ", oCreature );
				return TRUE;
			} else {
				AssignCommand( oCreature, ActionForceMoveToObject( oFleePoint, TRUE ) );
				LocalDebug( "I'm fleeing to Team Flee Point ", oCreature );
				return TRUE;
			}
		// Nowhere to run specifically
		} else {
		
			// Simple move away if our position changed
			if( GetDistanceBetweenLocations( 
					GetLocalLocation( oCreature, CREATURE_LAST_LOCATION ),
					GetLocation( oCreature) 
				) > DISTANCE_SAFE_LOCATION_LOW )
			{
					AssignCommand( oCreature, ActionMoveAwayFromObject( oTarget, TRUE, DISTANCE_FLEE_RETREAT ) );
					SetLocalLocation( oCreature, CREATURE_LAST_LOCATION, GetLocation( oCreature)  );
					return TRUE;
				
			// Condition : we're stuck, so let's find some place to go				
			} else {
			
				// Looking for a flee location in front of target
				location locFlee = GetFleeLocation( oCreature, oTarget, DISTANCE_FLEE_RETREAT );
				LocalDebug( "Fleeing randomly step 1 ", oCreature );
					// No safe location ? Then look right of player !
					if( !GetIsLocationValid( locFlee ) ) {
				locFlee = GetFleeLocation( oCreature, oTarget, DISTANCE_FLEE_RETREAT, -90.0 );
				LocalDebug( "Fleeing randomly step 3 ", oCreature );
						// Again not ? Look left !
						if( !GetIsLocationValid( locFlee ) ) {
						locFlee = GetFleeLocation( oCreature, oTarget, DISTANCE_FLEE_RETREAT, 90.0 );
				LocalDebug( "Fleeing randomly step 4 ", oCreature );
							// Still not ? 
							if( !GetIsLocationValid( locFlee ) ) {
								locFlee = GetFleeLocation( oCreature, oTarget, DISTANCE_FLEE_RETREAT, 180.0 ); 
								LocalDebug( "Fleeing randomly step 5 ", oCreature );
							}
								// OK. Go to hell.
								if( !GetIsLocationValid( locFlee ) ) 
								DestroyTeamCreature( oCreature );
							
						}
					}
				object oWaypoint = CreateObject( OBJECT_TYPE_WAYPOINT, "nw_waypoint001", locFlee, FALSE );
				AssignCommand( oCreature, ActionForceMoveToObject( oWaypoint, TRUE ) );
				DestroyObject( oWaypoint, 6.5);
				LocalDebugPosition( locFlee );
			}		
		} 		
	
	// We're safe, maybe we could try to heal ?
	} else {
		if( TalentHealingSelf( TRUE ) || TalentHeal( TRUE ) )
			return FALSE;
	}
	return TRUE;
}



void ActionCustomAttack( object oCreature, object oTarget ) {

		AssignCommand( oCreature, ClearAllActions( ) );
		AssignCommand( oCreature, ActionEquipMostDamagingMelee ( oTarget ) );
		AssignCommand( oCreature, ActionForceMoveToObject( oTarget, TRUE ) );
		AssignCommand( oCreature, ActionAttack( oTarget ) );		
		 
}

int RetreatFromMelee( object oCreature,  float fDistance =  DISTANCE_DEFAULT_RETREAT ){

	object oClosestEnemy = GetNearestCreature( CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1 );
	if( GetDistanceBetween( oCreature, oClosestEnemy) < fDistance ) {

	
	// This could be enhanced with LineOfSight checks
		AssignCommand( oCreature, ActionEquipMostDamagingMelee( oClosestEnemy ) );
		AssignCommand( oCreature, ActionMoveAwayFromObject( oClosestEnemy, TRUE, fDistance ) );
		AssignCommand( oCreature, ActionEquipMostDamagingRanged( oClosestEnemy ) );
		AssignCommand( oCreature, ActionAttack( oClosestEnemy, TRUE ) );
		
			LocalDebug( " I retreat, enemy too close !", oCreature);		
		return TRUE;		
	} else return FALSE; 	

}








// :: ==================================================================================
// :: MORALE MANAGEMENT
// :: ==================================================================================

int  GetMoraleModifierOnCreatureDeath ( int CreatureHierarchicFlag ){
	
	if ( CreatureHierarchicFlag & AI_FLAG_BOSS ) return MORALE_MALUS_PER_DEAD_BOSS;
	else if ( CreatureHierarchicFlag & AI_FLAG_RIGHTHAND ) return MORALE_MALUS_PER_DEAD_RIGHTHAND;
	else return MORALE_MALUS_PER_DEAD_MEMBER;
}
int GetCreatureMoraleRollResult( float fFearFactor, int nMoraleCurrent, int nPercentHPRemainingTeam, int nPercentHPRemainingCreature, float fRetreatMultiplierMalus ) {

	int nD20Roll = d20();
	int nHPFactor = 0;
	
	if( nPercentHPRemainingTeam >= 80) nHPFactor += MORALE_MALUS_100_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingTeam >= 60 ) nHPFactor += MORALE_MALUS_80_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingTeam >= 40 ) nHPFactor += MORALE_MALUS_60_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingTeam >= 20 ) nHPFactor += MORALE_MALUS_40_PERCENT_HP_LEFT;
	else nHPFactor += MORALE_MALUS_20_PERCENT_HP_LEFT;
	
	if( nPercentHPRemainingCreature >= 80) nHPFactor += MORALE_MALUS_100_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingCreature >= 60 ) nHPFactor += MORALE_MALUS_80_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingCreature >= 40 ) nHPFactor += MORALE_MALUS_60_PERCENT_HP_LEFT;
	else if ( nPercentHPRemainingCreature >= 20 ) nHPFactor += MORALE_MALUS_40_PERCENT_HP_LEFT;
	else nHPFactor += MORALE_MALUS_20_PERCENT_HP_LEFT;

//LocalDebug( "nPercentHPRemainingTeam " + IntToString( nPercentHPRemainingTeam ) + " + nPercentHPRemainingCreature " +  IntToString( nPercentHPRemainingCreature )  );
//LocalDebug( "Hit Points Factor " + IntToString( nHPFactor ) + " + fFearFactor " +  FloatToString( fFearFactor ) + " + fRetreatMultiplierMalus " +  FloatToString( fRetreatMultiplierMalus ) + " + Team Morale " +  IntToString( nMoraleCurrent ) );

	
	int nDifficulty = FloatToInt ( ( nMoraleCurrent - ( fFearFactor * nHPFactor ) ) * fRetreatMultiplierMalus );

LocalDebug( "------ Morale : Rolled " + IntToString( nD20Roll ) + " against " +  IntToString( nDifficulty ) );
	
	if ( nD20Roll <= nDifficulty ) return TRUE;
	else return FALSE;

}



int DestroyTeamCreature( object oCreature ){

LocalDebug("####### I'm getting destroyed after fleeing " + IntToString( GetLocalInt( oCreature, CREATURE_FLEE_COUNT ) ) + " rounds" , oCreature );

	// We want to get the creature team array
	string sTeam = GetLocalString ( oCreature, CREATURE_TEAM);
	
	// We want to get the morale modifier related to hierarchic flag
	int nFlags = GetLocalInt( oCreature, CREATURE_FLAGS);
	int nCreatureHierarchicFlag = GetCreatureHierarchicFlag( nFlags );
	int nMoraleModifier = GetMoraleModifierOnCreatureDeath ( nCreatureHierarchicFlag );	
	
	// We want to update TeamMorale 
	UpdateTeamMorale( sTeam, nMoraleModifier );
	AssignCommand( oCreature, SetIsDestroyable( TRUE, TRUE, TRUE ) );
	DestroyObject( oCreature, 0.3f );

	return TRUE;
}
		




// :: ==================================================================================
// :: XP MANAGEMENT
// :: ==================================================================================


int GetCreatureXPReward( string sCR, int  nPartyAverageLevel ) 
{
	float fCR = StringToFloat( sCR );
	
	if( fCR < 1.0 ) {
		sCR = "1";
		LocalDebug("Challenge Rating inferior to 1 ");

	}
	string szXP = Get2DAString( "xptable", "C"+sCR, nPartyAverageLevel ) ;

LocalDebug("GetCreatureXPReward " + sCR + " / " + IntToString( nPartyAverageLevel )+ " = " + szXP );
	return StringToInt( szXP );
}



void GiveXPForFlee( object oAttacker, object oAttacked ){

	// We want to define the remaining amount of XP 
	float fFleeXP = GetLocalInt( oAttacked, CREATURE_XP_TOTAL ) *  XP_FOR_FLEE_MODIFIER;
	SetLocalInt( oAttacked, CREATURE_XP_REWARDED, FloatToInt( fFleeXP ) );
	
LocalDebug("GiveXPForFlee " + FloatToString( fFleeXP ) );
	// XP distribution
	xp_AwardPartyMembers( oAttacker, FloatToInt( fFleeXP ), DISTANCE_PARTY_SCAN  );
//	GiveXPToCreature( oAttacker,  FloatToInt( fFleeXP ) );

}

void GiveXPForDeath( object oKiller, object oKilled = OBJECT_SELF ){

	// We want to define the remaining amount of XP 
	int nRemainingXP = GetLocalInt( oKilled, CREATURE_XP_TOTAL ) - GetLocalInt( oKilled, CREATURE_XP_REWARDED );
	SetLocalInt( oKilled, CREATURE_XP_REWARDED, GetLocalInt( oKilled, CREATURE_XP_TOTAL ) );
	
LocalDebug("GiveXPForDeath " + IntToString( nRemainingXP ) );
	// XP distribution
	xp_AwardPartyMembers( oKiller, nRemainingXP, DISTANCE_PARTY_SCAN  );
	
}




// :: =================================================================================
// :: LEVEL MANAGEMENT
// :: =================================================================================



int GetIsEncounterSpawnable( int nPartyAverageLevel, int nLevelMin, int nLevelMax ) {

	if(	 nPartyAverageLevel >= nLevelMin && nPartyAverageLevel <= nLevelMax ) return TRUE;
	else return FALSE;

}










// :: =================================================================================
// :: FLAGS MANAGEMENT
// :: =================================================================================


int  GetCreatureHierarchicFlag (  int nFlags ) {
	
	if ( nFlags & AI_FLAG_BOSS ) return AI_FLAG_BOSS;
	else if ( nFlags & AI_FLAG_RIGHTHAND ) return AI_FLAG_RIGHTHAND;
	else return 0;
	
}

int GetCreatureHasFunction( int nFlags ) {

    if( nFlags & AI_FLAG_CASTER || nFlags & AI_FLAG_HEALER || nFlags & AI_FLAG_BUFFER || nFlags & AI_FLAG_ARCHER )
		return TRUE;
	else return FALSE;
}

int GetCreatureHasBuffing( int nFlags ) {

    if( nFlags & AI_FLAG_CASTER || nFlags & AI_FLAG_HEALER || nFlags & AI_FLAG_BUFFER )
		return TRUE;
	else return FALSE;
}





void CustomSummonAllies ( object oCreature, int nLevel = 9, int bInstantSpell = TRUE ) {

	LocalDebug ( "I'm going to check I have no summoned", oCreature );
	
	// Check if we have a summoned already around to skip eventually
	object oSummoned = GetAssociate ( ASSOCIATE_TYPE_SUMMONED ) ;
	if ( GetIsObjectValid( oSummoned ) && !GetIsDead( oSummoned ) ) return;
	
	LocalDebug ( "I'm about to summon an ally if any", oCreature );
	
	if(GetHasSpell( SPELL_SUMMON_CREATURE_IX ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_IX,oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}
	  
	if(GetHasSpell( SPELL_SUMMON_CREATURE_VIII ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_VIII,oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_VII ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_VII, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_VI ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_VI, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_V ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_V, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_IV ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_IV, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_III ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_III, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_II ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_II, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}

	if(GetHasSpell( SPELL_SUMMON_CREATURE_I ) ){ 
	  ActionCastSpellAtObject(SPELL_SUMMON_CREATURE_I, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, bInstantSpell);return;}
	  	
	  
}



void SetSpawnFlags( object oCreature, int nCondition,  int nFlags, string sGlobalSpawnVar = sSpawnCondVarname ){

 
	//  We want all creatures to have ambient animations and search
	//SetActionMode(oCreature, ACTION_MODE_DETECT, TRUE);
	SummonFamiliar( oCreature );
	SummonAnimalCompanion( oCreature );
	
	// We want casters, buffers and healers to be ready for battle
    if( nFlags & AI_FLAG_CASTER || nFlags & AI_FLAG_HEALER || nFlags & AI_FLAG_BUFFER) {
	}
								
	// We want creatures with tags to use their talents via integrated AI system
    if( nFlags & AI_FLAG_CASTER) {
LocalDebug( "I am a caster", oCreature);							
		}
    if( nFlags & AI_FLAG_HEALER) {
LocalDebug( "I am a healer", oCreature);											
		}								
    if( nFlags & AI_FLAG_BUFFER) {
LocalDebug( "I am a buffer", oCreature );								
		
		}										
    if( nFlags & AI_FLAG_ARCHER) {
LocalDebug( "I am an archer", oCreature );								
//		AssignCommand( oCreature, ActionEquipMostDamagingRanged() );
	}
	
	// We want stealth creatures to get stealthy
    if( nFlags & AI_FLAG_STEALTH ) {
		SetLocalInt(oCreature, sGlobalSpawnVar, nCondition +=  AI_FLAG_STEALTH);
		SetActionMode(oCreature, ACTION_MODE_STEALTH, TRUE);
		LocalDebug( "I am stealthy", oCreature );

	}
}








// :: =================================================================================
// :: ACTION ROUND MANAGEMENT
// :: =================================================================================

// These are used with AssignCommand, since talent would not be easily used otherwise


// :: Archers

void DetermineArcherCombatRound( object oCreature, object oTarget ) {

	AssignCommand( oCreature, ClearAllActions() );
	
	// If a close enemy, retreat
	if ( RetreatFromMelee( oCreature, DISTANCE_ARCHER_RETREAT ) ) return;

	// What if my target is too far ?
	string sPreferedDistance = Get2DAString( "baseitems", "PrefAttackDist", GetBaseItemType( GetItemInSlot ( INVENTORY_SLOT_RIGHTHAND ) ) );
		LocalDebug( "My weapon range is :  " + sPreferedDistance, oCreature);
	if( GetDistanceBetween( oCreature, oTarget ) > 	StringToFloat( sPreferedDistance ) ) {
		LocalDebug( "I'm too far ! Moving closer. ", oCreature);
		float fAngle = EnclosedAngle( GetPosition( oCreature ), GetPosition( oTarget ) );
		location locArcher = LocAtAngleToLoc( GetLocation( oTarget ), 	StringToFloat( sPreferedDistance ), fAngle );
		if( !GetIsLocationValid( locArcher) ) 
			locArcher = CalcSafeLocation( oCreature, locArcher, DISTANCE_SAFE_LOCATION_MED,FALSE ,FALSE  ) ; 
		AssignCommand( oCreature, ActionForceMoveToLocation( locArcher, TRUE ) );
		LocalDebugPosition( locArcher );
//		AssignCommand( oCreature, ActionForceMoveToLocation( locArcher, TRUE, StringToFloat( sPreferedDistance ) ) );
//		AssignCommand( oCreature, ActionForceMoveToObject( oTarget, TRUE, StringToFloat( sPreferedDistance ) ) );
	}
	
	
	// I'm attacking with my best ranged weapon
	AssignCommand( oCreature, ActionEquipMostDamagingRanged ( oTarget ) );
	AssignCommand( oCreature, ActionAttack( oTarget, 1) );
		LocalDebug( " I attack as archer !", oCreature);

}


// :: Buffers

void DetermineBufferCombatRound( object oCreature, object oTarget ) {

	LocalDebug( "I will try to run a buffer talent. ", oCreature);
		AssignCommand( oCreature, ClearAllActions() );
	
		CustomSummonAllies(  oCreature);
	
		if( Random(100) > 80 )
			if ( RetreatFromMelee( oCreature, DISTANCE_ARCHER_RETREAT ) ) return;
  	
		if( TalentEnhanceOthers() ) { 		LocalDebug(" TalentEnhanceOthers ",  oCreature); return; }
		if( TalentBardSong() ) { 		LocalDebug(" TalentBardSong ",  oCreature); return; }
		if( TalentCureCondition() ) { 		LocalDebug(" TalentCureCondition ",  oCreature); return; }
		if( TalentHeal() ) { 		LocalDebug(" TalentHeal ",  oCreature); return; }
/*
*/
	if( TalentUseProtectionOthers() ) { 		LocalDebug(" TalentUseProtectionOthers 1",  oCreature); return; }
	if( TalentEnhanceOthers() ) { 		LocalDebug(" TalentEnhanceOthers ",  oCreature); return; }
	if( TalentDebuff( oTarget ) ) { 		LocalDebug(" TalentDebuff ",  oCreature); return; }
	if( TalentBuffSelf(  ) ) { 		LocalDebug(" TalentDebuff ",  oCreature); return; }
	ActionEquipMostDamagingRanged ( oTarget );
	ActionCustomAttack ( oCreature, oTarget );
	LocalDebug( "Couldn't find a valid talent, attacking. ", oCreature);

}
// :: Casters


void DetermineCasterCombatRound( object oCreature, object oTarget ) {

	//AssignCommand( oCreature, ClearAllActions() );
	LocalDebug( "I will try to run a caster talent. ", oCreature);
 
		CustomSummonAllies( oCreature );
		
		if(Random(100) > 75)
			if ( RetreatFromMelee( oCreature, DISTANCE_ARCHER_RETREAT ) ) return;
		
		if( TalentHealingSelf() ) {					LocalDebug(" TalentHealingSelf ", oCreature); return; }
		if( TalentSummonAllies() ) { 		LocalDebug(" TalentSummonAllies ", oCreature); return; }
		if( TalentSpellAttack( oTarget ) ) {					LocalDebug(" TalentSpellAttack 1", oCreature); return; }
//		if( TalentSeeInvisible() ) { 		LocalDebug(" TalentSeeInvisible ", oCreature); return; }
		if( TalentOthers(100, oTarget) ) { 		LocalDebug(" TalentOthers ",  oCreature); return; }
		if( TalentUseProtectionOthers() ) { 		LocalDebug(" TalentUseProtectionOthers ",  oCreature); return; }
		if( TalentEnhanceOthers() ) { 		LocalDebug(" TalentEnhanceOthers ",  oCreature); return; }
	 	
	ActionEquipMostDamagingRanged ( oTarget );
	ActionCustomAttack ( oCreature, oTarget );
	LocalDebug( "Couldn't find a valid talent, attacking. ", oCreature);

}


// :: Healers


void DetermineHealerCombatRound( object oCreature, object oTarget ) {

	LocalDebug( "I will try to run a talent. ", oCreature);
	// We don't want to be blocked
		// THIS MIGHT REQUIRE TO CHECK A SIGNAL FROM A CUSTOM ON BLOCKED

	//AssignCommand( oCreature, ClearAllActions() );
	
		if(Random(101) > 75)
			if ( RetreatFromMelee( oCreature, DISTANCE_ARCHER_RETREAT ) ) return;
	
		CustomSummonAllies( oCreature );

		if( TalentHealingSelf() ) {					LocalDebug(" TalentHealingSelf ", oCreature); return; }
		if( TalentResurrect() ) {					LocalDebug(" TalentResurrect ", oCreature); return; }
		if( TalentHeal() ) {					LocalDebug(" TalentHeal 1 ", oCreature); return; }
		if( TalentUseTurning() ) {					LocalDebug(" TalentUseTurning ", oCreature); return; }
		if( TalentOthers(100, oTarget) ) { 		LocalDebug(" TalentOthers ",  oCreature); return; }
		if( TalentUseProtectionOthers() ) { 		LocalDebug(" TalentUseProtectionOthers ",  oCreature); return; }
		if( TalentEnhanceOthers() ) { 		LocalDebug(" TalentEnhanceOthers ",  oCreature); return; }

	
	ActionEquipMostDamagingRanged ( oTarget );
	ActionCustomAttack ( oCreature, oTarget );
	LocalDebug( "Couldn't find a valid talent, attacking. ", oCreature);

}


void UseFunctionInCombat( object oCreature, object oTarget, int nFlags) {

		
   if( nFlags & AI_FLAG_ARCHER) {
		LocalDebug( " DetermineArcherCombatRound. ", oCreature);   
		AssignCommand( oCreature, DetermineArcherCombatRound( oCreature, oTarget ) );

		
   }
   else if( nFlags & AI_FLAG_BUFFER) {
		LocalDebug( " DetermineBufferCombatRound. ", oCreature);   
		AssignCommand( oCreature, DetermineBufferCombatRound( oCreature, oTarget ) );

		
   }
   else if( nFlags & AI_FLAG_CASTER) {
		LocalDebug( " DetermineCasterCombatRound. ", oCreature);   
		AssignCommand( oCreature, DetermineCasterCombatRound( oCreature, oTarget ) );

		
   }
   else if( nFlags & AI_FLAG_HEALER) {
		LocalDebug( " DetermineHealerCombatRound. ", oCreature);   
		AssignCommand( oCreature, DetermineHealerCombatRound( oCreature, oTarget ) );

		
   }
	else
	{
	
		AssignCommand( oCreature, ActionCustomAttack( oCreature, oTarget ) );
	
	}
		



}

void UseFunctionBuff( object oCreature ) {
							
//	if ( TalentAdvancedBuff(40.0, TRUE) ) return;
//		if( TalentAdvancedProtectSelf() ) return;
	int nCountAction = 0;	

	//://///////////////////////////////////////////////////////////////////////////////
	//:***NWN2 Autobuff by D. Campbell***
	//:***1/27/07***
	//:-some spells that i dont like or feel are erroneous are not listed
	//:-some spells have a very short duration (such as divine favor), but can still
	//: prove to be effective in the autobuff list under certain circumstances 
	//:-metamagic feats such as Extend Spell and in some cases Persistent Spell justify  
	//: placing very low duration spells on the buff list
	//:-uncomment out any spells that do not suit your creature/PC buffing preferences	
	//://///////////////////////////////////////////////////
	//:***THIS SECTION IS RESERVED FOR CLASS-BASED SPELLS***
	//://///////////////////////////////////////////////////
	//Aid
	if(GetHasSpell(SPELL_AID)&& !GetHasSpellEffect(SPELL_AID))
	  {
	  ActionCastSpellAtObject(SPELL_AID, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Aura of Glory
	if(GetHasSpell(SPELL_AURAOFGLORY)&& !GetHasSpellEffect(SPELL_AURAOFGLORY))
	  {
	  ActionCastSpellAtObject(SPELL_AURAOFGLORY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Aura of Vitality
	if(GetHasSpell(SPELL_AURA_OF_VITALITY)&& !GetHasSpellEffect(SPELL_AURA_OF_VITALITY))
	  {
	  ActionCastSpellAtObject(SPELL_AURA_OF_VITALITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Barkskin
	if(GetHasSpell(SPELL_BARKSKIN)&& !GetHasSpellEffect(SPELL_BARKSKIN))
	  {
	  ActionCastSpellAtObject(SPELL_BARKSKIN, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Battletide
	if(GetHasSpell(SPELL_BATTLETIDE)&& !GetHasSpellEffect(SPELL_BATTLETIDE))
	  {
	  ActionCastSpellAtObject(SPELL_BATTLETIDE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Bear's Endurance
	if(GetHasSpell(SPELL_BEARS_ENDURANCE)&& !GetHasSpellEffect(SPELL_BEARS_ENDURANCE))
	  {
	  ActionCastSpellAtObject(SPELL_BEARS_ENDURANCE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Bless
	if(GetHasSpell(SPELL_BLESS)&& !GetHasSpellEffect(SPELL_BLESS))
	  {
	  ActionCastSpellAtObject(SPELL_BLESS, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Bull's Strength
	if(GetHasSpell(SPELL_BULLS_STRENGTH)&& !GetHasSpellEffect(SPELL_BULLS_STRENGTH))
	  {
	  ActionCastSpellAtObject(SPELL_BULLS_STRENGTH, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Camoflage
	if(GetHasSpell(SPELL_MASS_CAMOFLAGE)&& !GetHasSpellEffect(SPELL_MASS_CAMOFLAGE))
	  {
	  ActionCastSpellAtObject(SPELL_MASS_CAMOFLAGE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_CAMOFLAGE)&& !GetHasSpellEffect(SPELL_CAMOFLAGE))
	  {
	  ActionCastSpellAtObject(SPELL_CAMOFLAGE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Cat's Grace
	if(GetHasSpell(SPELL_CATS_GRACE)&& !GetHasSpellEffect(SPELL_CATS_GRACE))
	  {
	  ActionCastSpellAtObject(SPELL_CATS_GRACE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Damage Reduction
	if(GetHasSpell(SPELL_PREMONITION) && !GetHasSpellEffect(SPELL_PREMONITION))
	  {
	  ActionCastSpellAtObject(SPELL_PREMONITION, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_GREATER_STONESKIN)&& !GetHasSpellEffect(SPELL_GREATER_STONESKIN))
	  {
	  ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, oCreature, METAMAGIC_ANY, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_STONESKIN)&& !GetHasSpellEffect(SPELL_STONESKIN))
	  {
	  ActionCastSpellAtObject(SPELL_STONESKIN, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_PROTECTION_FROM_ARROWS)&& !GetHasSpellEffect(SPELL_PROTECTION_FROM_ARROWS))
	  {
	  ActionCastSpellAtObject(SPELL_PROTECTION_FROM_ARROWS, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Death Armor
	if (GetHasSpell(SPELL_DEATH_ARMOR)&& !GetHasSpellEffect(SPELL_DEATH_ARMOR))
	  {
	  ActionCastSpellAtObject(SPELL_DEATH_ARMOR, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Death Ward
	if(GetHasSpell(SPELL_DEATH_WARD)&& !GetHasSpellEffect(SPELL_DEATH_WARD))
	  {
	  ActionCastSpellAtObject(SPELL_DEATH_WARD, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Detect Invisible
	if(GetHasSpell(SPELL_TRUE_SEEING)&& !GetHasSpellEffect(SPELL_TRUE_SEEING))
	  {
	  ActionCastSpellAtObject(SPELL_TRUE_SEEING, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_BLINDSIGHT)&& !GetHasSpellEffect(SPELL_BLINDSIGHT))
	  {
	  ActionCastSpellAtObject(SPELL_BLINDSIGHT, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_SEE_INVISIBILITY)&& !GetHasSpellEffect(SPELL_SEE_INVISIBILITY))
	  {
	  ActionCastSpellAtObject(SPELL_SEE_INVISIBILITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Displacement
	if(GetHasSpell(SPELL_DISPLACEMENT)&& !GetHasSpellEffect(SPELL_DISPLACEMENT))
	  {
	  ActionCastSpellAtObject(SPELL_DISPLACEMENT, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Divine Favor
	if(GetHasSpell(SPELL_DIVINE_FAVOR)&& !GetHasSpellEffect(SPELL_DIVINE_FAVOR))
	  {
	  ActionCastSpellAtObject(SPELL_DIVINE_FAVOR, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Divine Power
	if(GetHasSpell(SPELL_DIVINE_POWER)&& !GetHasSpellEffect(SPELL_DIVINE_POWER))
	  {
	  ActionCastSpellAtObject(SPELL_DIVINE_POWER, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Elemental Resist
	if(GetHasSpell(SPELL_PROTECTION_FROM_ENERGY)&& !GetHasSpellEffect(SPELL_PROTECTION_FROM_ENERGY))
	  {
	  ActionCastSpellAtObject(SPELL_PROTECTION_FROM_ENERGY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_RESIST_ENERGY)&& !GetHasSpellEffect(SPELL_RESIST_ENERGY))
	  {
	  ActionCastSpellAtObject(SPELL_RESIST_ENERGY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_ENDURE_ELEMENTS)&& !GetHasSpellEffect(SPELL_ENDURE_ELEMENTS))
	  {
	  ActionCastSpellAtObject(SPELL_ENDURE_ELEMENTS, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Elemental Shield
	if(GetHasSpell(SPELL_ELEMENTAL_SHIELD)&& !GetHasSpellEffect(SPELL_ELEMENTAL_SHIELD))
	  {
	  ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Enlarge
	if(GetHasSpell(SPELL_RIGHTEOUS_MIGHT)&& !GetHasSpellEffect(SPELL_RIGHTEOUS_MIGHT))
	  {
	  ActionCastSpellAtObject(SPELL_RIGHTEOUS_MIGHT, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_ENLARGE_PERSON)&& !GetHasSpellEffect(SPELL_ENLARGE_PERSON))
	  {
	  ActionCastSpellAtObject(SPELL_ENLARGE_PERSON, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Entropic Shield
	if(GetHasSpell(SPELL_ENTROPIC_SHIELD)&& !GetHasSpellEffect(SPELL_ENTROPIC_SHIELD))
	  {
	  ActionCastSpellAtObject(SPELL_ENTROPIC_SHIELD, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//False Life
	if(GetHasSpell(SPELL_FALSE_LIFE)&& !GetHasSpellEffect(SPELL_FALSE_LIFE))
	  {
	  ActionCastSpellAtObject(SPELL_FALSE_LIFE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Freedom of Movement
	if(GetHasSpell(SPELL_FREEDOM_OF_MOVEMENT)&& !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT))
	  {
	  ActionCastSpellAtObject(SPELL_FREEDOM_OF_MOVEMENT, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Globe
	if(GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY))
	  {
	  ActionCastSpellAtObject(SPELL_GLOBE_OF_INVULNERABILITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_LESSER_GLOBE_OF_INVULNERABILITY)&& !GetHasSpellEffect(SPELL_LESSER_GLOBE_OF_INVULNERABILITY))
	  {
	  ActionCastSpellAtObject(SPELL_LESSER_GLOBE_OF_INVULNERABILITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Haste
	if(GetHasSpell(SPELL_HASTE)&& !GetHasSpellEffect(SPELL_HASTE))
	  {
	  ActionCastSpellAtObject(SPELL_HASTE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Heroism
	if(GetHasSpell(SPELL_GREATER_HEROISM)&& !GetHasSpellEffect(SPELL_GREATER_HEROISM))
	  {
	  ActionCastSpellAtObject(SPELL_GREATER_HEROISM, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_HEROISM)&& !GetHasSpellEffect(SPELL_HEROISM))
	  {
	  ActionCastSpellAtObject(SPELL_HEROISM, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Iron Body
	if(GetHasSpell(SPELL_IRON_BODY)&& !GetHasSpellEffect(SPELL_IRON_BODY))
	  {
	  ActionCastSpellAtObject(SPELL_IRON_BODY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_STONE_BODY)&& !GetHasSpellEffect(SPELL_STONE_BODY))
	  {
	  ActionCastSpellAtObject(SPELL_STONE_BODY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Low-Light Vision
	if(GetHasSpell(SPELL_LOW_LIGHT_VISION)&& !GetHasSpellEffect(SPELL_LOW_LIGHT_VISION))
	  {
	  ActionCastSpellAtObject(SPELL_LOW_LIGHT_VISION, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Mage Armor
	if(GetHasSpell(SPELL_IMPROVED_MAGE_ARMOR)&& !GetHasSpellEffect(SPELL_IMPROVED_MAGE_ARMOR))
	  {
	  ActionCastSpellAtObject(SPELL_IMPROVED_MAGE_ARMOR, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_MAGE_ARMOR)&& !GetHasSpellEffect(SPELL_MAGE_ARMOR))
	  {
	  ActionCastSpellAtObject(SPELL_MAGE_ARMOR, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Mind Blank
	if(GetHasSpell(SPELL_MIND_BLANK)&& !GetHasSpellEffect(SPELL_MIND_BLANK))
	  {
	  ActionCastSpellAtObject(SPELL_MIND_BLANK, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_LESSER_MIND_BLANK)&& !GetHasSpellEffect(SPELL_LESSER_MIND_BLANK))
	  {
	  ActionCastSpellAtObject(SPELL_LESSER_MIND_BLANK, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Mirror Image
	if(GetHasSpell(SPELL_MIRROR_IMAGE)&& !GetHasSpellEffect(SPELL_MIRROR_IMAGE))
	  {
	  ActionCastSpellAtObject(SPELL_MIRROR_IMAGE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Prayer
	if(GetHasSpell(SPELL_PRAYER)&& !GetHasSpellEffect(SPELL_PRAYER))
	  {
	  ActionCastSpellAtObject(SPELL_PRAYER, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Protection from Spells
	if(GetHasSpell(SPELL_PROTECTION_FROM_SPELLS)&& !GetHasSpellEffect(SPELL_PROTECTION_FROM_SPELLS))
	  {
	  ActionCastSpellAtObject(SPELL_PROTECTION_FROM_SPELLS, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Resistance
	if(GetHasSpell(SPELL_RESISTANCE)&& !GetHasSpellEffect(SPELL_RESISTANCE))
	  {
	  ActionCastSpellAtObject(SPELL_RESISTANCE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Shield
	if(GetHasSpell(SPELL_SHIELD)&& !GetHasSpellEffect(SPELL_SHIELD))
	  {
	  ActionCastSpellAtObject(SPELL_SHIELD, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Shield of Faith
	if(GetHasSpell(SPELL_SHIELD_OF_FAITH)&& !GetHasSpellEffect(SPELL_SHIELD_OF_FAITH))
	  {
	  ActionCastSpellAtObject(SPELL_SHIELD_OF_FAITH, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Spell Mantle
	if(GetHasSpell(SPELL_GREATER_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE))
	  {
	  ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_SPELL_MANTLE))
	  {
	  ActionCastSpellAtObject(SPELL_SPELL_MANTLE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_LESSER_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE))
	  {
	  ActionCastSpellAtObject(SPELL_LESSER_SPELL_MANTLE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_LEAST_SPELL_MANTLE)&& !GetHasSpellEffect(SPELL_LEAST_SPELL_MANTLE))
	  {
	  ActionCastSpellAtObject(SPELL_LEAST_SPELL_MANTLE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Spell Resistance
	if(GetHasSpell(SPELL_SPELL_RESISTANCE)&& !GetHasSpellEffect(SPELL_SPELL_RESISTANCE))
	  {
	  ActionCastSpellAtObject(SPELL_SPELL_RESISTANCE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Virtue
	if(GetHasSpell(SPELL_VIRTUE)&& !GetHasSpellEffect(SPELL_VIRTUE))
	  {
	  ActionCastSpellAtObject(SPELL_VIRTUE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Visage
	if(GetHasSpell(SPELL_SHADOW_SHIELD)&& !GetHasSpellEffect(SPELL_SHADOW_SHIELD))
	  {
	  ActionCastSpellAtObject(SPELL_SHADOW_SHIELD, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_ETHEREAL_VISAGE)&& !GetHasSpellEffect(SPELL_ETHEREAL_VISAGE))
	  {
	  ActionCastSpellAtObject(SPELL_ETHEREAL_VISAGE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_GHOSTLY_VISAGE)&& !GetHasSpellEffect(SPELL_GHOSTLY_VISAGE))
	  {
	  ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//War Cry
	if(GetHasSpell(SPELL_WAR_CRY)&& !GetHasSpellEffect(SPELL_WAR_CRY))
	  {
	  ActionCastSpellAtObject(SPELL_WAR_CRY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//***Invisibility (this should be last)***
	if(GetHasSpell(SPELL_GREATER_INVISIBILITY)&& !GetHasSpellEffect(SPELL_GREATER_INVISIBILITY))
	  {
	  ActionCastSpellAtObject(SPELL_GREATER_INVISIBILITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_INVISIBILITY_SPHERE)&& !GetHasSpellEffect(SPELL_INVISIBILITY_SPHERE))
	  {
	  ActionCastSpellAtObject(SPELL_INVISIBILITY_SPHERE, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	else if(GetHasSpell(SPELL_INVISIBILITY)&& !GetHasSpellEffect(SPELL_INVISIBILITY))
	  {
	  ActionCastSpellAtObject(SPELL_INVISIBILITY, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	  
	//://////////////////////////////////////////////////////
	//:***THIS SECTION IS RESERVED FOR WARLOCK INVOCATIONS***
	//:Make sure to use METAMAGIC_NONE
	//://////////////////////////////////////////////////////
	//Beguiling Influence
	if(GetHasSpell(SPELL_I_BEGUILING_INFLUENCE)&& !GetHasSpellEffect(SPELL_I_BEGUILING_INFLUENCE))
	  {
	  ActionCastSpellAtObject(SPELL_I_BEGUILING_INFLUENCE, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Dark Foresight
	if(GetHasSpell(SPELL_I_DARK_FORESIGHT)&& !GetHasSpellEffect(SPELL_I_DARK_FORESIGHT))
	  {
	  ActionCastSpellAtObject(SPELL_I_DARK_FORESIGHT, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Dark One's Own Luck
	if(GetHasSpell(SPELL_I_DARK_ONES_OWN_LUCK)&& !GetHasSpellEffect(SPELL_I_DARK_ONES_OWN_LUCK))
	  {
	  ActionCastSpellAtObject(SPELL_I_DARK_ONES_OWN_LUCK, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Devil's Sight
	if(GetHasSpell(SPELL_I_DEVILS_SIGHT)&& !GetHasSpellEffect(SPELL_I_DEVILS_SIGHT))
	  {
	  ActionCastSpellAtObject(SPELL_I_DEVILS_SIGHT, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Entropic Warding
	if(GetHasSpell(SPELL_I_ENTROPIC_WARDING)&& !GetHasSpellEffect(SPELL_I_ENTROPIC_WARDING))
	  {
	  ActionCastSpellAtObject(SPELL_I_ENTROPIC_WARDING, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Flee the Scene
	if(GetHasSpell(SPELL_I_FLEE_THE_SCENE)&& !GetHasSpellEffect(SPELL_I_FLEE_THE_SCENE))
	  {
	  ActionCastSpellAtObject(SPELL_I_FLEE_THE_SCENE, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Hideous Blow *no metamagic here
	//uncomment out if you want to manually cast with metamagic
	if(GetHasSpell(SPELL_I_HIDEOUS_BLOW)&& !GetHasSpellEffect(SPELL_I_HIDEOUS_BLOW))
	  {
	  ActionCastSpellAtObject(SPELL_I_HIDEOUS_BLOW, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Leaps and Bounds
	if(GetHasSpell(SPELL_I_LEAPS_AND_BOUNDS)&& !GetHasSpellEffect(SPELL_I_LEAPS_AND_BOUNDS))
	  {
	  ActionCastSpellAtObject(SPELL_I_LEAPS_AND_BOUNDS, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Retributive Invisibility
	if(GetHasSpell(SPELL_I_RETRIBUTIVE_INVISIBILITY)&& !GetHasSpellEffect(SPELL_I_RETRIBUTIVE_INVISIBILITY))
	  {
	  ActionCastSpellAtObject(SPELL_I_RETRIBUTIVE_INVISIBILITY, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//See the Unseen
	if(GetHasSpell(SPELL_I_SEE_THE_UNSEEN)&& !GetHasSpellEffect(SPELL_I_SEE_THE_UNSEEN))
	  {
	  ActionCastSpellAtObject(SPELL_I_SEE_THE_UNSEEN, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	
	//Walk Unseen
	if(GetHasSpell(SPELL_I_WALK_UNSEEN)&& !GetHasSpellEffect(SPELL_I_WALK_UNSEEN))
	  {
	  ActionCastSpellAtObject(SPELL_I_WALK_UNSEEN, oCreature, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}	  
	//://///////////////////////////////////////////////////
	//:***THIS SECTION IS RESERVED FOR CREATURE ABILITIES***
	//://///////////////////////////////////////////////////
	//Auras
	if(GetHasSpell(SPELLABILITY_AURA_FEAR)&& !GetHasSpellEffect(SPELLABILITY_AURA_FEAR))
	  {
	  ActionCastSpellAtObject(SPELLABILITY_AURA_FEAR, oCreature, METAMAGIC_ANY, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
	  nCountAction++;}		
	  
	  
	  CustomSummonAllies( oCreature );
	  
	  if( !nCountAction ){
	  LocalDebug( "Autobuff not working", oCreature);
	  
		if( TalentUseProtectionOthers() ) { 		LocalDebug(" TalentUseProtectionOthers ", oCreature); return; }
		if( TalentRangedAttackers() ) { 		LocalDebug(" TalentRangedAttackers ", oCreature); return; }
		if( TalentRangedEnemies() ) { 		LocalDebug(" TalentRangedEnemies ", oCreature); return; }
		if( TalentBardSong() ) { 		LocalDebug(" TalentBardSong ", oCreature); return; }
		if( TalentMeleeAttack() ) { 		LocalDebug(" TalentMeleeAttack ", oCreature); return; }
	  
	  LocalDebug( "I found no action", oCreature);
	  }
}