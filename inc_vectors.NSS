// ************************************************
// inc_vectors
// ************************************************
// Author: Clement Poh
// Date: 29/11/06
// Version: 1.02
// Description : Basic 3 dimensional vector library.
// Uses the vectors learnt in late high school 
// and first year uni maths.
//
// If you want anything added to this library,
// please don't hesitate to contact me at any time.
//
// Update History:
// 30/11/06 - Added function: LocAtAngleToLocFacing.
// 01/12/06 - More abstraction: VAtAngleToV.
// 03/12/06 - Added function: DetermineQuadrant.
// 04/12/06 - Changed important Loc functions, changes are in comments
//
// Notes: 
// - The functions don't handle the third dimension
// very thoroughly at all, but it seems to work as
// it is.
// - soh cah and toa return angles not lengths.
// They do not currently work well determining
// quadrants.
// 
// ************************************************
// *** PROTOTYPES
// ************************************************

// ** Vector functions.

// Returns the vector from v1 to v2.
vector AtoB(vector v1, vector v2);

// Returns a vector fDist away from vRef at fAngle.
vector VAtAngleToV(vector vRef, float fDist, float fAngle);

// Returns the projection of v2 onto v1. The vector component of v2
// in the direction of, or along v1.
vector VectorProjection(vector v1, vector v2);

// Finds the scalar projection of v2 onto v1. The length of the vector
// projection of v2 on to v1.
float ScalarProjection(vector v1, vector v2);

// Returns the enclosed angle between two vectors.
float EnclosedAngle(vector v1, vector v2);

// - Returns the scalar triple product of v1, v2 and v3.
// - Defined as |v1 . (v2 x v3)| 
float ScalarTripleProduct(vector v1, vector v2, vector v3);

// - Returns v1 x v2, the resultant vector is perpendicular to both v1 and v2.
vector CrossProduct(vector v1, vector v2);

// Returns the dot product of two vectors.
// - If the vectors are perpendicular, the dot product is zero.
float DotProduct(vector v1, vector v2);

// ** Basic trigonometry

// Determines the quadrant that v1 is relative to vOrigin.
// Returns 0 if is at 0, 90, 180, or 270 degrees to the
// positive x-axis.
int DetermineQuadrant(vector vOrigin, vector v1);

// Returns the adjacent angle, given the length of the hypotenuse and
// opposite side. * returns 0.0 for divide by 0.
float soh(float fOppositeLength, float fHypotenuseLength);

// Returns the adjacent angle, given the length of the hypotenuse and
// adjacent side. * returns 0.0 for divide by 0.
float cah(float fAdjacentLength, float fHypotenuseLength);

// Returns the adjacent angle, given the length of the opposite side
// and the adjacent side. * returns 0.0 for divide by 0.
float toa(float fOppositeLength, float fAdjacentLength);


// ** angles between a point and an axis function.

// Returns the angle between a vector (position) and the positive x-axis.
// from 0.0 to 180.0
float GetXAngle(vector v1);

// Returns the angle between a vector (position) and the positive y-axis.
// from 0.0 to 180.0
float GetYAngle(vector v1);

// Returns the angle between a vector (position) and the positive z-axis.
// from 0.0 to 180.0
float GetZAngle(vector v1);


// ** Functions which deal with locations relative to a Point.

// Returns a location fDist in front of oObj, facing oObj.
location LocInFrontOfObj(object oObj, float fDist = 1.0);

// Returns a location fDist behind oObj, facing oObj.
location LocBehindObj(object oObj, float fDist = 1.0);

// Returns a location fDist on the right side of oObj, facing oOb.
location LocRSideOfObj(object oObj, float fDist = 1.0);

// Returns a location fDist on the left side of oObj, facing oObj.
location LocLSideOfObj(object oObj, float fDist = 1.0);

// Returns a location fDist at angle fAngle around oObj, facing oObj.
// 0 degrees is the facing of the oObj, so 90.0 degrees is left of oObj.
location LocAtAngleToObj(object oObj, float fDist = 1.0, float fAngle = 0.0);

// Returns a location fDist in front of lRef, facing lRef.
location LocInFrontOfLoc(location lRef, float fDist = 1.0);

