## Copyright (C) 2006 Francesco Potortì <potorti@isti.cnr.it>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software Foundation,
## Inc., 51 Franklin Street, 5th Floor, Boston, MA 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} plotdecimate (@var{P})
## @deftypefnx {Function File} {} plotdecimate (@var{P}, @var{so})
## @deftypefnx {Function File} {} plotdecimate (@var{P}, @var{so}, @var{res})
## Optimise plot data by removing redundant points and segments
##
## The first parameter @var{P} is a two-column matrix to be plotted as X and
## Y coordinates.   The second optional argument @var{so} disables segment
## optimisation when set to @var{false} (default is @var{true}). The third
## optional argument @var{res} is the size of the largest error on the plot:
## if it is a scalar, it is meant relative to the range of X and Y values
## (default 1e-3); if it is a 2x1 array, it contains the absolute errors for
## X and Y.  Returns a two-column matrix containing a subset of the rows of
## @var{P}. A line plot of @var{P} has the same appearance as a line plot of
## the output, with errors smaller than @var{res}.  When creating point
## plots, set @var{so} to @var{false}.
## @end deftypefn

function C = plotdecimate (P, so, res)

  if (!ismatrix(P) || columns(P) != 2)
    error("P must be a matrix with two columns");
  endif
  if (nargin < 2)
    so = true;                  # do segment optimisation
  endif
  if (nargin < 3)
    res = 1e-3;                 # default resolution is 1000 dots/axis
  endif

  ## Slack: admissible error on coordinates on the output plot
  if (isscalar(res))
    if (res <= 0)
      error("res must be positive");
    endif
    E = range(P)' * res;        # build error vector using range of data
  elseif (ismatrix(res))
    if (!all(size(res) == [2 1]) || any(res <= 0))
      error("res must be a 2x1 matrix with positive values");
    endif
    E = res;                    # take error vector as it is
  else
    error("res should be a scalar or matrix");
  endif

  if (rows(P) < 3)
    C = P;
    return;                     # nothing to do
  endif
  P ./= repmat(E',rows(P),1);   # normalize P
  rot = [0,-1;1,0];             # rotate a vector pi/4 anticlockwise

  ## Iteratively remove points too near to the previous point
  while (1)
    V = [true; sumsq(diff(P),2) > 1]; # points far from the previous ones
    if (all(V)) break; endif
    V = [true; diff(V) >= 0];   # identify the sequence leaders
    P = P(V,:);                 # remove them
  endwhile

  ## Remove points laying near to a segment: for each segment R->S, build a
  ## unitary-lenght projection vector D perpendicular to R->S, and project
  ## R->T over D to compute the distance ot T from R->S.
  if (so)                       # segment optimisation
    ## For each segment, r and s are its extremes
    r = 1; R = P(1,:)';         # start of segment
    s = 2; S = P(2,:)';         # end of the segment
    rebuild = true;             # build first projection vector

    for t = 3:rows(P)
      if (rebuild)              # build projection vector
        D = rot*(S-R)/sqrt(sumsq(S-R)); # projection vector for distance
        rebuild = false;        # keep current projection vector
      endif

      T = P(t,:)';              # next point

      if (abs(sum((T-R).*D)) < 1 # T is aligned
          && sum((T-R).*(S-R)) > 0) # going forward
        V(s) = false;           # do not plot s
      else                      # set a new segment
        r = s; R = S;           # new start of segment
        rebuild = true;         # rebuild projection vector
      endif
      s = t; S = T;             # new end of segment
    endfor
  endif

  C = P(V,:) .* repmat(E',sum(V),1); # denormalize P
endfunction

%!test
%! x = [ 0 1 2 3 4 8 8 8 8 8 9 ]';
%! y = [ 0 1 1 1 1 1 1 2 3 4 5 ]';
%!
%! x1 = [0 1 8 8 9]';
%! y1 = [0 1 1 4 5]';
%!   # optimised for segment plot
%!
%! x2 = [ 0 1 2 3 4 8 8 8 8 9 ]';
%! y2 = [ 0 1 1 1 1 1 2 3 4 5 ]';
%!   # double points removed
%!
%! P = [x,y];
%!   # Original
%! P1 = [x1, y1];
%!   # optimised segments
%! P2 = [x2, y2];
%!   # double points removed
%!
%! assert(plotdecimate(P), P1);
%! assert(plotdecimate(P, false), P2);
