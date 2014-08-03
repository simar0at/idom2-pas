inherited XSLTForm: TXSLTForm
  Caption = 'XSLT Input'
  ExplicitWidth = 397
  ExplicitHeight = 241
  PixelsPerInch = 96
  TextHeight = 13
  object XSLTText: TMemo
    Left = 0
    Top = 0
    Width = 391
    Height = 217
    Align = alClient
    Lines.Strings = (
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<xsl:stylesheet'
      '    xmlns="http://www.w3.org/1999/xhtml"'
      '    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"'
      '    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"'
      '    xmlns:tei="http://www.tei-c.org/ns/1.0"'
      '    exclude-result-prefixes="xd xsl tei"'
      '    version="1.0">'
      '    <xd:doc scope="stylesheet">'
      '        <xd:desc>'
      '            Test stylesheet for Open_idom'
      '        </xd:desc>'
      '    </xd:doc>'
      '    '
      '    <xd:doc>'
      '        <xd:desc>Set output to be XHTML4</xd:desc>'
      '    </xd:doc>'
      
        '    <xsl:output method="html" media-type="text/xhtml" indent="ye' +
        's" '
      'encoding="UTF-8"'
      '        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"'
      '        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-'
      'transitional.dtd"/>'
      '    '
      '    <xsl:template match="/tei:TEI">'
      '        <html>'
      '            <head>'
      '                <xsl:apply-templates select="tei:teiHeader"/>'
      '                <style type="text/css">'
      '                    .bold {'
      '                       font-weight: bold;'
      '                    }'
      '                    .italic {'
      '                       font-style: italic;'
      '                    }'
      '                </style>'
      '            </head>'
      '            <xsl:apply-templates select="tei:text"/>            '
      '        </html>'
      '    </xsl:template>'
      '    '
      '    <xsl:template match="tei:publicationStmt"/>'
      '    '
      '    <xsl:template match="tei:sourceDesc"/>'
      ''
      '    <xsl:template match="tei:fileDesc/tei:titleStmt/tei:title">'
      '        <title><xsl:value-of select="."/></title>'
      '    </xsl:template>'
      '    '
      '    <xsl:template match="tei:body">'
      '        <body>'
      '            <xsl:apply-templates select="tei:div"/>'
      '        </body>'
      '    </xsl:template>'
      '    '
      '    <xsl:template match="tei:div|tei:p">'
      
        '        <xsl:element name="{name()}"><xsl:apply-templates/></xsl' +
        ':element>'
      '    </xsl:template>'
      '    '
      '    <xsl:template match="tei:head">'
      '        <h1><xsl:value-of select="."/></h1>'
      '    </xsl:template>'
      '    '
      '    <xsl:template match="tei:hi">'
      '        <span class="{@style}"><xsl:value-of select="."/></span>'
      '    </xsl:template>'
      '    '
      '</xsl:stylesheet>')
    TabOrder = 0
    ExplicitLeft = 120
    ExplicitTop = 72
    ExplicitWidth = 185
    ExplicitHeight = 89
  end
end
