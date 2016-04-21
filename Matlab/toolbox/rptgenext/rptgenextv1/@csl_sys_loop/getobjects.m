function oList=getobjects(c,isVerify);
%GETOBJECTS returns a list of objects to include in report

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:48 $

switch c.att.LoopType
case '$auto'
   oList=loopsystem(c.zslmethods,...
      c.att.SortBy,...
      getparentloop(c));
case '$list'
   oList=parselist(c.att.ObjectList);
   
   if ~strcmp(c.att.SortBy,'$none')
      oList=loopsystem(c.zslmethods,...
         c.att.SortBy,...
         oList);
   elseif isVerify
      %we need to check the list of systems to make
      %sure that it is valid. This is not necessary
      %in the system loop because it checks the systems
      %one at a time during looping
      pList=getparam(c,oList,'Handle');
      okList=find(~cellfun('isempty',pList));
      oList=oList(okList);
   end
end

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