// Returns a location fDist behind of lRef, facing lRef.
location LocBehindLoc(location lRef, float fDist = 1.0);

// Returns a location fDist to the right of lRef, facing lRef.
location LocRSideOfLoc(location lRef, float fDist = 1.0);

// Returns a location fDist to the left of lRef, facing lRef.
location LocLSideOfLoc(location lRef, float fDist = 1.0);

// Returns a location fDist at angle fAngle around lRef, facing lRef.
// 0 degrees is the facing of the location, so 90.0 degrees is left of lRef.
location LocAtAngleToLoc(location lRef, float fDist = 1.0, float fAngle = 0.0);

// Returns a location fDist at angle fAngle around lRef, facing fFacing.
// 0 degrees is the facing of the location, so 90.0 degrees is left of lRef.
location LocAtAngleToLocFacing(location lRef, float fDist, float fAngle, float fFacing);


// ************************************************
// *** DEFINITIONS
// ************************************************

// Returns the vector from vA to vB.
vector AtoB(vector vA, vector vB) {
	return vB - vA;
}


// Returns a vector fDist away from vRef at fAngle.
vector VAtAngleToV(vector vRef, float fDist, float fAngle) {
	return Vector(vRef.x + fDist*cos(fAngle), vRef.y + fDist*sin(fAngle), vRef.z);
}

// Returns the projection of v2 onto v1. The vector component of v2
// in the direction of, or along v1.
vector VectorProjection(vector v1, vector v2) {
	return (DotProduct(v1, v2) / VectorMagnitude(v1)) * VectorNormalize(v1);
}

// Finds the scalar projection of v2 onto v1. The length of the vector
// projection of v2 on to v1.
float ScalarProjection(vector v1, vector v2) {
	return DotProduct(v1, v2)/VectorMagnitude(v1);
}

// Returns the enclosed angle between two vectors.
float EnclosedAngle(vector v1, vector v2) {
	return acos(DotProduct(v1, v2) / (VectorMagnitude(v1) * VectorMagnitude(v2)));
}

// Returns the scalar triple product of v1, v2 and v3.
// - The scalar triple product is equivalent to the volume of a
// parallelepiped of sides v1, v2 v3.
// - the volume of a tetrahedron is one sixth the volume of the associated
// parallelepiped.
// - If the scalar triple product is 0.0, v1, v2 and v3 are co-planar
float ScalarTripleProduct(vector v1, vector v2, vector v3) {
	return fabs(DotProduct(v1, CrossProduct(v2, v3)));
}

// Returns the cross product of vectors v1 and v2.
// - the magnitude of the cross product is equivalent to the area of a
// parallelogram with sides v1 and v2.
// - the are of triangle made by v1 and v2 is half the area of the associated
// parallelogram.
vector CrossProduct(vector v1, vector v2) {
	return Vector(v1.y * v2.z - v2.y * v1.z, v2.x * v1.z - v1.x * v2.z, v1.x * v2.y - v2.x * v1.y);
}


// Returns the dot product of two vectors.
float DotProduct(vector v1, vector v2) {
	return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z);
}


// ** Angles to the axes functions


// Determines the quadrant that v1 is relative to vOrigin.
// Returns 0 if is at 0, 90, 180, or 270 degrees to the
// positive x-axis.
int DetermineQuadrant(vector vOrigin, vector v1) {
	vector vNew = AtoB(vOrigin, v1);
	if (vNew.x > 0.0 && vNew.y > 0.0) {
		return 1;
	} else if (vNew.x < 0.0 && vNew.y > 0.0) {
		return 2;
	} else if (vNew.x < 0.0 && vNew.y < 0.0) {
		return 3;
	} else if (vNew.x > 0.0 && vNew.y < 0.0) {
		return 4;
	} else {
		return 0;
	}
}

// Returns the adjacent angle, given the length of the hypotenuse and
// opposite side. * returns 0.0 for divide by 0.
float soh(float fOppositeLength, float fHypotenuseLength) {
	if (fHypotenuseLength == 0.0) {
		return 0.0;
	} else {
		return asin(fOppositeLength/fHypotenuseLength);
	}
}

