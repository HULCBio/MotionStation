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
## @deftypefn {Function File} {} iptchecknargin (@var{low}, @var{high}, @var{in}, @var{func_name})
## Checks for correct number of arguments.
##
## This function returns an error unless @var{in} is between the values of
## @var{low} and @var{high}. It does nothing otherwise. They all must be non
## negative scalar integers. @var{high} can also be Inf.
##
## @var{func_name} is the name of the function to be used on the error message.
##
## @seealso{error, nargin, nargout, narginchk, nargoutchk}
## @end deftypefn

function iptchecknargin (low, high, in, func_name)

  if (nargin != 4)
    print_usage;
  elseif (!isnumeric (low) || !isscalar (low) || !isreal (low) || low < 0 || !isfinite (low) || rem (low, 1) != 0)
    error ("Argument 'low' must be a non-negative scalar integer");
  elseif (!isnumeric (high) || !isscalar (high) || !isreal (high) || low < 0 || (isfinite (high) && rem (low, 1) != 0))
    error ("Argument 'high' must be a non-negative scalar integer or Inf");
  elseif (!isnumeric (in) || !isscalar (in) || !isreal (in) || in < 0 || !isfinite (in) || rem (in, 1) != 0)
    error ("Argument 'in' must be a non-negative scalar integer");
  elseif (!ischar (func_name))
    error ("Argument 'func_name' must be a string");
  elseif (low > high)
    error ("Minimun number of arguments cannot be larger than maximum number of arguments")
  endif

  ## error ends in \n so the back trace of the error is not show. This is on
  ## purpose since the whole idea of this function is already to give a properly
  ## formatted error message
  if (in < low)
    error ("Function %s expected at least %d input arguments(s) but was called instead with %d input argument(s).\n", ...
           func_name, low, in);
  elseif (in > high)
    error ("Function %s expected at most %d input argument(s) but was called instead with %d input argument(s).\n", ...
           func_name, high, in);
  endif

endfunction

%!test ('iptchecknargin (0, 2, 1, "func")');    # check simple works
%!test ('iptchecknargin (0, Inf, 1, "func")');  # check Inf on max
%!fail ('iptchecknargin (3, 2, 1, "func")');    # check fail min >max
%!fail ('iptchecknargin (2, 3, 1, "func")');    # check fail in out of range
