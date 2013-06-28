# ZplPreview

ZplPreview is a library and program for parsing ZPL and generating previews
in other formats (html, pdf, etc).

Current state
=============

ZplPreview is still in its infant phase. There is no runnable executable,
nor any usable library.

How to run
==========

TODO

Library
=======

The library consists of three parts:
1. A ZPL parser
2. A pre-formatter that takes ZPL and creates a generic representation of labels and barcodes.
3. A set of formatters, capable of transforming the generic representation into other formats, such as HTML.
