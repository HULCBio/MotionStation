function A = set(A, varargin)
%AXISTEXT/SET Set axistext property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:03 $  

axischildObj = A.axischild;

if nargin == 3
   switch varargin{1}
   case 'XYData'
      HG = get(A,'MyHGHandle');
      pos = get(HG,'Position');
      val = varargin{2};
      pos = [val{1} val{2}];
      set(HG,'Position',pos);
   case 'XData'
      HG = get(A,'MyHGHandle');
      pos = get(HG,'Position');
      pos(1) = varargin{2};      
      set(HG,'Position',pos);
   case 'YData'
      HG = get(A,'MyHGHandle');
      pos = get(HG,'Position');
      pos(2) = varargin{2};
      set(HG,'Position',pos);
   case 'FigureOffset'
      A = LSetFigureOffset(A, varargin{2});
   case 'Offset'
      if strcmp(get(A,'Units'),'data')
         A.axischild = set(axischildObj, varargin{:});
      else
         A = LSetNonDataOffset(A, varargin{2});
      end
   otherwise
      A.axischild = set(axischildObj, varargin{:});
   end
else
   A.axischild = set(axischildObj, varargin{:});
end

function A = LSetNonDataOffset(A,initialPosition)

savedState = get(A, 'SavedState');
myHG = get(A,'MyHGHandle');
axH = get(myHG,'Parent');
figH = get(axH,'Parent');

figUnits = get(figH,'Units');
myUnits = get(myHG,'Units');
% work in figure units
set(myHG,'Units',figUnits);

pos = get(myHG,'Position');

savedState.Fig = figH;
savedState.PointX = initialPosition(1);
savedState.PointY = initialPosition(2);
savedState.OffsetX = initialPosition(1)-pos(1);
savedState.OffsetY = initialPosition(2)-pos(2);
savedState.DataUnitDrag = 0;
savedState.OldUnits = myUnits;

A = set(A,'SavedState',savedState);

function A = LSetFigureOffset(A,initialPosition)

savedState = get(A, 'SavedState');
myHG = get(A,'MyHGHandle');
axH = get(myHG,'Parent');
figH = get(axH,'Parent');

set(figH,'CurrentPoint',initialPosition);

figUnits = get(figH,'Units');
axUnits = get(axH,'Units');
myUnits = get(myHG,'Units');

set([figH axH],'Units', myUnits);

pointer = get(figH, 'CurrentPoint');
pos = get(myHG,'Position');
axPos = get(axH,'Position');
figPos = get(figH,'Position');
switch myUnits
case 'normalized'
   figPos = axPos(1:2) + pos(1:2).*axPos(3:4);
otherwise
   figPos = axPos(1:2) + pos(1:2).*axPos(3:4)./figPos(3:4);
end

savedState.Fig = figH;
savedState.PointX = pointer(1);
savedState.PointY = pointer(2);
savedState.OffsetX = pointer(1)-figPos(1);
savedState.OffsetY = pointer(2)-figPos(2);
savedState.DataUnitDrag = 0;
savedState.OldUnits = myUnits;

set([figH; axH],{'Units'}, {figUnits; axUnits});

A = set(A,'SavedState',savedState);
