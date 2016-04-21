function aObj = doselect(aObj, varargin)
%SCRIBEHGOBJ/DOSELECT Select scribegobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:13:26 $

switch nargin
case 4
   selType = varargin{1};
   figObjH = varargin{2};
   eventType = varargin{3};
case 3
   selType = varargin{1};
   figObjH = varargin{2};
   eventType = 'none';
case 1
   figH = get(aObj,'Figure');
   figObjH = getobj(figH);
   selType = get(figH, 'SelectionType');
   eventType = 'none';
end

selected = get(aObj,'IsSelected');

persistent selectedBeforeButtonDown;
if strcmp(eventType,'down')
   selectedBeforeButtonDown = selected;
end

% selection happens on mouse down
% deselection happens on mouse up, (which doesn't fire if we
% drag) unless we click an unselected object without shift...

if selectedBeforeButtonDown
   if strcmp(eventType, 'up')
      switch selType
      case 'extend'
         aObj = set(aObj,'IsSelected',0);
      case 'alt'
         % do nothing
      otherwise
         dragBinH = figObjH.DragObjects;
         myH = get(aObj, 'MyHandle');
         for aObjH = dragBinH.Items
            if ~(aObjH == myH)
               set(aObjH,'IsSelected',0);
            end
         end
      end
      clear selectedBeforeButtonDown;
   end
else % clicked object is not already selected
   if strcmp(eventType,'down')
      switch selType
      case 'extend'
         aObj = set(aObj,'IsSelected',1);
      otherwise 
         % clear selection
         dragBinH = figObjH.DragObjects;
         for aObjH = dragBinH.Items
            set(aObjH,'IsSelected',0);
         end
         % only this one should be selected
         aObj = set(aObj,'IsSelected',1);         
      end
   else
      clear selectedBeforeButtonDown;
   end
end
