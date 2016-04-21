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
## @deftypefn {Function File} {@var{valid} =} iptcheckstrs (@var{in}, @var{valid_str}, @var{func_name}, @var{var_name}, @var{pos})
## Check if argument is a valid string.
##
## If @var{in} is not a string, present in the cell array of strings
## @var{valid_str} gives a properly formatted error message. Otherwise,
## @var{valid} is the matched string. The performed matching is case-insensitive.
##
## @var{func_name} is the name of the function to be used on the error message,
## @var{var_name} the name of the argument being checked (for the error message),
## and @var{pos} the position of the argument in the input.
##
## @seealso{strcmp, strcmpi, find, validatestring}
## @end deftypefn

function out = iptcheckstrs (in, valid_str, func_name, var_name, pos)

  if (nargin != 5)
    print_usage;
  elseif (!ischar (in))
    error ("Argument 'in' must be a string.");
  elseif (!iscellstr (valid_str))
    error ("Argument 'valid_str' must be a cell array of strings.");
  elseif (!ischar (func_name))
    error ("Argument 'func_name' must be a string");
  elseif (!ischar (var_name))
    error ("Argument 'var_name' must be a string");
  elseif (!isnumeric (pos) || !isscalar (pos) || !isreal (pos) || pos <= 0 || rem (pos, 1) != 0)
    error ("Argument 'pos' must be a real positive integer");
  endif

  idx = find (strcmpi (valid_str, in) == 1, 1, "first");

  ## error ends in \n so the back trace of the error is not show. This is on
  ## purpose since the whole idea of this function is already to give a properly
  ## formatted error message
  if (isempty (idx))
    valid_str = cellfun (@(x) cstrcat (x, ", "), valid_str, "UniformOutput", false);
    valid_str = cstrcat (valid_str{:});
    error("Function %s expected its %s input argument, %s, to match one of these strings:\n...
         %s\n...
       The input, '%s', did not match any of the valid strings.\n", ...
      func_name, iptnum2ordinal (pos), var_name, valid_str(1:end-2), in);
  else
    out = valid_str{idx};
  endif

endfunction

%!assert (iptcheckstrs ("two", {"one", "two", "three"}, "func", "var", 1) == "two" );    # check simple works
%!assert (iptcheckstrs ("Two", {"one", "two", "three"}, "func", "var", 1) == "two" );    # check case insensitive
%!fail ('iptcheckstrs ("four", {"one", "two", "three"}, "func", "var", 1)');             # check failure if not found
