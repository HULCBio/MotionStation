function newHandle = copyobj(A, newParentH)
%SCRIBEHANDLE/COPYOBJ Copy scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.1 $  $Date: 2004/01/15 21:12:58 $

newHandle = [];

if isa(A,'scribehandle')
   aHG = A.HGHandle;
   ud = getscribeobjectdata(aHG);
   aObj = ud.ObjectStore;
elseif isa(A,'scribehgobj')
   aObj = A;
   aHG = A.HGHandle;
else
   error('must supply an HGOBJ or a handle to an HGOBJ object')
   return
end

selected = get(A,'IsSelected');

if nargin==1
   HGParent = get(aHG,'parent');
else
   HGParent = newParentH;
   % if isa(A,'scribehandle')
   %    HGParent = newParentH.HGHandle;
   % elseif ishandle(HGParent)
   %    HGParent = newParentH;
   % end
end
   
newObj = copyobj(aObj,HGParent);
if isempty(newObj), return, end

newHandle = scribehandle(newObj);

if selected
   set(newHandle,'IsSelected',selected);
end
