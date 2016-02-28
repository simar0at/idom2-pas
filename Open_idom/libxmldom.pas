unit libxmldom;

{
  ------------------------------------------------------------------------------
   This unit is an object-oriented wrapper for libxml2.
   It implements the interfaces defined in idom2.pas and idom2_ext.pas .

   Original author:
   Uwe Fechner <ufechner@4commerce.de>

   Contributers:
   Martijn Brinkers   <m.brinkers@pobox.com>
   Petr Kozelka       <pkozelka@centrum.cz>
   Thomas Freudenberg <th.freudenberg@4commerce.de>
   Marco Voetberg     <marco@dqd.nl>
   Daniel Rikowski

   Thanks to the gdome2 project, where I got many ideas from.
   (see: http://phd.cs.unibo.it/gdome2/)

   Thanks to Jan Kubatzki for testing.

   | The routines for testing XML rules were taken from the Extended Document
   | Object Model (XDOM) package, copyright (c) 1999-2002 by Dieter Köhler.
   | The latest XDOM version is available at "http://www.philo.de/xml/" under
   | a different open source license.  In addition, the author gave permission
   | to use the routines for testing XML rules included in this file under the
   | terms of either MPL 1.1, GPL 2.0 or LGPL 2.1.


   Copyright:
   4commerce technologies AG
   Kamerbalken 10-14
   22525 Hamburg, Germany

   http://www.4commerce.de

   Published under a double license:
   a) the GNU Library General Public License:
      http://www.gnu.org/copyleft/lgpl.html
   b) the Mozilla Public License:
      http://www.mozilla.org/MPL/MPL-1.1.html
  ------------------------------------------------------------------------------
}

  // Partly supported by libxml2:
  // IDomPersist
  // (asynchron parsing of xml files/ strings is not supported)

interface


uses
{$ifdef VER130} // Delphi 5
  jclUnicode,   // UTF8Encode and UTF8Decode
{$else}
  StrUtils,
{$endif}
  classes,
  idom2,
  idom2_ext,
  libxml2,
  libxslt,
  sysutils;

const

  SLIBXML = 'LIBXML_4CT';  { Do not localize }

type
  { IXmlDomDocRef }

  (*
   * IXmlDomDocRef is an interface that can be implemented by any object
   * that has a corresponding c-struct in libxml2 representing an xml-doc-node.
   * implemented by TDomDocument.
   *)

  IXmlDomDocRef = interface
    ['{86A9F11A-3AA5-4111-B860-CA60D4FA3ACA}']
    function GetXmlDocPtr: xmlDocPtr;
  end;

  { IXmlDomNodeRef }

  (*
   * IXmlDomNodeRef is an interface that can be implemented by any object
   * that has a corresponding c-struct in libxml2 representing an xml-node.
   * implemented by TDomNode.
   * It cannot be in the unit idom2_ext, because it uses the type xmlNodePtr,
   * that is defined in libxml2.
   *)

  IXmlDomNodeRef = interface
    ['{7787A532-C8C8-4F3C-9529-29098FE954B0}']
    function GetXmlNodePtr: xmlNodePtr;
  end;

  IXmlDomAttrOwnerRef = interface
    ['{0E981036-C8B6-4202-8830-13344B115D0D}']
    function GetXmlAttrOwnerPtr: xmlNodePtr;
  end;

(*
 * same as GetXmlNodePtr of IXmlDomNodeRef, but declared as function and
 * additional error-check
 *)
function GetXmlNode(const Node: IDomNode): xmlNodePtr;

(*
 * creates an IDomDocument from a xmlDocPtr (libxml2 representation of
 * a document)
 *)
function MakeDocument(doc: xmlDocPtr; impl: IDomImplementation): IDomDocument;

(*
 * same as GetXmlDocPtr of IXmlDomDocRef, but declared as function and
 * additional error-check
 *)
function GetXmlDoc(const Doc: IDomDocument): xmlDocPtr;

(*
 * create an IDomImplementation based on TDomImplementation Object
 *
 *)
function newDomImplementation: IDomImplementation;

(*
 * Same as IsSameNode of IDomNodeCompare, but declared as function
 * and works correctly, if any of the nodes is nil.
 * It is neccessary to use it with libxml2, because there can be
 * several interfaces pointing to the same node.
 *)
function IsSameNode(node1, node2: IDomNode): boolean;

implementation

type
  { TDomImplementation }

  TDomImplementation = class(TInterfacedObject, IDomImplementation,IDomDebug)
  private
    fDoccount: integer;  // number of living documents, created with this
                         // implementation. For debugging purposes only.
  protected
    { IDomImplementation }
    function hasFeature(const feature, version: DOMString): boolean;
    function createDocumentType(const qualifiedName, publicId,
      systemId: DOMString): IDomDocumentType;
    function createDocument(const namespaceURI, qualifiedName: DOMString;
      doctype: IDomDocumentType): IDomDocument;
    { IDomDebug }
    procedure set_doccount(doccount: integer);
    function get_doccount: integer;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  // used for creation of classes from libxml2-nodes
  TDomNodeClass = class of TDomNode;

  TDomNode = class(TInterfacedObject, IDomNode, IXMLDOMNodeRef, IDomNodeSelect,
      IDomNodeEx, IDomNodeEx2, IDomNodeCompare)
  private
    // this field helps to manage the lifetime of the OwnerDocument:
    // the document won't be freed, as long as a node exists, that
    // references it (RefCount>0)
    fXmlNode:       xmlNodePtr;    //reference to the corresponding c-struct
    fOwnerDocument: IDomDocument;  //reference to the owner document

  protected
    { for internal use within this unit only}
    function IsReadOnly: boolean;
    function IsAncestorOrSelf(newNode: xmlNodePtr): boolean;
    function Get_ExposeNsDefAttribs: boolean;
    { IDomNode }
    function get_nodeName: DOMString;
    function get_nodeValue: DOMString;
    procedure set_nodeValue(const Value: DOMString);
    function get_nodeType: DOMNodeType;
    function get_parentNode: IDomNode;
    function get_childNodes: IDomNodeList;
    function get_firstChild: IDomNode;
    function get_lastChild: IDomNode;
    function get_previousSibling: IDomNode;
    function get_nextSibling: IDomNode;
    function get_attributes: IDomNamedNodeMap;
    function get_ownerDocument: IDomDocument;
    function get_ownerOrSelf: IDomDocument;
    function get_namespaceURI: DOMString;
    function get_prefix: DOMString;
    procedure set_Prefix(const prefix: DomString);
    function get_localName: DOMString;
    function insertBefore(const newChild, refChild: IDomNode): IDomNode;
    function replaceChild(const newChild, oldChild: IDomNode): IDomNode;
    function removeChild(const childNode: IDomNode): IDomNode;
    function appendChild(const newChild: IDomNode): IDomNode;
    function hasChildNodes: boolean;
    function hasAttributes: boolean;
    function cloneNode(deep: boolean): IDomNode;
    procedure normalize;
    function IsSupported(const feature, version: DOMString): boolean;
    { IXmlDomNodeRef }
    function GetXmlNodePtr: xmlNodePtr;
    { IDomNodeSelect }
    function selectNode(const nodePath: DOMString): IDomNode;
    function selectNodes(const nodePath: DOMString): IDomNodeList;
    { IDomNodeEx }
    procedure transformNode(const stylesheet: IDomNode; var output: DomString); overload;
    procedure transformNode(const stylesheet: IDomNode; const output: IDomDocument); overload;
    function get_text: DomString;
    procedure set_text(const Value: DomString);
    function get_xml: DOMString;
    { IDomNodeCompare }
    function IsSameNode(node: IDomNode): boolean;
    { IDomNodeEx2}
    procedure RegisterNS(const prefix, URI: DomString);
  public
    constructor Create(ANode: xmlNodePtr; ADocument: IDomDocument);
    destructor Destroy; override;
    property xmlNode: xmlNodePtr read fXmlNode;
  end;

  TDomNodeList = class(TInterfacedObject, IDomNodeList, IDomNodeListExt)
  private
    fParent: xmlNodePtr;               // if we have a list like node.childnodes,
                                       // the parent node is stored here
    fXPathObject: xmlXPathObjectPtr;   // if we have a list, that is the result of
                                       // an xpath query, the xmlXPathObjectPtr is
                                       // stored here
    fOwnerDocument: IDomDocument;
  protected
    { IDomNodeList }
    function get_item(index: integer): IDomNode;
    function get_length: integer;
    { IDomNodeListExt }
    function get_xml: DomString;
  public
    constructor Create(AParent: xmlNodePtr; ADocument: IDomDocument); overload;
    constructor Create(AXpathObject: xmlXPathObjectPtr; ADocument: IDomDocument); overload;
    destructor Destroy; override;
  end;

  TDomNamedNodeMapType = (nnmAttributes, nnmEntities, nnmNotations);

  TDomNamedNodeMap = class(TInterfacedObject, IDomNamedNodeMap)
    // this class is used for attributes, entities and notations
  private
    fnnmType: TDomNamedNodeMapType;  // the type of the namedNodeMap
    fOwnerElement:   xmlNodePtr;     // the parent element of attribute lists
    fElement:        xmlElementPtr;  // the description of the parent element in the dtd
    fXmlInternalDtd: xmlDtdPtr;      // entities/notations of an internal DTD
    fXmlExternalDtd: xmlDtdPtr;      // entities/notations of an external DTD
    fOwnerDocument:  IDomDocument;
  protected
    { internal }
    function get_xmlAttributes: xmlNodePtr;
    { IDomNamedNodeMap }
    function get_item(index: integer): IDomNode;
    function get_length: integer;
    function getNamedItem(const Name: DOMString): IDomNode;
    function setNamedItem(const newItem: IDomNode): IDomNode;
    function removeNamedItem(const Name: DOMString): IDomNode;
    function getNamedItemNS(const namespaceURI, localName: DOMString): IDomNode;
    function setNamedItemNS(const newItem: IDomNode): IDomNode;
    function removeNamedItemNS(const namespaceURI, localName: DOMString): IDomNode;
  public
    constructor Create(ANamedNodeMap: xmlNodePtr; AOwnerDocument: IDomDocument;
      typ: TDomNamedNodeMapType = nnmAttributes; externalDtd: xmlDtdPtr = nil);
    destructor Destroy; override;
  end;

  { TDomAttr }

  TDomAttr = class(TDomNode, IDomAttr, IXmlDomAttrOwnerRef)
  private
    fOwnerElement: xmlNodePtr; //this is needed for default attributes
    function getXmlAttribute: xmlAttrPtr;
  protected
    { Property Get/Set }
    function get_name: DOMString;
    function get_specified: boolean;
    function get_value: DOMString;
    procedure set_value(const attributeValue: DOMString);
    function get_ownerElement: IDomElement;
    function getXmlAttrOwnerPtr: xmlNodePtr;
  public
    // this is currently not used but might be usefull
    property xmlAttribute: xmlAttrPtr read getXmlAttribute;
    constructor Create(AAttribute: xmlAttrPtr; ADocument: IDomDocument;
      OwnerElement: xmlNodePtr=nil);
    destructor Destroy; override;
  end;

  TDomCharacterData = class(TDomNode, IDomCharacterData)
  private
    function getXmlCharacterData: xmlNodePtr;
  protected
    { IDomCharacterData }
    function get_data: DOMString;
    procedure set_data(const Data: DOMString);
    function get_length: integer;
    function substringData(offset, Count: integer): DOMString;
    procedure appendData(const Data: DOMString);
    procedure insertData(offset: integer; const Data: DOMString);
    procedure deleteData(offset, Count: integer);
    procedure replaceData(offset, Count: integer; const Data: DOMString);
  public
    constructor Create(ACharacterData: xmlNodePtr; ADocument: IDomDocument);
    destructor Destroy; override;
    property xmlCharacterData: xmlNodePtr read getXmlCharacterData;
  end;

  { TDomElement }

  TDomElement = class(TDomNode, IDomElement)
  private
    function getXmlElement: xmlNodePtr;
  protected
    { IDomElement }
    function get_tagName: DOMString;
    function getAttribute(const Name: DOMString): DOMString;
    procedure setAttribute(const Name, Value: DOMString);
    procedure removeAttribute(const Name: DOMString);
    function getAttributeNode(const Name: DOMString): IDomAttr;
    function setAttributeNode(const newAttr: IDomAttr): IDomAttr;
    function removeAttributeNode(const oldAttr: IDomAttr): IDomAttr;
    function getElementsByTagName(const Name: DOMString): IDomNodeList;
    function getAttributeNS(const namespaceURI, localName: DOMString): DOMString;
    procedure setAttributeNS(const namespaceURI, qualifiedName, Value: DOMString);
    procedure removeAttributeNS(const namespaceURI, localName: DOMString);
    function getAttributeNodeNS(const namespaceURI, localName: DOMString): IDomAttr;
    function setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
    function getElementsByTagNameNS(const namespaceURI,
      localName: DOMString): IDomNodeList;
    function hasAttribute(const Name: DOMString): boolean;
    function hasAttributeNS(const namespaceURI, localName: DOMString): boolean;
    procedure normalize;
  public
    constructor Create(AElement: xmlNodePtr; ADocument: IDomDocument);
    destructor Destroy; override;
    property xmlElement: xmlNodePtr read getXmlElement;
  end;

  { TDomText }

  TDomText = class(TDomCharacterData, IDomText)
  protected
    function splitText(offset: integer): IDomText;
  end;

  { TDomComment }

  TDomComment = class(TDomCharacterData, IDomComment)
  end;

  { TDomCDATASection }

  TDomCDATASection = class(TDomText, IDomCDATASection)
  end;

  { TDomDocumentType }

  TDomDocumentType = class(TDomNode, IDomDocumentType)
  private
    fExternalDtd: xmlDtdPtr;
    fInternalDtd: xmlDtdPtr;
  protected
    { IDomDocumentType }
    function get_name: DOMString;
    function get_entities: IDomNamedNodeMap;
    function get_notations: IDomNamedNodeMap;
    function get_publicId: DOMString;
    function get_systemId: DOMString;
    function get_internalSubset: DOMString;
  public
    constructor Create(internalDtd, externalDtd: xmlDtdPtr; ADocument: IDomDocument);
    destructor Destroy; override;
  end;

  { TDomNotation }

  TDomNotation = class(TDomNode, IDomNotation)
  private
    // because the c-struct xmlNotation doesn't contain the shared fields of xmlNode
    // we have to store it separatly and not in the root node
    fXmlNotation:xmlNotationPtr;
  protected
    { IDomNotation }
    function get_publicId: DOMString;
    function get_systemId: DOMString;
  public
    constructor Create(notation:xmlNotationPtr; ADocument: IDomDocument);
    destructor Destroy; override;
  end;

  { TDomEntity }

  TDomEntity = class(TDomNode, IDomEntity)
  private
    // because the c-struct xmlEntity doesn't contain the shared fields of xmlNode
    // we have to store it separatly and not in the root node
    fXmlEntity: xmlEntityPtr;
  protected
    { IDomEntity }
    function get_publicId: DOMString;
    function get_systemId: DOMString;
    function get_notationName: DOMString;
  public
    constructor Create(entity:xmlEntityPtr; ADocument: IDomDocument);
    destructor Destroy; override;
  end;

  { TDomEntityReference }

  TDomEntityReference = class(TDomNode, IDomEntityReference)
  end;

  { TDomProcessingInstruction }

  TDomProcessingInstruction = class(TDomNode, IDomProcessingInstruction)
  protected
    { IDomProcessingInstruction }
    function get_target: DOMString;
    function get_data: DOMString;
    procedure set_data(const Value: DOMString);
  end;

  (*
   * neccesary to access internal neccessary methods of TDomDocument,
   * if you have a variable of type IDomDocument
   *)
  IDomInternal = interface
    ['{E9D505C3-D354-4D19-807A-8B964E954C09}']
    procedure set_reason(aReason: DomString);
    function get_reason: DomString; safecall;

    // managing the list of nodes and attributes, that must be freed manually
    procedure removeNode(node: xmlNodePtr);
    procedure removeAttr(attr: xmlAttrPtr);
    procedure appendAttr(attr: xmlAttrPtr);
    procedure appendNode(node: xmlNodePtr);
    procedure appendNs(ns: xmlNsPtr);
    function  getNewNamespace(const namespaceURI, prefix: DOMString): xmlNsPtr;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const ns: xmlNsPtr): xmlNsPtr; overload;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const namespaceURI, prefix: PAnsiChar): xmlNsPtr; overload;

    // managing a list of namespace declarations for xpath queries
    procedure registerNS(prefix,uri: AnsiString);
    function  getPrefixList:TStringList;
    function  getUriList:TStringList;

    // managing stylesheets, that must be freed differently
    procedure set_fXsltStylesheet(XSL: xsltStylesheetPtr);

    // managing stylesheets, that must be freed differently
    function getXsltStylesheetPtr: xsltStylesheetPtr;

    // doc element injection for XSLT transform.
    procedure injectDifferentDocElement(docElement: xmlDocPtr);

    property reason: DomString read get_reason write set_reason;

    // this procedure removes all text nodes, that contain whitespace only
    procedure removeWhitespace;
  end;

  { TDomDocument }

  TDomDocument = class(TDomNode, IXmlDomDocRef, IDomDocument, IDomParseOptions, IDomImplOptions,
      IDomPersist, IDomPersistHTML, IDomInternal, IDomOutputOptions, IDomParseError)
  private
    fDomImpl: IDomImplementation;         // the domimplementation used to create this document
    fXsltStylesheet: xsltStylesheetPtr;   // if the document was used as stylesheet,
                                          // this Pointer has to be freed and not
                                          // the xmlDocPtr
    fAsync: boolean;               // for compatibility, not really supported
    fPreserveWhiteSpace: boolean;  // difficult to support (doesn't work the same way
                                   // as MSXML)
    fResolveExternals: boolean;    // difficult to support (possibly not threadsafe)
    fValidate: boolean;            // if true, returns nil on failure
                                   // if false, loads a dtd if it exists
    fAttrList: TList;              // keeps a list of attributes, created on this document,
                                   // but not yet appended to it
    fNsList: TList;                // keeps a list of namespaces, created on this document
                                   // and used for lookup before creating new namespace structs
    fNodeList: TList;              // keeps a list of nodes, created on this document
                                   // but not yet appended to it
    fCompressionLevel: integer;    // the compression level of the parsed document
                                   // gzip-compression, valid values:
                                   // 0 (uncompressed) .. 9 (max compression)
    fEncoding: DomString;          // the encoding of the parsed document;
                                   // if you set this value before you save the
                                   // document, the new value is used
    fPrettyPrint: boolean;         // if true, a lf is inserted for each
                                   // structure, but no spaces or tabs
    fPrefixList: TStringList;      // if you want to use prefixes in xpath expressions,
    fURIList: TStringList;         // they must be registered and are then stored
                                   // on this two lists.
    fReason:  DomString;           // reason of last parse error
    fLine:    integer;             // line of the first parse error
    fLinePos: integer;             // row of first parse error
    fUrl:     DomString;           // filename or URL of parsed file containing error
    fExposeNsDefAttribs: boolean;  // whether to expose namespace declaration attributes
                                   // as Attributes via the IDomElement methods or not
    procedure processError;        // removes wrong error message validation error (if fValidate=false)
                                   // end extracts line and row number of error from fReason
    procedure setDefaults;         // set the default options
  protected
    // IXmlDomDocRef
    function GetXmlDocPtr: xmlDocPtr;
    // IDomDocument
    function get_doctype: IDomDocumentType;
    function get_domImplementation: IDomImplementation;
    function get_documentElement: IDomElement;
    procedure set_documentElement(const IDomElement: IDomElement);
    function createElement(const tagName: DOMString): IDomElement;
    function createDocumentFragment: IDomDocumentFragment;
    function createTextNode(const Data: DOMString): IDomText;
    function createComment(const Data: DOMString): IDomComment;
    function createCDATASection(const Data: DOMString): IDomCDATASection;
    function createProcessingInstruction(const target,
      Data: DOMString): IDomProcessingInstruction;
    function createAttribute(const Name: DOMString): IDomAttr;
    function createEntityReference(const Name: DOMString): IDomEntityReference;
    function getElementsByTagName(const tagName: DOMString): IDomNodeList;
    function importNode(importedNode: IDomNode; deep: boolean): IDomNode;
    function createElementNS(const namespaceURI,
      qualifiedName: DOMString): IDomElement;
    function createAttributeNS(const namespaceURI,
      qualifiedName: DOMString): IDomAttr;
    function getElementsByTagNameNS(const namespaceURI,
      localName: DOMString): IDomNodeList;
    function getElementById(const elementId: DOMString): IDomElement;
    // IDomParseOptions
    function get_async: boolean;
    function get_preserveWhiteSpace: boolean;
    function get_resolveExternals: boolean;
    function get_validate: boolean;
    procedure set_async(Value: boolean);
    procedure set_preserveWhiteSpace(Value: boolean);
    procedure set_resolveExternals(Value: boolean);
    procedure set_validate(Value: boolean);
    // IDomPersist
    function get_xml: DOMString;
    function asyncLoadState: integer;
    function loadFrom_XmlParserCtx(ctxt: xmlParserCtxtPtr): boolean;
    function load(Source: DOMString): boolean;
    function loadFromStream(const stream: TStream): boolean;
    function loadxml(const Value: DOMString): boolean;
    procedure save(Source: DOMString);
    procedure saveToStream(const stream: TStream);
    procedure set_OnAsyncLoad(const Sender: TObject;
      EventHandler: TAsyncEventHandler);
    // IDomPersistHTML
    function get_html: DOMString;
    // IDomInternal
    procedure removeNode(node: xmlNodePtr);
    procedure appendNode(node: xmlNodePtr);
    procedure removeAttr(attr: xmlAttrPtr);
    procedure appendAttr(attr: xmlAttrPtr);
    procedure appendNs(ns: xmlNsPtr);
    function  getNewNamespace(const namespaceURI, prefix: DOMString): xmlNsPtr;
    procedure registerNS(prefix,uri: AnsiString);
    function getXsltStylesheetPtr: xsltStylesheetPtr;
    procedure set_fXsltStylesheet(XSL: xsltStylesheetPtr);
    function  getPrefixList:TStringList;
    function  getUriList:TStringList;
    procedure set_reason(aReason: DomString);
    procedure removeWhitespace;
    procedure injectDifferentDocElement(docElement: xmlDocPtr);
    // IDomOutputOptions
    function get_prettyPrint: boolean;
    function get_encoding1: DomString;
    function get_parsedEncoding: DomString;
    function get_compressionLevel: integer;
    procedure set_prettyPrint(prettyPrint: boolean);
    procedure set_encoding1(encoding: DomString);
    procedure set_compressionLevel(compressionLevel: integer);
    // IDomParseError
    function get_errorCode: Integer;
    function get_url: DOMString; safecall;
    function get_reason: DOMString; safecall;
    function get_srcText: DOMString; safecall;
    function get_line: Integer;
    function get_linepos: Integer;
    function get_filepos: Integer;
    // IDomImplOptions
    function  get_exposeNsDefAttribs: boolean;
    procedure set_exposeNsDefAttribs(value: boolean);
    // not bound to an interface
    function  findNamespaceNode(const ns: xmlNsPtr): boolean;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const ns: xmlNsPtr): xmlNsPtr; overload;
    function  findOrCreateNewNamespace(const node: xmlNodePtr; const namespaceURI, prefix: PAnsiChar): xmlNsPtr; overload;
    procedure setDocOnCurrentLevel(next: xmlNodePtr; doc: xmlDocPtr);
    procedure setDocOnNextLevel(next: xmlNodePtr; doc: xmlDocPtr);
  public
    // to create an empty document or a document with a documentElement node
    // this constructor is used:
    constructor Create(DOMImpl: IDomImplementation;
      const namespaceURI, qualifiedName: DomString;
      doctype: IDomDocumentType); overload;
    // to create an empty document, the following constructor is used:
    constructor Create(DOMImpl: IDomImplementation); overload;
    // to create a document from a file, the following constructor is used
    constructor Create(DOMImpl: IDomImplementation; aUrl: DomString); overload;
    // to get the result of xslt-transformations, the following constructor is used
    constructor Create(DOMImpl: IDomImplementation; docnode: xmlNodePtr); overload;
    destructor Destroy; override;
  end;

  { TDomDocumentFragment }

  TDomDocumentFragment = class(TDomNode, IDomDocumentFragment)
  end;

  { TDomDocumentBuilderFactory }

  (*
   * taken from java, not defined in dom2 from w3c org
   *)

  TDomDocumentBuilderFactory = class(TInterfacedObject, IDomDocumentBuilderFactory)
  //todo: find an url, where IDomDocumentBuilderFactory is explained
  private
    fFreeThreading: boolean;

  public
    constructor Create(AFreeThreading: boolean);

    function NewDocumentBuilder: IDomDocumentBuilder;
    function Get_VendorID: DomString;
  end;

  { TDomDocumentBuilderFactory }

  (*
   * taken from java, not defined in dom2 from w3c org
   *)

  TDomDocumentBuilder = class(TInterfacedObject, IDomDocumentBuilder)
  private
    fFreeThreading: boolean;
  public
    constructor Create(AFreeThreading: boolean);
    destructor Destroy; override;
    function Get_DomImplementation: IDomImplementation;
    function Get_IsNamespaceAware: boolean;
    function Get_IsValidating: boolean;
    function Get_HasAsyncSupport: boolean;
    function Get_HasAbsoluteURLSupport: boolean;
    function newDocument: IDomDocument;
    function parse(const xml: DomString): IDomDocument;
    function load(const url: DomString): IDomDocument;
  end;

