function olIndex=multipleselect(p,olHandle)
%MULTIPLESELECT modifies the list of selected components

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:50 $


if isa(olHandle,'rptcp')
   %if we have been given a rptcp object containing
   %the handles of the selected components
   [common,olIndex,bIndex]=intersect(p.h,olHandle.h);
elseif ishandle(olHandle) & floor(olHandle)~=olHandle
   %if we have been given the handle of the outline
   olIndex=get(olHandle,'Value');
else
   %if we have been given a list of selected indices
   olIndex=olHandle;
end

if length(olIndex)>1
   rootComponents=selectroot(p,olIndex);   
   rootComponents=LocTraverseList([],rootComponents.h);
   [commmon,olIndex,bIndex]=intersect(p.h,rootComponents);
elseif length(olIndex)<1
   olIndex=1;
end

olIndex=sort(olIndex);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocTraverseList(list,newComponents)

for i=1:length(newComponents)
   list=[list newComponents(i)];
   myChildren=get(newComponents(i),'Children');
   list=LocTraverseList(list,myChildren);
end
