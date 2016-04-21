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
## @deftypefn  {Function File} @var{s} = zenity_entry(@var{text}, @var{entry_text}, @var{password})
## Displays a text entry dialog.
## The variable @var{text} sets the title of the dialog, and the
## @var{entry_text} variable sets the default value of the text
## entry field. If the @var{password} variable is non-empty the
## value of the text entry field will not be displayed on the screen.
## All arguments are optional.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function s = zenity_entry(text, entrytext, password)
  if (nargin < 1), text      = ""; endif
  if (nargin < 2), entrytext = ""; endif
  if (nargin < 3), password  = ""; endif

  if (!isempty(text)), text = sprintf('--text="%s" --title="%s"', text, text); endif
  if (!isempty(entrytext)), entrytext = sprintf('--entry-text="%s"', entrytext); endif
  if (!isempty(password)), password = "--hide-text"; endif
  
  cmd = sprintf('zenity --entry %s %s %s', text, entrytext, password);
  [status, output] = system(cmd);
  if (status == 0)
    if (output(end) == "\n") output = output(1:end-1); endif
    s = output;
  elseif (status == 1)
    s = "";
  else
    error("zenity_entry: %s", output);
  endif
endfunction
