# Publican Slides

## Description

The **publican-slides** repository provides a collection of SVG slides about Publican, an open-source publishing system for documentation authored in DocBook XML, and a build script to convert these slides or their subset to the PDF format.

## Requirements

To ensure that the slides are rendered as intended, make sure that you have the correct font family installed on your machine:

* The [Droid Fonts](http://www.droidfonts.com/) family of fonts, namely **Droid Sans** and **Droid Sans Mono**.

In addition, the following tools are required in order to use the included **build.sh** script:

* [Inkscape](http://inkscape.org/), an open-source vector graphics editor.

* [PDFJam](http://www2.warwick.ac.uk/fac/sci/statistics/staff/academic-research/firth/software/pdfjam), a collection of scripts for manipulating PDF files.


## Usage

To convert a custom subset of the SVG slides to the PDF format, change to the directory with your local copy of this repository and run the **build.sh** script as follows:

    ./build.sh <filename>

where *filename* is a configuration file with the list of slides to use. In this configuration file, each slide must be specified in the form of a path to the corresponding SVG file, and must be listed on a separate line. Empty lines and lines beginning with the number sign (#) are ignored.

To build the default set of slides, use the included **slides.conf** configuration file as follows:

    ./build.sh slides.conf

This creates a file named **slides.pdf** in the directory with the configuration file.

## Copyright

Copyright © 2013 Jaromir Hradilek

This work is licensed under a [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).
