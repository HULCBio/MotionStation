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
##
## @deftypefn {Function File} @
## {[@var{A}]} = bim3a_osc_advection_diffusion (@var{mesh}, @var{alpha}, @var{v})
##
## Build the Scharfetter-Gummel stabilized OSC stiffness 
## matrix for a diffusion-advection problem. 
## 
## For details on the Orthogonal Subdomain Collocation (OSC) method
## see: M.Putti and C.Cordes, SIAM J.SCI.COMPUT. Vol.19(4), pp.1154-1168, 1998.
##
## The equation taken into account is:
##
## - div (@var{alpha} ( grad (u) - grad (@var{v}) u)) = f
##
## where @var{v} is a piecewise linear continuous scalar
## functions and @var{alpha} is a piecewise constant scalar function.
##
## @seealso{bim3a_rhs, bim3a_osc_laplacian, bim3a_reaction, bim3a_laplacian, bim3c_mesh_properties}
## @end deftypefn

function M = bim3a_osc_advection_diffusion (msh, epsilon, v)

  ## Check input
  if (nargin != 3)
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
    epsilon = epsilon * ones(nelem, 1);
  endif

  if (! isvector (epsilon))
    error ("bim3a_laplacian: coefficient is not a vector");
  elseif (numel (epsilon) != nelem)
    error (["bim3a_laplacian: length of epsilon is ", ...
            "not equal to the number of mesh elements"]);
  endif

  ## Local contributions
  Lloc = __osc_local_laplacian__ (msh.p, msh.t, msh.shg, epsilon, msh.area, nnodes, nelem);
  
  ## Stabilization
  if (isscalar (v))
    v = zeros (nelem, 1);
  endif

  vloc = v(msh.t(1:4, :));
  [bp12, bm12] = bimu_bernoulli (vloc(2,:)-vloc(1,:));
  [bp13, bm13] = bimu_bernoulli (vloc(3,:)-vloc(1,:));
  [bp14, bm14] = bimu_bernoulli (vloc(4,:)-vloc(1,:));
  [bp23, bm23] = bimu_bernoulli (vloc(3,:)-vloc(2,:));
  [bp24, bm24] = bimu_bernoulli (vloc(4,:)-vloc(2,:));
  [bp34, bm34] = bimu_bernoulli (vloc(4,:)-vloc(3,:));
  
  bp12 = reshape (bp12, 1, 1, nelem) .* Lloc(1,2,:);
  bm12 = reshape (bm12, 1, 1, nelem) .* Lloc(1,2,:);
  bp13 = reshape (bp13, 1, 1, nelem) .* Lloc(1,3,:);
  bm13 = reshape (bm13, 1, 1, nelem) .* Lloc(1,3,:);
  bp14 = reshape (bp14, 1, 1, nelem) .* Lloc(1,4,:);
  bm14 = reshape (bm14, 1, 1, nelem) .* Lloc(1,4,:);
  bp23 = reshape (bp23, 1, 1, nelem) .* Lloc(2,3,:);
  bm23 = reshape (bm23, 1, 1, nelem) .* Lloc(2,3,:);
  bp24 = reshape (bp24, 1, 1, nelem) .* Lloc(2,4,:);
  bm24 = reshape (bm24, 1, 1, nelem) .* Lloc(2,4,:);
  bp34 = reshape (bp34, 1, 1, nelem) .* Lloc(3,4,:);
  bm34 = reshape (bm34, 1, 1, nelem) .* Lloc(3,4,:);

  Sloc(1,1,:) = -bm12-bm13-bm14;
  Sloc(1,2,:) = bp12;
  Sloc(1,3,:) = bp13;
  Sloc(1,4,:) = bp14;

  Sloc(2,1,:) = bm12;
  Sloc(2,2,:) = -bp12-bm23-bm24; 
  Sloc(2,3,:) = bp23;
  Sloc(2,4,:) = bp24;

  Sloc(3,1,:) = bm13;
  Sloc(3,2,:) = bm23;
  Sloc(3,3,:) = -bp13-bp23-bm34;
  Sloc(3,4,:) = bp34;
  
  Sloc(4,1,:) = bm14;
  Sloc(4,2,:) = bm24;
  Sloc(4,3,:) = bm34;
  Sloc(4,4,:) = -bp14-bp24-bp34;

     
  ## Assembly
  for inode = 1:4
    for jnode = 1:4
      ginode(inode, jnode,:) = msh.t(inode, :);
      gjnode(inode, jnode,:) = msh.t(jnode, :);
    endfor
  endfor

  M = sparse (ginode(:), gjnode(:), Sloc(:), nnodes, nnodes);

