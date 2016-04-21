function [foundList,toFindList]=getzxxmethodslist(p,toFindList)
%GETZXXMETHODSLIST returns a list of components using a "methods" pointer
%   FOUNDLIST=GETZXXMETHODSLIST(P)
%      P is any RPTCP object, though usually COUTLINE
%      FOUNDLIST will return which of the helper objects which
%            are present in P and its subcomponents


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:40 $

if nargin<2
   toFindList=LocConstructList;
end

if nargout<2
   origFindList=toFindList;
end

foundList={};

numHandles=length(p.h);

i=1;
done=[length(toFindList)<1];

while i<=numHandles & ~done
   c=get(p.h(i),'UserData');
   j=1;
   while j<=length(toFindList)
      if isa(c,toFindList{j})
         foundList(end+1)=toFindList(j);
         toFindList=toFindList([1:j-1,j+1:end]);
      else
         j=j+1;
      end
   end
   if length(toFindList)>0
      [childFound,toFindList]=getzxxmethodslist(...
         children(rptcp(p.h(i))),toFindList);
      foundList=[foundList,childFound];
   else
      done=logical(1);
   end
   
   i=i+1;
end

if nargout<2
   %we need to sort the foundList so that it
   %is in the same order as the original toFindList
   [intersectList,indexA,indexB]=intersect(foundList,origFindList);
   foundList=[{'rptcomponent';'zhgmethods'};origFindList(sort(indexB))];
end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mList=LocConstructList
%This function constructs a list of all the external
%helper objects on the Path

persistent RPTGEN_METHODS_LIST

if isempty(RPTGEN_METHODS_LIST)
   ex=exist('zslmethods');
   if ex==2 | ex==6
      mList={'zslmethods';'zsfmethods'};
   else
      mList={};
   end
   for i='a':'z'
      for j='a':'z'
         mName=sprintf('rpt%c%cmethods',i,j);
         ex=exist(mName);
         if ex==2 | ex==6
            mList{end+1,1}=mName;
         end
      end
   end
   
   if isempty(mList)
      RPTGEN_METHODS_LIST{1}='!';
   else
      RPTGEN_METHODS_LIST=mList;
   end
elseif strcmp(RPTGEN_METHODS_LIST{1},'!')
   mList={};
else
   mList=RPTGEN_METHODS_LIST;
end