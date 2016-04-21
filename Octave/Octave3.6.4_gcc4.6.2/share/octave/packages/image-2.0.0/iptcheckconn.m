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
## @deftypefn {Function File} {} iptcheckconn (@var{con}, @var{func_name}, @var{var_name}, @var{pos})
## Check if argument is valid connectivity.
##
## If @var{con} is not a valid connectivity argument, gives a properly formatted
## error message. @var{func_name} is the name of the function to be used on the
## error message, @var{var_name} the name of the argument being checked (for the
## error message), and @var{pos} the position of the argument in the input.
##
## A valid connectivity argument must be either double or logical. It must also
## be either a scalar from set [1 4 6 8 18 26], or a symmetric matrix with all
## dimensions of size 3, with only 0 or 1 as values, and 1 at its center.
##
## @end deftypefn

function iptcheckconn (con, func_name, var_name, pos)

  ## thanks to Oldak in ##matlab for checking the validity of connectivities
  ## with more than 2D and the error messages

  if (nargin != 4)
    print_usage;
  elseif (!ischar (func_name))
    error ("Argument func_name must be a string");
  elseif (!ischar (var_name))
    error ("Argument var_name must be a string");
  elseif (!isnumeric (pos) || !isscalar (pos) || !isreal (pos) || pos <= 0 || rem (pos, 1) != 0)
    error ("Argument pos must be a real positive integer");
  endif

  base_msg = sprintf ("Function %s expected input number %d, %s, to be a valid connectivity specifier.\n       ", ...
                      func_name, pos, var_name);

  ## error ends in \n so the back trace of the error is not show. This is on
  ## purpose since the whole idea of this function is already to give a properly
  ## formatted error message
  if (!any (strcmp (class (con), {'logical', 'double'})) || !isreal (con) || !isnumeric (con))
    error ("%sConnectivity must be a real number of the logical or double class.\n", base_msg);
  elseif (isscalar (con))
    if (!any (con == [1 4 6 8 18 26]))
      error ("%sIf connectivity is a scalar, must belong to the set [1 4 6 8 18 26].\n", base_msg);
    endif
  elseif (ismatrix (con))
    center_index = ceil(numel(con)/2);
    if (any (size (con) != 3))
      error ("%sIf connectivity is a matrix, all dimensions must have size 3.\n", base_msg);
    elseif (!all (con(:) == 1 | con(:) == 0))
      error ("%sIf connectivity is a matrix, only 0 and 1 are valid.\n", base_msg);
    elseif (con(center_index) != 1)
      error ("%sIf connectivity is a matrix, central element must be 1.\n", base_msg);
    elseif (!all (con(1:center_index-1) == con(end:-1:center_index+1)))
      error ("%sIf connectivity is a matrix, it must be symmetric relative to its center.\n", base_msg);
    endif
  else
    error ("%s\n", base_msg);
  endif

endfunction

%!test ("iptcheckconn (4, 'func', 'var', 2)");                      # simple must work
%!test ("iptcheckconn (ones(3,3,3,3), 'func', 'var', 2)");          # accept more than just 3D
%!fail ("iptcheckconn (3, 'func', 'var', 2)");                      # does not belong to set
%!fail ("iptcheckconn ([1 1 1; 1 0 1; 1 1 1], 'func', 'var', 2)");  # matrix center must be 1
%!fail ("iptcheckconn ([1 2 1; 1 1 1; 1 1 1], 'func', 'var', 2)");  # matrix must be 1 and 0 only
%!fail ("iptcheckconn ([0 1 1; 1 1 1; 1 1 1], 'func', 'var', 2)");  # matrix must be symmetric
%!fail ("iptcheckconn (ones(3,3,3,4), 'func', 'var', 2)");          # matrix must have all sizes 3
