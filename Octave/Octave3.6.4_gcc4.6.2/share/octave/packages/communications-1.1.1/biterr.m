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
## @deftypefn {Function File} {[@var{num}, @var{rate}] = } biterr (@var{a},@var{b})
## @deftypefnx {Function File} {[@var{num}, @var{rate}] = } biterr (@var{...},@var{k})
## @deftypefnx {Function File} {[@var{num}, @var{rate}] = } biterr (@var{...},@var{flag})
## @deftypefnx {Function File} {[@var{num}, @var{rate} @var{ind}] = } biterr (@var{...})
##
## Compares two matrices and returns the number of bit errors and the bit 
## error rate. The binary representations of the variables @var{a} and 
## @var{b} are treated and @var{a} and @var{b} can be either:
##
## @table @asis
## @item Both matrices
## In this case both matrices must be the same size and then by default the
## the return values @var{num} and @var{rate} are the overall number of bit
## errors and the overall bit error rate.
## @item One column vector
## In this case the column vector is used for bit error comparision column-wise
## with the matrix. The returned values @var{num} and @var{rate} are then 
## row vectors containing the num of bit errors and the bit error rate for
## each of the column-wise comparisons. The number of rows in the matrix 
## must be the same as the length of the column vector 
## @item One row vector
## In this case the row vector is used for bit error comparision row-wise
## with the matrix. The returned values @var{num} and @var{rate} are then 
## column vectors containing the num of bit errors and the bit error rate for
## each of the row-wise comparisons. The number of columns in the matrix 
## must be the same as the length of the row vector 
## @end table
##
## This behaviour can be overridden with the variable @var{flag}. @var{flag}
## can take the value 'column-wise', 'row-wise' or 'overall'. A column-wise
## comparision is not possible with a row vector and visa-versa.
##
## By default the number of bits in each symbol is assumed to be give by the
## number required to represent the maximum value of @var{a} and @var{b}.
## The number of bits to represent a symbol can be overridden by the variable
## @var{k}.
## @end deftypefn

## 2003 FEB 13
##   initial release

function [num, rate, ind] = biterr (a, b, varargin)

  if ((nargin < 2) || (nargin > 4))
    usage ("[num rate ind] = biterr (a, b [,k [,flag]])");
  endif
  
  if (ndims (a) > 2 || ndims (b) > 2)
    error ("biterr: a and b must have at most two dimensions");
  endif
  
  if (any(any(isinf(a))) || any(any(isnan(a))) || any(any(isinf(b))) || ...
      any(any(isnan(b))) || !isreal(a) || !isreal(b) || ...
      any(any((floor(a)) != a)) || any(any((floor(b)) != b)) || ...
      any(any(a < 0)) || any(any(b < 0)))
    error ("biterr: a and b must contain only non-negative integers");
  endif
  
  [ar,ac] = size(a);
  [br,bc] = size(b);
  
  k = max([max(a(:)),max(b(:))]);
  m = 1;
  while (k > (2^m-1))
    m = m + 1;
  end

  if ((ar == br) && (ac == bc))
    type = "matrix";
    flag = "overall";
    c = 1;
  elseif (any([ar,br] == 1))
    type = "row";
    flag = "row";
    if (ac != bc)
      error ("biterr: row-wise comparison must have the same number of columns in inputs");
    endif
    if (ar == 1)
      a = ones(br,1) * a;
    else
      b = ones(ar,1) * b;
    endif
  elseif (any([ac,bc] == 1))
    type = "column";
    flag = "column";
    if (ar != br)
      error ("biterr: column-wise comparison must have the same number of rows in inputs");
    endif
    if (ac == 1)
      a = a * ones(1,bc);
    else
      b = b * ones(1,ac);
    endif
  else
    error ("biterr: matrix sizes must match");
  endif

  k = 0;
  for i =1:length(varargin)
    arg = varargin{i};
    if (ischar(arg))
      if (strcmp(arg,"row-wise"))
	      if (strcmp(type,"column"))
	        error ("biterr: row-wise comparison not possible with column inputs");
	      endif
	      flag = "row";
      elseif (strcmp(arg,"column-wise"))
	      if (strcmp(type,"row"))
	        error ("biterr: column-wise comparison not possible with row inputs");
	      endif
	      flag = "column";
      elseif (strcmp(arg,"overall"))
	      flag = "overall";
      else
	      error ("biterr: unrecognized string argument");
      endif
    else
      k = arg;
      if (k < m)
	      error ("biterr: the symbol size is too small for largest element");
      endif
    endif
  end
  
  if (k == 0)
    k = m;
  endif
  
  ## Call the core error function to count the bit errors 
  ind = __errcore__(a,b);

  switch (flag)
    case 'row',
      if (strcmp(type,"matrix") && (ac == 1))
	      num = ind;
      else
        num = sum(ind')';
      endif
      rate = num / k / max(ac,bc);
    case 'column',
      if (strcmp(type,"matrix") && (ar == 1))
	      num = ind;
      else
	      num = sum(ind);
      endif
      rate = num / k / max(ar,br);
    case 'overall',
      num = sum(sum(ind));
      rate = num / k / max(ar,br) / max(ac,bc);
    otherwise
      error("impossible");
  endswitch

endfunction
