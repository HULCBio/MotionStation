function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:44 $

if strcmp(c.att.Source,'MATFILE')
   matFileName = parsevartext(c,c.att.Filename);
   variables=whos('-file',matFileName);
   autoName=sprintf('File %s', matFileName);
   useWorkspace=0;
else
   variables=evalin('base','whos');
   autoName='MATLAB Workspace';
   useWorkspace=1;
end

if length(variables)<1
   out='';
   status(c,'Warning - no workspace variables found',2);
   return
end


switch c.att.TitleType
case 'auto'
   tTitle=sprintf('Variables from %s', autoName);   
otherwise  %manual
   tTitle=parsevartext(c,c.att.TableTitle);   
end

colWid=[2]; %Normalize by "name" column


toRemove={};
if ~c.att.isSize
   toRemove{length(toRemove)+1}='size';
else
   lv=length(variables);
   for i=lv:-1:1
      thisarray=variables(i).size;
      thisstr='';
      for j=1:length(thisarray)
         thisstr=[thisstr,num2str(thisarray(j))];
         if j<length(thisarray)
            thisstr=[thisstr,'x'];
         end
      end
      sizestrings{i}=thisstr;
   end
   [variables(1:lv).size]=deal(sizestrings{1:lv});
   colWid(end+1)=1;
end

if ~c.att.isBytes
   toRemove{length(toRemove)+1}='bytes';
else
   colWid(end+1)=1;
end

if ~c.att.isClass
   toRemove{length(toRemove)+1}='class';
else
   colWid(end+1)=1.5;
end

if ~isempty(toRemove)
   variables=rmfield(variables,toRemove);
end

if c.att.isValue
	if ~useWorkspace
        %We need to account for the case in which
        %variables are not in the workspace and we
        %are reading from a MAT file
	    allValues=load(matFileName);
    end
    
   colWid(end+1)=4;
   [variables.Value]=deal('&nbsp;');
   for i=length(variables):-1:1
       if useWorkspace
           variableName=variables(i).name;
       else
           variableName=getfield(allValues,variables(i).name);
       end
       
      variables(i).Value=rendervariable(c,...
         variableName,... %variable name
         logical(1),... %force inline
         [.25],... %use default display restriction
         '',... %no title
         useWorkspace ... %extract from Workspace
         );
   end
end

variables=LocStruct2Cell(variables);

tableComp=c.rptcomponent.comps.cfrcelltable;
att=tableComp.att;
att.isPgwide=logical(0);
att.TableCells=variables;
att.numHeaderRows=1;
att.ColumnWidths=colWid;
att.TableTitle=tTitle;
att.isBorder=logical(1);
tableComp.att=att;

out=runcomponent(tableComp,5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vCell=LocStruct2Cell(vStruct)

vFields=fieldnames(vStruct);
numVars=length(vStruct);

vCell{numVars+1,length(vFields)}='';

vCell(1,:)=vFields';

for i=1:length(vFields)
   eval(['[vCell{2:end,i}]=deal(vStruct.' vFields{i} ');']);
end
