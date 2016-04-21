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
## @deftypefn  {Function File} @var{s} = zenity_list(@var{title}, @var{columns}, @var{data}, @var{options1}, ...)
## Displays a graphical list of data.
## The variable @var{title} sets the title of the list. The variable
## @var{columns} must be a cell array of strings of length N containing the headers
## of the list. The variable @var{data} must be cell array of strings of
## length NxM containing the data of the list.
##
## The code
## @example
## zenity_list("Age versus Height", @{"Age", "Height"@}, 
## @{"10", "20"; "120cm", "180cm"@})
## @end example
## produces a list of the data. The user can select a row in the table, and it's
## first value will be returned by the function when the user closes the window.
##
## It's possible to alter the behaviour of the list window by passing more than
## three arguments to the funtion. Theese optional string arguments can be
## @table @samp
## @item checklist
## The first row in the list will be a check box. The first value of each data row
## must be either "TRUE" or "FALSE".
## @item radiolist
## The first row in the list will be a radio list. The first value of each data row
## must be either "TRUE" or "FALSE".
## @item editable
## The values of the list will be editable by the user.
## @item A numeric value
## The value returned by the function will be the value of this column
## of the user selected row.
## @item all
## The value returned by the function will be the entire row selected by the user.
## @end table
##
## @seealso{zenity_calendar, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function s = zenity_list(title, columns, data, varargin)
  if (nargin < 3 || !ischar(title) || !iscellstr(columns) || !iscellstr(data))
    print_usage();
  endif
  
  checklist = radiolist = editable = "";
  print_column = "1";
  for i = 1:length(varargin)
    option = varargin{i};
    isc = ischar(option);
    if (isc && strcmpi(option, "checklist"))
      checklist = "--checklist";
    elseif (isc && strcmpi(option, "radiolist"))
      radiolist = "--radiolist";
    elseif (isc && strcmpi(option, "editable"))
      editable = "--editable";
    elseif (isc && strcmpi(option, "all"))
      print_column = "all";
    elseif (isnumeric(option))
      print_column = num2str(option);
    else
      error("zenity_list: unsupported option");
    endif
  endfor

  columns = sprintf('--column="%s" ', columns{:});
  data = sprintf("%s ", data{:});

  cmd = sprintf('zenity --list --title="%s" %s %s %s --print-column="%s" --separator=":" %s %s', ...
                title, checklist, radiolist, editable, print_column, columns, data);
  [status, output] = system(cmd);
  if (status == 0)
    if (length(output) > 0 && output(end) == "\n")
      output = output(1:end-1);
    endif
    idx = strfind(output, ":");
    idx = [0, idx, length(output)+1];
    l = length(idx);
    if (l == 2)
      s = output;
    else
      s = cell(1, l-1);
      for i = 1:l-1
        s{i} = output((idx(i)+1):(idx(i+1)-1));
      endfor
    endif
  elseif (status == 1)
    s = "";
  else
    error("zenity_list: %s", output);
  endif
endfunction
