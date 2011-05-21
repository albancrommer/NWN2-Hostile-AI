// Name     : nwnx_hashset
// Purpose  : A general purpose implementation combining a hash and a set (NWNX2 version)
// Author   : Ingmar Stieger
// Modified : March 19th, 2007 by Marc Paradise (Grinning Fool) for new NWNX4 functions
//            December 27th, 2007 by Marc Paradise (Grinning Fool) to add Array functions.

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2

/************************************/
/* Return codes                     */
/************************************/

const string HASHSET = "HASHSET";

const string HASHSET_CREATE = "CR";
const string HASHSET_DESTROY = "DR";
const string HASHSET_IS_VALID = "IV";
const string HASHSET_IS_EXISTING = "IE";
const string HASHSET_INSERT = "IN";
const string HASHSET_LOOKUP = "LK";
const string HASHSET_DELETE = "DL";
const string HASHSET_GET_FIRST_KEY = "FK";
const string HASHSET_GET_NEXT_KEY = "NK";
const string HASHSET_GET_HAS_NEXT_KEY = "HK";
const string HASHSET_GET_FIRST_VALUE = "FV";
const string HASHSET_GET_NEXT_VALUE = "NV";
const string HASHSET_GET_HAS_NEXT_VALUE = "HV";
const string HASHSET_GET_SIZE = "GS";
const string HASHSET_LOAD_FROM_FILE = "FF";
const string HASHSET_TOKENMAP_NEW = "TC";
const string HASHSET_TOKENMAP_NEXT = "TN";


const string ARRAY_CREATE = "AC";      // AC , name, size
const string ARRAY_DELETE = "AD";      // AD , name
const string ARRAY_GET_ELEMENT = "AG"; // AG , name, index
const string ARRAY_GET_ELEMENT_INT = "AI"; // AI , name, index
const string ARRAY_GET_ELEMENT_FLOAT = "AF"; // AF , name, index
const string ARRAY_SET_ELEMENT = "AS"; // AS , name,
const string ARRAY_ADD_ELEMENT = "AA";
const string ARRAY_REMOVE_ELEMENT = "AR";
const string ARRAY_GET_COUNT = "AT";
const string ARRAY_IS_VALID = "AV"; // AV , name


/************************************/
/* Function prototypes              */
/************************************/

// create a new HashSet on oObject with name sHashSetName
// iSize is optional. HashSetName mmust not contain any exclamation points
int HashSetCreate(string sHashSetName, int iSize = 500);

// Clear and delete sHashSetName on oObject
void HashSetDestroy(string sHashSetName);

// return true if hashset sHashSet is valid
int HashSetValid(string sHashSetName);

// return true if hashset sHashSet contains key sKey
int HashSetKeyExists(string sHashSetName, string sKey);

// Set key sKey of sHashset to string sValue
int HashSetSetLocalString(string sHashSetName, string sKey, string sValue);

// Retrieve string value of sKey in sHashset
string HashSetGetLocalString(string sHashSetName, string sKey);

// Set key sKey of sHashset to integer iValue
int HashSetSetLocalInt(string sHashSetName, string sKey, int iValue);

// Retrieve integer value of sKey in sHashset
int HashSetGetLocalInt(string sHashSetName, string sKey);

// Delete sKey in sHashset
int HashSetDeleteVariable(string sHashSetName, string sKey);

// Return the n-th key in sHashset
// note: this returns the KEY, not the value of the key;
// DEPRECATED for nwnx4;
// string HashSetGetNthKey(string sHashSetName, int i);

// Return the first key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetFirstKey(string sHashSetName);

// Return TRUE if the current key is not the last one, FALSE otherwise
int HashSetHasNextKey(string sHashSetName);

// Return the next key in sHashset
// note: this returns the KEY, not the value of the key;
string HashSetGetNextKey(string sHashSetName);

// Return the first value in sHashset
string HashSetGetFirstValue(string sHashSetName);

// Return TRUE if the current value is not the last one, FALSE otherwise
int HashSetHasNextValue(string sHashSetName);

// Return the next value in sHashset
string HashSetGetNextValue(string sHashSetName);


// Return the number of elements in sHashset
int HashSetGetSize(string sHashSetName);

