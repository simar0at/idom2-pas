unit XPTest_idom2_TestPersist;

interface

uses
{$ifndef fpc}
  TestFrameWork,
  domSetup,
{$else}
  fpcunit,
  fpcDomSetup,
{$endif}
  idom2,
  idom2_ext,
  SysUtils,
  Classes,
{$ifdef VER130} // Delphi 5
  jclUnicode,   // UTF8Encode and UTF8Decode
{$endif}
{$ifdef mswindows}
  ActiveX,
{$endif}
  XPTest_idom2_Shared;

type
  TTestPersist = class(TMyTestCase)
  private
    impl: IDomImplementation;
    doc: IDomDocument;
    doc1: IDomDocument;
    pe: IDOMPersist;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure persist;
    procedure valid;
    procedure valid1;
    procedure valid1_ParseError;
    procedure valid2;
    procedure valid3;
    procedure valid4;
    procedure valid4_ParseError;
    procedure wellformed;
    procedure wellformed_ParseError;
    procedure wellformed1;
    procedure wellformed2;
    procedure wellformed3;
    procedure parsedEncoding;
    procedure parsedEncoding1;
    procedure parsedEncoding1_ParseError;
    procedure stringEncoding;
    procedure fileEncoding;
    procedure stringPrettyPrint;
    procedure filePrettyPrint;
    procedure LoadFiles;
    procedure LoadFilesII;
    procedure loadXmlUml;
    procedure loadXmlUnicode;
    procedure load_windows_pathdelimiter;
  end;

implementation

{ TTestPersist }

procedure TTestPersist.persist;
var
  sl: TStrings;
  tmp, data1, Data: string;
begin
  try
    // get a textual representation of the dom
    Data := (doc as IDomPersist).xml;
    data1 := unify(Data);
    // save the dom to a file and load it as a textfile
    (doc as IDomPersist).save('temp.xml');
    sl := TStringList.Create;
    sl.LoadFromFile('temp.xml');
    tmp := sl.Text;
    // adjust contents of the textfile
    tmp := unify(tmp);
    // compare the textual representation of the dom to the contents of the textfile
    check(data1 = tmp, 'wrong content');
    // load the dom from a textfile
    (doc as IDomPersist).load('temp.xml');
    // get a textual representation of the dom
    tmp := (doc as IDomPersist).xml;
    // adjust the textual representation of the dom
    tmp := Unify(tmp);
    check(data1 = tmp, 'wrong content');
    sl.Free;
  finally
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;

procedure TTestPersist.valid;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that IS valid against the dtd
var
  Data: string;
begin
  Data := xmldecl +
          '<!DOCTYPE root [' +
          '<!ELEMENT root (test*,a)>' +
          '<!ELEMENT test (#PCDATA)>' +
          '<!ATTLIST test name CDATA #IMPLIED>' +
          '<!ELEMENT a (#PCDATA)>' +
          ']>' +
          '<root><a/></root>';
  (doc as IDomParseOptions).validate := True;
  check((doc as IDomPersist).loadxml(Data),
    'result of load is false - should be true because xml is valid');
end;

procedure TTestPersist.valid1;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that NOT valid against the dtd
var
  Data: string;
begin
  Data := xmldecl +
          '<!DOCTYPE root [' +
          '<!ELEMENT root (test*)>' +
          '<!ELEMENT test (#PCDATA)>' +
          '<!ATTLIST test name CDATA #IMPLIED>' +
          ']>' +
          '<egon />';

  (doc as IDomParseOptions).validate := True;
  check(not (doc as IDomPersist).loadxml(Data),
    'result of load true - should be false because xml is not valid');
end;

procedure TTestPersist.valid1_ParseError;
  // Test if the xml structure is validated against the dtd.
  // Create and save a xml structure that NOT valid against the dtd.
  // Additional have a look at the parse error.
const
  Data        = xmldecl +
                '<!DOCTYPE root [' + CRLF +
                '<!ELEMENT root (test*)>' + CRLF +
                '<!ELEMENT test (#PCDATA)>' + CRLF +
                '<!ATTLIST test name CDATA #IMPLIED>' + CRLF +
                ']>' + CRLF +
                '<egon />';
begin
  (doc as IDomParseOptions).validate := True;
  try
    check(not (doc as IDomPersist).loadxml(Data),
      'result of load true - should be false because xml is not valid');
  finally
    check((doc as IDOMParseError).url = '','Xml was parsed from a string not from a file.');
    check((doc as IDOMParseError).line = 6,'There must occur a parse error at line 6.');
    //check((doc as IDOMParseError).linePos = 7,'There must occur a parse error at linepos 7.' );
    // ... but for msxml it is linepos 9 !
  end;
