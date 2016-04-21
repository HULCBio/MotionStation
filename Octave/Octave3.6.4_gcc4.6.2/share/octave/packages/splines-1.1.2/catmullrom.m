## Copyright (C) 2008 Carlo de Falco <carlo.defalco@gmail.com>
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
##  @deftypefn {Function File} {@var{pp}} = catmullrom( @var{x},@
##  @var{f}, @var{v}) 
##
## Returns the piecewise polynomial form of the Catmull-Rom cubic
## spline interpolating @var{f} at the points @var{x}.
## If the input @var{v} is supplied it will be interpreted as the
## values of the tangents at the extremals, if it is
## missing, the values will be computed from the data via one-sided
## finite difference formulas. See the wikipedia page for "Cubic
## Hermite spline" for a description of the algorithm.
##
##  @seealso{ppval}
##  @end deftypefn

function pp = catmullrom(x,f,v)

  if ( nargin < 2 )
    print_usage();
  endif

  h00 = [2 -3 0 1];
  h10 = [1 -2 1 0];
  h01 = [-2 3 0 0];
  h11 = [1 -1 0 0];
  
  h  = diff(x(:)');
  p0 = f(:)'(1:end-1);
  p1 = f(:)'(2:end);
     
  if (nargin < 3)
    v(1) = (p1(1)-p0(1))./h(1);
    v(2) = (p1(end)-p0(end))./h(end);
  endif
  m  = (p1(2:end)-p0(1:end-1))./(h(2:end)+h(1:end-1));
  m0 = [v(1) m];
  m1 = [m v(2)];
    
  for ii = 1:4
    coeff(:,ii) =  ((h00(ii)*p0 + h10(ii)*h.*m0 +...
                     h01(ii)*p1 + h11(ii)*h.*m1 )./h.^(4-ii))' ;
  end

  pp = mkpp (x, coeff);
  
endfunction
