unit TestDOM2MethodsMSXML;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TestDOM2Methods, msxml_impl, testregistry;

type

  { TTestDOM2MethodsMSXML }

  TTestDOM2MethodsMSXML = class(TTestDOM2Methods)
  public
      constructor Create; override;
  published
      // a leading "basic" indicates that only properties are tested
      // a trailing "10times" indicates that the basic tests are done for 10 diffenent property values
      // a leading "unknown" indicates that we have to discuss this test
      // a trailing "setNodeValue" indicates that a nodeValue is set where it schould have no effect
      // a leading "ext" indicates that the basic test was extended
      procedure basic_appendChild;
      procedure basic_cloneNode_AttributeNode;
      procedure basic_cloneNode_AttributeNodeNS;
      procedure basic_cloneNode_AttributeNS_on_element_deep;
      procedure basic_cloneNode_AttributeNS_on_element_flat;
      procedure basic_cloneNode_Attribute_on_element_deep;
      procedure basic_cloneNode_Attribute_on_element_flat;
      procedure basic_cloneNode_CDATA_deep;
      procedure basic_cloneNode_Comment_deep;
      procedure basic_cloneNode_DocumentFragment;
      procedure basic_cloneNode_ElementNS_deep;
      procedure basic_cloneNode_ElementNS_flat;
      procedure basic_cloneNode_Element_AttrNS_flat;
      procedure basic_cloneNode_Element_deep;
      procedure basic_cloneNode_Element_flat;
  //    procedure basic_cloneNode_NodeList_deep;
      procedure basic_cloneNode_ProcessingInstruction;
      procedure basic_cloneNode_TextNode_deep;
      procedure basic_createAttribute;
      procedure basic_createAttributeNS;
      procedure basic_createAttributeNS_createNsDecl;
      procedure basic_createCDATASection;
      procedure basic_createComment;
      procedure basic_createDocumentFragment;
      procedure basic_createElement;
      procedure basic_createElementNS;
      procedure basic_createEntityReference;
      procedure basic_createProcessingInstruction;
      procedure basic_createTextNode;
      procedure basic_docType;
      procedure basic_document;
      procedure basic_documentElement;
      procedure basic_documentFragment;
      procedure basic_domImplementation;
      procedure basic_firstChild;
      procedure basic_get_defaultNs;
      procedure basic_get_NsDecl;
      procedure basic_getAttributeNodeNS_setAttributeNodeNS;
      procedure basic_getAttributeNS_setAttributeNS;
      procedure basic_getAttribute_setAttribute;
      procedure basic_getElementByID;
      procedure basic_getElementsByTagName;
      procedure basic_getElementsByTagNameNS;

      procedure basic_hasAttributeNS_setAttributeNodeNS;
      procedure basic_hasAttributes_setAttribute;
      procedure basic_hasAttribute_setAttributeNode;
      procedure basic_hasChildNodes;

      procedure basic_importNode_AttributeNode;
      procedure basic_importNode_AttributeNode1;
      procedure basic_importNode_AttributeNodeNS;
      procedure basic_importNode_AttributeNodeNS1;
      procedure basic_importNode_AttributeNodeNS_on_element;
      procedure basic_importNode_AttributeNode_on_element;
      procedure basic_importNode_CDataSection;
      procedure basic_importNode_CommentNode;
      procedure basic_importNode_DocumentFragment_deep;
      procedure basic_importNode_DocumentFragment_flat;
      procedure basic_importNode_Element_deep_flat;
      procedure basic_importNode_ElementNS_deep_flat;
      procedure basic_importNode_ProcessingInstruction;
      procedure basic_importNode_TextNode;

      procedure basic_insertBefore;
      procedure basic_isSupported;
      procedure basic_lastChild;
      procedure basic_nsdecl;
      procedure basic_ownerElement;
      procedure basic_removeAttribute;
      procedure basic_removeAttributeNode;
      procedure basic_removeAttributeNS;
      procedure basic_removeChild;
      procedure basic_replaceChild;

      procedure basic_set_defaultNs;
      procedure basic_set_NsDecl;

      procedure ext_appendAttributeNodeNS_removeAttributeNode;
      procedure ext_appendChild_10times;
      procedure ext_appendChild_defaultNs;
      procedure ext_appendChild_override_defaultNs;
      procedure ext_appendChild_existing;
      procedure ext_appendChild_NsDecl;
      procedure ext_appendChild_orphan;
      procedure ext_appendChild_removeChild;
      procedure ext_append_100_attributes_with_different_namespaces;
      procedure ext_appendRemove_defaultNs;
      procedure ext_appendRemove_NsDecl;
      procedure ext_attributes_10times;
      procedure ext_attribute_default2;
      procedure ext_attribute_default3;
      procedure ext_attribute_default_enumeration;
      procedure ext_attribute_default5;
      procedure ext_attribute_default_removeNamedItem;
      procedure ext_attribute_default_getAttribute;
      procedure ext_attribute_default_getAttributeNode;
      procedure ext_attribute_default_getAttributeNodeNS;
      procedure ext_attribute_default_getAttributeNS;
      procedure ext_attribute_default_modify;
      procedure ext_attribute_default_removeNamedItemNS;
      procedure ext_attribute_specified;
      procedure ext_checkIgnoreDocumentProcessInstruction;
      procedure ext_cloneNode_AttributeNode_default;
      procedure ext_cloneNode_AttributeNode_default_on_Element;
      procedure ext_cloneNode_document;
      procedure ext_cloneNode_documentNS;
      procedure ext_cloneNode_getFragmentA;
      procedure ext_cloneNode_NsDecl;
      procedure ext_createElementNS_defaultNS;
      procedure ext_defaultNs_check_serializer;
      procedure ext_docType;
      procedure ext_docType_entities1;
      procedure ext_docType_entities2;
      procedure ext_docType_entities;
      procedure ext_docType_entities_externalDTD;
      procedure ext_docType_entities_external_internalDTD;
      procedure ext_docType_notations;
      procedure ext_docType_notations_externalDTD;
      procedure ext_document_setNodeValue;
      procedure ext_element_setNodeValue;
      procedure ext_getAttribute;
      procedure ext_getAttributeNodeNS;
      procedure ext_getAttributeNode_setAttributeNode;
      procedure ext_getAttributeNS;
      procedure ext_getElementsByTagName;
      procedure ext_getElementsByTagNameNS;
      procedure ext_getElementsByTagNameNS_10times;
      procedure ext_importNode_AttributeNodeNS_default;
      procedure ext_importNode_AttributeNode_default;
      procedure ext_importNode_AttributeNode_default_on_element;
      procedure ext_importNode_cloneNode;

      procedure ext_insertBefore_10times;
      procedure ext_insertBefore_documentFragment;
      procedure ext_insertBefore_existing;
      procedure ext_insertBefore_TextNode;

      procedure ext_namespaceMove_I;
      procedure ext_namespaceMove_II;
      procedure ext_namespaceAppendRemoveAttr;
      procedure ext_namedNodeMap;
      procedure ext_namedNodeMapNS;
      procedure ext_namedNodeMap_append_remove_NsDecl1;
      procedure ext_namedNodeMap_append_remove_NsDecl2;
      procedure ext_nextSibling_10times;
      procedure ext_nsdecl;
      procedure ext_previousSibling_10times;
      procedure ext_reconciliate1;
      procedure ext_reconciliate;
      procedure ext_removeChild;
      procedure ext_removeAttributeNs;
      procedure ext_setAttributeNodeNs_NsDecl;
      procedure ext_setAttributeNodeNS_Xml;
      procedure ext_setAttributeNS;
      procedure ext_setAttributeNS_removeAttributeNS;
      procedure ext_setNamedItemNS_Xml;
      procedure ext_TestDocCount;
      procedure ext_unicode_NodeName;
      procedure ext_unicode_TextNodeValue;
      procedure unknown_createElementNS;
      procedure unknown_createElementNS_1;
      procedure unknown_normalize;
      procedure unknown_normalize_deep;
      procedure unknown_normalize_emptyTextNodes;
      procedure unknown_normalize_flat;
      procedure unknown_normalize_mix;
      procedure unknown_PrettyPrint1;
      procedure unknown_PrettyPrint;

  end;