end;

procedure TTestPersist.valid2;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that is NOT valid against the dtd
var
  Data: string;
begin
  Data := xmldecl +
          '<!DOCTYPE root [' +
          '<!ELEMENT root (test*)>' +
          '<!ELEMENT test (#PCDATA)>' +
          '<!ATTLIST test name CDATA #IMPLIED>' +
          ']>' +
          '<egon />';

  (doc as IDomParseOptions).validate := False;
  check((doc as IDomPersist).loadxml(Data),
    'result of load is false - should be true because ParseOptions set to false');
end;

procedure TTestPersist.valid3;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that IS valid against the dtd
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  sl.Text := xmldecl +
             '<!DOCTYPE root [' +
             '<!ELEMENT root (test*)>' +
             '<!ELEMENT test (#PCDATA)>' +
             '<!ATTLIST test name CDATA #IMPLIED>' +
             ']>' +
             '<root />';
  sl.SaveToFile('temp.xml');
  sl.Free;
  (doc as IDomParseOptions).validate := True;
  try
    check((doc as IDomPersist).load('temp.xml'),
      'result of load is false - should be true because xml is valid');
  finally
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;

procedure TTestPersist.valid4;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that is NOT valid against the dtd
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  sl.Text := xmldecl +
             '<!DOCTYPE root [' +
             '<!ELEMENT root (test*)>' +
             '<!ELEMENT test (#PCDATA)>' +
             '<!ATTLIST test name CDATA #IMPLIED>' +
             ']>' +
             '<egon />';
  sl.SaveToFile('temp.xml');
  sl.Free;
  (doc as IDomParseOptions).validate := True;
  try
    check(not (doc as IDomPersist).load('temp.xml'),
      'result of load is true - should be false because xml is not vaild');
  finally
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;

procedure TTestPersist.valid4_ParseError;
  // test if the xml structure is validated against the dtd
  // create and save a xml structure that is NOT valid against the dtd
  // Additional the parse error is checked.
var
  sl: TStrings;
  url: string;
begin
  sl := TStringList.Create;
  sl.Text := xmldecl + CRLF +
             '<!DOCTYPE root [' + CRLF +
             '<!ELEMENT root (test*)>' + CRLF +
             '<!ELEMENT test (#PCDATA)>' + CRLF +
             '<!ATTLIST test name CDATA #IMPLIED>' + CRLF +
             ']>' + CRLF +
             '<egon />';
  sl.SaveToFile('temp.xml');
  sl.Free;
  (doc as IDomParseOptions).validate := True;
  try
    check(not (doc as IDomPersist).load('temp.xml'),
      'result of load is true - should be false because xml is not vaild');
  finally
    check((doc as IDOMParseError).line = 7,'There must occur a parse error at line 7.');
    url := (doc as IDOMParseError).url;
    check(url = 'temp.xml','The Url is different from "temp.xml".');
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;
procedure TTestPersist.LoadFiles;
var
  builder: IDomDocumentBuilder;
  mydoc:   IDomDocument;
  fd:      string; // file directory
  fn:      string; // file name
  sr:      TSearchRec;
  rv:      integer; // returned value
  cnt:     integer; // tested file counter
