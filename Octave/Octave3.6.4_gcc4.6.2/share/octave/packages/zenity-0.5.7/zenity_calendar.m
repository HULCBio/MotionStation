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
## @deftypefn  {Function File} @var{d} = zenity_calendar(@var{title}, @var{day}, @var{month}, @var{year})
## Displays a date selection window.
## The variable @var{title} sets the title of the calendar.
## The optional arguments @var{day}, @var{month}, and @var{year} changes
## the standard selected date.
##
## @seealso{zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function d = zenity_calendar(title, day, month, year)
  [Y, M, D] = datevec(date);
  if (nargin < 1), title = "Select a date"; endif
  if (nargin < 2), day   = D; endif
  if (nargin < 3), month = M; endif
  if (nargin < 4), year  = Y; endif
  
  cmd = sprintf(['zenity --calendar --title="%s" --text="%s" ', ...
                 '--day=%d --month=%d --year=%d --date-format="%%m/%%d/%%Y"'],
                 title, title, day, month, year);
  [status, output] = system(cmd);
  if (status == 0)
    if (length(output) > 0 && output(end) == "\n")
      output = output(1:end-1);
    endif
    d = datestr(output);
  elseif (status == 1)
    d = "";
  else
    error("zenity_calendar: %s", output);
  endif
endfunction
