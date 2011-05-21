// script name - e_trig_encounters_e
/*
	Description: custom spawning trigger

*/

#include "inc_ai_hostile"

void main (){

	object oTrigger = OBJECT_SELF;
	
	// :: _________________________________________________________________
	// :: 
	// :: First checking if spawns occurs or not depending on time and level
	// :: 
	// :: _________________________________________________________________
	
	// We want to check the last entering object
	object oPC = GetEnteringObject(); 
	if( ( !GetIsPC(oPC) && !GetIsPossessedFamiliar(oPC)) || GetIsDM(oPC) )
	return;

	// We want to get the controller's tag 
	string sTeam = GetLocalString ( OBJECT_SELF,TRIGGER_NAME);
	string sControllerTag =  sTeam;

LocalDebug("****** Looking for team : " + sTeam );			
	
	
	
	// This belongs to first design, might prove useless now
/*
	// We want to set eventually this object's name to match the controller's tag
	if( GetName( OBJECT_SELF ) != sControllerTag ) {
		SetFirstName ( OBJECT_SELF, sControllerTag );
		SetLastName ( OBJECT_SELF, "" );
		}		
*/

	// We want to get trigger delay and last activation timestamp 
	int nTriggerRespawnDelay = GetLocalInt ( oTrigger, TRIGGER_DELAY );
	int nTriggerLastSpawnTime = GetLocalInt( oTrigger, TRIGGER_TIMESTAMP);

	// Todo : implement at module level ( max number of creatures) 
	
	// We want to get the amount of creature spawned yet and the actual timestamp
//	int nCounter = GetLocalInt( GetModule(), HOSTILE_SPAWN_COUNTER );
	int nNow = GetHourStamp();				
	
	
	// We want to get the last entering object party's average level
	struct PARTY_DATA stPartyData = xp_getPartyData( oPC, DISTANCE_PARTY_SCAN );
	int nPartyAverageLevel = FloatToInt( stPartyData.fAverageLevel );
	int nLevelMin = GetLocalInt( oTrigger, TRIGGER_LEVEL_MIN);
	int nLevelMax = GetLocalInt( oTrigger, TRIGGER_LEVEL_MAX);
LocalDebug("****** nPartyAverageLevel : " + IntToString ( nPartyAverageLevel ) );			


	// :: _________________________________________________________________
	// :: 
	// ::Checking starts now
	// :: 
	// :: _________________________________________________________________


	// Checking if Time of Day is ok
	if ( CheckTODTag( 	GetLocalInt ( oTrigger, TRIGGER_TOD ) ) ) {

	// Checking timer 
	if ( nTriggerLastSpawnTime == 0 || ( nTriggerLastSpawnTime + nTriggerRespawnDelay ) <= nNow ) {	

	// Checking if level range is ok 
	if( GetIsEncounterSpawnable( nPartyAverageLevel, nLevelMin, nLevelMax ) ) {
		
LocalDebug("**************************************** ");
LocalDebug("****** Trigger spawning creatures ! ******");
LocalDebug("**************************************** ");

	// :: _________________________________________________________________
	// :: 
	// :: At this point, spawn will happen
	// :: 
	// :: _________________________________________________________________

	
	
		// Team spawns, update timestamp
		SetLocalInt( oTrigger, TRIGGER_TIMESTAMP, nNow);			

		// We want to get the controller and create it eventually
		object oController = InstantiateController( sControllerTag,  GetLocation( OBJECT_SELF ) );
		
		if( !GetIsObjectValid( oController ) )
LocalDebug(" ######!!!! Couldn't spawn the controller ");
		
		// We want to reset the max HP for existing controllers
		// Max HP would be too high and morale abnormaly down
		if( GetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL ) )
			SetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL, GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT ) );
		
		
		// We want to retrieve the team's parameters 
		float fDifficulty = GetLocalFloat( oTrigger, TRIGGER_DIFFICULTY );
		string sTeam = GetLocalString ( oTrigger, TRIGGER_NAME);
		float fFearFactor = GetLocalFloat ( oTrigger, TRIGGER_FEAR_FACTOR );
		int nTeamState = GetLocalInt( oTrigger, TRIGGER_TEAM_STATE );
		int nState = GetLocalInt( oTrigger, TRIGGER_STATE );
		string sCreaturesArrayName =  GetTag( oController ) ;
		string sFleeWaypoint =   GetLocalString ( oTrigger, TRIGGER_FLEE_WAYPOINT );

		// We want to update the controller
		SetLocalFloat( oController, CONTROLLER_TEAM_FEAR_FACTOR , fFearFactor);
		SetLocalInt( oController, CONTROLLER_TEAM_STATE , nTeamState);
		
		// We want to create the arrays required by the spawning process
		ArrayCreate( POOL_BASE_ARRAY_NAME );
		ArrayCreate( POOL_BASE_ARRAY_COUNT );
		ArrayCreate( FINAL_SPAWN_ARRAY_NAME );
							
		// We want to know the targetted Challenge Rating
		float fReachedCR = 0.0;
		float fTargetCR = GetTargetCR( stPartyData.fAverageLevel, stPartyData.nMembersInRange, fDifficulty, TARGET_CR_GLOBAL_MODIFIER);	
LocalDebug("****** Target CR : " + FloatToString( fTargetCR ));
		
		// _____________________________________________________________________
		// :: 
		// :: The spawning has been decided so now we A/ prepare B/ cook
		// :: 
		//
		// A/ Prepare 
		// ===========
		// A.1 : load encounter lines into a BasePool array 
		// 		 and add the fixed creatures
		// A.2 : Compare target CR with actual CR and decide if more is needed
		// A.3 : If more is required, let's add some to the final array
		//
		// B/ Cook
		// ========
		// B.1 Spawn creatures 
		// B.2 Instantiate object
		// B.3 Set creature : scriptset, conditional and other variables 
		// B.4 Update controller
		// B.5 Add creature to team array
		// :: 
		// :: _________________________________________________________________

		

		
		// :: =========================================================		
		// A.1
		// :: =========================================================		
							
		int nToSpawn = 0; // stores how many creatures will spawn
		int nNthCreature = 1;
		string sCreatureStringData = GetLocalString ( oTrigger, TRIGGER_CREATURE + IntToString( nNthCreature ) );
		
		// Reading from trigger and adding to the arrays
		// ===============================================
		
		while ( sCreatureStringData != "" ) {
LocalDebug("****** Looking for variable : " + TRIGGER_CREATURE + IntToString( nNthCreature ));
LocalDebug("****** Original Variable : " + sCreatureStringData );				

		
			// We parse min spawn, CR 
			// =======================================
			
			int nArraySize = UtilCreateTokenizedArray( TEMP_ARRAY_NAME, sCreatureStringData, ",");			
			int nSpawnMin = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_MIN );
			int nSpawnMax = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_MAX );
			int nSpawned = 0;
			float fCR = StringToFloat( UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_CR )  );
					
