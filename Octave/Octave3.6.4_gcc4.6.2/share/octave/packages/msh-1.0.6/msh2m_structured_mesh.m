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
## msh2m_structured_mesh(@var{x},@var{y},@var{region},@var{sides},@var{string})
##
## Construct a structured triangular 2D mesh on a rectangular domain.
##
## @itemize @bullet
## @item @var{x} and @var{y} are the one dimensional mesh vector of the
## corresponding Cartesian axis.
## @item @var{region} is a number identifying the geometrical surface
## region, while @var{sides} is a 4 components vector containing the
## numbers used to identify the geometrical side edges. 
## @item @var{string} is an optional value specifying the orientation of
## the diagonal edge of the structured mesh. It may take the value
## @code{"right"} (default), @code{"left"}, @code{"random"}.
## @end itemize
##
## The returned value @var{mesh} is a PDE-tool like mesh structure
## composed of the following fields:
## @itemize @minus
## @item @var{p}: matrix with size 2 times number of mesh points. 
## @itemize @bullet
## @item 1st row: x-coordinates of the points.
## @item 2nd row: y-coordinates of the points.
## @end itemize
## @item @var{e}: matrix with size 7 times number of mesh side edges.
## @itemize @bullet
## @item 1st row: number of the first vertex of the side edge.
## @item 2nd row: number of the second vertex of the side edge.
## @item 3rd row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 4th row: set to 0, present for compatibility with MatLab PDE-tool.
## @item 5th row: number of the geometrical border containing the side
## edge.
## @item 6th row: number of the geometrical surface to the right of
## side edge.
## @item 7th row: number of the geometrical surface to the left of the
## side edge.
## @end itemize
## @item @var{t}: matrix with size 4 times number of mesh elements.
## @itemize @bullet
## @item 1st row: number of the first vertex of the element.
## @item 2nd row: number of the second vertex of the element.
## @item 3rd row: number of the third vertex of the element.
## @item 4th row: number of the geometrical surface containing the element.
## @end itemize
## @end itemize 
##
## @seealso{msh3m_structured_mesh, msh2m_gmsh, msh2m_mesh_along_spline,
## msh2m_join_structured_mesh, msh2m_submesh} 
## @end deftypefn

function [mesh] = msh2m_structured_mesh(x,y,region,sides,varargin)
  
  ## Check input
  if ((nargin < 4) || (nargin > 5)) # Number of input parameters
    error("msh2m_structured_mesh: wrong number of input parameters.");
  elseif !(isvector(x) && isnumeric(x) && isvector(y) && isnumeric(y))
    error("msh2m_structured_mesh: X and Y must be valid numeric vectors.");
  elseif !isscalar(region)
    error("msh2m_structured_mesh: REGION must be a valid scalar.");
  elseif !(isvector(sides) && (length(sides) == 4))
    error("msh2m_structured_mesh: SIDES must be a 4 components vector.");
  endif

  ## Build mesh
  default = "right";

  ## Check if any orientation is given
  if length(varargin)==0
    string = default;
  else
    string = varargin{1};
  endif

  ## Construct mesh
  switch string
    case "right"
      [mesh] = Ustructmesh_right(x, y, region, sides);
    case "left"
      [mesh] = Ustructmesh_left(x, y, region, sides);
    case "random"
      [mesh] = Ustructmesh_random(x, y, region, sides);
    otherwise
      error("msh2m_structured_mesh: STRING has not a valid value.");
  endswitch

endfunction

## Right diagonal structured mesh
function [mesh]=Ustructmesh_right(x,y,region,sides)
  
  x = sort(x);
  y = sort(y);

  nx = length(x);
  ny = length(y);
  [XX,YY] = meshgrid(x,y);
  p = [XX(:),YY(:)]';
  iiv (ny,nx)=0;
  iiv(:)=1:nx*ny;
  iiv(end,:)=[];
  iiv(:,end)=[];
  iiv=iiv(:)';
  t = [[iiv;iiv+ny;iiv+ny+1],[iiv;iiv+ny+1;iiv+1] ];
  t (4,:)=region;

  l1 = 1+ny*([1:nx]-1);
  l4 = 1:ny;
  l2 = ny*(nx-1)+1:nx*ny;
  l3 = ny + l1 -1;

  e = [ l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])
       l1([2:end]) l2([2:end]) l3([2:end]) l4([2:end])
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       l1([1:end-1])*0+sides(1) l2([1:end-1])*0+sides(2) l3([1:end-1])*0+sides(3) l4([1:end-1])*0+sides(4)
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0+region
       ];
  mesh.p = p;
  mesh.e = e;
  mesh.t = t;
  
