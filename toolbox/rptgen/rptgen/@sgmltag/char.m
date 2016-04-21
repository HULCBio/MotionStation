function ch=char(t,myBlanks)
%CHAR converts an SGMLTAG object to a character array
%   CHAR(S) converts SGMLTAG object S from parsed
%   tag information to character data.


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:30 $

if nargin<2
   myBlanks='  ';
end

if ~isempty(t.tag)
   
   if t.opt(3)
      lbreak=char(10);
      closeBlanks=myBlanks;
   else
      lbreak='';
      closeBlanks='';
   end

   openTag=[myBlanks '<' t.tag LocAttributes(t) '>' lbreak];
   if t.opt(2)
      closeTag=[closeBlanks '</' t.tag '>\n'];
   else
      closeTag='\n';
   end
   
   if t.opt(1)
      myBlanks(end+1:end+2)='  ';
   else
      myBlanks='';
   end
else
   openTag='';
   closeTag='';
   lbreak=char(10);
end

if ~t.opt(3)
   myBlanks='';
end

ch=[openTag,...
      LocProcessData(t.data,myBlanks,lbreak,t.opt(4)),...
      closeTag];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myChar=LocProcessData(data,indentBlanks,lbreak,isSGML)

myChar='';
switch class(data)
case 'cell'
   for i=1:length(data)
      myChar=[myChar,LocProcessData(...
            data{i},...
            indentBlanks,...
            lbreak,...
            isSGML)];
   end
case 'sgmltag'
   myChar=char(data,indentBlanks);
case 'char'
   nRow=size(data,1);
   if nRow<2
      myChar=[indentBlanks,LocPrepareText(data,isSGML),lbreak];
   elseif nRow>1
      data=[data ones(nRow,1)*lbreak]';
      myChar=[indentBlanks,LocPrepareText(data(:)',isSGML)];
   end
case 'double'
   if size(data,1)>0
      myChar=[indentBlanks sprintf('%0.5g ',data) lbreak];
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function attStr=LocAttributes(t)

attStr='';
for i=1:size(t.att,1);
   data=t.att{i,2};
   
   if isnumeric(data)
      attStr=[attStr ' ' t.att{i,1} '=' ...
            sprintf('%0.5g ',data)];      
   elseif ischar(data)
      attStr=[attStr ' ' t.att{i,1} '="' ...
            strrep(strrep(strrep(data,'%','%%'),'\','\\'),'<','&lt;'),...
            '"'];      
   else
      warning('Attribute value not a string or character');
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocPrepareText(in,isSGML)

out=(strrep(strrep(in,...
   '%','%%'),...
   '\','\\'));

if ~isSGML
   out=strrep(strrep(strrep(strrep(out,...
      '&nbsp;',char([255   110    98   115   112 59])),...
      '&','&amp;'),...
      char([255   110    98   115   112 59]),'&nbsp;'),...
      '<','&lt;');
end