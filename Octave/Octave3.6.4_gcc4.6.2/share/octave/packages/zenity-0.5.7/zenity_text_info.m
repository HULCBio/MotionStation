## Copyright (C) 2006 Søren Hauberg
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} @var{s} = zenity_text_info(@var{title}, @var{text}, @var{editable})
## Display a large amount of text in a graphical display.
## The title of the display window is set with the variable @var{title},
## and the actual text ti display is set with the variable @var{text}.
## If the optional argument @var{editable} is given the displayed text
## is editable. In this case the altered text is returned from the function.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_file_selection, zenity_notification}
## @end deftypefn

function s = zenity_text_info(title, text, editable)
  if (nargin < 2 || !ischar(title) || !ischar(text))
    print_usage();
  endif

  if (nargin < 3)
    editable = "--editable";
  else
    editable = "";
  endif
  
  filename = tmpnam();
  fid = fopen(filename, "w");
  fprintf(fid, "%s", text);
  fclose(fid);
  
  cmd = sprintf('zenity --text-info --title="%s" --filename="%s" %s', title, filename, editable);
  [status, output] = system(cmd);
  unlink(filename);
  if (status == 0)
    s = output;
  elseif (status == 1)
    s = "";
  else
    error("zenity_text_info: %s", output);
  endif
endfunction