LocalDebug("Variables parsed : Spawn Min " + IntToString( nSpawnMin ) +" | CR : "+ FloatToString( fCR ) );


			// Add to final spawn array the eventual lines
			// ===========================================
			
			if( nSpawnMin > 0 )			
				while( nSpawnMin > 0 ){			
					ArrayAddStringElement( FINAL_SPAWN_ARRAY_NAME, sCreatureStringData);
					fReachedCR = GetUpdatedReachedCR( fReachedCR, fCR );
					nSpawnMin--;
					nSpawned++;
					nToSpawn++;
LocalDebug( "Spawning one, Reached CR : " + FloatToString( fReachedCR ) );
				}
			
				
			// Add to Pool Base Array only if CR of creature inferior to target CR
			// or if max creatures is not reached
			// =====================================================================
			
			if( fCR < fTargetCR || nSpawned <= nSpawnMax ){
				ArrayAddStringElement( POOL_BASE_ARRAY_NAME, sCreatureStringData);
				ArrayAddStringElement( POOL_BASE_ARRAY_COUNT, IntToString( nSpawned ) );
				
LocalDebug( "Adding to Base Pool Array.");				
				}
			
			// Get next creature's line
			// ================================
			 sCreatureStringData = GetLocalString ( oTrigger, TRIGGER_CREATURE + IntToString( ++nNthCreature ) );
		

		}
	
			
LocalDebug( "******  Base Pool Array name count : " + IntToString( ArrayGetCount( POOL_BASE_ARRAY_NAME ) ) );				
LocalDebug( "******  Base Pool Array count count: " + IntToString( ArrayGetCount( POOL_BASE_ARRAY_COUNT ) ) );				
LocalDebug( "******  Final Pool Array count : " +  IntToString( ArrayGetCount( FINAL_SPAWN_ARRAY_NAME ) ) );				
			
