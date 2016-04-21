## Copyright (C) 2000, 2001 Kai Habel
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
## @deftypefn {Function File} {@var{pp} = } csape (@var{x}, @var{y}, @var{cond}, @var{valc})
## cubic spline interpolation with various end conditions.
## creates the pp-form of the cubic spline.
##
## the following end conditions as given in @var{cond} are possible. 
## @table @asis
## @item 'complete'    
##    match slopes at first and last point as given in @var{valc}
## @item 'not-a-knot'     
##    third derivatives are continuous at the second and second last point
## @item 'periodic' 
##    match first and second derivative of first and last point
## @item 'second'
##    match second derivative at first and last point as given in @var{valc}
## @item 'variational'
##    set second derivative at first and last point to zero (natural cubic spline)
## @end table
##
## @seealso{ppval, spline}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 23. nov 2000
## Algorithms taken from G. Engeln-Muellges, F. Uhlig:
## "Numerical Algorithms with C", Springer, 1996

## Paul Kienzle, 19. feb 2001,  csape supports now matrix y value
## Nir Krakauer, 21 Nov 2012, fixed a bug with periodic boundary conditions and matrix y (noticed by Ted Rippert); added more tests to verify it won't happen again

function pp = csape (x, y, cond, valc)

  x = x(:);
  n = length(x);
  if (n < 3) 
    error("csape requires at least 3 points"); 
  endif

  ## Check the size and shape of y
  ndy = ndims (y);
  szy = size (y);
  if (ndy == 2 && (szy(1) == n || szy(2) == n))
    if (szy(2) == n)
      a = y.';
    else
      a = y;
      szy = fliplr (szy);
    endif
  else
    a = shiftdim (reshape (y, [prod(szy(1:end-1)), szy(end)]), 1);
  endif


  b = c = zeros (size (a));
  h = diff (x);
  idx = ones (columns(a),1);

  if (nargin < 3 || strcmp(cond,"complete"))
    # specified first derivative at end point
    if (nargin < 4)
      valc = [0, 0];
    endif

    if (n == 3)
      dg = 1.5 * h(1) - 0.5 * h(2);
      c(2:n - 1,:) = 1/dg(1);
    else
      dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
      dg(1) = dg(1) - 0.5 * h(1);
      dg(n - 2) = dg(n-2) - 0.5 * h(n - 1);

      e = h(2:n - 2);

      g = 3 * diff (a(2:n,:)) ./ h(2:n - 1,idx)\
        - 3 * diff (a(1:n - 1,:)) ./ h(1:n - 2,idx);
      g(1,:) = 3 * (a(3,:) - a(2,:)) / h(2) \
          - 3 / 2 * (3 * (a(2,:) - a(1,:)) / h(1) - valc(1));
      g(n - 2,:) = 3 / 2 * (3 * (a(n,:) - a(n - 1,:)) / h(n - 1) - valc(2))\
          - 3 * (a(n - 1,:) - a(n - 2,:)) / h(n - 2);

      c(2:n - 1,:) = spdiags([[e(:);0],dg,[0;e(:)]],[-1,0,1],n-2,n-2) \ g;

    end

    c(1,:) = (3 / h(1) * (a(2,:) - a(1,:)) - 3 * valc(1) 
              - c(2,:) * h(1)) / (2 * h(1)); 
    c(n,:) = - (3 / h(n - 1) * (a(n,:) - a(n - 1,:)) - 3 * valc(2) 

                + c(n - 1,:) * h(n - 1)) / (2 * h(n - 1));
    b(1:n - 1,:) = diff (a) ./ h(1:n - 1, idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));

  elseif (strcmp(cond,"variational") || strcmp(cond,"second"))

    if ((nargin < 4) || strcmp(cond,"variational"))
      ## set second derivatives at end points to zero
      valc = [0, 0];
    endif

    c(1,:) = valc(1) / 2;
    c(n,:) = valc(2) / 2;

    g = 3 * diff (a(2:n,:)) ./ h(2:n - 1, idx)\
      - 3 * diff (a(1:n - 1,:)) ./ h(1:n - 2, idx);

    g(1,:) = g(1,:) - h(1) * c(1,:);
    g(n - 2,:) = g(n-2,:) - h(n - 1) * c(n,:);

    if( n == 3)
      dg = 2 * h(1);
      c(2:n - 1,:) = g / dg;
    else
      dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
      e = h(2:n - 2);
      c(2:n - 1,:) = spdiags([[e(:);0],dg,[0;e(:)]],[-1,0,1],n-2,n-2) \ g;
    end
        
    b(1:n - 1,:) = diff (a) ./ h(1:n - 1,idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));
  
  elseif (strcmp(cond,"periodic"))

    h = [h; h(1)];

    ## XXX FIXME XXX --- the following gives a smoother periodic transition:
    ##    a(n,:) = a(1,:) = ( a(n,:) + a(1,:) ) / 2;
    a(n,:) = a(1,:);

    tmp = diff (shift ([a; a(2,:)], -1));
    g = 3 * tmp(1:n - 1,:) ./ h(2:n,idx)\
      - 3 * diff (a) ./ h(1:n - 1,idx);

    if (n > 3)
      dg = 2 * (h(1:n - 1) .+ h(2:n));
      e = h(2:n - 1);

      ## Use Sherman-Morrison formula to extend the solution
      ## to the cyclic system. See Numerical Recipes in C, pp 73-75
      gamma = - dg(1);
      dg(1) -=  gamma;
      dg(end) -= h(1) * h(1) / gamma; 
      z = spdiags([[e(:);0],dg,[0;e(:)]],[-1,0,1],n-1,n-1) \ ...
          [[gamma; zeros(n-3,1); h(1)],g];
      fact = (z(1,2:end) + h(1) * z(end,2:end) / gamma) / ...
          (1.0 + z(1,1) + h(1) * z(end,1) / gamma);

      c(2:n,:) = z(:,2:end) - z(:,1) * fact;
    endif

    c(1,:) = c(n,:);
    b = diff (a) ./ h(1:n - 1,idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    b(n,:) = b(1,:);
    d = diff (c) ./ (3 * h(1:n - 1, idx));
    d(n,:) = d(1,:);

  elseif (strcmp(cond,"not-a-knot"))

    g = zeros(n - 2,columns(a));
    g(1,:) = 3 / (h(1) + h(2)) * (a(3,:) - a(2,:)\
          - h(2) / h(1) * (a(2,:) - a(1,:)));
    g(n - 2,:) = 3 / (h(n - 1) + h(n - 2)) *\
        (h(n - 2) / h(n - 1) * (a(n,:) - a(n - 1,:)) -\
         (a(n - 1,:) - a(n - 2,:)));

    if (n > 4)

      g(2:n - 3,:) = 3 * diff (a(3:n - 1,:)) ./ h(3:n - 2,idx)\
        - 3 * diff (a(2:n - 2,:)) ./ h(2:n - 3,idx);

      dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
      dg(1) = dg(1) - h(1);
      dg(n - 2) = dg(n-2) - h(n - 1);

      ldg = udg = h(2:n - 2);
      udg(1) = udg(1) - h(1);
      ldg(n - 3) = ldg(n-3) - h(n - 1);
      c(2:n - 1,:) = spdiags([[ldg(:);0],dg,[0;udg(:)]],[-1,0,1],n-2,n-2) \ g;

    elseif (n == 4)

      dg = [h(1) + 2 * h(2), 2 * h(2) + h(3)];
      ldg = h(2) - h(3);
      udg = h(2) - h(1);
      c(2:n - 1,:) = spdiags([[ldg(:);0],dg,[0;udg(:)]],[-1,0,1],n-2,n-2) \ g;
      
    else # n == 3
            
      dg= [h(1) + 2 * h(2)];
      c(2:n - 1,:) = g/dg(1);

    endif

    c(1,:) = c(2,:) + h(1) / h(2) * (c(2,:) - c(3,:));
    c(n,:) = c(n - 1,:) + h(n - 1) / h(n - 2) * (c(n - 1,:) - c(n - 2,:));
    b = diff (a) ./ h(1:n - 1, idx)\
      - h(1:n - 1, idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));

  else
    msg = sprintf("unknown end condition: %s",cond);
    error (msg);
  endif

  d = d(1:n-1,:); c=c(1:n-1,:); b=b(1:n-1,:); a=a(1:n-1,:);
  pp = mkpp (x, cat (2, d'(:), c'(:), b'(:), a'(:)), szy(1:end-1));

