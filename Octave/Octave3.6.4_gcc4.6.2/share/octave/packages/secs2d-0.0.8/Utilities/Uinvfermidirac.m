function [fd]=Uinvfermidirac(eta,par);

%  [fd]=Uinvfermidirac(eta,par);

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

% reshape eta into a sorted vector
s = size(eta);
eta = eta(:);
[eta,order] = sort(eta);

limits = Ufermidirac([-18,18],par);
low  = limits(1);
high = limits(2);

etalow  = find(eta<=low);
etahigh = find(eta>=high);
etamid  = find((eta<high)&(eta>low));

switch par
case 1/2    
    load fdhalf;
    fd(etalow) =log(eta(etalow));
    fd(etahigh)=(eta(etahigh)*3*sqrt(pi)/4).^(2/3);
    if length(etamid)
        fd(etamid) =log(linterp(a(:,2),exp(a(:,1)),eta(etamid)));
    end
case -1/2    
    load fdmhalf;
    fd(etalow) =log(eta(etalow));
    fd(etahigh)=pi*(eta(etahigh).^2)/4;
    if length(etamid)
        fd(etamid) =log(linterp(a(:,2),exp(a(:,1)),eta(etamid)));
    end
otherwise
    error(['wrong parameter: par=' num2str(par)])
    return
end


% give answer in original order and shape
fd(order) = fd;
fd = reshape(fd,s);
