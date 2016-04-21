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
## @deftypefn {Function File} {[@var{Ax},@var{Ay}]} =  @
## msh2m_displacement_smoothing(@var{msh},@var{k})
##
## Displace the boundary of a 2D mesh setting a spring with force/length
## constant @var{k} along each edge and enforcing equilibrium. 
##
## This function builds matrices containing the resulting (linearized)
## equation for x and y coordinates of each mesh node. Boundary
## conditions enforcing the displacement (Dirichlet type problem) or the
## force (Neumann type) at the boundary must be added to make the system
## solvable, e.g.: 
##
## @example
## msh = msh2m_structured_mesh(linspace(0,1,10),@
## linspace(0,1,10),@
## 1,1:4,"left");
##
## dnodes   = msh2m_nodes_on_sides(msh,1:4);
## varnodes = setdiff([1:columns(msh.p)],dnodes);
## xd     = msh.p(1,dnodes)';
## yd     = msh.p(2,dnodes)';
## dx     = dy    = zeros(columns(msh.p),1);
## dxtot  = dytot = -.5*sin(xd.*yd*pi/2);
## Nsteps = 10;
##
## for ii = 1:Nsteps
##  dx(dnodes) = dxtot;
##  dy(dnodes) = dytot;
##  [Ax,Ay] = msh2m_displacement_smoothing(msh,1);
##  dx(varnodes) = Ax(varnodes,varnodes) \ ...
##      (-Ax(varnodes,dnodes)*dx(dnodes));
##  dy(varnodes) = Ay(varnodes,varnodes) \ ...
##      (-Ay(varnodes,dnodes)*dy(dnodes));
##  msh.p += [ dx'/Nsteps; dy'/Nsteps ] ;
##  triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)');
##  pause(.01)
## endfor
## @end example
##
## @seealso{msh2m_jiggle_mesh}
##
## @end deftypefn

function [Ax,Ay] = msh2m_displacement_smoothing(msh, k)

  ## Check input
  if nargin != 2 # Number of input parameters
    error("msh2m_displacement_smoothing: wrong number of input parameters.");
  elseif !(isstruct(msh)    && isfield(msh,"p") &&
	   isfield(msh,"t") && isfield(msh,"e"))
    error("msh2m_displacement_smoothing: first input is not a valid mesh structure.");
  elseif !isscalar(k)
    error("msh2m_displacement_smoothing: k must be a valid scalar");
  endif

  ## Construct matrices
  x  = msh.p(1,:);
  y  = msh.p(2,:);

  dx2 = (x(msh.t([1 2 3],:))-x(msh.t([2 3 1],:))).^2;
  dy2 = (y(msh.t([1 2 3],:))-y(msh.t([2 3 1],:))).^2;

  l2  = dx2 + dy2;

  Ax = spalloc(length(x),length(x),1);
  Ay = spalloc(length(x),length(x),1);

  ax = zeros(3,3,columns(msh.t));
  ay = zeros(3,3,columns(msh.t));
	
  for inode=1:3
    for jnode=1:3
      ginode(inode,jnode,:)=msh.t(inode,:);
      gjnode(inode,jnode,:)=msh.t(jnode,:);
    endfor
  endfor

  for ii=1:3  
    for jj=ii+1:3
	
      ax(ii,jj,:) = ax(jj,ii,:) = reshape(-k * dx2(ii,:)./l2(ii,:),1,1,[]);	
      ay(ii,jj,:) = ay(jj,ii,:) = reshape(-k * dy2(ii,:)./l2(ii,:),1,1,[]);
      
      ax(ii,ii,:) -= ax(ii,jj,:);
      ax(jj,jj,:) -= ax(ii,jj,:);
      ay(ii,ii,:) -= ay(ii,jj,:);
      ay(jj,jj,:) -= ay(ii,jj,:);
      
    endfor
  endfor
  
  Ax = sparse(ginode(:),gjnode(:),ax(:));
  Ay = sparse(ginode(:),gjnode(:),ay(:));
	 
endfunction

%!demo
%! msh = msh2m_structured_mesh(linspace(0,1,10),
%! 			    linspace(0,1,10),
%! 			    1,1:4,"left");
%! dnodes   = msh2m_nodes_on_sides(msh,1:4);
%! varnodes = setdiff([1:columns(msh.p)],dnodes);
%! 
%! xd = msh.p(1,dnodes)';
%! yd = msh.p(2,dnodes)';
%! 
%! dy = zeros(columns(msh.p),1);
%! dx = dy;
%! 
%! dxtot = -.5*sin(xd.*yd*pi/2);
%! dytot = -.5*sin(xd.*yd*pi/2);
%! 
%! Nsteps = 5;
%! for ii=1:Nsteps
%!   
%!   dx(dnodes) = dxtot;
%!   dy(dnodes) = dytot;
%!   
%!   [Ax,Ay] = msh2m_displacement_smoothing(msh,1);
%!   
%!   dx(varnodes) = Ax(varnodes,varnodes) \ ...
%!       (-Ax(varnodes,dnodes)*dx(dnodes));
%!   dy(varnodes) = Ay(varnodes,varnodes) \ ...
%!       (-Ay(varnodes,dnodes)*dy(dnodes));
%! 
%!   msh.p(1,:) += dx'/Nsteps;
%!   msh.p(2,:) += dy'/Nsteps;
%! 
%!   if mod(ii,2)==0
%!     triplot(msh.t(1:3,:)',msh.p(1,:)',msh.p(2,:)');
%!     pause(.01)
%!   endif
%! endfor