endfunction

## Left diagonal structured mesh
function [mesh]=Ustructmesh_left(x,y,region,sides)

  x = sort(x);
  y = sort(y);

  nx = length(x);
  ny = length(y);
  [XX,YY] = meshgrid(x,y);
  p = [XX(:),YY(:)]';
  iiv (ny,nx)=0;
  iiv(:)=1:nx*ny;
  iiv(end,:)=[];
  iiv(:,end)=[];
  iiv=iiv(:)';
  t = [[iiv;iiv+ny;iiv+1],[iiv+1;iiv+ny;iiv+ny+1] ];
  t (4,:)=region;

  l1 = 1+ny*([1:nx]-1);
  l4 = 1:ny;
  l2 = ny*(nx-1)+1:nx*ny;
  l3 = ny + l1 -1;

  e = [ l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])
       l1([2:end]) l2([2:end]) l3([2:end]) l4([2:end])
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       l1([1:end-1])*0+sides(1) l2([1:end-1])*0+sides(2) l3([1:end-1])*0+sides(3) l4([1:end-1])*0+sides(4)
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0+region
       ];
  mesh.p = p;
  mesh.e = e;
  mesh.t = t;

endfunction

## Random diagonal structured mesh
function [mesh]=Ustructmesh_random(x,y,region,sides)
  
  x = sort(x);
  y = sort(y);

  nx = length(x);
  ny = length(y);
  [XX,YY] = meshgrid(x,y);
  p = [XX(:),YY(:)]';
  iiv (ny,nx)=0;
  iiv(:)=1:nx*ny;
  iiv(end,:)=[];
  iiv(:,end)=[];
  iiv=iiv(:)';

  niiv = length(iiv);
  theperm = iiv(randperm(niiv));
  first = theperm(1:floor(niiv/2));
  second = theperm(floor(niiv/2)+1:end);

  t = [[first;first+ny;first+ny+1],[first;first+ny+1;first+1] ];
  t = [t,[second;second+ny;second+1],[second+ny;second+ny+1;second+1] ];

  t (4,:)=region;

  l1 = 1+ny*([1:nx]-1);
  l4 = 1:ny;
  l2 = ny*(nx-1)+1:nx*ny;
  l3 = ny + l1 -1;

  e = [ l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])
       l1([2:end]) l2([2:end]) l3([2:end]) l4([2:end])
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       l1([1:end-1])*0+sides(1) l2([1:end-1])*0+sides(2) l3([1:end-1])*0+sides(3) l4([1:end-1])*0+sides(4)
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0
       [l1([1:end-1]) l2([1:end-1]) l3([1:end-1]) l4([1:end-1])]*0+region
       ];
  mesh.p = p;
  mesh.e = e;
  mesh.t = t;

endfunction

%!test
%! x = y = linspace(0,1,3);
%! msh = msh2m_structured_mesh(x,y,1,[1:4]);
%! p = [0.00000   0.00000   0.00000   0.50000   0.50000   0.50000 \
%!      1.00000   1.00000   1.00000
%!      0.00000   0.50000   1.00000   0.00000   0.50000   1.00000 \
%!      0.00000   0.50000   1.00000];
%! assert(msh.p,p)
%! e = [1   4   7   8   3   6   1   2
%!      4   7   8   9   6   9   2   3
%!      0   0   0   0   0   0   0   0
%!      0   0   0   0   0   0   0   0
%!      1   1   2   2   3   3   4   4
%!      0   0   0   0   0   0   0   0
%!      1   1   1   1   1   1   1   1];
%! assert(msh.e,e)
%! t =[1   2   4   5   1   2   4   5
%!     4   5   7   8   5   6   8   9
%!     5   6   8   9   2   3   5   6
%!     1   1   1   1   1   1   1   1];
%! assert(msh.t,t)