endfunction


%!shared x,x2,y,cond
%! x = linspace(0,2*pi,5); y = sin(x); x2 = linspace(0,2*pi,16);

%!assert (ppval(csape(x,y),x), y, 10*eps);
%!assert (ppval(csape(x,y),x'), y', 10*eps);
%!assert (ppval(csape(x',y'),x'), y', 10*eps);
%!assert (ppval(csape(x',y'),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y]),x), \
%!        [ppval(csape(x,y),x);ppval(csape(x,y),x)], 10*eps)
%!assert (ppval(csape(x,[y;y]),x2), \
%!        [ppval(csape(x,y),x2);ppval(csape(x,y),x2)], 10*eps)

%!test cond='complete';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y],cond),x), \
%!        [ppval(csape(x,y,cond),x);ppval(csape(x,y,cond),x)], 10*eps)
%!assert (ppval(csape(x,[y;y],cond),x2), \
%!        [ppval(csape(x,y,cond),x2);ppval(csape(x,y,cond),x2)], 10*eps)

%!test cond='variational';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y],cond),x), \
%!        [ppval(csape(x,y,cond),x);ppval(csape(x,y,cond),x)], 10*eps)
%!assert (ppval(csape(x,[y;y],cond),x2), \
%!        [ppval(csape(x,y,cond),x2);ppval(csape(x,y,cond),x2)], 10*eps)

%!test cond='second';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y],cond),x), \
%!        [ppval(csape(x,y,cond),x);ppval(csape(x,y,cond),x)], 10*eps)
%!assert (ppval(csape(x,[y;y],cond),x2), \
%!        [ppval(csape(x,y,cond),x2);ppval(csape(x,y,cond),x2)], 10*eps)

%!test cond='periodic';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y],cond),x), \
%!        [ppval(csape(x,y,cond),x);ppval(csape(x,y,cond),x)], 10*eps)
%!assert (ppval(csape(x,[y;y],cond),x2), \
%!        [ppval(csape(x,y,cond),x2);ppval(csape(x,y,cond),x2)], 10*eps)

%!test cond='not-a-knot';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y;y],cond),x), \
%!        [ppval(csape(x,y,cond),x);ppval(csape(x,y,cond),x)], 10*eps)
%!assert (ppval(csape(x,[y;y],cond),x2), \
%!        [ppval(csape(x,y,cond),x2);ppval(csape(x,y,cond),x2)], 10*eps)
