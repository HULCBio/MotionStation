## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {@var{h} = } hammgen (@var{m})
## @deftypefnx {Function File} {@var{h} = } hammgen (@var{m},@var{p})
## @deftypefnx {Function File} {[@var{h},@var{g}] = } hammgen (@var{...})
## @deftypefnx {Function File} {[@var{h},@var{g},@var{n},@var{k}] = } hammgen (@var{...})
##
## Produce the parity check and generator matrices of a Hamming code. The
## variable @var{m} defines the [@var{n},@var{k}] Hamming code where 
## @code{@var{n} = 2 ^ @var{m} - 1} and @code{@var{k} = @var{n} - @var{m}}.
## @var{m} must be between 3 and 16.
##
## The parity check matrix is generated relative to the primitive polynomial
## of GF(2^@var{m}). If @var{p} is specified the default primitive polynomial
## of GF(2^@var{m}) is overridden. @var{p} must be a valid primitive 
## polynomial of the correct order for GF(2^@var{m}).
##
## The parity check matrix is returned in the @var{m} by @var{n} matrix 
## @var{h}, and if requested the generator matrix is returned in the @var{k}
## by @var{n} matrix @var{g}.
##
## @end deftypefn
## @seealso{gen2par}

function [h, g, n, k] = hammgen(m, p)

  if ((nargin < 1) || (nargin > 2))
    usage ("[h [, g [, n, k]]] = hammgen (m [, p])");
  endif

  if (!isscalar(m) || (floor(m) != m) || (m < 3) || (m > 16))
    error ("hammgen: m must be an integer between 3 and 16");
  endif

  if (nargin > 1)
    if (!isscalar(p))
      p = bi2de(p);
    endif
    if ((floor(p) != p) || (p < 2^m) || (p > 2^(m+1)) || !isprimitive(p))
      error ("hammgen: p must be a primitive polynomial of GF(2^m)");
    endif
  else
    ## Get the primitive polynomial of GF(2^M). Note that the default
    ## primitive polynomial is not necessarily primpoly(m,"min"), so
    ## have to create a Galois variable to extract the default primitive.
    ## The problem is, this limits m to be less than or equal to 16,
    ## as the Galois type itself is limited to this value
    p = gf(0,m).prim_poly;
  endif

  n = 2^m -1;
  k = n - m;
  if (nargout > 1)
    [h, g] = cyclgen(n, p);
  else
    h = cyclgen(n,p);
  endif
  
endfunction
