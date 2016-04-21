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

% Udrawfaces(mesh,sides)

function Udrawfaces(mesh,sides)

nsides = max(sides);
%max(mesh.e(10,:));
% nfaces = size(mesh.e,2);
% for ifac = 1:nfaces
%     if (sides==0 | ismember(mesh.e(10,ifac),sides))
%         patch(mesh.p(1,mesh.e(1:3,ifac)),...
%             mesh.p(2,mesh.e(1:3,ifac)),...
%             mesh.p(3,mesh.e(1:3,ifac)),...
%             mesh.e(10,ifac),...
%             'linestyle','none');
%     end
%     hold on
% end

[yesno]=ismember(mesh.e(10,:),sides);
where = find(yesno);
patch(reshape(mesh.p(1,mesh.e(1:3,where)),3,[]),...
      reshape(mesh.p(2,mesh.e(1:3,where)),3,[]),...
      reshape(mesh.p(3,mesh.e(1:3,where)),3,[]),mesh.e(10,where));


% cm   = zeros(nsides+1,3);
% grad = linspace(0,1,nsides+1)';
% cm(:,1) = grad(1+randperm(nsides));
% cm(:,2) = grad(1+randperm(nsides));
% cm(:,3) = grad(1+randperm(nsides));
% colormap(cm)
colorbar
%colorbar('ytick',1:nsides)

% figure(2)
% xbase=0;
% done=[];
% for ii=1:nfaces
%     if ((sides==0 | ismember(mesh.e(10,ii),sides))& ~ismember(mesh.e(10,ii),done))
%         patch(xbase+[0,1,1,0],[0,0,1,1],cm(mesh.e(10,ii),:))
%         hold on
%         
%         text(xbase+.5,.5,num2str(mesh.e(10,ii)));
%         xbase = xbase +1;
%         done = [done mesh.e(10,ii)];
%     end
% end

xlabel('x'),ylabel('y'),zlabel('z')
