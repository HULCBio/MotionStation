function aObj = dodrag(aObj, varargin)
%AXISTEXT/DODRAG Drag axistext object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:11:53 $

axischildObj = aObj.axischild;
aObj.axischild = dodrag(axischildObj, varargin{:});

myHG = get(aObj,'MyHGHandle');
units = get(myHG,'Units');

switch units
case 'data'
   parentAx = get(myHG,'Parent');
   labels = get(parentAx,{'XLabel','YLabel','ZLabel','Title'});
   if find(myHG==[labels{:}])
      % make labels normalized so they don't disappear
      set(myHG,'Units','normalized');
      initialPosition = varargin{1};
      aObj = set(aObj,'Offset',initialPosition);
   else
      savedState = get(aObj,'SavedState');
      savedState.DataUnitDrag = 1;
      aObj = set(aObj,'SavedState',savedState);
   end
      
otherwise
   initialPosition = varargin{1};
   aObj = set(aObj,'Offset',initialPosition);
end

   

