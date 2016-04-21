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
## @deftypefn  {Function File} zenity_file_selection(@var{title}, @var{option1}, ...)
## Opens a file selection dialog.
## The variable @var{title} sets the title of the file selection window.
## The optional string arguments can be
## @table @samp
## @item save
## The file selection dialog is a dialog for saving files.
## @item multiple
## It is possible to select multiple files.
## @item directory
## It is possible to select directories as well as files.
## @item Anything else
## The argument will be the default selected file.
## @end table
## and @code{error}.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_notification}
## @end deftypefn

function files = zenity_file_selection(title, varargin)
  
  save = multiple = directory = filename = title = "";
  if (nargin == 0 || isempty(title)), title = "Select a file"; endif
  for i = 1:length(varargin)
    option = varargin{i};
    isc = ischar(option);
    if (isc && strcmpi(option, "save"))
      save = "--save";
    elseif (isc && strcmpi(option, "multiple"))
      multiple = "--multiple";
    elseif (isc && strcmpi(option, "directory"))
      directory = "--directory";
    elseif (isc)
      filename = sprintf('--filename="%s"', varargin{i});
    else
      error("zenity_file_selection: unsupported option");
    endif
  endfor
  
  cmd = sprintf('zenity --file-selection --title="%s" --separator=":" %s %s %s %s', ...
                 title, save, multiple, directory, filename);
  [status, output] = system(cmd);
  if (status == 0)
    if (length(output) > 0 && output(end) == "\n")
      output = output(1:end-1);
    endif
    idx = strfind(output, ":");
    idx = [0, idx, length(output)+1];
    l = length(idx);
    if (l == 2)
      files = output;
    else
      files = cell(1, l-1);
      for i = 1:l-1
        files{i} = output((idx(i)+1):(idx(i+1)-1));
      endfor
    endif
  elseif (status == 1)
    files = "";
  else
    error("zenity_file_selection: %s", output);
  endif
endfunction