int nArrayCount = ArrayGetCount( POOL_BASE_ARRAY_COUNT );
for( nNthCreature = --nArrayCount; nNthCreature >= 0 ; nNthCreature--) 
{
LocalDebug("creatures : " + IntToString( nNthCreature ) + " : " +  ArrayGetStringElement( POOL_BASE_ARRAY_COUNT, nNthCreature )  + " / " +  ArrayGetStringElement( POOL_BASE_ARRAY_NAME, nNthCreature )  );
}				
			
				
		// :: =========================================================	
		// A.2 : Compare target CR with actual CR and decide if more is needed
		// :: =========================================================	
		int nA3Switch = ( fTargetCR > fReachedCR ) ? 1 : 0 ;
		
		
		// :: =========================================================	
		// A.3 : If more is required, let's add some to the final array
		// :: =========================================================	
		
		if( nA3Switch ) {
		
			float fPotentialCR; // Updated during the process, local temp var
			
		
			// Spawn until a./ CR ok OR b./ pool is depleted 
			while(  fTargetCR < fReachedCR || ArrayGetCount( POOL_BASE_ARRAY_NAME ) > 0 ) {
LocalDebug("************************************************************ " );				
LocalDebug("****** Another Roll : CR  " + FloatToString( fReachedCR ) + " / " + FloatToString( fTargetCR ) );				
			

				// We get through the base pool array
				int nArrayCount = ArrayGetCount( POOL_BASE_ARRAY_NAME );
LocalDebug("****** Pool Base Array count : " + IntToString( nArrayCount ) );				
LocalDebug("************************************************************ " );				
				for( nNthCreature = --nArrayCount; nNthCreature >= 0 ; nNthCreature--) 
				{
				
				
					// We retrieve the creature's line and tokenize it
					sCreatureStringData = ArrayGetStringElement( POOL_BASE_ARRAY_NAME, nNthCreature );
					int nArraySize = UtilCreateTokenizedArray( TEMP_ARRAY_NAME, sCreatureStringData, ",");			
					int nSpawnMax = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_MAX );		
					float fCR = StringToFloat( UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_CR )  );
LocalDebug("****** Original Variable : " + sCreatureStringData );				

					
					// If potential CR is above Target CR OR if potential CR equal to current OR if max creatures spawned
					// We drop and delete from pool arrays
					
					fPotentialCR = GetUpdatedReachedCR( fReachedCR, fCR );
					int nSpawned = StringToInt( ArrayGetStringElement( POOL_BASE_ARRAY_COUNT, nNthCreature ) );	
LocalDebug("Count creatures : " +  IntToString(nSpawned) );
					if( 
						fPotentialCR > fTargetCR
						|| fPotentialCR == fReachedCR
						|| StringToInt( ArrayGetStringElement( POOL_BASE_ARRAY_COUNT, nNthCreature ) ) >= nSpawnMax
					){
LocalDebug("Removing Creature from pool. " );
						ArrayRemoveElement( POOL_BASE_ARRAY_NAME, nNthCreature );
						ArrayRemoveElement( POOL_BASE_ARRAY_COUNT, nNthCreature );					
					}
					
					// Else we roll probability of spawning 
					else if(
						RollSpawnProbability( fTargetCR, fPotentialCR, nToSpawn, stPartyData.nMembersInRange )
					){
LocalDebug("Adding Creature to spawn : Updated CR : " + FloatToString( fPotentialCR ) );
						nSpawned++;
						ArrayAddStringElement( FINAL_SPAWN_ARRAY_NAME, sCreatureStringData);
						fReachedCR = fPotentialCR;
						ArraySetElementAt( POOL_BASE_ARRAY_COUNT, IntToString( nSpawned ),nNthCreature );
						nToSpawn++;
LocalDebug("Count creatures update : " +  ArrayGetStringElement( POOL_BASE_ARRAY_COUNT, nNthCreature ) );
						
					}
					
				}
