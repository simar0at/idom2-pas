  {
   * Summary: implementation of the Relax-NG validation
   * Description: implementation of the Relax-NG validation
   *
   * Copy: See Copyright for the status of this software.
   *
   * Author: Daniel Veillard
    }

  type
    xmlRelaxNG = record
	  end;
    xmlRelaxNGPtr = ^xmlRelaxNG;
      {*
   * A schemas validation context
    }
    xmlRelaxNGParserCtxt = record
	  end;
    xmlRelaxNGParserCtxtPtr = ^xmlRelaxNGParserCtxt;
    xmlRelaxNGValidCtxt = record
	  end;
    xmlRelaxNGValidCtxtPtr = ^xmlRelaxNGValidCtxt;
  {*
   * xmlRelaxNGValidityErrorFunc:
   * @ctx: the validation context
   * @msg: the message
   * @...: extra arguments
   *
   * Signature of an error callback from a Relax-NG validation
    }
(* Const before type ignored *)

    xmlRelaxNGValidityErrorFunc = procedure (ctx:xmlRelaxNGValidCtxt; msg:PAnsiChar);cdecl varargs;
  {*
   * xmlRelaxNGValidityWarningFunc:
   * @ctx: the validation context
   * @msg: the message
   * @...: extra arguments
   *
   * Signature of a warning callback from a Relax-NG validation
    }
(* Const before type ignored *)

    xmlRelaxNGValidityWarningFunc = procedure (ctx:xmlRelaxNGValidCtxt; msg:PAnsiChar; args:array of const);cdecl;

  {
   * xmlRelaxNGValidErr:
   *
   * List of possible Relax NG validation errors
    }

    xmlRelaxNGValidErr =  Longint;
    Const
      XML_RELAXNG_OK = 0;
      XML_RELAXNG_ERR_MEMORY = 1;
      XML_RELAXNG_ERR_TYPE = 2;
      XML_RELAXNG_ERR_TYPEVAL = 3;
      XML_RELAXNG_ERR_DUPID = 4;
      XML_RELAXNG_ERR_TYPECMP = 5;
      XML_RELAXNG_ERR_NOSTATE = 6;
      XML_RELAXNG_ERR_NODEFINE = 7;
      XML_RELAXNG_ERR_LISTEXTRA = 8;
      XML_RELAXNG_ERR_LISTEMPTY = 9;
      XML_RELAXNG_ERR_INTERNODATA = 10;
      XML_RELAXNG_ERR_INTERSEQ = 11;
      XML_RELAXNG_ERR_INTEREXTRA = 12;
      XML_RELAXNG_ERR_ELEMNAME = 13;
      XML_RELAXNG_ERR_ATTRNAME = 14;
      XML_RELAXNG_ERR_ELEMNONS = 15;
      XML_RELAXNG_ERR_ATTRNONS = 16;
      XML_RELAXNG_ERR_ELEMWRONGNS = 17;
      XML_RELAXNG_ERR_ATTRWRONGNS = 18;
      XML_RELAXNG_ERR_ELEMEXTRANS = 19;
      XML_RELAXNG_ERR_ATTREXTRANS = 20;
      XML_RELAXNG_ERR_ELEMNOTEMPTY = 21;
      XML_RELAXNG_ERR_NOELEM = 22;
      XML_RELAXNG_ERR_NOTELEM = 23;
      XML_RELAXNG_ERR_ATTRVALID = 24;
      XML_RELAXNG_ERR_CONTENTVALID = 25;
      XML_RELAXNG_ERR_EXTRACONTENT = 26;
      XML_RELAXNG_ERR_INVALIDATTR = 27;
      XML_RELAXNG_ERR_DATAELEM = 28;
      XML_RELAXNG_ERR_VALELEM = 29;
      XML_RELAXNG_ERR_LISTELEM = 30;
      XML_RELAXNG_ERR_DATATYPE = 31;
      XML_RELAXNG_ERR_VALUE = 32;
      XML_RELAXNG_ERR_LIST = 33;
      XML_RELAXNG_ERR_NOGRAMMAR = 34;
      XML_RELAXNG_ERR_EXTRADATA = 35;
      XML_RELAXNG_ERR_LACKDATA = 36;
      XML_RELAXNG_ERR_INTERNAL = 37;
      XML_RELAXNG_ERR_ELEMWRONG = 38;
      XML_RELAXNG_ERR_TEXTWRONG = 39;
  {
   * xmlRelaxNGParserFlags:
   *
   * List of possible Relax NG Parser flags
    }

  type
    xmlRelaxNGParserFlag =  Longint;
    Const
      XML_RELAXNGP_NONE = 0;
      XML_RELAXNGP_FREE_DOC = 1;
      XML_RELAXNGP_CRNG = 2;

  function	    xmlRelaxNGInitTypes:longint; cdecl;external LIBXML2_SO;
  procedure	    xmlRelaxNGCleanupTypes; cdecl;external LIBXML2_SO;
  
  {
   * Interfaces for parsing.
    }
