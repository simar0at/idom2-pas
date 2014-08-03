inherited XMLForm: TXMLForm
  Caption = 'XML Input'
  PixelsPerInch = 96
  TextHeight = 13
  object XMLText: TMemo
    Left = 0
    Top = 0
    Width = 391
    Height = 217
    Align = alClient
    Lines.Strings = (
      '<?xml version="1.0" encoding="UTF-8"?>'
      '<?xml-model href="http://www.tei-'
      
        'c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="a' +
        'pplication/xml" '
      'schematypens="http://relaxng.org/ns/structure/1.0"?>'
      '<?xml-model href="http://www.tei-'
      
        'c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="a' +
        'pplication/xml"'
      #9'schematypens="http://purl.oclc.org/dsdl/schematron"?>'
      '<TEI xmlns="http://www.tei-c.org/ns/1.0">'
      '  <teiHeader>'
      '      <fileDesc>'
      '         <titleStmt>'
      '            <title>Open_idom Test Text (header)</title>'
      '         </titleStmt>'
      '         <publicationStmt>'
      '            <p>Publication Information</p>'
      '            <p>cc-by-sa</p>'
      '         </publicationStmt>'
      '         <sourceDesc>'
      '            <p>Born digital source</p>'
      '         </sourceDesc>'
      '      </fileDesc>'
      '  </teiHeader>'
      '  <text>'
      '      <body>'
      '         <div>'
      '            <head>Open_idom Test Text</head>'
      
        '            <p>Lorem ipsum dolor sit amet, consectetur adipiscin' +
        'g elit. Integer nec '
      'odio. Praesent'
      
        '               libero. Sed cursus ante dapibus diam. Sed nisi. N' +
        'ulla quis sem at nibh '
      'elementum'
      
        '               imperdiet. Duis sagittis ipsum. <hi style="bold">' +
        'Lorem ipsum dolor sit '
      'amet, consectetur adipiscing'
      
        '                  elit</hi>. Praesent mauris. <hi style="bold">L' +
        'orem ipsum dolor sit '
      'amet, consectetur adipiscing'
      
        '                  elit</hi>. Fusce nec tellus sed augue semper p' +
        'orta. <hi '
      'style="bold">Lorem ipsum dolor sit amet,'
      
        '                  consectetur adipiscing elit</hi>. Mauris massa' +
        '. Vestibulum lacinia arcu '
      'eget nulla.'
      
        '               Class aptent taciti sociosqu ad litora torquent p' +
        'er conubia nostra, per '
      'inceptos'
      '               himenaeos. </p>            '
      
        '            <p>Curabitur sodales ligula in libero. Sed dignissim' +
        ' lacinia nunc. Curabitur '
      'tortor.'
      
        '               Pellentesque nibh. Aenean quam. In scelerisque se' +
        'm at dolor. '
      'Maecenas mattis. Sed'
      
        '               convallis tristique sem. Proin ut ligula vel nunc' +
        ' egestas porttitor. Morbi '
      'lectus'
      
        '               risus, iaculis vel, suscipit quis, luctus non, ma' +
        'ssa. <hi style="bold">Class '
      'aptent taciti sociosqu'
      
        '                  ad litora torquent per conubia nostra, per inc' +
        'eptos himenaeos</hi>. '
      'Fusce ac turpis'
      
        '               quis ligula lacinia aliquet. Mauris ipsum. <hi st' +
        'yle="bold">Curabitur '
      'sodales ligula in libero</hi>.'
      
        '               Nulla metus metus, ullamcorper vel, tincidunt sed' +
        ', euismod in, nibh. </p> '
      '           '
      
        '            <p>Quisque volutpat condimentum velit. Class aptent ' +
        'taciti sociosqu ad '
      'litora torquent'
      
        '               per conubia nostra, per inceptos himenaeos. Nam n' +
        'ec ante. Sed lacinia, '
      'urna non'
      
        '               tincidunt mattis, tortor neque adipiscing diam, a' +
        ' cursus ipsum ante quis '
      'turpis.'
      
        '               Nulla facilisi. Ut fringilla. Suspendisse potenti' +
        '. <hi style="italic">Aenean '
      'quam</hi>. Nunc feugiat'
      
        '               mi a tellus consequat imperdiet. Vestibulum sapie' +
        'n. Proin quam. Etiam '
      'ultrices.'
      
        '                  <hi style="bold">Nulla metus metus, ullamcorpe' +
        'r vel, tincidunt sed, '
      'euismod in, nibh</hi>.'
      
        '               Suspendisse in justo eu magna luctus suscipit. </' +
        'p>'
      '         </div>'
      '      </body>'
      '  </text>'
      '</TEI>')
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 375
    ExplicitHeight = 201
  end
end
