function A = doresize(A)
%FIGOBJ/DORESIZE Resize for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.14.4.1 $  $Date: 2004/01/15 21:12:35 $

% Don't resize legend for ScribeCopyBufferFig
if ~strcmp(get(A,'Tag'),'ScribeCopyBufferFig')
    legend ResizeLegend;
end

HG = get(A,'MyHGHandle');

arrows = findall(HG,'Tag','ScribeArrowlineObject');
for a = arrows'
   set(getobj(a),'Refresh','');
end

%find doesn't work with hidden handles yet, so we have
%to find children of the axes
axH=findall(HG,'type','axes');
arrows = double(find(handle(axH),'-class','graph2d.arrow'));
for a = arrows'
   set(getobj(a),'Refresh','');
end