(* Const before type ignored *)

  function xmlRelaxNGNewParserCtxt(URL:PAnsiChar):xmlRelaxNGParserCtxtPtr;cdecl;external LIBXML2_SO;

(* Const before type ignored *)
  function xmlRelaxNGNewMemParserCtxt(buffer:PAnsiChar; size:longint):xmlRelaxNGParserCtxtPtr;cdecl;external LIBXML2_SO;

  function xmlRelaxNGNewDocParserCtxt(doc:xmlDocPtr):xmlRelaxNGParserCtxtPtr;cdecl;external LIBXML2_SO;

  function xmlRelaxParserSetFlag(ctxt:xmlRelaxNGParserCtxtPtr; flag:longint):longint;cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGFreeParserCtxt(ctxt:xmlRelaxNGParserCtxtPtr);cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGSetParserErrors(ctxt:xmlRelaxNGParserCtxtPtr; err:xmlRelaxNGValidityErrorFunc; warn:xmlRelaxNGValidityWarningFunc; userData: Pointer);cdecl;external LIBXML2_SO;

  function xmlRelaxNGGetParserErrors(ctxt:xmlRelaxNGParserCtxtPtr; var err:xmlRelaxNGValidityErrorFunc; var warn:xmlRelaxNGValidityWarningFunc; userData: Pointer):longint;cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGSetParserStructuredErrors(ctxt:xmlRelaxNGParserCtxtPtr; serror:xmlStructuredErrorFunc; userData: Pointer);cdecl;external LIBXML2_SO;

  function xmlRelaxNGParse(ctxt:xmlRelaxNGParserCtxtPtr):xmlRelaxNGPtr;cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGFree(schema:xmlRelaxNGPtr);cdecl;external LIBXML2_SO;

{.$ifdef LIBXML_OUTPUT_ENABLED}
//  procedure xmlRelaxNGDump(var output:FILE; schema:xmlRelaxNGPtr);cdecl;external LIBXML2_SO;

//  procedure xmlRelaxNGDumpTree(var output:FILE; schema:xmlRelaxNGPtr);cdecl;external LIBXML2_SO;

{.$endif}
  { LIBXML_OUTPUT_ENABLED  }
  {
   * Interfaces for validating
    }

  procedure xmlRelaxNGSetValidErrors(ctxt:xmlRelaxNGValidCtxtPtr; err:xmlRelaxNGValidityErrorFunc; warn:xmlRelaxNGValidityWarningFunc; userData: Pointer);cdecl;external LIBXML2_SO;

  function xmlRelaxNGGetValidErrors(ctxt:xmlRelaxNGValidCtxtPtr; var err:xmlRelaxNGValidityErrorFunc; var warn:xmlRelaxNGValidityWarningFunc; userData: Pointer):longint;cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGSetValidStructuredErrors(ctxt:xmlRelaxNGValidCtxtPtr; serror:xmlStructuredErrorFunc; userData: Pointer);cdecl;external LIBXML2_SO;

  function xmlRelaxNGNewValidCtxt(schema:xmlRelaxNGPtr):xmlRelaxNGValidCtxtPtr;cdecl;external LIBXML2_SO;

  procedure xmlRelaxNGFreeValidCtxt(ctxt:xmlRelaxNGValidCtxtPtr);cdecl;external LIBXML2_SO;

  function xmlRelaxNGValidateDoc(ctxt:xmlRelaxNGValidCtxtPtr; doc:xmlDocPtr):longint;cdecl;external LIBXML2_SO;

  {
   * Interfaces for progressive validation when possible
    }
  function xmlRelaxNGValidatePushElement(ctxt:xmlRelaxNGValidCtxtPtr; doc:xmlDocPtr; elem:xmlNodePtr):longint;cdecl;external LIBXML2_SO;

(* Const before type ignored *)
  function xmlRelaxNGValidatePushCData(ctxt:xmlRelaxNGValidCtxtPtr; data:PxmlChar; len:longint):longint;cdecl;external LIBXML2_SO;

  function xmlRelaxNGValidatePopElement(ctxt:xmlRelaxNGValidCtxtPtr; doc:xmlDocPtr; elem:xmlNodePtr):longint;cdecl;external LIBXML2_SO;

  function xmlRelaxNGValidateFullElement(ctxt:xmlRelaxNGValidCtxtPtr; doc:xmlDocPtr; elem:xmlNodePtr):longint;cdecl;external LIBXML2_SO;


