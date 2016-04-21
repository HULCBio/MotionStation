function [Fx,Fy]=Ufvsgcurrent3(mesh,u,alpha,gamma,eta,beta);

  
  ## -*- texinfo -*-
  ##
  ## @deftypefn {Function File} {[@var{jx},@var{jy}]} = Ufvsgcurrent3 @
  ## (@var{mesh}, @var{u}, @var{alpha}, @var{gamma}, @var{eta}, @var{beta});
  ##
  ##
  ## Builds the Scharfetter-Gummel approximation of the vector  
  ## field 
  ##
  ## @iftex 
  ## @tex
  ## $ \vect{J}(u) = \alpha \gamma (\eta\vect{\nabla}u-\vect{beta}u) $
  ## @end tex 
  ## @end iftex 
  ## @ifinfo
  ## J(@var{u}) = @var{alpha}* @var{gamma} * (@var{eta} * grad @var{u} - @var{beta} * @var{u}))
  ## @end ifinfo
  ## 
  ## where: 
  ## @itemize @minus
  ## @item @var{alpha} is an element-wise constant scalar function
  ## @item @var{eta}, @var{u}, @var{gamma} are piecewise linear 
  ## conforming scalar functions
  ## @item @var{beta}  is an element-wise constant vector function
  ## @end itemize
  ##
  ## J(@var{u}) is an element-wise constant vector function
  ##
  ## Instead of passing the vector field @var{beta} directly
  ## one can pass a piecewise linear conforming scalar function
  ## @var{phi} as the last input.  In such case @var{beta} = grad @var{phi}
  ## is assumed.  If @var{phi} is a single scalar value @var{beta}
  ## is assumed to be 0 in the whole domain.
  ##
  ## @seealso{Uscharfettergummel3}
  ## @end deftypefn

  %% This file is part of 
  %%
  %%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
  %%         -------------------------------------------------------------------
  %%            Copyright (C) 2004-2006  Carlo de Falco
  %%
  %%
  %%
  %%  SECS2D is free software; you can redistribute it and/or modify
  %%  it under the terms of the GNU General Public License as published by
  %%  the Free Software Foundation; either version 2 of the License, or
  %%  (at your option) any later version.
  %%
  %%  SECS2D is distributed in the hope that it will be useful,
  %%  but WITHOUT ANY WARRANTY; without even the implied warranty of
  %%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  %%  GNU General Public License for more details.
  %%
  %%  Youx should have received a copy of the GNU General Public License
  %%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
  
  Nelem  = columns(mesh.t);
  Nnodes = columns(mesh.p);

  uloc      = u(mesh.t(1:3,:));

  shgx = reshape(mesh.shg(1,:,:),3,Nelem);
  shgy = reshape(mesh.shg(2,:,:),3,Nelem);

  x      = reshape(mesh.p(1,mesh.t(1:3,:)),3,[]);
  dx     = [ (x(3,:)-x(2,:)) ; 
	    (x(1,:)-x(3,:)) ;
	    (x(2,:)-x(1,:)) ];

  y      = reshape(mesh.p(2,mesh.t(1:3,:)),3,[]);
  dy     = [ (y(3,:)-y(2,:)) ; 
	    (y(1,:) -y(3,:)) ;
	    (y(2,:) -y(1,:)) ];
  
  ##ei     = sqrt( dx.^2 + dy.^2 );

  if all(size(beta)==1)
    v12=0;v23=0;v31=0;
  elseif all(size(beta)==[2,Nelem])
    v23    = beta(1,:) .* dx(1,:) + beta(2,:) .* dy(1,:);
    v31    = beta(1,:) .* dx(2,:) + beta(2,:) .* dy(2,:);
    v12    = beta(1,:) .* dx(3,:) + beta(2,:) .* dy(3,:);
  elseif all(size(beta)==[Nnodes,1])
    betaloc = beta(mesh.t(1:3,:));
    v23    = betaloc(3,:)-betaloc(2,:);
    v31    = betaloc(1,:)-betaloc(3,:);
    v12    = betaloc(2,:)-betaloc(1,:);
  end
  
  etaloc = eta(mesh.t(1:3,:));
  
  eta23    = etaloc(3,:)-etaloc(2,:);
  eta31    = etaloc(1,:)-etaloc(3,:);
  eta12    = etaloc(2,:)-etaloc(1,:);
  
  etalocm1 = Utemplogm(etaloc(2,:),etaloc(3,:));
  etalocm2 = Utemplogm(etaloc(3,:),etaloc(1,:));
  etalocm3 = Utemplogm(etaloc(1,:),etaloc(2,:));
  
  gammaloc = gamma(mesh.t(1:3,:));
  geloc      = gammaloc.*etaloc;
  
  gelocm1 = Utemplogm(geloc(2,:),geloc(3,:));
  gelocm2 = Utemplogm(geloc(3,:),geloc(1,:));
  gelocm3 = Utemplogm(geloc(1,:),geloc(2,:));
  
  [bp23,bm23] = Ubern( (v23 - eta23)./etalocm1);
  [bp31,bm31] = Ubern( (v31 - eta31)./etalocm2);
  [bp12,bm12] = Ubern( (v12 - eta12)./etalocm3);

  gfigfj = [ shgx(3,:) .* shgx(2,:) + shgy(3,:) .* shgy(2,:) ;
	    shgx(1,:) .* shgx(3,:) + shgy(1,:) .* shgy(3,:) ;
	    shgx(2,:) .* shgx(1,:) + shgy(2,:) .* shgy(1,:) ];

  Fx = - alpha' .* ( gelocm1 .* etalocm1 .* dx(1,:) .*  ...         
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
		   
  Fy = - alpha' .* ( gelocm1 .* etalocm1 .* dy(1,:) .*  ...         
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
