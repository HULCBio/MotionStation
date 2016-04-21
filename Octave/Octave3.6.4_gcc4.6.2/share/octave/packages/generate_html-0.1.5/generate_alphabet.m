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
## @deftypefn {Function File} generate_alphabet (@var{directory}, @var{data_file}, @
## @var{root}, @var{options})
## @end deftypefn

function generate_alphabet (directory, data_file, root, options = struct ())
  ## Check input
  if (!ischar (directory))
    error ("generate_alphabet: first input argument must be a string");
  endif
    
  if (!ischar (data_file))
    error ("generate_alphabet: second input argument must be a string");
  endif
    
  if (!ischar (root))
    error ("generate_alphabet: third input argument must be a string");
  endif
    
  ## If options is a string, call get_html_options
  if (ischar (options))
    options = get_html_options (options);
  elseif (!isstruct (options))
    error ("generate_alphabet: fourth input argument must be a string or a structure");
  endif
  
  ## Load data
  data = load (data_file);
  data = data.functions;
  
  ## Sort data
  data = sort (data);
  
  ## Convert data to lower case but also keep the original in memory
  ldata = lower (data);
  
  ## Iterate over each function
  ## First we find the first function that starts with 'a'
  for a = 1:length (data)
    if (ldata {a}(1) >= "a")
      break;
    endif
  endfor
  
  ## Then we iterate over each function until we get something that doesn't start with 'z'
  current = data {a}(1);
  [fid, footer] = new_file (directory, current, options);
  for idx = a:length (data)
    ## Are we still working on the same file
    if (ldata {idx}(1) != current)
      fprintf (fid, "</div\n%s", footer);
      fclose (fid);
      current = ldata {idx}(1);
      [fid, footer] = new_file (directory, current, options);
    endif
    
    ## Write the actual function to the file
    fun = data {idx};
    fprintf (fid, "<div class=\"func\"><b><a href=\"%s/function/%s.html\">%s</a></b></div>\n",
             root, fun, fun);
    try
      sentence = get_first_help_sentence (fun, 200);
    catch
      warning ("Marking '%s' as not implemented", fun);
      sentence = "Not implemented";
    end_try_catch
    fprintf (fid, "<div class=\"ftext\">%s</div>\n", sentence);
  endfor

  fprintf (fid, "</div\n%s", footer);
  fclose (fid);
endfunction

function [fid, footer] = new_file (directory, current, options)
  current = upper (current);
  filename = fullfile (directory, sprintf ("%s.html", current));
  fid = fopen (filename, "w");
  if (fid <= 0)
    error ("generate_alphabet: could not open '%s' for writing", filename);
  endif
  
  options.body_command = 'onload="javascript:fix_top_menu (); javascript:alphabetical_menu ();"';
  title = sprintf ("Alphabetical List of Functions: %s", current);
  [header, title, footer] = get_overview_header_title_and_footer (options, title, "../");

  fprintf (fid, "%s\n", header);
  fprintf (fid, "<h2><a name=\"%s\">%s</a></h2>\n<div>\n", current, current);
endfunction

