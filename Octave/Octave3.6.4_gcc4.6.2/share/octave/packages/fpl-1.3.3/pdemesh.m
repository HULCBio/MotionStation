##  Copyright (C) 2010  Carlo de Falco
##
##  This file is part of:
##         FPL - Fem PLotting package for octave
##
##  FPL is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 3 of the License, or
##  (at your option) any later version.
##
##  FPL is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with FPL; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {@var{h} =} pdemesh (@var{p}, @var{e}, @var{t}, @var{u})
##
## Plot a triangular mesh in 3D given a mesh structure and node data.
## @var{p}, @var{t} are the mesh vertices and connectivity, @var{u} node data.
## @var{e} is ignored and is accepted only for compatibiity.
##
## @seealso{fpl_dx_write_field, fpl_vtk_write_field} 
##
## @end deftypefn

function h = pdemesh (p, e, t, u)

  ## Check input
  if (nargin < 3)
    error("pdemesh: wrong number of input parameters");
  elseif (nargin == 3)
    u = zeros (1, columns (p));
  endif

  nel = columns (t);
  npt = columns (p);
  if (numel (u) != npt)
    error("pdemesh: wrong data size");
  endif

  hs = ishold ();
  
### node data
  H = trimesh (t(1:3, :).', p(1,:).', p(2,:).', u(:));
  
  if (nargout == 1)
    h = H;
  endif

  if (hs)
    hold on;
  else
    hold off;
  endif

endfunction

%!demo
%! msh = msh2m_structured_mesh ([0:.05:1], [0:.1:1], 1, 1:4, 'random');
%! x = msh.p(1,:)'; xm = sum(x(msh.t(1:3,:)),1)/3;
%! y = msh.p(2,:)'; ym = sum(y(msh.t(1:3,:)),1)/3;
%! pdemesh (msh.p, msh.t, msh.t, x.*(1-x).*y.*(1-y))
%! view(3)
