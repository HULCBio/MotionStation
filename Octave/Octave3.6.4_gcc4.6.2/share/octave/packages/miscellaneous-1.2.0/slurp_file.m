## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{s} = } slurp_file ( f ) 
## @cindex  
## slurp_file return a whole text file @var{f} as a string @var{s}.
##
## @var{f} : string : filename
## @var{s} : string : contents of the file
##
## If @var{f} is not an absolute filename, and 
## is not an immediately accessible file, slurp_file () 
## will look for @var{f} in the path.
## @end deftypefn

function s = slurp_file (f)

  if (nargin != 1)
    print_usage;
  elseif ! ischar (f)
    error ("f  is not a string");
  elseif isempty (f)
    error ("f  is empty");
  endif

  s = "";

  f0 = f;
  [st,err,msg] = stat (f);
  if err && f(1) != "/", 
    f = file_in_loadpath (f);
    if isempty (f)
      ## Could not find it anywhere. Open will fail
      f = f0;
      error ("slurp_file : Can't find '%s' anywhere",f0);
    end
  end

  ## I'll even get decent error messages!
  [status, s] = system (sprintf ("cat '%s'",f), 1);
endfunction