/*
nArrayCount = ArrayGetCount( POOL_BASE_ARRAY_COUNT );
for( nNthCreature = --nArrayCount; nNthCreature >= 0 ; nNthCreature--) 
{
LocalDebug("creatures : " + IntToString( nNthCreature ) + " : " +  ArrayGetStringElement( POOL_BASE_ARRAY_COUNT, nNthCreature )  + " / " +  ArrayGetStringElement( POOL_BASE_ARRAY_NAME, nNthCreature )  );
}				
*/			
			}
		
		
		}
LocalDebug("************************************************************ " );				
LocalDebug( "******  Base Pool Array name count : " + IntToString( ArrayGetCount( POOL_BASE_ARRAY_NAME ) ) );				
LocalDebug( "******  Base Pool Array count count : " + IntToString( ArrayGetCount( POOL_BASE_ARRAY_COUNT ) ) );				
LocalDebug( "******  Final Pool Array count : " +  IntToString( ArrayGetCount( FINAL_SPAWN_ARRAY_NAME ) ) );				
			

		
LocalDebug("************************************************************ " );				
LocalDebug( "******  Start Spawning " );				
LocalDebug("************************************************************ " );				



		// B/ Cook
		// ========
		nArrayCount = ArrayGetCount( FINAL_SPAWN_ARRAY_NAME );
		for( nNthCreature = --nArrayCount; nNthCreature >= 0 ; nNthCreature--) 
		{
			
		// :: =========================================================	
		// B.1 Spawn creatures 
		// :: =========================================================	

			int nIndex, nRandomWaypointIndex, nCondition, nCreatureCurrentHP, nCreatureXPMax, nCreatureIsBoss;
			location lLoc;
			string sWaypointTag, sCreatureTag, sArea, sCreatureArrayName;

			object oCreature;

			// We retrieve the creature's line and tokenize it
			sCreatureStringData = ArrayGetStringElement( FINAL_SPAWN_ARRAY_NAME, nNthCreature );
			int nArraySize = UtilCreateTokenizedArray( TEMP_ARRAY_NAME, sCreatureStringData, ",");
			int nFlags = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_FLAGS );
			int nSpawnMin = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_MIN );
			int nSpawnMax = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_MAX );		
			string sResref = UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_RESREF );
	//		float fCR = StringToFloat( UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_CR )  );
			string sCR = UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_CR )  ;
			int nNumberOfWP = UtilGetIntTokenFromArrayAt( TEMP_ARRAY_NAME, INDEX_CREATURE_SPAWN_WAYPOINT_NUMBER );

LocalDebug("****** Original Variable : " + sCreatureStringData );				
		
		// :: =========================================================	
		// B.2 Instantiate object
		// :: =========================================================	
		
					// We want to get a random waypoint from the array : indexes >= INDEX_CREATURE_SPAWN_FIRST_WAYPOINT
					nRandomWaypointIndex = INDEX_CREATURE_SPAWN_FIRST_WAYPOINT + Random( nNumberOfWP );
					sWaypointTag = UtilGetTokenFromArrayAt( TEMP_ARRAY_NAME, nRandomWaypointIndex );
					lLoc = GetLocation( GetObjectByTag ( sWaypointTag ) );
LocalDebug("spawning WP : " + sWaypointTag + ", Index Number : " + IntToString( nRandomWaypointIndex ));						
										
		
					// We want to create creature's tag and iterate module counter
//					sCreatureTag = "ENEMY_" + IntToString( nCounter );
//					SetLocalInt( GetModule(), HOSTILE_SPAWN_COUNTER, ++nCounter);

					// Preceding was commented in order to use CopyObject
					sCreatureTag = sResref;
					
					
					// We want to create the creature
					
					// If a creature is already around, let's copy and heal it
					object oSource = GetObjectByTag( sResref );
					
					if( GetIsObjectValid( oSource) && !GetIsDead( oSource)  ){
LocalDebug("Copying resref : " + sResref, oCreature);						
						oCreature = CopyObject( oSource, lLoc );
						ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(999), oCreature);	
						
						// Todo : ResetCreatureVariables
						DeleteLocalInt( oCreature, CREATURE_FLEE_COUNT );
						DeleteLocalInt( oCreature, CREATURE_STATE );
						DeleteLocalInt( oCreature, CREATURE_HP_CURRENT );
						DeleteLocalInt( oCreature, CREATURE_TARGET );
						
						effect eEffect = GetFirstEffect( oCreature );
						while ( GetIsEffectValid(eEffect) )
						{
							RemoveEffect(oCreature, eEffect);
						}

					}else{
					// Spawn new creature
						oCreature = CreateObject( OBJECT_TYPE_CREATURE, sResref, lLoc, FALSE, sCreatureTag );		
					}
					nCondition = GetLocalInt(oCreature, sSpawnCondVarname);
		if( GetIsObjectValid( oCreature ) ) 	
			LocalDebug("spawning creature : " + sCreatureTag, oCreature);						
		else 										
			LocalDebug("###!!!!Couldn't spawn creature : " + sCreatureTag);						
					
		// :: =========================================================	
		// B.3 Set creature : scriptset, conditional and other variables
		// :: =========================================================	
					SetCreatureScriptsToSet( oCreature, CUSTOM_CREATURE_SCRIPTSET_NUMBER);							
					SetSpawnFlags( oCreature, nCondition, nFlags );					
					nCreatureCurrentHP = GetCurrentHitPoints( oCreature );
