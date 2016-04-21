## Copyright (C) 2001 Paul Kienzle
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
## @deftypefn {Function File} {@var{qidx} = } quantiz (@var{x}, @var{table})
## @deftypefnx {Function File} {[@var{qidx}, @var{q}] = } quantiz (@var{x}, @var{table}, @var{codes})
## @deftypefnx {Function File} {[ @var{qidx}, @var{q}, @var{d}] = } quantiz (@var{...})
##
## Quantization of an arbitrary signal relative to a paritioning.
##
## @table @code
## @item qidx = quantiz(x, table)
##   Determine position of x in strictly monotonic table.  The first
##   interval, using index 0, corresponds to x <= table(1).
##   Subsequent intervals are table(i-1) < x <= table(i).
##
## @item [qidx, q] = quantiz(x, table, codes)
##   Associate each interval of the table with a code.  Use codes(1) 
##   for x <= table(1) and codes(n+1) for table(n) < x <= table(n+1).
##
## @item [qidx, q, d] = quantiz(...)
##   Compute distortion as mean squared distance of x from the
##   corresponding quantization values.
## @end table
## @end deftypefn

function [qidx, q, d] = quantiz (x, table, codes)
  if (nargin < 2 || nargin > 3)
    usage("[qidx, q, d] = quantiz(x, table, codes)");
  endif

  qidx = length(table) - lookup(flipud(table(:)), x(:));
  if (nargin > 2 && nargout > 1)
    q = codes(qidx + 1);
  endif
  if (nargout > 2)
    table = [table(1) ; table(:) ];
    d = sumsq (x(:) - q(:)) / length(x);
  endif
endfunction
