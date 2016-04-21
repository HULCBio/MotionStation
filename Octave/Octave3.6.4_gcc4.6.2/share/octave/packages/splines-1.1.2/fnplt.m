## Copyright (C) 2000 Kai Habel
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
## @deftypefn {Function File} { } fnplt (@var{pp}, '@var{plt}')
## plots spline 
##
## @seealso{ppval, spline, csape}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 3. dec 2000
## 2001-02-19 Paul Kienzle
##   * use pp.x rather than just x in linspace; add plt parameter
##   * return points instead of plotting them if desired
##   * also plot control points
##   * added demo

function [x, y] = fnplt (pp, plt)

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif
  if (nargin < 2)
    plt = "r;;";
  endif
  xi = linspace(min(pp.x),max(pp.x),256)';
  pts = ppval(pp,xi);
  if nargout == 2
    x = xi;
    y = pts;
  elseif nargout == 1
    x = [xi, pts];
  else
    plot(xi,pts,plt,pp.x,ppval(pp,pp.x),"bx;;");
  endif

endfunction

%!demo
%! x = [ 0; sort(rand(25,1)); 1 ];
%! pp = csape (x, sin (2*pi*3*x), 'periodic');
%! axis([0,1,-2,2]); 
%! title('Periodic spline reconstruction of randomly sampled sine');
%! fnplt (pp,'r;reconstruction;'); 
%! t=linspace(0,1,100); y=sin(2*pi*3*t);
%! hold on; plot(t,y,'g;ideal;'); hold off;
%! axis; title("");
