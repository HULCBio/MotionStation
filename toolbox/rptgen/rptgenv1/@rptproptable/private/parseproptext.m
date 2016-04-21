function [leftCell,rightCell]=parseproptext(c,entry,isAttributePage)
%PARSEPROPTEXT parse property text into left and right columns
%   [LEFT,RIGHT]=PARSEPROPTEXT(C,ENTRY,ISATTPAGE)


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:07 $

entryText=singlelinetext(rptparent,entry.text,'');
begbrax=findstr('%<',entryText);
endbrax=findstr('>',entryText);

numBrax=min(length(begbrax),length(endbrax));
begbrax=begbrax(1:numBrax);
endbrax=endbrax(1:numBrax);

if c.att.SingleValueMode
   if numBrax>0
      property=entryText(begbrax(1)+2:endbrax(1)-1);
      [leftCell,rightCell]=LocGetProperty(c,entry,property,isAttributePage);
   else
      leftCell='';
      rightCell='';
   end
else %nargout==1   %allow multiple text
   rightCell='';
   parsedCells={};
   
   begbrax=[begbrax,length(entryText)+1];
   endbrax=[0,endbrax];
   
   for i=1:min(length(endbrax),length(begbrax))
      plainText=entryText(endbrax(i)+1:begbrax(i)-1);
      if isAttributePage
         plainText=LocUnLatex(plainText);
      end
      if i<length(endbrax)
         property=entryText(begbrax(i)+2:endbrax(i+1)-1);
         [pName,pValue]=LocGetProperty(c,entry,property,isAttributePage);
      else
         pName='';
         pValue='';
      end
      parsedCells={parsedCells{:} plainText pName pValue};
   end  %for i=1:length(endbrax)
   notEmptyCells=find(~cellfun('isempty',parsedCells));
   leftCell=parsedCells(notEmptyCells);
   if isAttributePage
      leftCell=singlelinetext(rptparent,leftCell,'');
   elseif length(leftCell)>1
      leftCell=sgmltag(leftCell);
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [propName,propValue]=LocGetProperty(c,entry,property,isAtt) 

if isAtt
   if isempty(property)
      propName='';
      valName='';
   else
      capChar=find(abs(property)>=abs('A') & ...
         abs(property)<=abs('Z'));
      if ~isempty(capChar)
         valString=lower(property(capChar));
      else
         valString=lower(property(1));
      end
      valName=[valString 'Value'];
      propName=LocUnLatex(property);
   end
   
   
   cellResult=struct('name',propName,...
      'value',valName);
else
   try
      cellResult=tableref(c,'GetPropCell',property);
      if isempty(cellResult)
         cellResult=struct('name',property,'value','');
      end
   catch
      status(c,sprintf('Warning - could not get property "%s"', property ),2);
      cellResult=struct('name',property,'value','');
   end
end

if isnumeric(entry.render)
   propRenderCode = {'v'
      'p v'
      'P v'
      'p:v'
      'P:v'
      'p-v'
      'P-v'};
   if entry.render>0 & entry.render<=length(propRenderCode)
      renderCode=propRenderCode{entry.render};
   else
      renderCode='P v';
   end
else
   renderCode=entry.render;
end

if length(renderCode)>1 & ~isempty(cellResult.name)
   switch renderCode(2)
   case ':'
      propName=[cellResult.name ': '];
   case '-'
      propName=[cellResult.name ' - '];      
   otherwise %case ' '
      propName=[cellResult.name '  '];
   end
   
   if strcmp(renderCode(1),'P')
      if isAtt
         propName=['\it' propName '\rm'];
      else
         propName=set(sgmltag,...
            'data',propName,...
            'tag','emphasis');
      end
   end
else
   propName='';
end

propValue=cellResult.value;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pName,pValue]=LocDisplayProperty(entry,property);

pName=property;
pValue='Value';

if isnumeric(entry.render)
   propRenderCode = {'v'
      'p v'
      'P v'
      'p:v'
      'P:v'
      'p-v'
      'P-v'};
   if entry.render>0 & entry.render<=length(propRenderCode)
      renderCode=propRenderCode{entry.render};
   else
      renderCode='P v';
   end
else
   renderCode=entry.render;
end

if length(renderCode)>1 & ~isempty(cellResult.name)
   switch renderCode(2)
   case ':'
      propName=[cellResult.name ': '];
   case '-'
      propName=[cellResult.name ' - '];      
   otherwise %case ' '
      propName=[cellResult.name '  '];
   end
   
   if strcmp(renderCode(1),'P')
      propName=set(sgmltag,...
         'data',propName,...
         'tag','emphasis');
   end
else
   propName='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outString=LocUnLatex(inString)

outString=strrep(inString,'\','\\');
outString=strrep(outString,'{','\{');
outString=strrep(outString,'}','\}');
outString=strrep(outString,'_','\_');
outString=strrep(outString,'^','\^');