// This tokenizes the string sData, and prepares each token for matching
// elements in the map  HashSetName.  Use in conjunction with "HashSetGetNextToken"
// This is a tool that khalidine is using to help parse speech text, and may
// be of limited use outside of such applications; however, I figured it was already
// written, so I might as well include it.
// Example usage:
// map named  "Sample" contains key => value as below:
//    "one" => "value one", "two" => "value two", "five" => "value five"
// Code:
//    HashSetTokenize(oPC, "Sample", "The one and only time that two people will meet in one place");
//    string result = HashSetGetNextToken(oPC, "Sample");
//    while (result != "") {
//       SendMessageToPC(oPC, result);
//    }
//  Result:
//     tokenizer splits string into tokens, separators are ", []()"
//     PC receives message: "value one" because the word "one" (first occurrence) is found in map "Sample"
//     PC receives message: "value two" because the word "two" is found in map "Sample"
//     PC receives message: "value one" because the word "one" (second occurrence) is found in map "Sample"
void HashSetTokenize(string sHashSetName, string sData);

// Get next map-lookup value for tokens in sHashSetName, for string declared
// in HashSetTokenize
string HashSetGetNextToken(string sHashSetName);

// Get next map-lookup value for tokens in sHashSetName, for string declared
// in HashSetTokenize
int HashSetGetNextIntToken(string sHashSetName);

int HashSetCreate(string sHashSetName, int iSize = 500)
{
    return NWNXGetInt(HASHSET, HASHSET_CREATE, sHashSetName, iSize);
}

void HashSetDestroy(string sHashSetName)
{
    NWNXGetInt(HASHSET, HASHSET_DESTROY, sHashSetName, 0);
}

int HashSetValid(string sHashSetName)
{
    return NWNXGetInt(HASHSET, HASHSET_IS_VALID, sHashSetName, 0);
}

int HashSetKeyExists(string sHashSetName, string sKey)
{
    return NWNXGetInt(HASHSET, HASHSET_IS_EXISTING, sHashSetName + "|" + sKey, 0);
}

int HashSetSetLocalString(string sHashSetName, string sKey, string sValue)
{
    return NWNXGetInt(HASHSET, HASHSET_INSERT, sHashSetName + "|" + sKey + "|" + sValue, 0);
}

string HashSetGetLocalString(string sHashSetName, string sKey)
{
    return NWNXGetString(HASHSET, HASHSET_LOOKUP, sHashSetName + "|" + sKey, 0);
}

int HashSetSetLocalInt(string sHashSetName, string sKey, int iValue)
{
    return HashSetSetLocalString(sHashSetName, sKey, IntToString(iValue));
}

int HashSetGetLocalInt(string sHashSetName, string sKey)
{
    return StringToInt(HashSetGetLocalString(sHashSetName, sKey));
}

int HashSetDeleteVariable(string sHashSetName, string sKey)
{
    return NWNXGetInt(HASHSET, HASHSET_DELETE, sHashSetName + "|" + sKey, 0);
}

string HashSetGetFirstKey(string sHashSetName)
{
    return NWNXGetString(HASHSET, HASHSET_GET_FIRST_KEY, sHashSetName, 0);
}

string HashSetGetNextKey(string sHashSetName)
{
    return NWNXGetString(HASHSET, HASHSET_GET_NEXT_KEY, sHashSetName, 0);
}

int HashSetHasNextKey(string sHashSetName)
{
    return NWNXGetInt(HASHSET, HASHSET_GET_HAS_NEXT_KEY, sHashSetName, 0);
}

string HashSetGetFirstValue(string sHashSetName)
{
    return NWNXGetString(HASHSET, HASHSET_GET_FIRST_VALUE, sHashSetName, 0);
}

string HashSetGetNextValue(string sHashSetName)
{
    return NWNXGetString(HASHSET, HASHSET_GET_NEXT_VALUE, sHashSetName, 0);
}

int HashSetHasNextValue(string sHashSetName)
{
    return NWNXGetInt(HASHSET, HASHSET_GET_HAS_NEXT_VALUE, sHashSetName, 0);
}

int HashSetGetSize(string sHashSetName)
{
    return NWNXGetInt(HASHSET, HASHSET_GET_SIZE, sHashSetName, 0);
}

// new stuff
int  HashSetCreateFromFile(string sHashSetName, string sFileName, string sSep = ",")
{
    return NWNXGetInt(HASHSET, HASHSET_LOAD_FROM_FILE, sHashSetName + "|" + sFileName + "|" + sSep, 0);
}

void HashSetTokenize(string sTokenizerName, string sData)
{
    NWNXGetInt(HASHSET, HASHSET_TOKENMAP_NEW, sTokenizerName + "|" + sData, 0);

}
string HashSetGetNextToken(string sTokenizerName)
{
    return NWNXGetString(HASHSET, HASHSET_TOKENMAP_NEXT, sTokenizerName, 0);
}

