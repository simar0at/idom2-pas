{
    ------------------------------------------------------------------------------
    Translated into pascal with help of h2pas utility from the FreePascal project.
}

  {
   * Summary: interface for the document handling
   * Description: implements document loading and cache (multiple
   *              document() reference for the same resources must
   *              be equal.
   *
   * Copy: See Copyright for the status of this software.
   *
   * Author: Daniel Veillard
    }

  function xsltNewDocument(ctxt:xsltTransformContextPtr; doc:xmlDocPtr):xsltDocumentPtr;cdecl;external LIBXSLT_SO;
  function xsltLoadDocument(ctxt:xsltTransformContextPtr; URI:PxmlChar):xsltDocumentPtr;cdecl;external LIBXSLT_SO;
  function xsltFindDocument(ctxt:xsltTransformContextPtr; doc:xmlDocPtr):xsltDocumentPtr;cdecl;external LIBXSLT_SO;
  procedure xsltFreeDocuments(ctxt:xsltTransformContextPtr);cdecl;external LIBXSLT_SO;
  function xsltLoadStyleDocument(style:xsltStylesheetPtr; URI:PxmlChar):xsltDocumentPtr;cdecl;external LIBXSLT_SO;
  function xsltNewStyleDocument(style:xsltStylesheetPtr; doc:xmlDocPtr):xsltDocumentPtr;cdecl;external LIBXSLT_SO;
  procedure xsltFreeStyleDocuments(style:xsltStylesheetPtr);cdecl;external LIBXSLT_SO;

  {
   * Hooks for document loading
    }
  {*
   * xsltLoadType:
   *
   * Enum defining the kind of loader requirement.
    }
  { loading for a top stylesheet  }
  { loading for a stylesheet include/import  }
  { loading document at transformation time  }

  type
    xsltLoadType =  Longint;
    Const
      XSLT_LOAD_START = 0;
      XSLT_LOAD_STYLESHEET = 1;
      XSLT_LOAD_DOCUMENT = 2;

  {*
   * xsltDocLoaderFunc:
   * @URI: the URI of the document to load
   * @dict: the dictionary to use when parsing that document
   * @options: parsing options, a set of xmlParserOption
   * @ctxt: the context, either a stylesheet or a transformation context
   * @type: the xsltLoadType indicating the kind of loading required
   *
   * An xsltDocLoaderFunc is a signature for a function which can be
   * registered to load document not provided by the compilation or
   * transformation API themselve, for example when an xsl:import,
   * xsl:include is found at compilation time or when a document()
   * call is made at runtime.
   *
   * Returns the pointer to the document (which will be modified and
   * freed by the engine later), or NULL in case of error.
    }
  type
    PxsltDocLoaderFunc = ^xsltDocLoaderFunc;
    xsltDocLoaderFunc = function (URI:PxmlChar; dict:xmlDictPtr; options:longint; ctxt:pointer; _type:xsltLoadType):xmlDocPtr;cdecl;

  procedure xsltSetLoaderFunc(f:xsltDocLoaderFunc);cdecl;external LIBXSLT_SO;

