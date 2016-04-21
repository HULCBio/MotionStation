function [oList, badList]=getobjects(c,isVerify)
%GETOBJECTS returns a list of objects to include in report
%   OBJLIST=GETOBJECTS(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:36 $

if nargin<2
   isVerify=1;
end

if c.att.isFilterList
   filterTerms=c.att.FilterTerms;
else
   filterTerms={};
end

switch c.att.LoopType
case '$list'
   context=parselist(c.att.ObjectList);
   
otherwise
   sortType=c.att.SortBy;
   context=getparentloop(c);
end

[oList, badList]=loopblock(c.zslmethods,...
   c.att.SortBy,...
   context,...
   filterTerms);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function newList=parselist(oldList);

newList={};
for i=1:length(oldList)
   currString=oldList{i};
   if isempty(currString)
      %do nothing and move on
   elseif strncmp(currString,'%<',2) & strcmp(currString(end),'>')
      %This is a string to be evaluated in the base workspace!
      currString=currString(3:end-1);
      try
         rezString=evalin('base',currString);
      catch
         rezString=[];
      end
      
      if ischar(rezString) & size(rezString,1)==1
         newList{end+1,1}=rezString;
      elseif iscell(rezString) & min(size(rezString))==1
         newList=[newList(:);rezString(:)];
      elseif isnumeric(rezString) & min(size(rezString))==1
         rezString=num2cell(rezString);
         newList=[newList(:);rezString(:)];
      end
   else
      newList{end+1,1}=currString;
   end
end

