function makemapped(h)
%MAKEMAPPED make an object a mapped object
%
% MAKEMAPPED(h) adds a Mapping Toolbox structure to the displayed objects 
% associated with h. h can be a handle, vector of handles, or any name string
% recognized by HANDLEM. The objects are then considered to be geographic 
% data. Objects extending outside the map frame should first be trimmed to the 
% map frame using TRIMCART.
%
% See also TRIMCART, HANDLEM, CART2GRN

% needs something special for patches, so they can be reprojected

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:18:46 $


if nargin < 1; error('Incorrect number of arguments'); end


if isstr(h); h = handlem(h); end

if ~ishandle(h); error('Inputs must be handles to graphics objects'); end

% ensure vectors

h = h(:);

% Remove objects from the list that are already mapped

lengthin = length(h);
for i=length(h):-1:1
	if ismapped(h(i)); h(i) = []; end 
end

% Warn about them
if ~isequal(length(h), lengthin)
	warning('Some objects already mapped')
end

% Add a mapping toolbox object structure
set(h,'UserData',struct('trimmed',[],'clipped',[]),'ButtonDownFcn','uimaptbx');