endfunction

%!shared msh, epsilon, M, nnodes, nelem, x, y, z
%!test
%! msh = bim3c_mesh_properties (msh3m_structured_mesh (0:5, 0:5, 0:5, 1, 1:6));
%! x = msh.p (1, :).';
%! y = msh.p (2, :).';
%! z = msh.p (3, :).';
%! u = ones (size (x));
%! M = bim3a_osc_advection_diffusion (msh, 1, 0);
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
%! M = bim3a_osc_advection_diffusion (msh, pi, 0);
%! assert (M(int, int) * u(int), -M(int, bnd) * u(bnd), 100 * eps)
%!test
%! M = bim3a_osc_advection_diffusion (msh, 1, x);
%! assert (norm (sum (M, 1), inf), 0, eps * 100)
%!test
%! M = bim3a_osc_advection_diffusion (msh, 1, y);
%! assert (norm (sum (M, 1), inf), 0, eps * 100)
%!test
%! M = bim3a_osc_advection_diffusion (msh, 1, z);
%! assert (norm (sum (M, 1), inf), 0, eps * 100)

%!demo
%! gmsh_input = [["Point(1) = {0, 0, 0, .1};      \n"], ...
%! ["Point(2) = {1, 0, 0, .1};                    \n"], ...
%! ["Point(3) = {0, -.3, 0, .1};                  \n"], ...
%! ["Point(4) = {0, +.3, 0, .1};                  \n"], ...
%! ["Point(5) = {1, -.3, 0, .1};                  \n"], ...
%! ["Point(6) = {1, 0.3, 0, .1};                  \n"], ...
%! ["Point(7) = {0, 0, -.3, .1};                  \n"], ...
%! ["Point(8) = {0, 0, +.3, .1};                  \n"], ...
%! ["Point(9) = {1, 0, -.3, .1};                  \n"], ...
%! ["Point(10) = {1, 0, 0.3, .1};                 \n"], ...
%! ["Circle(1) = {4, 1, 7};                       \n"], ...
%! ["Circle(2) = {7, 1, 3};                       \n"], ...
%! ["Circle(3) = {3, 1, 8};                       \n"], ...
%! ["Circle(4) = {8, 1, 4};                       \n"], ...
%! ["Circle(5) = {6, 2, 9};                       \n"], ...
%! ["Circle(6) = {9, 2, 5};                       \n"], ...
%! ["Circle(7) = {5, 2, 10};                      \n"], ...
%! ["Circle(8) = {10, 2, 6};                      \n"], ...
%! ["Line(9) = {4, 6};                            \n"], ...
%! ["Line(10) = {3, 5};                           \n"], ...
%! ["Line(11) = {8, 10};                          \n"], ...
%! ["Line(12) = {7, 9};                           \n"], ...
%! ["Line Loop(13) = {4, 1, 2, 3};                \n"], ...
%! ["Plane Surface(14) = {13};                    \n"], ...
%! ["Line Loop(15) = {5, 6, 7, 8};                \n"], ...
%! ["Plane Surface(16) = {15};                    \n"], ...
%! ["Line Loop(17) = {9, -8, -11, 4};             \n"], ...
%! ["Ruled Surface(18) = {17};                    \n"], ...
%! ["Line Loop(19) = {12, -5, -9, 1};             \n"], ...
%! ["Ruled Surface(20) = {19};                    \n"], ...
%! ["Line Loop(21) = {12, 6, -10, -2};            \n"], ...
%! ["Ruled Surface(22) = {21};                    \n"], ...
%! ["Line Loop(23) = {11, -7, -10, 3};            \n"], ...
%! ["Ruled Surface(24) = {23};                    \n"], ...
%! ["Surface Loop(25) = {18, 20, 22, 16, 24, 14}; \n"], ...
%! ["Volume(26) = {25};                           \n"]];
%! fname = tmpnam ();
%! [fid, msg] = fopen (strcat (fname, ".geo"), "w");
%! if (fid < 0); error (msg); endif
%! fputs (fid, gmsh_input);
%! fclose (fid); 
%! msh = bim3c_mesh_properties (msh3m_gmsh (fname, "clscale", ".25"));
%! x = msh.p (1, :).';
%! u = x;
%! bnd = bim3c_unknowns_on_faces (msh, [14, 16]);
%! int = setdiff (1:columns (msh.p), bnd);
%! Mosc = bim3a_osc_advection_diffusion (msh, 1, msh.p(1,:)'*0);
%! Mgal = bim3a_advection_diffusion (msh, 1, msh.p(1,:)'*0);
%! u(int) = Mosc(int, int) \ ( - Mosc(int, bnd) * u(bnd));
%! uosc = u;
%! u(int) = Mgal(int, int) \ ( - Mgal(int, bnd) * u(bnd));
%! ugal = u;
%! fname_out = tmpnam ();
%! printf ("saving results to %s \n", strcat (fname_out, ".vtu"));
%! fpl_vtk_raw_write_field (fname_out, msh, {uosc, "u_osc"; ugal, "u_galerkin"}, {});
%! unlink (fname);

%!demo
%! gmsh_input = [["Point(1) = {0, 0, 0, .1};      \n"], ...
%! ["Point(2) = {1, 0, 0, .1};                    \n"], ...
%! ["Point(3) = {0, -.3, 0, .1};                  \n"], ...
%! ["Point(4) = {0, +.3, 0, .1};                  \n"], ...
%! ["Point(5) = {1, -.3, 0, .1};                  \n"], ...
%! ["Point(6) = {1, 0.3, 0, .1};                  \n"], ...
%! ["Point(7) = {0, 0, -.3, .1};                  \n"], ...
%! ["Point(8) = {0, 0, +.3, .1};                  \n"], ...
%! ["Point(9) = {1, 0, -.3, .1};                  \n"], ...
%! ["Point(10) = {1, 0, 0.3, .1};                 \n"], ...
%! ["Circle(1) = {4, 1, 7};                       \n"], ...
%! ["Circle(2) = {7, 1, 3};                       \n"], ...
%! ["Circle(3) = {3, 1, 8};                       \n"], ...
%! ["Circle(4) = {8, 1, 4};                       \n"], ...
%! ["Circle(5) = {6, 2, 9};                       \n"], ...
%! ["Circle(6) = {9, 2, 5};                       \n"], ...
%! ["Circle(7) = {5, 2, 10};                      \n"], ...
%! ["Circle(8) = {10, 2, 6};                      \n"], ...
%! ["Line(9) = {4, 6};                            \n"], ...
%! ["Line(10) = {3, 5};                           \n"], ...
%! ["Line(11) = {8, 10};                          \n"], ...
%! ["Line(12) = {7, 9};                           \n"], ...
%! ["Line Loop(13) = {4, 1, 2, 3};                \n"], ...
%! ["Plane Surface(14) = {13};                    \n"], ...
%! ["Line Loop(15) = {5, 6, 7, 8};                \n"], ...
%! ["Plane Surface(16) = {15};                    \n"], ...
%! ["Line Loop(17) = {9, -8, -11, 4};             \n"], ...
%! ["Ruled Surface(18) = {17};                    \n"], ...
%! ["Line Loop(19) = {12, -5, -9, 1};             \n"], ...
%! ["Ruled Surface(20) = {19};                    \n"], ...
%! ["Line Loop(21) = {12, 6, -10, -2};            \n"], ...
%! ["Ruled Surface(22) = {21};                    \n"], ...
%! ["Line Loop(23) = {11, -7, -10, 3};            \n"], ...
%! ["Ruled Surface(24) = {23};                    \n"], ...
%! ["Surface Loop(25) = {18, 20, 22, 16, 24, 14}; \n"], ...
%! ["Volume(26) = {25};                           \n"]];
%! fname = tmpnam (); 
%! [fid, msg] = fopen (strcat (fname, ".geo"), "w");
%! if (fid < 0); error (msg); endif
%! fputs (fid, gmsh_input);
%! fclose (fid); 
%! msh = bim3c_mesh_properties (msh3m_gmsh (fname, "clscale", ".25"));
%! x = msh.p (1, :).';
%! u = x;
%! bnd = bim3c_unknowns_on_faces (msh, [14, 16]);
%! int = setdiff (1:columns (msh.p), bnd);
%! Mosc = bim3a_osc_advection_diffusion (msh, 1, msh.p(1,:)'*0);
%! Mgal = bim3a_advection_diffusion (msh, 1, msh.p(1,:)'*0);
%! f = bim3a_rhs (msh, 10, 1);
%! u(int) = Mosc(int, int) \ (f(int) - Mosc(int, bnd) * u(bnd));
%! uosc = u;
%! u(int) = Mgal(int, int) \ (f(int) - Mgal(int, bnd) * u(bnd));
%! ugal = u;
%! fname_out = tmpnam ();
%! printf ("saving results to %s \n", strcat (fname_out, ".vtu"));
%! fpl_vtk_raw_write_field (fname_out, msh, {uosc, "u_osc"; ugal, "u_galerkin"}, {});
%! unlink (fname);
