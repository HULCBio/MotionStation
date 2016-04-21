function [p,e,t]=Ustructmesh(x,y,region,sides,varargin)

% [p,e,t]=Ustructmesh(x,y,region,sides,varargin)

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

defaultoption = 'right';

if length(varargin)==0
    theoption = defaultoption;
else
    theoption = varargin{1};
end

[p,e,t]=feval(['Ustructmesh_' theoption],x,y,region,sides);
