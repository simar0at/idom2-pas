unit TestXSLTLibXML;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, testregistry, TestXSLT, libxmldom;

type

  { TTestXSLTLibXML }

  TTestXSLTLibXML = class(TTestXSLT)
  public
    constructor Create; override;
  published
    (*
     * XSLT capabilities
     *)
    procedure transformNode2PlainText_WideString;
    procedure transformNode2PlainText_DomDocument;
    procedure transformNode2Html4_WideString;
    //procedure transformNode2Html4_DomDocument;
    procedure transformNode2XHTML_DomDocument;
    procedure transformNode2XHTML_WideString;
    procedure transformNodeVersion10;
    procedure transformNodeSimplifiedSyntax;
    procedure transformNodeNonTerminatingLoop;
    (*
     * IDomNodeEx capabilities
     *)
    procedure setText;
    procedure getText;
    procedure getXml;
    procedure getXmlWithUmlauts;
    procedure loadXmlUnicode;
    (*
     * IDomNodeListEx capabilities
     *)
    procedure getXml_NodeList;
  end;

implementation

{ TTestXSLTLibXML }

constructor TTestXSLTLibXML.Create;
begin
  inherited Create;
  fVendorID := SLIBXML;
end;

procedure TTestXSLTLibXML.transformNode2PlainText_WideString;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNode2PlainText_DomDocument;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNode2Html4_WideString;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNode2XHTML_DomDocument;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNode2XHTML_WideString;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNodeVersion10;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNodeSimplifiedSyntax;
begin
   inherited;
end;

procedure TTestXSLTLibXML.transformNodeNonTerminatingLoop;
begin
   inherited;
end;

procedure TTestXSLTLibXML.setText;
begin
   inherited;
end;

procedure TTestXSLTLibXML.getText;
begin
   inherited;
end;

procedure TTestXSLTLibXML.getXml;
begin
   inherited;
end;

procedure TTestXSLTLibXML.getXmlWithUmlauts;
begin
   inherited;
end;

procedure TTestXSLTLibXML.loadXmlUnicode;
begin
   inherited;
end;

procedure TTestXSLTLibXML.getXml_NodeList;
begin
   inherited;
end;

initialization
  RegisterTest(TTestXSLTLibXML)
end.

