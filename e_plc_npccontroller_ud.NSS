//:://////////////////////////////////////////////////
//:: e_plc_npccontroller_ud
//:://////////////////////////////////////////////////
/*
	Description: custom onUserDefinedEvent for Khalidine NPC Controller System
   
*/
//:://////////////////////////////////////////////////
// 29/12/07 Creation by Alban : hostile creatures management
//:://////////////////////////////////////////////////
/*

# Events
	74840 - trigger entered, spawn hostile creatures


*/
//:://////////////////////////////////////////////////


#include "inc_ai_hostile"


// :: ----------------------------------------------------------------------------------------------------
// :: MAIN  
// :: ----------------------------------------------------------------------------------------------------
	

void main() {

    int nEvent = GetUserDefinedEventNumber();

LocalDebug("e_plc_npccontroller_ud launched");

	object oController = OBJECT_SELF;
	string sTeamArrayName = GetTag( OBJECT_SELF );
	int  bCreatureChoseTarget, nCreatureFlags, nCreatureHierarchicFlag, nCreatureHPCurrent, nCreatureHPMax, nPercentHPRemainingCreature, nCreatureState, nCreatureNextState, nCustomCreatureAILevel;
	object oCreatureTarget, oTarget, oNextTarget, oPerceived;


	// :: ----------------------------------------------------------------------------------------------------
	// :: Event 74843 : hostile creature attacked
	// :: Signal sent by custom onAttacked event script
	// :: ----------------------------------------------------------------------------------------------------	

    if( nEvent == EVENT_HOSTILE_CREATURE_TEAM_WAKE){
		LocalDebug("################# EVENT_HOSTILE_CREATURE_TEAM_WAKE launched", OBJECT_SELF);
		
	// If the hostile team already sighted enemy this should not start	
	if( GetLocalInt( oController, CONTROLLER_TEAM_STATE ) <= ACTION_TEAM_FIRST_SIGHT ){
		LocalDebug("################# EVENT_HOSTILE_CREATURE_TEAM_WAKE operating", OBJECT_SELF);
	
		SetLocalInt( oController, CONTROLLER_TEAM_STATE, ACTION_TEAM_COMBAT);
		int	nTeamArrayCount = ArrayGetCount( sTeamArrayName );

		object oTeamTarget = GetLocalObject( oController, CONTROLLER_TEAM_TARGET_CURRENT );
		

			// This is a reduced version of what happens when heartbeat starts
	
	int nNthCreature;
	for( nNthCreature = --nTeamArrayCount; nNthCreature >= 0 ; nNthCreature--) 
	{
	
		object oTarget = oTeamTarget;
		
		object oCreature = ArrayGetObjectElement( sTeamArrayName, nNthCreature );
LocalDebug("------------------------------------------------------------------------ ");
LocalDebug("Controller parsing creature : " + GetTag( oCreature )+" at index : "+IntToString(nNthCreature) , oCreature );
			
		if ( !GetIsObjectValid( oCreature )  || GetIsDead(oCreature) ){
			ArrayRemoveElement( sTeamArrayName, nNthCreature );
LocalDebug("****** Removing from array at index " +IntToString(nNthCreature)+", "+IntToString(nTeamArrayCount)+" Creature(s) left in array" );		
			continue;
		} 		
		{
		
	
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
		
				
									
LocalDebug(">>>>> I'm having first sight with my team."  , oCreature );
					
				// Action : wake up, buff and so on
				SetActionMode(oCreature, ACTION_MODE_DETECT, FALSE);
				AssignCommand( oCreature, ClearAllActions() );


					if ( GetCreatureHasBuffing( nCreatureFlags ) ) {
LocalDebug(">>>>> I'm buffing myself  ! ", oCreature );
							
						 UseFunctionBuff( oCreature ) ;
					}else if( GetCreatureHasFunction( nCreatureFlags ) ) {
					
					
						UseFunctionInCombat( oCreature, oTarget, nCreatureFlags );
						
						// We want the creature to attack team target
					} else {
LocalDebug(">>>>> I'm not buffing myself  ! Attack ! ", oCreature );
					
						ActionCustomAttack(  oCreature,  oTarget ) ;
						
					}
			}
		}
		}else{

		LocalDebug("################# EVENT_HOSTILE_CREATURE_TEAM_WAKE : not operating  due to team state", OBJECT_SELF);		
		}
	} // End of Event 74842 : hostile creature killed
		

	// :: ----------------------------------------------------------------------------------------------------
	// :: Event 74840 : spawning hostile creatures
	// :: Signal sent by any Khalidine hostile AI Trigger
	// :: ----------------------------------------------------------------------------------------------------	
	
    if( nEvent == EVENT_HOSTILE_CREATURE_SPAWN  ){
LocalDebug("EVENT_HOSTILE_CREATURE_SPAWN launched", oController);

/*		
		// We look for the closest trigger : we're spawned at its location
		object oTrigger = GetNearestObjectByTag( HOSTILE_AI_TRIGGER);

		
LocalDebug("Getting trigger", oTrigger);

		// _____________________________________________________________________
		// ::  START CHECKING
					
		// Has that trigger our tag and is it requesting spawn ?
		if( GetTag( oController ) == GetName( oTrigger )  && GetLocalInt( oTrigger, TRIGGER_STATE) == ACTION_TRIGGER_REQUESTING_SPAWN) {

LocalDebug("Valid Trigger", oTrigger);
		
			// We want to get that trigger delay and last activation timestamp 
			int nTriggerRespawnDelay = GetLocalInt ( oTrigger, TRIGGER_DELAY );
			int nTriggerLastSpawnTime = GetLocalInt( oTrigger, TRIGGER_TIMESTAMP);

			// We want to get the amount of creature spawned yet and the actual timestamp
			int nCounter = GetLocalInt( GetModule(), HOSTILE_SPAWN_COUNTER );
			int nNow = GetHourStamp();				
			
			// Is it time to spawn that trigger creatures ?
			if ( nTriggerLastSpawnTime == 0 || ( nTriggerLastSpawnTime + nTriggerRespawnDelay ) <= nNow ) {	
LocalDebug("spawning creature");
		
				int nDifficulty = GetLocalInt( oTrigger, TRIGGER_DIFFICULTY );
				string sTeam = GetLocalString ( oTrigger, TRIGGER_NAME);
				int nMin = GetLocalInt( oTrigger, TRIGGER_MIN);
				int nMax = GetLocalInt( oTrigger, TRIGGER_MAX);
				float fFearFactor = GetLocalFloat ( oTrigger, TRIGGER_FEAR_FACTOR );

				// We want to update the controller
				SetLocalFloat( oController, CONTROLLER_TEAM_FEAR_FACTOR , fFearFactor);

									
				// We want to get the last entering object party's average level
				string sEnteredTag = GetLocalString ( oTrigger, TRIGGER_TAG_ENTERED);
				int nPartyAverageLevel = GetPartyAverageLevel( GetObjectByTag( sEnteredTag ) );
									
				// _____________________________________________________________________
				// ::  START SPAWNING
				
				// We spawn creatures following that path
				// 0. Check if creature spawns, and how much eventually, related to CR etc.
				// 1 Spawn creatures 
				// 1.a Instantiate object
				// 1.b Set creature : scriptset, conditional and other variables 
				// 1.c Update controller
				// 1.d Add creature to team array
				
									
				// We want to look for the creatures strings and spawn them accordingly
				int nNthCreature = 1;
				string sCreatureStringData = GetLocalString ( oTrigger, TRIGGER_CREATURE + IntToString( nNthCreature ) );

				while ( sCreatureStringData != "" ) {
					
					string sCreaturesArrayName =  GetTag( oController ) ;
				
					// We want to parse the line 
					// Flag:BinaryInt|LevelMin:0|LevelMax:40|Resref:string|NumberOfWaypoints|WP_team_1|WP_team_2|etc.		
					int nArraySize = UtilCreateTokenizedArray( TEMP_ARRAY_NAME, sCreatureStringData, "|");
					
					int nFlags = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_FLAGS );
					int nLevelMin = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_LEVEL_MIN );
					int nLevelMax = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_LEVEL_MAX );		
					string sResref = UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_RESREF );
					int nNumberOfWP = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_WAYPOINT_NUMBER );
						
	
					// 0. Check if creature spawns
					if( GetIsEncounterSpawnable( nPartyAverageLevel, nLevelMin, nLevelMax ) ) {
					
						// We want to know how much of this creature resref to spawn
						// ================================================
						// TODO :: Provide a formula to integrate the factors :
						// Unique
						// Trigger difficulty
						// Creatures Min Max
						// Total number of creatures in the spawn
						// Actually we're gonna spawn one per creature line 
						int nCreatureQuantity = GetEncounterQuantity();
						
						int nIndex, nRandomWaypointIndex, nCondition, nCreatureCurrentHP, nCreatureXPMax, nCreatureIsBoss;
						location lLoc;
						string sWaypointTag, sCreatureTag, sArea, sCreatureArrayName;
						object oCreature;
						
						
						// 1 Spawn creatures 

						for ( nIndex = 0; nIndex < nCreatureQuantity; nIndex++) {
						
							// 1.a Instantiate object
						
							// We want to get a random waypoint from the array : indexes >= 5
							nRandomWaypointIndex = INDEX_CREATURE_SPAWN_FIRST_WAYPOINT + Random( nNumberOfWP );
							sWaypointTag = UtilGetTokenFromArrayAt( WAYPOINT_ARRAY_NAME, nRandomWaypointIndex );
							lLoc = GetLocation( GetObjectByTag ( sWaypointTag ) );
														
							// We want to create creature's tag and iterate module counter
							sCreatureTag = "ENEMY_" + IntToString( nCounter );
							SetLocalInt( GetModule(), HOSTILE_SPAWN_COUNTER, ++nCounter);
							
							// We want to create the creature
							oCreature = CreateObject( OBJECT_TYPE_CREATURE, sResref, lLoc, FALSE, sCreatureTag );		
							nCondition = GetLocalInt(oCreature, sSpawnCondVarname);
																	
LocalDebug("spawned creature : " + sCreatureTag, oCreature);						
							

							// _____________________________________________________________________
							// 1.b Set creature : scriptset, conditional and other variables 
							
							SetCreatureScriptsToSet( oCreature, CUSTOM_CREATURE_SCRIPTSET_NUMBER);		
							SetSpawnFlags( oCreature, nCondition, nFlags );
							nCreatureCurrentHP = GetCurrentHitPoints( oCreature );
							nCreatureXPMax = GetCreatureXPReward( 100 );
							nCreatureIsBoss = 0; if( nFlags & NW_FLAG_BOSS ) { nCreatureIsBoss  = 1; }
							SetLocalInt( oCreature, CREATURE_HP_CURRENT , nCreatureCurrentHP);
							SetLocalInt( oCreature, CREATURE_XP_TOTAL, nCreatureXPMax);												
						  	SetLocalInt ( oCreature, CREATURE_FLAGS, nFlags);	
							
							
							
							// _____________________________________________________________________
							// 1.c Update controller
							
							SetLocalInt( oController, CONTROLLER_TEAM_HAS_BOSS , GetLocalInt( oController, CONTROLLER_TEAM_HAS_BOSS ) + nCreatureIsBoss );
							SetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT , GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT ) + nCreatureCurrentHP);
							SetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL , GetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL ) + nCreatureCurrentHP);
							SetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT , GetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT ) + MORALE_FACTOR_BONUS_PER_NEW_MEMBER);

							
							
							// _____________________________________________________________________
							// 1.d Add creature to team array
	
							sCreatureArrayName = GetTag( oController );

							// We want to check if this team array exists and create it if needed 
							if ( ArrayGetCount( sCreatureArrayName ) == 0 ) { ArrayCreate( sCreatureArrayName );}
						
							ArrayAddObjectElement( sCreatureArrayName, oCreature);
							
LocalDebug("Array count : " + IntToString( ArrayGetCount( sCreatureArrayName) ) );
					
							 }							
						

					}
					
					
					// Looking for next creature variable
					// ================================
					string sCreatureStringData = GetLocalString ( oTrigger, TRIGGER_CREATURE + IntToString( ++nNthCreature ) );
				
				}

	
				


 					SetLocalInt( oTrigger, TRIGGER_TIMESTAMP, nNow);			

			}
			else LocalDebug("Not respawing creatures yet !");				
			
			// reset the request for spawning
			SetLocalInt( oTrigger, TRIGGER_STATE, ACTION_TRIGGER_WAITING );
		}	
*/	
	} // End of Event 74840 : spawning creatures


	// :: ----------------------------------------------------------------------------------------------------
	// :: Event 74841 : hostile creature damaged
	// :: Signal sent by custom onDamaged event script
	// :: of any Khalidine Hostile AI Trigger spawned creature
	// :: ----------------------------------------------------------------------------------------------------	

    if( nEvent == EVENT_HOSTILE_CREATURE_DAMAGED ){
		LocalDebug("EVENT_HOSTILE_CREATURE_DAMAGED launched");
		
		// We want to get the amount of HP lost by creature
		
		// We want to update the TeamHP variable


		
		
	} // End of Event 74841 : hostile creature damaged
		
	// :: ----------------------------------------------------------------------------------------------------
	// :: Event 74842 : hostile creature killed
	// :: Signal sent by custom onDeath event script
	// :: of any Khalidine Hostile AI Trigger spawned creature
	// :: ----------------------------------------------------------------------------------------------------	

    if( nEvent == EVENT_HOSTILE_CREATURE_DEAD ){
		LocalDebug("EVENT_HOSTILE_CREATURE_DEAD launched");
	} // End of Event 74842 : hostile creature killed
		
	
		
}