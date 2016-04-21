## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## @deftypefn {Function File} {@var{h} = } shapeplot (@var{shape})
## @deftypefnx {Function File} {@var{h} = } shapeplot (@var{shape}, @var{N})
## @deftypefnx {Function File} {@var{h} = } shapeplot (@dots{}, @var{param}, @var{value})
## Pots a 2D shape defined by piecewise smooth polynomials in the current axis.
##
## @var{pp} is a cell where each elements is a 2-by-(poly_degree+1) matrix
## containing a pair of polynomials.
## @var{N} is the number of points to be used in non-straight edges.
## Additional parameter value pairs are passed to @code{drawPolygon}.
##
## @seealso{drawPolygon, shape2polygon}
## @end deftypefn

function h = shapeplot(shape, varargin)

  n = cell2mat(cellfun(@(x)curveval(x,rand(1,5)), shape, 'uniformoutput',false));
  dr = (max(n(:,1))-min(n(:,1)))*(max(n(:,2))-min(n(:,2)))/100;
  p = shape2polygon(shape,'tol', dr);
  h = drawPolygon(p,varargin{:});

endfunction
