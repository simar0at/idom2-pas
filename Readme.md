MPL/LGPL/GPL licensed DOM Vendor for Delphi using libxml2 and libxslt
=====================================================================
Origin of the project: http://idom2-pas.sourceforge.net/
with Fixed Bugs, changes for Delphi 2010 to 10.1,
current [libxml2.dll, libxslt.dll and dependencies](https://github.com/kiyolee/libxslt-win-build)
Added IDOMParseError implementation, RelaxNG and XSD Schema validation.
Should be a drop in replacement of the ever ageing msxmldom DOM Vendor.
xsl:import and xsl:include resolution by callback implementation.

------------------------------------------------------------------------------
   This unit is an object-oriented wrapper for libxml2.
   It implements the interfaces defined in xmldom.pas and xmldom_ext.pas (a bunch of extensions).

   Original author:
   Uwe Fechner <ufechner@4commerce.de>

   Contributers:
   Martijn Brinkers   <m.brinkers@pobox.com>
   Petr Kozelka       <pkozelka@centrum.cz>
   Thomas Freudenberg <th.freudenberg@4commerce.de>
   Omar Siam          <Omar.Siam@oeaw.ac.at>

   Thanks to the gdome2 project, where I got many ideas from.
   (see: http://phd.cs.unibo.it/gdome2/)

   Thanks to Jan Kubatzki for testing.

   > The routines for testing XML rules were taken from the Extended Document
   > Object Model (XDOM) package, copyright (c) 1999-2002 by Dieter Köhler.
   > The latest XDOM version is available at "http://www.philo.de/xml/" under
   > a different open source license.  In addition, the author gave permission
   > to use the routines for testing XML rules included in this file under the
   > terms of either MPL 1.1, GPL 2.0 or LGPL 2.1.


   Copyright [2002]:
   4commerce technologies AG
   Kamerbalken 10-14
   22525 Hamburg, Germany

   http://www.4commerce.de

Original Readme (form around 2002)
==================================
This is the main directory of the idom2-pas project.

idom2 implements the dom2 specification, as defined at:

http://www.w3.org/TR/DOM-Level-2-Core/

To use libxmldom.pas, you have to copy the shared libraries
of libxml2 and libxslt into a directory, that is in your
search path.

On windows you can do that:

a) download libxml2, libxslt and iconv from
   http://www.fh-frankfurt.de/~igor/projects/libxml/

b) copy the four dlls e.g. into c:/WINNT/system32 or another
   folder, that is in your windows-search path

On linux you can do that:

a) download libxml2-2.4.19-1.i368.rpm or newer from 
   ftp://ftp.gnome.org/pub/GNOME/stable/redhat/i386/libxml/
   and install it.
   If you use debian, you can convert it into a debian package
   with alien.
b) download libxslt-1.0.15-1.i386.rpm or similar from
   ftp://ftp.gnome.org/pub/GNOME/stable/redhat/i386/libxslt/
   and install it.
   An older package of libxslt is ok, an older version of libxml2
   won't work!

c) If you use debian, change the const libxml2.so in libxml2.pas
   to libxml2.so.2 and libxslt.so in libxslt.pas to libxslt.so.1

To compile the demos or the XPTests, you have to include
the following paths in your library search-path:

1) Open_idom
2) Open_jcl    (needed for Delphi5 only)
3) Open_libxml2
4) Open_libxslt
5) Open_helper (for precise time measuring)
6) XP_dunit    (needed for the XPTests only)

Alternatively, delphi users can rename _XPTestSuite_idom2.dof
to XPTestSuite_idom2.dof in the folder Open_idom\XPtest.

Then you should be able to compile the XPTest-Suite 
XPTestSuite_idom2.dpr. 

If you didn't download the idom2-pas package, but use
the cvs directly, than it might be neccessary to download
the libraries 3) and 4) seperatly as described in the
Readme.txt files of the three directories.

The XPTest project is tested with Delphi5, Delphi6 and with Kylix2 OE.


Related Projects:

http://www.xmlsoft.org 
The home of the libxml2 project

http://sourceforge.net/projects/libxml2-pas/
header translations and more for libxml2

Look for updates of this software at:
http://sourceforge.net/projects/idom2-pas/

or join the mailing list:
http://lists.sourceforge.net/lists/listinfo/idom2-pas-interest

Uwe Fechner