//					nCreatureXPMax = GetCreatureXPReward( FloatToString( fCR ), FloatToInt( stPartyData.fAverageLevel ) );
					nCreatureXPMax = GetCreatureXPReward( sCR , FloatToInt( stPartyData.fAverageLevel ) );
					nCreatureIsBoss = ( nFlags & AI_FLAG_BOSS ? 1 : 0 );
				  	SetLocalInt ( oCreature, CREATURE_AI_LEVEL, GetCustomAILevel( oCreature ) );	
				  	SetLocalInt ( oCreature, CREATURE_FLAGS, nFlags);	
					SetLocalInt( oCreature, CREATURE_HP_CURRENT , nCreatureCurrentHP);
					SetLocalInt( oCreature, CREATURE_HP_MAX , nCreatureCurrentHP);
					SetLocalInt( oCreature, CREATURE_XP_TOTAL, nCreatureXPMax);												
					SetLocalInt( oCreature, CREATURE_XP_REWARDED, 0 );												
				  	SetLocalString ( oCreature, CREATURE_TEAM, sTeam );	
				  	SetLocalString ( oCreature, CREATURE_FLEE_WAYPOINT, sFleeWaypoint );	
					
LocalDebug( "****** Creature XP : " + IntToString( nCreatureXPMax)  + " <=> " + IntToString( GetLocalInt( oCreature, CREATURE_XP_TOTAL) ), oCreature );
		
		// :: =========================================================	 
		// B.4 Update controller
		// :: =========================================================	
					
					SetLocalInt( oController, CONTROLLER_TEAM_HAS_BOSS , GetLocalInt( oController, CONTROLLER_TEAM_HAS_BOSS ) + nCreatureIsBoss );
					SetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT , GetLocalInt( oController, CONTROLLER_TEAM_HP_CURRENT ) + nCreatureCurrentHP);
					SetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL , GetLocalInt( oController, CONTROLLER_TEAM_HP_TOTAL ) + nCreatureCurrentHP);
					SetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT , GetLocalInt( oController, CONTROLLER_TEAM_MORALE_CURRENT ) + MORALE_BONUS_PER_NEW_MEMBER);
		
		// :: =========================================================	
		// B.5 Add creature to team array
		// :: =========================================================	

		
					sCreatureArrayName = GetTag( oController );

					// We want to check if this team array exists and create it if needed 
					if ( ArrayGetCount( sCreatureArrayName ) == 0 ) { ArrayCreate( sCreatureArrayName );}
				
					ArrayAddObjectElement( sCreatureArrayName, oCreature);
					
LocalDebug("****** Array count : " + IntToString( ArrayGetCount( sCreatureArrayName) ) );
		
		
		
		
		}			
		
			
			// Dinner ready : Time to eat !
		
		} // Level NOK
		else LocalDebug("****** GetIsEncounterSpawnable NOK : Party average " + IntToString(nPartyAverageLevel) + " / Min : " + IntToString(nLevelMin) + " / Max : " + IntToString(nLevelMax)   );

	} // Timestamp NOK
	else LocalDebug("****** Not respawing creatures yet !");				

	}// TOD NOK
	else LocalDebug("****** Time Of Day is wrong ! : " + IntToString( GetLocalInt ( oTrigger, TRIGGER_TOD ))  + " vs actual : " + IntToString( GetTimeHour() ) ) ;				
}