// Returns the adjacent angle, given the length of the hypotenuse and
// adjacent side. * returns 0.0 for divide by 0.
float cah(float fAdjacentLength, float fHypotenuseLength) {
	if (fHypotenuseLength == 0.0) {
		return 0.0;
	} else {
		return acos(fAdjacentLength/fHypotenuseLength);
	}
}

// Returns the adjacent angle, given the length of the opposite side
// and the adjacent side. * returns 0.0 for divide by 0.
float toa(float fOppositeLength, float fAdjacentLength) {
	if (fAdjacentLength == 0.0) {
		return 0.0;
	} else {
		return atan(fOppositeLength/fAdjacentLength);
	}
}

// Returns the angle between a vector (position) and the positive x-axis
float GetXAngle(vector v1) {
	return cah(v1.x, VectorMagnitude(v1));
}

// Returns the angle between a vector (position) and the positive y-axis
float GetYAngle(vector v1) {
	return cah(v1.y, VectorMagnitude(v1));
}

// Returns the angle between a vector (position) and the positive z-axis
float GetZAngle(vector v1) {
	return cah(v1.z, VectorMagnitude(v1));
}


// ** Locations relative to a Point functions

// Returns a location fDist in front of oObj, facing oObj.
location LocInFrontOfObj(object oObj, float fDist) {
	return LocAtAngleToLoc(GetLocation(oObj), fDist, 0.0);
} 

// Returns a location fDist behind oObj, facing oObj.
location LocBehindObj(object oObj, float fDist) {
	return LocAtAngleToLoc(GetLocation(oObj), fDist, 180.0);
} 

// Returns a location fDist to the right of oObj, facing oObj.
location LocRSideOfObj(object oObj, float fDist) {
	return LocAtAngleToLoc(GetLocation(oObj), fDist, -90.0);
}

// Returns a location fDist to the left of oObj, facing oObj.
location LocLSideOfObj(object oObj, float fDist) {		
	return LocAtAngleToLoc(GetLocation(oObj), fDist, 90.0);
}

// Returns a location fDist at angle fAngle around oObj, facing oObj.
// 0 degrees is the facing of oObj, so 90.0 degrees is left of the oObj.
location LocAtAngleToObj(object oObj, float fDist, float fAngle) {
	return LocAtAngleToLoc(GetLocation(oObj), fDist, fAngle);
} 

// Returns a location fDist in front of lRef, facing lRef.
location LocInFrontOfLoc(location lRef, float fDist) {		
	return LocAtAngleToLoc(lRef, fDist, 0.0);
} 

// Returns a location fDist in front of lRef, facing lRef.
location LocBehindLoc(location lRef, float fDist) {		
	return LocAtAngleToLoc(lRef, fDist, 180.0);
} 

// Returns a location fDist in front of lRef, facing lRef.
location LocRSideOfLoc(location lRef, float fDist) {		
	return LocAtAngleToLoc(lRef, fDist, -90.0);
} 

// Returns a location fDist in front of lRef, facing lRef.
location LocLSideOfLoc(location lRef, float fDist) {		
	return LocAtAngleToLoc(lRef, fDist, 90.0);
} 

// Returns a location fDist at angle fAngle around lRef, facing lRef.
// 0 degrees is the facing of the location, so 90.0 degrees is left of the location.
location LocAtAngleToLoc(location lRef, float fDist, float fAngle) {
	float fFacing = GetFacingFromLocation(lRef) + fAngle;
	return LocAtAngleToLocFacing(lRef, fDist, fAngle, fFacing - 180.0);
} 

// Returns a location fDist at angle fAngle around lRef, facing fFacing.
// 0 degrees is the facing of the location, so 90.0 degrees is left of the location.
location LocAtAngleToLocFacing(location lRef, float fDist, float fAngle, float fNew) {
	object oArea = GetAreaFromLocation(lRef);
	vector vRef = GetPositionFromLocation(lRef);
	float fFacing = GetFacingFromLocation(lRef);
	
	vector vNewPos = VAtAngleToV(vRef, fDist, fFacing + fAngle);
	return Location(oArea, vNewPos, fNew);
} 