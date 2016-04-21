## Copyright (C) 1994-2012 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} hist (@var{y})
## @deftypefnx {Function File} {} hist (@var{y}, @var{x})
## @deftypefnx {Function File} {} hist (@var{y}, @var{nbins})
## @deftypefnx {Function File} {} hist (@var{y}, @var{x}, @var{norm})
## @deftypefnx {Function File} {[@var{nn}, @var{xx}] =} hist (@dots{})
## @deftypefnx {Function File} {[@dots{}] =} hist (@dots{}, @var{prop}, @var{val})
##
## Produce histogram counts or plots.
##
## With one vector input argument, @var{y}, plot a histogram of the values
## with 10 bins.  The range of the histogram bins is determined by the
## range of the data.  With one matrix input argument, @var{y}, plot a
## histogram where each bin contains a bar per input column.
##
## Given a second vector argument, @var{x}, use that as the centers of
## the bins, with the width of the bins determined from the adjacent
## values in the vector.
##
## If scalar, the second argument, @var{nbins}, defines the number of bins.
##
## If a third argument is provided, the histogram is normalized such that
## the sum of the bars is equal to @var{norm}.
##
## Extreme values are lumped in the first and last bins.
##
## With two output arguments, produce the values @var{nn} and @var{xx} such
## that @code{bar (@var{xx}, @var{nn})} will plot the histogram.
##
## The histogram's appearance may be modified by specifying property/value
## pairs, @var{prop} and @var{val} pairs.  For example the face and edge
## color may be modified.
##
## @example
## @group
## hist (randn (1, 100), 25, "facecolor", "r", "edgecolor", "b");
## @end group
## @end example
##
## @noindent
## The histograms colors also depend upon the colormap.
##
## @example
## @group
## hist (rand (10, 3));
## colormap (summer ());
## @end group
## @end example
##
## @seealso{bar}
## @end deftypefn

## Author: jwe

function [nn, xx] = hist (y, varargin)

  if (nargin < 1)
    print_usage ();
  endif

  arg_is_vector = isvector (y);

  if (rows (y) == 1)
    y = y(:);
  endif

  if (isreal (y))
    max_val = max (y(:));
    min_val = min (y(:));
  else
    error ("hist: first argument must be real valued");
  endif

  iarg = 1;
  if (nargin == 1 || ischar (varargin{iarg}))
    n = 10;
    x = [0.5:n]'/n;
    x = x * (max_val - min_val) + ones(size(x)) * min_val;
  else
    ## nargin is either 2 or 3
    x = varargin{iarg++};
    if (isscalar (x))
      n = x;
      if (n <= 0)
        error ("hist: number of bins must be positive");
      endif
      x = [0.5:n]'/n;
      x = x * (max_val - min_val) + ones (size (x)) * min_val;
    elseif (isreal (x))
      if (isvector (x))
        x = x(:);
      endif
      tmp = sort (x);
      if (any (tmp != x))
        warning ("hist: bin values not sorted on input");
        x = tmp;
      endif
    else
      error ("hist: second argument must be a scalar or a vector");
    endif
  endif

  ## Avoid issues with integer types for x and y
  x = double (x);
  y = double (y);

  cutoff = (x(1:end-1,:) + x(2:end,:)) / 2;
  n = rows (x);
  y_nc = columns (y);
  if (n < 30 && columns (x) == 1)
    ## The following algorithm works fastest for n less than about 30.
    chist = zeros (n+1, y_nc);
    for i = 1:n-1
      chist(i+1,:) = sum (y <= cutoff(i));
    endfor
    chist(n+1,:) = sum (! isnan (y));
  else
    ## The following algorithm works fastest for n greater than about 30.
    ## Put cutoff elements between boundaries, integrate over all
    ## elements, keep totals at boundaries.
    [s, idx] = sort ([y; repmat(cutoff, 1, y_nc)]);
    len = rows (y);
    chist = cumsum (idx <= len);
    chist = [(zeros (1, y_nc));
             (reshape (chist(idx > len), rows (cutoff), y_nc));
             (chist(end,:) - sum (isnan (y)))];
  endif

  freq = diff (chist);

  if (nargin > 2 && ! ischar (varargin{iarg}))
    ## Normalise the histogram.
    norm = varargin{iarg++};
    freq = freq / rows (y) * norm;
  endif

  if (nargout > 0)
    if (arg_is_vector)
      nn = freq';
      xx = x';
    else
      nn = freq;
      xx = x;
    endif
  elseif (size (freq, 2) != 1)
    bar (x, freq, 0.8, varargin{iarg:end});
  else
    bar (x, freq, 1.0, varargin{iarg:end});
  endif

endfunction

%!test
%!  [nn,xx]=hist([1:4],3);
%!  assert(xx, [1.5,2.5,3.5]);
%!  assert(nn, [2,1,1]);
%!test
%!  [nn,xx]=hist([1:4]',3);
%!  assert(xx, [1.5,2.5,3.5]);
%!  assert(nn, [2,1,1]);
%!test
%!  [nn,xx]=hist([1 1 1 NaN NaN NaN 2 2 3],[1 2 3]);
%!  assert(xx, [1,2,3]);
%!  assert(nn, [3,2,1]);
%!test
%!  [nn,xx]=hist([[1:4]',[1:4]'],3);
%!  assert(xx, [1.5;2.5;3.5]);
%!  assert(nn, [[2,1,1]',[2,1,1]']);
%!assert(hist(1,1),1);
%!test
%!  for n = [10, 30, 100, 1000]
%!    assert(sum(hist([1:n], n)), n);
%!    assert(sum(hist([1:n], [2:n-1])), n);
%!    assert(sum(hist([1:n], [1:n])), n);
%!    assert(sum(hist([1:n], 29)), n);
%!    assert(sum(hist([1:n], 30)), n);
%!  endfor
%!test
%!  assert (size (hist(randn(750,240), 200)), [200,240]);
