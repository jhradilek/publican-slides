#!/bin/bash

# build.sh, a script to build a PDF presentation from a set of SVG files
# Copyright (C) 2013 Jaromir Hradilek

# This program is  free software:  you can redistribute it and/or modify it
# under  the terms  of the  GNU General Public License  as published by the
# Free Software Foundation, version 3 of the License.
#
# This program  is  distributed  in the hope  that it will  be useful,  but
# WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
# BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.
#
# You should have received a copy of the  GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# IMPORTANT: This script requires a working  installation  of  Inkscape and
#            the pdfjoin utility to work.

# General script information:
NAME=${0##*/}
VERSION='1.0.0'

# A function that displays an error message, and immediately terminates the
# script.
#
# Usage: display_error [<error_message> [<exit_status>]]
function display_error {
  # Retrieve function arguments and assign their default values:
  local error_message=${1:-'An unexpected error has occurred.'}
  local exit_status=${2:-1}

  # Write the error message to the standard error stream:
  echo -e "$NAME: $error_message" >&2

  # Terminate the script with the selected exit status:
  exit $exit_status
}

# A function that displays a warning message.
#
# Usage: display_warning <warning_message>
function display_warning {
  # Retrieve function arguments:
  local warning_message="$1"

  # Write warning message to the standard error stream:
  echo -e "$warning_message" >&2
}

# A function that accepts an SVG file name and converts the file to PDF.
#
# Usage: svg_to_pdf <source_file>
function svg_to_pdf {
  # Retrieve function arguments:
  local source_file="$1"

  # Verify that the source file is an SVG file:
  if [[ "${source_file##*.}" != "svg" ]]; then
    # Warn the user that the file type is not supported:
    display_warning "Not an SVG file: \`$source_file'"

    # Abort:
    return 1
  fi

  # Verify that the source file exists and is readable:
  if [[ ! -r "$source_file" ]]; then
    # Warn the user that the file is unreadable:
    display_warning "Unable to read the file: \`$source_file'"

    # Abort:
    return 1
  fi

  # Compose the PDF file name:
  local pdf_file="${source_file%%.svg}.pdf"

  # Convert the source file to PDF:
  inkscape --export-pdf "$pdf_file" "$source_file"

  # Display the name of the PDF file:
  [[ "$?" -eq 0 ]] && echo "$pdf_file"
}

# A function that accepts  a file with a list  of SVG files, converts these
# files to PDF, and lists the created PDF files.
#
# Usage: build_pdf_files <index_file>
function build_pdf_files {
  # Retrieve function arguments:
  local input_file="$1"

  # Process the index file:
  while read line; do
    # Skip empty lines:
    [[ -z "$line" ]] && continue

    # Skip lines that begin with the hash:
    [[ "$line" =~ ^[\t\ ]*# ]] && continue

    # Convert the input file:
    svg_to_pdf "$line"
  done < "$input_file"
}

# A function that accepts a file with a list of SVG files and converts them
# to a single PDF file.
#
# Usage: build_slides <index_file>
function build_slides {
  # Retrieve function arguments:
  local input_file="$1"

  # Compose the output file name:
  local output_file="${1%%.conf}.pdf"

  # Convert given SVG files to PDF:
  pdf_files=$(build_pdf_files "$input_file")

  # Verify that the list of PDF files is not empty:
  if [[ -z "$pdf_files" ]]; then
    # Warn the user that there is nothing to do:
    display_warning "Nothing to do."

    # Terminate the script:
    exit 1
  fi

  # Concatenate the individual PDF files:
  pdfjoin -o "$output_file" $pdf_files &>/dev/null

  # Verify that the PDF file has been created:
  if [[ "$?" -ne 0 ]]; then
    # Report an error and terminate the script:
    display_error "Unable to create the target file: \`$output_file'" 1
  fi

  # Remove the individual PDF files:
  rm -f $pdf_files
}

# Process command line options:
while getopts ":hv" OPTION; do
  case "$OPTION" in
    h)
      # Display usage information:
      echo "Usage: $NAME SOURCE_FILE"
      echo
      echo '  -h             display this help and exit'
      echo '  -v             display the script version and exit'

      # Terminate the script:
      exit 0
      ;;
    v)
      # Display version information:
      echo "$NAME $VERSION"

      # Terminate the script:
      exit 0
      ;;
    *)
      # Report an error and terminate the script:
      display_error "Invalid option: $OPTARG" 22
      ;;
  esac
done

# Shift the positional parameters:
shift $(($OPTIND - 1))

# Verify the number of command line arguments:
if [[ "$#" -ne 1 ]]; then
  # Report an error and terminate the script:
  display_error "Invalid number of arguments." 22
fi

# Verify that the index file exists is readable:
if [[ ! -r "$1" ]]; then
  # Report an error and terminate the script:
  display_error "Unable to read the file: \`$1'" 13
fi

# Build the PDF presentation:
build_slides "$1"

# Terminate the script:
exit 0
