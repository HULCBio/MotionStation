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

function [header, title, footer] = get_overview_header_title_and_footer (options, name, root = "")
  if (isfield (options, "overview_header"))
    header = options.overview_header;
  elseif (isfield (options, "header"))
    header = options.header;
  else
    header = "<html><head><title></title><head><body>";
  endif
  
  if (isfield (options, "css"))
    header = strrep (header, "%css", options.css);
  endif
  
  header = strrep (header, "%root", root);
  if (isfield (options, "pack_body_cmd"))
    header = strrep (header, "%body_command", options.pack_body_cmd);
  elseif (isfield (options, "body_command"))
    header = strrep (header, "%body_command", options.body_command);
  endif
  
  if (isfield (options, "overview_title"))
    title = options.overview_title;
  elseif (isfield (options, "title"))
    title = options.title;
  else
    title = "List of Functions for the '%name' package";
  endif
  title = strrep (title, "%name", name);
  title_start_idx = strfind (lower (header), "<title>");
  title_stop_idx = strfind (lower (header), "</title>");
  if (!isempty (title_start_idx) && !isempty (title_stop_idx))
    header = sprintf ("%s<title>%s%s", header (1:title_start_idx-1), title, 
                      header (title_stop_idx:end));
  else
    header = strrep (header, "%title", title);
  endif

    ## Write footer of overview page
    if (isfield (options, "overview_footer"))
      footer = options.overview_footer;
    elseif (isfield (options, "footer"))
      footer = options.footer;
    else
      footer = "</body></html>";
    endif
endfunction
