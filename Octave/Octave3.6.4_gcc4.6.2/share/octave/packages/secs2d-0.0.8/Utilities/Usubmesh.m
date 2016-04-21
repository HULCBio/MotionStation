function [omesh,onodes,oelements]=Usubmesh(imesh,intrfc,sdl,short)

#
#  [omesh,onodes,oelements]=Usubmesh(imesh,intrfc,sdl,short)
#
# builds the mesh structure for
# the given list
# of subdomains sdl
#
# NOTE: the intrfc parameter is unused and only kept 
#       as a legacy



% This file is part of 
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; If not, see <http://www.gnu.org/licenses/>.





nsd = length(sdl);

#######
# the shp field will remain unchanged
if (~short)
    omesh.shp = imesh.shp;
end

#######
# set list of output triangles 
oelements=[];
for isd=1:nsd
	oelements = [oelements find(imesh.t(4,:)==sdl(isd))];
end

omesh.t = imesh.t(:,oelements);

#######
# discard unneeded part of shg and wjacdet
if (~short)
    omesh.shg= imesh.shg(:,:,oelements);
    omesh.wjacdet = imesh.wjacdet(:,oelements);
end

#######
# set list of output nodes
onodes          = unique(reshape(imesh.t(1:3,oelements),1,[]));
omesh.p         = imesh.p(:,onodes);


#######
# use new node numbering in connectivity matrix
indx(onodes) = [1:length(onodes)];
iel = [1:length(oelements)];
omesh.t(1:3,iel) = indx(omesh.t(1:3,iel));

#######
# set list of output edges
omesh.e =[];
for isd=1:nsd
	omesh.e = [omesh.e imesh.e(:,imesh.e(7,:)==sdl(isd))];
	omesh.e = [omesh.e imesh.e(:,imesh.e(6,:)==sdl(isd))];
end
omesh.e=unique(omesh.e',"rows")';

#######
# use new node numbering in boundary segment list
ied = [1:size(omesh.e,2)];
omesh.e(1:2,ied) = indx(omesh.e(1:2,ied));

% Last Revision:
% $Author: adb014 $
% $Date: 2008-02-04 16:26:27 +0100 (man, 04 feb 2008) $

