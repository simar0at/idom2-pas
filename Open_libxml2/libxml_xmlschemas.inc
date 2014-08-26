{
 * Summary: incomplete XML Schemas structure implementation
 * Description: interface to the XML Schemas handling and schema validity
 *              checking, it is incomplete right now.
 *
 * Copy: See Copyright for the status of this software.
 *
 * Author: Daniel Veillard
  }

{*
 * This error codes are obsolete; not used any more.
  }
type
  xmlSchemaValidError =  Longint;
  Const
    XML_SCHEMAS_ERR_OK = 0;
    XML_SCHEMAS_ERR_NOROOT = 1;
    XML_SCHEMAS_ERR_UNDECLAREDELEM = 2;
    XML_SCHEMAS_ERR_NOTTOPLEVEL = 3;
    XML_SCHEMAS_ERR_MISSING = 4;
    XML_SCHEMAS_ERR_WRONGELEM = 5;
    XML_SCHEMAS_ERR_NOTYPE = 6;
    XML_SCHEMAS_ERR_NOROLLBACK = 7;
    XML_SCHEMAS_ERR_ISABSTRACT = 8;
    XML_SCHEMAS_ERR_NOTEMPTY = 9;
    XML_SCHEMAS_ERR_ELEMCONT = 10;
    XML_SCHEMAS_ERR_HAVEDEFAULT = 11;
    XML_SCHEMAS_ERR_NOTNILLABLE = 12;
    XML_SCHEMAS_ERR_EXTRACONTENT = 13;
    XML_SCHEMAS_ERR_INVALIDATTR = 14;
    XML_SCHEMAS_ERR_INVALIDELEM = 15;
    XML_SCHEMAS_ERR_NOTDETERMINIST = 16;
    XML_SCHEMAS_ERR_CONSTRUCT = 17;
    XML_SCHEMAS_ERR_INTERNAL = 18;
    XML_SCHEMAS_ERR_NOTSIMPLE = 19;
    XML_SCHEMAS_ERR_ATTRUNKNOWN = 20;
    XML_SCHEMAS_ERR_ATTRINVALID = 21;
    XML_SCHEMAS_ERR_VALUE = 22;
    XML_SCHEMAS_ERR_FACET = 23;
    XML_SCHEMAS_ERR_ = 24;
    XML_SCHEMAS_ERR_XXX = 25;
{
* ATTENTION: Change xmlSchemaSetValidOptions's check
* for invalid values, if adding to the validation
* options below.
 }
{*
 * xmlSchemaValidOption:
 *
 * This is the set of XML Schema validation options.
  }
{ Default/fixed: create an attribute node
	* or an element's text node on the instance.
	 }
type
  xmlSchemaValidOption =  Longint;
  Const
    XML_SCHEMA_VAL_VC_I_CREATE = 1 shl 0;
{
	XML_SCHEMA_VAL_XSI_ASSEMBLE = 1 shl 1;
	* assemble schemata using
	* xsi:schemaLocation and
	* xsi:noNamespaceSchemaLocation
 }
{*
 * The schemas related types are kept internal
  }
type
  xmlSchema = record
  end;
  xmlSchemaParserCtxt = record
  end;
  xmlSchemaValidCtxt = record
  end;

  xmlSchemaPtr = ^xmlSchema;

{*
 * A schemas validation context
  }
  
  xmlSchemaParserCtxtPtr = ^xmlSchemaParserCtxt;
  xmlSchemaValidCtxtPtr = ^xmlSchemaValidCtxt;
{*
 * xmlSchemaValidityErrorFunc:
 * @ctx: the validation context
 * @msg: the message
 * @...: extra arguments
 *
 * Signature of an error callback from an XSD validation
  }
(* Const before type ignored *)

  xmlSchemaValidityErrorFunc = procedure (ctx:xmlSchemaValidCtxtPtr; msg:PAnsiChar);cdecl varargs;
{*
 * xmlSchemaValidityWarningFunc:
 * @ctx: the validation context
 * @msg: the message
 * @...: extra arguments
 *
 * Signature of a warning callback from an XSD validation
  }
(* Const before type ignored *)

  xmlSchemaValidityWarningFunc = procedure (ctx:xmlSchemaValidCtxtPtr; msg:PAnsiChar);cdecl varargs;

{*
 * xmlSchemaValidityLocatorFunc:
 * @ctx: user provided context
 * @file: returned file information
 * @line: returned line information
 *
 * A schemas validation locator, a callback called by the validator.
 * This is used when file or node informations are not available
 * to find out what file and line number are affected
 *
 * Returns: 0 in case of success and -1 in case of error
  }
(* Const before type ignored *)

  xmlSchemaValidityLocatorFunc = function (ctx:xmlSchemaValidCtxtPtr; var file_:PAnsiChar; var line:longword):longint;cdecl;
{
 * Interfaces for parsing.
  }
(* Const before type ignored *)

