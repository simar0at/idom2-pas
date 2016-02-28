Release notes:
--------------

look at ..\@Docu\ReleaseNotes.txt



The files in this directory:
----------------------------

idom2.pas
.
a dom2-complient interface unit, translated from Java by Martijn Brinkers,
some xmldom.pas (a similar wrapper from Borland, but published under GPL only) 
compatibility added by Uwe Fechner

idom2_ext.pas
.
extensions to the idom2 interfaces for XPATH support, XSLT support and more

libxmldom.pas

the implementation of the idom2.pas and idom2_ext interfaces, using the libxml2-pas wrapper,
that you can find in the folder libxml2 here in the cvs


msxml_impl.pas

an implementation for the idom2.pas interfaces, using msxml-dom

MSXML_TLB.pas

a type-library, needed by msxmldom.pas

MSXML3.pas

a new version of this type-library, needed if you use the msxml 4.0 parser

You can download it at:
http://www.microsoft.com/downloads/release.asp?ReleaseID=33037

Be careful, msxml 3.0 and msxml 4.0 are not completly compatible.
The nodeselect interface of msxml 4.0 uses the full xpath syntax,
msxml 3.0 a proprietary limited syntax.

_xmldom.pas
.
the dom2 interface unit from Borland. use it only, if you own the personal
or open edition of delphi/kylix, and want to be able to switch to the
"big" editions with use of TXMLDocument later without any code changes.

If you want to use it, rename it to xmldom.pas.
If you own a version of the compiler, that comes with TXMLDocument, than
you don't need it, because it is already there and this second copy 
could lead to conflicts.

xmldom_ext.pas

extensions to the interfaces defined in xmldom.pas from borland.

libxml.pas 

implementation of the interfaces, defined in xmldom.pas and xmldom_ext.pas.
change the define at the beginning so that it matches your version of
delphi/ kylix.

Uwe Fechner <ufechner@sk28.de>