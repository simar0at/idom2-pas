unit converter_lib;

interface

uses classes, idom2, idom2_ext, libxmldom, SysUtils;

type TConverter = class
  private
    fImpl: IDomImplementation;
    fInputFileName:  string;
    fOutputFileName: string;
    fTemplateName: string;
    fInputFile:  TStringList;
    fTemplateDoc: IDomDocument;
    fLinesReplaced: integer;
    fSectionsInserted: integer;
    fLinesNotFound: integer;

    // replace a line of the text
    // replaces only one accurency
    // returns true, if found.
    function replace(line, newline: string): boolean;

    // replaces text with newtext
    // returns true, if found
    function replace1(text, newtext: string; findfirst: integer = 0): boolean;

    // inserts the text newtext before the line line
    // returns true, if line was found
    function insertBefore(line, newtext: string): boolean;

  public
    procedure read;
    procedure convert;
    procedure write;
    procedure outLog(msg: string);
    constructor create;
    destructor destroy; override;
  end;

implementation

{ converter }

procedure TConverter.convert;
// handles four cases:
// 1. replace line line
// 2. replace line cdata
// 3. replace cdata cdata
// 4. insert before cdata
var
  elem:  IDomElement;
  node:  IDomNode;
  cdata, cdata1: IDomNode;
  list:  IDomNodeList;
  i: integer;
  line, newline: string;
  findfirst: integer;
begin
  // fetch the root node of the document
  elem:= fTemplateDoc.documentElement;
  // get the list of childnodes
  list:= elem.childNodes;
  // loop through the list of children
  for i:=0 to list.length - 1 do begin
    node:=list[i];
    // if we have an element node
    if node.nodeType = ELEMENT_NODE then begin
      elem:=(node as IDomElement);
      outLog(elem.nodeName);
      if elem.nodeName='replace' then begin
        line    := elem.getAttribute('line');
        newline := elem.getAttribute('with');
        // check, if we have line and newline as attribute
        // *** CASE 1.***
        if (line<>'') and (newline<>'') then begin
          //outLog('  line = "'+line+'"');
          //outLog('  with = "'+newline+'"');
          if replace(line,newline) then begin
            inc(fLinesReplaced);
          end else begin
            outLog('Not found: "' + line+'"');
            inc(fLinesNotFound);
          end;
        // check if we have line as attribute and newline as CDATA node
        // *** CASE 2.***
        end else if (line<>'') then begin
          cdata:=elem.firstChild;
          if (cdata<>nil) and (cdata.nodeType = CDATA_SECTION_NODE) then begin
            newline:=(cdata as IDomCDataSection).data;
            newline:=adjustLineBreaks(newline);
            if replace(line,newline) then begin
              inc(fLinesReplaced);
            end else begin
              outLog('Not found: "' + line+'"');
              inc(fLinesNotFound);
            end;
          end else begin
            outLog('Error: CDATA-Node not found: "'+ line +'"');
            inc(fLinesNotFound);
          end;
        // *** CASE 3.***
        // replace without attributes, but two cdata children
        end else begin
          cdata:=elem.firstChild;
          cdata1:=cdata.nextSibling;
          if cdata1.nodetype = COMMENT_NODE then
            cdata1:=cdata1.nextSibling;
          if (cdata<>nil) and (cdata1<>nil)
                          and (cdata.nodeType = CDATA_SECTION_NODE)
                          and (cdata1.nodeType = CDATA_SECTION_NODE) then begin
            line:=(cdata as IDomCDataSection).data;
            line:=adjustLineBreaks(line);
            newline:=(cdata1 as IDomCDataSection).data;
            newline:=adjustLineBreaks(newline);
            findfirst:=StrToIntDef(elem.getAttribute('findfirst'),0);
            if replace1(line,newline, findfirst) then begin
              inc(fLinesReplaced);
            end else begin
              outLog('Not found: "' + line+'"');
              inc(fLinesNotFound);
            end;
          end else begin
            outLog('Error: CDATA-Node(s) not found: "'+ line +'"');
            inc(fLinesNotFound);
          end;
        end;
      // *** CASE 4.***
      // insert before cdata
      end else if elem.nodeName='insert' then begin
        line    := elem.getAttribute('before');
        if line <> '' then begin
          cdata:=elem.firstChild;
          if (cdata<>nil) and (cdata.nodeType = CDATA_SECTION_NODE) then begin
            newline:=(cdata as IDomCDataSection).data;
            newline:=adjustLineBreaks(newline);
            if insertbefore(line,newline) then begin
              inc(fSectionsInserted);
            end else begin
              outLog('Not found: "' + line+'"');
              inc(fLinesNotFound);
            end;
          end else begin
            outLog('Error: CDATA-Node not found: "'+ line +'"');
            inc(fLinesNotFound);
          end;
        end else begin
          outLog('Error: Attribute before of element insert not found!');
        end;
      end;
    end;
  end;
  outLog('Lines replaced:    '+inttostr(fLinesReplaced));
  outLog('Sections inserted: '+inttostr(fSectionsInserted));
  outLog('Lines not found:   '+inttostr(fLinesNotFound));
  readln;
