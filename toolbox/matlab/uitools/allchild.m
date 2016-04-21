function ChildList=allchild(HandleList);
%ALLCHILD Get all object children
%   ChildList=ALLCHILD(HandleList) returns the list of all children 
%   (including ones with hidden handles) for each handle.  If 
%   HandleList is a single element, the output is returned in a 
%   vector.  Otherwise, the output is a cell array.
%
%   For example, try get(gca,'children') and allchild(gca).
%
%   See also GET, FINDALL.

%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.15 $ $Date: 2002/04/15 03:24:08 $

error(nargchk(1,1,nargin));
if ~all(ishandle(HandleList)),
  error('Invalid handles passed to ALLCHILD.')  
end  

Temp=get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
ChildList=get(HandleList,'Children');
set(0,'ShowHiddenHandles',Temp);
