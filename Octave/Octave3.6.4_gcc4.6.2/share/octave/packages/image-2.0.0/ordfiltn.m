## Copyright (C) 2008 Soren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} {} ordfiltn(@var{A}, @var{nth}, @var{domain}, [@var{S}, @var{padding}])
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
## is padded from the edges. See @code{padarray} for details.
## 
## @seealso{ordfilt2, padarray}
## @end deftypefn

## This function is based on 'ordfilt2' by Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## which is released under GPLv2 or later.

function retval = ordfiltn(A, nth, domain, varargin)
  ## Check input
  if (nargin < 3)
    error("ordfiltn: not enough input arguments");
  endif
  if (!ismatrix(A))
    error("ordfiltn: first input must be an array");
  endif
  if (!isscalar(nth) || nth <= 0 || nth != round(nth))
    error("ordfiltn: second input argument must be a positive integer");
  endif
  if (!ismatrix(domain) && !isscalar(domain))
    error("ordfiltn: third input argument must be an array or a scalar");
  endif
  if (isscalar(domain) && (domain <= 0 || domain != round(domain)))
    error("ordfiltn: third input argument must be a positive integer, when it is a scalar");
  endif
  if (isscalar(domain))
    domain = ones(repmat(domain, 1, ndims(A)), "logical");
  endif
  
  if (ndims(A) != ndims(domain))
    error("ordfiltn: first and second argument must have same dimensionality");
  endif
  if (any(size(A) < size(domain)))
    error("ordfiltn: domain array cannot be larger than the data array");
  endif    

  ## Parse varargin
  S = zeros(size(domain));
  padding = 0;
  for i=1:length(varargin)
    a = varargin{:};
    if (ischar(a) || isscalar(a))
      padding = a;
    elseif (ismatrix(a) && size_equal(a, domain))
      S = a;
    endif
  endfor

  ## Make sure 'domain' is logical. The C++ code assumes this.
  domain = logical(domain);

  ## Pad array
  pad = floor(size(domain)/2);
  A = padarray(A, pad, padding);
  even = ( round(size(domain)/2) == size(domain)/2 );
  idx = cell(1, ndims(A));
  for k = 1:ndims(A)
    idx{k} = (even(k)+1):size(A,k);
  endfor
  A = A(idx{:});
  
  ## Perform the filtering
  retval = __spatial_filtering__ (A, domain, "ordered", S, nth);
endfunction
