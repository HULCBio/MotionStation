function delete(A)
%SCRIBEHGOBJ/DELETE Delete scribehgobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/01/15 21:13:22 $

myhandle = get(A,'MyHandle');
if get(myhandle,'IsSelected'), set(myhandle,'IsSelected',0); end

myParent = get(A,'MyBin');
if ~isempty(myParent)
   myParent.RemoveItem = A;
end
