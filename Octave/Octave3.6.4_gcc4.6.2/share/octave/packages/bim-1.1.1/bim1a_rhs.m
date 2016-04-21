## Copyright (C) 2006,2007,2008,2009,2010  Carlo de Falco, Massimiliano Culpo
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
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{b}]} = @
## bim1a_rhs(@var{mesh},@var{f}, @var{g}) 
##
## Build the finite element right-hand side of a diffusion problem
## employing mass-lumping.
##
## The equation taken into account is:
##
## @var{delta} * u = f * g
## 
## where @var{f} is an element-wise constant scalar function, while
## @var{g} is a piecewise linear conforming scalar function.
## 
## @seealso{bim1a_reaction, bim1a_advection_diffusion, bim1a_laplacian,
## bim2a_reaction, bim3a_reaction}
## @end deftypefn

function b = bim1a_rhs(mesh,f,g)

  ## Check input
  if nargin != 3
    error("bim1a_rhs: wrong number of input parameters.");
  elseif !isvector(mesh)
    error("bim1a_rhs: first argument is not a valid vector.");
  endif

  mesh   = reshape(mesh,[],1);
  nnodes = length(mesh);
  nelem  = nnodes-1;

  ## Turn scalar input to a vector of appropriate size
  if isscalar(f)
    f = f*ones(nelem,1);
  endif
  if isscalar(g)
    g = g*ones(nnodes,1);
  endif

  if !( isvector(f) && isvector(g) )
    error("bim1a_rhs: coefficients are not valid vectors.");
  elseif (length(f) != nelem && length(f) != 1)
    error("bim1a_rhs: length of f is not equal to the number of elements.");
  elseif (length(g) != nnodes && length(g) != 1)
    error("bim1a_rhs: length of g is not equal to the number of nodes.");
  endif

  h = (mesh(2:end)-mesh(1:end-1)).*f;
  b = g.*[h(1)/2; (h(1:end-1)+h(2:end))/2; h(end)/2];

endfunction

%!test
%! x = linspace(0,1,101);
%! A = bim1a_rhs(x,1,1);
%! delta = ones(100,1);
%! zeta  = ones(101,1);
%! B = bim1a_rhs(x,delta,zeta);
%! assert(A,B)