function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:06 $

currBlk=c.zslmethods.Block;

out='';

if isempty(currBlk)
   status(c,'Warning - no block for automatic property table',2);
   return;
end

try
   blkType=get_param(currBlk,'blocktype');
catch
   status(c,'Warning - can not get block parameters',2);
   return;
end

try
   maskNames=get_param(currBlk,'MaskNames');
catch
   maskNames={};
end

if ~isempty(maskNames)
   typeString=get_param(currBlk,'MaskType');
   
   if c.att.isNamePrompt
      nameCol=strrep(get_param(currBlk,'MaskPrompts'),':','');
   else
      nameCol=maskNames;
   end
   
   %a column vector with all of the mask values
   valCol=get_param(currBlk,'MaskValues');
else
   typeString=blkType;
   
   dParam=get_param(currBlk,'dialogparameters');
   if isstruct(dParam)
      nameCol=fieldnames(dParam);
      valCol={};
      i=1;
      while i<=length(nameCol)
         try
            valCol{i,1}=get_param(currBlk,nameCol{i});
            i=i+1;
         catch
            %We have encountered a write-only property
            nameCol=[nameCol(1:i-1);nameCol(i+1:end)];
         end
      end
      
      if c.att.isNamePrompt
         for i=length(nameCol):-1:1
            nameCol{i,1}=strrep(getfield(getfield(dParam,nameCol{i}),'Prompt'),':','');
         end
      end
   else
      valCol={};
      nameCol={};
   end
end

if isempty(nameCol)
   status(c,...
      'Warning - no parameters for block automatic property table'...
      ,2);
   return;
end


switch c.att.HeaderType
case   'blkname'
   hdrCells={typeString,strrep(get_param(currBlk,'Name'),char(10),' ')};
   numHeaderRows=1;
case   'namevalue'
   hdrCells={'Name','Value'};
   numHeaderRows=1;
otherwise %'none'
   hdrCells=cell(0,2);
   numHeaderRows=0;
end

tableCells=[hdrCells;[nameCol,valCol]];

switch c.att.TitleType
case 'blkname'
   tableTitle=strrep(get_param(currBlk,'Name'),char(10),' ');
case 'other'
   tableTitle=c.att.TitleString;
otherwise %   'none'
   tableTitle='';
end

tableComp=c.rptcomponent.comps.cfrcelltable;
att=tableComp.att;
att.TableTitle=tableTitle;
att.TableCells=tableCells;
att.isPgwide=logical(1);
att.ColumnWidths=[.4 .6];
att.numHeaderRows=numHeaderRows;
att.isBorder=c.att.isBorder;
tableComp.att=att;

out=runcomponent(tableComp,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pName=LocPromptify(sName)
%Tries to turn an InterCapped block parameter
%into a spaced and noncapitalized prompt

absName=abs(sName);
capPos=find(absName>=abs('A') & absName<=abs('Z'));
if isempty(capPos) | capPos(1)~=1
   capPos=[1 capPos ];
end

capPos=[capPos length(sName)+1];

pName=sName(capPos(1):capPos(2)-1);
for i=2:length(capPos)-1
   pName=[pName ' ' lower(sName(capPos(i):capPos(i+1)-1))];
end