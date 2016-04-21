function oList=getobjects(c,isVerify)
%GETOBJECTS
%   OBJLIST=GETOBJECTS(C)

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:55:00 $

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
   
   if c.att.isSortList
      sortType=c.att.SortBy;
   else
      sortType='';
   end
otherwise
   sortType=c.att.SortBy;
   context=getparentloop(c);
end

oList=loopfixpt(c,...
   sortType,...
   context,...
   filterTerms,...
   c.att.LoggedOnly);

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

