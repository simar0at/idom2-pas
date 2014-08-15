unit xmldom_ext;

interface

(*
 * Interface specifications for extensions to Dom level 2.
 *
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Initial Developers of the Original Code are:

 *   - Martijn Brinkers (m.brinkers@pobox.com)
 *   - Uwe Fechner (ufechner@csi.com)
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
*)

uses xmldom, classes;

type

  { IDomNodeCompare }

  // this interfaces implements the dom3 method IsSameNode
  // it is neccessary to use it with libxml2, because there can be
  // several interfaces pointing to the same node

  IDomNodeCompare = interface
    ['{ED63440C-6A94-4267-89A9-E093247F10F8}']
    function IsSameNode(node: IDomNode): boolean;
  end;

  { IDomNodeExt }

  // this interface is similar to the interface IDomNodeEx from Borland,
  // but not the same, therefore a slightly different name is used
  // it provides methods for xslt transformation (transformNode)
  // for accessing the text-value of an element (similar to textcontent in dom3)
  // and for obtaining the string-value of a node (property xml)

  IDomNodeExt = interface(IDomNode)
    ['{1B41AE3F-6365-41FC-AFDD-26BC143F9C0F}']
    { Property Acessors }
    function get_text: DomString; safecall;
    function get_xml: DomString; safecall;
    procedure set_text(const Value: DomString); safecall;
    { Methods }
    procedure transformNode(const stylesheet: IDomNode; var output: DomString); overload; safecall;
    procedure transformNode(const stylesheet: IDomNode; var output: IDomDocument); safecall;
      overload;
    { Properties }
    property Text: DomString read get_text write set_text;
    property xml: DomString read get_xml;
  end;

  { IDomNodeListExt }

  // this interface is similar to the interface IDomNodeExt
  // and is using for serialization of nodelists

  IDomNodeListExt = interface(IDomNodeList)
    ['{1B41AE3F-6365-41FC-AFDD-26BC143F9C0F}']
    { Property Acessors }
    function get_xml: DomString;
    { Methods }
    { Properties }
    property xml: DomString read get_xml;
  end;

  {IDomOutputOptions}

  // this interface enables using the output-options, provided by libxml2
  // it will be replaced by dom3 methods in the future

  IDomOutputOptions = interface
    ['{B2ECC3F1-CC9B-4445-85C6-3D62638F7835}']
    { Property Acessors }
    function get_prettyPrint: boolean;
    function get_encoding: DomString;
    function get_parsedEncoding: DomString;
    function get_compressionLevel: integer;
    procedure set_prettyPrint(prettyPrint: boolean);
    procedure set_encoding(encoding: DomString);
    procedure set_compressionLevel(compressionLevel: integer);
    { methods }
    { Properties }
    property prettyPrint: boolean read get_prettyPrint write set_prettyPrint;
    property encoding: DomString read get_encoding write set_encoding;
    property parsedEncoding: DomString read get_parsedEncoding;
    property compressionLevel: integer read get_compressionLevel write set_compressionLevel;
  end;

  {IDomDebug}

  // this interface enables it, to get the count of currently existing documents
  // for debugging purposes

  IDomDebug = interface
  ['{D5DE14B0-C454-4E75-B6CE-4E8C07FAC9BA}']
    { Property Acessors }
    function get_doccount: integer;
    procedure set_doccount(doccount: integer);
    { Properties }
    property doccount: integer read get_doccount write set_doccount;
  end;

implementation

end.
