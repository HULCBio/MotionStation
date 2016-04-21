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
## @deftypefn {Function File} {[@var{num}, @var{rate}] = } symerr (@var{a},@var{b})
## @deftypefnx {Function File} {[@var{num}, @var{rate}] = } symerr (@var{...},@var{flag})
## @deftypefnx {Function File} {[@var{num}, @var{rate} @var{ind}] = } symerr (@var{...})
##
## Compares two matrices and returns the number of symbol errors and the 
## symbol error rate. The variables @var{a} and @var{b} can be either:
##
## @table @asis
## @item Both matrices
## In this case both matrices must be the same size and then by default the
## the return values @var{num} and @var{rate} are the overall number of symbol
## errors and the overall symbol error rate.
## @item One column vector
## In this case the column vector is used for symbol error comparision
## column-wise with the matrix. The returned values @var{num} and @var{rate}
## are then row vectors containing the num of symbol errors and the symbol
## error rate for each of the column-wise comparisons. The number of rows in 
## the matrix must be the same as the length of the column vector 
## @item One row vector
## In this case the row vector is used for symbol error comparision row-wise
## with the matrix. The returned values @var{num} and @var{rate} are then 
## column vectors containing the num of symbol errors and the symbol error rate
## for each of the row-wise comparisons. The number of columns in the matrix 
## must be the same as the length of the row vector 
## @end table
##
## This behaviour can be overridden with the variable @var{flag}. @var{flag}
## can take the value 'column-wise', 'row-wise' or 'overall'. A column-wise
## comparision is not possible with a row vector and visa-versa.
## @end deftypefn

## 2003 FEB 13
##   initial release

function [num, rate, ind] = symerr (a, b, _flag)

  if ((nargin < 2) || (nargin > 4))
    usage ("[num rate ind] = symerr (a, b [,flag])");
  endif
  if (any(any(isinf(a))) || any(any(isnan(a))) || any(any(isinf(b))) || ...
      any(any(isnan(b))) || !real(a) || !real(b) || ...
      any(any((floor(a)) != a)) || any(any((floor(b)) != b)) || ...
      any(any(a < 0)) || any(any(b < 0)))
    error ("symerr: a and b must contain only postive integers");
  endif
  
  [ar,ac] = size(a);
  [br,bc] = size(b);

  if ((ar == br) && (ac == bc))
    type = "matrix";
    flag = "overall";
    c = 1;
  elseif (any([ar,br] == 1))
    type = "row";
    flag = "row";
    if (ac != bc)
      error ("symerr: row-wise comparison must have the same number of columns in inputs");
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
      error ("symerr: column-wise comparison must have the same number of rows in inputs");
    endif
    if (ac == 1)
      a = a * ones(1,bc);
    else
      b = b * ones(1,ac);
    endif
  else
    error ("symerr: matrix sizes must match");
  endif

  if (nargin > 2)
    if (ischar(_flag))
      if (strcmp(_flag,"row-wise"))
	if (strcmp(type,"column"))
	  error ("symerr: row-wise comparison not possible with column inputs");
	endif
	flag = "row";
      elseif (strcmp(_flag,"column-wise"))
	if (strcmp(type,"row"))
	  error ("symerr: column-wise comparison not possible with row inputs");
	endif
	flag = "column";
      elseif (strcmp(_flag,"overall"))
	flag = "overall";
      else
	error ("symerr: unrecognized string argument");
      endif
    else
      error ("symerr: unrecognized argument");
    endif
  endif
  
  ## Call the core error function to count the bit errors 
  ind = (__errcore__(a,b) != 0);

  switch (flag)
    case 'row',
      if (strcmp(type,"matrix") && (ac == 1))
	num = ind;
      else
	num = sum(ind')';
      endif
      rate = num / max(ac,bc);
    case 'column',
      if (strcmp(type,"matrix") && (ar == 1))
	num = ind;
      else
	num = sum(ind);
      endif
      rate = num / max(ar,br);
    case 'overall',
      num = sum(sum(ind));
      rate = num / max(ar,br) / max(ac,bc);
    otherwise
      error("impossible");
  endswitch

endfunction
