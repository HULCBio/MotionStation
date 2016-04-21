function mesh=Ujoinmeshes(mesh1,mesh2,s1,s2)

%  mesh=Ujoinmeshes(mesh1,mesh2,side1,side2)

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


% make sure that the outside world is always 
% on the same side of the boundary of mesh1
[mesh1.e(6:7,:),I] = sort(mesh1.e(6:7,:));
for ic=1:size(mesh1.e,2)
    mesh1.e(1:2,ic) = mesh1.e(I(:,ic),ic);
end

intnodes1=[];
intnodes2=[];


j1=[];j2=[];
for is=1:length(s1)    
    side1 = s1(is);side2 = s2(is);
    [i,j] = find(mesh1.e(5,:)==side1);
    j1=[j1 j];
    [i,j] = find(mesh2.e(5,:)==side2);
    oldregion(side1) = max(max(mesh2.e(6:7,j)));
    j2=[j2 j];
end

intnodes1=[mesh1.e(1,j1),mesh1.e(2,j1)];
intnodes2=[mesh2.e(1,j2),mesh2.e(2,j2)];

intnodes1 = unique(intnodes1);
[tmp,I] = sort(mesh1.p(1,intnodes1));
intnodes1 = intnodes1(I);
[tmp,I] = sort(mesh1.p(2,intnodes1));
intnodes1 = intnodes1(I);

intnodes2 = unique(intnodes2);
[tmp,I] = sort(mesh2.p(1,intnodes2));
intnodes2 = intnodes2(I);
[tmp,I] = sort(mesh2.p(2,intnodes2));
intnodes2 = intnodes2(I);

% delete redundant edges
mesh2.e(:,j2) = [];

% change edge numbers
indici=[];consecutivi=[];
indici = unique(mesh2.e(5,:));
consecutivi (indici) = [1:length(indici)]+max(mesh1.e(5,:));
mesh2.e(5,:)=consecutivi(mesh2.e(5,:));


% change node indices in connectivity matrix
% and edge list
indici=[];consecutivi=[];
indici  = 1:size(mesh2.p,2);
offint  = setdiff(indici,intnodes2);
consecutivi (offint) = [1:length(offint)]+size(mesh1.p,2);
consecutivi (intnodes2) = intnodes1;
mesh2.e(1:2,:)=consecutivi(mesh2.e(1:2,:));
mesh2.t(1:3,:)=consecutivi(mesh2.t(1:3,:));


% delete redundant points
mesh2.p(:,intnodes2) = [];

% set region numbers
regions = unique(mesh1.t(4,:));
newregions(regions) = 1:length(regions);
mesh1.t(4,:) = newregions(mesh1.t(4,:));

% set region numbers
regions = unique(mesh2.t(4,:));
newregions(regions) = [1:length(regions)]+max(mesh1.t(4,:));
mesh2.t(4,:) = newregions(mesh2.t(4,:));
% set adjacent region numbers in edge structure 2
[i,j] = find(mesh2.e(6:7,:));
i = i+5;
mesh2.e(i,j) = newregions(mesh2.e(i,j));
% set adjacent region numbers in edge structure 1
mesh1.e(6,j1) = newregions(oldregion(mesh1.e(5,j1)));

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


