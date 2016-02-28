unit idom2_utils;

interface

uses
  {$IFDEF VER130}
  D6forD5,
  {$ELSE}
  StrUtils,
  {$ENDIF}
  idom2,
  idom2_ext;

type
  TDomCharEncoding = (ceUnknown, ceUTF8, ceUTF16LE, ceUTF16BE, ceISO88591);

const
  cDomCharEncodingIdentifier: array [TDomCharEncoding] of string =
   ( '', 'utf-8', 'utf-16', 'utf-16', 'iso-8859-1' );

function  idom_findElement(ANode: IDomNode; sName : DOMString): IDomElement;
function  idom_nodeList_get_xml(ANodeList: IDomNodeList): DOMstring;
procedure idom_optimize_EmptyTextNodes(ADOM: IDomDocument);
function  PrettyPrint(text: DOMString): DOMString; overload;
function PrettyPrint(ADoc: IDomDocument; filename: string): boolean; overload;

implementation

uses SysUtils{, utilities};

function idom_findElement(ANode: IDomNode; sName : DOMString): IDomElement;
begin
  result := nil;
  // cycle throug tree
  while Assigned(ANode) do begin

    if (ANode.NodeType = ELEMENT_NODE) and ((ANode as IDomElement).nodeName = sName)
       then begin
         result := (ANode as IDomElement);
         Exit;
       end;

    if ANode.HasChildNodes
       then begin
         result := idom_findElement(ANode.FirstChild, sName);
         if Assigned(result) then Exit;
       end;

    ANode := ANode.NextSibling;
  end;
end;

function idom_nodeList_get_xml(ANodeList: IDomNodeList): DOMstring;
var i: integer;
begin
  result := '';

  // build xmls
  for i := 0 to ANodeList.length - 1 do
    // concat their xml
    result := result + (ANodeList.item[i] as IDomNodeExt).xml;

end;

procedure idom_optimize_EmptyTextNodes(ADOM: IDomDocument);
var i: integer; iNodes: IDomNodeList;
begin
  // check for something to do
  if (not Assigned(ADOM)) or (not Assigned(ADOM.documentElement)) then exit;

  // search empty textnodes
  iNodes := (ADOM.documentElement as IDomNodeSelect).SelectNodes('//text()["" = normalize-space(.)]');
  try
    // remove them
    for i := 0 to iNodes.length - 1 do
        iNodes.item[i].parentNode.removeChild(iNodes.Item[i]);

  finally
    iNodes := nil;
  end;

end;

function PrettyPrint(text: DOMString): DOMString;
// text: a wellformed xml document
// adds spaces and crlfs to make the document better readable for humans
const
  {$ifdef mswindows}
  CRLF=#13#10;
  {$else}
  CRLF=#10;
  {$endif}
  indentstr = '  ';
  exclude = [WideChar(#9),WideChar(#13),WideChar(#10)]; // exclude formating characters : tab, control, linefeed
var
  i,indentlevel: integer;
  temp: DOMString;
begin
  // set default value
  result:='';
  // this routine assumes that text is a wellformed xml structure
  // get rid off formating
  temp := '';
  for i := 1 to Length(text) do begin
    if not(text[i] in exclude) then begin
     temp := temp + text[i]; // copy any character that is not in the exclude list
    end;
  end;
  text := temp;
  i := 1; // strings start with index 1
  indentlevel := 0; // no indention at start
  while i <= Length(text) do begin // go through the text
    if text[i] = '<' then begin // tag-start
      // we won't find '<' at the end of a wellformed xml structure
      // so we can look up the next character without getting an index error
      if text[i+1] <> '!' then begin
        if text[i+1] <> '/' then begin // start-tag
          if i > 1 then begin
            if text[i-1] <> '>' then begin // start-tag with leading text
              result := result + CRLF;
            end;
          end;
          result := result + DupeString(indentstr,indentlevel) + '<';
          if text[i+1] <> '?' then inc(indentlevel);
        end else begin // end-tag
          dec(indentlevel);
          // any other character than '<' won't be at the start of a wellformed xml
          // structure so we can look up the previous character without getting an
          // index error
          if text[i-1] <> '>' then begin // with leading text
            result := result + '</';
          end else begin // with leading tag
            result := result + DupeString(indentstr,indentlevel) + '</';
          end;
          inc(i); // jump over the next character
        end;
      end else begin // some section starts
        // the CDATA-section may contain unescaped characters
        // we leave the context of the xml structure until
        // we've found the end of the CDATA-section
        // we'll find it before end of file because of wellformedness
        if Copy(text,i,Length('<![CDATA[')) = '<![CDATA[' then begin // CDATA-section
          inc(i,9);
          result := result + DupeString(indentstr,indentlevel) + '<![CDATA[';
          while Copy(text,i,Length(']]>')) <> ']]>' do begin
            result := result + text[i]; // simply append the content of the CDATA section
            inc(i); // process the next character
          end;
          result := result + ']]>' + CRLF;
          inc(i,2); // jump over the next 2 characters - we already appended them
        end;
      end;
    end else begin // anything else but a tag-start
      // we won't find '/' at the end of a wellformed xml structure
      // so we can look up the next character without getting an index error
      if (text[i] = '/') and (text[i+1] = '>') then begin // short-tag
        result := result + '/>' + CRLF;
        inc(i); // jump over the next character
        dec(indentlevel);
      end else begin
        if text[i] = '>' then begin // tag-end
          // '>' is the last character of a wellformed xml structure
          // in this case we should not look up the next character
          if i < Length(text) then begin // tag-end in the middle
            if text[i+1] = '<' then begin // tag-end with following tag
              result := result + '>' + CRLF;
            end else begin // tag-end with following text
              result := result + '>';
            end;
          end else begin // tag end at end of text
            // the two trailing linefeeds make it pretty
            // if appending two PrettyPrint results
            result := result + '>' + CRLF + CRLF;
          end;
        end else begin // any other character
          result := result + text[i]; // simply append it
        end;
      end;
    end;
    inc(i); // process the next character
    //debug: temp := Copy(text,i,Length(text)-i+1);
  end;
end;

function PrettyPrint(ADoc: IDomDocument; filename: string): boolean;
var
  xml: widestring;
begin
  (ADoc as IDomOutputOptions).prettyPrint:=false;
  xml:=(ADoc as IDomPersist).xml;
  // to do:
  // write with char-encoding
  try
    //utilities.writeTextFile(filename, PrettyPrint(xml));
    result:=true;
  except
    result:=false;
  end;
end;


end.