function xmlSchemaNewParserCtxt(URL:PAnsiChar):xmlSchemaParserCtxtPtr;cdecl;external LIBXML2_SO;
(* Const before type ignored *)
function xmlSchemaNewMemParserCtxt(buffer:PAnsiChar; size:longint):xmlSchemaParserCtxtPtr;cdecl;external LIBXML2_SO;
function xmlSchemaNewDocParserCtxt(doc:xmlDocPtr):xmlSchemaParserCtxtPtr;cdecl;external LIBXML2_SO;
procedure xmlSchemaFreeParserCtxt(ctxt:xmlSchemaParserCtxtPtr);cdecl;external LIBXML2_SO;
procedure xmlSchemaSetParserErrors(ctxt:xmlSchemaParserCtxtPtr; err:xmlSchemaValidityErrorFunc; warn:xmlSchemaValidityWarningFunc; userData: Pointer);cdecl;external LIBXML2_SO;
procedure xmlSchemaSetParserStructuredErrors(ctxt:xmlSchemaParserCtxtPtr; serror:xmlStructuredErrorFunc; userData: Pointer);cdecl;external LIBXML2_SO;
function xmlSchemaGetParserErrors(ctxt:xmlSchemaParserCtxtPtr; var err:xmlSchemaValidityErrorFunc; var warn:xmlSchemaValidityWarningFunc; userData: Pointer):longint;cdecl;external LIBXML2_SO;
function xmlSchemaIsValid(ctxt:xmlSchemaValidCtxtPtr):longint;cdecl;external LIBXML2_SO;
function xmlSchemaParse(ctxt:xmlSchemaParserCtxtPtr):xmlSchemaPtr;cdecl;external LIBXML2_SO;
procedure xmlSchemaFree(schema:xmlSchemaPtr);cdecl;external LIBXML2_SO;
{.$ifdef LIBXML_OUTPUT_ENABLED}
{procedure xmlSchemaDump(var output:FILE; schema:xmlSchemaPtr);cdecl;external LIBXML2_SO;}
{.$endif}
{ LIBXML_OUTPUT_ENABLED  }
{
 * Interfaces for validating
  }

procedure xmlSchemaSetValidErrors(ctxt:xmlSchemaValidCtxtPtr; err:xmlSchemaValidityErrorFunc; warn:xmlSchemaValidityWarningFunc; userData: Pointer);cdecl;external LIBXML2_SO;
procedure xmlSchemaSetValidStructuredErrors(ctxt:xmlSchemaValidCtxtPtr; serror:xmlStructuredErrorFunc; userData: Pointer);cdecl;external LIBXML2_SO;
function xmlSchemaGetValidErrors(ctxt:xmlSchemaValidCtxtPtr; var err:xmlSchemaValidityErrorFunc; var warn:xmlSchemaValidityWarningFunc; userData: Pointer):longint;cdecl;external LIBXML2_SO;
function xmlSchemaSetValidOptions(ctxt:xmlSchemaValidCtxtPtr; options:longint):longint;cdecl;external LIBXML2_SO;
(* Const before type ignored *)
procedure xmlSchemaValidateSetFilename(vctxt:xmlSchemaValidCtxtPtr; filename:PAnsiChar);cdecl;external LIBXML2_SO;
function xmlSchemaValidCtxtGetOptions(ctxt:xmlSchemaValidCtxtPtr):longint;cdecl;external LIBXML2_SO;
function xmlSchemaNewValidCtxt(schema:xmlSchemaPtr):xmlSchemaValidCtxtPtr;cdecl;external LIBXML2_SO;
procedure xmlSchemaFreeValidCtxt(ctxt:xmlSchemaValidCtxtPtr);cdecl;external LIBXML2_SO;
function xmlSchemaValidateDoc(ctxt:xmlSchemaValidCtxtPtr; instance:xmlDocPtr):longint;cdecl;external LIBXML2_SO;
function xmlSchemaValidateOneElement(ctxt:xmlSchemaValidCtxtPtr; elem:xmlNodePtr):longint;cdecl;external LIBXML2_SO;
function xmlSchemaValidateStream(ctxt:xmlSchemaValidCtxtPtr; input:xmlParserInputBufferPtr; enc:xmlCharEncoding; sax:xmlSAXHandlerPtr; var user_data:pointer):longint;cdecl;external LIBXML2_SO;
(* Const before type ignored *)
function xmlSchemaValidateFile(ctxt:xmlSchemaValidCtxtPtr; filename:PAnsiChar; options:longint):longint;cdecl;external LIBXML2_SO;
function xmlSchemaValidCtxtGetParserCtxt(ctxt:xmlSchemaValidCtxtPtr):xmlParserCtxtPtr;cdecl;external LIBXML2_SO;
{
 * Interface to insert Schemas SAX validation in a SAX stream
  }
type
  xmlSchemaSAXPlug = record
  end;
  xmlSchemaSAXPlugPtr = ^xmlSchemaSAXPlug;

//function xmlSchemaSAXPlug(ctxt:xmlSchemaValidCtxtPtr; var sax:xmlSAXHandlerPtr; var user_data:pointer):xmlSchemaSAXPlugPtr;cdecl;external LIBXML2_SO;
function xmlSchemaSAXUnplug(plug:xmlSchemaSAXPlugPtr):longint;cdecl;external LIBXML2_SO;
procedure xmlSchemaValidateSetLocator(vctxt:xmlSchemaValidCtxtPtr; f:xmlSchemaValidityLocatorFunc; userData: Pointer);cdecl;external LIBXML2_SO;

