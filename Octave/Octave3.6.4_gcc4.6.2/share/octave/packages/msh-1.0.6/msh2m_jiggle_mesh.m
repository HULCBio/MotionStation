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
## @deftypefn {Function File} {[@var{newmsh}]} = @
## msh2m_jiggle_mesh(@var{msh},@var{steps})
##
## Equalize the size of  triangle edges setting a spring of rest length
## @var{factor}*@var{area} along each edge of the mesh and solving for
## static equilibrium.
##
## The non-linear eqautions of the system obtained are solved via a
## non-linear Gauss-Seidel method. @var{step} is the number of steps of
## the method to be applied.
##
## May be useful when distorting a mesh, type @code{demo
## msh2m_jiggle_mesh} to see some examples. 
##
## @seealso{msh2m_displacement_smoothing, msh2m_equalize_mesh}
##
## @end deftypefn
  
function [msh] = msh2m_jiggle_mesh(msh,steps)

  ## Check input
  if nargin != 2 # Number of input parameters
    error("msh2m_jiggle_mesh: wrong number of input parameters.");
  elseif !(isstruct(msh)    && isfield(msh,"p") &&
	   isfield(msh,"t") && isfield(msh,"e"))
    error("msh2m_jiggle_mesh: first input is not a valid mesh structure.");
  elseif !isscalar(steps)
    error("msh2m_jiggle_mesh: second argument is not a valid scalar");
  endif

  ## Solve for static equilibrium
  nel= columns(msh.t);
  nnodes = columns(msh.p);

  x  = msh.p(1,:)';
  y  = msh.p(2,:)';

  dnodes = unique(msh.e(1:2,:)(:));
  vnodes = setdiff(1:nnodes,dnodes);

  ## Find node neighbours 
  ## FIXME: should this go into msh2m_topological_properties ?
  sides = msh2m_topological_properties(msh,"sides");
  for inode = 1:nnodes
    neig{inode} = (sides(:, sides(1,:) == inode | sides(2,:) == inode))(:);
    neig{inode} (neig{inode} == inode) = [];
  endfor

  for istep = 1:steps
    for inode =vnodes
      xx = x(neig{inode}) * ones(size(neig{inode}))';
      lx = abs ( xx - xx' )(:);
      mx = ( xx + xx'  )(:)/2; 
      x(inode) = sum(mx.*lx)/sum(lx);

      yy = y(neig{inode}) * ones(size(neig{inode}))';
      ly = abs ( yy - yy' )(:);
      my = (yy + yy')(:)/2; 
      y(inode) = sum(my.*ly)/sum(ly);
    endfor
  endfor
  
  msh.p = [x';y'];

endfunction
  
%!demo
%! ### distort a mesh on a square equalizing at each step
%! msh = msh2m_structured_mesh(linspace(0,1,10),linspace(0,1,10),1,1:4,"right");
%! dnodes = msh2m_nodes_on_sides(msh,1:4);
%! varnodes = setdiff([1:columns(msh.p)],dnodes);
%! x = msh.p(1,:)';
%! y = msh.p(2,:)';
%! dx = dy = zeros(columns(msh.p),1);
%! dytot = dxtot = -.4*sin(x(dnodes).*y(dnodes)*pi/2);
%! Nsteps = 30;
%! for ii=1:Nsteps
%!   dx(dnodes) = dxtot;
%!   dy(dnodes) = dytot;
%!   [Ax,Ay] = msh2m_displacement_smoothing(msh,1);
%!   dx(varnodes) = Ax(varnodes,varnodes) \ ...
%!       (-Ax(varnodes,dnodes)*dx(dnodes));
%!   dy(varnodes) = Ay(varnodes,varnodes) \ ...
%!       (-Ay(varnodes,dnodes)*dy(dnodes));
%!   msh.p(1,:) += dx'/Nsteps;
%!   msh.p(2,:) += dy'/Nsteps;
%!   triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)','r');
%!   pause(.5)
%!   x   = msh.p(1,:)';
%!   y   = msh.p(2,:)';
%!   msh = msh2m_jiggle_mesh(msh,10);
%!   hold on;
%!   triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)');
%!   hold off;
%!   pause(.5)
%! endfor