function loadcape

%LOADCAPE load Cape Cod elevation image into a regular matrix map

% $Revision: 1.11.4.1 $
% Written by W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.

load cape
cmap = map; clear map;
maplegend = [120    44   -72];
map = flipud(X); clear X
map(map==1) = -1;	% to get sea colored correctly

assignin('caller','map',map)
assignin('caller','maplegend',maplegend)
assignin('caller','cmap',cmap)
assignin('caller','caption',caption)

