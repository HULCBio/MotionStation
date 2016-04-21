## Copyright (C) 2010  Carlo de Falco
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
##
## @deftypefn {Function File} @
## {[@var{A}]} = bim1a_advection_upwind (@var{mesh}, @var{beta})
##
## Build the UW stabilized stiffness matrix for an advection problem. 
## 
## The equation taken into account is:
##
##  (@var{beta} u)' = f
##
## where @var{beta} is an element-wise constant.
##
## Instead of passing the vector field @var{beta} directly one can pass
## a piecewise linear conforming scalar function  @var{phi} as the last
## input.  In such case @var{beta} = grad @var{phi} is assumed.
##
## If @var{phi} is a single scalar value @var{beta} is assumed to be 0
## in the whole domain. 
##
## @seealso{bim1a_rhs, bim1a_reaction, bim1a_laplacian, bim2a_advection_diffusion} 
## @end deftypefn

function A = bim1a_advection_upwind (x, beta)

  ## Check input
  if nargin != 2
    error("bim1a_advection_upwind: wrong number of input parameters.");
  endif
  
  nnodes = length(x);
  nelem  = nnodes-1;

  areak = reshape(diff(x),[],1);
 
  if (length(beta) == 1)
    vk = 0;
  elseif (length(beta) == nelem)
    vk = beta .* areak; 
  elseif (length(beta) == nnodes)
    vk = diff(beta);
  else
    error("bim1a_advection_upwind: coefficient beta has wrong dimensions.");
  endif
  
  ck  =  2./([0; areak(2:end)]+[areak(1:end-1); 0]);
  bmk =  (vk+abs(vk))/2;
  bpk = -(vk-abs(vk))/2;
 
  dm1 = [-(ck.*bmk); NaN]; 
  dp1 = [NaN; -(ck.*bpk)]; 
  d0  = [(ck(1).*bmk(1)); ((ck.*bmk)(2:end) + (ck.*bpk)(1:end-1)); (ck(end).*bpk(end))];
  A   = spdiags([dm1, d0, dp1],-1:1,nnodes,nnodes);

endfunction
