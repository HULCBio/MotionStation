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
## {[@var{F}]} = @
## bim3c_global_flux (@var{mesh}, @var{u}, @var{alpha}, @var{v})
##
## Compute the flux associated with the Scharfetter-Gummel approximation
## of the scalar field @var{u}.
##
## The vector field is defined as:
##
## F =- @var{alpha} ( grad (u) - gard (@var{v}) u ) 
##
## where @var{v} is a piecewise linear continuous scalar
## functions and @var{alpha} is a piecewise constant scalar function.
##
## @seealso{bim3a_rhs, bim3a_reaction, bim3a_laplacian, bim3c_mesh_properties}
## @end deftypefn


function F = bim3c_global_flux (mesh, u, acoeff, v)

  t = mesh.t;
  nelem = columns(mesh.t);
  F = zeros (3, nelem);

  for iel = 1:nelem
    ## Local matrices
    Lloc = zeros(4,4); ## diffusion
    Sloc = zeros(4,4); ## advection-diffusion

    epsilonareak = acoeff(iel) .* mesh.area(iel);
    shg = mesh.shg(:,:,iel);    
    vloc = v(t(1:4, iel));
    uloc = u(t(1:4, iel));

    ## Computation
    for inode = 1:4
      for jnode = 1:4
        Lloc(inode, jnode)   = sum (shg(:, inode) .* shg(:, jnode)) .* epsilonareak;
      endfor
    endfor	

    ## SGloc=[...
    ##        -bm12-bm13-bm14,bp12            ,bp13           ,bp14     
    ##        bm12           ,-bp12-bm23-bm24 ,bp23           ,bp24
    ##        bm13           ,bm23            ,-bp13-bp23-bm34,bp34
    ##        bm14           ,bm24            ,bm34           ,-bp14-bp24-bp34...
    ##        ];
    
    for inode = 1:4
      for jnode = inode+1:4
        [Sloc(inode, jnode), Sloc(jnode, inode)] = bimu_bernoulli (vloc(jnode)-vloc(inode));
        Sloc(inode, jnode) *= Lloc(inode, jnode);
        Sloc(jnode, inode) *= Lloc(inode, jnode);
      endfor
    endfor

    for inode = 1:4
      Sloc(inode, inode) = - sum (Sloc (:, inode));
    endfor

   r = Sloc * uloc;
   f = Lloc(1:3, 1:3) \ r(1:3);

   F(:,iel) = shg(:,1:3) * f;

  endfor

endfunction

%!test
%! N = 10; pp = linspace (0, 1, N); msh = bim3c_mesh_properties (msh3m_structured_mesh (pp, pp, pp, 1, 1:6));
%! u = ones (N^3, 1);
%! v = ones (N^3, 1);
%! alpha = ones (columns (msh.t), 1);
%! F =  bim3c_global_flux (msh, u, alpha, v);
%! assert (norm (F(:), inf), 0, 100*eps);