%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

%
%  [omesh,onodes,oelements]=Usubmesh(imesh,intrfc,sdl,short)
%
% builds the mesh structure for the given list
% of subdomains sdl
%

function [omesh,onodes,oelements]=Usubmesh(imesh,intrfc,sdl,short)

oelements=[];
for ir = 1:length(sdl)
  oelements = [ oelements find(imesh.t(5,:)==sdl(ir)) ];
end

onodes = reshape(imesh.t(1:4,oelements),1,[]);
onodes = unique(onodes);

if (~short)
  omesh.shp     = imesh.shp;
  omesh.wjacdet = imesh.wjacdet(:,oelements);
  omesh.area    = imesh.area(oelements);
  omesh.shg     = imesh.shg(:,:,oelements);
end

omesh.p         = imesh.p  (:,onodes);
indx(onodes)    = 1:length (onodes);
omesh.t         = imesh.t  (:,oelements);
omesh.t(1:4,:)  = indx(omesh.t(1:4,:));

omesh.e  = [];
for ifac = 1:size(imesh.e,2)
  if (length(intersect(imesh.e(1:3,ifac),onodes) )== 3)
    omesh.e = [omesh.e imesh.e(:,ifac)];
  end
end

omesh.e(1:3,:)  = indx(omesh.e(1:3,:));

