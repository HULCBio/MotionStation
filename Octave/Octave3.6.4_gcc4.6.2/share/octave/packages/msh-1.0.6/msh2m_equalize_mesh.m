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
## msh2m_equalize_mesh(@var{mesh}) 
##
## Apply a baricentric regularization to equalize the size of triangle
## edges, i.e. move each node to the center of mass of the patch of
## triangles to which it belongs. 
##
## May be useful when distorting a mesh.
## Type @code{demo msh2m_equalize_mesh} to see some examples.
##
## @seealso{msh2m_displacement_smoothing}
##
## @end deftypefn
  
function [msh] = msh2m_equalize_mesh(msh)
  
  ## Check input
  if nargin != 1 # Number of input parameters
    error("msh2m_equalize_mesh: wrong number of input parameters.");
  elseif !(isstruct(msh)    && isfield(msh,"p") &&
	   isfield(msh,"t") && isfield(msh,"e"))
    error("msh2m_equalize_mesh: first input is not a valid mesh structure.");
  endif

  ## Apply regularization
  nel= columns(msh.t);

  x  = msh.p(1,:)';
  y  = msh.p(2,:)';

  dnodes = unique(msh.e(1:2,:)(:));
  varnodes = setdiff([1:columns(msh.p)],dnodes);

  Ax = spalloc(length(x),length(x),1);
  Ay = spalloc(length(x),length(x),1);

  ax = zeros(3,3,nel);
  ay = zeros(3,3,nel);

  for inode=1:3
    giinode(inode,:)=msh.t(inode,:);
    for jnode=1:3
      ginode(inode,jnode,:)=msh.t(inode,:);
      gjnode(inode,jnode,:)=msh.t(jnode,:);
    endfor
  endfor

  for ii=1:3  
    for jj=ii+1:3
      
      ax(ii,jj,:) = ax(jj,ii,:) = -ones(1,1,nel);
      ay(ii,jj,:) = ay(jj,ii,:) = -ones(1,1,nel);
      
      ax(ii,ii,:) -= ax(ii,jj,:);
      ax(jj,jj,:) -= ax(ii,jj,:);
      ay(ii,ii,:) -= ay(ii,jj,:);
      ay(jj,jj,:) -= ay(ii,jj,:);
      
    endfor
  endfor

  Ax = sparse(ginode(:),gjnode(:),ax(:));
  Ay = sparse(ginode(:),gjnode(:),ay(:));

  x(varnodes) = Ax(varnodes,varnodes) \ (-Ax(varnodes,dnodes)*x(dnodes));
  y(varnodes) = Ay(varnodes,varnodes) \ (-Ay(varnodes,dnodes)*y(dnodes));
  msh.p(1,:) = x';
  msh.p(2,:) = y';

endfunction

%!demo
%! ### equalize a structured mesh without moving boundary nodes
%! msh = msh2m_structured_mesh(linspace(0,1,10),linspace(0,1,10),1,1:4,"random");
%! dnodes = msh2m_nodes_on_sides(msh,1:4);
%! varnodes = setdiff([1:columns(msh.p)],dnodes);
%! x = msh.p(1,:)';
%! y = msh.p(2,:)';
%! msh = msh2m_equalize_mesh(msh);
%! triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)');
%! pause(.01)

%!demo
%! ### distort a mesh on a square equalizing at each step
%! msh = msh2m_structured_mesh(linspace(0,1,10),linspace(0,1,10),1,1:4,"random");
%! dnodes = msh2m_nodes_on_sides(msh,1:4);
%! varnodes = setdiff([1:columns(msh.p)],dnodes);
%! x = msh.p(1,:)';
%! y = msh.p(2,:)';
%! dx = dy = zeros(columns(msh.p),1);
%! dytot = dxtot = -.7*sin(x(dnodes).*y(dnodes)*pi/2);
%! Nsteps = 10;
%! for ii=1:Nsteps
%!  dx(dnodes) = dxtot;
%!  dy(dnodes) = dytot;
%!  [Ax,Ay] = msh2m_displacement_smoothing(msh,1);
%!  dx(varnodes) = Ax(varnodes,varnodes) \ ...
%!      (-Ax(varnodes,dnodes)*dx(dnodes));
%!  dy(varnodes) = Ay(varnodes,varnodes) \ ...
%!  (-Ay(varnodes,dnodes)*dy(dnodes));
%!  msh.p(1,:) += dx'/Nsteps;
%!  msh.p(2,:) += dy'/Nsteps;
%! triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)','r');
%!  pause(.5)
%! x = msh.p(1,:)';
%! y = msh.p(2,:)';
%! msh = msh2m_equalize_mesh(msh);
%! hold on;triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)');hold off
%!  pause(.5)
%! endfor