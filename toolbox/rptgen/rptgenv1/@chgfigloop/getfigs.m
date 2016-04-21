function hList=getfigs(c)
%GETFIGS returns a list of figures to be looped upon
%  
%
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:04 $


switch upper(c.att.LoopType);
case 'ALL'
   allFigs=allchild(0);
   
   if isfield(c.ref,'RptgenTagList')
      badTags=c.ref.RptgenTagList;
   else
      i=getinfo(c);
      badTags=i.ref.RptgenTagList;
   end
   badList=FindFiguresWithTags(badTags,allFigs);
   
   if c.att.isDataFigureOnly
      restrictionString={'HandleVisibility','on','Visible','on'};
   else
      restrictionString={'Visible','on'};
   end
   
   foundList=findall(allFigs,'flat',restrictionString{:});
   
   hList=setdiff(foundList,badList);
   
case 'CURRENT'
   hList=get(0,'CurrentFigure');
case 'TAG'
   hList=sort(FindFiguresWithTags(c.att.TagList,allchild(0)));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tFigs=FindFiguresWithTags(tagList,allFigs)


tFigs=[];

for i=1:length(tagList)
   tFigs=[tFigs
      findall(allFigs,'flat','tag',tagList{i})];
end  