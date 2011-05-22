//:://////////////////////////////////////////////////
//:: e_plc_npccontroller_hb
//:://////////////////////////////////////////////////
/*
	Description: custom onHeartBeat for Khalidine NPC Controller System
   
*/
//:://////////////////////////////////////////////////
// 29/12/07 Creation by Alban : hostile creatures management
//:://////////////////////////////////////////////////
/*

 

*/
//:://////////////////////////////////////////////////


#include "inc_ai_hostile"


void main () {


	// We want to get / set a bunch of local variables from controller
	object oController = OBJECT_SELF;
	int nRound = GetLocalInt( oController, CONTROLLER_TEAM_ROUND_COUNT) + 1;
	float fFearFactor = GetLocalFloat( oController, CONTROLLER_TEAM_FEAR_FACTOR );
	int nHasBoss = GetLocalInt( oController, CONTROLLER_TEAM_HAS_BOSS );
	int nTeamHPCurrent = GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT );
	int nTeamHPTotal = GetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL );
	
	// Bug fix : nTeamHPTotal -must- not be null to be used as diviser
	if( 0 == nTeamHPTotal ) nTeamHPTotal = 1;
	int nPercentHPRemainingTeam = FloatToInt( 100.0 * IntToFloat(nTeamHPCurrent) / IntToFloat(nTeamHPTotal) ) ;
	
	int nMoraleCurrent = GetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT );
	int nTeamState = GetLocalInt( oController, CONTROLLER_TEAM_STATE );
	object oTeamTarget = GetLocalObject( oController, CONTROLLER_TEAM_TARGET_CURRENT );
	
	float fRetreatMultiplierMalus = 1.0;
	
	string sTeamArrayName = GetTag( oController );
	int	nTeamArrayCount = ArrayGetCount( sTeamArrayName );
	
LocalDebug("TEAM HP : " + IntToString( nTeamHPCurrent ) +" / " + IntToString( nTeamHPTotal ) +" => " + IntToString( nPercentHPRemainingTeam ) +"%"   );
LocalDebug("TEAM Morale : " + IntToString( nMoraleCurrent )    );

	int nCreatureFlags, nCreatureHierarchicFlag, nCreatureHPCurrent, nCreatureHPMax, nPercentHPRemainingCreature, nCreatureState, nCreatureNextState, nCustomCreatureAILevel;
	object oCreatureTarget, oTarget, oPerceived, oLastValidTarget;
	int bHasNoValidTarget, nCountNoTargets;   
 
