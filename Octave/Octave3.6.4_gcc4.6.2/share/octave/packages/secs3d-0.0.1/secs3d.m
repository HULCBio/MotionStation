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

# Run this only if the package is installed
## PKG_ADD: if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_ADD:  dirlist= {"Utilities", "DDG", "DDGOX", "DDGt", "QDDGOX", "data/CMOS"};
## PKG_ADD:  for ii=1:length(dirlist)
## PKG_ADD:     addpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}]);
## PKG_ADD:  end
## PKG_ADD: end

# Run this only if the package is installed
## PKG_DEL: if (! exist (fullfile (fileparts (mfilename ("fullpath")), "inst"), "dir"))
## PKG_DEL:  dirlist= {"Utilities", "DDG", "DDGOX", "DDGt", "QDDGOX", "data/CMOS"};
## PKG_DEL:  for ii=1:length(dirlist)
## PKG_DEL:     rmpath ( [ fileparts( mfilename("fullpath")) "/" dirlist{ii}]);
## PKG_DEL:  end
## PKG_DEL: end
