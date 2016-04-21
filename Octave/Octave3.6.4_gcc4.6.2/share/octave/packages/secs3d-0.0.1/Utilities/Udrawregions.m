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

% Udrawregions(mesh,r)

function Udrawregions(mesh,r)

pct = mesh.p(1:3,:)';

nr  = length(r);

if r~=0
  wch=[];
  for ir=1:nr
    wch = union(wch,find(mesh.t(5,:)==r(ir)));
  end
  tet=mesh.t(1:4,wch)';
  col=mesh.t(5,wch)';
else
  tet=mesh.t(1:4,:)';
  col=mesh.t(5,:)';
end

tetramesh(tet,pct,col);%a! ,'linestyle','none');

nr   = max(col);
cm   = zeros(nr,3);
grad = linspace(0,1,nr)';
cm(:,1) = grad(randperm(nr));
cm(:,2) = grad(randperm(nr));
cm(:,3) = grad(randperm(nr));
colormap(cm)
colorbar('ytick',1:nr)