end;

constructor TConverter.create;
begin
  fInputFileName  := '../../libxmldom.pas';
  fOutputFileName := '../../libxml.pas';
  fTemplateName   := '../../converter.xml';
  fInputFile      := TStringList.create;
  fImpl           := getDom(SLIBXML);
end;

destructor TConverter.destroy;
begin
  fInputFile.Free;
  inherited Destroy;
end;

function TConverter.insertBefore(line, newtext: string): boolean;
var
  i: integer;
begin
  result:=false;
  for i:=0 to fInputFile.count - 1 do begin
    if fInputFile[i] = line then begin
      //outLog('  found in line: '+inttostr(i));
      fInputFile[i]:=newtext+line;
      result:=true;
      exit;
    end;
  end;
end;

procedure TConverter.outLog(msg: string);
// change this procedure, if you need a gui application
begin
  writeln(msg);
end;

procedure TConverter.read;
var
  ok: boolean;
  tmp: string;
begin
  fInputFile.LoadFromFile(fInputFileName);
  fTemplateDoc:=fImpl.createDocument('','',nil);
  ok:=(fTemplateDoc as IDomPersist).load(fTemplateName);
  if not ok then begin
    tmp:=((fTemplateDoc as IDomParseError).reason);
    raise exception.Create('Error reading template file: '+ fTemplateName+#13#10+tmp);
  end;
end;

function TConverter.replace(line, newline: string): boolean;
// replace the first occurance of line in the inputfile with newline
// return true on success
var
  i: integer;
begin
  result:=false;
  for i:=0 to fInputFile.count - 1 do begin
    if fInputFile[i] = line then begin
      //outLog('  found in line: '+inttostr(i));
      fInputFile[i]:=newline;
      result:=true;
      exit;
    end;
  end;
end;

function TConverter.replace1(text, newtext: string; findfirst: integer = 0): boolean;
// replace the first occurance text in the inputfile with newtext
// return true on success
// might be slow
var
  tmp: string;
  list: TStringList;
  i: integer;
begin
  if findfirst = 0 then begin
    tmp:=stringreplace(fInputFile.Text,text,newtext,[]);
  end else begin
    list:=TStringList.Create;
    try
      list.Text:=text;
      text:='';
      for i:=0 to findfirst-1 do begin
        if i<>0 then begin
          text:=text+#13#10;
        end;
        text:=text+list[i];
      end;
      tmp:=stringreplace(fInputFile.Text,text,newtext,[]);
    finally
      list.Free;
    end;
  end;
  result:=tmp <> fInputFile.Text;
  fInputFile.Text:=tmp;
end;

procedure TConverter.write;
begin
  fInputFile.SaveToFile(fOutputFileName);
end;

end.
