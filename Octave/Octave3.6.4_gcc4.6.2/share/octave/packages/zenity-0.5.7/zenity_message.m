## Copyright (C) 2006  Søren Hauberg
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
## @deftypefn  {Function File} zenity_message(@var{text}, @var{type})
## Displays a graphical message dialog.
## The variable @var{text} sets the message of the dialog, and the
## optional variable @var{type} sets the type of the message.
## @var{type} must be one of the following strings @code{error},
## @code{info}, @code{question}, and @code{warning}. The default
## value of @var{type} is @code{info}. Retuns the value @code{status}
## which is 0 for 'Ok' and 1 for 'Cancel' button selection; a value 
## of -1 indicates a failure of dialog box.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function status=zenity_message(text, type)
  if (nargin == 0 || !ischar(text)), print_usage(); endif
  if (nargin < 2), type = "info"; endif
  if !(ischar(type) && any(strcmp(type, {"error", "info", "question", "warning"})))
    error("zenity_message: unsupported message type: %s", type);
  endif
  
  cmd = sprintf('zenity --%s --text="%s"', type, text);
  [status, output] = system(cmd);
  if (status == -1)
    error("zenity_message: %s", output);
  endif
endfunction
