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
## @deftypefn {Function File} {[@var{jx},@var{jy}]} = @
## bim2c_global_flux(@var{mesh},@var{u},@var{alpha},@var{gamma},@var{eta},@var{beta})
## 
## Compute the flux associated with the Scharfetter-Gummel approximation
## of the scalar field @var{u}.
##
## The vector field is defined as:
##
## J(@var{u}) = @var{alpha}* @var{gamma} * (@var{eta} * grad @var{u} - @var{beta} * @var{u}))
## 
## where @var{alpha} is an element-wise constant scalar function,
## @var{eta} and @var{gamma} are piecewise linear conforming scalar
## functions, while @var{beta} is element-wise constant vector function.
##
## J(@var{u}) is an element-wise constant vector function.
##
## Instead of passing the vector field @var{beta} directly one can pass
## a piecewise linear conforming scalar function  @var{phi} as the last
## input.  In such case @var{beta} = grad @var{phi}  is assumed.  If
## @var{phi} is a single scalar value @var{beta}  is assumed to be 0 in
## the whole domain.
##
## @seealso{bim2c_pde_gradient,bim2a_advection_diffusion}
## @end deftypefn

function [jx, jy] = bim2c_global_flux(mesh,u,alpha,gamma,eta,beta)

  ## Check input
  if nargin != 6
    error("bim2c_global_flux: wrong number of input parameters.");
  elseif !(isstruct(mesh)     && isfield(mesh,"p") &&
	   isfield (mesh,"t") && isfield(mesh,"e"))
    error("bim2c_global_flux: first input is not a valid mesh structure.");
  endif
  
  nnodes = columns(mesh.p);
  nelem  = columns(mesh.t);
  

  if !( isvector(u) && isvector(alpha) && isvector(gamma) && isvector(eta) )
    error("bim2c_global_flux: coefficients are not valid vectors.");
  elseif length(u) != nnodes
    error("bim2c_global_flux: length of u is not equal to the number of nodes.");
  elseif length(alpha) != nelem
    error("bim2c_global_flux: length of alpha is not equal to the number of elements.");
  elseif length(gamma) != nnodes
    error("bim2c_global_flux: length of gamma is not equal to the number of nodes.");
  elseif length(eta) != nnodes
    error("bim2c_global_flux: length of eta is not equal to the number of nodes.");
  endif

  nelem  = columns(mesh.t);
  nnodes = columns(mesh.p);

  uloc      = u(mesh.t(1:3,:));

  shgx = reshape(mesh.shg(1,:,:),3,nelem);
  shgy = reshape(mesh.shg(2,:,:),3,nelem);

  x      = reshape(mesh.p(1,mesh.t(1:3,:)),3,[]);
  dx     = [ (x(3,:)-x(2,:)) ; 
	    (x(1,:)-x(3,:)) ;
	    (x(2,:)-x(1,:)) ];

  y      = reshape(mesh.p(2,mesh.t(1:3,:)),3,[]);
  dy     = [ (y(3,:)-y(2,:)) ; 
	    (y(1,:) -y(3,:)) ;
	    (y(2,:) -y(1,:)) ];

  if all(size(beta)==1)
    v12=0;v23=0;v31=0;
  elseif all(size(beta)==[2,nelem])
    v23    = beta(1,:) .* dx(1,:) + beta(2,:) .* dy(1,:);
    v31    = beta(1,:) .* dx(2,:) + beta(2,:) .* dy(2,:);
    v12    = beta(1,:) .* dx(3,:) + beta(2,:) .* dy(3,:);
  elseif all(size(beta)==[nnodes,1])
    betaloc = beta(mesh.t(1:3,:));
    v23    = betaloc(3,:)-betaloc(2,:);
    v31    = betaloc(1,:)-betaloc(3,:);
    v12    = betaloc(2,:)-betaloc(1,:);
  else
    error("bim2c_global_flux: coefficient beta has wrong dimensions.");
  endif
  
  etaloc = eta(mesh.t(1:3,:));
  
  eta23    = etaloc(3,:)-etaloc(2,:);
  eta31    = etaloc(1,:)-etaloc(3,:);
  eta12    = etaloc(2,:)-etaloc(1,:);
  
  etalocm1 = bimu_logm(etaloc(2,:),etaloc(3,:));
  etalocm2 = bimu_logm(etaloc(3,:),etaloc(1,:));
  etalocm3 = bimu_logm(etaloc(1,:),etaloc(2,:));
  
  gammaloc = gamma(mesh.t(1:3,:));
  geloc      = gammaloc.*etaloc;
  
  gelocm1 = bimu_logm(geloc(2,:),geloc(3,:));
  gelocm2 = bimu_logm(geloc(3,:),geloc(1,:));
  gelocm3 = bimu_logm(geloc(1,:),geloc(2,:));
  
  [bp23,bm23] = bimu_bernoulli( (v23 - eta23)./etalocm1);
  [bp31,bm31] = bimu_bernoulli( (v31 - eta31)./etalocm2);
  [bp12,bm12] = bimu_bernoulli( (v12 - eta12)./etalocm3);

  gfigfj = [ shgx(3,:) .* shgx(2,:) + shgy(3,:) .* shgy(2,:) ;
	    shgx(1,:) .* shgx(3,:) + shgy(1,:) .* shgy(3,:) ;
	    shgx(2,:) .* shgx(1,:) + shgy(2,:) .* shgy(1,:) ];

  jx = - alpha' .* ( gelocm1 .* etalocm1 .* dx(1,:) .*  ...         
		    gfigfj(1,:) .* ...
		    ( bp23 .* uloc(3,:)./etaloc(3,:) -...
		     bm23 .* uloc(2,:)./etaloc(2,:)) +... %% 1 
		    gelocm2 .* etalocm2 .* dx(2,:) .*  ...
		    gfigfj(2,:) .* ...
		    (bp31 .* uloc(1,:)./etaloc(1,:) -...
		     bm31 .* uloc(3,:)./etaloc(3,:)) +... %% 2
		    gelocm3 .* etalocm3 .* dx(3,:) .* ...
		    gfigfj(3,:) .* ...
		    (bp12 .* uloc(2,:)./etaloc(2,:) -...
		     bm12 .* uloc(1,:)./etaloc(1,:)) ... %% 3
		   );
		   
  jy = - alpha' .* ( gelocm1 .* etalocm1 .* dy(1,:) .*  ...         
		    gfigfj(1,:) .* ...
		    ( bp23 .* uloc(3,:)./etaloc(3,:) -...
		     bm23 .* uloc(2,:)./etaloc(2,:)) +... %% 1 
		    gelocm2 .* etalocm2 .* dy(2,:) .*  ...
		    gfigfj(2,:) .* ...
		    (bp31 .* uloc(1,:)./etaloc(1,:) -...
		     bm31 .* uloc(3,:)./etaloc(3,:)) +... %% 2
		    gelocm3 .* etalocm3 .* dy(3,:) .* ...
		    gfigfj(3,:) .* ...
		    (bp12 .* uloc(2,:)./etaloc(2,:) -...
		     bm12 .* uloc(1,:)./etaloc(1,:)) ... %% 3
		    );
endfunction