implementation

{ TTestDOM2MethodsMSXML }

constructor TTestDOM2MethodsMSXML.Create;
begin
  inherited Create;
  fVendorID := MSXML2Rental;
end;

procedure TTestDOM2MethodsMSXML.basic_appendChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_AttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_AttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_AttributeNS_on_element_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_AttributeNS_on_element_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Attribute_on_element_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Attribute_on_element_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_CDATA_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Comment_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_DocumentFragment;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_ElementNS_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_ElementNS_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Element_AttrNS_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Element_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_Element_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_ProcessingInstruction;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_cloneNode_TextNode_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createAttributeNS_createNsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createCDATASection;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createComment;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createDocumentFragment;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createElement;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createElementNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createEntityReference;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createProcessingInstruction;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_createTextNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_docType;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_document;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_documentElement;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_documentFragment;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_domImplementation;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_firstChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_get_defaultNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_get_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getAttributeNodeNS_setAttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getAttributeNS_setAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getAttribute_setAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getElementByID;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getElementsByTagName;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_getElementsByTagNameNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_hasAttributeNS_setAttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_hasAttributes_setAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_hasAttribute_setAttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_hasChildNodes;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNode1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNodeNS1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNodeNS_on_element;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_AttributeNode_on_element;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_CDataSection;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_CommentNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_DocumentFragment_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_DocumentFragment_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_Element_deep_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_ElementNS_deep_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_ProcessingInstruction;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_importNode_TextNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_insertBefore;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_isSupported;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_lastChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_nsdecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_ownerElement;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_removeAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_removeAttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_removeAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_removeChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_replaceChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_set_defaultNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.basic_set_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendAttributeNodeNS_removeAttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_defaultNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_override_defaultNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_existing;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_orphan;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendChild_removeChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_append_100_attributes_with_different_namespaces;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendRemove_defaultNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_appendRemove_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attributes_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default2;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default3;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_enumeration;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default5;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_removeNamedItem;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_getAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_getAttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_getAttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_getAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_modify;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_default_removeNamedItemNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_attribute_specified;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_checkIgnoreDocumentProcessInstruction;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_AttributeNode_default;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_AttributeNode_default_on_Element;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_document;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_documentNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_getFragmentA;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_cloneNode_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_createElementNS_defaultNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_defaultNs_check_serializer;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_entities1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_entities2;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_entities;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_entities_externalDTD;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_entities_external_internalDTD;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_notations;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_docType_notations_externalDTD;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_document_setNodeValue;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_element_setNodeValue;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getAttribute;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getAttributeNodeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getAttributeNode_setAttributeNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getElementsByTagName;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getElementsByTagNameNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_getElementsByTagNameNS_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_importNode_AttributeNodeNS_default;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_importNode_AttributeNode_default;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_importNode_AttributeNode_default_on_element;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_importNode_cloneNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_insertBefore_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_insertBefore_documentFragment;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_insertBefore_existing;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_insertBefore_TextNode;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namespaceMove_I;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namespaceMove_II;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namespaceAppendRemoveAttr;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namedNodeMap;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namedNodeMapNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namedNodeMap_append_remove_NsDecl1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_namedNodeMap_append_remove_NsDecl2;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_nextSibling_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_nsdecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_previousSibling_10times;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_reconciliate1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_reconciliate;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_removeChild;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_removeAttributeNs;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_setAttributeNodeNs_NsDecl;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_setAttributeNodeNS_Xml;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_setAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_setAttributeNS_removeAttributeNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_setNamedItemNS_Xml;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_TestDocCount;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_unicode_NodeName;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.ext_unicode_TextNodeValue;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_createElementNS;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_createElementNS_1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_normalize;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_normalize_deep;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_normalize_emptyTextNodes;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_normalize_flat;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_normalize_mix;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_PrettyPrint1;
begin
   inherited;
end;

procedure TTestDOM2MethodsMSXML.unknown_PrettyPrint;
begin
   inherited;
end;

initialization
  RegisterTest(TTestDOM2MethodsMSXML);
end.

