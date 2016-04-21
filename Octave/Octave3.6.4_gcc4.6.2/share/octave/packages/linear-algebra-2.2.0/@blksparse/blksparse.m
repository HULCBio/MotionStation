## Copyright (C) 2010 VZLU Prague
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{s} =} blksparse (@var{i}, @var{j}, @var{sv})
## @deftypefnx{Function File} {@var{s} =} blksparse (@var{i}, @var{j}, @var{sv}, @var{m}, @var{n})
## @deftypefnx{Function File} {@var{s} =} blksparse (@dots{}, @var{mode})
##
## Construct a block sparse matrix. The meaning of arguments is analogous to the
## built-in @code{sparse} function, except that @var{i}, @var{j} are indices of
## blocks rather than elements, and @var{sv} is a 3-dimensional array, the first two
## dimensions determining the block size. Optionally, @var{m} and @var{n} can be
## specified as the true block dimensions; if not, the maximum values of @var{i}, @var{j}
## are taken instead. The resulting sparse matrix has the size 
##
## @example
##   [@var{m}*@var{p}, @var{n}*@var{q}]
## @end example
##
## where 
##
## @example
##   @var{p} = size (@var{sv}, 1)
##   @var{q} = size (@var{sv}, 2)
## @end example
##
## The blocks are located so that
##
## @example 
## @var{s}(@var{i}(k):@var{i}(k)+@var{p}-1, @var{j}(k):@var{j}(K)+@var{q}-1) = @var{sv}(:,:,k)
## @end example
##
## Multiple blocks corresponding to the same pair of indices are summed, unless
## @var{mode} is "unique", in which case the last of them is used.
## @end deftypefn

function s = blksparse (i, j, sv, m = 0, n = 0, mode)
  persistent chkver = check_version ();
  if (nargin == 0)
    i = j = zeros (0, 1);
    sv = zeros (1, 1, 0);
    s = class (struct ("i", i, "j", j, "sv", sv, "siz", [0, 0], "bsiz", [1, 1]), "blksparse");
    return
  endif

  if (nargin < 3 || nargin > 6)
    print_usage ();
  endif

  if (! isvector (i) || ! isvector (j))
    error ("blksparse: i, j must be vectors");
  elseif (ndims (sv) != 3)
    error ("blksparse: sv must be a 3D array");
  endif

  if (nargin == 4 && ischar (m))
    mode = m;
    m = 0;
  elseif (nargin < 6)
    mode = "sum";
  endif

  if (strcmp (mode, "unique"))
    summation = false;
  elseif (strcmp (mode, "sum") || strcmp (mode, "summation"))
    summation = true;
  else
    error ("blksparse: invalid mode: %s", mode);
  endif

  if (m == 0)
    m = max (i);
  endif
  if (n == 0)
    n = max (j);
  endif

  siz = [m, n];
  ji = [j(:), i(:)];

  [ji, fidx, ridx] = unique (ji, "rows");
  j = ji(:,1);
  i = ji(:,2);

  if (summation)
    sv = accumdim (ridx, sv, 3, rows (ji));
  else
    sv = sv(:,:,fidx);
  endif

  s = struct ("i", i, "j", j, "sv", sv, "siz", siz, "bsiz", size (sv)(1:2));
  s = class (s, "blksparse");

endfunction

function ok = check_version ()
  ok = compare_versions (version, "3.3.51", ">=");
  if (! ok)
    error ("blksparse: can only be used with Octave 3.3.51+");
  endif
endfunction
