# ZplPreview

ZplPreview is a library and program for parsing ZPL and generating previews
in other formats (html, pdf, etc).

Current state
=============

ZplPreview is still in its infant phase. It currently supports converting ZPL to HTML,
but will only display labels. All parts of the library are far from feature-complete.

How to run
==========
    $ zpl_preview --format html --width 2.36 --height 1.18 --dpi 300 input_file.zpl > output_file.html

Options (all are required):

--format  - Output format. Supported formats: html

--width   - The width of the label in inches

--height  - The height of the label in inches

--dpi     - Dots per inch


Library
=======

The library consists of three parts:
1. A ZPL parser

2. A pre-formatter that takes ZPL and creates a generic representation of labels and barcodes.

3. A set of formatters, capable of transforming the generic representation into other formats, such as HTML.

Open Questions
==============

Fonts
-----

What fonts should we map to A-Z and 1-9 for the ^A font directive?

How do we properly calculate the font size in HTML, given that in HTML there is only "font size", and in ZPL there is "font width" and "font height"?

How do we support font orientation in HTML?
