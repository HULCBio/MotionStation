function tightmap(style)

%TIGHTMAP removes whitespace around a map
% 
%   TIGHTMAP sets the MATLAB axis limits to be tight around the map in the 
%   current axes.  This eliminates or reduces the white border between the 
%   map frame and the axes box.  Use AXIS AUTO to undo TIGHTMAP.
%   
%   See also PANZOOM, ZOOM, PAPERSCALE, AXESSCALE, PREVIEWMAP

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:22:59 $


if nargin == 0
   style = 'tight';
end

switch style
case 'tight'
   param = 0;
case 'loose'
   param = 1;
otherwise
   error('Style must be ''tight'' or ''loose''')
end


hframe = handlem('Frame');
newframe = 0;
if isempty(hframe)
	hframe = framem;
	newframe = 1;
end

xframe = get(hframe,'Xdata');
yframe = get(hframe,'Ydata');   

% remove spurious zero at end of frame (was converted from NaN - PC matlab bug?)
xframe(end) = []; 
yframe(end) = [];

xdiff = max(xframe) - min(xframe);
ydiff = max(yframe) - min(yframe);

xlim([min(xframe) max(xframe)] + param*xdiff/100*[-1 1])
ylim([min(yframe) max(yframe)] + param*ydiff/100*[-1 1])

if newframe; delete(hframe); end  % to toggle state back to what it was


