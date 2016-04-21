## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

function shape = polygon2shape (polygon)

  # Filter colinear points
  polygon = simplifypolygon (polygon);
  
  np = size(polygon,1);
  # polygonal shapes are memory inefficient!!
  # TODO filter the regions where edge angles are canging slowly and fit
  # polynomial of degree 3;
  pp = nan (2*np,2);
  
  # Transform edges into polynomials of degree 1;
  # pp = [(p1-p0) p0];
  pp(:,1) = diff(polygon([1:end 1],:)).'(:);
  pp(:,2) = polygon.'(:);

  shape = mat2cell(pp, 2*ones (1,np), 2);
  
endfunction
