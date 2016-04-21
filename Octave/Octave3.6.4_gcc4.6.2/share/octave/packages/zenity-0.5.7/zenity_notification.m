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
## @deftypefn  {Function File} zenity_notification(@var{text}, @var{icon})
## Displays an icon with a text in the notification area.
## The variable @var{text} sets the text in the notification area, and the
## optional variable @var{icon} determines which icon to show.
## @var{icon} can be either @code{info}, @code{warning}, @code{question},
## and @code{error}.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection}
## @end deftypefn

function zenity_notification(text, icon)
  if (nargin == 0 || !ischar(text))
    print_usage();
  endif
  
  icon = "";
  if (nargin > 1 && ischar(icon))
    icon = sprintf('--window-icon="%s"', icon);
  endif
  
  cmd = sprintf('zenity --notification --text="%s" %s', text, icon);
  [status, output] = system(cmd);
  if (status == -1)
    error("zenity_notification: %s", output);
  endif
endfunction