(*
 * xml utility functions
 *)

function IsXmlName(const S: DOMString): boolean; forward;
function IsXmlChars(const S: DOMString): boolean; forward;


const
  {$ifdef mswindows}
    crlf=#13#10;
  {$else}
    crlf=#10;
  {$endif}

// *************************************************************
// internal methods
// *************************************************************


{$ifdef VER130} // Delphi 5
function UTF8Encode(s: DOMString):AnsiString;
begin
  result:=jclUnicode.WideStringToUTF8(s);
end;
{$endif}

function UTF8Decode(const s: PAnsiChar): DOMString;
begin
  if Assigned(s)
  {$ifdef VER130} // Delphi 5
     then Result := jclUnicode.UTF8ToWideString(s)
  {$else}
     then Result := System.UTF8Decode(s)
  {$endif}
     else Result := '';
end;

function isEncodingUTF8(const Encoding: DOMString): boolean;
var
  S : AnsiString;
begin
  S:=lowercase(Encoding);

  Result:=(S='utf-8') or (S='utf8');
end;

function isEncodingUTF16(const Encoding: DOMString): boolean;
var
  S : AnsiString;
begin
  S:=lowercase(Encoding);

  Result:=(S='utf-16') or (S='utf16');
end;

// converts an error no into the corresponding string
function errorString(err: integer): AnsiString;
begin
  case err of
    INDEX_SIZE_ERR: Result := 'INDEX_SIZE_ERR';
    DOMSTRING_SIZE_ERR: Result := 'DOMSTRING_SIZE_ERR';
    HIERARCHY_REQUEST_ERR: Result := 'HIERARCHY_REQUEST_ERR';
    WRONG_DOCUMENT_ERR: Result := 'WRONG_DOCUMENT_ERR';
    INVALID_CHARACTER_ERR: Result := 'INVALID_CHARACTER_ERR';
    NO_DATA_ALLOWED_ERR: Result := 'NO_DATA_ALLOWED_ERR';
    NO_MODIFICATION_ALLOWED_ERR: Result := 'NO_MODIFICATION_ALLOWED_ERR';
    NOT_FOUND_ERR: Result := 'NOT_FOUND_ERR';
    NOT_SUPPORTED_ERR: Result := 'NOT_SUPPORTED_ERR';
    INUSE_ATTRIBUTE_ERR: Result := 'INUSE_ATTRIBUTE_ERR';
    INVALID_STATE_ERR: Result := 'INVALID_STATE_ERR';
    SYNTAX_ERR: Result := 'SYNTAX_ERR';
    INVALID_MODIFICATION_ERR: Result := 'INVALID_MODIFICATION_ERR';
    NAMESPACE_ERR: Result := 'NAMESPACE_ERR';
    INVALID_ACCESS_ERR: Result := 'INVALID_ACCESS_ERR';
    NULL_PTR_ERR: Result:='NULL_PTR_ERR';
    WRITE_ERR: Result:='WRITE_ERR';
    20: Result := 'SaveXMLToMemory_ERR';
    22: Result := 'SaveXMLToDisk_ERR';
    100: Result := 'LIBXML2_NULL_POINTER_ERR';
    101: Result := 'INVALID_NODE_SET_ERR';
    else Result := 'Unknown error no: ' + IntToStr(err);
  end;
end;

// Raises an exception with speaking message
procedure checkError(err: integer; classname: AnsiString = 'unknown');
var location: AnsiString;
begin
  if classname = 'unknown'
    then location := ''
    else location := 'in class ' + classname;
  if err <> 0
    then raise EDomException.Create(err, ErrorString(err)+location);
end;

{+------------------------------------------------------------
 | Function IScan
 |
 | Parameters:
 |  ch: Character to scan for
 |  S : String to scan
 |  fromPos: first character to scan
 | Returns:
 |  position of next occurence of character ch, or 0, if none
 |  found
 | Description:
 |  Search for next occurence of a character in a string.
 | Error Conditions: none
 | Created: 11/27/96 by P. Below
 +------------------------------------------------------------}
Function IScan( ch: Char; Const S: String; fromPos: Integer ): Integer;
Var
  i: Integer;
Begin
  Result := 0;
  For i := fromPos  To Length(S) Do Begin
    If S[i] = ch Then Begin
      Result := i;
      Break;
    End; { If }
  End; { For }
End; { IScan }

{+------------------------------------------------------------
 | Procedure SplitString
 |
 | Parameters:
 |  S: String to split
 |  separator: character to use as separator between substrings
 |  substrings: list to take the substrings
 | Description:
 |  Isolates the individual substrings and copies them into the
 |  passed stringlist. Note that we only add to the list, we do
 |  not clear it first! If two separators follow each other directly
 |  an empty string will be added to the list.
 | Error Conditions:
 |  will do nothing if the stringlist is not assigned
 | Created: 08.07.97 by P. Below
 +------------------------------------------------------------}
Procedure SplitString( Const S: String; separator: Char; substrings: TStringList );
Var
  i, n: Integer;
Begin
  If Assigned( substrings ) and ( Length( S )>0 ) Then Begin
    i:= 1;
    Repeat
      n := IScan( separator, S, i );
      If n = 0 Then
        n:= Length( S )+1;
      substrings.Add( Copy( S,i,n-i ));
      i:= n+1;
    Until i>Length( S );
  End; { If }
End; { SplitString }


function IsReadOnlyNode(node: xmlNodePtr): boolean;
begin
  if node <> nil
    then case node.type_ of
           XML_NOTATION_NODE, XML_ENTITY_NODE, XML_ENTITY_DECL: Result := True;
         else Result := False;
         end
    else Result := False;
end;


function MakeNode(Node: xmlNodePtr; ADocument: IDomDocument): IDomNode;
const
  NodeClasses: array[XML_ELEMENT_NODE .. XML_DOCB_DOCUMENT_NODE] of TDomNodeClass =
    (TDomElement, TDomAttr, TDomText, TDomCDataSection,
    TDomEntityReference, TDomEntity, TDomProcessingInstruction,
    TDomComment, TDomDocument, TDomDocumentType, TDomDocumentFragment,
    TDomNotation, nil, nil, nil, nil, nil, nil, nil, nil, nil );
var
  nodeType: xmlElementType;
  tmp: DOMString;
begin
  result:=nil;
  if Node=nil then exit;
  nodeType := Node.type_;
  if nodeType = XML_ENTITY_DECL then begin
    tmp:=UTF8Decode(node.content);
    result:=ADocument.createTextNode(tmp);
    exit;
  end;
  // this is a workaround for handling the result of xslt transformations
  if nodeType = XML_HTML_DOCUMENT_NODE then nodeType := XML_DOCUMENT_NODE;
  // this is neccessary for default attributes
  if nodeType = XML_ATTRIBUTE_DECL then nodeType := XML_ATTRIBUTE_NODE;
  // check if the nodeType is one of the implemented node classes
  if not (nodeType<XML_HTML_DOCUMENT_NODE)
    then checkError(INVALID_ACCESS_ERR);
  Result := NodeClasses[nodeType].Create(Node, ADocument)
end;

function MakeAttr(attr: xmlAttrPtr; AOwnerDocument: IDomDocument; AOwnerElement: xmlNodePtr): IDomAttr;
begin
  // set the default value
  result:=nil;
  // check for valid argument
  if attr=nil then exit;
  // check for type of attribute
  if attr.type_ = XML_ATTRIBUTE_DECL then begin
    // for attributes from the dtd, store the ownerelement in the wrapper
    result:=TDomAttr.Create(attr,AOwnerDocument,AOwnerElement) as IDomAttr;
  end else begin
    Result := MakeNode(xmlNodePtr(attr), AOwnerDocument) as IDomAttr;
  end;
end;

function LookUpNs(node:xmlNodePtr; ns:xmlNsPtr; deep: boolean = true):boolean;
// look in the nsdef list of the node and his parents, wether the namespace
// and prefix are already registered
var
  node1: xmlNodePtr;
  break: boolean;

function LookUpNs1(node:xmlNodePtr; ns: xmlNsPtr; out break: boolean):boolean;
  // Look in the nsdef list of the node, wether the namespace
  // and prefix are already registered.
  //
  // The return parameter break is true (and result false),
  // if a different default namespace declaration was found.
  // case a: ns.prefix=nil and tmp.prefix=nil
  //     result:=(ns.href=tmp.href)
  // case b: ns.prefix<>nil and tmp.prefix<>nil
  //     result:=(ns.href=tmp.href and ns.prefix = tmp.prefix)
  // otherwise (one of the prefixes is nil)
  //     result:=false
  var
    tmp: xmlNsPtr;
  begin
    result:=false;
    break:=false;
    tmp:=node.nsdef;
    while tmp <> nil do begin
      //compare the prefix, if it exists
      if (tmp.prefix <> nil) and (ns.prefix<>nil) then begin
        if (StrComp(tmp.href,ns.href)=0) and (StrComp(tmp.prefix,ns.prefix)=0) then begin
          // it is already in the list
          result:=true;
          // all done
          exit;
        end
      // otherwise, check if both namespaces are the same default namespaces
      end else begin
        if ((ns.prefix=nil) and (tmp.prefix=nil)) and(StrComp(tmp.href,ns.href)=0) then begin
          // it is already in the list
          result:=true;
          // all done
          exit;
        end else begin
          // if we found a second default namespace declaration, that is different
          if (ns.prefix=nil) and (tmp.prefix = nil) then begin
            break:=true;
            result:=false;
      // all done
      exit;
          end;
        end;
      end;
      // get the next entry
      tmp:=tmp^.next;
    end;
  end;

// function LookUpNs
begin
  // set the default value
  result:=false;
  // fix by ThFreudenberg
  // this it to be checked again for specification !!!!
  if (not Assigned(ns)) then exit;

  node1:=node;
  if not deep then begin
    result:=LookupNs1(node1,ns,break);
    exit;
  end;

  while node1 <> nil do begin
    // if found, than exit
    if LookupNs1(node1,ns, break) then begin
      result := true;
      exit;
    end;
    // if a different default namespace was found, than exit
    if break then exit;
    node1:=node1.parent;
  end;

end;

function appendNamespace(element: xmlNodePtr; ns: xmlNsPtr;force: boolean=false): boolean;
// this function appends a namespace to the nsDef list of an element
// if it isn't already defined on one of the parents nodes or if force is true
// this must be done, if you append a node or an attribute to an element

var
  tmp, last: xmlNsPtr;
  newNs: xmlNsPtr;

// function appendNamespace
begin
  // Set default value
  Result := False;
  last := nil;
  // exit the function, if element isn't an element node
  if element^.type_ <> XML_ELEMENT_NODE then exit;

  // look in the nsdef list, wether the namespace and prefix
  // are already registered on the current element
  // if not force, than do it deep (in all nodes above, too)
  if LookupNs(element,ns, not force) then exit;

  // if we reach this point the namespace wasn't found on this element
  // and not on any of its parents.
  // We have to create a copy of the namespace because
  // ns will be freed by the wrapper and the copy by libxml2
  newNs:=xmlCopyNamespace(ns);
  // cycle to the end of the list
  tmp:=element^.nsdef;
  while tmp<>nil do begin
    last:=tmp;
    tmp:=tmp^.next;
  end;
  // now append it at the end
  if element^.nsDef = nil
    then element^.nsDef := newNs
    else last^.Next := newNs;
  Result := True;
end;

procedure addNsdef(node: xmlNodePtr); overload;
// this procedure appends the namespace of the node and of all its
// attributes (but not the default attributes) to it's nsdef list
var
  attr: xmlAttrPtr;
begin
  // append the namespace of the node
  if node.ns <> nil then begin
    appendNamespace(node,node.ns,true);
  end;
  // append the namespace of it's attributes
  attr:=node.properties;
  // loop through the list of attributes
  while attr <> nil do begin
    // append the namespace of the current attribute
    if attr.ns <> nil then begin
      appendNamespace(node,attr.ns,true);
    end;
    attr:=attr.next;
  end;
end;

procedure addNsdef(node: xmlNodePtr; deep: boolean); overload;
// this procedure appends the namespace of the node and of all its
// attributes (but not the default attributes) to it's nsdef list
// if deep is true, than it works recursively through the node and
// all it's children
var
  child: xmlNodePtr;
begin
  // exit the function, if node isn't an element node
  if node.type_ <> XML_ELEMENT_NODE then exit;
  // add the namespace(s) of the node itself
  addNsdef(node);
  // if deep, then loop through all children
  if deep then begin
    // get the first child
    child:=node.children;
    // if it exists, loop through the list of children
    while child <> nil do begin
      // add the namespaces of the subtree of the child
      addNsdef(child, true);
      child:=child.next;
    end;
  end;
end;

function charCountOf(c: WideChar; const s: DOMString; breakAfter: integer = 0): integer;
var i: integer;
begin
  result := 0;
  for i := 1 to length(s) do
    if (s[i] = c)
       then begin
         inc(result);
         if (result > breakAfter)
            then break;
       end;
end;

function split_prefix(const qualifiedName: DOMString): DOMString;
begin
  Result := Copy(qualifiedName, 1, Pos(':', qualifiedName) - 1);
end;

function split_localName(const qualifiedName: DOMString): DOMString;
begin
  Result := Copy(qualifiedName, Pos(':', qualifiedName) + 1, MAXINT);
end;

function check_IsSupported(const feature, version: DOMString): boolean;
begin
  Result := ((upperCase(feature) = 'CORE') or (upperCase(feature) = 'XML')) and
            ((version = '2.0') or (version = '1.0') or (version = ''));
end;

function IsSameNode(node1, node2: IDomNode): boolean;
begin
  try
    Result := (node1 as IDomNodeCompare).IsSameNode(node2);
  except
    if node1 = node2 then Result := True
    else Result := False;
  end;
end;

