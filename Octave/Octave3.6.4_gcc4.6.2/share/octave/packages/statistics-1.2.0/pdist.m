## Copyright (C) 2008 Francesco Potort� <pot@gnu.org>
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
## @deftypefn {Function File} {@var{y} =} pdist (@var{x})
## @deftypefnx {Function File} {@var{y} =} pdist (@var{x}, @var{metric})
## @deftypefnx {Function File} {@var{y} =} pdist (@var{x}, @var{metric}, @var{metricarg}, @dots{})
##
## Return the distance between any two rows in @var{x}.
##
## @var{x} is the @var{n}x@var{d} matrix representing @var{q} row
## vectors of size @var{d}.
##
## The output is a dissimilarity matrix formatted as a row vector
## @var{y}, @math{(n-1)*n/2} long, where the distances are in
## the order [(1, 2) (1, 3) @dots{} (2, 3) @dots{} (n-1, n)].  You can
## use the @code{squareform} function to display the distances between
## the vectors arranged into an @var{n}x@var{n} matrix.
##
## @code{metric} is an optional argument specifying how the distance is
## computed. It can be any of the following ones, defaulting to
## "euclidean", or a user defined function that takes two arguments
## @var{x} and @var{y} plus any number of optional arguments,
## where @var{x} is a row vector and and @var{y} is a matrix having the
## same number of columns as @var{x}.  @code{metric} returns a column
## vector where row @var{i} is the distance between @var{x} and row
## @var{i} of @var{y}. Any additional arguments after the @code{metric}
## are passed as metric (@var{x}, @var{y}, @var{metricarg1},
## @var{metricarg2} @dots{}).
##
## Predefined distance functions are:
##
## @table @samp
## @item "euclidean"
## Euclidean distance (default).
##
## @item "seuclidean"
## Standardized Euclidean distance. Each coordinate in the sum of
## squares is inverse weighted by the sample variance of that
## coordinate.
##
## @item "mahalanobis"
## Mahalanobis distance: see the function mahalanobis.
##
## @item "cityblock"
## City Block metric, aka Manhattan distance.
##
## @item "minkowski"
## Minkowski metric.  Accepts a numeric parameter @var{p}: for @var{p}=1
## this is the same as the cityblock metric, with @var{p}=2 (default) it
## is equal to the euclidean metric.
##
## @item "cosine"
## One minus the cosine of the included angle between rows, seen as
## vectors.
##
## @item "correlation"
## One minus the sample correlation between points (treated as
## sequences of values).
##
## @item "spearman"
## One minus the sample Spearman's rank correlation between
## observations, treated as sequences of values.
##
## @item "hamming"
## Hamming distance: the quote of the number of coordinates that differ.
##
## @item "jaccard"
## One minus the Jaccard coefficient, the quote of nonzero
## coordinates that differ.
##
## @item "chebychev"
## Chebychev distance: the maximum coordinate difference.
## @end table 
## @seealso{linkage, mahalanobis, squareform}
## @end deftypefn

## Author: Francesco Potort�  <pot@gnu.org>

