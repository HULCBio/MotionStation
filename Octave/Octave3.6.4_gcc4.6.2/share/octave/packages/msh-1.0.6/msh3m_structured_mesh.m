## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     MSH - Meshing Software Package for Octave
##
##  MSH is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  MSH is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with MSH; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{mesh}]} = @
## msh3m_structured_mesh(@var{x},@var{y},@var{z},@var{region},@var{sides})
##
## Construct a structured tetrahedral 3D mesh on a parallelepipedal
## domain.
##
## @itemize @bullet
## @item @var{x}, @var{y} and @var{z} are the one dimensional mesh
## vector of the corresponding Cartesian axis. 
## @item @var{region} is a number identifying the geometrical volume,
## while @var{sides} is a 6 components vector containing the numbers
## used to identify the geometrical face edges. 
## @end itemize
## 
## The returned value @var{mesh} is a PDE-tool like mesh structure
## composed of the following fields:
## @itemize @minus
## @item @var{p}: matrix with size 3 times number of mesh points. 
## @itemize @bullet
## @item 1st row: x-coordinates of the points.
## @item 2nd row: y-coordinates of the points.
## @item 3rd row: z-coordinates of the points.
## @end itemize
## @item @var{e}: matrix with size 10 times number of mesh face edges.
## @itemize @bullet
## @item 1st row: number of the first vertex of the face edge.
## @item 2nd row: number of the second vertex of the face edge.
## @item 3rd row: number of the third vertex of the face edge.
## @item 4th row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 5th row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 6th row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 7th row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 8th row: number of the geometrical volume to the right of the
## face edge.
## @item 9th row: number of the geometrical volume to the left of the
## face edge.
## @item 10th row: number of the geometrical border containing the face
## edge.
## @end itemize
## @item @var{t}: matrix with size 5 times number of mesh elements.
## @itemize @bullet
## @item 1st row: number of the first vertex of the element.
## @item 2nd row: number of the second vertex of the element.
## @item 3rd row: number of the third vertex of the element.
## @item 4th row: number of the fourth vertex of the element.
## @item 5th row: number of the geometrical volume containing the element.
## @end itemize
## @end itemize 
##
## @seealso{msh2m_structured_mesh, msh3m_gmsh, msh2m_mesh_along_spline,
## msh3m_join_structured_mesh, msh3m_submesh}
## @end deftypefn

