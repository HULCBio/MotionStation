function out=execute(c)
%EXECUTE generates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:06 $

if strcmp(c.att.StartSys,'FROMLOOP')
   currSys=c.zslmethods.System;
else
   currSys=c.zslmethods.Model;
end

if ~isempty(currSys)
   nestList=buildnestlist(c,targetsys(c),...
      c.att.isPeers,c.att.ChildDepth,c.att.ParentDepth);
   
   cellList=LocNest2Cell(nestList,c.att.HighlightStartSys);
   
   listComp=c.rptcomponent.comps.cfrlist;
   listComp.att.SourceCell = cellList;
   %listComp.att.Spacing = 'Compact';
   
   switch c.att.DisplayAs
   case 'BULLETLIST'
      listComp.att.ListStyle = 'ItemizedList';
   case 'NUMBEREDLIST'
      listComp.att.ListStyle = 'OrderedList';
      listComp.att.NumInherit = 'Inherit';
      listComp.att.NumContinue = 'Restarts';
   end

   out=runcomponent(listComp,5);
else
   status(c,['Warning - could not find System to build heirarchy list'],2);
   out='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  cellList=LocNest2Cell(nestList,isHighlight)

cellList={};
for i=1:length(nestList)
   myCell=LocStripName(nestList(i).Name);
   if isHighlight & nestList(i).isCurrent
       myCell=set(sgmltag,'tag','Emphasis','data',myCell);
       %myCell=execute(cfrtext('Content',myCell,...
       %  'isEmphasis',logical(1)));
   end
   cellList{end+1}=myCell;
   
   if ~isempty(nestList(i).Children)
      cellList{end+1}=LocNest2Cell(...
         nestList(i).Children,isHighlight);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function clean=LocStripName(dirty)

slashLoc=findstr(dirty,'/');
if isempty(slashLoc)
   slashLoc=0;
end
clean=dirty(slashLoc(end)+1:end);