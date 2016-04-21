## Copyright (C) 2012  Carlo de Falco
##
## This file is part of:
##     BIM - Diffusion Advection Reaction PDE Solver
##
##  BIM is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  BIM is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with BIM; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} @
## {@var{A}} = bim3a_osc_laplacian (@var{mesh}, @var{epsilon})
##
## Build the osc finite element stiffness matrix for a diffusion
## problem. 
##
## For details on the Orthogonal Subdomain Collocation (OSC) method
## see: M.Putti and C.Cordes, SIAM J.SCI.COMPUT. Vol.19(4), pp.1154-1168, 1998. 
##
## The equation taken into account is:
##
## - div (@var{epsilon} grad (u)) = f
## 
## where @var{epsilon} is an element-wise constant scalar function,
## while @var{kappa} is a piecewise linear conforming scalar function.
##
## @seealso{bim3a_rhs, bim3a_reaction, bim2a_laplacian, bim3a_laplacian}
## @end deftypefn

function M = bim3a_osc_laplacian (msh, epsilon)

  ## Check input
  if (nargin != 2)
    print_usage ();
  elseif (! (isstruct (msh)     
             && isfield (msh, "p") 
             && isfield (msh, "t") 
             && isfield (msh, "e")))
    error (["bim3a_laplacian: first input ", ...
            "is not a valid msh structure"]);
  endif

  nnodes = columns (msh.p);
  nelem  = columns (msh.t);

  ## Turn scalar input to a vector of appropriate size
  if (isscalar (epsilon))
    epsilon = epsilon * ones (nelem, 1);
  endif

  if (! isvector (epsilon))
    error ("bim3a_laplacian: coefficient is not a vector");
  elseif (numel (epsilon) != nelem)
    error (["bim3a_laplacian: length of epsilon is ", ...
            "not equal to the number of mesh elements"]);
  endif

  ## Local contributions
  Lloc = __osc_local_laplacian__ (msh.p, msh.t, msh.shg, epsilon, msh.area, nnodes, nelem);

  ## Assembly
  for inode = 1:4
    for jnode = 1:4
      ginode(inode, jnode,:) = msh.t(inode, :);
      gjnode(inode, jnode,:) = msh.t(jnode, :);
    endfor
  endfor

  M = sparse (ginode(:), gjnode(:), Lloc(:), nnodes, nnodes);

endfunction

%!shared msh, epsilon, M, nnodes, nelem, x, y, z
%!test
%! msh = bim3c_mesh_properties (msh3m_structured_mesh (0:5, 0:5, 0:5, 1, 1:6));
%! x = msh.p (1, :).';
%! y = msh.p (2, :).';
%! z = msh.p (3, :).';
%! u = ones (size (x));
%! M = bim3a_osc_laplacian (msh, 1);
%! assert (M * u, zeros (size (u)), eps * 100)
%!test
%! u = x;
%! bnd = bim3c_unknowns_on_faces (msh, [1, 2]);
%! int = setdiff (1:columns (msh.p), bnd);
%! assert (M(int, int) * u(int), -M(int, bnd) * u(bnd), 100 * eps)
%!test
%! u = y;
%! bnd = bim3c_unknowns_on_faces (msh, [3, 4]);
%! int = setdiff (1:columns (msh.p), bnd);
%! assert (M(int, int) * u(int), -M(int, bnd) * u(bnd), 100 * eps)
%!test
%! u = z;
%! bnd = bim3c_unknowns_on_faces (msh, [5, 6]);
%! int = setdiff (1:columns (msh.p), bnd);
%! assert (M(int, int) * u(int), -M(int, bnd) * u(bnd), 100 * eps)
%!test
%! u = z;
%! bnd = bim3c_unknowns_on_faces (msh, [5, 6]);
%! int = setdiff (1:columns (msh.p), bnd);
%! M = bim3a_osc_laplacian (msh, pi);
%! assert (M(int, int) * u(int), -M(int, bnd) * u(bnd), 100 * eps)
