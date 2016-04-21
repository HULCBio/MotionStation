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
## @deftypefn {Function File} {@var{g} = } rsgenpoly (@var{n},@var{k})
## @deftypefnx {Function File} {@var{g} = } rsgenpoly (@var{n},@var{k},@var{p})
## @deftypefnx {Function File} {@var{g} = } rsgenpoly (@var{n},@var{k},@var{p},@var{b},@var{s})
## @deftypefnx {Function File} {@var{g} = } rsgenpoly (@var{n},@var{k},@var{p},@var{b})
## @deftypefnx {Function File} {[@var{g}, @var{t}] = } rsgenpoly (@var{...})
##
## Creates a generator polynomial for a Reed-Solomon coding with message
## length of @var{k} and codelength of @var{n}. @var{n} must be greater
## than @var{k} and their difference must be even. The generator polynomial
## is returned on @var{g} as a polynomial over the Galois Field GF(2^@var{m})
## where @var{n} is equal to @code{2^@var{m}-1}. If @var{m} is not integer
## the next highest integer value is used and a generator for a shorten
## Reed-Solomon code is returned.
##
## The elements of @var{g} represent the coefficients of the polynomial in 
## descending order. If the length of @var{g} is lg, then the generator
## polynomial is given by
## @iftex
## @tex
## $$
## g_0 x^{lg-1} + g_1 x^{lg-2} + \cdots + g_{lg-1} x + g_lg.
## $$
## @end tex
## @end iftex
## @ifinfo
##
## @example
## @var{g}(0) * x^(lg-1) + @var{g}(1) * x^(lg-2) + ... + @var{g}(lg-1) * x + @var{g}(lg).
## @end example
## @end ifinfo
## 
## If @var{p} is defined then it is used as the primitive polynomial of the
## the Galois Field GF(2^@var{m}). The default primitive polynomial will
## be used if @var{p} is equal to [].
##
## The variables @var{b} and @var{s} determine the form of the generator 
## polynomial in the following manner.
## @iftex
## @tex
## $$
## g = (x - A^{bs}) (x - A^{(b+1)s})  \cdots (x - A ^{(b+2t-1)s}).
## $$
## @end tex
## @end iftex
## @ifinfo
##
## @example
## @var{g} = (@var{x} - A^(@var{b}*@var{s})) * (@var{x} - A^((@var{b}+1)*@var{s})) * ... * (@var{x} - A^((@var{b}+2*@var{t}-1)*@var{s})).
## @end example
## @end ifinfo
##
## where @var{t} is @code{(@var{n}-@var{k})/2}, and A is the primitive element 
## of the Galois Field. Therefore @var{b} is the first consecutive root of the
## generator polynomial and @var{s} is the primitive element to generate the
## the polynomial roots.
##
## If requested the variable @var{t}, which gives the error correction
## capability of the the Reed-Solomon code
## @end deftypefn
## @seealso{gf,rsenc,rsdec}

function [g, t] = rsgenpoly(n, k, _prim, _b, _s)

  if ((nargin < 2) || (nargin > 5))
    error ("usage: [g, t] = rsgenpoly(n, k, p, b, s)");
  endif

  if (!isscalar(n) || (n < 3) || ((n - floor(n)) != 0))
    error ("rsgenpoly: invalid codeword length");
  endif

  if (!isscalar(k) || (k < 1) || ((k- floor(k)) != 0))
    error ("rsgenpoly: invalid message length");
  endif

  if (((n-k)/2 - floor((n-k)/2)) != 0)
    error ("rsgenpoly: difference of codeword and message lengths must be even");
  endif

  m = ceil(log2(n+1));
  ## Adjust n and k if n not equal to 2^m-1
  dif = 2^m - 1 - n;
  n = n + dif;
  k = k + dif;
    
  prim = 0;
  if (nargin > 2)
    if (isempty(_prim))
      prim = 0;
    else
      prim = _prim;
    endif      
  endif

  if (!isscalar(prim) || (prim<0) || ((prim - floor(prim)) != 0))
    error ("rsgenpoly: primitive polynomial must use integer representation");
  endif

  if (prim != 0)
    if (!isprimitive(prim))
      error ("rsgenpoly: polynomial is not primitive");
    endif

    if ((prim < 2^m) || (prim > 2^(m+1)))
      error ("rsgenpoly: invalid order of the primitive polynomial");
    endif   
  endif   
  
  b = 1;
  if (nargin > 3)
    b = _b;
  endif

  if (!isscalar(b) || (b < 0) || ((b - floor(b)) != 0))
    error ("rsgenpoly: invalid value of b");
  endif

  s = 1;
  if (nargin > 4)
    s = _s;
  endif
  
  if (!isscalar(s) || (s < 0) || ((s - floor(s)) != 0))
    error ("rsgenpoly: invalid value of s");
  endif

  alph = gf(2, m, prim);
  t = (n - k) / 2;
  
  g = gf(1, m, prim);
  for i= 1:2*t
    g = conv(g, gf([1,alph^((b+i-1)*s)], m, prim));
  end
  
endfunction
