## Copyright (C) 2006 Muthiah Annamalai
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
## @deftypefn  {Function File} @var{output} = zenity_scale(@var{title},@var{text}, @var{value}, @var{minval}, @var{maxval},@var{step},@var{print_partial},@var{hideval})
## Displays a selection scale (range widget) window.
## Allows the user to choose a parameter within the set ranges, and sets
## default value, and step sizes.
## The variable @var{title} sets the title of the window.
## The variable @var{text} sets the label of the range widget.
## The other arguments @var{value}, @var{minval},@var{maxval},
## @var{step}, @var{print_partial}, and @var{hideval}.
## The range widget can be used to select anywhere from @var{minval} to
## @var{maxval} values in increments of @var{step}. The variable
## @var{print_partial} and @var{hideval} are boolean flags to partial
## and hidden views of the value on the range widget.
## The first 3 parameters are essential, while the remaining parameters
## @var{minval}, @var{maxval},@var{step},@var{print_partial},@var{hideval} if
## not specified take on default values of 0,100,1,false,false
## respectively.
## @seealso{zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function output = zenity_scale(title,text, value, minval, maxval, step, print_partial, hideval)

  if (nargin < 1), title="Adjust the scale value"; endif
  if (nargin < 2), text=""; endif
  if (nargin < 3), value=0; endif
  if (nargin < 4), minval= 0; endif
  if (nargin < 5), maxval= 100; endif
  if (nargin < 6), step  = 1; endif
  if (nargin < 7), print_partial = false; endif
  if (nargin < 8), hideval = false; endif

  ppartial="";
  hvalue="";

  if(length(title)==0), title="Adjust the scale value"; endif
  if(print_partial), ppartial="--print-partial"; endif
  if(hideval), hvalue="--hide-value"; endif
  
  cmd = sprintf(['zenity --scale --title="%s" --text="%s" ', ...
                 '--value=%d --min-value=%d --max-value=%d --step=%d ',...
		 '%s %s '],title, text, value, minval,maxval,step,ppartial,hvalue);
  [status, output] = system(cmd);
  if (status == 0)
    output = str2num(output);
  elseif (status == 1)
    output = value; ##default when user kills it.
  else
    error("zenity_scale: %s", output); ##kill -9 
  endif
endfunction
%
%(Shamelessly copied from Søren Hauberg's zenity_calendar).
%zenity --scale --text 'What is in your Wallet' --value 10 --min-value 0 --max-value 100 --step 5
%zenity_scale('','What is in your Wallet',10,0,100,5)
%