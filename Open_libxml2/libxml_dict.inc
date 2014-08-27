{
    ------------------------------------------------------------------------------
    Translated into pascal with help of h2pas utility from the FreePascal project.
}

{
 * Summary: string dictionnary
 * Description: dictionary of reusable strings, just used to avoid allocation
 *         and freeing operations.
 *
 * Copy: See Copyright for the status of this software.
 *
 * Author: Daniel Veillard
  }

{
 * The dictionnary.
  }
type
  xmlDict = record
  end;
  xmlDictPtr  = ^xmlDict;
{
 * Initializer
  }

function xmlInitializeDict:longint;cdecl;external LIBXML2_SO;
{
 * Constructor and destructor.
}
function xmlDictCreate:xmlDictPtr;cdecl;external LIBXML2_SO;
function xmlDictSetLimit(dict:xmlDictPtr; limit:longword):longword;cdecl;external LIBXML2_SO;
function xmlDictGetUsage(dict:xmlDictPtr):longword;cdecl;external LIBXML2_SO;
function xmlDictCreateSub(sub:xmlDictPtr):xmlDictPtr;cdecl;external LIBXML2_SO;
function xmlDictReference(dict:xmlDictPtr):longint;cdecl;external LIBXML2_SO;
procedure xmlDictFree(dict:xmlDictPtr);cdecl;external LIBXML2_SO;
{
 * Lookup of entry in the dictionnary.
}
function xmlDictLookup(dict:xmlDictPtr; name:PxmlChar; len:longint):PxmlChar;cdecl;external LIBXML2_SO;
function xmlDictExists(dict:xmlDictPtr; name:PxmlChar; len:longint):PxmlChar;cdecl;external LIBXML2_SO;
function xmlDictQLookup(dict:xmlDictPtr; prefix:PxmlChar; name:PxmlChar):PxmlChar;cdecl;external LIBXML2_SO;
function xmlDictOwns(dict:xmlDictPtr; str:PxmlChar):longint;cdecl;external LIBXML2_SO;
function xmlDictSize(dict:xmlDictPtr):longint;cdecl;external LIBXML2_SO;
{
 * Cleanup function
}
procedure xmlDictCleanup;cdecl;external LIBXML2_SO;

