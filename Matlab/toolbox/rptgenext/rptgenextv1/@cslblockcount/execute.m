function out=execute(c)
%EXECUTE generates report contents
%   OUTPUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:09 $

parentLoop=getparentloop(c);

errMsg='';
fullNames=logical(0);
switch parentLoop
case 'Model'
   if strcmp(c.att.IncludeBlocks,'all')
      mdlName=c.zslmethods.Model;
      if ~isempty(mdlName)
         bList=find_system(mdlName,...
            'type','block');
      else
         bList={};
      end
   else
      bList=c.zslmethods.ReportedBlockList;
   end
   fullNames=logical(1);
case 'System'
   currSys=c.zslmethods.System;
   if ~isempty(currSys)
      bList=find_system(currSys,...
         'SearchDepth',1,...
         'type','block');   
      bList=setdiff(bList,currSys);
   else
      bList={};
   end
   fullNames=logical(0);
case 'Block'
   errMsg='Error - can not count blocktypes inside block loop';
   bList={};
   fullNames=logical(0);
case 'Signal'
   errMsg='Error - can not count blocktypes inside signal loop';
   bList={};
   fullNames=logical(0);
otherwise
   startModels=find_system('type','block_diagram',...
      'blockdiagramtype','model');
   bList=find_system(startModels,...
      'type','block');
   fullNames=logical(1);
end

if ~isempty(errMsg)
   status(c,errMsg,1)
   out='';
   return
elseif isempty(bList)
   status(c,'Warning - no blocks found for block count',2);
   out='';
   return;
end

allTypes=getparam(c.zslmethods,bList,'blocktype');

[uniqTypes,aIndex,bIndex]=unique(allTypes);

for i=length(uniqTypes):-1:1
   origIndex=find(bIndex==bIndex(aIndex(i)));
   numTypes{i,1}=length(origIndex);
   typeBlocks{i,1}=bList(origIndex);
   %create a comma separated list of block names
   %if length(origIndex)>1
   %   blkList=cell(length(typeBlocks),1);
   %   [blkList{2:2:2*length(typeBlocks)-2}]=deal(sprintf(',   '));
   %   [blkList{1:2:2*length(typeBlocks)-1}]=deal(typeBlocks{:});
   %else
   %   blkList=typeBlocks;
   %end
   %listBlocks{i,1}=blkList;
end

switch c.att.SortOrder
case 'alpha'
   [sortedTypes,sortIndex]=sort(uniqTypes);
case 'numblocks'
   [sortedNums,sortIndex]=sort([numTypes{:}]);
   %we want this list to be sorted in descending order
   sortIndex=sortIndex(end:-1:1);
otherwise
   sortIndex=[1:length(uniqTypes)];
end

tableCells=[[{'BlockType'};uniqTypes(sortIndex)],...
      [{'# of Occurrences'};numTypes(sortIndex)]];

if c.att.isBlockName
   typeBlocks=typeBlocks(sortIndex);
   %typeBlocks is a cell array of block handles
   
   linkComp=c.rptcomponent.comps.cfrlink;
   linkComp.att.LinkType='Link';
   
   listComp=c.rptcomponent.comps.cfrlist;
   listComp.att.ListStyle='SimpleList';
   
   
   colIndex=3;
   for i=length(typeBlocks):-1:1
      bHandles=get_param(typeBlocks{i},'Handle');
      bHandles=[bHandles{:}];
      %bHandles=typeBlocks{sortIndex(i)};
      listCells={};
      for j=length(bHandles):-1:1
         if fullNames
            bName=getfullname(bHandles(j));
         else
            bName=get_param(bHandles(j),'Name');
         end
         
         linkComp.att.LinkID=linkid(c.zslmethods,bHandles(j),'blk');
         linkComp.att.LinkText=bName;
                          
         listCells{j}=runcomponent(linkComp,0);
      end
      listComp.att.SourceCell=listCells;
      tableCells{i+1,colIndex}=runcomponent(listComp,0);
      
      %JADE throws a processing error if you try to stick a list
      %directly into a table Element.  Works OK if you wrap inside MsgText
      %tableCells{i+1,colIndex}=set(sgmltag,...
      %   'tag','msgtext',...
      %   'data',runcomponent(listComp,0));
   end
   tableCells{1,colIndex}='Block Names';
   
   cWid=[2 1 4];
else
   cWid=[3 1];
end

tableComp=c.rptcomponent.comps.cfrcelltable;

att=tableComp.att;
att.TableCells=tableCells;
att.ColumnWidths=cWid;
att.numHeaderRows=1;
att.TableTitle=c.att.TableTitle;
tableComp.att=att;

out=runcomponent(tableComp,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sorted=LocSort(unsorted,SortOrder,InvertSort)

if strcmp(SortOrder,'numblocks')
   [sortVec,sortIndex]=sort([unsorted.Count]);
else
   sortIndex=[1:length(unsorted)];
end

if InvertSort
   sortIndex=sortIndex(end:-1:1);
end

sorted=[unsorted(sortIndex)];

