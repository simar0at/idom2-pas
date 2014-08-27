{
    ------------------------------------------------------------------------------
    Translated into pascal with help of h2pas utility from the FreePascal project.
}


  {
   * Summary: interface for the extension support
   * Description: This provide the API needed for simple and module
   *              extension support.
   *
   * Copy: See Copyright for the status of this software.
   *
   * Author: Daniel Veillard
    }

  {*
   * Extension Modules API.
    }
  {*
   * xsltInitGlobals:
   *
   * Initialize the global variables for extensions
   *
    }

  procedure xsltInitGlobals;cdecl;external LIBXSLT_SO;

  {*
   * xsltStyleExtInitFunction:
   * @ctxt:  an XSLT stylesheet
   * @URI:  the namespace URI for the extension
   *
   * A function called at initialization time of an XSLT extension module.
   *
   * Returns a pointer to the module specific data for this transformation.
    }

  type
    PxsltStyleExtInitFunction = ^xsltStyleExtInitFunction;
    xsltStyleExtInitFunction = function (style:xsltStylesheetPtr; URI:PxmlChar):pointer;cdecl;
  {*
   * xsltStyleExtShutdownFunction:
   * @ctxt:  an XSLT stylesheet
   * @URI:  the namespace URI for the extension
   * @data:  the data associated to this module
   *
   * A function called at shutdown time of an XSLT extension module.
    }

    xsltStyleExtShutdownFunction = procedure (style:xsltStylesheetPtr; URI:PxmlChar; var data:pointer);cdecl;
  {*
   * xsltExtInitFunction:
   * @ctxt:  an XSLT transformation context
   * @URI:  the namespace URI for the extension
   *
   * A function called at initialization time of an XSLT extension module.
   *
   * Returns a pointer to the module specific data for this transformation.
    }

    PxsltExtInitFunction = ^xsltExtInitFunction;
    xsltExtInitFunction = function (ctxt:xsltTransformContextPtr; URI:PxmlChar):pointer;cdecl;
  {*
   * xsltExtShutdownFunction:
   * @ctxt:  an XSLT transformation context
   * @URI:  the namespace URI for the extension
   * @data:  the data associated to this module
   *
   * A function called at shutdown time of an XSLT extension module.
    }

    xsltExtShutdownFunction = procedure (ctxt:xsltTransformContextPtr; URI:PxmlChar; var data:pointer);cdecl;

  function xsltRegisterExtModule(URI:PxmlChar; initFunc:xsltExtInitFunction; shutdownFunc:xsltExtShutdownFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltRegisterExtModuleFull(URI:PxmlChar; initFunc:xsltExtInitFunction; shutdownFunc:xsltExtShutdownFunction; styleInitFunc:xsltStyleExtInitFunction; styleShutdownFunc:xsltStyleExtShutdownFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltUnregisterExtModule(URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  function xsltGetExtData(ctxt:xsltTransformContextPtr; URI:PxmlChar):pointer;cdecl;external LIBXSLT_SO;

  function xsltStyleGetExtData(style:xsltStylesheetPtr; URI:PxmlChar):pointer;cdecl;external LIBXSLT_SO;

  function xsltStyleStylesheetLevelGetExtData(style:xsltStylesheetPtr; URI:PxmlChar):pointer;cdecl;external LIBXSLT_SO;

  procedure xsltShutdownCtxtExts(ctxt:xsltTransformContextPtr);cdecl;external LIBXSLT_SO;

  procedure xsltShutdownExts(style:xsltStylesheetPtr);cdecl;external LIBXSLT_SO;

  function xsltXPathGetTransformContext(ctxt:xmlXPathParserContextPtr):xsltTransformContextPtr;cdecl;external LIBXSLT_SO;

  {
   * extension functions
   }
   
  function xsltRegisterExtModuleFunction(name:PxmlChar; URI:PxmlChar; _function:xmlXPathFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltExtModuleFunctionLookup(name:PxmlChar; URI:PxmlChar):xmlXPathFunction;cdecl;external LIBXSLT_SO;

  function xsltUnregisterExtModuleFunction(name:PxmlChar; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  {
   * extension elements
    }

  type

    xsltPreComputeFunction = function (style:xsltStylesheetPtr; inst:xmlNodePtr; _function:xsltTransformFunction):xsltElemPreCompPtr;cdecl;

  function xsltNewElemPreComp(style:xsltStylesheetPtr; inst:xmlNodePtr; _function:xsltTransformFunction):xsltElemPreCompPtr;cdecl;external LIBXSLT_SO;

  procedure xsltInitElemPreComp(comp:xsltElemPreCompPtr; style:xsltStylesheetPtr; inst:xmlNodePtr; _function:xsltTransformFunction; freeFunc:xsltElemPreCompDeallocator);cdecl;external LIBXSLT_SO;

  function xsltRegisterExtModuleElement(name:PxmlChar; URI:PxmlChar; precomp:xsltPreComputeFunction; transform:xsltTransformFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltExtElementLookup(ctxt:xsltTransformContextPtr; name:PxmlChar; URI:PxmlChar):xsltTransformFunction;cdecl;external LIBXSLT_SO;

  function xsltExtModuleElementLookup(name:PxmlChar; URI:PxmlChar):xsltTransformFunction;cdecl;external LIBXSLT_SO;

  function xsltExtModuleElementPreComputeLookup(name:PxmlChar; URI:PxmlChar):xsltPreComputeFunction;cdecl;external LIBXSLT_SO;

  function xsltUnregisterExtModuleElement(name:PxmlChar; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  {
   * top-level elements
    }

  type

    xsltTopLevelFunction = procedure (style:xsltStylesheetPtr; inst:xmlNodePtr);cdecl;

  function xsltRegisterExtModuleTopLevel(name:PxmlChar; URI:PxmlChar; _function:xsltTopLevelFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltExtModuleTopLevelLookup(name:PxmlChar; URI:PxmlChar):xsltTopLevelFunction;cdecl;external LIBXSLT_SO;

  function xsltUnregisterExtModuleTopLevel(name:PxmlChar; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  { These 2 functions are deprecated for use within modules.  }
  function xsltRegisterExtFunction(ctxt:xsltTransformContextPtr; name:PxmlChar; URI:PxmlChar; _function:xmlXPathFunction):longint;cdecl;external LIBXSLT_SO;

  function xsltRegisterExtElement(ctxt:xsltTransformContextPtr; name:PxmlChar; URI:PxmlChar; _function:xsltTransformFunction):longint;cdecl;external LIBXSLT_SO;

  {
   * Extension Prefix handling API.
   * Those are used by the XSLT (pre)processor.
    }
  function xsltRegisterExtPrefix(style:xsltStylesheetPtr; prefix:PxmlChar; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  function xsltCheckExtPrefix(style:xsltStylesheetPtr; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  function xsltCheckExtURI(style:xsltStylesheetPtr; URI:PxmlChar):longint;cdecl;external LIBXSLT_SO;

  function xsltInitCtxtExts(ctxt:xsltTransformContextPtr):longint;cdecl;external LIBXSLT_SO;

  procedure xsltFreeCtxtExts(ctxt:xsltTransformContextPtr);cdecl;external LIBXSLT_SO;

  procedure xsltFreeExts(style:xsltStylesheetPtr);cdecl;external LIBXSLT_SO;

  function xsltPreComputeExtModuleElement(style:xsltStylesheetPtr; inst:xmlNodePtr):xsltElemPreCompPtr;cdecl;external LIBXSLT_SO;

  {
   * Extension Infos access.
   * Used by exslt initialisation
    }
  function xsltGetExtInfo(style:xsltStylesheetPtr; URI:PxmlChar):xmlHashTablePtr;cdecl;external LIBXSLT_SO;

  {*
   * Test module http://xmlsoft.org/XSLT/
    }
  procedure xsltRegisterTestModule;cdecl;external LIBXSLT_SO;

//  procedure xsltDebugDumpExtensions(var output:FILE);cdecl;external LIBXSLT_SO;


