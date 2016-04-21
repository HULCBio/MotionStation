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
## @deftypefn {Function File} {} ordfilt2(@var{A}, @var{nth}, @var{domain}, [@var{S}, @var{padding}])
## Two dimensional ordered filtering.
##
## Ordered filter replaces an element of @var{A} with the @var{nth} 
## element of the sorted set of neighbours defined by the logical 
## (boolean) matrix @var{domain}.
## Neighbour elements are selected to the sort if the corresponding 
## element in the @var{domain} matrix is true.
## 
## The optional variable @var{S} is a matrix of size(@var{domain}). 
## Values of @var{S} corresponding to nonzero values of domain are 
## added to values obtained from @var{A} when doing the sorting.
##
## Optional variable @var{padding} determines how the matrix @var{A} 
## is padded from the edges. See impad for details.
## 
## @seealso{medfilt2}
## @end deftypefn

function retval = ordfilt2(A, nth, domain, varargin)

S = zeros(size(domain));
padding = "zeros";
for i=1:length(varargin)
  a = varargin{:};
  if(ischar(a))
    padding = a;
  elseif(ismatrix(a) && size(a) == size(domain))
    S = a;
  endif
endfor

domain = logical(domain);

xpad(1) = floor((size(domain, 2)+1)/2) - 1;
xpad(2) = size(domain,2) - xpad(1) - 1;
ypad(1) = floor((size(domain, 1)+1)/2) - 1;
ypad(2) = size(domain,1) - ypad(1) - 1;

if(ypad(1) >= size(A,1) || xpad(1) >= size(A,2))
  error("domain matrix too large");
endif;

A = impad(A, xpad, ypad, padding);
retval = __spatial_filtering__ (A, domain, "ordered", S, nth);

endfunction
