function aObj = enddrag(aObj)
%AXISCHILD/ENDDRAG End axischild drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/01/15 21:11:32 $

savedState = get(aObj, 'SavedState');

myH = get(aObj,'MyHandle');
set(myH,'EraseMode',savedState.EraseMode);

if get(aObj,'AutoDragConstraint')
   aObj = set(aObj,'OldDragConstraint','restore');
end
suffix = get(aObj,'Suffix');
if ~isempty(suffix)
   feval(suffix{1},myH,suffix{2:end});
end


