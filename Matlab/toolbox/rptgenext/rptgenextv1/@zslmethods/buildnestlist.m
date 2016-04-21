function nl=buildnestlist(m,currSys,isPeers,childDepth,parentDepth)
%BUILDNESTLIST builds a nested list of simulink systems
%   NESTLIST=BUILDNESTLIST(ZSLMETHODS,SYSNAME,ISPEERS,CDEPTH,PDEPTH)
%   A NESTLIST is a recursively nested structure containing fields
%   .Name = the name of the current node
%   .Children = children of this object (more NESTLIST structs)
%   .isCurrent = showing whether the item is the current system
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:27 $


entry=struct('Name',currSys,...
   'Children',[],...
   'isCurrent',logical(1));
entry=LocAddChildren(entry,1,childDepth);
if isPeers
   withPeers=LocAddPeers(entry);
else
   withPeers=entry;
end
nl=LocAddParents(withPeers,entry,1,parentDepth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function entry=LocAddChildren(entry,currDepth,maxDepth)

if currDepth<=maxDepth
   childList=LocGetChild(entry(1).Name);
   entry.Children=struct('Name',childList,...
      'Children',[],'isCurrent',logical(0));
   for i=1:length(entry.Children)
      entry.Children(i)=LocAddChildren(entry.Children(i),...
         currDepth+1,maxDepth);
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function entryOut=LocAddPeers(entryIn);

parentSys=get_param(entryIn(1).Name,'Parent');

if ~isempty(parentSys)
   peerList=LocGetChild(parentSys);
   
   currIndex=find(strcmp(peerList,entryIn(1).Name));
   currIndex=currIndex(1);
   
   entryOut=struct('Name',peerList,...
      'Children',[],...
      'isCurrent',logical(0)); 
   entryOut(currIndex)=entryIn;
else
   entryOut=entryIn;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parent=LocAddParents(peers,current,currDepth,maxDepth)

parent=peers;
if currDepth<=maxDepth
   parentSys=get_param(current(1).Name,'Parent');
   if ~isempty(parentSys)
      parent=struct('Name',parentSys,...
         'Children',peers,...
         'isCurrent',logical(0));
      parent=LocAddParents(parent,parent,currDepth+1,maxDepth);
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function childList=LocGetChild(parentSys)

childList=find_system(parentSys,...
   'SearchDepth',1,...
   'BlockType','SubSystem');

parentLoc=find(strcmp(childList,parentSys));
if ~isempty(parentLoc)
   childList={childList{1:parentLoc-1},...
         childList{parentLoc+1:end}};
end