function mesh = msh3m_structured_mesh (x, y, z, region, sides)

  ## Check input
  if (nargin != 5) # Number of input parameters
    print_usage ();
  elseif !(isvector (x) && isnumeric (x) && ! isscalar (x)
           && isvector (y) && isnumeric (y) && ! isscalar (y)
           && isvector (z) && isnumeric (z) && ! isscalar (z))
    error("msh3m_structured_mesh: X, Y, Z must be valid numeric vectors.");
  elseif !isscalar(region)
    error("msh3m_structured_mesh: REGION must be a valid scalar.");
  elseif !(isvector(sides) && (length(sides) == 6))
    error("msh3m_structured_mesh: SIDES must be a 6 components vector.");
  endif

  ## Build mesh
  ## Sort point coordinates
  x = sort (x);
  y = sort (y);
  z = sort (z);
  ## Compute # of points in each direction
  nx = length (x);
  ny = length (y);
  nz = length (z);

  ## Generate vertices
  [XX, YY, ZZ] = meshgrid (x, y, z);
  p = [XX(:), YY(:), ZZ(:)]';

  iiv (ny,nx,nz)=0;
  iiv(:)=1:nx*ny*nz;
  iiv(end,:,:)=[];
  iiv(:,end,:)=[];
  iiv(:,:,end)=[];
  iiv=iiv(:)';

  ## Generate connections:

  n1 = iiv; # bottom faces
  n2 = iiv + 1;
  n3 = iiv + ny;
  n4 = iiv + ny + 1;

  N1 = iiv + nx * ny; # top faces
  N2 = N1  + 1;
  N3 = N1  + ny;
  N4 = N3  + 1;

  t = [[n1; n3; n2; N2],...
       [N1; N2; N3; n3],...
       [N1; N2; n3; n1],...
       [N2; n3; n2; n4],...
       [N3; n3; N2; N4],...
       [N4; n3; N2; n4]];

  ## Generate boundary face list

  ## left
  T = t;
  T(:) = p(1, t)' == x(1);
  [~, order] = sort (T, 1);
  ii = (find(sum(T,1)==3));
  order(1,:) = [];
  for jj=1:length (ii)
    e1(:,jj) = t(order(:,ii(jj)),ii(jj));
  endfor
  e1(10,:) = sides(1);

  ## right
  T(:) = p(1,t)' == x(end);
  [~, order] = sort (T, 1);
  ii = (find (sum (T, 1) == 3));
  order(1,:) = [];
  for jj=1:length (ii)
    e2(:,jj) = t(order(:,ii(jj)),ii(jj));
  end
  e2(10,:) = sides(2);

  ## front
  T(:) = p(2,t)' == y(1);
  [~, order] = sort (T, 1);
  ii = (find (sum (T, 1) == 3));
  order(1,:) = [];
  for jj=1:length (ii)
    e3(:,jj) = t(order(:,ii(jj)),ii(jj));
  endfor
  e3(10,:) = sides(3);

  ## back
  T(:) = p(2,t)' == y(end);
  [~,order] = sort (T,1);
  ii = (find (sum (T,1) == 3));
  order(1,:) = [];
  for jj=1:length (ii)
    e4(:,jj) = t(order(:,ii(jj)),ii(jj));
  endfor
  e4(10,:) = sides(4);
  
  ## bottom
  T       = t;
  T(:)    = p(3,t)'==z(1);
  [ignore,order] = sort(T,1);
  ii      = (find (sum (T,1)==3));
  order(1,:) = [];
  for jj=1:length(ii)
    e5(:,jj)      = t(order(:,ii(jj)),ii(jj));
  endfor
  e5(10,:) = sides(5);
  
  ## top
  T       = t;
  T(:)    = p(3,t)'==z(end);
  [ignore,order] = sort(T,1);
  ii      = (find (sum (T,1) == 3));
  order(1,:) = [];
  for jj=1:length(ii)
    e6(:,jj)      = t(order(:,ii(jj)),ii(jj));
  endfor
  e6(10,:) = sides(6);

  ## Assemble structure
  mesh.e       = [e1,e2,e3,e4,e5,e6];
  mesh.t       = t;
  mesh.e (9,:) = region;
  mesh.t (5,:) = region;
  mesh.p       = p;

endfunction

%!test
% x = y = z = linspace (0,1,2)
% [mesh] = msh3m_structured_mesh (x, y, z, 1, 1:6)
% assert = (columns (mesh.p), 8)
% assert = (columns (mesh.t), 6)
% assert = (columns (mesh.e), 12)

%!test
%! x = y = z = linspace (0, 1, 3);
%! mesh = msh3m_structured_mesh (x, y, z, 1, 1:6);
%! assert (columns (mesh.p), 27)
%! assert (columns (mesh.t), 48)
%! assert (columns (mesh.e), 48)

%!test
%! x = y = z = linspace (0,1,4);
%! [mesh] = msh3m_structured_mesh (x, y, z, 1, 1:6);
%! assert (columns (mesh.p), 64)
%! assert (columns (mesh.t), 162)
%! assert (columns (mesh.e), 108)

%!test
%! x = y = z = linspace (0, 1, 1);
%! fail("mesh = msh3m_structured_mesh (x, y, z, 1, 1:6)", "msh3m_structured_mesh: X, Y, Z must be valid numeric vectors.");

%!test
%! x = y = z = eye (2);
%! fail("mesh = msh3m_structured_mesh (x, y, z, 1, 1:6)", "msh3m_structured_mesh: X, Y, Z must be valid numeric vectors.");