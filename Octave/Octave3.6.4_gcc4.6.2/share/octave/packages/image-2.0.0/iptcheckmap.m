## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {} iptcheckmap (@var{in}, @var{func_name}, @var{var_name}, @var{pos})
## Check if argument is valid colormap.
##
## If @var{in} is not a valid colormap, gives a properly formatted error message.
## @var{func_name} is the name of the function to be used on the error message,
## @var{var_name} the name of the argument being checked (for the error message),
## and @var{pos} the position of the argument in the input.
##
## A valid colormap is a 2-D matrix with 3 columns of doubles with values between
## 0 and 1 (inclusive), that refer to the intensity levels of red, green and blue.
##
## @seealso{colormap}
## @end deftypefn

function iptcheckmap (in, func_name, var_name, pos)

  if (nargin != 4)
    print_usage;
  elseif (!ischar (func_name))
    error ("Argument func_name must be a string");
  elseif (!ischar (var_name))
    error ("Argument var_name must be a string");
  elseif (!isnumeric (pos) || !isscalar (pos) || !isreal (pos) || pos <= 0 || rem (pos, 1) != 0)
    error ("Argument pos must be a real positive integer");
  endif

  ## error ends in \n so the back trace of the error is not show. This is on
  ## purpose since the whole idea of this function is already to give a properly
  ## formatted error message
  if (!iscolormap (in))
    error ("Function %s expected input number %d, %s, to be a valid colormap.\n...
       Valid colormaps must be nonempty, double, 2-D matrices with 3 columns.\n", ...
      func_name, pos, var_name);
  endif

endfunction

%!test ("iptcheckmap (jet(64), 'func', 'var', 2)");                 # simple must work
%!fail ("iptcheckconn (3, 'func', 'var', 2)");                      # not a colormap
