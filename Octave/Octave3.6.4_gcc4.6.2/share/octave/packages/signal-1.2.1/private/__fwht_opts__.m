## Copyright (C) 2013 Mike Miller <mtmiller@ieee.org>
##
## This program is free software: you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation, either version 3 of the License, or (at your option) any later
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
## @deftypefn {Function File} {[@var{y}, @var{len}] =} __fwht_opts__ (@var{caller}, @var{x}, @var{n}, @var{order})
## Undocumented internal function.
## @end deftypefn

## Author: Mike Miller

function [y, len] = __fwht_opts__ (caller, x, n, order)

  if (nargin < 1)
    print_usage ();
  elseif (nargin != 4)
    print_usage (caller);
  endif

  [nr, nc] = size (x);
  
  if (isempty (n))
    if (nr == 1)
      n = 2^nextpow2 (nc);
    else
      n = 2^nextpow2 (nr);
    endif
  elseif (!(isscalar (n) && n == fix (n) && n > 0))
    error ("%s: N must be a positive scalar", caller);
  else
    f = log2(n);
    if (f != fix (f))
      error ("%s: N must be a power of 2", caller);
    endif
  endif

  if (isempty (order))
    order = "sequency";
  endif
  if (!(strncmp (order, "dyadic", 6) ||
        strncmp (order, "hadamard", 8) ||
        strncmp (order, "sequency", 8)))
    error ("%s: invalid order option", caller);
  endif

  if (nr == 1)
    nc = n;
    x = x(:);
  else
    nr = n;
  endif

  ## Zero-based index for normal Hadamard ordering
  idx = 0:n-1;

  ## Gray code permutation of index for alternate orderings
  idx_bin = dec2bin (idx) - "0";
  idx_bin_a = idx_bin(:,1:end-1);
  idx_bin_b = idx_bin(:,2:end);
  idx_bin(:,2:end) = mod (idx_bin_a + idx_bin_b, 2);
  idx_bin = char (idx_bin + "0");

  if (strncmp (order, "dyadic", 6))
    idx = bin2dec (idx_bin) + 1;
  elseif (strncmp (order, "sequency", 8))
    idx = bin2dec (fliplr (idx_bin)) + 1;
  else
    idx += 1;
  endif

  len = n;
  x = postpad (x, len);

  if (len < 2)
    y = x;
  else
    y = __fwht__ (x);
  endif

  y = reshape (y(idx,:), nr, nc);

endfunction
