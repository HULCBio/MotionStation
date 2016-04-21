function out=execute(r,c)
%EXECUTE generates the report tags
%   out=execute(r,c)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:41 $


%%%%%%% get list of objects to include in table %%%%%%%%%%%%%

l=make_loop_comp(r,c);
%disp('LoopComponent');
%disp(l);
%disp('--------------');

objectList=getobjects(l,logical(1));
%disp('Object List');
%disp(objectList);

clear_loop_comp(r,c,l);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

typeInfo=get_table(r,c);

if ~isempty(objectList)
   
   paramList=subsref(c,substruct('.','att','.',...
      sprintf('%sParameters',typeInfo.id)));
   anchorFlag=subsref(c,substruct('.','att','.',...
      sprintf('is%sAnchor',typeInfo.id)));
   
   if strcmp(subsref(c,substruct('.','att','.','TitleType')),'$auto')
      tableTitle=sprintf('%s Properties',typeInfo.displayName);
      autoTitle=logical(1);
   else
      tableTitle=parsevartext(rptcomponent,...
         subsref(c,substruct('.','att','.','TableTitle')));
      autoTitle=logical(0);
   end
   
   if ~any(strcmp(paramList,'%<SplitDialogParameters>'))
      out=LocMakeTable(objectList,...
         paramList,...
         tableTitle,...
         anchorFlag,...
         typeInfo,...
         c);
   else
      splitParamList=LocGetSplitParamList(c,objectList,paramList,typeInfo);
      out={};
      for i=size(splitParamList,1):-1:1
         if autoTitle
            splitTitle=[splitParamList{i,1}, ' ', tableTitle];
         else
            splitTitle=tableTitle;
         end
         
         out{i}=LocMakeTable(splitParamList{i,2},...
            splitParamList{i,3},...
            splitTitle,...
            anchorFlag,...
            typeInfo,...
            c);
      end
   end
else
   out='';
   warnStr='Warning - Could not find any "%s" objects for summary table.';
   status(c,sprintf(warnStr,typeInfo.displayName),2);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myTable=LocMakeTable(objList,...
   propList,...
   tableTitle,...
   isLink,...
   typeInfo,...
   c)

numObj=length(objList);
numProps=length(propList);

propColumnHeading=propList;

if ~isLink
   %if we are not inserting a link anchor, change any
   %"name" properties so that they link to their 
   %source anchor by changing "Name" to "NameLinked"
   nameIndex=find(strcmpi(propList,'name'));
   if ~isempty(nameIndex)
      [propList{nameIndex}]=deal('NameLinked');
   end
end

if numObj<1 | numProps<1
   myTable='';
   return
end

tCells={};
for i=1:length(propList)
   propColumn=feval(typeInfo.getCmd,...
      c,...
      'GetPropValue',...
      objList,...
      propList{i});
   tCells(:,end+1)=[propColumnHeading(i); propColumn];
end

r=rptcomponent;
if isLink
   linkComp=r.comps.cfrlink;
   linkComp.att.LinkType='Anchor';
   
   for i=2:size(tCells,1)
      linkComp.att.LinkID=linkid(c,objList(i-1),typeInfo.linkid);
      linkText=tCells{i,1};
      if isempty(linkText)
         linkText='&nbsp;';
      end
      linkComp.att.LinkText=linkText;
      
      tCells{i,1}=runcomponent(linkComp,0);
   end
end

tableComp=r.comps.cfrcelltable;
tableComp.att.numHeaderRows=1;
tableComp.att.TableTitle=tableTitle;
tableComp.att.TableCells=tCells;

myTable=runcomponent(tableComp,5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spl=LocGetSplitParamList(c,objectList,allParams,typeInfo)
%returns a Nx3 cell array splitParamList
%col1 = block/mask type
%col2 = blocks
%col3 = parameters

blockTypes=feval(typeInfo.getCmd,...
   c,...
   'GetPropValue',...
   objectList,...
   'BlockType');

[uniqueBlockTypes,blockIndexA,blockIndexB]=unique(blockTypes);

systemIndices = find(strcmp(blockTypes,'SubSystem'));
systemList = objectList(systemIndices);

maskTypes = feval(typeInfo.getCmd,...
    c,...
    'GetPropValue',...
    objectList(systemIndices),...
    'MaskType');

[uniqueMaskTypes,maskIndexA,maskIndexB]=unique(maskTypes);


%--------------------
spl=cell(0,3);
dpIndex=find(strcmp(allParams,'%<SplitDialogParameters>'));
dpIndex=[dpIndex length(allParams)+1];

for i=1:length(uniqueBlockTypes)
   if ~any(strcmp({'SubSystem' 'Scope' 'Outport' 'Inport',''},...
         uniqueBlockTypes{i}))
     
      typeIndices=find(blockIndexB==i);
      exampleObject=objectList{typeIndices(1)};
      dialogParams=feval(typeInfo.getCmd,...
         c,...
         'GetPropValue',...
         exampleObject,...
         'dialogparameters');
      dialogParams=dialogParams{1};
      if isempty(dialogParams)
         dialogParams={};
      end
      splitParams=allParams(1:dpIndex(1)-1);
      for j=1:length(dpIndex)-1
         splitParams={splitParams{:},...
               dialogParams{:},...
               allParams{dpIndex(j)+1:dpIndex(j+1)-1}};
      end
      
      spl(end+1,:)={uniqueBlockTypes{i},...
            objectList(typeIndices),...
            splitParams};
   end
end

for i=1:length(uniqueMaskTypes)
    if ~any(strcmp({''},uniqueMaskTypes{i}))
        
        typeIndices=find(maskIndexB==i);
        exampleObject = systemList{typeIndices(1)};
        
        dialogParams=feval(typeInfo.getCmd,...
            c,...
            'GetPropValue',...
            exampleObject,...
            'MaskNames');
        
        dialogParams=dialogParams{1};
        if isempty(dialogParams)
            dialogParams={};
        end
        
        splitParams=allParams(1:dpIndex(1)-1);
        for j=1:length(dpIndex)-1
            splitParams={splitParams{:},...
                    dialogParams{:},...
                    allParams{dpIndex(j)+1:dpIndex(j+1)-1}};
        end
        
        spl(end+1,:)={uniqueMaskTypes{i},...
                systemList(typeIndices),...
                splitParams};
    end
end
