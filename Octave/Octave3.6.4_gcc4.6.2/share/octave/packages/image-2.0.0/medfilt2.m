## Copyright (C) 2000 Teemu Ikonen <tpikonen@pcu.helsinki.fi>
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
## @deftypefn {Function File} {} medfilt2(@var{A}, [@var{domain}, @var{padding}])
## Two dimensional median filtering.
##
## Replaces elements of @var{A} with the median of their neighbours defined 
## by true elements of logical matrix @var{domain}. The default @var{domain} 
## is a 3 by 3 matrix with all elements equal to 1. If @var{domain} is 1 by 2
## row vector, the domain matrix will be 
## logical(ones(@var{domain}(2), @var{domain}(1))).
##
## Optional variable @var{padding} defines the padding used in augmenting 
## the borders of @var{A}. See impad for details.
##
## @seealso{ordfilt2}
## @end deftypefn

function retval = medfilt2(A, varargin)

padding = "zeros";
domain = logical(ones(3,3));

for i=1:length(varargin)
  a = varargin{i};
  if(ischar(a))
    padding = a;
  elseif(isvector(a) && size(a) == [1, 2])
    domain = logical(ones(a(2), a(1)));
  elseif(ismatrix(a))
    domain = logical(a);
  endif
endfor

n = sum(sum(domain));
if((n - 2*floor(n/2)) == 0) % n even - more work
  nth = floor(n/2);
  a = ordfilt2(A, nth, domain, padding);
  b = ordfilt2(A, nth + 1, domain, padding);
  retval = a./2 + b./2; # split into two divisions to avoid overflow on integer data
else
  nth = floor(n/2) + 1;
  retval = ordfilt2(A, nth, domain, padding);
endif

endfunction

%!test
%! b = [0,1,2,3;1,8,12,12;4,20,24,21;7,22,25,18];
%! assert(medfilt2(b),[0,1,2,0;1,4,12,3;4,12,20,12;0,7,20,0]);
