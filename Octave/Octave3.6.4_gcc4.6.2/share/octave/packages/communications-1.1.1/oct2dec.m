## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File}  @var{d} = oct2dec (@var{c})
##
## Convert octal to decimal values.
##
## Each element of the octal matrix @var{c} is converted to a decimal value.
##
## @seealso{base2dec,bin2dec,dec2bin}
## @end deftypefn

function d = oct2dec (c)

  if (nargin != 1)
    print_usage ();
  endif

  # Check for negative or non-integer values
  if (any (c(:) < 0) || any (c(:) != floor (c(:))))
    error ("oct2dec: c must be an octal matrix");
  endif

  d = zeros (size (c));
  l = size (c, 2);
  for k = 1:l
    str = num2str (c(:,k));
    d(:,k) = base2dec (str, 8);
    if (any (isnan (d(:,k))))
      error ("oct2dec: c must be an octal matrix");
    endif
  endfor

endfunction

%!shared x,y
%! x = reshape ([0:79], 10, 8)(1:8,:);
%! y = reshape ([0:63], 8, 8);
%!assert (oct2dec (0), 0)
%!assert (oct2dec (77777777), 2^24 - 1)
%!assert (oct2dec (x), y)

%% Test input validation
%!error oct2dec ()
%!error oct2dec (0, 0)
%!error <octal matrix> oct2dec (0.1)
%!error <octal matrix> oct2dec (-1)
%!error <octal matrix> oct2dec (8)