LocalDebug("**************************************** ");
LocalDebug("****** Controller heartbeat on Round : " + IntToString( nRound ) + " ******");
LocalDebug("****** Array count : " + IntToString( nTeamArrayCount ) +"            ******");
LocalDebug("**************************************** ");


	// Let's destroy the array and controller if array is empty
	if( nTeamArrayCount == 0 ) {
	
		ArrayDelete( sTeamArrayName );
		DestroyObject( oController );
LocalDebug("****** Destroying array : " + sTeamArrayName );
		return;
		
	}
	
	// Let's change the team state if necessary
	// TODO nTeamState = ChangeTeamState( nTeamState );
	if( nTeamState == ACTION_TEAM_FIRST_SIGHT ) {
		
		// pass to combat 
//		nTeamState = ACTION_TEAM_COMBAT;
		SetLocalInt( oController, CONTROLLER_TEAM_STATE, ACTION_TEAM_COMBAT);
//LocalDebug("****** Team will go for fight on next round! ");
		
	}
		
	// :: GO TROUGH CREATURES IN TEAM ARRAY 
	// :: =====================================

	
	int nNthCreature;
	for( nNthCreature = --nTeamArrayCount; nNthCreature >= 0 ; nNthCreature--) {
	
		bHasNoValidTarget = 0;
		oTarget = oTeamTarget; // Our default target is team target

		object oCreature = ArrayGetObjectElement( sTeamArrayName, nNthCreature );
LocalDebug("------------------------------------------------------------------------ ");
LocalDebug("Controller parsing creature : " + GetResRef( oCreature )+" at index : "+IntToString(nNthCreature) , oCreature );
		//LocalDebug("HP : " + IntToString( nCreatureHPCurrent ) +" / " + IntToString( nCreatureHPMax ) +" => " + IntToString( nPercentHPRemainingCreature )+"%"   , oCreature );
			
		if ( !GetIsObjectValid( oCreature )  || GetIsDead(oCreature) ){
				 
			// :: DEAD ENCOUNTERS 
			// :: =================			
			// We're /SO/ dead we get removed from team array
			ArrayRemoveElement( sTeamArrayName, nNthCreature );
LocalDebug("****** Removing from array at index " +IntToString(nNthCreature)+", "+IntToString(nTeamArrayCount)+" Creature(s) left in array" );		
			continue;
			
		}else{
	
			// :: LIVING ENCOUNTERS 
			// :: ===================

			// Let's get local vars on creature
			nCreatureFlags = GetLocalInt ( oCreature, CREATURE_FLAGS );
			nCreatureHierarchicFlag = GetCreatureHierarchicFlag( nCreatureFlags );
			nCreatureHPCurrent = GetLocalInt( oCreature, CREATURE_HP_CURRENT);
			nCreatureHPMax = GetLocalInt( oCreature, CREATURE_HP_MAX);
			nPercentHPRemainingCreature = FloatToInt( 100.0 * IntToFloat(nCreatureHPCurrent) / IntToFloat(nCreatureHPMax) ) ;
			nCreatureState = GetLocalInt( oCreature, CREATURE_STATE );
			oCreatureTarget = GetLocalObject(  oCreature, CREATURE_TARGET );
			nCustomCreatureAILevel = GetLocalInt( oCreature, CREATURE_AI_LEVEL );
	
	
			AssignCommand( oCreature, ClearAllActions( TRUE ) );
			
			// :: ============================================================
			// :: MORALE CHECKS
			// :: ============================================================
			// If we have the coward flag raised, stop here
			// This is not coherent : the creature needs a personal target but receives so far team target
			
			// If we were retreating last round, we have more chances to flee again : 10% x FearFactor
			if( nCreatureState == ACTION_CREATURE_RETREAT ) 
				fRetreatMultiplierMalus = 1.0 - ( MORALE_MALUS_FOR_RETREATING * fFearFactor );

				
				
								
			// :: ============================================================
			// :: COWARD ENCOUNTERS 
			// :: ============================================================
			// Coward creatures get a complete different loop ( no xp for flee )
			if( nCreatureFlags & AI_FLAG_WILD ){
LocalDebug(">>>>> I'm a coward ! " , oCreature );
			
				int nFledRounds = GetLocalInt( oCreature, CREATURE_FLEE_COUNT );
	
				// Is there still a valid PC around ?
				object oNearestPC = GetNearestCreature( CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature );				
LocalDebug(">>>>> Nearest PC : " + GetName(oNearestPC)  , oCreature );
				
					// Are we about to disappear because we fled for too long ?
					if(	nFledRounds >= MAX_FLEE_ROUNDS && GetDistanceBetween( oCreature, oNearestPC ) > DISTANCE_DISAPPEAR_FLEEING )					{

						DestroyTeamCreature( oCreature );
							
					}
					// Fleeing for our life	
					else if ( GetDistanceBetween( oCreature, oNearestPC ) < DISTANCE_FLEE_RETREAT )
					{
						// The coward creatures have no "wake up" state, hence they need that
						if( GetActionMode( oCreature, ACTION_MODE_DETECT ) )
							SetActionMode( oCreature, ACTION_MODE_DETECT, FALSE );
							
						// If we're not really fleeing for the moment, it won't increment counter
						if( ActionFlee( oCreature, oCreatureTarget ) )
							SetLocalInt( oCreature, CREATURE_FLEE_COUNT, GetLocalInt( oCreature, CREATURE_FLEE_COUNT )+1 );
LocalDebug(">>>>> I'm running out of here after " + IntToString( GetLocalInt( oCreature, CREATURE_FLEE_COUNT ) ) + " rounds of fleeing" , oCreature );

						bHasNoValidTarget = !GetIsObjectValid( oNearestPC );
						
					}
					// Do nothing
					else {
					
						AssignCommand( oCreature, ActionRandomWalk() );
					
					}
					
			}
			// We want to check if creature succeeds Morale check
			else if( 
				GetCreatureMoraleRollResult ( fFearFactor, nMoraleCurrent, nPercentHPRemainingTeam, nPercentHPRemainingCreature, fRetreatMultiplierMalus ) 
				) {

				
				// :: CONFIDENT ENCOUNTERS 
				// :: =======================
				
				// We want to switch actions depending on the team state
				// :: ==================================================
				
				switch( nTeamState ) {
				
				
				
				// =============================================================
				// WANDERING
				// =============================================================
				
				
				
				case ACTION_TEAM_WANDER :
					LocalDebug("I'm wandering with my team."  , oCreature );
				


					// TODO : Maybe simulate more intelligent activities ?
					AssignCommand( oCreature, ActionRandomWalk() );
//					AssignCommand( oCreature, ActionMoveToObject( GetNearestObject( OBJECT_TYPE_ALL, oCreature, Random( nTeamArrayCount ) + 3 ), FALSE) );
					
					// If a scout, run long range sighting and don't move
					if( nCreatureFlags & AI_FLAG_SCOUT  ){
							LocalDebug("I'm a scout." , oCreature );
							
							// Todo : this might go into a function
							// eventually returning a spotted creature
							
							int nNthScouted = 1;
							int nSpotted = 1;
					
							object oScoutSighted = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, nNthScouted);
							while( GetIsObjectValid( oScoutSighted ) ) {
LocalDebug("Enemy spotted." , oCreature );
								
								// If we reached a PC out of distance, break
								if( GetDistanceBetween( oCreature, oScoutSighted ) > DISTANCE_SCOUT_RANGE ) {
LocalDebug("Enemy too far." , oCreature );
									nSpotted = 0;
									}
								// Does scout detect stealth creature
								if( GetActionMode( oScoutSighted, ACTION_MODE_STEALTH ) ){
LocalDebug("Enemy stealthy." , oCreature );
									
									if( GetIsSkillSuccessful( oCreature, SKILL_LISTEN, GetSkillRank( SKILL_MOVE_SILENTLY, oScoutSighted ) ) 
									&&  GetIsSkillSuccessful( oCreature, SKILL_SPOT, GetSkillRank( SKILL_HIDE, oScoutSighted   ) ) )
										oPerceived = oScoutSighted;	
										nSpotted = 0;
LocalDebug("Enemy not detected." , oCreature );
									
								} 
								// We got a target
								if( nSpotted )
								{
LocalDebug("Enemy detected." , oCreature );
									oPerceived = oScoutSighted;	
									oScoutSighted = OBJECT_INVALID;
								}
								
									
								nNthScouted++;
								oScoutSighted = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, nNthScouted);
									
							}	
									
					
					} else 				
						// We want to look if there's any enemy around and eventually activate team
						oPerceived = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oCreature, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
					
					// If enemy spotted, time to wake team up
					if( GetIsValidTarget( oPerceived ) ) {
						oTeamTarget = oPerceived;
						SetLocalObject( oController, CONTROLLER_TEAM_TARGET_CURRENT, oPerceived );


						event eEvent =  EventUserDefined(EVENT_HOSTILE_CREATURE_TEAM_WAKE);
						SignalEvent( oController, eEvent);
						nTeamState = ACTION_TEAM_FIRST_SIGHT; // This will avoid further actions while this round
		
							LocalDebug(">>>>> I've spotted an enemy ! " + GetName( oPerceived )  , oCreature );
					}
				break;
	
				
				
				
				
				
				
				// =============================================================
				// FIGHTING
				// =============================================================
				
				case ACTION_TEAM_COMBAT:
					LocalDebug(">>>>> I'm fighting with my team."  , oCreature );
				




					// :: ============================================================
					// ::  TARGETING
					// :: ============================================================
					
					// :: BOSS
					// If we're a boss or a right hand and the boss is gone, our target will become the group's target 
					if( nCreatureHierarchicFlag == AI_FLAG_BOSS || ( nCreatureHierarchicFlag == AI_FLAG_RIGHTHAND && nHasBoss == 0 ) ) {
		
						bHasNoValidTarget = !GetTarget( oCreature);
						oTeamTarget = GetLocalObject( oCreature, CREATURE_TARGET );
						SetLocalObject( oController, CONTROLLER_TEAM_TARGET_CURRENT, oTeamTarget );
							LocalDebug(">>>>> I chose a target as leader : " + GetName( GetLocalObject( oCreature, CREATURE_TARGET) ), oCreature );
											
					// :: STUPID CREATURE
					// If creature too stupid to pick team target, pick its own
					} else if ( GetHasNotUnderstoodOrders( nCustomCreatureAILevel, nCreatureHierarchicFlag ) ) {
							LocalDebug(">>>>> I didn't undestand orders ! ", oCreature );

						// Reattack last creature if valid, else select a new one and attack
						if(GetIsValidTarget( oCreatureTarget ) ) 	
							oTarget = oCreatureTarget;
						else {
						
							bHasNoValidTarget = !GetTarget( oCreature);
							oTarget = GetLocalObject( oCreature, CREATURE_TARGET);
							
						}	
							
					// :: INVALID TEAM TARGET
					// If Invalid team target, get another one
					}  else if ( !GetIsValidTarget( oTeamTarget ) ) { 

							LocalDebug(">>>>> Invalid Team Target when picking a target", oCreature );	
						bHasNoValidTarget = !GetTarget( oCreature);
						oTarget = GetLocalObject( oCreature, CREATURE_TARGET);
							LocalDebug(">>>>> I chose a target : " + GetName( oTarget ), oCreature );

					// :: DEFAULT TEAM TARGET
					}  else { 
						SetLocalObject( oCreature, CREATURE_TARGET, oTarget );
							LocalDebug(">>>>> I didn't choose a target when picking a target, heriting : " + GetName( oTeamTarget ), oCreature );					

					}
					
					// At this point if we don't have a valid target we need to get the last valid one
					if ( !GetIsValidTarget( oTarget ) ) {
						if ( GetIsValidTarget( oLastValidTarget ) ) {
						
							oTarget = oLastValidTarget;
							SetLocalObject( oCreature, CREATURE_TARGET, oTarget );
							LocalDebug(">>>>> Invalid Target when picking a target, acquiring oLastValidTarget : " + GetName( oLastValidTarget ), oCreature );					
						
						}else{
							// We have no valid target !!!
							bHasNoValidTarget = 1;
						}
						
					}else{
						oLastValidTarget = oTarget;
					}
					
					
					// :: ============================================================
					// :: ACTIONS
					// :: ============================================================
					
					if( bHasNoValidTarget ){
					
					
					
					}
					
					
					// We check if we have a special function
					else if ( GetCreatureHasFunction( nCreatureFlags ) ) {
							
						UseFunctionInCombat( oCreature, oTarget, nCreatureFlags );
							LocalDebug(">>>>> I execute my team function ! ", oCreature );
						
														
					// We want the creature to attack team target
					} else {
						
						AssignCommand( oCreature, ActionCustomAttack( oCreature, oTarget ) );
							LocalDebug(">>>>> I attack my target ! ", oCreature );
	
					}
				break;

				
				case ACTION_TEAM_RETREAT:
LocalDebug(">>>>> I'm retreating with my team."  , oCreature );
				break;
				
				}
			// We want the creature to flee
			} else {
			
				// :: ============================================================
				// :: FLEEING ENCOUNTERS 
				// :: ============================================================
			
				int nFledRounds = GetLocalInt( oCreature, CREATURE_FLEE_COUNT );
	
				// Is there still a valid PC around ?
				object oNearestPC = GetNearestPC( );				
				
					// Are we about to disappear because we fled for too long ?
					if(	nFledRounds >= MAX_FLEE_ROUNDS && GetDistanceBetween( oCreature, oNearestPC ) > DISTANCE_DISAPPEAR_FLEEING )
					{
						DestroyTeamCreature( oCreature );		
					}
					// Fleeing for our life	
					else
					{
						// If we were stealthy... 
						if( GetActionMode( oCreature, ACTION_MODE_STEALTH ) )
							SetActionMode( oCreature, ACTION_MODE_STEALTH, FALSE );

							
						bHasNoValidTarget = !GetIsObjectValid( oNearestPC );
						
						// If we're not really fleeing for the moment, it won't increment counter
						if( ActionFlee( oCreature, oNearestPC ) )
							SetLocalInt( oCreature, CREATURE_FLEE_COUNT, GetLocalInt( oCreature, CREATURE_FLEE_COUNT )+1 );
LocalDebug(">>>>> I'm running out of here after " + IntToString( GetLocalInt( oCreature, CREATURE_FLEE_COUNT ) ) + " rounds of fleeing" , oCreature );


						// Eventually distribute XP for flee
						if( !GetLocalInt( oCreature, VAR_XP_FLEE_DISTRIBUTED ) && !(nCreatureFlags & AI_FLAG_WILD) ){
							 SetLocalInt( oCreature, VAR_XP_FLEE_DISTRIBUTED, 1 );
							 GiveXPForFlee( oCreatureTarget, oCreature );
LocalDebug("++++++ Some XP for flee got distributed"  , oCreature );
						}
					
					}
		
			}
		}	
		nCountNoTargets += bHasNoValidTarget;
LocalDebug("########### nCountNoTargets : " + IntToString(nCountNoTargets) , oCreature );
	} 	
	
	SetLocalInt( oController, CONTROLLER_TEAM_ROUND_COUNT, nRound);
	
	// Returning to wandering if no more enemies around ! 
	if( ArrayGetCount( sTeamArrayName ) == nCountNoTargets ){
		SetLocalInt( oController, CONTROLLER_TEAM_STATE, ACTION_TEAM_WANDER);
LocalDebug("****** Team is returning to wandering state! :  " + IntToString( nTeamArrayCount ) +" / "+ IntToString( nCountNoTargets ) );
	
	}
	
} 