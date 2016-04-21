function p=selectroot(p,selected)
%SELECTROOT returns unique shared parents of components
%   SELECTROOT(P,SELECTED) searches the
%   SELECTED components in the outline list and
%   returns a list of which reflects
%   the unique parents of those selected.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:59 $

%selected can be a list of indices in P or an independent
%list of object pointer handles;

if ~isa(selected,'rptcp')
   selected=p.h(sort(selected));
else
   selected=selected.h;
end

rootList=[];

for i=1:length(selected)
   myHandle=selected(i);
   if isempty(intersect(rootList,...
         LocParentList(myHandle)))
      rootList=[rootList myHandle];
   end
end

p.h=rootList;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pList=LocParentList(startObj)

pList=startObj;
while pList(end)>0
   pList=[pList get(pList(end),'Parent')];
end