begin
  fd := StringReplace(datapath,'\',PathDelim,[rfReplaceAll]);
  try
    cnt := 0;
    rv := FindFirst(fd + '*.xml', faAnyFile, sr);
    while (rv = 0) do begin
      Inc(cnt);
      builder := getDocumentBuilderFactory(DomVendor).newDocumentBuilder;
      fn := fd + sr.Name;
      mydoc := builder.load(fn);
      check(mydoc <> nil, fn + ': document not loaded');
      check(mydoc.documentElement <> nil, fn + ': documentElement is nil');
      rv := FindNext(sr);
    end;
    if (cnt = 0) then begin
      check(False, 'No XML file available for testing in directory ' + fd);
    end;
  finally
    FindClose(sr);
  end;
end;

procedure TTestPersist.LoadFilesII;
var
  mydoc: IDomDocument;
  fd:    string; // file directory
  fn:    string; // file name
  sr:    TSearchRec;
  rv:    integer; // returned value
  cnt:   integer; // tested file counter
begin
  impl := GetDom(domvendor);
  mydoc := impl.createDocument('', '', nil);
  fd := StringReplace(datapath,'\',PathDelim,[rfReplaceAll]);
  try
    cnt := 0;
    rv := FindFirst(fd + '/*.xml', faAnyFile, sr);
    while (rv = 0) do begin
      Inc(cnt);
      fn := fd + '/' + sr.Name;
      (mydoc as IDomPersist).load(fn);
      check(mydoc <> nil, fn + ': document not loaded');
      check(mydoc.documentElement <> nil, fn + ': documentElement is nil');
      rv := FindNext(sr);
    end;
    if (cnt = 0) then begin
      check(False, 'No XML file available for testing in directory ' + fd);
    end;
  finally
    FindClose(sr);
  end;
end;

procedure TTestPersist.SetUp;
begin
  // reset all
  doc := nil;
  doc1 := nil;
  impl := nil;
  pe := nil;

  impl := getCurrentDomSetup.getDocumentBuilder.domImplementation;
  doc := impl.createDocument('', '', nil);
  (doc as IDomPersist).loadxml(xmlstr);
  doc1 := impl.createDocument('', '', nil);
  (doc1 as IDomPersist).loadxml(xmlstr1);
end;

procedure TTestPersist.TearDown;
begin
  doc := nil;
  doc1 := nil;
  impl := nil;
  pe := nil;
end;

procedure TTestPersist.wellformed;
  // load a NOT wellformed xml from string
begin
  check(not (doc as IDOMPersist).loadxml(xmldecl+'<test>'+CRLF+'<a>'+CRLF+'</test>'),
    'method loadxml should return False because xml is NOT wellformed');
end;

procedure TTestPersist.wellformed_ParseError;
  // load a NOT wellformed xml from string
begin
  try
    check(not (doc as IDOMPersist).loadxml(xmldecl+'<test>'+CRLF+'<a>'+CRLF+'</test>'),
      'method loadxml should return False because xml is NOT wellformed');
  finally
    check((doc as IDOMParseError).line = 3,'There must occur a parse error at line 3.');
    check((doc as IDOMParseError).url = '','Xml was parsed from a string not from a file.');
  end;
end;

procedure TTestPersist.wellformed1;
  // load a wellformed xml from string
begin
  check((doc as IDOMPersist).loadxml(xmlstr),
    'method loadxml should return True because xml IS wellformed');
end;

procedure TTestPersist.wellformed2;
  // load a NOT wellformed xml from a file
const
  filename = 'temp.xml';
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  sl.Text := xmldecl+'<test>';
  sl.SaveToFile(filename);
  sl.Free;
  try
    check(not (doc as IDOMPersist).load(filename),
      'method load should return False because xml is NOT wellformed');
  finally
    DeleteFile(filename);
  end;
end;

procedure TTestPersist.wellformed3;
  // load a wellformed xml from a file
const
  filename = 'temp.xml';
var
  sl: TStrings;
begin
  sl := TStringList.Create;
  sl.Text := xmlstr;
  sl.SaveToFile(filename);
  sl.Free;
  try
    check((doc as IDOMPersist).load(filename),
      'method load should return True because xml IS wellformed');
  finally
    DeleteFile(filename);
  end;
end;

procedure TTestPersist.parsedEncoding;
var
  sl: TStrings;
  ok: boolean;
  tmp,tmp1: widestring;
begin
  if domvendor='LIBXML_4CT' then begin
    sl := TStringList.Create;
    tmp := '<?xml version="1.0" encoding="iso-8859-1"?>' +
           '<test>' +
             '�����܀' +
           '</test>';
    sl.text:=tmp;
    sl.SaveToFile('temp.xml');
    sl.Free;
    try
      ok:=(doc as IDomPersist).load('temp.xml');
      check(ok,'parse error');
      tmp1:= (doc as IDomPersist).xml;
      tmp1:=Unify(tmp1,false);
      //showMessage(tmp+CRLF+tmp1);
      check(tmp=tmp1,'encoding error');
      check((doc as IDomOutputOptions).parsedEncoding='iso-8859-1','wrong parsed encoding');
    finally
      if FileExists('temp.xml') then DeleteFile('temp.xml');
    end;
  end else begin
    check(false,'DomVendor not supported!');
  end;
end;

procedure TTestPersist.parsedEncoding1;
// check wether there is a parse error reported, if we
// try to parse a document, that containes umlauts (non ascii chars),
// but has no declared encoding
var
  sl: TStrings;
  ok,ok1: boolean;
  tmp: widestring; // ,tmp1
begin
  ok1 := False;
  sl := TStringList.Create;
  tmp := '<?xml version="1.0"?>' + CRLF +
         '<test>' + CRLF +
           '�����܀' + CRLF +
         '</test>';
  sl.text:=tmp;
  sl.SaveToFile('temp.xml');
  sl.Free;
  try
    ok:=(doc as IDomPersist).load('temp.xml');
    check(not ok,'parse error');
    ok1:=true;
  finally
    check(ok1,'exception raised, but should not');
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;

procedure TTestPersist.parsedEncoding1_ParseError;
// check wether there is a parse error reported, if we
// try to parse a document, that containes umlauts (non ascii chars),
// but has no declared encoding
var
  sl: TStrings;
  ok,ok1: boolean;
  tmp: widestring; // ,tmp1
begin
  ok1 := False;
  sl := TStringList.Create;
  tmp := '<?xml version="1.0"?>' + CRLF +
         '<test>' + CRLF +
           '�����܀' + CRLF +
         '</test>';
  sl.text:=tmp;
  sl.SaveToFile('temp.xml');
  sl.Free;
  try
    ok:=(doc as IDomPersist).load('temp.xml');
    check(not ok,'no parse error');
    ok1:=true;
  finally
    check(ok1,'exception raised, but should not');
    check((doc as IDOMParseError).line = 3, 'There must occur a parse error at line 3.');
    check((doc as IDOMParseError).url = 'temp.xml','The Url must be "temp.xml".');
    if FileExists('temp.xml') then DeleteFile('temp.xml');
  end;
end;

procedure TTestPersist.stringEncoding;
var
  sl: TStrings;
  ok: boolean;
  tmp,tmp1: widestring;
begin
  if domvendor='LIBXML_4CT'
    then
      begin
        sl:=TStringList.Create;
        tmp := '<?xml version="1.0" encoding="iso-8859-1"?><test>������</test>';
        sl.text:=tmp;
        sl.SaveToFile('temp.xml');
        sl.Free;

        try
          ok:=(doc as IDomPersist).load('temp.xml');
          check(ok,'parse error');
          (doc as IDomOutputOptions).encoding:=cUTF8; // used to be: utf-8
          tmp1:= (doc as IDomPersist).xml;
          tmp1:=Unify(tmp1);
          tmp:=Unify(tmp);
          check(tmp=tmp1,'encoding error');
          check((doc as IDomOutputOptions).parsedEncoding='iso-8859-1','wrong parsed encoding');
        finally
          if FileExists('temp.xml') then DeleteFile('temp.xml');
        end;
      end
    else
      begin
        check(false,'DomVendor not supported!');
      end;
end;

procedure TTestPersist.fileEncoding;
var
  sl: TStrings;
  ok: boolean;
  tmp,tmp1: widestring;
begin
  if domvendor='LIBXML_4CT'
    then
      begin
        sl:=TStringList.Create;
        tmp := '<?xml version="1.0" encoding="iso-8859-1"?><test>������</test>';
        sl.text:=tmp;
        sl.SaveToFile('temp.xml');
        sl.Free;
        try
          ok:=(doc as IDomPersist).load('temp.xml');
          check(ok,'parse error');
          if FileExists('temp.xml') then DeleteFile('temp.xml');
          (doc as IDomOutputOptions).encoding:=cUTF8; // used to be: utf-8
          (doc as IDomPersist).save('temp.xml');
          ok:=(doc as IDomPersist).load('temp.xml');
          check(ok,'parse error');
          tmp1:=(doc as IDomPersist).xml;
          tmp1:=Unify(tmp1);
          tmp:=Unify(tmp);
          check(tmp=tmp1,'encoding error');
          check((doc as IDomOutputOptions).parsedEncoding=cUTF8, 'wrong parsed encoding');  // used to be: utf-8
        finally
          if FileExists('temp.xml') then DeleteFile('temp.xml');
        end;
      end
    else
      begin
        check(false,'DomVendor not supported!');
      end;
end;

procedure TTestPersist.filePrettyPrint;
var
  sl: TStrings;
  ok: boolean;
  tmp,tmp1: widestring;
begin
  if domvendor='LIBXML_4CT' then begin
    sl := TStringList.Create;
    tmp := '<?xml version="1.0" encoding="iso-8859-1"?>' +
           '<test>' +
           '������' +
           '</test>';
    sl.text:=tmp;
    sl.SaveToFile('temp.xml');
    sl.Free;
    try
      (doc as IDomParseOptions).preserveWhiteSpace:=false;
      ok:=(doc as IDomPersist).load('temp.xml');
      check(ok,'parse error');
      if FileExists('temp.xml') then DeleteFile('temp.xml');
      (doc as IDomOutputOptions).prettyPrint:=true;
      (doc as IDomPersist).save('temp.xml');
      sl := TStringList.Create;
      sl.LoadFromFile('temp.xml');
      tmp1:=sl.Text;
      sl.free;
      //tmp1:=Unify(tmp1);
      //tmp:=Unify(tmp);
      //showMessage(tmp+CRLF+tmp1);
    finally
      if FileExists('temp.xml') then DeleteFile('temp.xml');
    end;
  end else begin
    check(false,'DomVendor not supported!');
  end;
end;

procedure TTestPersist.stringPrettyPrint;
var
  sl: TStrings;
  ok: boolean;
  tmp,tmp1: widestring;
begin
  if domvendor='LIBXML_4CT' then begin
    sl := TStringList.Create;
    tmp := '<?xml version="1.0" encoding="iso-8859-1"?>' +
           '<test>' +
           '������' +
           '</test>';
    sl.text:=tmp;
    sl.SaveToFile('temp.xml');
    sl.Free;
    try
      (doc as IDomParseOptions).preserveWhiteSpace:=false;
      ok:=(doc as IDomPersist).load('temp.xml');
      check(ok,'parse error');
      (doc as IDomOutputOptions).prettyPrint:=true;
      tmp1:= (doc as IDomPersist).xml;
      //tmp1:=Unify(tmp1);
      //tmp:=Unify(tmp);
      //showMessage(tmp+CRLF+tmp1);
    finally
      if FileExists('temp.xml') then DeleteFile('temp.xml');
    end;
  end else begin
    check(false,'DomVendor not supported!');
  end;
end;

procedure TTestPersist.loadXmlUml;
var teststr: widestring;
begin
  // test how loadxml behaves with 'umlauts'
  teststr := xmldecl+'<root><text>����</text><text>���</text></root>';
  (doc as IDOMPersist).loadxml(teststr);
  check(doc.documentElement.hasChildNodes, 'has no childNodes');
  check(doc.documentElement.childNodes.length = 2, 'wrong length');
  check(doc.documentElement.firstChild.firstChild.nodeType = TEXT_NODE, 'wrong nodeType');
  check(doc.documentElement.lastChild.firstChild.nodeType = TEXT_NODE, 'wrong nodeType');
  //showMessage(doc.documentElement.firstChild.firstChild.nodeValue);
  check(doc.documentElement.firstChild.firstChild.nodeValue = '����', 'wrong nodeValue');
  check(doc.documentElement.lastChild.firstChild.nodeValue = '���', 'wrong nodeValue');
  check(((unify((doc as IDomPersist).xml)=unify(teststr))), 'xml output is different from parsed text');
end;

procedure TTestPersist.loadXmlUnicode;
var
  teststr: widestring;
  parsestr: widestring;
  ok: boolean;
begin
  teststr:= getunicodestr(1);
  parsestr:='';
  parsestr:=parsestr+'<?xml version="1.0" encoding="'+cUTF8+'"?><root><text>'+teststr+'</text><text>���</text></root>';  // used to be: utf8
  //showMessage(parsestr);
  ok:=(doc as IDOMPersist).loadxml(parsestr);
  check(ok,'parse error');
  check(doc.documentElement.hasChildNodes, 'has no childNodes');
  check(doc.documentElement.childNodes.length = 2, 'wrong length');
  check(doc.documentElement.firstChild.firstChild.nodeType = TEXT_NODE, 'wrong nodeType');
  check(doc.documentElement.lastChild.firstChild.nodeType = TEXT_NODE, 'wrong nodeType');
  check(doc.documentElement.firstChild.firstChild.nodeValue = teststr, 'wrong nodeValue');
  check(doc.documentElement.lastChild.firstChild.nodeValue = '���', 'wrong nodeValue');
  check((unify((doc as IDomPersist).xml)=unify(parsestr)), 'xml output is different from parsed text');
end;

procedure TTestPersist.load_windows_pathdelimiter;

begin
  {$ifdef mswindows}
  check(Pos('\',datapath) > 0, 'datapath does not have a windows path delimiter');
  {$endif}
  (doc as IDOMParseOptions).resolveExternals := True;
  (doc as IDOMParseOptions).validate := True;
  check((doc as IDOMPersist).load(StringReplace(datapath,'\',PathDelim,[rfReplaceAll])+'test-dtd.xml'), 'parse error');
end;

initialization
  datapath := getDataPath;
  {$ifdef mswindows}
  CoInitialize(nil);
  {$endif}
  {$ifdef linux}
  ;
  {$endif}
end.

