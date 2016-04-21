function nextmap

%NEXTMAP  Readies a map axes for the next object
%
%  NEXTMAP readies a map axes for the next map object.
%  If the hold state is off, NEXTMAP will also clear
%  the current map before the next object is displayed.
%
%  See also CLMA

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.1.6.1 $    $Date: 2003/12/13 02:55:22 $


%  Clear the map, but not the frame,
%  if a hold on has not been issued

if ismap
     if strcmp(get(gca,'NextPlot'),'replace');    clmo('map');    end
end

