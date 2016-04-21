function DDGOXplotresults(mesh,Simesh,n,p,V,Fn,Fp,gi,nrm,step);

%
% DDGOXplotresults(mesh,Simesh,n,p,V,Fn,Fp,gi,nrm,step);
%
%

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




f1=figure(1);
subplot(2,3,1)
Updesurf(Simesh,log10(n),'colormap','jet','mesh','off','contour','on');
title('Electron Density (log)'); grid; colorbar; view(2)

subplot(2,3,2)
Updesurf(Simesh,log10(p),'colormap','jet','mesh','off');
title('Hole Density (log)'); grid; colorbar; view(2)

subplot(2,3,4)
Updesurf(Simesh,Fn,'colormap','jet','mesh','off');
title('Electron QFL'); grid; colorbar; view(2)

subplot(2,3,5)
Updesurf(Simesh,Fp,'colormap','jet','mesh','off');
title('Hole QFL'); grid; colorbar; view(2)

subplot(1,3,3)
Updesurf(mesh,V,'colormap','jet','mesh','off');
title('Electric Potential'); grid; colorbar; view(2)
pause(.1)