function y = pdist (x, metric, varargin)

  if (nargin < 1)
    print_usage ();
  elseif ((nargin > 1)
          && ! ischar (metric)
          && ! isa (metric, "function_handle"))
    error (["pdist: the distance function must be either a string or a "
            "function handle."]);
  endif

  if (nargin < 2)
    metric = "euclidean";
  endif

  if (! ismatrix (x) || isempty (x))
    error ("pdist: x must be a nonempty matrix");
  elseif (length (size (x)) > 2)
    error ("pdist: x must be 1 or 2 dimensional");
  endif

  y = [];
  if (rows(x) == 1)
    return;
  endif

  if (ischar (metric))
    order = nchoosek(1:rows(x),2);
    Xi = order(:,1);
    Yi = order(:,2);
    X = x';
    metric = lower (metric);
    switch (metric)
      case "euclidean"
        d = X(:,Xi) - X(:,Yi);
        if (str2num(version()(1:3)) > 3.1)
          y = norm (d, "cols");
        else
          y = sqrt (sumsq (d, 1));
        endif

      case "seuclidean"
        d = X(:,Xi) - X(:,Yi);
        weights = inv (diag (var (x, 0, 1)));
        y = sqrt (sum ((weights * d) .* d, 1));

      case "mahalanobis"
        d = X(:,Xi) - X(:,Yi);
        weights = inv (cov (x));
        y = sqrt (sum ((weights * d) .* d, 1));

      case "cityblock"
        d = X(:,Xi) - X(:,Yi);
        if (str2num(version()(1:3)) > 3.1)
          y = norm (d, 1, "cols");
        else
          y = sum (abs (d), 1);
        endif

      case "minkowski"
        d = X(:,Xi) - X(:,Yi);
        p = 2;                  # default
        if (nargin > 2)
          p = varargin{1};      # explicitly assigned
        endif;
        if (str2num(version()(1:3)) > 3.1)
          y = norm (d, p, "cols");
        else
          y = (sum ((abs (d)).^p, 1)).^(1/p);
        endif

      case "cosine"
        prod = X(:,Xi) .* X(:,Yi);
        weights = sumsq (X(:,Xi), 1) .* sumsq (X(:,Yi), 1);
        y = 1 - sum (prod, 1) ./ sqrt (weights);

      case "correlation"
        if (rows(X) == 1)
          error ("pdist: correlation distance between scalars not defined")
        endif
        corr = cor (X);
        y = 1 - corr (sub2ind (size (corr), Xi, Yi))';

      case "spearman"
        if (rows(X) == 1)
          error ("pdist: spearman distance between scalars not defined")
        endif
        corr = spearman (X);
        y = 1 - corr (sub2ind (size (corr), Xi, Yi))';

      case "hamming"
        d = logical (X(:,Xi) - X(:,Yi));
        y = sum (d, 1) / rows (X);

      case "jaccard"
        d = logical (X(:,Xi) - X(:,Yi));
        weights = X(:,Xi) | X(:,Yi);
        y = sum (d & weights, 1) ./ sum (weights, 1);

      case "chebychev"
        d = X(:,Xi) - X(:,Yi);
        if (str2num(version()(1:3)) > 3.1)
          y = norm (d, Inf, "cols");
        else
          y = max (abs (d), [], 1);
        endif

    endswitch
  endif

  if (isempty (y))
    ## Metric is a function handle or the name of an external function
    l = rows (x);
    y = zeros (1, nchoosek (l, 2));
    idx = 1;
    for ii = 1:l-1
      for jj = ii+1:l
        y(idx++) = feval (metric, x(ii,:), x, varargin{:})(jj);
      endfor
    endfor
  endif

endfunction

%!shared xy, t, eucl
%! xy = [0 1; 0 2; 7 6; 5 6];
%! t = 1e-3;
%! eucl = @(v,m) sqrt(sumsq(repmat(v,rows(m),1)-m,2));
%!assert(pdist(xy),              [1.000 8.602 7.071 8.062 6.403 2.000],t);
%!assert(pdist(xy,eucl),         [1.000 8.602 7.071 8.062 6.403 2.000],t);
%!assert(pdist(xy,"euclidean"),  [1.000 8.602 7.071 8.062 6.403 2.000],t);
%!assert(pdist(xy,"seuclidean"), [0.380 2.735 2.363 2.486 2.070 0.561],t);
%!assert(pdist(xy,"mahalanobis"),[1.384 1.967 2.446 2.384 1.535 2.045],t);
%!assert(pdist(xy,"cityblock"),  [1.000 12.00 10.00 11.00 9.000 2.000],t);
%!assert(pdist(xy,"minkowski"),  [1.000 8.602 7.071 8.062 6.403 2.000],t);
%!assert(pdist(xy,"minkowski",3),[1.000 7.763 6.299 7.410 5.738 2.000],t);
%!assert(pdist(xy,"cosine"),     [0.000 0.349 0.231 0.349 0.231 0.013],t);
%!assert(pdist(xy,"correlation"),[0.000 2.000 0.000 2.000 0.000 2.000],t);
%!assert(pdist(xy,"spearman"),   [0.000 2.000 0.000 2.000 0.000 2.000],t);
%!assert(pdist(xy,"hamming"),    [0.500 1.000 1.000 1.000 1.000 0.500],t);
%!assert(pdist(xy,"jaccard"),    [1.000 1.000 1.000 1.000 1.000 0.500],t);
%!assert(pdist(xy,"chebychev"),  [1.000 7.000 5.000 7.000 5.000 2.000],t);