function extractEncoding(const Source: DOMString): DOMString;
//extracts the encoding from the xml header
var p, e, pEnd: PWideChar;
begin
  // init result
  result := '';
  // init pointers
  p := @Source[1];
  pEnd := p + length(Source);
  // first '<'
  while (p < pEnd) do
    // ignore ONLY whitespaces
    if ((p^ = #32)  or
        (p^ = #9)   or
        (p^ = #13)  or
        (p^ = #10)) then inc(p)
    else
    // have found the symbol
    if (p^ = '<') then break
    else
    // not valid xml
      exit;

  // check next five, must be ?xml<blank>
  if ((p + 1)^ <> '?') or
     ((p + 2)^ <> 'x') or
     ((p + 3)^ <> 'm') or
     ((p + 4)^ <> 'l') or
     ((p + 5)^ <> #32) then exit;

  // find end of this
  e := p + 6;
  while (e <= pEnd) do
    // have found the symbol
    if (e^ = '>') then break
    else
    // not valid xml
    if (e^ = '<') then exit
    else
    // next char
      inc(e);

  // mask this out
  result := Copy(Source, p - @Source[1], e - p + 1);

  // check for encoding
  p := PWideChar(@result[1]) + Pos(DOMString('encoding='), result) - 1;

  if (p < @result[1])
     then result := ''
     else begin
       // skip test "encoding="
       inc(p, 9);
       // get end
       pEnd := PWideChar(@result[1]) + length(result);
       // skip until end of attr value enclosed in "" or ''
       e := p + 1;
       while (e < pEnd) and (e^ <> p^) do inc(e);
       // check that we have found the end and that there is a quote
       if ((p^ <> '"') and (p^ <> #39)) or (e^ <> p^)
          then
            // not valid xml
            result := ''
          else
            // ok, mask it out
            result := lowerCase(Copy(result, p - @result[1] + 2, e - p - 1));
     end;
end;

procedure check_ValidQualifierNS(const namespaceURI, qualifiedName: DOMString);
begin
  if (qualifiedName <> '') then begin
    if not IsXmlName(qualifiedName)
       then checkError(INVALID_CHARACTER_ERR);
  end;
  if  (CharCountOf(':', qualifiedName, 1) > 1)  or
     ((CharCountOf(':', qualifiedName, 0) > 0)  and (namespaceURI =  ''))
     then checkError(NAMESPACE_ERR);

  if ('xml' = split_Prefix(qualifiedName)) and (namespaceURI <> XML_NAMESPACE_URI)
    then
     checkError(NAMESPACE_ERR);
end;

procedure check_NsDeclAttr(const namespaceURI, qualifiedName: DOMString);
begin
  if ((qualifiedName = 'xmlns') or (split_prefix(qualifiedName) = 'xmlns'))
    and (namespaceURI <> XMLNS_NAMESPACE_URI) then checkError(NAMESPACE_ERR);
end;

function check_NsDeclAttr1(const qualifiedName: DOMString): integer;
// returns 1 for defaultns and 2 for nsdecl attribute, 0 otherwise
begin
  result:=0;
  if (qualifiedName = 'xmlns')
    then result:=1
    else if (split_prefix(qualifiedName) = 'xmlns')
      then result:=2;
end;



// *************************************************************
// internal libxml_utils methods
// *************************************************************

procedure xmlNormalize(node:xmlNodePtr);
var
  node1, Next, new_next: xmlNodePtr;
  temp:     AnsiString;
begin
  // don't do anything on nodes, other than elements
  if node^.type_ <> XML_ELEMENT_NODE then exit;
  // get the list of children of this element
  node1 := node^.children;
  // walk through the list of children
  while node1 <> nil do begin
    if node1^.type_ = XML_TEXT_NODE then begin
      temp:=node1^.content;
      if (not assigned(node1^.content) or (temp='')) then begin
        // remove empty text nodes
        new_next:=node1^.next;
        xmlUnlinkNode(node1);
        xmlFreeNode(node1);
        // go to the next node
        node1:=new_next;
      end else begin
        // check if the following node is a text node, too
        Next := node1^.Next;
        // loop through the text nodes, that follow this text node
        while Next <> nil do begin
          // leave the inner loop, it the next node isn't a text node
          if Next^.type_ <> XML_TEXT_NODE then break;
          // concat adjesting text nodes
          temp := Next^.content;
          xmlTextConcat(node1, PAnsiChar(temp), length(temp));
          new_next := Next^.Next;
          Next^.parent := nil;
          xmlUnlinkNode(Next);
          xmlFreeNode(Next);
          Next := new_next;
        end;
        // go to the next node
        node1 := node1^.Next;
      end;
    end else if node1^.type_ = XML_ELEMENT_NODE then begin
      // if there is an element on the list of children, normalize it
      xmlNormalize(node1);
      // go to the next node
      node1 := node1^.Next;
    end;
  end;
end;

// libxml2 method has a BUG if there is only the root element in document
// so we append a dummy node to this empty document, use then reconciliate
procedure xmlReconciliateNS(doc: xmlDocPtr; node: xmlNodePtr);
var root, dummy: xmlNodePtr;
begin
  // get the root element to test
  root := xmlDocGetRootElement(doc);
  // check if root has children
  if Assigned(root^.children)
     then dummy := nil
     else dummy := xmlAddChild(root, xmlNewText(nil));
  // use the libxml2 method
  libxml2.xmlReconciliateNs(doc, node);
  // remove our dummy
  if Assigned(dummy)
     then
       try xmlUnlinkNode(dummy) finally xmlFreeNode(dummy); end;
end;

procedure check_fixedAttr(var attr: xmlAttrPtr; clearDefaultAttr: boolean=false);
begin
  if assigned(attr) and (attr^.type_ = XML_ATTRIBUTE_DECL) then begin
    if xmlAttributePtr(attr)^.def = XML_ATTRIBUTE_FIXED then begin
      checkError(NO_MODIFICATION_ALLOWED_ERR);
    end;
    // clear the default attribute, if required
    if clearDefaultAttr then attr:=nil;
  end;
end;

procedure xmlAddPropChild(const parent: xmlNodePtr; const xmlAttr: xmlAttrPtr);
var iloop: xmlAttrPtr;
begin
  // assign parent property to this scopes parent
  xmlAttr^.parent := parent;
  xmlAttr^.doc := parent^.doc;
  // first check that properties is intialized
  if (not Assigned(parent^.properties))
     then
       // set new struct
       parent^.properties := xmlAttr
     else begin
       // cycle to the end
       iloop := parent^.properties;
       // check until we point with next to nil
       while Assigned(iloop^.next) do iloop := iloop^.next;
       // insert this new struct
       iloop^.next     := xmlAttr;
       xmlAttr^.prev   := iloop;
     end;
end;

function removeNamespace(node: xmlNodePtr;ns: xmlNsPtr): xmlNsPtr;
// this procedure removes a namespace from a nsdef list of an element
// the removed ns is returned, if it was found
// the removed ns is not freed, this must be done from the calling
// programm after calling this procedure

var
  tmp,last: xmlNsPtr;
begin
  // set the default value
  result:=nil;
  // if there are invalid parameters passed, than exit
  if node=nil then exit;
  if node^.type_ <> XML_ELEMENT_NODE then exit;
  if ns=nil then exit;
  // get the first entry of the nsDef list
  tmp:=node^.nsDef;
  last:=nil;
  // loop through all entries
  while tmp<>nil do begin
    // check, if the nsuris are the same and the prefixes are nil or the same
    if (StrComp(tmp.href,ns.href)=0) and (((tmp.prefix=nil) and (ns.prefix=nil)) or
      (StrComp(tmp.prefix,ns.prefix)=0)) then begin
      // now remove the nsdef entry
      // if we are at the beginning of the list:
      if tmp=node^.nsDef then begin
        node^.nsDef:=tmp^.next;
      // if we are in the middle or at the end;
      end else begin
        last^.next:=tmp^.next;
      end;
      // we found and removed the nsdef entry, so we can quit
      result:=tmp;
      exit;
    end;
    last:=tmp;
    tmp:=tmp^.next;
  end;
end;

procedure cleanNsdef(node:xmlNodePtr); overload;
  // removes the namespaces from the nsdef list of the given element-node,
  // if they exist above
  var
    tmp,next: xmlNsPtr;
  begin
    if node^.type_ <> XML_ELEMENT_NODE then exit;
    tmp:=node^.nsdef;
    while tmp<>nil do begin
      next:=tmp^.next;
      if LookUpNs(node.parent,tmp) then begin
        // delete the nsdef entry in the node
        removeNamespace(node,tmp);
        xmlFreeNs(tmp);
      end;
      tmp:=next;
    end;
  end;

procedure cleanNsdef(node:xmlNodePtr; deep: boolean); overload;
// removes the namespaces from the nsdef list of the given element-node,
// and his children and grandchildren... (deep=true), if they exist above
var
  child: xmlNodePtr;
begin
  // exit the function, if node isn't an element node
  if node.type_ <> XML_ELEMENT_NODE then exit;
  // clean the nsdef list of the current node
  cleanNsdef(node);
  // if not deep, than all done!
  if not deep then exit;
  // if deep, than process the list of children of this node
  child:=node.children;
  while assigned(child) do begin
    cleanNsdef(child,true);
    child:=child^.next;
  end;
end;

function xmlGetDefaultNs(node: xmlNodePtr): xmlNsPtr;
// get the default namespace attribute of the element node
// if there is none, return nil
var
  nsDef: xmlNsPtr;
begin
  // set the default value
  result:=nil;
  // get the first entry of the nsdef list
  nsDef:=node.nsDef;
  // loop through the list
  while nsDef<>nil do begin
    // if the prefix is nil, then we found the default namespace
    if nsDef.prefix=nil then begin
      // set the result
      result:=nsDef;
      // exit
      exit;
    end;
    // get the next member of the list
    nsDef:=nsDef.next;
  end;
end;

function xmlRemoveDefaultNs(node: xmlNodePtr): xmlNsPtr;
// remove the default namespace from the passed element node
// returns true, if a default ns was found and removed
begin
  result:=nil;
  if node.type_ <> XML_ELEMENT_NODE then exit;
  result:=xmlGetDefaultNs(node);
  if result=nil then exit;
  // remove the defaultNs;
  removeNamespace(node,result);
end;

procedure xmlRemoveWhitespace(node:xmlNodePtr); overload;
  // removes all empty text nodes from the child- list of the given element-node
  // and frees them
  var
    tmp,next: xmlNodePtr;
  begin
    if node.type_ <> XML_ELEMENT_NODE then exit;
    tmp:=node.children;
    while tmp<>nil do begin
      next:=tmp.next;
        if xmlIsBlankNode(tmp) = 1 then begin
          //remove the whitespace from the list of children
          xmlUnlinkNode(tmp);
          //free it
          xmlFreeNode(tmp);
      end;
      tmp:=next;
    end;
  end;

procedure xmlRemoveWhitespace(node:xmlNodePtr; deep: boolean); overload;
// removes all empty text nodes from the child- list of the given element-node
// and his children and grandchildren... (deep=true), and frees them
var
  child: xmlNodePtr;
begin
  // exit the function, if node isn't an element node
  if node.type_ <> XML_ELEMENT_NODE then exit;
  // clean the nsdef list of the current node
  xmlRemoveWhitespace(node);
  // if not deep, than all done!
  if not deep then exit;
  // if deep, than process the list of children of this node
  child:=node.children;
  while assigned(child) do begin
    xmlRemoveWhitespace(child,true);
    child:=child.next;
  end;
end;

procedure xmlUnlinkPropNode(const parent: xmlNodePtr; const xmlAttr: xmlAttrPtr);
begin
  // free parent property
  xmlAttr.parent := nil;
  // first check that properties is intialized
  if (parent.properties = xmlAttr)
     then begin
       parent.properties := parent.properties.next;
       // check that we have still a list
       if Assigned(parent.properties)
          then
            // correct prev link
            parent.properties.prev := nil;
     end
     else begin
       // we are in the middle
       if Assigned(xmlAttr.next) then xmlAttr.next.prev := xmlAttr.prev;
       if Assigned(xmlAttr.prev) then xmlAttr.prev.next := xmlAttr.next;
     end;

  // now unlink this attribute
  xmlAttr.prev := nil;
  xmlAttr.next := nil;
end;

function xmlCloneAttr(inAttr:xmlAttrPtr; wrapperDoc: IDomDocument; deep: boolean):xmlAttrPtr;
// this function clones an attribute, according to the dom2 rules:
// the namespaces are cloned, too, and are created with findOrCreateNamespace,
// so they are created only, if neccessary, and are appended to the internal
// list of the new OwnerDocument (=wrapperDoc)
var
  node  : xmlNodePtr;
  doc   : xmlDocPtr;
  child : xmlNodePtr;
begin
  result := nil;
  doc:=xmlDocPtr((wrapperDoc as IXmlDomNodeRef).GetXmlNodePtr);
  node:=xmlNodePtr(xmlCopyProp(nil,inAttr));
  if node <> nil then begin
    node.doc := doc;
    // it's important, that the first parameter of findOrCreateNewNamespace is nil!
    node.ns:=(wrapperDoc as IDomInternal).findOrCreateNewNamespace(nil,inAttr.ns);

    // it's important to set the owner doc of the children too! (MAV)
    child:=node.children;
    while child<>nil do
    begin
      child.doc:=doc;
      child:=child.next;
    end;

    Result := xmlAttrPtr(node);
  end;
end;

function xmlCloneAttrDecl(attrDecl:xmlAttributePtr; wrapperDoc: IDomDocument; deep: boolean;ns:xmlNsPtr=nil):xmlAttrPtr;
// this function clones an attribute declaration node, according to the dom2 rules:
var
  doc: xmlDocPtr;
  attr: xmlAttrPtr;
begin
  doc:=xmlDocPtr((wrapperDoc as IXmlDomNodeRef).GetXmlNodePtr);
  if ns=nil then begin
    // create a dummy attribute with the correct content
    attr:=xmlNewProp(nil,attrDecl.name,attrDecl.defaultValue);
    attr.doc := doc;
  end else begin
    attr:=xmlNewNsProp(nil,ns,attrDecl.name,attrDecl.defaultValue);
    attr.doc := doc;
  end;
  result:=attr;
end;

function xmlCloneNode(inNode:xmlNodePtr; wrapperDoc: IDomDocument):xmlNodePtr; overload;
// this function clones a node, according to the dom2 rules:
// attributes are cloned, too, even if deep is false
// the namespaces are cloned, too, and are created with findOrCreateNamespace,
// so they are created only, if neccessary, and are appended to the internal
// list of the new OwnerDocument (=wrapperDoc)
var
  node:   xmlNodePtr;
  attr,attr1:   xmlAttrPtr;
  recursive: integer;
  doc: xmlDocPtr;
  deep: boolean; // for debugging only
begin
  deep:=false;
  if inNode.type_=XML_ATTRIBUTE_NODE
    then begin
      result:=xmlNodePtr(xmlCloneAttr(xmlAttrPtr(inNode),wrapperDoc,deep));
      exit;
    end;
  if inNode.type_=XML_ATTRIBUTE_DECL
    then begin
      result:=xmlNodePtr(xmlCloneAttrDecl(xmlAttributePtr(inNode),wrapperDoc,deep));
      exit;
    end;
  doc:=xmlDocPtr((wrapperDoc as IXmlDomNodeRef).GetXmlNodePtr);
  if deep
    then recursive := 1
    else recursive := 0;
  if inNode.type_= XML_DOCUMENT_FRAG_NODE then begin
    node := xmlNewDocFragment(doc);
  end else begin
    node := xmlDocCopyNode(inNode, doc, recursive);
    if node <> nil then begin
      // set properties
      node.doc := doc;
      node.ns:=(wrapperDoc as IDomInternal).findOrCreateNewNamespace(nil,inNode.ns);
      if inNode.type_=xml_element_node then begin
        appendNamespace(node,node.ns);
      end;
      // if not deep, than copy the attributes of the element
      // here in the wrapper
      if (not deep) and (inNode.type_=XML_ELEMENT_NODE) then begin
        attr:=inNode.properties;
        while attr<>nil do begin
          attr1:=xmlCopyProp(node,attr);
          attr1.doc:=doc;
          attr1.ns:=(wrapperDoc as IDomInternal).findOrCreateNewNamespace(nil,attr.ns);
          xmlAddPropChild(node,attr1);
          attr:=attr.next;
        end;
      end;
    end;
  end;
  result:=node;
end;

function xmlCloneNode(inNode:xmlNodePtr; wrapperDoc: IDomDocument; deep: boolean):xmlNodePtr; overload;
// clones the node; if deep=true, than all the children are cloned, too, recursively,
// and are appended to the result
var
  child: xmlNodePtr;
  copy:  xmlNodePtr;
begin
  if (inNode.type_=XML_ATTRIBUTE_DECL) or (inNode.type_=XML_ATTRIBUTE_NODE) or (inNode.children=nil)
    then deep:=false;
  result:=xmlCloneNode(inNode,wrapperDoc);
  if deep then begin
    child:=inNode.children;
    while assigned(child) do begin
      copy:=xmlCloneNode(child,wrapperDoc,true);
      xmlAddChild(result,copy);
      cleanNsdef(copy,true);
      child:=child.next;
    end;
  end;
end;

//
// macros from xpath.h
//

(* These macros may later turn into functions *)
(**
 * xmlXPathNodeSetGetLength:
 * @ns:  a node-set
 *
 * Implement a functionality similar to the DOM NodeList.length
 *
 * Returns the number of nodes in the node-set.
 *)
function xmlXPathNodeSetGetLength(ns: xmlNodeSetPtr): Integer;
begin
  if ns = nil then begin
    Result := 0;
  end else begin
    Result := ns^.nodeNr;
  end;
end;

(**
 * xmlXPathNodeSetItem:
 * @ns:  a node-set
 * @index:  index of a node in the set
 *
 * Implements a functionnality similar to the DOM NodeList.item().
 *
 * Returns the xmlNodePtr at the given @index in @ns or NULL if
 *         @index is out of range (0 to length-1)
 *)
function xmlXPathNodeSetItem(ns: xmlNodeSetPtr; index: Integer): xmlNodePtr;
var
  p: PxmlNodePtr;
begin
  Result := nil;
  if ns = nil then exit;
  if index < 0 then exit;
  if index >= ns^.nodeNr then exit;
  p := ns^.nodeTab;
  Inc(p, index);
  Result := p^;
end;

(**
 * xmlXPathNodeSetIsEmpty:
 * @ns: a node-set
 *
 * Checks whether @ns is empty or not.
 *
 * Returns %TRUE if @ns is an empty node-set.
 *)
function xmlXPathNodeSetIsEmpty(ns: xmlNodeSetPtr): Boolean;
begin
  Result := ((ns = nil) or (ns^.nodeNr = 0) or (ns^.nodeTab = nil));
end;
// ****************************************************************************
// todo: replace the following code with a version of xmlGetHashEntry, that
// uses libxml2 api functions only
// ****************************************************************************

type

   xmlHashTablePtr = ^xmlHashTable;

   xmlHashEntryPtr = ^xmlHashEntry;
   xmlHashEntry = record
        next    : xmlHashEntryPtr;
        name    : PAnsiChar;
        name2   : PAnsiChar;
        name3   : PAnsiChar;
        payload : pointer;
        valid   : longint;  //new in 2.4.23
     end;

   {
     The entire hash table
   }
   pXmlHashEntryPtr=^xmlHashEntryPtr;
   xmlHashTable = record
        table   : xmlHashEntryPtr;  //new in 2.4.23
        size    : longint;
        nbElems : longint;
     end;

// ****************************************************************************


function xmlGetHashEntry(hash: xmlHashTablePtr; index: integer): pointer;
// get a pointer to the content of a hash-entry with a given index
// index = 0..HashLength-1
// returns nil, if it doesn't exist
var
  i,j: integer;
  hashEntry,next: xmlHashEntryPtr;
  p: xmlHashEntryPtr;
begin
  // set the default result
  result:=nil;
  // check for invalid index
  if index<0 then exit;
  // we will count j from index downto zero
  j:=index;
  inc(j);
  // scan the hash
  if hash.table<>nil then begin
    for i:=0 to hash.size-1 do begin
      p := hash.table;
      Inc(p, i);
      hashEntry := p;
      if (hashEntry<>nil) and (hashEntry.valid <> 0) then begin    //new in 2.4.23
        while hashEntry<>nil do begin
          next:=hashEntry.next;
          dec(j);
          // check if we found the entry with the correct index
          if j=0 then begin
            // return the result
            result:=hashEntry.payload;
            break;
          end;
          hashEntry:=next;
        end; {while}
      end; {if valid}                       //new in 2.4.23
    end; {for}
  end;
end;

procedure xmlSetAttrValue(attr: xmlAttrPtr; svalue: AnsiString);
var
  buffer : PAnsiChar;
  tmp    : xmlNodePtr;
begin
  if attr^.children <> nil then xmlFreeNodeList(attr^.children);
  attr^.children := nil;
  attr^.last := nil;
  buffer := xmlEncodeEntitiesReentrant(attr^.doc, PAnsiChar(sValue));
  attr.children := xmlStringGetNodeList(attr.doc, buffer); // FIX: not "pchar(svalue)" !!!
  tmp := attr^.children;
  while tmp <> nil do begin
    tmp^.parent := xmlNodePtr(attr);
    tmp^.doc := attr^.doc;
    if tmp^.Next = nil then attr^.last := tmp;
    tmp := tmp^.Next;
  end;
  xmlFree(buffer);
end;

function xmlReplacePropNode(const xmlOldPropNode, xmlNewPropNode: xmlAttrPtr): xmlAttrPtr;
begin
  // replace the nodes
  result := xmlAttrPtr(xmlReplaceNode(xmlNodePtr(xmlOldPropNode), xmlNodePtr(xmlNewPropNode)));
  // in special case that xmlOldPropNode is pointed to parent.properties
  // xmlReplaceNode did not correct the parent.properties
  if (xmlNewPropNode^.parent^.properties = xmlOldPropNode)
     then xmlNewPropNode^.parent^.properties := xmlNewPropNode;
end;

// *****************************************************************************
//     helper functions for the handling of namespace declaration attributes
// *****************************************************************************

function xmlGetNsAttrib(node: xmlNodePtr; name: DOMString; out value: DOMString): boolean;
// check if the passed attribute is a namespace declaration attribute
// if so, than return true, and return it's value. If not found, return an empty string;
// otherwise return false and do nothing
var
  test: integer;
  ns: xmlNsPtr;
  prefix: AnsiString;
begin
  // check if it is a namespace-declaration attribute
  test:=check_NsDeclAttr1(name);
  // set the return value (true means, name contains xmlns)
  result := test <> 0;
  // if it is a default ns-decl attribute
  if test = 1 then begin
    // if there is a default ns
    ns:=xmlGetDefaultNs(node);
    if ns<>nil then begin
      // than return true and we are finished
      if ns.href <> nil then begin
        value:=UTF8Decode(ns.href);
      end;
      exit;
    end;
    // if there isn't, return an empty string
    value:='';
    exit;
  // if its a non-default namespace attribute
  end else if test = 2 then begin
    prefix:=UTF8Encode(split_localName(name));
    ns:=node.nsDef;
    while ns <> nil do begin
      if ns.prefix <> nil
        then if (StrComp(ns.prefix,PAnsiChar(prefix))=0)
          then begin
            value:=UTF8Decode(ns.href);
            exit;
          end;
      ns:=ns.next;
    end;
  end;
end;

function xmlSetNsAttrib(doc: IDomDocument; node: xmlNodePtr; name, value: DOMString): boolean;
// check if the passed attribute is a namespace declaration attribute
// if so, than return true, and add it to the nsdef list
// otherwise return false and do nothing
var
  test: integer;
  ns: xmlNsPtr;
  OldValue: DOMString;
begin
  // check if it is a namespace-declaration attribute
  test:=check_NsDeclAttr1(name);
  // set the return value (true means, name contains xmlns)
  result := test <> 0;
  // if it is a default ns-decl attribute
  if test=1 then begin
    // first check, of a default namespace is already defined
    ns:=xmlGetDefaultNs(node);
    if (ns<>nil) then begin
      if (strcomp(ns.href , PAnsiChar(UTF8Encode(Value)))<>0)
        then checkError(NO_MODIFICATION_ALLOWED_ERR)
        // if this default-ns was already defined, we get quit
        else exit;
    end;
    // if it is a default ns attribute, create one and append it to the nsdecl-list
    //
    // first create it; we use nil for the parameter node, because we want
    // to use our own appendNamespace procedure to append the namespace
    // to the nsdecl list of the node
    ns:=(doc as IDomInternal).findOrCreateNewNamespace
      (nil,PAnsiChar(UTF8Encode(Value)),nil);
    // then append it
    appendNamespace(node,ns,true);
    exit;
  end else
  // if it is a non-default ns-decl attribute
  if test=2 then begin
    xmlGetNsAttrib(node,name,OldValue);
    if (OldValue<>'') and (OldValue<>Value) then checkError(NO_MODIFICATION_ALLOWED_ERR);
    // if the same namespace is already defined, then quit
    if OldValue<>'' then exit;      
    // find or create the new namespace
    ns:=(doc as IDomInternal).findOrCreateNewNamespace
      (nil,PAnsiChar(UTF8Encode(value)),
           PAnsiChar(UTF8Encode(split_localName(name))));
    // then append it
    appendNamespace(node,ns,true);
    exit;
  end;
end;

function xmlHasNsAttrib(node: xmlNodePtr; name: DOMString; out exists: boolean): boolean;
var
  test: integer;
  ns: xmlNsPtr;
  OldValue: DOMString;
begin
  exists:=false;
  // check if it is a namespace-declaration attribute
  test:=check_NsDeclAttr1(name);
  // set the return value (true means, name contains xmlns)
  result := test <> 0;
  // if it is a default ns-decl attribute
  if test=1 then begin
    // if there is a default ns
    ns:=xmlGetDefaultNs(node);
    if ns<>nil then begin
      // than return true and we are finished
      exists:=true;
      exit;
    end;
  // if it is a normal ns-decl attribute
  end else if test=2 then begin
    // try to get it's value
    xmlGetNsAttrib(node,name,OldValue);
    // if it has a value <> '', then say that it exists
    if OldValue<>'' then exists:=true;
  end;
end;

function xmlRemoveNsAttrib(doc: IDomDocument; node: xmlNodePtr; name: DOMString): boolean;
var
  test: integer;
  ns: xmlNsPtr;
  prefix: AnsiString;
begin
  // check if it is a namespace-declaration attribute
  test:=check_NsDeclAttr1(name);
  // set the return value (true means, name contains xmlns)
  result := test <> 0;
  // quit, if we don't have a nsdef attribute
  if test = 0 then exit;
  // if it is a default ns-decl attribute
  if test = 1 then begin
    ns:=xmlRemoveDefaultNs(node);
  // if it is a normal ns-decl attribute
  end else begin
    // get the prefix
    prefix:=UTF8Encode(split_localName(name));
    // get the first entry in the nsDef list
    ns:=node.nsDef;
    // loop through the list
    while ns <> nil do begin
      // if its not a default ns
      if ns.prefix <> nil
        // check, if we found the correct prefix
        then if (StrComp(ns.prefix,PAnsiChar(prefix))=0)
          // if we found it
          then begin
            // remove the Namespace from the nsDef list
            ns:=removeNamespace(node,ns);
            break;
          end;
      // get the next entry of the list
      ns:=ns.next;
    end;
  end;
  if ns<>nil then begin
    // add the nsdecl to the list of ns-nodes, that have to be
    // freed at the end
    (doc as IDomInternal).appendNs(ns);
  end;

end;

// *****************************************************************************

function xmlSetPropNode(const parent: xmlNodePtr; const xmlNewPropNode, xmlOldPropNode: xmlAttrPtr): xmlAttrPtr;
begin
  // default
  result := nil;
  // make sure thats assigned
  if (not Assigned(xmlNewPropNode)) then exit;
  // make sure thats ok
  if (xmlNewPropNode.doc <> parent.doc) then checkError(WRONG_DOCUMENT_ERR);
  if Assigned(xmlNewPropNode.parent) then checkError(INUSE_ATTRIBUTE_ERR);
  // check first
  if Assigned(xmlOldPropNode)
     then
       // replace the old one
       result := xmlReplacePropNode(xmlOldPropNode, xmlNewPropNode)
     else
       // make sure we have a parent
       if Assigned(parent)
          then
            // append the new one
            xmlAddPropChild(parent, xmlNewPropNode);
end;

(*
 *  TXDomDocumentBuilder
*)
constructor TDomDocumentBuilder.Create(AFreeThreading: boolean);
begin
  inherited Create;
  FFreeThreading := AFreeThreading;
end;

destructor TDomDocumentBuilder.Destroy;
begin
  inherited Destroy;
end;

function TDomDocumentBuilder.Get_DomImplementation: IDomImplementation;
begin
  Result := TDomImplementation.Create;
end;

function TDomDocumentBuilder.Get_IsNamespaceAware: boolean;
begin
  Result := True;
end;

function TDomDocumentBuilder.Get_IsValidating: boolean;
begin
  Result := True;
end;

function TDomDocumentBuilder.Get_HasAbsoluteURLSupport: boolean;
begin
  Result := False;
end;

function TDomDocumentBuilder.Get_HasAsyncSupport: boolean;
begin
  Result := False;
end;

function TDomImplementation.hasFeature(const feature, version: DOMString): boolean;
begin
  Result := Check_IsSupported(feature, version);
end;

function TDomImplementation.createDocumentType(const qualifiedName, publicId,
  systemId: DOMString): IDomDocumentType;
var
  dtd:        xmlDtdPtr;
  alocalName: DOMString;
begin
  result:=nil;
  alocalName := split_localname(qualifiedName);
  if ((Pos(':', alocalName)) > 0) then begin
    checkError(NAMESPACE_ERR,ClassName);
  end;
  if not IsXmlName(qualifiedName) then checkError(INVALID_CHARACTER_ERR);
  dtd := xmlCreateIntSubSet(nil, PAnsiChar(UTF8Encode(qualifiedName)), PAnsiChar(UTF8Encode(publicId)), PAnsiChar(UTF8Encode(systemId)));
  if dtd <> nil
    then Result := TDomDocumentType.Create(dtd, nil, nil) as IDomDocumentType;
end;

function TDomImplementation.createDocument(const namespaceURI, qualifiedName: DOMString;
  doctype: IDomDocumentType): IDomDocument;
begin
  Result := TDomDocument.Create(self, namespaceURI, qualifiedName,
    doctype) as IDomDocument;
end;

constructor TDomImplementation.Create;
begin
  inherited Create;
end;

destructor TDomImplementation.Destroy;
begin
  inherited Destroy;
end;

// *************************************************************
// TDomeNode Implementation
// *************************************************************

function TDomNode.get_text: DomString;
var
  i:    integer;
  node: IDomNode;
begin
  // concat content of all text node children of node
  Result := '';
  node := self as IDomNode;
  for i := 0 to node.childNodes.length - 1 do begin
    if node.childNodes[i].nodeType = TEXT_NODE then begin
      Result := Result + node.childnodes[i].nodeValue;
    end;
  end;
end;

procedure TDomNode.set_text(const Value: DomString);
var
  node, child: IDomNode;
  Text:        IDomText;
begin
  // replace all children of node with value as text node
  node := self as IDomNode;
  while node.hasChildNodes do begin
    child := node.lastChild;
    node.removeChild(child);
  end;
  Text := get_OwnerOrSelf.createTextNode(Value);
  node.appendChild(Text);
end;

function TDomNode.GetXmlNodePtr: xmlNodePtr;
begin
  Result := fXmlNode;
end;

// IDomNode
function TDomNode.get_nodeName: DOMString;
const
  emptyWString: DOMString = '';
begin
  case fXmlNode.type_ of
    XML_HTML_DOCUMENT_NODE,
    XML_DOCUMENT_NODE: Result := '#document';
    XML_CDATA_SECTION_NODE: Result := '#cdata-section';
    XML_DOCUMENT_FRAG_NODE: Result := '#document-fragment';
    XML_ENTITY_DECL: Result := '#text';
    XML_TEXT_NODE,
    XML_COMMENT_NODE: Result := emptyWString + '#' + UTF8Decode(fXmlNode.Name);
    else Result := UTF8Decode(fXmlNode.Name);
      if Assigned(fXmlNode.ns) and Assigned(fXmlNode.ns.prefix)
         then Result := emptyWString + UTF8Decode(fXmlNode.ns.prefix) + ':' + Result;
  end;
end;

function TDomNode.get_nodeValue: DOMString;
var
  temp1: PAnsiChar;
begin
  case fXmlNode.type_ of
    XML_ATTRIBUTE_NODE:
      begin
        if fXmlNode.children <> nil
          then temp1 := fXmlNode.children.content
          else temp1 := nil;
      end;
    XML_ATTRIBUTE_DECL:
      begin
        temp1:=(xmlAttributePtr(fXmlNode)).defaultValue;
      end;
    else temp1 := fXmlNode^.content;
  end;
  Result := UTF8Decode(temp1);
end;


procedure TDomNode.set_nodeValue(const Value: DOMString);
var
  sValue: AnsiString;
  attr:   xmlAttrPtr;
  attributes: xmlAttributePtr;
  owner: xmlNodePtr;  // the owner element of an default attribute
  ns: xmlNsPtr;
begin
  sValue := UTF8Encode(Value);
  case fXmlNode^.type_ of
    XML_ATTRIBUTE_NODE:
      begin
        attr := xmlAttrPtr(fXmlNode);
        xmlSetAttrValue(attr,sValue);
      end;
    XML_DOCUMENT_NODE,
    XML_DOCUMENT_FRAG_NODE,
    XML_DOCUMENT_TYPE_NODE,
    XML_ENTITY_REF_NODE,
    XML_ENTITY_NODE,
    XML_NOTATION_NODE,
    XML_ELEMENT_NODE:
      begin
      end;
    XML_ATTRIBUTE_DECL:
      begin
        attributes:=xmlAttributePtr(fXmlNode);
        // if it's a 'normal' attribute with a default value,
        // then create a dummy attribute
        if (attributes^.def <> XML_ATTRIBUTE_FIXED) then begin
          // 1) clone the attribute and replace the default attribute with the clone
          // because an attribute declaration carries only the prefix with it,
          // we have to make a namespace lookup on the owner element
          owner:=(self as IXmlDomAttrOwnerRef).GetXmlAttrOwnerPtr;
          // make sure, that the owner exists
          if owner<>nil then begin
            ns:=xmlSearchNs(fXmlNode^.doc,owner,xmlAttributePtr(fXmlNode)^.prefix);
          end else begin
            ns:=nil;
          end;
          fXmlNode:=xmlNodePtr(xmlCloneAttrDecl(xmlAttributePtr(fXmlNode),self.fOwnerDocument,false,ns));
          // 2) set the value of the new attribute
          attr := xmlAttrPtr(fXmlNode);
          xmlSetAttrValue(attr,sValue);
          // xmlAddPropChild(owner,attr);
          // 3) append the cloned attribute to the internal list
          // (fOwnerDocument as IDomInternal).appendAttr(attr);
          // 4) all done
          exit;
        end;
        checkError(NO_MODIFICATION_ALLOWED_ERR);
      end;
  else xmlNodeSetContent(fXmlNode, PAnsiChar(sValue));
  end;
end;

function TDomNode.get_nodeType: DOMNodeType;
begin
  if fXmlNode.type_<> XML_ATTRIBUTE_DECL then begin
    Result := domNodeType(fXmlNode.type_);
  end else begin
    result := ATTRIBUTE_NODE;
  end;
end;

function TDomNode.get_parentNode: IDomNode;
begin
  if fXmlNode.type_= XML_ATTRIBUTE_NODE then begin
    result:=nil;
    exit;
  end;
  if (fXmlNode.parent=xmlNodePtr(fXmlNode.doc)) and (fXmlNode.parent<>nil)
    then result:=fOwnerDocument as IDomNode
    else result := MakeNode(fXmlNode.parent, get_OwnerOrSelf);
end;

function TDomNode.get_childNodes: IDomNodeList;
begin
  Result := TDomNodeList.Create(fXmlNode, get_OwnerOrSelf) as IDomNodeList;
end;

function TDomNode.get_firstChild: IDomNode;
begin
  Result := MakeNode(fXmlNode.children, get_OwnerOrSelf);
end;

function TDomNode.get_lastChild: IDomNode;
begin
  Result := MakeNode(fXmlNode.last, get_OwnerOrSelf);
end;

function TDomNode.get_previousSibling: IDomNode;
begin
  Result := MakeNode(fXmlNode.prev, get_OwnerOrSelf);
end;

function TDomNode.get_nextSibling: IDomNode;
begin
  Result := MakeNode(fXmlNode.Next, get_OwnerOrSelf);
end;

function TDomNode.get_attributes: IDomNamedNodeMap;
begin
  if fXmlNode.type_ = XML_ELEMENT_NODE then Result :=
      TDomNamedNodeMap.Create(fXmlNode, get_OwnerOrSelf) as IDomNamedNodeMap
  else Result := nil;
end;

function TDomNode.get_ownerDocument: IDomDocument;
begin
  Result := fOwnerDocument
end;

function TDomNode.get_namespaceURI: DOMString;
var
  owner: xmlNodePtr; // the ownerElement of an default attribute
  ns: xmlNsPtr;
begin
  Result := '';
  case fXmlNode.type_ of
    XML_ELEMENT_NODE,
    XML_ATTRIBUTE_NODE:
      begin
        if fXmlNode.ns = nil then exit;
        Result := UTF8Decode(fXmlNode.ns.href);
      end;
    XML_ATTRIBUTE_DECL:
      begin
        // because an attribute declaration carries only the prefix with it,
        // we have to make a namespace lookup on the owner element
        owner:=(self as IXmlDomAttrOwnerRef).GetXmlAttrOwnerPtr;
        // make sure, the owner exists
        if owner = nil then exit;
        ns:=xmlSearchNs(fXmlNode.doc,owner,xmlAttributePtr(fXmlNode).prefix);
        if ns=nil then exit;
        Result := UTF8Decode(ns.href);
      end;
  end;
end;

function TDomNode.get_prefix: DOMString;
begin
  Result := '';
  case fXmlNode.type_ of
    XML_ELEMENT_NODE,
    XML_ATTRIBUTE_NODE:
      begin
        if fXmlNode.ns = nil then begin
          if pos('xmlns:',fXmlNode.name)=0 then exit;
          result:='xmlns';
          exit;
        end;
        Result := UTF8Decode(fXmlNode.ns.prefix);
      end;
    XML_ATTRIBUTE_DECL:
      begin
        result:= UTF8Decode(xmlAttributePtr(fXmlNode).prefix);
      end;
  end;
end;

function TDomNode.get_localName: DOMString;
begin
  case fXmlNode.type_ of
    XML_HTML_DOCUMENT_NODE,
    XML_DOCUMENT_NODE: Result := '#document';
    XML_CDATA_SECTION_NODE: Result := '#cdata-section';
    XML_TEXT_NODE,
    XML_COMMENT_NODE,
    XML_DOCUMENT_FRAG_NODE: Result := '#' + UTF8Decode(fXmlNode.Name);
    XML_ATTRIBUTE_DECL:
      begin
        result:=UTF8Decode(xmlAttributePtr(fXmlNode).name);
      end;
    else begin
        Result := UTF8Decode(fXmlNode.name);
        // this is neccessary, because according to the dom2
        // specification localName has to be nil for nodes,
        // that don't have a namespace
        if fXmlNode.ns = nil then begin
          if pos('xmlns:',fXmlNode.name)=0 then begin
            Result := '';
          end else begin
            result:=split_localName(UTF8Decode(fXmlNode.name));
          end;
        end;
      end;
  end;
end;

function TDomNode.insertBefore(const newChild, refChild: IDomNode): IDomNode;
const
  FAllowedChildTypes = [Element_Node, Text_Node, CDATA_Section_Node,
    Entity_Reference_Node, Processing_Instruction_Node, Comment_Node,
    Document_Type_Node, Document_Fragment_Node, Notation_Node];
var
  node: xmlNodePtr;
begin
  if refChild=nil
    then begin
      result:=self.appendChild(newChild);
      exit;
    end;
  node := GetXmlNode(newChild);
  if self.isAncestorOrSelf(node) then CheckError(HIERARCHY_REQUEST_ERR);
  if not (newChild.NodeType in FAllowedChildTypes) then
    CheckError(HIERARCHY_REQUEST_ERR);
  if (GetXmlNode(refChild) = GetXmlNode(refChild.OwnerDocument.documentElement)) then
    if (newChild.nodeType = Element_Node) then CheckError(HIERARCHY_REQUEST_ERR);
  if node.doc <> fXmlNode.doc then CheckError(WRONG_DOCUMENT_ERR);
  if (GetXmlNode(refChild)).parent<>fXmlNode then CheckError(NOT_FOUND_ERR);
  if node.parent <> nil
    then xmlUnlinkNode(node)
      //if it wasn't already in the tree, then remove it from the list of
      //nodes, that have to be freed
  else if node.type_ <> XML_DOCUMENT_FRAG_NODE then begin // don't remove documentFragment nodes!!!
    // remove the node fron the internal list of orphan nodes
    (get_OwnerOrSelf as IDomInternal).removeNode(node);
  end;
  if node.type_ = XML_DOCUMENT_FRAG_NODE then begin
    while NewChild.HasChildNodes do begin
      insertBefore(newChild.ChildNodes[0],refChild)
    end;
  end else begin
    // if you append a text node to a text node with xmlAddPrevSibling, than
    // the text is appended to the first node and the second node is freed.
    // We have to check this case and remove the second node from the internal
    // list than.
    if node.type_ = XML_TEXT_NODE then
      if (GetXmlNode(refChild).type_ = XML_TEXT_NODE) then
          begin
           (fOwnerDocument as IDomInternal).removeNode(GetXmlNode(newChild));
          end;
    node:= xmlAddPrevSibling(GetXmlNode(refChild), GetXmlNode(newChild));
    cleanNsDef(node,true);
  end;

  if node <> nil
    then
      // Used to be: Result := newChild. Which is wrong! See above remark! (MAV)
      Result:=MakeNode(node, get_OwnerOrSelf)
    else
      Result := nil;
end;

function TDomNode.replaceChild(const newChild, oldChild: IDomNode): IDomNode;
var
  nextNode : IDomNode;
begin
  nextNode:=oldChild.nextSibling;
  Result:=removeChild(oldChild);
  if Result = nil then checkError(NOT_FOUND_ERR);
  insertBefore(newChild, nextNode)
end;

function TDomNode.removeChild(const childNode: IDomNode): IDomNode;
var
  node: xmlNodePtr;
  parent: xmlNodePtr;
  ns: xmlNsPtr;
  nsFound: boolean;
begin
  if childNode <> nil then begin
    node := GetXmlNode(childNode);

    if node.parent <> fXmlNode then checkError(NOT_FOUND_ERR);
    if node = nil then checkError(NOT_FOUND_ERR);  //check wether this is correct

    // this code might be useful to speed up things
    // now append all the nsdef entries of the parent elements
    parent:=node.parent;
    nsFound:=false;
    while parent<>nil do begin
      ns:=parent.nsDef;
      // append all nsdef entries of this parent
      while ns <> nil do begin
        //temp:=ns.href;
        //appendNamespace(node,ns,true);
        nsFound:=true;
        break;
        ns:=ns.next;
      end;
      parent:=parent.parent
    end;

    // check, if all the namespaces of the attributes of the removed child are
    // defined on it
    // if not, append them to the nsdef list of the removed child
    if nsFound then addNsdef(node,true);
    xmlUnlinkNode(node);
    // if we append to a normal node, we use this access to the internal list
    (get_OwnerOrSelf as IDomInternal).appendNode(node)
  end else begin
    checkError(NOT_FOUND_ERR);
  end;
  Result := childNode;
end;

(**
 * gdome_xml_n_appendChild:
 * @self:  Node Object ref
 * @newChild:  The node to add
 * @exc:  Exception Object ref
 *
 * Adds the node @newChild to the end of the list of children of this node.
 * If the @newChild is already in the tree, it is first removed. If it is a
 * DocumentFragment node, the entire contents of the document fragment are
 * moved into the child list of this node
 *
 * %GDOME_HIERARCHY_REQUEST_ERR: Raised if this node is of a type that does not
 * allow children of the type of the @newChild node, or if the node to append is
 * one of this node's ancestors or this node itself.
 * %GDOME_WRONG_DOCUMENT_ERR: Raised if @newChild was created from a different
 * document than the one that created this node.
 * %GDOME_NO_MODIFICATION_ALLOWED_ERR: Raised when the node is readonly.
 * Returns: the node added.
 *)
function TDomNode.appendChild(const newChild: IDomNode): IDomNode;
const
  FAllowedChildTypes = [Element_Node, Text_Node, CDATA_Section_Node,
    Entity_Reference_Node, Processing_Instruction_Node, Comment_Node,
    Document_Type_Node, Document_Fragment_Node, Notation_Node];
var
  node: xmlNodePtr;
begin
  node := GetXmlNode(newChild);
  if node = nil then CheckError(Not_Supported_Err);
  //***KB it would be nice to evaluate self dependent conditions first.
  if self.IsReadOnly then CheckError(NO_MODIFICATION_ALLOWED_ERR);
  if not (newChild.NodeType in FAllowedChildTypes) then
    CheckError(HIERARCHY_REQUEST_ERR);
  // w3c: only one root element is allowed
  // check, if we have already a document element, if we try to append an element
  // to the document; if so, raise an error
  if fXmlNode.type_ = XML_DOCUMENT_NODE then if (newChild.nodeType = Element_Node)
      and (xmlDocGetRootElement(xmlDocPtr(fXmlNode)) <> nil) then
      CheckError(HIERARCHY_REQUEST_ERR);
  if node.doc <> fXmlNode.doc then CheckError(WRONG_DOCUMENT_ERR);
  if self.isAncestorOrSelf(node) then CheckError(HIERARCHY_REQUEST_ERR);
  {***KB comment:
    Could be done earlier to improve performance.
    Should be implemented after the "node.parent <> nil" evaluation for performance improvement.
  }
  if IsReadOnlyNode(node.parent) then CheckError(NO_MODIFICATION_ALLOWED_ERR);
  // if the new child is already in the tree, it is first removed
  if node.parent <> nil
    then xmlUnlinkNode(node)
      //if it wasn't already in the tree, then remove it from the list of
      //nodes, that have to be freed
  else if node.type_ <> XML_DOCUMENT_FRAG_NODE then begin // don't remove documentFragment nodes!!!
    // get the interface IDomInternal (from fOwnerdocument, if it exists, otherwise from self)
    (get_ownerOrSelf as IDomInternal).removeNode(node);
  end;
  // if the new child is a document_fragment, then the entire contents of the document fragment are
  // moved into the child list of this node
  if node.type_ = XML_DOCUMENT_FRAG_NODE then begin
    while NewChild.HasChildNodes do begin
      appendChild(newChild.ChildNodes[0])
    end;
  end else begin
    // if you append a text node to a text node with xmlAddChild, than
    // the text is appended to the first node and the second node is freed.
    // We have to check this case and remove the second node from the internal
    // list than.
    if fXmlNode.children <> nil then
      if fXmlNode.children.last <> nil then
        if fXmlNode.children.last.type_ = XML_TEXT_NODE then
          if (node.type_ = XML_TEXT_NODE) then
              begin
               (get_ownerOrSelf as IDomInternal).removeNode((node));
              end;
    // append the node
    node := xmlAddChild(fXmlNode, node);
    // remove nsdef entries, that are not neccessary
    cleanNsdef(node,true);
  end;
  if node <> nil
    then
      // Used to be: Result := newChild. Which is wrong! See above remark! (MAV)
      Result:=MakeNode(node, get_OwnerOrSelf)
    else
      Result := nil;
end;

function TDomNode.hasChildNodes: boolean;
begin
  result := Assigned(fXmlNode.children);
end;

function TDomNode.hasAttributes: boolean;
begin
  Result := (fXmlNode.type_ = XML_ELEMENT_NODE) and (get_Attributes.length > 0);
end;

function TDomNode.cloneNode(deep: boolean): IDomNode;
var
  node:   xmlNodePtr;
  recursive: integer;
  owner: xmlNodePtr; // ownerElement of an default attribute
  ns: xmlNsPtr;
begin
  // set default value
  result:=nil;
  node := nil;
  // different node types have to be handeled differently
  case fXmlNode.type_ of
    XML_ENTITY_NODE, XML_ENTITY_DECL, XML_NOTATION_NODE, XML_DOCUMENT_TYPE_NODE,
    XML_DTD_NODE: CheckError(NOT_SUPPORTED_ERR);
    XML_DOCUMENT_NODE:
      begin
        if deep
          then recursive := 1
          else recursive := 0;
        node := xmlNodePtr(xmlCopyDoc(xmlDocPtr(fXmlNode), recursive));
        if node <> nil then begin
          node.doc := nil;
          // node.ns := xmlCopyNamespace(fXmlNode.ns);
          // build the interface object
          Result := MakeDocument(xmlDocPtr(node), (self as IDomDocument).domImplementation) as IDomNode;
          exit;
        end;
      end;
    XML_ATTRIBUTE_DECL:
      begin
        // because an attribute declaration carries only the prefix with it,
        // we have to make a namespace lookup on the owner element
        owner:=(self as IXmlDomAttrOwnerRef).GetXmlAttrOwnerPtr;
        // make sure, that the owner exists
        if owner<>nil then begin
          ns:=xmlSearchNs(fXmlNode.doc,owner,xmlAttributePtr(fXmlNode).prefix);
        end else begin
          ns:=nil;
        end;
        node:=xmlNodePtr(xmlCloneAttrDecl(xmlAttributePtr(fXmlNode),self.fOwnerDocument,false,ns));
        (fOwnerDocument as IDomInternal).appendAttr(xmlAttrPtr(node));
      end;
  else
    node:=xmlCloneNode(fXmlNode,fOwnerDocument,deep);
    if node.type_=XML_ATTRIBUTE_NODE
      then (fOwnerDocument as IDomInternal).appendAttr(xmlAttrPtr(node))
      else (fOwnerDocument as IDomInternal).appendNode(node);
  end;
  if assigned(node) then begin
    // build the interface object
    Result := MakeNode(node, fOwnerDocument);
  end;
end;

procedure TDomNode.normalize;
begin
  xmlNormalize(fXmlNode);
end;

function TDomNode.IsSupported(const feature, version: DOMString): boolean;
begin
  Result := Check_IsSupported(feature, version);
end;

constructor TDomNode.Create(ANode: xmlNodePtr; ADocument: IDomDocument);
begin
  inherited Create;
  fXmlNode := ANode;
  // the owner Document of a Document is nil! (w3c.org)
  // todo: implement this check in the procedure makeNode!
  if ANode.type_=XML_DOCUMENT_NODE
    then fOwnerDocument:=nil
    else fOwnerDocument := ADocument;
end;

destructor TDomNode.Destroy;
begin
  fOwnerDocument := nil;
  inherited Destroy;
end;

{ TDomNodeList }

constructor TDomNodeList.Create(AParent: xmlNodePtr; ADocument: IDomDocument);
  // create a IDomNodeList from a var of type xmlNodePtr
  // xmlNodePtr is the same as xmlNodePtrList, because in libxml2 there is no
  // difference in the definition of both
begin
  inherited Create;
  FParent := AParent;
  FXpathObject := nil;
  fOwnerDocument := ADocument;
end;


constructor TDomNodeList.Create(AXpathObject: xmlXPathObjectPtr;
  ADocument: IDomDocument);
  // create a IDomNodeList from a var of type xmlNodeSetPtr
  //  xmlNodeSetPtr = ^xmlNodeSet;
  //  xmlNodeSet = record
  //    nodeNr : longint;                { number of nodes in the set  }
  //    nodeMax : longint;              { size of the array as allocated  }
  //    nodeTab : PxmlNodePtr;       { array of nodes in no particular order  }
  //  end;
begin
  inherited Create;
  FParent := nil;
  FXpathObject := AXpathObject;
  fOwnerDocument := ADocument;
end;

destructor TDomNodeList.Destroy;
begin
  fOwnerDocument := nil;
  if FXPathObject <> nil then begin
    try
      // todo 5: find out, why this causes a problem
      xmlXPathFreeObject(FXPathObject);
    except
    end;
  end;
  inherited Destroy;
end;

function TDomNodeList.get_item(index: integer): IDomNode;
// get an item from a nodelist
var
  node: xmlNodePtr;
  i:    integer;
begin
  // assign index to i
  i := index;
  // set node to nil
  node := nil;
  begin
    // if we have a nodelist with a parent
    if FParent <> nil then begin
      // get the first entry of the list
      node := FParent.children;
      // walk through the list i times forward, but not beyond the end
      while (i > 0) and (node.Next <> nil) do begin
        dec(i);
        node := node.Next
      end;
      // raise an error, if we are at the end, but i isn't zero
      if i > 0 then checkError(INDEX_SIZE_ERR);
    // if we have a nodelist as array from an xpath result
    end else begin
      if FXPathObject <> nil then node :=
          xmlXPathNodeSetItem(FXPathObject.nodesetval, i)
      else checkError(INVALID_ACCESS_ERR);
    end;
  end;
  // create the result from the xmlNodePtr
  Result := MakeNode(node, fOwnerDocument);
end;

function TDomNodeList.get_length: integer;
// get the length of a nodelist
var
  node: xmlNodePtr;
  i:    integer;
begin
  // if it is a nodelist with a parent
  if FParent <> nil then begin
    i := 1;
    node := FParent.children;
    // count the children
    if node <> nil then while (node.Next <> nil) do begin
        inc(i);
        node := node.Next
      end else i := 0;
    Result := i
  // if it is an xpath result array
  end else begin
    begin
      // and it does exist
      if FXPathObject.nodesetval<>nil
        // get the size of the array
        then Result := FXPathObject.nodesetval.nodeNr
        else result := 0;
    end
  end;
end;

function TDomNodeList.get_xml: DomString;
var
  i: integer;
  delim: DOMString;
begin
  // libxml returns unix-like strings in the moment;
  delim:=#10;
  result:='';
  // cyle trough the nodelist
  for i:=0 to self.get_length-1 do begin
    // append the xml of the current node to the result
    result:=result+delim+(self.get_item(i) as IDomNodeEx).xml;
  end;
end;

{ TDomNamedNodeMap }

function TDomNamedNodeMap.get_item(index: integer): IDomNode;
// get item no i from the named node map
// index = 0..length-1
// similar to NodeList.get_item
// in the moment only attributes and default attributes are supported
// todo: implement it for entities and notations

var
  node: xmlNodePtr;
  i:    integer;
  notation: xmlNotationPtr;
  entity:   xmlEntityPtr;
  attr: xmlAttrPtr;
  attributes: xmlAttributePtr;
begin
  attr := nil;
  result:=nil;
  if fnnmType<>nnmAttributes then begin

    // get the entities or notations of the internal dtd
    if fXmlInternalDtd<>nil then begin
      if (fXmlInternalDtd.entities <> nil) and (fnnmType=nnmEntities) then begin
        entity:=xmlGetHashEntry(xmlHashTablePtr(fXmlInternalDtd.entities), index);
        if entity <> nil then begin
          // create the result as IDomNode
          result:=(TDomEntity.Create(entity,fOwnerDocument)) as IDomNode;
          // all done
          exit;
        end;
        // if there are entries int the internal and external dtd, than search
        // again with the correct index
        index:=index-xmlHashSize(fXmlInternalDtd.entities);
      end;
      if (fXmlInternalDtd.notations <> nil) and (fnnmType=nnmNotations) then begin
        notation:=xmlGetHashEntry(xmlHashTablePtr(fXmlInternalDtd.notations), index);
        if notation <> nil then begin
          // create the result as IDomNode
          result:=(TDomNotation.Create(notation,fOwnerDocument)) as IDomNode;
          // all done
          exit;
        end;
        // if there are entries int the internal and external dtd, than search
        // again with the correct index
        index:=index-xmlHashSize(fXmlInternalDtd.notations);
      end;
    end;

    // get the entities or notations of the external dtd
    if fXmlExternalDtd<>nil then begin
      if (fXmlExternalDtd.entities <> nil) and (fnnmType=nnmEntities) then begin
        entity:=xmlGetHashEntry(xmlHashTablePtr(fXmlExternalDtd.entities), index);
        if entity=nil then exit;
        // create the result as IDomNode
        result:=(TDomEntity.Create(entity,fOwnerDocument)) as IDomNode;
        // all done
        exit;
      end;
      if (fXmlExternalDtd.notations <> nil) and (fnnmType=nnmNotations) then begin
        notation:=xmlGetHashEntry(xmlHashTablePtr(fXmlExternalDtd.notations), index);
        if notation=nil then exit;
        // create the result as IDomNode
        result:=(TDomNotation.Create(notation,fOwnerDocument)) as IDomNode;
        // all done
        exit;
      end;
    end;
    // all done
    exit;
  end;

  // not supported for named node map <> attributes yet
  if fOwnerElement=nil then checkError(NOT_SUPPORTED_ERR);
  i := index;

  // get the first entry of the named node map; can be nil
  node := get_xmlAttributes;

  // if the first entry exists, cycle to the i-th item
  // node is nil, if the named nodemap is empty
  inc(i);
  if node<>nil then begin
    while (i > 0) and (node <> nil) do begin
      dec(i);
      if i=0 then break;
      node := node.Next
    end;
  end;

  // if the named node map isn't empty and the named item was found
  if  (node <> nil) and (i=0) then begin
    // create the wrapper object from the node
    Result := MakeNode(node, fOwnerDocument);

    // all done
    exit;
  end else begin
    dec(i);
    // check for default attributes
    if fElement <> nil then begin
      attributes:=fElement.attributes;
      if attributes<>nil then begin

        // the loop is so designed, that i=0 means, the right
        // attributes was found, so we have to start the search
        // with i=index+1
        inc(i);

        //loop through all attributes, defined on this element
        while (i>0) and (attributes <> nil) do begin
          if attributes.def <> XML_ATTRIBUTE_IMPLIED then begin
            // decrement only, if an attribute with this name
            // doesn't exist as normal attribute
            attr:=xmlHasProp(fOwnerElement,attributes.name);
            if assigned(attr) and (attr.type_=XML_ATTRIBUTE_DECL)
              then dec(i);
            // leave the loop, if the right attribute was found
            if i=0 then break;
          end;
          attributes:=attributes.nexth;
        end;

        // if a default attribute was found
        if (attributes<>nil) and (i=0)
          then begin
            // create the wrapper object
            // we cannot use MakeNode here, because we have to pass the OwnerElement
            result:=TDomAttr.Create(attr,fOwnerDocument,fOwnerElement) as IDomNode;
            // all done
            exit;
          end
          else checkError(INDEX_SIZE_ERR);
      end;
    end
  end;
end;

function TDomNamedNodeMap.get_length: integer;
var
  node: xmlNodePtr;
  attr: xmlAttrPtr;
  attributes: xmlAttributePtr;
begin
  result := 0;
  node:=get_xmlAttributes;
  if fnnmType<>nnmAttributes then begin

    // count the entities and notations of the internal dtd
    if fXmlInternalDtd<>nil then begin
      if (fXmlInternalDtd^.entities <> nil) and (fnnmType=nnmEntities) then begin
        result := xmlHashSize(fXmlInternalDtd^.entities);
      end;
      if (fXmlInternalDtd^.notations <> nil) and (fnnmType=nnmNotations) then begin
        result := xmlHashSize(fXmlInternalDtd^.notations);
      end;
    end;

    // count the entities and notations of the external dtd
    if fXmlExternalDtd<>nil then begin
      if (fXmlExternalDtd^.entities <> nil) and (fnnmType=nnmEntities) then begin
        result := result + xmlHashSize(fXmlExternalDtd^.entities);
      end;
      if (fXmlExternalDtd^.entities <> nil) and (fnnmType=nnmNotations) then begin
        result := result + xmlHashSize(fXmlExternalDtd^.notations);
      end;
    end;
  end else begin

    // count normal attributes
    if node<>nil then begin
      inc(result);
      while (node^.next<>nil) do begin
        inc(result);
        node := node^.next
      end;
    end;

    // count the default attributes
    if fElement<>nil then begin
      attributes:=fElement^.attributes;
      while attributes <> nil do begin
        if attributes^.def<>XML_ATTRIBUTE_IMPLIED then begin
          // increment only, if an attribute with this name
          // doesn't exist as normal attribute
          attr:=xmlHasProp(fOwnerElement,attributes^.name);
          if not(assigned(attr) and (attr^.type_<>XML_ATTRIBUTE_DECL))
            then inc(result);
        end;
        attributes:=attributes^.nexth;
      end;
    end;
  end;
end;


function TDomNamedNodeMap.getNamedItem(const Name: DOMString): IDomNode;
// this function returns a namedItem, identified by its name, from a named node map
// normal attributes, default attributes, enitites and notations must be handled
// seperatly
var
  node:     xmlNodePtr;
  entity:   xmlEntityPtr;
  notation: xmlNotationPtr;
  doc:      xmlDocPtr;
  attr:     xmlAttrPtr;
  //attributes: xmlAttributePtr;
begin
  result := nil;
  node := get_xmlAttributes;
  if node=nil then begin
    if fnnmType=nnmEntities then begin

      // get the libxml2 document pointer
      doc:=xmlDocPtr(getXmlNode(fOwnerDocument as IDomNode));

      // try to find it in the list of the internal DTD
      entity:=xmlGetDocEntity(doc, PAnsiChar(UTF8Encode(Name)));

      // if it wasn't found, try to find it in the list of the external DTD
      if entity=nil then begin
        entity:=xmlGetDTDEntity(doc, PAnsiChar(UTF8Encode(Name)));
      end;

      // create the result as IDomNode
      result:=(TDomEntity.Create(entity,fOwnerDocument)) as IDomNode;

      // all done
      exit;
    end;
    if fnnmType=nnmNotations then begin

      // if there is an internal dtd, search the notation there
      if Assigned(fXmlInternalDtd)
        then notation := xmlGetDtdNotationDesc(fXmlInternalDtd,PAnsiChar(UTF8Encode(Name)))
        else notation := nil;

      // if there is an external dtd and the notation wasn't found yet
      if Assigned(fXmlExternalDtd) and (not Assigned(notation))
        then notation:=xmlGetDtdNotationDesc(fXmlExternalDtd,PAnsiChar(UTF8Encode(Name)));

      // create the result as IDomNode
      result:=(TDomNotation.Create(notation,fOwnerDocument)) as IDomNode;

      // all done
      exit;
    end;

  end;
  attr:=xmlHasProp(fOwnerElement, PAnsiChar(UTF8Encode(Name)));
  result:=MakeAttr(attr,fOwnerDocument,fOwnerElement);
end;

function TDomNamedNodeMap.setNamedItem(const newItem: IDomNode): IDomNode;
var
  xmlNewPropNode: xmlNodePtr;
  xmlOldPropNode: xmlAttrPtr;
begin
  // default
  result := nil;

  // check
  if (not Assigned(newItem)) then checkError(NOT_SUPPORTED_ERR);

  // now include it
  xmlNewPropNode := GetXmlNode(newItem);

  // additional checks
  if (xmlNewPropNode^.type_ <> XML_ATTRIBUTE_NODE) then checkError(HIERARCHY_REQUEST_ERR);

  // check if it is a default attribute
  xmlOldPropNode:=xmlHasProp(fOwnerElement, xmlNewPropNode^.name);
  if assigned(xmlOldPropNode) and (xmlOldPropNode^.type_ = XML_ATTRIBUTE_DECL) then begin
    // raise an error if its a fixed attribute
    check_fixedAttr(xmlOldPropNode);
    // if it's a default attribute, don't remove it
    // todo: should it be returned as orphan attribute?
    xmlOldPropNode:=nil;
  end;

  // set the new node
  xmlOldPropNode := xmlSetPropNode(fOwnerElement,
                                   xmlAttrPtr(xmlNewPropNode),
                                   xmlOldPropNode);

  // remove the new one from internal list
  (fOwnerDocument as IDomInternal).removeAttr(xmlAttrPtr(xmlNewPropNode));

  // check to add the old one to internal list
  if Assigned(xmlOldPropNode)
     then begin
       (fOwnerDocument as IDomInternal).appendAttr(xmlOldPropNode);
       Result := TDomAttr.Create(xmlOldPropNode, fOwnerDocument) as IDomAttr;
     end;
end;

function TDomNamedNodeMap.removeNamedItem(const Name: DOMString): IDomNode;
var
  attr:  xmlAttrPtr;
begin
  if (fnnmType=nnmEntities) or (fnnmType=nnmNotations)
    then checkError(NO_MODIFICATION_ALLOWED_ERR);
  // check that this exists
  if (not Assigned(fOwnerElement)) then checkError(NOT_SUPPORTED_ERR);
  attr := xmlHasProp(FOwnerElement, PAnsiChar(UTF8Encode(Name)));
  if (not Assigned(attr)) then checkError(NOT_FOUND_ERR);
  // check if it is a fixed attribute
  check_fixedAttr(attr);
  // if it is assigned and not an default attr, than remove it
  if assigned(attr) and (attr^.type_ <> XML_ATTRIBUTE_DECL) then begin
    // remove it from list, but still hold the information
    xmlUnlinkPropNode(fOwnerElement, attr);
    // add to the list of orphan attributes
    (fOwnerDocument as IDomInternal).appendAttr(attr);
    // result me the interface
    Result := MakeNode(xmlNodePtr(attr), fOwnerDocument);
  // if it is assigned, but an default attr, than return it
  end else if assigned(attr) and (attr^.type_ = XML_ATTRIBUTE_DECL) then begin
    // result me the interface
    Result := MakeNode(xmlNodePtr(attr), fOwnerDocument);
  // if it is not assigned, return nil;
  end else begin
    result:=nil;
  end;
end;

function TDomNamedNodeMap.getNamedItemNS(const namespaceURI,
  localName: DOMString): IDomNode;
var
  node: xmlNodePtr;
begin
  // if namespaceURI=nil, do the same as getNamedItem
  if namespaceURI=''
    then begin
      result:=self.getNamedItem(localName);
      exit;
    end;

  // set the default value
  result := nil;

  // get the attribute with the given namespaceURI and name
  node := xmlNodePtr(xmlHasNSProp(FOwnerElement, PAnsiChar(UTF8Encode(localName)), PAnsiChar(UTF8Encode(namespaceURI))));

  // if we try to get a namespace declaration attributes,
  // search it again without its default namespace, but with the correct prefix
  if (node=nil) and (namespaceURI=XMLNS_NAMESPACE_URI) then begin
    node := xmlNodePtr((xmlHasProp(FOwnerElement, PAnsiChar(UTF8Encode('xmlns:'+localName)))));
  end;

  if node=nil then exit;

  // create the wrapper for the result
  result := MakeNode(node, fOwnerDocument);
end;

function TDomNamedNodeMap.setNamedItemNS(const newItem: IDomNode): IDomNode;
var xmlNewPropNode: xmlNodePtr; xmlOldPropNode: xmlAttrPtr; namespaceURI: PAnsiChar;
begin
  // if namespaceURI=nil, do the same as setNamedItem
  if newItem.namespaceURI = ''
    then begin
      result:=self.setNamedItem(newItem);
      exit;
    end;
  // default
  result := nil;

  // check
  if (not Assigned(newItem)) then checkError(NOT_SUPPORTED_ERR);

  // now include it
  xmlNewPropNode := GetXmlNode(newItem);

  // additional checks
  if (xmlNewPropNode^.type_ <> XML_ATTRIBUTE_NODE) then checkError(HIERARCHY_REQUEST_ERR);

  // check the namespaceURI
  if Assigned(xmlNewPropNode^.ns)
     then namespaceURI := xmlNewPropNode^.ns^.href
     else namespaceURI := nil;

  // check if it is a default attribute
  xmlOldPropNode:=xmlHasNsProp(fOwnerElement, xmlNewPropNode.Name, namespaceURI);
  if assigned(xmlOldPropNode) and (xmlOldPropNode.type_ = XML_ATTRIBUTE_DECL) then begin
    // raise an error if its a fixed attribute
    if xmlAttributePtr(xmlOldPropNode)^.def = XML_ATTRIBUTE_FIXED then begin
      checkError(NO_MODIFICATION_ALLOWED_ERR);
    end;
    // if it's a default attribute, don't remove it
    // todo: should it be returned as orphan attribute?
    xmlOldPropNode:=nil;
  end;

  // set the new node
  xmlOldPropNode := xmlSetPropNode(fOwnerElement,
                                   xmlAttrPtr(xmlNewPropNode),
                                   xmlOldPropNode
                                   );

  // add the namespace of the attribute to the list of namespaces, declared
  // on this element
  appendNamespace(fOwnerElement,xmlNewPropNode^.ns);

  // remove the new one from internal list
  (fOwnerDocument as IDomInternal).removeAttr(xmlAttrPtr(xmlNewPropNode));

  // check to add the old one to internal list
  if Assigned(xmlOldPropNode)
     then begin
       (fOwnerDocument as IDomInternal).appendAttr(xmlOldPropNode);
       Result := TDomAttr.Create(xmlOldPropNode, fOwnerDocument) as IDomAttr;
     end;
end;

function TDomNamedNodeMap.removeNamedItemNS(const namespaceURI,
  localName: DOMString): IDomNode;
var
  attr:  xmlAttrPtr;
begin
  // if namespaceURI=nil, do the same as removeNamedItem
  if namespaceURI=''
    then begin
      result:=self.removeNamedItem(localName);
      exit;
    end;  // default
  result := nil;
  // check that this exists
  if (not Assigned(fOwnerElement)) then exit;
  attr := (xmlHasNsProp(fOwnerElement, PAnsiChar(UTF8Encode(localName)), PAnsiChar(UTF8Encode(namespaceURI))));
  // check, if it was found
  if (not Assigned(attr)) then checkError(NOT_FOUND_ERR);
  // check, if it was a fixed attribute, that must not be removed
  check_fixedAttr(attr);
  if assigned(attr) and (attr.type_ <> XML_ATTRIBUTE_DECL) then begin
    // remove it from list, but still hold the information
    xmlUnlinkPropNode(fOwnerElement, attr);
    // link this to internal document
    (fOwnerDocument as IDomInternal).appendAttr(attr);
    // result me the interface
    Result := MakeNode(xmlNodePtr(attr), fOwnerDocument);
  end else if assigned(attr) and (attr.type_ = XML_ATTRIBUTE_DECL) then begin
    // result me the interface
    Result := MakeNode(xmlNodePtr(attr), fOwnerDocument);
  end else begin
    result:=nil;
  end;
end;

constructor TDomNamedNodeMap.Create(ANamedNodeMap: xmlNodePtr;
  AOwnerDocument: IDomDocument; typ: TDomNamedNodeMapType = nnmAttributes; externalDtd: xmlDtdPtr = nil);
begin
  fOwnerDocument := AOwnerDocument;
  if typ = nnmAttributes then begin
    fXmlInternalDtd := nil;
    fXmlExternalDtd := nil;
    fOwnerElement := ANamedNodeMap;
    // check, wether the node has an ownerDocument
    if assigned(fOwnerElement.doc) then begin
      //get the element description from the dtd
      if fOwnerElement.doc.intSubset<>nil then begin
        fElement:=xmlGetDtdElementDesc(fOwnerElement.doc.intSubset,fOwnerElement.name);
      end else begin
        fElement:=xmlGetDtdElementDesc(fOwnerElement.doc.extSubset,fOwnerElement.name);
      end;
    end;
  end else begin
    fXmlInternalDtd := xmlDtdPtr(ANamedNodeMap);
    fXmlExternalDtd:= externalDtd;
    fOwnerElement := nil;
  end;
  fnnmType:=typ;
  inherited Create;
end;

destructor TDomNamedNodeMap.Destroy;
begin
  fOwnerDocument := nil;
  fOwnerElement := nil;
  fXmlInternalDtd := nil;
  fXmlExternalDtd:= nil;
  inherited Destroy;
end;

function TDomNamedNodeMap.get_xmlAttributes: xmlNodePtr;
begin
  if FOwnerElement <> nil
    then Result := xmlNodePtr(FOwnerElement.properties)
    else Result := nil;
end;

{ TDomAttr }

function TDomAttr.getXmlAttribute: xmlAttrPtr;
begin
  Result := xmlAttrPtr(xmlNode);
end;

function TDomAttr.get_name: DOMString;
begin
  Result := inherited get_nodeName;
end;

function TDomAttr.get_ownerElement: IDomElement;
begin
  // for a default attribute, the OwnerElement is stored in fOwnerElement
  // when the attribute-wrapper is created
  if fOwnerElement<>nil
    then result:= MakeNode(fOwnerElement,fOwnerDocument) as IDomElement
    // for a normal attribute, we find out the OwnerElement in this way
    else begin
      result:=MakeNode(fXmlNode.parent,fOwnerDocument) as IDomElement;
    end;
end;

function TDomAttr.get_specified: boolean;
begin
  if fXmlNode.type_= XML_ATTRIBUTE_DECL
    then result := false
    else result := True;
end;

function TDomAttr.get_value: DOMString;
begin
  Result := inherited get_nodeValue;
end;

procedure TDomAttr.set_value(const attributeValue: DOMString);
begin
  inherited set_nodeValue(attributeValue);
  // check wether the attribute is of type default attribute (specified=false)
  // in this case ONLY fOwnerElement is <> nil
  if assigned(fOwnerElement)
    // if so, append the dummy attribute to the OwnerElement
    then xmlAddPropChild(fOwnerElement,xmlAttrPtr(fXmlNode));
end;

constructor TDomAttr.Create(AAttribute: xmlAttrPtr; ADocument: IDomDocument;
  OwnerElement: xmlNodePtr=nil);
begin
  fOwnerElement:=OwnerElement;
  inherited Create(xmlNodePtr(AAttribute), ADocument);
end;

destructor TDomAttr.Destroy;
begin
  inherited Destroy;
end;


//***************************
//TDomElement Implementation
//***************************

function TDomElement.GetXmlElement: xmlNodePtr;
begin
  Result := xmlNode;
end;

function TDomElement.get_tagName: DOMString;
begin
  Result := self.get_nodeName;
end;

function TDomElement.getAttribute(const Name: DOMString): DOMString;
var
  attr:  xmlAttrPtr;
begin
  // set the default return value
  result:='';
  // check, if we are looking for a namespace attribute
  // if so, get it and quit
  if xmlGetNsAttrib(fXmlNode,name,result) then exit;

  // now use the libxml2 default function, to look for the attribute
  attr := xmlHasProp(xmlElement, PAnsiChar(UTF8Encode(Name)));

  // if an attribute was found, and it was a default attribute
  if assigned(attr) and (attr.type_ = XML_ATTRIBUTE_DECL) then begin
    // get the default value
    result:=UTF8Decode(xmlAttributePtr(attr).defaultValue);
    // and we are done
    exit;
  end;

  // if an attribute was found and it has content
  if Assigned(attr) and Assigned(attr.children)
  { TODO : use libxml2-function instead of children.content }
     // then get the content
     then Result := UTF8Decode(attr.children.content)
     // else return an empty string
     else Result := '';
end;

procedure TDomElement.setAttribute(const Name, Value: DOMString);
var
  attr:         xmlAttrPtr;
  node:         xmlNodePtr;
begin
  // check for valid name
  if not IsXMLName(Name) then checkError(INVALID_CHARACTER_ERR);

  // if it is a nsdecl-attribute, than process it, and you are done
  if xmlSetNsAttrib(get_OwnerOrSelf,fXmlNode, name, value) then exit;

  // check wether this attribute exists in the dtd as fixed attribute
  attr := xmlHasProp(xmlElement, PAnsiChar(UTF8Encode(Name)));
  check_fixedAttr(attr);
  // get the xmlElement
  node := xmlElement;
  // set the new property
  attr := xmlSetProp(node, PAnsiChar(UTF8Encode(Name)), PAnsiChar(UTF8Encode(Value)));
  attr^.parent := node;
  attr^.doc := node^.doc;
end;

procedure TDomElement.removeAttribute(const Name: DOMString);
var
  attr: xmlAttrPtr;
begin
  // check, if its a namespace declaration attribute
  if xmlRemoveNsAttrib(self.fOwnerDocument,fXmlNode,Name) then exit;

  // check if it is a default attribute
  attr := xmlHasProp(xmlElement, PAnsiChar(UTF8Encode(Name)));
  check_fixedAttr(attr);

  // remove the attribute and free it
  xmlUnsetProp(xmlElement,PAnsiChar(UTF8Encode(Name)));
end;

function TDomElement.getAttributeNode(const Name: DOMString): IDomAttr;
var
  attr:  xmlAttrPtr;
begin
  result:=nil;
  attr := xmlHasProp(xmlElement, PAnsiChar(UTF8Encode(Name)));
  // create the wrapper; if attr is a default attribute, store
  // the ownerElement in the wrapper
  result:=MakeAttr(attr,fOwnerDocument,xmlElement);
end;

function TDomElement.setAttributeNode(const newAttr: IDomAttr): IDomAttr;
var xmlNewPropNode, xmlOldPropNode: xmlAttrPtr;
begin
  // default
  result := nil;
  // check
  if (not Assigned(newAttr)) then exit;

  // now include it
  xmlNewPropNode := xmlAttrPtr(GetXmlNode(newAttr));

  // check, if an attribute with the name of newAttr already exists
  xmlOldPropNode := xmlHasProp(xmlElement, xmlNewPropNode.Name);

  // check, if it is a fixed default attribute and clear it, if it's a default
  // attribute
  check_fixedAttr(xmlOldPropNode,true);

  xmlOldPropNode := xmlSetPropNode(xmlElement, xmlNewPropNode, xmlOldPropNode);

  // remove the new one from internal list
  (fOwnerDocument as IDomInternal).removeAttr(xmlNewPropNode);

  // check to add the old one to internal list
  if Assigned(xmlOldPropNode)
     then begin
       (fOwnerDocument as IDomInternal).appendAttr(xmlOldPropNode);
       Result := TDomAttr.Create(xmlOldPropNode, fOwnerDocument) as IDomAttr;
     end;
end;

function TDomElement.removeAttributeNode(const oldAttr: IDomAttr): IDomAttr;
var
  xmlAttr,xmlAttr2: xmlAttrPtr;
  namespaceURI,name: AnsiString;
  ns, ns1: xmlNsPtr;
begin
  // default
  result := nil;
  // check
  if (not Assigned(oldAttr)) then exit;
  // check, that in my node
  xmlAttr := xmlAttrPtr(GetXmlNode(oldAttr));
  // now get the namespaces URI of the old Attr:
  namespaceURI:=UTF8Encode(oldAttr.namespaceURI);
  if namespaceURI<>''
    then name:=UTF8Encode(oldAttr.localName)
    else name:=UTF8Encode(oldAttr.Name);
  // if the attribute to remove has no namespace, do the same as
  // removeAttributeNode
  if namespaceURI<>''
    then xmlAttr2:=xmlHasNSProp(xmlElement, PAnsiChar(name), PAnsiChar(namespaceURI))
    else xmlAttr2:=xmlHasProp(xmlElement, PAnsiChar(name));
  // check, if it is a fixed attribute
  check_fixedAttr(xmlAttr2);
  if (not Assigned(xmlAttr2)) then checkError(NOT_FOUND_ERR);
  if (xmlAttr2.type_ <> XML_ATTRIBUTE_DECL) then begin
    // unlink it
    xmlUnlinkPropNode(xmlElement, xmlAttr);
    ns1:=xmlAttr.ns;
    //Check, if an default attribute needs the current namespace
    xmlAttr2:=xmlHasNSProp(xmlElement, PAnsiChar(name), PAnsiChar(namespaceURI));
    // if not, then remove the namespace from the nsdef list of the attr.parent
    if (ns1<>nil) and (xmlAttr2=nil) then begin
      ns:=removeNamespace(xmlElement,ns1);
      if (ns<>nil) then begin
        xmlFreeNs(ns);
        // add it back again, if it is needed by an other attribute or node
        // in the current subtree
        addNsdef(xmlElement,true);
      end;
    end;
    // store it to internal list
    (fOwnerDocument as IDomInternal).appendAttr(xmlAttr);
    // result me
    result := oldAttr;
  end else begin
    result:=nil;
  end;
end;

function TDomElement.getElementsByTagName(const Name: DOMString): IDomNodeList;
begin
  try
    // todo: check Name is NOT a XPath expression
    // if IsXmlName(Name) then
    Result := selectNodes('.//'+Name)
  except
    result := nil;
  end;

  if not Assigned(result)
     then
       Result := TDomNodeList.Create(xmlNodePtr(nil), fOwnerDocument);
end;

function TDomElement.getAttributeNS(const namespaceURI, localName: DOMString): DOMString;
var
  attr: xmlAttrPtr;
begin
  if (namespaceURI='')
    or (get_ExposeNsDefAttribs and (namespaceURI = XMLNS_NAMESPACE_URI)) then begin
    result:=self.getAttribute(localName);
    exit;
  end;
  attr := xmlHasNSProp(xmlElement, PAnsiChar(UTF8Encode(localName)), PAnsiChar(UTF8Encode(namespaceURI)));

  // check if it is an default attribute
  if assigned(attr) and (attr.type_ = XML_ATTRIBUTE_DECL) then begin
    // get the default value from the dtd
    result:=UTF8Decode(xmlAttributePtr(attr).defaultValue);
    // all done
    exit;
  end;
  if Assigned(attr) and Assigned(attr.children)
{ TODO : use libxml2-function instead of children.content }
     then Result := UTF8Decode(attr.children.content)
     else Result := '';
end;

procedure TDomElement.setAttributeNS(const namespaceURI, qualifiedName, Value: DOMString);
var
  attr: xmlAttrPtr;
  ns: xmlNsPtr;
begin
  check_ValidQualifierNS(namespaceURI, qualifiedName);
  if (namespaceURI='')
    or (get_ExposeNsDefAttribs and (namespaceURI = XMLNS_NAMESPACE_URI)) then begin
    self.setAttribute(qualifiedName,Value);
    exit;
  end;
  check_NsDeclAttr(namespaceURI, qualifiedName);
  // check wether this attribute exists in the dtd as fixed attribute
  attr:=xmlHasNSProp(xmlElement, PAnsiChar(UTF8Encode(split_localname(qualifiedName))),
    PAnsiChar(UTF8Encode(namespaceURI)));
  check_fixedAttr(attr);
  // create the new namespace
  ns:=(fOwnerDocument as IDomInternal).getNewNamespace(namespaceURI, split_Prefix(qualifiedName));
  // set the new attribute
  xmlSetNSProp(xmlElement,
               ns,
               PAnsiChar(UTF8Encode(split_localname(qualifiedName))),
               PAnsiChar(UTF8Encode(Value))
               );
  // add the namespace of the attribute to the list of namespaces, declared
  // on this element
  appendNamespace(xmlElement,ns);
end;

procedure TDomElement.removeAttributeNS(const namespaceURI, localName: DOMString);
var
  attr, xmlattr2:         xmlAttrPtr;
  parent: xmlNodePtr;
  ns, ns1: xmlNsPtr;
  snamespaceURI, sname: AnsiString;
begin
  // if the namespaceURI is nil (nil isn't possible in pascal, so we use the
  // empty string instead), than the effect must be the same as removeAttribute
  if (namespaceURI='') or (namespaceURI = XMLNS_NAMESPACE_URI) then begin
    self.removeAttribute(localName);
    exit;
  end;
  snamespaceURI:=UTF8Encode(namespaceURI);
  sname:=UTF8Encode(localName);
  // check if it is a default attribute
  attr := xmlHasNsProp(xmlElement, PAnsiChar(UTF8Encode(localName)), PAnsiChar(UTF8Encode(namespaceURI)));
  check_fixedAttr(attr);
  if (attr <> nil) and (attr^.type_<> XML_ATTRIBUTE_DECL) then begin
    parent:=attr.parent;
    ns1:=attr.ns;
    xmlRemoveProp(attr);
    // Check, if an default attribute needs the current namespace
    xmlAttr2:=xmlHasNSProp(xmlElement, PAnsiChar(sname), PAnsiChar(snamespaceURI));
    // remove the nsdef entry of the attribute, if it has an namespace, that
    // is not needed by an default attribute
    if (ns1 <> nil) and (xmlAttr2 = nil) then begin
      ns:=removeNamespace(parent,ns1);
      if ns<>nil then begin
        xmlFreeNs(ns);
        // add it back again, if it is needed by an other attribute or node
        // in the current subtree
        addNsdef(parent,true);
      end;
    end;
  end;
end;

function TDomElement.getAttributeNodeNS(const namespaceURI, localName: DOMString): IDomAttr;
var
  attr: xmlAttrPtr;
begin
  if (namespaceURI='')
    or (get_ExposeNsDefAttribs and (namespaceURI = XMLNS_NAMESPACE_URI)) then begin
    result:=self.getAttributeNode(localName);
    exit;
  end;
  attr := xmlHasNSProp(xmlElement, PAnsiChar(UTF8Encode(localName)), PAnsiChar(UTF8Encode(namespaceURI)));
  // create the wrapper object
  result:=MakeAttr(attr,fOwnerDocument,xmlElement);
end;

function TDomElement.setAttributeNodeNS(const newAttr: IDomAttr): IDomAttr;
var
  xmlNewPropNode: xmlNodePtr;
  xmlOldPropNode: xmlAttrPtr;
  namespaceURI:  PAnsiChar;
  //ns: xmlNsPtr;
begin
  // default
  result := nil;

  // check
  if (not Assigned(newAttr)) then exit;

  // now include it
  xmlNewPropNode := GetXmlNode(newAttr);

  // check the namespaceURI
  if Assigned(xmlNewPropNode.ns)
     then namespaceURI := xmlNewPropNode.ns.href
     else namespaceURI := nil;

  if namespaceUri=nil then begin
    // check, if an attribute with the name of newAttr already exists
    xmlOldPropNode := xmlHasProp(xmlElement, xmlNewPropNode^.Name);
    // and clear it, if its an default attribute
    check_fixedAttr(xmlOldPropNode,true);
  end else begin
    xmlOldPropNode := xmlHasNsProp(xmlElement, xmlNewPropNode.Name,PAnsiChar(namespaceURI));
    check_fixedAttr(xmlOldPropNode,true);
  end;

  // set the new node

  xmlOldPropNode := xmlSetPropNode(xmlElement,
                                   xmlAttrPtr(xmlNewPropNode),
                                   xmlOldPropNode);

  // add the namespace of the attribute to the list of namespaces, declared
  // on this element
  appendNamespace(xmlElement,xmlNewPropNode.ns);

  // remove the new one from internal list
  (fOwnerDocument as IDomInternal).removeAttr(xmlAttrPtr(xmlNewPropNode));

  // check to add the old one to internal list
  if Assigned(xmlOldPropNode)
     then begin
       (fOwnerDocument as IDomInternal).appendAttr(xmlOldPropNode);
       Result := TDomAttr.Create(xmlOldPropNode, fOwnerDocument) as IDomAttr;
     end;

end;

function TDomElement.getElementsByTagNameNS(const namespaceURI,
  localName: DOMString): IDomNodeList;
begin
  if namespaceURI = '*' then begin
    // what is meant by namespaceURI = * ?
    // a) a namespace exists
    // b) namespace does not matter
    // case b) is currently implemented
    if localName <> '*' then begin
      result := selectNodes('.//*[local-name() = "'+localName+'"]');
    end else begin
      result := selectNodes('.//*');
    end;
  end else begin
    if localName <> '*' then begin
      result := selectNodes('.//*[(namespace-uri() = "'+namespaceURI+'") and (local-name() = "'+localName+'")]');
    end else begin
      result := selectNodes('.//*[namespace-uri() = "'+namespaceURI+'"]');
    end;
  end;
end;

function TDomElement.hasAttribute(const Name: DOMString): boolean;
var
  attr: xmlAttrPtr;
  tmp:  boolean;
begin
  // w3c.org:
  // Returns true when an attribute with a given name is specified on this element
  //  or has a default value, false otherwise

  // check, if we are looking for a namespace attribute
  // if so, return the result
  if xmlHasNsAttrib(fXmlNode,name,tmp) then begin
    result:=tmp;  // this is needed for the conversion to wordbool in libxml.pas
    exit;
  end;

  // use the libxml default function to find the attribute
  attr:=xmlHasProp(xmlElement, PAnsiChar(UTF8Encode(name)));

  // if it was found, and it is a default attribute
  if assigned(attr) and (attr.type_=XML_ATTRIBUTE_DECL) then begin
    // than check, if a default value is assigned
    if assigned(xmlAttributePtr(attr).defaultValue)
      /// if so, then return true
      then result:=true
      // else, return false
      else result:=false;
    // all done
    exit;
  end;
  // no check, if a normal attribute was found
  if Assigned(attr)
    // if so, return true
    then Result := True
    // else, return false
    else Result := False;
end;

function TDomElement.hasAttributeNS(const namespaceURI, localName: DOMString): boolean;
var
  attr: xmlAttrPtr;
begin
  // if the namespaceURI is nil (in our case: an empty string), do the same
  // as self.hasAttribute
  if (namespaceURI='')
    or (get_ExposeNsDefAttribs and (namespaceURI = XMLNS_NAMESPACE_URI)) then begin
    result:=self.hasAttribute(localName);
    exit;
  end;
  // w3c.org:
  // Returns true when an attribute with a given local name and namespace URI
  //  is specified on this element or has a default value, false otherwise
  attr:=xmlHasNsProp(xmlElement, PAnsiChar(UTF8Encode(localName)),PAnsiChar(UTF8Encode(namespaceURI)));
  if assigned(attr) and (attr^.type_=XML_ATTRIBUTE_DECL) then begin
    if assigned(xmlAttributePtr(attr)^.defaultValue)
      then result:=true
      else result:=false;
    // all done
    exit;
  end;
  if Assigned(attr)
    then Result := True
    else Result := False;
end;

procedure TDomElement.normalize;
begin
  inherited normalize;
end;

constructor TDomElement.Create(AElement: xmlNodePtr; ADocument: IDomDocument);
begin
  inherited Create(xmlNodePtr(AElement), ADocument);
end;

destructor TDomElement.Destroy;
begin
  inherited Destroy;
end;


//************************************************************************
// functions of TDomDocument
//************************************************************************

constructor TDomDocument.Create(DOMImpl: IDomImplementation;
  const namespaceURI, qualifiedName: DOMString;
  doctype: IDomDocumentType);
var
  root:       xmlNodePtr;
  ns:         xmlNsPtr;
  wLocalName: DOMString;
  xmlDoc:  xmlDocPtr;
begin
  // special hack to check creation of an empty DOM
  if (qualifiedName = '') and (namespaceURI <> '') then checkError(NAMESPACE_ERR);

  check_ValidQualifierNS(namespaceURI, qualifiedName);

  fDomImpl := DOMImpl;
  if (doctype <> nil) then
    if (doctype.ownerDocument <> nil) then
      if ((doctype.ownerDocument as IUnknown) <> (self as IUnknown)) then
        checkError(WRONG_DOCUMENT_ERR);

  // at this point we need our internal stuff
  // so create it here, because otherwise next call
  // to getNewNamespace will cause ACCESS VIOLATION
  FNsList:=TList.Create;
  FAttrList := TList.Create;
  FNodeList := TList.Create;
  FPrefixList:=TStringList.Create;
  FUriList:=TStringList.Create;
  fXsltStylesheet:=nil;

  // check if we need to create a new namespace
  if (namespaceUri = '')
     then ns := nil
     else ns := getNewNamespace(namespaceURI, split_prefix(qualifiedName));

  xmlDoc := xmlNewDoc(nil);

  wLocalName := split_localname(qualifiedName);
  if (wLocalName <> '')
     then xmlDoc^.children := xmlNewDocNode(xmlDoc, ns, PAnsiChar(UTF8Encode(wLocalName)), nil);
  if xmlDoc^.children<>nil
    then appendNamespace(xmlDoc^.children,ns);
  //Get root-node
  root := xmlNodePtr(xmlDoc);

  //Create root-node as pascal object
  inherited Create(root, nil);
  (fDomImpl as IDomDebug).doccount:=(fDomImpl as IDomDebug).doccount+1;
  setDefaults;
end;

constructor TDomDocument.Create(DOMImpl: IDomImplementation);
var
  root:   xmlNodePtr;
  xmlDoc: xmlDocPtr;
begin
  fDomImpl := DOMImpl;
  xmlDoc := xmlNewDoc(nil);
  //Get root-node
  root := xmlNodePtr(xmlDoc);
  FNsList:=TList.Create;
  FAttrList := TList.Create;
  FNodeList := TList.Create;
  FPrefixList:=TStringList.Create;
  FURIList:=TStringList.Create;
  //Create root-node as pascal object
  inherited Create(root, nil);
  (fDomImpl as IDomDebug).doccount:=(fDomImpl as IDomDebug).doccount+1;
  setDefaults;
end;

constructor TDomDocument.Create(DOMImpl: IDomImplementation; aUrl: DomString);
var
  fn:     string;
begin
  fDomImpl := DOMImpl;
  {$ifdef mswindows}
  // libxml accepts only '/' as path delimiter
  fn := UTF8Encode(StringReplace(aUrl, '\', '/', [rfReplaceAll]));
  {$else}
  fn := aUrl;
  {$endif}
  //Load DOM from file
  xmlInitParser();
  // at this point we need our internal stuff
  // so create it here, because otherwise next call
  // to getNewNamespace will cause ACCESS VIOLATION
  FAttrList := TList.Create;
  FNodeList := TList.Create;
  FNsList:=TList.Create;
  FPrefixList:=TStringList.Create;
  FURIList:=TStringList.Create;

  if (loadFrom_XmlParserCtx(xmlCreateFileParserCtxt(PAnsiChar(fn))))
     then begin
       fXsltStylesheet:=nil;
       (fDomImpl as IDomDebug).doccount:=(fDomImpl as IDomDebug).doccount+1;
     end;
  setDefaults;
end;

constructor TDomDocument.Create(DOMImpl: IDomImplementation;
  docnode: xmlNodePtr);
begin
  fDomImpl := DOMImpl;
  fXsltStylesheet:=nil;
  FAttrList := TList.Create;
  FNodeList := TList.Create;
  FNsList:=TList.Create;
  FPrefixList:=TStringList.Create;
  FURIList:=TStringList.Create;
  //Create root-node as pascal object
  inherited Create(docnode, nil);
  (fDomImpl as IDomDebug).doccount:=(fDomImpl as IDomDebug).doccount+1;
  setDefaults;
end;

destructor TDomDocument.Destroy;
var
  i:     integer;
  AAttr:  xmlAttrPtr;
  ANode:  xmlNodePtr;
  ANs:    xmlNsPtr;
begin
  // check if we need to free the content
  if GetXmlDocPtr<>nil
     then begin

       // remove our global stored nodes
       try
         for i := 0 to FNodeList.Count - 1 do begin
           ANode := FNodeList[i];

           // make sure that this is not a DOM linked one
           // Is it possible to have nodes with setted parent node in this list?
           // Answer:
           // If there is no error in the code, than it isn't, but better be
           // shure not to free anything twice!
           if Assigned(ANode) and (not Assigned(ANode.parent)) then begin

             // at least remove this node
             xmlFreeNode(ANode);
            end; // if Assigned(Node) ...
         end; // for
       finally
         // free the internal list object
         FNodeList.Free;
       end;

       // remove our global saved attribute list
       try
         for i := 0 to FAttrList.Count - 1 do
         begin
           // get item to check
           AAttr := FAttrList[i];
           // make sure that this is not a DOM linked one
           // todo: is it possible to have nodes with setted parent node in this list
           if Assigned(AAttr) and (not Assigned(AAttr.parent))
              then begin
                 xmlFreeProp(AAttr);
              end;
         end;
       finally
         // free the internal list object
         FreeAndNil(FAttrList);
       end;

       // remove our global saved namespace list
       try
         for i := 0 to FNsList.Count - 1 do
         begin
           // get item to check
           ANs := FNsList[i];
           if Assigned(ANs)
              then begin
                xmlFreeNs(ANs);
              end;
         end;
       finally
         // free the internal list object
         FreeAndNil(FNsList);
       end;

       // this frees the document or the doucment plus the additional
       // stylesheet information
       if fXsltStylesheet=nil
         then
           xmlFreeDoc(GetXmlDocPtr)
         else
           begin
             xsltFreeStylesheet(fXsltStylesheet);
             fXsltStylesheet:=nil;
           end;

       fXmlNode:=nil;
       // setup the internal information
       (fDomImpl as IDomDebug).doccount:=(fDomImpl as IDomDebug).doccount-1;

       // remove helper objects
       FreeAndNil(FPrefixList);
       FreeAndNil(FURIList);
     end; // if Assigned(fXmlDocPtr) ....

  // go on
  inherited Destroy;
end;

// IDomDocument
function TDomDocument.get_doctype: IDomDocumentType;
var
  dtd1, dtd2: xmlDtdPtr;
begin
  dtd1 := GetXmlDocPtr.intSubset;
  dtd2 := GetXmlDocPtr.extSubset;
  if (dtd1 <> nil) or (dtd2 <> nil) then Result :=
      TDomDocumentType.Create(dtd1, dtd2, self)
  else Result := nil;
end;

function TDomDocument.get_domImplementation: IDomImplementation;
begin
  Result := fDomImpl;
end;

function TDomDocument.get_documentElement: IDomElement;
var
  root1:  xmlNodePtr;
  FGRoot: TDomElement;
begin
  root1 := xmlDocGetRootElement(GetXmlDocPtr);
  if assigned(root1)
    then FGRoot := TDomElement.Create(root1, self)
    else FGRoot := nil;
  Result := FGRoot;
end;

procedure TDomDocument.set_documentElement(const IDomElement: IDomElement);
begin
  checkError(NOT_SUPPORTED_ERR);
end;

function TDomDocument.createElement(const tagName: DOMString): IDomElement;
var
  AElement: xmlNodePtr;
begin
  result:=nil;
  if not IsXMLName(tagName) then checkError(INVALID_CHARACTER_ERR);
  AElement := xmlNewDocNode(GetXmlDocPtr, nil, PAnsiChar(UTF8Encode(tagName)), nil);
  if AElement <> nil then begin
    AElement^.parent := nil;
    fNodeList.Add(AElement);
    Result := TDomElement.Create(AElement, self)
  end;
end;

function TDomDocument.createDocumentFragment: IDomDocumentFragment;
var
  node: xmlNodePtr;
begin
  node := xmlNewDocFragment(GetXmlDocPtr);
  if node <> nil then begin
    fNodeList.Add(node);
    result := TDomDocumentFragment.Create(node, self)
  end else Result := nil;
end;

function TDomDocument.createTextNode(const Data: DOMString): IDomText;
var
  textNode: xmlNodePtr;
begin
  textNode := xmlNewDocText(GetXmlDocPtr, PAnsiChar(UTF8Encode(Data)));
  if textNode <> nil then begin
    fNodeList.Add(textNode);
    result := TDomText.Create(textNode, self)
  end
  else result:=nil;
end;

function TDomDocument.createComment(const Data: DOMString): IDomComment;
var
  node:  xmlNodePtr;
begin
  node := xmlNewDocComment(GetXmlDocPtr, PAnsiChar(UTF8Encode(Data)));
  if node <> nil then begin
    fNodeList.Add(node);
    result := TDomComment.Create((node), self)
  end
  else result:=nil;
end;

function TDomDocument.createCDATASection(const Data: DOMString): IDomCDATASection;
var
  sData: AnsiString;
  node:  xmlNodePtr;
begin
  result:=nil;
  sData := UTF8Encode(Data);
  node := xmlNewCDataBlock(GetXmlDocPtr, PAnsiChar(sData), length(sData));
  if node <> nil then begin
    FNodeList.Add(node);
    Result := TDomCDataSection.Create(node, self)
  end;
end;

function TDomDocument.createProcessingInstruction(const target,
  Data: DOMString): IDomProcessingInstruction;
var
  AProcessingInstruction: xmlNodePtr;
begin
  result:=nil;
  if not IsXMLChars(target) then CheckError(INVALID_CHARACTER_ERR);
  AProcessingInstruction := xmlNewPI(PAnsiChar(UTF8Encode(target)), PAnsiChar(UTF8Encode(Data)));
  if AProcessingInstruction <> nil then begin
    AProcessingInstruction.parent := nil;
    AProcessingInstruction.doc := GetXmlDocPtr;
    FNodeList.Add(AProcessingInstruction);
    Result := TDomProcessingInstruction.Create(AProcessingInstruction, self)
  end;
end;

function TDomDocument.createAttribute(const Name: DOMString): IDomAttr;
var
  AAttr: xmlAttrPtr;
begin
  result:=nil;
  if not IsXMLName(Name) then checkError(INVALID_CHARACTER_ERR);
  AAttr := xmlNewDocProp(GetXmlDocPtr, PAnsiChar(UTF8Encode(Name)), nil);
  AAttr.parent := nil;
  if AAttr <> nil then begin
    FAttrList.Add(AAttr);
    Result := TDomAttr.Create(AAttr, self)
  end;
end;

function TDomDocument.createEntityReference(const Name: DOMString): IDomEntityReference;
var
  AEntityReference: xmlNodePtr;
begin
  result:=nil;
  if not IsXMLName(Name) then checkError(INVALID_CHARACTER_ERR);
  AEntityReference := xmlNewReference(GetXmlDocPtr, PAnsiChar(UTF8Encode(Name)));
  if AEntityReference <> nil then begin
    FNodeList.Add(AEntityReference);
    Result := TDomEntityReference.Create(AEntityReference, self)
  end;
end;

function TDomDocument.getElementsByTagName(const tagName: DOMString): IDomNodeList;
begin
  result := (self.get_documentElement as IDomNodeSelect).selectNodes('//' + tagName);
end;

function TDomDocument.importNode(importedNode: IDomNode; deep: boolean): IDomNode;
var
  node,inNode:   xmlNodePtr;
  owner: xmlNodePtr;
  inDoc: xmlDocPtr;
  temp: AnsiString;
  ns: xmlNsPtr;
begin
  // set default value
  result:=nil;
  node := nil;
  temp:= importedNode.namespaceURI;
  inNode:=(importedNode as IXmlDomNodeRef).GetXmlNodePtr;
  // different node types have to be handeled differently
  case integer(inNode^.type_) of
    XML_ENTITY_NODE, XML_ENTITY_DECL, XML_NOTATION_NODE, XML_DOCUMENT_TYPE_NODE,
      XML_DTD_NODE, XML_DOCUMENT_NODE: CheckError(NOT_SUPPORTED_ERR);

    XML_ATTRIBUTE_DECL:
      begin
        owner:=(importedNode as IXmlDomAttrOwnerRef).GetXmlAttrOwnerPtr;
        inDoc:=xmlDocPtr((importedNode.ownerDocument as IXmlDomNodeRef).GetXmlNodePtr);
        ns:=xmlSearchNs(indoc,owner,xmlAttributePtr(inNode)^.prefix);
        node:=xmlNodePtr(xmlCloneAttrDecl(xmlAttributePtr(inNode),self,false,ns));
      end;
  else
    node:=xmlCloneNode(inNode, self, deep);
  end;

  if Assigned(node)
    then
      begin
        node^.doc:=GetXmlDocPtr;

        if node.type_=XML_ATTRIBUTE_NODE
          then
            (self as IDomInternal).appendAttr(xmlAttrPtr(node))
          else
            (self as IDomInternal).appendNode(node);

        // I think xmlSetTreeDoc does not what it was supposed to do!
        // I would expect it to recurse and modify the doc for all nodes
        // but, for one, it doesn't change the doc for attributes and
        // it doesn't change the doc for attribute values... (MAV) 
        //
        xmlSetTreeDoc(node, GetXmlDocPtr);

        // build the interface object
        Result := MakeNode(node, self);
      end;
end;


function TDomDocument.createElementNS(const namespaceURI,
  qualifiedName: DOMString): IDomElement;
var
  AElement:     xmlNodePtr;
  ns: xmlNsPtr;
begin
  // default
  result := nil;

  // check qualifier and URI
  check_ValidQualifierNS(namespaceURI, qualifiedName);

  ns:=getNewNamespace(namespaceURI, split_Prefix(qualifiedName));
  AElement := xmlNewDocNode(GetXmlDocPtr,
                            ns,
                            PAnsiChar(UTF8Encode(split_localname(qualifiedName))),
                            nil
                           );

  if Assigned(AElement)
     then begin
       // add the namespace of the element to the list of namespaces,
       // declared for this element
       if AElement^.ns<>nil
         then begin
           //AElement.ns._private:=nil;
           appendNamespace(AElement,AElement.ns);
         end;
       FNodeList.Add(AElement);
       Result := TDomElement.Create(AElement, self);
     end;
end;

procedure TDomDocument.injectDifferentDocElement(docElement: xmlDocPtr);
begin
  xmlFreeDoc(GetXmlDocPtr());
  fXmlNode := xmlNodePtr(docElement);
end;

function TDomDocument.createAttributeNS(const namespaceURI,
  qualifiedName: DOMString): IDomAttr;
var
  Attr: xmlAttrPtr;
begin
  // default
  result := nil;

  // check qualifier and URI
  check_ValidQualifierNS(namespaceURI, qualifiedName);
  check_NsDeclAttr(namespaceURI, qualifiedName);

  Attr := xmlNewNsProp(nil,
                       getNewNamespace(namespaceURI, split_Prefix(qualifiedName)),
                       PAnsiChar(UTF8Encode(split_localname(qualifiedName))),
                       nil
                      );

  if Assigned(Attr)
     then begin
       Attr^.doc := GetXmlDocPtr;
       FAttrList.Add(Attr);
       Result := TDomAttr.Create(Attr, self);
     end;
end;

function TDomDocument.getElementsByTagNameNS(const namespaceURI,
  localName: DOMString): IDomNodeList;
var
  docElement: IDomElement;
  tmp1:       IDomNodeList;
begin
  if (namespaceURI = '*') then begin
    if (localname <> '*') then begin
      docElement := self.get_documentElement;
      tmp1 := (docElement as IDomNodeSelect).selectNodes('//*[local-name()="' +
        localname + '"]');
      Result := tmp1;
    end else begin
      docElement := self.get_documentElement;
      tmp1 := (docElement as IDomNodeSelect).selectNodes('//*');
      Result := tmp1;
    end
  end else begin
    docElement := self.get_documentElement;
    tmp1 := (docElement as IDomNodeSelect).selectNodes('//*[(local-name() = "'+
      localname+'") and (namespace-uri() = "'+namespaceURI+'")]');
    Result := tmp1;
  end;
end;

function TDomDocument.getElementById(const elementId: DOMString): IDomElement;
var
  AAttr:    xmlAttrPtr;
  AElement: xmlNodePtr;
begin
  AAttr := xmlGetID(GetXmlDocPtr, PAnsiChar(UTF8Encode(elementID)));
  if AAttr <> nil
    then AElement := AAttr^.parent
    else AElement := nil;
  if AElement <> nil
    then Result := TDomElement.Create(AElement, self)
    else result:=nil;
end;

// IDomParseOptions
function TDomDocument.get_async: boolean;
begin
  Result := fAsync;
end;

function TDomDocument.get_preserveWhiteSpace: boolean;
begin
  Result := fPreserveWhiteSpace;
end;

function TDomDocument.get_resolveExternals: boolean;
begin
  Result := fResolveExternals;
end;

function TDomDocument.get_validate: boolean;
begin
  Result := fValidate;
end;

procedure TDomDocument.setDocOnCurrentLevel(next: xmlNodePtr; doc: xmlDocPtr);
begin
  while next <> nil do
  begin
    next^.doc := doc;
    setDocOnNextLevel(next^.children, doc);
    setDocOnNextLevel(xmlNodePtr(next^.properties), doc);
    next := next^.next;
  end;
end;

procedure TDomDocument.setDocOnNextLevel(next: xmlNodePtr; doc: xmlDocPtr);
begin
  while next <> nil do
  begin
    next^.doc := doc;
    setDocOnCurrentLevel(next^.next, doc);
    next := next^.children;
  end;
end;

procedure TDomDocument.set_async(Value: boolean);
begin
  fAsync := True;
end;

procedure TDomDocument.set_preserveWhiteSpace(Value: boolean);
begin
  fPreserveWhiteSpace := Value;
  if Value
    then xmlKeepBlanksDefault(1)
    else xmlKeepBlanksDefault(0);
end;

procedure TDomDocument.set_resolveExternals(Value: boolean);
begin
  if Value
    then xmlSubstituteEntitiesDefault(1)
    else xmlSubstituteEntitiesDefault(0);
  fResolveExternals := Value;
end;

procedure TDomDocument.set_validate(Value: boolean);
begin
  fValidate := Value;
end;

// IDomPersist
function TDomDocument.get_xml: DOMString;
var
  CString, encoding: PAnsiChar;
  length: longint;
  format: integer;
begin
  // default
  result := '';

  // check encoding
  if fEncoding = ''
     then encoding := GetXmlDocPtr^.encoding
     else encoding := PAnsiChar(AnsiString(lowercase(fEncoding)));

  // if the xml document doesn't have an encoding or a documentElement,
  // return an empty string (it works like this in msdom)
  if (Assigned(GetXmlDocPtr^.children) or (encoding <> ''))
    then begin
      // handle format
      if fPrettyPrint
         then format := -1
         else format := 0;

      // do the streaming
      try

        // here we have to make sure that all namespaces are well declared
        cleanNsDef(xmlDocGetRootElement(GetXmlDocPtr),true);
   
        // Dump this to my memory
        xmlDocDumpFormatMemoryEnc(GetXmlDocPtr, CString, @length, encoding, format);

        try
          // check decoding
          if not isEncodingUTF8(encoding)
            then
              Result:=CString
            else
              Result:=UTF8Decode(CString);
        finally
          // always free my memory buffer
          xmlFree(CString);
        end;

      finally
        // !!! ALLWAYS repair our ns nodes previous
        // xmlUnprepareNSSerialization(xmlDocGetRootElement(fXmlDocPtr));
      end;
    end;
end;

// IDomPersistHTML
function TDomDocument.get_html: DOMString;
var
  CString:  PAnsiChar;
  encoding: PAnsiChar;
  length:   longint;
  temp:     AnsiString;
begin
  result:='';
  temp := fEncoding;
  if fEncoding = ''
    then encoding := GetXmlDocPtr.encoding
    else encoding := PAnsiChar(temp);
  // if the xml document doesn't have an encoding or a documentElement,
  // return an empty string (it works like this in msdom)
  if (GetXmlDocPtr.children<>nil) or (encoding<>'')
    then begin
      // set encoding
      // htmlSetMetaEncoding(fXmlDocPtr, encoding);
      // create a buffer
      //buffer := xmlBufferCreate;
      try
        //htmlDocContentDumpFormatOutput(, fXmlDocPtr, encoding, format);
        htmlDocDumpMemory(GetXmlDocPtr, @CString, @length);
        // get the text
        //CString := xmlBufferContent(buffer);
        try
          // set the prolog
          // THIS IS A HACK !!!!
          if (encoding = '')
             then
               Result := '<?xml version="1.0"' + ' ?>'#13#10
             else
               Result := '<?xml version="1.0"' + ' encoding="' + encoding + '"' + ' ?>'#13#10;

          // make xhtml header
          // check encoding
          if not isEncodingUTF8(encoding)
            then
              Result := Result + {'<html xmlns="http://www.w3.org/1999/xhtml"' + } CString { Copy(CString, 6, maxint) }
            else
              Result := Result + {'<html xmlns="http://www.w3.org/1999/xhtml"' + Copy( } UTF8Decode(CString){, 6, maxint)};
        finally
          // free string
          xmlFree(CString);  //this works with the new dll from 2001-01-25
        end;
      finally
        //xmlBufferFree(buffer);
      end;
    end;
end;

function TDomDocument.asyncLoadState: integer;
begin
  Result := 0;
end;

type
  TErrCtx = record
              document: TDomDocument;
              errMsg:   AnsiString;
            end;

  TErrCtxPtr = ^TErrCtx;

function countSubstringOccurance(s,sub: AnsiString): integer;
var
  n: integer;
begin
  result := 0;
  n := Pos(sub,s);
  while n <> 0 do begin
    Inc(result);
    s := Copy(s,n+Length(sub),Length(s)-(n+Length(sub))+1);
    n := Pos(sub,s);
  end;
end;

// the following definitions overwrite the definitions in libxml_xmlerror.inc
// this is neccessary, until we find a better solution
type
  xmlGenericErrorFunc = procedure(ctx: Pointer; msg, arg1: PAnsiChar; arg2: integer; arg3: PAnsiChar); cdecl;

procedure xmlSetGenericErrorFunc(ctx: Pointer; handler: xmlGenericErrorFunc); cdecl; external LIBXML2_SO;

procedure errorHandler(ctx: pointer; msg, arg1: PAnsiChar; arg2: integer; arg3: PAnsiChar); cdecl;
// writes the formatted error message into the field document.fReason
// IMPORTANT:
// ctx.document must be initialized with a pointer to the document
// of type TDomDocument OR ctx.document is nil and
// ctx.errMsg is initialized with an empty string
// document.fLine must be initialized with -1;
var
  error:        AnsiString;
  sMsg, sArg1, sArg3:  AnsiString;
  cArg: char;
  iArg2: integer;
begin
  sMsg  := msg;
  sMsg  := adjustLinebreaks(sMsg);
  iArg2:=arg2;
  error:='';
  if pos('%s',sMsg) > 0 then begin
    if pos('%d',sMsg) > 0 then begin
      if countSubstringOccurance(sMsg,'%s') = 2 then begin
        sArg1 := arg1;
        sArg3 := arg3;
        try
          error := Format(sMsg,[sArg1,iArg2,sArg3]);
        except
          error := 'Unknown format of error msg: '+sMsg;
        end;
      end else begin
        sArg1 :=arg1;
        try
          error := format(sMsg, [sArg1, iArg2]);
        except
          error := 'Too many parameters in error msg: '+sMsg;
        end;
      end;
    end else begin
      sArg1 :=arg1;
      if sArg1<>''
        then error := format(sMsg, [sArg1]);
    end;
  end else if pos('%d',sMsg) > 0 then begin
    iArg2:=integer(arg1);
    error := format(sMsg, [iArg2]);
  end else begin if pos('%c',sMsg) > 0 then begin
    cArg:=char(arg1);
    sMsg:=stringReplace(sMsg,'%c','%s',[rfReplaceAll]);
    error:=format(sMsg, [cArg]);
  end else
    error := sMsg;
  end;

  error := adjustLinebreaks(error);

  // check if we are parsing a document or are evaluating an xpath expressions
  if ctx<>nil then begin
    if TErrCtxPtr(ctx)^.document<>nil then begin
      with TDomDocument(TErrCtxPtr(ctx)^.document) do begin
        fReason := fReason + CRLF+error;
        // if a dezimal format char is in the format string and fLine was not set yet
        if (pos('%d',sMsg) > 0) and (fLine=-1) then begin
          // assign the line number of the error
          fLine:=iArg2;
        end;
        // a validity error isn't an error, if fValidate is false
        // reset the error line in this case
        if (pos('validity',error) > 0) and (not fValidate) then begin
          fLine:=-1;
        end;
      end;
    end else begin
      // deliver XPATH error string;
      TErrCtxPtr(ctx)^.ErrMsg:=TErrCtxPtr(ctx)^.ErrMsg+error;
    end;
  end;
end;

function TDomDocument.loadFrom_XmlParserCtx(ctxt: xmlParserCtxtPtr): boolean;
var
  ErrCtx: TErrCtx;
  lineno: integer;
  tmp: AnsiString;
begin
  Result := False;
  try
    if Assigned(ctxt)
    then begin
      // parser validates always
      ctxt.validate := -1;
      ErrCtx.document := self;
      ErrCtx.errMsg:='';
      self.fLine    := -1;  // no error
      self.fReason  := '';  // no reason
      self.fUrl     := '';  // no file was parsed wrong
      xmlSetGenericErrorFunc(@ErrCtx, errorHandler);
      // todo: async (separate thread)

      // libxml2 keeps the setting of resolveExternals, even if the
      // document is freed.
      // we have to set the global var of libxml2 from the content
      // of the field fResolveExternals, that is kept in the wrapper
      // of the document
      // WARNING: it is not threadsafe, to use different values for
      // this option in different threads
      set_resolveExternals(fResolveExternals);
      if (xmlParseDocument(ctxt) <> 0{error}) or
         (ctxt^.wellFormed = 0{false}) or
         (Fvalidate and (ctxt^.valid = 0{false}))
         then begin
           lineno:=ctxt.linenumbers;
           tmp:=inttostr(lineno);
           xmlFreeDoc(ctxt.myDoc);
           ctxt.myDoc := nil;
           fUrl:=ctxt.input.filename;
           processError;
         end
         else begin
           // this frees the document or the doucment plus the additional
           // stylesheet information
           if fXsltStylesheet=nil
             then
               xmlFreeDoc(GetXmlDocPtr)
             else
               begin
                 xsltFreeStylesheet(fXsltStylesheet);
                 fXsltStylesheet:=nil;
               end;

           inherited Destroy;

           Result := True;
           // create an DomDocument with this
           inherited Create(xmlNodePtr(ctxt^.myDoc), nil);
           // remove the whitespace, that wasn't removed before
           if not self.fPreserveWhiteSpace then begin
             self.removeWhitespace;
           end;
     // set the field fEncoding
     self.fEncoding:=ctxt.myDoc.encoding;
         end;
      end; // if assigned
  finally
     // do it always
     xmlFreeParserCtxt(ctxt);
     // reset error handler
     xmlSetGenericErrorFunc(nil, errorHandler);
  end;
end;

function TDomDocument.loadxml(const Value: DOMString): boolean;
// Load dom from string;
var
  pxml: AnsiString;
  ok: boolean;
begin
  xmlInitParser();
  fEncoding:=extractEncoding(Value);

  if isEncodingUTF8(fEncoding) or isEncodingUTF16(fEncoding)
    then
      ok:=loadfrom_XmlParserCtx(xmlCreateDocParserCtxt(PAnsiChar(UTF8Encode(value))))
    else
      begin
        // we NEED this copy to create an complete memory area
        pxml := Value;
        // load this context from memory
        ok := loadfrom_XmlParserCtx(xmlCreateDocParserCtxt(PAnsiChar(pxml)));
      end;

  Result:=ok;
end;

function TDomDocument.loadFromStream(const stream: TStream): boolean;
var
  tmp     : AnsiString;
begin
  SetLength(tmp, stream.Size-stream.Position);
  stream.Read(tmp[1], stream.Size-stream.Position);
  Result:=(Self as IDomPersist).loadxml(tmp);
end;

function TDomDocument.load(Source: DOMString): boolean;
// Load dom from file
var fn, fn1:   AnsiString;
begin
  {$ifdef mswindows}
  // libxml accepts only '/' as path delimiter
  fn1 := (StringReplace(Source, '\', '/', [rfReplaceAll]));
  // escape spaces
  fn := UTF8Encode(StringReplace(fn1, ' ', '%20', [rfReplaceAll]));
  {$else}
  fn := Source;
  {$endif}
  xmlInitParser();
  if fileExists(fn1)
    then begin
      result := loadfrom_XmlParserCtx(xmlCreateFileParserCtxt(PAnsiChar(fn)));
    end else begin
      self.fUrl:=fn;
      self.fReason:='File not found!';
      result := false;
    end;
end;

procedure TDomDocument.save(Source: DOMString);
var
  encoding:    AnsiString;
  bytes:       integer;
  sSource: AnsiString;
  format:      integer;
begin
  // check encoding
  if fEncoding = ''
     then encoding := GetXmlDocPtr.encoding
     else encoding := lowercase(fEncoding);

  // check output format
  if fPrettyPrint
     then format := -1
     else format := 0;

  // copy Source to get a PAnsiChar from DomString
  sSource := Source;

  // now save it to Sourec
  bytes := xmlSaveFormatFileEnc(PAnsiChar(sSource), GetXmlDocPtr, PAnsiChar(encoding), format);

  // check result of operation
  if bytes < 0 then CheckError(WRITE_ERR);

end;

procedure TDomDocument.saveToStream(const stream: TStream);
var
  tmp: AnsiString;
begin
  tmp:=(self as IDomPersist).xml;
  { Write string }
  Stream.Write(tmp[1], Length(tmp));
end;

procedure TDomDocument.set_OnAsyncLoad(const Sender: TObject;
  EventHandler: TAsyncEventHandler);
begin
  checkError(NOT_SUPPORTED_ERR);
end;

function getXmlNode(const Node: IDomNode): xmlNodePtr;
begin
  if not Assigned(Node) then checkError(INVALID_ACCESS_ERR);
  Result := (Node as IXMLDOMNodeRef).GetXmlNodePtr;
end;

function TDomAttr.getXmlAttrOwnerPtr: xmlNodePtr;
begin
  result:=fOwnerElement;
end;

{ TDomCharacterData }

procedure TDomCharacterData.appendData(const Data: DOMString);
begin
  xmlNodeAddContent(xmlCharacterData, PAnsiChar(UTF8Encode(Data)));
end;

procedure TDomCharacterData.deleteData(offset, Count: integer);
begin
  replaceData(offset, Count, '');
end;

function TDomCharacterData.get_data: DOMString;
begin
  result := inherited get_nodeValue;
end;

function TDomCharacterData.get_length: integer;
begin
  result := length(get_data);
end;

function TDomCharacterData.GetXmlCharacterData: xmlNodePtr;
begin
  result := xmlNode;
end;

procedure TDomCharacterData.insertData(offset: integer;
  const Data: DOMString);
begin
  replaceData(offset, 0, Data);
end;

procedure TDomCharacterData.replaceData(offset, Count: integer;
  const Data: DOMString);
var
  s1, s2, s: DOMString;
begin
  s := Get_data;
  if (offset < 0) or (offset > length(s)) or (Count < 0) then checkError(INDEX_SIZE_ERR);
  s1 := Copy(s, 1, offset);
  s2 := Copy(s, offset + Count + 1, Length(s) - offset - Count);
  s := s1 + Data + s2;
  Set_data(s);
end;

procedure TDomCharacterData.set_data(const Data: DOMString);
begin
  inherited set_nodeValue(Data);
end;

function TDomCharacterData.substringData(offset,
  Count: integer): DOMString;
var
  s: DOMString;
begin
  if (offset < 0) or (offset > length(s)) or (Count < 0) then checkError(INDEX_SIZE_ERR);
  s := Get_data;
  s := copy(s, offset, Count);
  Result := s
end;

constructor TDomCharacterData.Create(ACharacterData: xmlNodePtr;
  ADocument: IDomDocument);
begin
  inherited Create(xmlNodePtr(ACharacterData), ADocument);
end;

destructor TDomCharacterData.Destroy;
begin
  inherited Destroy;
end;

{ TDomText }

function TDomText.splitText(offset: integer): IDomText;
var
  s, s1: DOMString;
  tmp:   IDomText;
  node:  IDomNode;
begin
  s := Get_data;
  if (offset < 0) or (offset > length(s)) then checkError(INDEX_SIZE_ERR);
  s1 := Copy(s, 1, offset);
  Set_data(s1);
  s1 := Copy(s, 1 + offset, length(s));
  tmp := self.fOwnerDocument.createTextNode(s1);
  if self.get_parentNode <> nil then begin
    node := self.get_parentNode;
    if self.get_nextSibling = nil then node.appendChild(tmp)
    else node.insertBefore(tmp, self.get_nextSibling);
  end;
  Result := tmp;
end;

{ TMSDOMEntity }

function TDomEntity.get_notationName: DOMString;
begin
  result:=UTF8Decode(fXmlEntity.content);
end;

function TDomEntity.get_publicId: DOMString;
begin
  result:=UTF8Decode(fXmlEntity.ExternalID);
end;

function TDomEntity.get_systemId: DOMString;
begin
  result:=UTF8Decode(fXmlEntity.SystemID);
end;


{ TDomProcessingInstruction }

function TDomProcessingInstruction.get_data: DOMString;
begin
  Result := inherited get_nodeValue;
end;

function TDomProcessingInstruction.get_target: DOMString;
begin
  Result := inherited get_nodeName;
end;

procedure TDomProcessingInstruction.set_data(const Value: DOMString);
begin
  inherited set_nodeValue(Value);
end;

{ TDomDocumentType }

function TDomDocumentType.get_entities: IDomNamedNodeMap;
begin
  if (fInternalDtd <> nil) or (fExternalDtd <> nil) then Result :=
      TDomNamedNodeMap.Create(xmlNodePtr(fInternalDtd), fOwnerDocument, nnmEntities,
      fExternalDtd) as IDomNamedNodeMap
  else Result := nil;
end;

function TDomDocumentType.get_internalSubset: DOMString;
var
  buff: xmlBufferPtr;
begin
  buff := xmlBufferCreate();
  xmlNodeDump(buff, nil, xmlNodePtr(fInternalDtd), 0,0);
  Result := UTF8Decode(buff^.content);
  xmlBufferFree(buff);
end;

function TDomDocumentType.get_name: DOMString;
begin
  Result := self.get_nodeName;
end;

function TDomDocumentType.get_notations: IDomNamedNodeMap;
begin
  if (fInternalDtd <> nil) or (fExternalDtd <> nil) then Result :=
      TDomNamedNodeMap.Create(xmlNodePtr(fInternalDtd), fOwnerDocument, nnmNotations,
      fExternalDtd) as IDomNamedNodeMap
  else Result := nil;
end;

function TDomDocumentType.get_publicId: DOMString;
begin
  Result := UTF8Decode(fInternalDtd^.ExternalID);
end;

function TDomDocumentType.get_systemId: DOMString;
begin
  Result := UTF8Decode(fInternalDtd^.SystemID);
end;



constructor TDomDocumentType.Create(internalDtd, externalDtd: xmlDtdPtr;
  ADocument: IDomDocument);
var
  root: xmlNodePtr;
begin
  fInternalDtd := internalDtd;
  fExternalDtd := externalDtd;
  // if there is an internal dtd, use is as root node
  // otherwise use the external dtd as root node
  if assigned(internalDtd)
    then root:=xmlNodePtr(internalDtd)
    else root:=xmlNodePtr(externalDtd);
  //Create root-node as pascal object
  inherited Create(root, ADocument);
end;


destructor TDomDocumentType.Destroy;
begin
  inherited Destroy;
end;

{ TDomNotation }

function TDomNotation.get_publicId: DOMString;
begin
  result:=UTF8Decode(fXmlNotation^.PublicID);
end;

function TDomNotation.get_systemId: DOMString;
begin
    result:=UTF8Decode(fXmlNotation^.SystemID);
end;


function TDomNode.selectNode(const nodePath: DOMString): IDomNode;
begin
  Result := selectNodes(nodePath)[0];
end;

function TDomNode.selectNodes(const nodePath: DOMString): IDomNodeList;
// raises SYNTAX_ERR,
// if invalid xpath expression or
// if the result type is string or number
var
  doc:  xmlDocPtr;
  ctxt: xmlXPathContextPtr;
  res:  xmlXPathObjectPtr;
  temp: AnsiString;
  tmpdoc: xmlDocPtr;
  tmpnode: xmlNodePtr;
  nodetype: xmlXPathObjectType;
  i: integer;
  Prefix,Uri,Uri1: AnsiString;
  FPrefixList,FUriList:TStringList;
  errCtx: TErrCtx;
begin
  // encode the nodePath
  temp := UTF8Encode(nodePath);
  // get the xmlDocumentPtr
  doc := fXmlNode.doc;
  // raise an error, if it's nil
  if doc = nil then CheckError(NULL_PTR_ERR,classname);
  // create an XPathContext
  ctxt := xmlXPathNewContext(doc);
  // assign the context node
  ctxt.node := fXmlNode;
  // get the prefix and uri list
  FPrefixList:=(get_OwnerOrSelf as IDomInternal).getPrefixList;
  FUriList:=(get_OwnerOrSelf as IDomInternal).getUriList;
  // register these namespaces in th XPATH context
  for i:=0 to FPrefixList.Count-1 do begin
    Prefix:=FPrefixList[i];
    Uri:=FUriList[i];
    // check wether it was already registered
    Uri1:=xmlXPathNsLookup(ctxt,PAnsiChar(prefix));
    // register it only, if it wasn't registered yet
    // (otherwise you get an access violation)
    if (Prefix <> '') and (Uri <> '') and (Uri<>Uri1)
      then xmlXPathRegisterNs(ctxt, PAnsiChar(Prefix), PAnsiChar(URI));
  end;
  // clear last error message
  (get_OwnerOrSelf as IDOMInternal).reason := '';
  ErrCtx.document:=nil;
  ErrCtx.errMsg:='';
  // initialize the errorHandler
  xmlSetGenericErrorFunc(@ErrCtx, errorHandler);
  // evaluate the xpath expression
  res := xmlXPathEvalExpression(PAnsiChar(temp), ctxt);
  // check if the expression was valid
  if res <> nil then begin
    // if there was a result, get it's type
    nodetype := res.type_;
    case nodetype of
      // if it was a nodeset, create a nodelist
      XPATH_NODESET:
        begin
          Result := TDomNodeList.Create(res, fOwnerDocument)
        end
     // otherwise raise an syntax error
     else begin
       Result := nil;
       // cleanUp
       xmlXPathFreeContext(ctxt);
       checkError(SYNTAX_ERR);
     end;
    end;
  // if the xpath expression was invalid
  end else begin
    Result := nil;
    (get_OwnerOrSelf as IDOMInternal).reason := ErrCtx.errMsg;
    // cleanUp
    xmlXPathFreeContext(ctxt);
    checkError(SYNTAX_ERR);
  end;
  // cleanUp
  tmpdoc:=ctxt.doc;
  tmpnode:=ctxt.node;
  //try
  // todo: check, why this line causes problems
  xmlXPathFreeContext(ctxt);
  //except
  //  temp:=tmpdoc.name;
  //  temp:=tmpnode.name;
  //end;
end;

(*
 *  TXDomDocumentBuilderFactory
*)
constructor TDomDocumentBuilderFactory.Create(AFreeThreading: boolean);
begin
  FFreeThreading := AFreeThreading;
end;

function TDomDocumentBuilderFactory.NewDocumentBuilder: IDomDocumentBuilder;
begin
  Result := TDomDocumentBuilder.Create(FFreeThreading);
end;

function TDomDocumentBuilderFactory.Get_VendorID: DomString;
begin
  if FFreeThreading then Result := SLIBXML
  else Result := SLIBXML;
end;

procedure TDomNode.set_Prefix(const prefix: DomString);
begin
  checkError(NOT_SUPPORTED_ERR);
end;

function TDomDocumentBuilder.load(const url: DomString): IDomDocument;
begin
  Result := (TDomDocument.Create(Get_DomImplementation, url)) as IDomDocument;
end;

function TDomDocumentBuilder.newDocument: IDomDocument;
begin
  Result := TDomDocument.Create(Get_DomImplementation);
end;

function TDomDocumentBuilder.parse(const xml: DomString): IDomDocument;
var
  doctype: IDomDocumentType;
begin
  doctype:=nil;
  Result := TDomDocument.Create(Get_DomImplementation,'', '', doctype);
  (Result as IDomParseOptions).resolveExternals := True;
  (Result as IDomPersist).loadxml(xml);
end;

procedure TDomNode.RegisterNS(const prefix, URI: DomString);
begin
  (fOwnerDocument as IDomInternal).registerNS(UTF8Encode(prefix),UTF8Encode(Uri));
end;

function TDomNode.IsReadOnly: boolean;
begin
  Result := IsReadOnlyNode(fXmlNode)
end;

function TDomNode.IsAncestorOrSelf(newNode: xmlNodePtr): boolean;
var
  node: xmlNodePtr;
begin
  node := fXmlNode;
  Result := True;
  while node <> nil do begin
    if node = newNode then exit;
    node := node^.parent;
  end;
  Result := False;
end;

procedure TDomDocument.removeAttr(attr: xmlAttrPtr);
begin
  if attr <> nil
    then FAttrList.Remove(attr);
end;

procedure TDomDocument.appendAttr(attr: xmlAttrPtr);
begin
  if attr <> nil then FAttrList.add(attr);
  if attr^.children <> nil then
    attr^.children^.doc := attr^.doc;
end;

procedure TDomDocument.appendNode(node: xmlNodePtr);
begin
  if node <> nil then FNodeList.add(node);
  setDocOnCurrentLevel(node, node^.doc);
end;

//********************************************************************//
// | The following routines for testing XML rules were taken from the //
// | Extended Document Object Model (XDOM) package,                   //
// | copyright (c) 1999-2002 by Dieter Köhler.                        //
//********************************************************************//

function IsXmlIdeographic(const S: widechar): boolean;
begin
  case word(S) of
    $4E00..$9FA5,$3007,$3021..$3029: Result := True;
    else Result := False;
  end;
end;

function IsXmlBaseChar(const S: widechar): boolean;
begin
  case word(S) of
    $0041..$005a,$0061..$007a,$00c0..$00d6,$00d8..$00f6,$00f8..$00ff,
    $0100..$0131,$0134..$013E,$0141..$0148,$014a..$017e,$0180..$01c3,
    $01cd..$01f0,$01f4..$01f5,$01fa..$0217,$0250..$02a8,$02bb..$02c1,
    $0386,$0388..$038a,$038c,$038e..$03a1,$03a3..$03ce,$03D0..$03D6,
    $03DA,$03DC,$03DE,$03E0,$03E2..$03F3,$0401..$040C,$040E..$044F,
    $0451..$045C,$045E..$0481,$0490..$04C4,$04C7..$04C8,$04CB..$04CC,
    $04D0..$04EB,$04EE..$04F5,$04F8..$04F9,$0531..$0556,$0559,
    $0561..$0586,$05D0..$05EA,$05F0..$05F2,$0621..$063A,$0641..$064A,
    $0671..$06B7,$06BA..$06BE,$06C0..$06CE,$06D0..$06D3,$06D5,
    $06E5..$06E6,$0905..$0939,$093D,$0958..$0961,$0985..$098C,
    $098F..$0990,$0993..$09A8,$09AA..$09B0,$09B2,$09B6..$09B9,
    $09DC..$09DD,$09DF..$09E1,$09F0..$09F1,$0A05..$0A0A,$0A0F..$0A10,
    $0A13..$0A28,$0A2A..$0A30,$0A32..$0A33,$0A35..$0A36,$0A38..$0A39,
    $0A59..$0A5C,$0A5E,$0A72..$0A74,$0A85..$0A8B,$0A8D,$0A8F..$0A91,
    $0A93..$0AA8,$0AAA..$0AB0,$0AB2..$0AB3,$0AB5..$0AB9,$0ABD,$0AE0,
    $0B05..$0B0C,$0B0F..$0B10,$0B13..$0B28,$0B2A..$0B30,$0B32..$0B33,
    $0B36..$0B39,$0B3D,$0B5C..$0B5D,$0B5F..$0B61,$0B85..$0B8A,
    $0B8E..$0B90,$0B92..$0B95,$0B99..$0B9A,$0B9C,$0B9E..$0B9F,
    $0BA3..$0BA4,$0BA8..$0BAA,$0BAE..$0BB5,$0BB7..$0BB9,$0C05..$0C0C,
    $0C0E..$0C10,$0C12..$0C28,$0C2A..$0C33,$0C35..$0C39,$0C60..$0C61,
    $0C85..$0C8C,$0C8E..$0C90,$0C92..$0CA8,$0CAA..$0CB3,$0CB5..$0CB9,
    $0CDE,$0CE0..$0CE1,$0D05..$0D0C,$0D0E..$0D10,$0D12..$0D28,
    $0D2A..$0D39,$0D60..$0D61,$0E01..$0E2E,$0E30,$0E32..$0E33,
    $0E40..$0E45,$0E81..$0E82,$0E84,$0E87..$0E88,$0E8A,$0E8D,
    $0E94..$0E97,$0E99..$0E9F,$0EA1..$0EA3,$0EA5,$0EA7,$0EAA..$0EAB,
    $0EAD..$0EAE,$0EB0,$0EB2..$0EB3,$0EBD,$0EC0..$0EC4,$0F40..$0F47,
    $0F49..$0F69,$10A0..$10C5,$10D0..$10F6,$1100,$1102..$1103,
    $1105..$1107,$1109,$110B..$110C,$110E..$1112,$113C,$113E,$1140,
    $114C,$114E,$1150,$1154..$1155,$1159,$115F..$1161,$1163,$1165,
    $1167,$1169,$116D..$116E,$1172..$1173,$1175,$119E,$11A8,$11AB,
    $11AE..$11AF,$11B7..$11B8,$11BA,$11BC..$11C2,$11EB,$11F0,$11F9,
    $1E00..$1E9B,$1EA0..$1EF9,$1F00..$1F15,$1F18..$1F1D,$1F20..$1F45,
    $1F48..$1F4D,$1F50..$1F57,$1F59,$1F5B,$1F5D,$1F5F..$1F7D,
    $1F80..$1FB4,$1FB6..$1FBC,$1FBE,$1FC2..$1FC4,$1FC6..$1FCC,
    $1FD0..$1FD3,$1FD6..$1FDB,$1FE0..$1FEC,$1FF2..$1FF4,$1FF6..$1FFC,
    $2126,$212A..$212B,$212E,$2180..$2182,$3041..$3094,$30A1..$30FA,
    $3105..$312C,$AC00..$d7a3: Result := True;
    else Result := False;
  end;
end;

function IsXmlLetter(const S: widechar): boolean;
begin
  Result := IsXmlIdeographic(S) or IsXmlBaseChar(S);
end;

function IsXmlDigit(const S: widechar): boolean;
begin
  case word(S) of
    $0030..$0039,$0660..$0669,$06F0..$06F9,$0966..$096F,$09E6..$09EF,
    $0A66..$0A6F,$0AE6..$0AEF,$0B66..$0B6F,$0BE7..$0BEF,$0C66..$0C6F,
    $0CE6..$0CEF,$0D66..$0D6F,$0E50..$0E59,$0ED0..$0ED9,$0F20..$0F29: Result := True;
    else Result := False;
  end;
end;

function IsXmlCombiningChar(const S: widechar): boolean;
begin
  case word(S) of
    $0300..$0345,$0360..$0361,$0483..$0486,$0591..$05A1,$05A3..$05B9,
    $05BB..$05BD,$05BF,$05C1..$05C2,$05C4,$064B..$0652,$0670,
    $06D6..$06DC,$06DD..$06DF,$06E0..$06E4,$06E7..$06E8,$06EA..$06ED,
    $0901..$0903,$093C,$093E..$094C,$094D,$0951..$0954,$0962..$0963,
    $0981..$0983,$09BC,$09BE,$09BF,$09C0..$09C4,$09C7..$09C8,
    $09CB..$09CD,$09D7,$09E2..$09E3,$0A02,$0A3C,$0A3E,$0A3F,
    $0A40..$0A42,$0A47..$0A48,$0A4B..$0A4D,$0A70..$0A71,$0A81..$0A83,
    $0ABC,$0ABE..$0AC5,$0AC7..$0AC9,$0ACB..$0ACD,$0B01..$0B03,$0B3C,
    $0B3E..$0B43,$0B47..$0B48,$0B4B..$0B4D,$0B56..$0B57,$0B82..$0B83,
    $0BBE..$0BC2,$0BC6..$0BC8,$0BCA..$0BCD,$0BD7,$0C01..$0C03,
    $0C3E..$0C44,$0C46..$0C48,$0C4A..$0C4D,$0C55..$0C56,$0C82..$0C83,
    $0CBE..$0CC4,$0CC6..$0CC8,$0CCA..$0CCD,$0CD5..$0CD6,$0D02..$0D03,
    $0D3E..$0D43,$0D46..$0D48,$0D4A..$0D4D,$0D57,$0E31,$0E34..$0E3A,
    $0E47..$0E4E,$0EB1,$0EB4..$0EB9,$0EBB..$0EBC,$0EC8..$0ECD,
    $0F18..$0F19,$0F35,$0F37,$0F39,$0F3E,$0F3F,$0F71..$0F84,
    $0F86..$0F8B,$0F90..$0F95,$0F97,$0F99..$0FAD,$0FB1..$0FB7,$0FB9,
    $20D0..$20DC,$20E1,$302A..$302F,$3099,$309A: Result := True;
    else Result := False;
  end;
end;

function IsXmlExtender(const S: widechar): boolean;
begin
  case word(S) of
    $00B7,$02D0,$02D1,$0387,$0640,$0E46,$0EC6,$3005,$3031..$3035,
    $309D..$309E,$30FC..$30FE: Result := True;
    else Result := False;
  end;
end;

function IsXmlNameChar(const S: widechar): boolean;
begin
  if IsXmlLetter(S) or IsXmlDigit(S) or IsXmlCombiningChar(S) or
    IsXmlExtender(S) or (S = '.') or (S = '-') or (S = '_') or (S = ':') then Result := True
  else Result := False;
end;

function IsUtf16LowSurrogate(const S: widechar): boolean;
begin
  case word(S) of
    $DC00..$DFFF: Result := True;
    else Result := False;
  end;
end;

function IsXmlChars(const S: DOMString): boolean;
var
  i, l, pl: integer;
  sChar:    widechar;
begin
  Result := True;
  i := 0;
  l := length(S);
  pl := pred(l);
  while i < pl do begin
    inc(i);
    sChar := S[i];
    case word(sChar) of
      $0009,$000A,$000D,$0020..$D7FF,$E000..$FFFD: // Unicode below $FFFF
      ; // do nothing.
      $D800..$DBFF: // High surrogate of Unicode character [$10000..$10FFFF]
        begin
          if i = l then begin
            Result := False;
            break;
          end; // End of wideString --> No low surrogate found
          inc(i);
          sChar := S[i];
          if not IsUtf16LowSurrogate(sChar) then begin
            Result := False;
            break;
          end; // No low surrogate found
        end;
      else begin
          Result := False;
          break;
        end;
    end; {case ...}
  end;   {while ...}
end;

function IsXmlName(const S: DOMString): boolean;
var
  i: integer;
begin
  Result := True;
  if Length(S) = 0 then begin
    Result := False;
    exit;
  end;
  if not (IsXmlLetter(PWideChar(S)^) or (PWideChar(S)^ = '_') or (PWideChar(S)^ = ':')) then
  begin
    Result := False;
    exit;
  end;
  for i := 2 to length(S) do if not IsXmlNameChar((PWideChar(S) + i - 1)^) then begin
      Result := False;
      exit;
    end;
end;

//********************************************************************//
// | The preceding routines for testing XML rules were taken from the //
// | Extended Document Object Model (XDOM) package,                   //
// | copyright (c) 1999-2002 by Dieter Köhler.                        //
//********************************************************************//

procedure TDomDocument.removeNode(node: xmlNodePtr);
begin
  if node <> nil then FNodeList.Remove(node);
end;

{$ifdef VER130} // Delphi 5

function LeftStr(const AText: AnsiString; const ACount: Integer): AnsiString;
begin
  Result := Copy(AText, 1, ACount);
end;

function RightStr(const AText: AnsiString; const ACount: Integer): AnsiString;
begin
  Result := Copy(AText, Length(AText) + 1 - ACount, ACount);
end;

{$endif}

procedure TDomNode.transformNode(const stylesheet: IDomNode; var output: DomString);
var
  Doc:       xmlDocPtr;
  styleDoc:  IDomDocument;
  outputDoc: xmlDocPtr;
  tempXSL:   xsltStylesheetPtr;
  encoding:  DOMString;
  length1:   longint;
  CString:   PAnsiChar;
  len:       integer;
  meta:      DOMString;
  doctype:   xmlElementType;
  element:   xmlNodePtr;
begin
  output:='';

  if not SysUtils.Supports(stylesheet, IDomDocument, styleDoc)
    then
      styleDoc:=stylesheet.ownerDocument;
  if styleDoc = nil then Exit;

  Doc:=fXmlNode.doc;
  if Doc = nil then Exit;

  tempXSL:=(styleDoc as IDomInternal).getXsltStylesheetPtr;
  if tempXSL = nil then Exit;

  outputDoc:=xsltApplyStylesheet(tempXSL, Doc, nil);
  if outputDoc = nil then exit;

  doctype := outputDoc.type_;
  element := xmlDocGetRootElement(outputDoc);
  encoding := outputDoc^.encoding;
  xmlDocDumpMemoryEnc(outputDoc, CString, @length1, outputDoc^.encoding);
  output := CString;
  // free the document as a string is returned, and not the document
  xmlFreeDoc(outputDoc);
  // if the document is of type plain-text or html
  if (element = nil) or (doctype = XML_HTML_DOCUMENT_NODE) then begin
    //cut the leading xml header
    len := pos('>', output) + 2;
    output := copy(output, len, length1 - len);
  end;
  if doctype = XML_HTML_DOCUMENT_NODE
    then begin
    //insert the meta tag for html output after the head tag
    meta := '<META http-equiv="Content-Type" content="text/html; charset=' +
      encoding + '">';
    len := pos(DOMString('<head>'), string(output)) + 6 - 1;
    output := leftstr(output, len) + meta + rightstr(output, length(output) - len);
  end;
  xmlFree(CString);
end;

procedure TDomNode.transformNode(const stylesheet: IDomNode; const output: IDomDocument);
var
  doc:       xmlDocPtr;
  styleDoc:  xmlDocPtr;
  outputDoc: xmlDocPtr;
  styleNode: xmlNodePtr;
  tempXSL:   xsltStylesheetPtr;
  impl:      IDomImplementation;
begin
  if output = nil then
//    raise DOMException.Create(SNodeExpected);
    raise Exception.Create('output may not be nil!');
  doc := fXmlNode.doc;
  // if the node is the documentnode, it's ownerdocument is nil,
  // so you have to use self to get the domImplementation
  if self.fOwnerDocument<>nil
    then impl:= self.fOwnerDocument.domImplementation
    else impl:= (self as IDomDocument).domImplementation;
  styleNode := GetXmlNode(stylesheet);
  styleDoc := styleNode.doc;
  if (styleDoc = nil) or (doc = nil) then exit;
  // the userData passed to the error func is not what i expected. need to check
  // how to set that correctly.
  xmlSetStructuredErrorFunc(nil, nil);
  tempXSL := xsltParseStyleSheetDoc(styleDoc);
  if tempXSL = nil then exit;
  // mark the document as stylesheetdocument;
  // it holds additional information, so a different free method must
  // be used
  (stylesheet.ownerDocument as IDomInternal).set_fXsltStylesheet(tempXSL);
  outputDoc := xsltApplyStylesheet(tempXSL, doc, nil);
  if outputDoc = nil then exit;
  (output as IDomInternal).injectDifferentDocElement(outputDoc);
end;

function TDomNode.IsSameNode(node: IDomNode): boolean;
var
  xnode1, xnode2: xmlNodePtr;
begin
  Result := True;
  if (self = nil) and (node = nil) then exit;
  Result := False;
  if (self = nil) or (node = nil) then exit;
  xnode1 := GetXmlNode(self);
  xnode2 := GetXmlNode(node);
  if xnode1 = xnode2 then Result := True
  else Result := False;
end;

function TDomDocument.getXsltStylesheetPtr: xsltStylesheetPtr;
begin
  if fXsltStylesheet=nil
    then
      fXsltStylesheet:=xsltParseStyleSheetDoc(GetXmlDocPtr);

  Result:=fXsltStylesheet;
end;

function TDomNode.get_xml: DOMString;
var
  CString: PAnsiChar;
  buffer:  xmlOutputBufferPtr;
  fEncoding: AnsiString;
  encoding:  AnsiString;
  encoder: xmlCharEncodingHandlerPtr;
begin
  // default
  result := '';
  // check, if the current node is a document node
  if self.fOwnerDocument = nil then begin
    result := (self as IDomPersist).xml;
    exit;
  end;

  // check encoding
  fEncoding:=(self.fOwnerDocument as IDomOutputOptions).encoding;
  if fEncoding = ''
     then encoding := fXmlNode^.doc^.encoding
    else encoding := PAnsiChar(fEncoding); //by FE 30.08.2002

  // get the right encoder
  if not isEncodingUTF8(encoding)
    then
      encoder:=xmlFindCharEncodingHandler(PAnsiChar(encoding))
    else
      encoder:=nil;

  // allocate an output buffer
  buffer := xmlAllocOutputBuffer(encoder);

  // dump the content of the node to the buffer
  xmlNodeDumpOutput(buffer, fXmlNode^.doc, fXmlNode, 0, 0, PAnsiChar(encoding));

  // flush the buffer
  xmlOutputBufferFlush(buffer);

  // get the decoded content, if available, otherwise the utf8 content
  if assigned(buffer^.conv)
    then CString := xmlBufferContent(buffer^.conv)
    else CString := xmlBufferContent(buffer^.buffer);

  if not isEncodingUTF8(encoding)
    then
      Result:=CString
    else
      Result:=UTF8Decode(CString);

  // close the output buffer and free all the associated resources
  xmlOutputBufferClose(buffer);
end;

function TDomDocument.get_compressionLevel: integer;
begin
  Result := FcompressionLevel;
end;

function TDomDocument.get_encoding1: DomString;
begin
  Result := fEncoding;
end;

function TDomDocument.get_prettyPrint: boolean;
begin
  Result := fPrettyPrint;
end;

procedure TDomDocument.set_compressionLevel(compressionLevel: integer);
begin
  FcompressionLevel := compressionLevel;
end;

procedure TDomDocument.set_encoding1(encoding: DomString);
begin
  fEncoding := encoding;
end;

procedure TDomDocument.set_prettyPrint(prettyPrint: boolean);
begin
  fPrettyPrint := prettyPrint;
end;

function TDomDocument.get_parsedEncoding: DomString;
begin
  Result := GetXmlDocPtr^.encoding;
end;

procedure TDomDocument.registerNS(prefix, uri: AnsiString);
begin
  FPrefixList.Add(prefix);
  FUriList.Add(uri);
end;

function TDomDocument.getPrefixList: TStringList;
begin
  result:=FPrefixList;
end;

function TDomDocument.getUriList: TStringList;
begin
  result:=FUriList;
end;

function MakeDocument(doc: xmlDocPtr; impl: IDomImplementation): IDomDocument;
begin
   result := TDomDocument.Create(impl, xmlNodePtr(doc)) as IDomDocument;
end;

procedure TDomImplementation.set_doccount(doccount: integer);
begin
  Fdoccount:=doccount;
end;

function TDomImplementation.get_doccount: integer;
begin
  result:=Fdoccount;
end;

function newDomImplementation: IDomImplementation;
begin
  Result := TDomImplementation.Create;
end;

constructor TDomNotation.Create(notation: xmlNotationPtr;
  ADocument: IDomDocument);
var
  root: xmlNodePtr;
begin
  // store the notation pointer in the private field fXmlNotation
  fXmlNotation:= notation;
  // create a root node that reflects the behaviour, required by the
  // dom2 specification
  root:=xmlNewNode(nil,notation^.name);
  // A Notation node does not have any parent. (w3c.org)
  root^.parent:=nil;
  root^.type_:=XML_NOTATION_NODE;
  inherited Create(root, ADocument);
end;

destructor TDomNotation.Destroy;
begin
  xmlFreeNode(xmlNode);
  inherited;
end;

constructor TDomEntity.Create(entity: xmlEntityPtr;
  ADocument: IDomDocument);
var
  root: xmlNodePtr;
begin
  // store the entity pointer in the private field fXmlEntity
  fXmlEntity:= entity;
  // create a root node that reflects the behaviour, required by the
  // dom2 specification
  root:=xmlNewNode(nil,entity^.name);
  // An entity node does not have any parent. (w3c.org)
  root^.parent:=nil;
  // XML does not mandate that a non-validating XML processor read and process
  // entity declarations made in the external subset or declared in external
  // parameter entities. This means that parsed entities declared in the external
  // subset need not be expanded by some classes of applications, and that the
  // replacement value of the entity may not be available. When the replacement
  // value is available, the corresponding Entity node's child list represents
  // the structure of that replacement text. Otherwise, the child list is empty.
  // (w3c.org)
  root^.children:=nil;
  root^.type_:=XML_ENTITY_NODE;
  inherited Create(root, ADocument);
end;

destructor TDomEntity.Destroy;
begin
  xmlFreeNode(xmlNode);
  inherited;
end;

function TDomDocument.findNamespaceNode(const ns: xmlNsPtr): boolean;
begin
  // check it from list
  result := (FNsList.IndexOf(ns) >= 0);
end;

function TDomDocument.findOrCreateNewNamespace(const node: xmlNodePtr; const ns: xmlNsPtr): xmlNsPtr;
begin
  // use the normal one
  if (not Assigned(ns))
     then result := findOrCreateNewNamespace(node, nil, nil)
     else result := findOrCreateNewNamespace(node, ns^.href, ns^.prefix);
end;

function TDomDocument.findOrCreateNewNamespace(const node: xmlNodePtr; const namespaceURI, prefix: PAnsiChar): xmlNsPtr;
var i: integer;
begin
  // default
  result := nil;

  // check the settings
  if (not Assigned(namespaceURI)) and (not Assigned(prefix)) then exit;

  // try to locate this namespace in already stored list
  for i := 0 to pred(FNsList.Count) do
      // compare this to internal entries
      if (Assigned(xmlNsPtr(FNsList[i])^.prefix) = Assigned(prefix))
         and
         ((not Assigned(prefix)) or (StrComp(xmlNsPtr(FNsList[i])^.prefix, prefix) = 0))

      then if
         (StrComp(xmlNsPtr(FNsList[i])^.href,   namespaceURI ) = 0)
         then begin
           result := xmlNsPtr(FNsList[i]);
           break;
         end;

  // check this result
  if not Assigned(result)
     then begin
       // create the new ns
       result := xmlNewNs(node, namespaceURI, prefix);
       // check this result
       if Assigned(result)
          then
            // append it to our internal list
            FNsList.Add(result);

     end;

end;

function TDomDocument.getNewNamespace(const namespaceURI, prefix: DOMString): xmlNsPtr;
begin
  if (prefix = '')
     then result := findOrCreateNewNamespace(nil, PAnsiChar(UTF8Encode(namespaceURI)), nil)
     else result := findOrCreateNewNamespace(nil, PAnsiChar(UTF8Encode(namespaceURI)), PAnsiChar(UTF8Encode(prefix)));
end;

function TDomDocument.GetXmlDocPtr: xmlDocPtr;
begin
  result := xmlDocPtr(xmlNode);
end;

function TDomDocument.get_errorCode: Integer;
begin
  result := 0;
end;

function TDomDocument.get_filepos: Integer;
begin
  result := 0;
end;

function TDomDocument.get_line: Integer;
begin
  result:=fLine;
end;

function TDomDocument.get_linepos: Integer;
begin
  result:=fLinePos;
end;

function TDomDocument.get_reason: DOMString;
// get the reason of the last parse error
begin
  result:=fReason;
end;

function TDomDocument.get_srcText: DOMString;
begin

end;

function TDomDocument.get_url: DOMString;
begin
  result:=fUrl;
end;

procedure TDomDocument.processError;

var
  temp: AnsiString;
  substrings: TStringList;
  i: integer;
begin
   temp:=fReason;
   // remove windows linefeeds
   temp:=stringreplace(temp,#13,'',[rfReplaceAll]);
   substrings:=TStringList.Create;
   try
     // split string into strings
     splitString(temp,#10,substrings);
     // remove validity error if fValidate is false
     if (substrings.Count>=3) and (not self.fValidate) then begin
       if pos('validity',substrings[0]) > 0 then begin
          substrings[0]:='';
          substrings[1]:='';
          substrings[2]:='';
       end;
       if pos('validity',substrings[2]) > 0 then begin
          substrings[1]:='';
          substrings[2]:='';
          substrings[3]:='';
          substrings[4]:='';
          substrings[5]:='';
          substrings[6]:='';
          substrings[7]:='';
       end;
     end;

     // concat strings to string
     temp:='';
     fLinePos:=-1;
     for i:=0 to substrings.count-1 do begin
       if substrings[i]<>'' then begin
         temp:=temp+substrings[i]+crlf;
       end;
       if (pos('^',substrings[i]) > 0) and (fLinePos=-1) then begin
         fLinePos:=pos('^',substrings[i]);
       end;
     end;
   finally
     substrings.Free;
   end;
   fReason:=temp;
end;



procedure TDomDocument.set_reason(aReason: DomString);
begin
  fReason := aReason;
end;

procedure TDomDocument.removeWhitespace;
var
  node: xmlNodePtr;
begin
  // get the documentElement
  node:=xmlDocGetRootElement(GetXmlDocPtr);
  // remove all the whitespace beyond of it
  if node <> nil then begin
    xmlRemoveWhitespace(node,true);
  end;
end;

procedure TDomDocument.appendNs(ns: xmlNsPtr);
begin
  if ns <> nil then FNsList.add(ns);
end;

function GetXmlDoc(const Doc: IDomDocument): xmlDocPtr;
begin
  if not Assigned(Doc) then checkError(INVALID_ACCESS_ERR);
  Result := (Doc as IXMLDOMDocRef).GetXmlDocPtr;
end;

function TDomNode.get_ownerOrSelf: IDomDocument;
// because the ownerDocument of a Document is nil,
// we need this function
begin
  result:=fOwnerDocument;
  if result=nil then result:=self as IDomDocument;
end;

function TDomDocument.get_exposeNsDefAttribs: boolean;
begin
  result := fExposeNsDefAttribs;
end;

procedure TDomDocument.set_exposeNsDefAttribs(value: boolean);
begin
  fExposeNsDefAttribs:=value;
end;

procedure TDomDocument.set_fXsltStylesheet(XSL: xsltStylesheetPtr);
begin
  fXsltStylesheet := XSL;
end;

procedure TDomDocument.setDefaults;
// if you want to change the defaults, you can do it here
begin
  (self as IDomParseOptions).Validate            := false;
  (self as IDomParseOptions).resolveExternals    := false;
  (self as IDomImplOptions).ExposeNsDefAttribs   := false;
end;

function TDomNode.Get_ExposeNsDefAttribs: boolean;
begin
  result:=(get_ownerOrSelf as IDomImplOptions).exposeNsDefAttribs;
end;

initialization
  RegisterDomVendorFactory(TDomDocumentBuilderFactory.Create(False));

finalization

end.



