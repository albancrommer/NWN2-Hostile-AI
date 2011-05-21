// Name     : NWNX Utility Include
// Purpose  : Various utility functions
// Authors  : Marc Paradise (Grinning Fool)
// Modified : December 14th, 2006

// This file is licensed under the terms of the
// GNU GENERAL PUBLIC LICENSE (GPL) Version 2
/************************************/
/* Function prototypes              */
/************************************/
const int MT_EVENT = 0;
const int MT_TELL  = 1;
const int MT_SPEECH = 2;
const int MT_DM     = 3;
const int MT_DEATH  = 4;
const int MT_RAISE  = 5;

int UtilCreateTokenizer(string tokenizerName, string data, string delimiters = " ");

int UtilDeleteTokenizer(string tokenizerName);

string UtilGetNextToken(string tokenizerName);

string UtilGetTokenRemainder(string tokenizerName);

int UtilGetNextIntToken(string tokenizerName);
int UtilGetTokenCount(string tokenizerName);

int UtilCreateTokenizedArray(string tokenizerName, string data, string delimiters = " ");

int UtilDeleteTokenizedArray(string tokenizerName);

int UtilDeleteTokenFromArrayAt(string tokenizerName, int index);
string UtilGetTokenFromArrayAt(string tokenizerName, int index);

int UtilGetIntTokenFromArrayAt(string tokenizerName, int index);

int  UtilGetTokenArraySize(string tokenizerName);
string UtilTranslateToLanguage(int languageId, string text);
int UtilInitLanguage(string filename);
void UtilSendStringToIRC(string message);


/** Gets a random number.
 * Returns a random number between 0 and nMax-1
 * @param nMax the upper limit of the random number to retrieve.
 * @return Random number between 0 and nMax-1
 */
int UtilGetRandom(int nMax);
/** Gets current time.
 * Returns time as an int.
 * @return number of seconds since epoc
 */
int UtilGetTime();

/*
NWNXGetInt:
    TC // create tokenizer, name|data|delim
    TX // delete tokenizer, name
    TI // next INT elt in tok, name (as int)
    TN // num elements in tok, name

    AC   // createarray, name|data|delim
    AX // delete array
    AI // getinttoken from array, name, index
    AD // delete token from array at : mame,index
    AN // get token array szie, name

    LI // init language, filename



NWNXGetString
    TG // get next STR elt in toklist:   name, index
    TR // get remainder :  name

    AG // get at array element : nId
    LT // translate langage: nId, text to translate

NWNXSetString
    IS // send VALUE to irc

/************************************/
/* Implementation                   */
/************************************/

int UtilCreateTokenizer(string tokenizerName, string data, string delimiters)
{
    return NWNXGetInt("UTIL", "TC", tokenizerName + "|" + delimiters + "|" + data, 0);
}
int UtilDeleteTokenizer(string tokenizerName)
{
    return NWNXGetInt("UTIL", "TX", tokenizerName, 0);
}
string UtilGetNextToken(string tokenizerName)
{
    return NWNXGetString("UTIL", "TG", tokenizerName, 0);
}
string UtilGetTokenRemainder(string tokenizerName)
{
    return NWNXGetString("UTIL", "TR", tokenizerName, 0);
}
int UtilGetNextIntToken(string tokenizerName)
{
    return NWNXGetInt("UTIL", "TI", tokenizerName, 0);
}
int UtilGetTokenCount(string tokenizerName)
{
    return NWNXGetInt("UTIL", "TN", tokenizerName, 0);
}
int UtilCreateTokenizedArray(string tokenizerName, string data, string delimiters = " ")
{
    return NWNXGetInt("UTIL", "AC", tokenizerName + "|" + delimiters + "|" + data, 0);
}
int UtilDeleteTokenizedArray(string tokenizerName)
{
    return NWNXGetInt("UTIL", "AX", tokenizerName, 0);
}
string UtilGetTokenFromArrayAt(string tokenizerName, int index)
{
    return NWNXGetString("UTIL", "AG", tokenizerName, index);
}
int UtilGetIntTokenFromArrayAt(string tokenizerName, int index)
{
    return NWNXGetInt("UTIL", "AI", tokenizerName, index);
}
int UtilGetTokenArraySize(string tokenizerName)
{
    return NWNXGetInt("UTIL", "AN", tokenizerName, 0);

}
int UtilRemoveFromArrayAt(string tokenizerName, int index)
{
    return NWNXGetInt("UTIL", "AD", tokenizerName, index);
}
void UtilLanguageInit(int nCount)
{
    NWNXSetInt("UTIL", "LI", "", 0, nCount);
}
void UtilLanguageAdd(int languageId, string sTranslationString)
{
    NWNXSetString("UTIL", "LA", "", languageId, sTranslationString);
}

string UtilTranslateToLanguage(int languageId, string text)
{
    return NWNXGetString("UTIL", "LT", text, languageId);
}

void IRCConnect(string server, string nick)
{
//    NWNXSetString("UTIL", "II", server, 0, nick);
}
void IRCJoin(string channel)
{
    //NWNXSetString("UTIL", "IJ", "", 0, channel);

}
void IRCSendMessage(string channel, int nType, string message)
{
   //NWNXSetString("UTIL", "IM", channel, nType, message);
}


int UtilGetTime()
{
    return NWNXGetInt("UTIL", "TM", "", 0);
}

int UtilGetRandom(int nMax)
{
    return NWNXGetInt("UTIL", "RN", IntToString(nMax), 0);

}