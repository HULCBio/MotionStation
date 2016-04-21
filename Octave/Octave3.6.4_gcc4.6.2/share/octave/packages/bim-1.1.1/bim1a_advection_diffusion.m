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
##
## @deftypefn {Function File} @
## {[@var{A}]} = @
## bim1a_advection_diffusion(@var{mesh},@var{alpha},@var{gamma},@var{eta},@var{beta})
##
## Build the Scharfetter-Gummel stabilized stiffness matrix for a
## diffusion-advection problem. 
## 
## The equation taken into account is:
##
## - div (@var{alpha} * @var{gamma} (@var{eta} grad (u) - @var{beta} u)) = f
##
## where @var{alpha} is an element-wise constant scalar function,
## @var{eta} and @var{gamma} are piecewise linear conforming scalar
## functions, @var{beta} is an element-wise constant vector function.
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

function A = bim1a_advection_diffusion (x,alpha,gamma,eta,beta)

  ## Check input
  if nargin != 5
    error("bim1a_advection_diffusion: wrong number of input parameters.");
  elseif !isvector(x)
    error("bim1a_advection_diffusion: first argument is not a valid vector.");
  endif
  
  nnodes = length(x);
  nelem  = nnodes-1;

  ## Turn scalar input to a vector of appropriate size
  if isscalar(alpha)
    alpha = alpha*ones(nelem,1);
  endif
  if isscalar(gamma)
    gamma = gamma*ones(nnodes,1);
  endif
  if isscalar(eta)
    eta = eta*ones(nnodes,1);
  endif
  
  if !( isvector(alpha) && isvector(gamma) && isvector(eta) )
    error("bim1a_advection_diffusion: coefficients are not valid vectors.");
  elseif (length(alpha) != nelem)
    error("bim1a_advection_diffusion: length of alpha is not equal to the number of elements.");
  elseif (length(gamma) != nnodes)
    error("bim1a_advection_diffusion: length of gamma is not equal to the number of nodes.");
  elseif (length(eta) != nnodes)
    error("bim1a_advection_diffusion: length of eta is not equal to the number of nodes.");
  endif

  areak = reshape(diff(x),[],1);
 
  if (length(beta) == 1)
    vk = 0;
  elseif (length(beta) == nelem)
    vk = beta .* areak;
  elseif (length(beta) == nnodes)
    vk = diff(beta);
  else
    error("bim1a_advection_diffusion: coefficient beta has wrong dimensions.");
  endif
  
  gammaetak = bimu_logm ( (gamma.*eta)(1:end-1), (gamma.*eta)(2:end));
  veta      = diff(eta);
  etak      = bimu_logm ( eta(1:end-1), eta(2:end));
  ck        = alpha .* gammaetak .* etak ./ areak; 

  [bpk, bmk]  = bimu_bernoulli( (vk - veta)./etak);
 
  dm1 = [-(ck.*bmk); NaN]; 
  dp1 = [NaN; -(ck.*bpk)]; 
  d0  = [(ck(1).*bmk(1)); ((ck.*bmk)(2:end) + (ck.*bpk)(1:end-1)); (ck(end).*bpk(end))];
  A   = spdiags([dm1, d0, dp1],-1:1,nnodes,nnodes);

endfunction

%!test
%! x = linspace(0,1,101);
%! A = bim1a_advection_diffusion(x,1,1,1,0);
%! alpha = ones(100,1);
%! gamma = ones(101,1);
%! eta   = gamma;
%! B = bim1a_advection_diffusion(x,alpha,gamma,eta,0);
%! assert(A,B)