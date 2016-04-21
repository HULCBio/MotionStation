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
## @deftypefn {Function File} {@var{h} =} pdesurf (@var{p}, @var{t}, @var{u})
##
## Plot a 3D surface given node or element data on a triangular mesh.
## @var{p}, @var{t} are the mesh vertices and connectivity, @var{u} node or element data.
##
## @seealso{fpl_dx_write_field, fpl_vtk_write_field} 
##
## @end deftypefn

function h = pdesurf (p, t, u)

  ## Check input
  if nargin!=3
    error("pdesurf: wrong number of input parameters");
  endif

  nel = columns (t);
  npt = columns (p);
  if (numel (u) != npt && numel (u) != nel)
    error("pdesurf: wrong data size");
  endif

  hs = ishold ();
  
### node data
  if (numel (u) == npt)
    ## normalize data
    c  = colormap;
    uc = sum (u(t(1:3, :)), 1)/3;
    uc = floor ((rows (c)-1)*(uc - min (uc))/(max (uc) - min (uc))) + 1;
    H = patch ('Faces', t(1:3, :)', 
               'Vertices', [p(1,:)', p(2,:)', u], 
               'FaceVertexCData', c(uc(:), :));
### triangle data
  elseif (numel (u) == nel)
    tri = reshape (1:3*nel, 3, [])';
    pt(:, 1) = p(1, t(1:3, :));
    pt(:, 2) = p(2, t(1:3, :));
    pt(:, 3) = repmat (u(:)', 3, 1)(:);
    ## normalize data
    c  = colormap;
    uc = floor ((rows (c)-1)*(u - min (u))/(max (u) - min (u))) + 1;
    H = patch ('Faces', tri, 
               'Vertices', pt, 
               'FaceVertexCData', c(uc(:), :), 
               'FaceColor', 'flat');
  endif
  
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
%! pdesurf (msh.p, msh.t, x.*(1-x).*y.*(1-y))
%! title ('node data')
%! view(3)
%! figure ()
%! pdesurf (msh.p, msh.t, xm.*(1-xm).*ym.*(1-ym))
%! title ('element data')
%! view(3)