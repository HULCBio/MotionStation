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
## @deftypefn {Function File} generate_operators (@var{outdir}, @var{options})
## Generate a HTML page with a list of operators available in GNU Octave.
## @end deftypefn

function generate_operators (outdir = "htdocs", options = struct ())
  ## Check input
  if (!ischar (outdir))
    error ("generate_operators: first input argument must be a string");
  endif
    
  ## If options is a string, call get_html_options
  if (ischar (options))
    options = get_html_options (options);
  elseif (!isstruct (options))
    error ("generate_operators: second input argument must be a string or a structure");
  endif
  
  ## Create directories if needed
  if (!exist (outdir, "dir"))
    mkdir (outdir);
  endif
  name = fullfile (outdir, "operators.html");
  
  ## Generate html
  title = "Operators and Keywords";
  options.body_command = 'onload="javascript:fix_top_menu ();"';
  [header, title, footer] = get_overview_header_title_and_footer (options, title);

  fid = fopen (name, "w");
  if (fid < 0)
    error ("generate_operators: couldn't open file for writing");
  endif
  
  fprintf (fid, "%s\n", header);  
  
  fprintf (fid, "<h2 class=\"tbdesc\">Operators</h2>\n\n");
  write_list (__operators__, fid, false);

  fprintf (fid, "<h2 class=\"tbdesc\">Keywords</h2>\n\n");
  write_list (__keywords__, fid, true);

  fprintf (fid, "\n%s\n", footer);
  fclose (fid);
endfunction

function write_list (list, fid, write_anchors)
  for k = 1:length (list)
    elem = list {k};
    [text, format] = get_help_text (elem);
    if (strcmp (format, "texinfo"))
      text = strip_defs (text);
      text = __makeinfo__ (text, "plain text");
    endif
    if (write_anchors)
      fprintf (fid, "<a name=\"%s\">\n", elem);
    endif
    fprintf (fid, "<div class=\"func\"><b>%s</b></div>\n", elem);
    fprintf (fid, "<div class=\"ftext\">%s</div>\n", text); # XXX: don't use text
    if (write_anchors)
      fprintf (fid, "</a>\n\n");
    endif
  endfor
endfunction

function text = strip_defs (text)
  ## Lines ending with "@\n" are continuation lines, so they should be concatenated
  ## with the following line.
  text = strrep (text, "@\n", " ");
  
  ## Find, and remove, lines that start with @def. This should remove things
  ## such as @deftypefn, @deftypefnx, @defvar, etc.
  keep = true (size (text));
  def_idx = strfind (text, "@def");
  if (!isempty (def_idx))
    endl_idx = find (text == "\n");
    for k = 1:length (def_idx)
      endl = endl_idx (find (endl_idx > def_idx (k), 1));
      if (isempty (endl))
        keep (def_idx (k):end) = false;
      else
        keep (def_idx (k):endl) = false;
      endif
    endfor
  
    ## Remove the @end ... that corresponds to the @def we removed above
    def1 = def_idx (1);
    space_idx = find (text == " ");
    space_idx = space_idx (find (space_idx > def1, 1));
    bracket_idx = find (text == "{" | text == "}");
    bracket_idx = bracket_idx (find (bracket_idx > def1, 1));
    if (isempty (space_idx) && isempty (bracket_idx))
      error ("generate_operators: couldn't parse texinfo");
    endif
    sep_idx = min (space_idx, bracket_idx);
    def_type = text (def1+1:sep_idx-1);

    end_idx = strfind (text, sprintf ("@end %s", def_type));
    if (isempty (end_idx))
      error ("generate_operators: couldn't parse texinfo");
    endif
    endl = endl_idx (find (endl_idx > end_idx, 1));
    if (isempty (endl))
      keep (end_idx:end) = false;
    else
      keep (end_idx:endl) = false;
    endif
    
    text = text (keep);
  endif
endfunction
