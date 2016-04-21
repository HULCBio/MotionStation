function cleanup(r)
%CLEANUP clears leftover data after report generation

%     *removes any component pointers from the 
%       clipboard which were added during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:52 $

%clean up added component pointers
if ~isempty(what('rptsp'))
	clipboardPointer=rptsp('clipboard');
	newHandles=allchild(clipboardPointer.h);
else
	newHandles = [];
end

oldHandles=subsref(r,...
   substruct('.','PreRunClipboardHandles'));

addedHandles=setdiff(newHandles,oldHandles);
delete(addedHandles);

getimgname(r,'$SaveVariables');
