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

%  mesh=Ujoinmeshes(mesh1,mesh2,side1,side2)
% Join two structured 3d meshes.

function mesh=Ujoinmeshes(mesh1,mesh2,s1,s2)

% make sure that the outside world is always 
% on the same side of the boundary of mesh1
[mesh1.e(8:9,:),I] = sort(mesh1.e(8:9,:));
%% NYI!! If the regions are inverted the vertex order
%% should also be inverted!!


% get interface nodes
intnodes1= Ugetnodesonface(mesh1,s1)';
intnodes2= Ugetnodesonface(mesh2,s2)';

% sort interface nodes by position
[tmp,I] = sort(mesh1.p(1,intnodes1));
intnodes1 = intnodes1(I);
[tmp,I] = sort(mesh1.p(2,intnodes1));
intnodes1 = intnodes1(I);
[tmp,I] = sort(mesh1.p(3,intnodes1));
intnodes1 = intnodes1(I);

[tmp,I] = sort(mesh2.p(1,intnodes2));
intnodes2 = intnodes2(I);
[tmp,I] = sort(mesh2.p(2,intnodes2));
intnodes2 = intnodes2(I);
[tmp,I] = sort(mesh2.p(3,intnodes2));
intnodes2 = intnodes2(I);

% delete redundant boundary faces
% but first remeber what region
% they were connected to
for is = 1:length(s2)
  ii           = find(mesh2.e(10,:)==s2(is));
  adreg(is,:)  = unique(mesh2.e(9,ii)); 
end
for is=1:length(s2)
  mesh2.e(:,find(mesh2.e(10,:)==s2(is))) = [];
end

% change face numbers
indici=[];consecutivi=[];
indici = unique(mesh2.e(10,:));
consecutivi (indici) = [1:length(indici)]+max(mesh1.e(10,:));
mesh2.e(10,:)=consecutivi(mesh2.e(10,:));


% change node indices in connectivity matrix
% and edge list
indici=[];consecutivi=[];
indici  = 1:size(mesh2.p,2);
offint  = setdiff(indici,intnodes2);
consecutivi (offint) = [1:length(offint)]+size(mesh1.p,2);
consecutivi (intnodes2) = intnodes1;
mesh2.e(1:3,:)=consecutivi(mesh2.e(1:3,:));
mesh2.t(1:4,:)=consecutivi(mesh2.t(1:4,:));


% delete redundant points
mesh2.p(:,intnodes2) = [];

% set region numbers
regions = unique(mesh1.t(5,:));
newregions(regions) = 1:length(regions);
mesh1.t(5,:) = newregions(mesh1.t(5,:));

% set region numbers
regions = unique(mesh2.t(5,:));
newregions(regions) = [1:length(regions)]+max(mesh1.t(5,:));
mesh2.t(5,:) = newregions(mesh2.t(5,:));

% set adjacent region numbers in face structure 2
[i,j] = find(mesh2.e(8:9,:));
i = i+7;
mesh2.e(i,j) = newregions(mesh2.e(i,j));
% set adjacent region numbers in edge structure 1

for is = 1:length(s1)
  ii            = find(mesh1.e(10,:)==s1(is));
  mesh1.e(8,ii) = newregions(regions(adreg(is,:)));
end

% make the new p structure
mesh.p = [mesh1.p mesh2.p];
mesh.e = [mesh1.e mesh2.e];
mesh.t = [mesh1.t mesh2.t];

% 
% %double check to avoid degenerate triangles
% [p,ii,jj]=unique(mesh.p(1:2,:)','rows');
% mesh.p =p';
% mesh.e(1:2,:)=jj(mesh.e(1:2,:));
% mesh.t(1:3,:)=jj(mesh.t(1:3,:));
% 
% [ii,jj] = find (mesh.e(1,:)==mesh.e(2,:));
% mesh.e(:,jj) = [];
% [ii,jj] = find ((mesh.t(1,:)==mesh.t(2,:))|(mesh.t(1,:)==mesh.t(3,:))|(mesh.t(3,:)==mesh.t(2,:)));
% mesh.t(:,jj) = [];

