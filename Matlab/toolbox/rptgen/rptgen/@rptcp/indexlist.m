function iList=indexlist(iList,nonIncluded)
%INDEXLIST returns list indices of included components

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:42 $

if nargin<2
   nonIncluded=[];
end

if ~isa(nonIncluded,'rptcp')
   currHandle=iList.h(end);
   c=get(currHandle,'UserData');
   c.ref.OutlineIndex=length(iList);
   isInclude=(c.comp.Active==1);
else
   currHandle=nonIncluded.h;
   c=get(currHandle,'UserData');
   c.ref.OutlineIndex=0;
   isInclude=logical(0);
end
set(currHandle,'UserData',c);

myChild=get(currHandle,'children');
for i=1:length(myChild)
   if isInclude
      iList=[iList myChild(i)];
      nonIncluded=[];
   else
      nonIncluded=rptcp(myChild(i));
   end
   iList=indexlist(iList,nonIncluded);
end

