## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{reference} =} txi2reference (@var{file_pattern})
## Convert @code{.txi} files in the Octave source into a functon reference.
##
## @var{file_pattern} must be a string containing either the name of a @code{.txi}
## file, or a pattern for globbing a set of files (e.g. @t{"*.txi"}). The resulting
## cell array @var{reference} contains a string for each @code{.txi} file. These
## strings can the be passed to @code{makeinfo} to create output in many formats.
##
## As an example, if the Octave source code is located in @t{~/octave_code},
## then this function can be called with
##
## @example
## octave_source_code = "~/octave_code";
## reference = txi2reference (fullfile (octave_source_code, "doc/interpreter", "*.txi"));
## @end example
## @seealso{makeinfo, txi2index}
## @end deftypefn

function result = txi2reference (filename, docstring_handler = @default_docstring_handler)
  ## Check input
  if (nargin == 0)
    print_usage ();
  endif

  if (!ischar (filename))
    error ("txi2reference: first input argument must be a string");
  endif
  
  if (!isa (docstring_handler, "function_handle"))
    error ("txi2reference: second input argument must be a function handle");
  endif
  
  ## Constants for string matching
  DOCSTRING = "@DOCSTRING";
  DS_start = "(";
  DS_stop = ")";

  ## Open and read file
  fid = fopen (filename, "r");
  if (fid < 0)
    error ("txi2reference: couldn't open '%s' for reading", filename);
  endif

  text = char (fread (fid).');
  fclose (fid);
    
  ## Search for @DOCSTRING
  DOCSTRING_idx = strfind (text, DOCSTRING);
  DS_start_idx = find (text == DS_start);
  DS_stop_idx = find (text == DS_stop);

  ## Process search results
  result = "";
  prev = 1;
  for n = 1:length (DOCSTRING_idx)
    idx = DOCSTRING_idx (n);
    start = DS_start_idx (find (DS_start_idx > idx, 1));
    stop = DS_stop_idx (find (DS_stop_idx > idx, 1));
    fun = text (start+1:stop-1);
    fun_text = docstring_handler (fun);
    result = strcat (result, text (prev:idx-1), fun_text);
    prev = stop + 1;
  endfor
  result = strcat (result, text (prev:end));
endfunction

function ds = default_docstring_handler (fun)
  ds = sprintf ("See: @xref{%s}", fun);
endfunction