int HashSetGetNextIntToken(string sTokenizerName)
{
    return StringToInt(HashSetGetNextToken(sTokenizerName));
}
//////////////////////////
// Array Functions
//
/// @todo Add option to serialize array to/from file.
/*

const string ARRAY_CREATE = "AC";      // AC , name, size
const string ARRAY_DELETE = "AD";      // AD , name
const string ARRAY_GET_ELEMENT = "AG"; // AG , name, index
const string ARRAY_GET_ELEMENT_INT = "AI"; // AI , name, index
const string ARRAY_GET_ELEMENT_FLOAT = "AF"; // AF , name, index
const string ARRAY_SET_ELEMENT = "AS"; // AS , name,
const string ARRAY_ADD_ELEMENT_= "AA";
const string ARRAY_REMOVE_ELEMENT = "AR";
const string ARRAY_GET_COUNT = "AT";
const string ARRAY_VALID = "AV"; // AV , name

*/
int ArrayCreate(string sArrayName, int nSize = 10)
{
    return NWNXGetInt(HASHSET, ARRAY_CREATE, sArrayName, nSize);
}

int ArrayDelete(string sArrayName)
{
    return NWNXGetInt(HASHSET, ARRAY_DELETE, sArrayName, 0);
}

string ArrayGetStringElement(string sArrayName, int index)
{
    return NWNXGetString(HASHSET, ARRAY_GET_ELEMENT, sArrayName, index);
}
void ArrayAddStringElement(string sArrayName, string sElement)
{
    NWNXSetString(HASHSET, ARRAY_ADD_ELEMENT, sArrayName, 0, sElement);
}

object ArrayGetObjectElement(string sArrayName, int index)
{

    return IntToObject(NWNXGetInt(HASHSET, ARRAY_GET_ELEMENT_INT, sArrayName, index));
}

void ArrayAddObjectElement(string sArrayName, object oElement)
{
    NWNXSetString(HASHSET, ARRAY_ADD_ELEMENT, sArrayName, 0, IntToString(ObjectToInt(oElement)));
}

int ArrayGetIntElement(string sArrayName, int index)
{
    return NWNXGetInt(HASHSET, ARRAY_GET_ELEMENT_INT, sArrayName,  index);
}
void ArrayAddIntElement(string sArrayName, int nElement)
{
    NWNXSetString(HASHSET, ARRAY_ADD_ELEMENT, sArrayName, 0, IntToString(nElement));
}

float ArrayGetFloatElement(string sArrayName, int index)
{
    return NWNXGetFloat(HASHSET, ARRAY_GET_ELEMENT_FLOAT, sArrayName,  index);
}
void ArrayAddFloatElement(string sArrayName, float fElement)
{
    NWNXSetString(HASHSET, ARRAY_ADD_ELEMENT, sArrayName, 0, FloatToString(fElement));
}

int ArrayValid(string sArrayName)
{
    return NWNXGetInt(HASHSET, ARRAY_IS_VALID, sArrayName, 0);
}
int ArrayGetCount(string sArrayName)
{
    return NWNXGetInt(HASHSET, ARRAY_GET_COUNT, sArrayName, 0);
}
// Return 0 if array or element at index does not already exist.
int ArrayRemoveElement(string sArrayName, int index)
{
    return NWNXGetInt(HASHSET, ARRAY_REMOVE_ELEMENT, sArrayName, index);
}
// Returns 0 if array or element at index does not already exist.
void ArraySetElementAt(string sArrayName, string sValue, int index)
{
    NWNXSetString(HASHSET, ARRAY_SET_ELEMENT, sArrayName, index, sValue);
}
// Returns 0 if array or element at index does not already exist.
void ArraySort(string sArrayName, string sValue, int index)
{
    NWNXSetString(HASHSET, ARRAY_SET_ELEMENT, sArrayName, index, sValue);
}


// Removes an object by value by searching through the array.
void ArrayRemoveObjectByValue(string sArrayName, object oObject, int bUnique = TRUE)
 {
     int max = ArrayGetCount(sArrayName) - 1;
     int x;
     object o;
     for (x = max; x >= 0; x--) {
         o = ArrayGetObjectElement(sArrayName, x);
         if (o == oObject) {
             ArrayRemoveElement(sArrayName, x);
             if (!bUnique) {
                 return;

             }
         }
     }
 }


// Adds a unique object to array by first ensuring it's not already present.
/// @todo replace these with nwn2 arrays...
void ArrayAddUniqueObject(string sArrayName, object oObject)
{
    int max = ArrayGetCount(sArrayName);
    int x;
    object o;
    for (x = 0; x < max; x++) {
        o = ArrayGetObjectElement(sArrayName, x);
        if (o == oObject) {
            return;
        }
    }
    ArrayAddObjectElement(sArrayName, oObject);
}

