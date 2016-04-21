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
## @deftypefn  {Function File} @var{h} = zenity_progress(@var{title}, @var{option1}, @var{option2})
## @deftypefnx {Function File} zenity_progress(@var{h}, @var{progress})
## @deftypefnx {Function File} zenity_progress(@var{h}, @var{progress}, @var{text})
## Displays a graphical progress bar.
## If the first argument is either non-present or a string, a new progress bar is
## created and a handle is returned. If the first argument is a string it will be
## used as the title of the progress bar. The two optional arguments @var{option1}
## and @var{option2} can be
## @table @samp
## @item auto-close
## The progress bar will be closed when it reaches 100.
## @item pulsate
## The progress bar will pulsate.
## @end table
##
## If the first argument is a handle to a progress bar and the second
## argument is an integer, the progress bar will set its current value
## to the given integer. If the second argument is a string, the text
## of the progress bar will be set to the given string.
## It is possible to pass both an integer and a string to the function
## in one function call.
##
## @seealso{zenity_calendar, zenity_list, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function pid = zenity_progress(h, progress, text)
  ## Create a progress bar?
  if (nargin == 0 || (nargin >= 1 && ischar(h)))
    ## Title
    title = options = "";
    if (nargin == 1)
        title = sprintf('--title="%s" --text="%s"', h, h);
    endif
    ## Options
    if (nargin > 1 && ischar(progress))
      if (strcmpi(progress, "auto-close"))
        options = sprintf("%s --auto-close", options);
      elseif (strcmpi(progress, "pulsate"))
        options = sprintf("%s --pulsate", options);
      endif
    endif
    if (nargin > 2 && ischar(text))
      if (strcmpi(text, "auto-close"))
        options = sprintf("%s --auto-close", options);
      elseif (strcmpi(text, "pulsate"))
        options = sprintf("%s --pulsate", options);
      endif
    endif
    ## Start the process
    pid = popen(["zenity --progress ", title, " ", options], "w");
  ## Handle an existing process
  elseif (nargin > 0 && isnumeric(h))
    out = "";
    if (nargin > 1 && isnumeric(progress))
      out = sprintf("%s\n%d\n", out, progress);
    endif
    if (nargin > 1 && ischar(progress))
      out = sprintf("%s\n#%s\n", out, progress);
    endif
    if (nargin > 2 && isnumeric(text))
      out = sprintf("%s\n%d\n", out, text);
    endif
    if (nargin > 2 && ischar(text))
      out = sprintf("%s\n#%s\n", out, text);
    endif
    fputs(h, out);
  else
    print_usage();
  endif
endfunction
