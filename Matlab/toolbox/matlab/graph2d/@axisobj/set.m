function A = set(A, varargin)
%AXISOBJ/SET Set axisobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:11:47 $  

if nargin == 3
   switch varargin{1}
   case 'ZoomScale'
      A.ZoomScale = varargin{2};
   case 'Offset'
      A = LSetOffset(A, varargin{2});
   otherwise
      HGObj = A.scribehgobj;
      A.scribehgobj = set(HGObj, varargin{:});
   end
else
   HGObj = A.scribehgobj;
   A.scribehgobj = set(HGObj, varargin{:});
end



function A = LSetOffset(A,initialPosition)
savedState.iPoints = 1;
fig = get(A,'Figure');
oldUnits = get(fig,'Units');
set(fig,'Units',get(A,'Units'));
initialPosition = get(fig,'CurrentPoint');
set(fig,'Units',oldUnits);
pos = get(A,'Position');

savedState.OffsetX = initialPosition(1)-pos(1);
savedState.OffsetY = initialPosition(2)-pos(2);
savedState.DragConstraint = '';
HGObj = A.scribehgobj;
A.scribehgobj = set(HGObj, 'SavedState', savedState);
