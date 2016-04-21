function addedPointers=addcomp(currSelect,toAdd,leaveInPlace)
%ADDCOMP adds a component to the tree

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:24 $

if nargin<3
   leaveInPlace=logical(0);
end

%addList is a vector of HG handles which should
%be added under currSelect
addList=LocAddList(toAdd);

if (numsubcomps(currSelect)>0)...
      | isa(currSelect,'coutline')
   %we are including addList at the top of the currently
   %selected component's list of children
   addedPointers=LocAdd(double(currSelect),addList,leaveInPlace);
else
   parentIndex=double(getparent(currSelect));
   oldChildren=get(parentIndex,'children');
   AddUnderLoc=rank(currSelect);
   
   addedPointers=LocAdd(double(parentIndex),addList,leaveInPlace);
   
   set(parentIndex,'Children',...
      [oldChildren(1:AddUnderLoc);...
         addedPointers.h;...
         oldChildren(AddUnderLoc+1:end)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function children=LocAdd(parent,children,isCopy);

if isCopy
   children=copyobj(children,parent);
   children=validate(rptcp(children));
else
   set(children,'Parent',parent);
   children=rptcp(children);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addList=LocAddList(toAdd);

%toAdd can be a single component pointer or a cell array
%of many pointers

if isa(toAdd,'rptcp')
   addList=toAdd.h;
elseif isa(toAdd,'cell')
   addList=[];
   for i=1:length(toAdd)
      addList=[addList LocAddList(toAdd{i})];
   end
elseif ishandle(toAdd)
   addList=toAdd;
else
   addList=[];
end

%we want to make sure that addList is a
%column matrix
alSize=size(addList);
if alSize(2)>alSize(1)
   addList=addList';
end



