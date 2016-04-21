function B = loadobj(A)
%SCRIBEHGOBJ/LOADOBJ Load scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.3 $  $Date: 2004/01/15 21:13:29 $

if isa(A,'scribehgobj') % strcmp(class(A),'scribehgobj')
    B = A;
else % object definition has changed
    % should check that this is really a v5.2 object
    A.Draggable = 1;
    A.DragConstraint = '';
    if isstruct(A)
      % make a new struct that has the same order of fields as constructor
      C.Class = A.Class;
      C.HGHandle = A.HGHandle;
      C.ObjBin = A.ObjBin;
      C.ObjSelected = A.ObjSelected;
      C.SavedState = A.SavedState;
      C.Draggable = A.Draggable;
      C.DragConstraint = A.DragConstraint;
      B = class(C,'scribehgobj');
    else
      B = A;
    end
end

% v5.2 object definition
%           Class: 'scribehgobj'
%        HGHandle: 139.0001
%          ObjBin: {[1x1 scribehandle]}
%     ObjSelected: 0
%      SavedState: {}

%    A.Class = 'scribehgobj';
%    A.HGHandle = [];
%    A.ObjBin = {};
%    A.ObjSelected = [];
%    A.Draggable = [];
%    A.DragConstraint = [];
%    A.SavedState = {};
%    A = class(A,'scribehgobj');
