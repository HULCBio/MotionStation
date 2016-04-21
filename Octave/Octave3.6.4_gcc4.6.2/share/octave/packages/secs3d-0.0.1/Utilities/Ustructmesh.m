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
% [omesh]=Ustructmesh(x,y,z,region,sides)
%
% Construct a structured mesh of a parallelepiped.
%

function [omesh]=Ustructmesh(x,y,z,region,sides)

% sort point coordinates
x = sort(x);
y = sort(y);
z = sort(z);

nx = length(x);
ny = length(y);
nz = length(z);

% generate verticeces
[XX,YY,ZZ] = meshgrid(x,y,z);
p = [XX(:),YY(:),ZZ(:)]';

iiv (ny,nx,nz)=0;
iiv(:)=1:nx*ny*nz;
iiv(end,:,:)=[];
iiv(:,end,:)=[];
iiv(:,:,end)=[];
iiv=iiv(:)';

% generate connections:

% bottom faces
n1 = iiv;
n2 = iiv + 1;
n3 = iiv + ny;
n4 = iiv + ny + 1;

% top faces
N1 = iiv + nx * ny;
N2 = N1  + 1;
N3 = N1  + ny;
N4 = N3  + 1;

t = [...
    [n1; n3; n2; N2],...
    [N1; N2; N3; n3],...
    [N1; N2; n3; n1],...
    [N2; n3; n2; n4],...
    [N3; n3; N2; N4],...
    [N4; n3; N2; n4],...
    ];

% generate boundary face list:

% left
T       = t;
T(:)    = p(1,t)'==x(1);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e1(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e1(10,:) = sides(1);

% right
T(:)    = p(1,t)'==x(end);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e2(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e2(10,:) = sides(2);

% front
T(:)    = p(2,t)'==y(1);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e3(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e3(10,:) = sides(3);

% back
T(:)    = p(2,t)'==y(end);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e4(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e4(10,:) = sides(4);

% bottom
T       = t;
T(:)    = p(3,t)'==z(1);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e5(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e5(10,:) = sides(5);

% top
T       = t;
T(:)    = p(3,t)'==z(end);
[ignore,order] = sort(T,1);
ii      = (find(sum(T,1)==3));
order(1,:) = [];
for jj=1:length(ii)
  e6(:,jj)      = t(order(:,ii(jj)),ii(jj));
end
e6(10,:) = sides(6);


omesh.e       = [e1,e2,e3,e4,e5,e6];
omesh.t       = t;
omesh.e (9,:) = region;
omesh.t (5,:) = region;
omesh.p       = p;

