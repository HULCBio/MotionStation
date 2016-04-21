function A = dodrag(A)
%SCRIBEHGOBJ/DODRAG Drag scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/15 21:13:24 $

% get my position

figH = gcbf; oldFigUnits = get(figH,'Units');
oldAxUnits = get(A,'Units');

set(figH,'Units','pixels');
myFigPos = get(figH,'Position');


set(A,'Units','pixels');
pos = get(A,'Position');

% call dragrect
pos = dragrect(pos);

% get the ending position in screen coordinates
screenPtPos = myFigPos(1:2) + get(figH,'CurrentPoint');

% look for other figure windows
oldUnits = get(0,'Units');
set(0,'Units','pixels');
figs = findobj('Type','figure','Visible','on');
% returned in stacking order
vOtherFigPos = get(figs,'Position');

% is the current point within the current figure
if IsInRect(myFigPos, screenPtPos)
   % do the normal thing
   A = set(A,'Position',pos);
else
   for i = 1:length(vOtherFigPos)
      if IsInRect(vOtherFigPos{i}, screenPtPos)
		 theDropFig = figs(i);
		 % drop
		 % should check whether the parent is a fig, then set
		 % parent accordingly
		 set(A,'Parent', figs(i));
		 otherpos = vOtherFigPos{i};
		 newPos = pos + [myFigPos(1:2) 0 0] - [otherpos(1:2) 0 0];
		 set(A,'Position', newPos);
		 break;
      end
   end
end
   
% is the current point within a different figure?


% restore original units
set(figH,'Units',oldFigUnits);
set(0,'Units',oldUnits);

% update my position
A = set(A,'Units',oldAxUnits);


function hit = IsInRect(rect,pt)
% ISINRECT Local function

% rect = [l b w h]
rectBounds = [rect(1:2) ; rect(1:2)+rect(3:4)];
% rectBounds = [l b; r t];
hit = (pt >= rectBounds(1,:)) & (pt <=rectBounds(2,:));
