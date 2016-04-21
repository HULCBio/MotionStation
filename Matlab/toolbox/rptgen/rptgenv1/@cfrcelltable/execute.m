function out=execute(c)
%EXECUTE produces report output at generation time
%   OUTPUT=EXECUTE(CFRCELLTABLE)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:07 $

bodyCells=LocGetCells(c);

tableTitle=parsevartext(c.rptcomponent,c.att.TableTitle);

if length(bodyCells)==1
   out=LocCell2Table(c,bodyCells.table,tableTitle);
elseif length(bodyCells)>1
   status(c,[sprintf('Warning - cell array has more than 2 dimensions.') ...
         sprintf('Splitting into multiple tables')],2);
   for i=length(bodyCells):-1:1
      pageText=':,:,';
      lIndex=length(bodyCells(i).index);
      for j=1:lIndex
         pageText=[pageText num2str(bodyCells(i).index(j))];
         if j<lIndex
            pageText=[pageText ','];
         end
      end
      
      pageTitle=[tableTitle ...
            ' (' pageText ')'];
      out{i}=LocCell2Table(c,bodyCells(i).table,pageTitle);
   end
else
   out='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocCell2Table(c,bodyCells,tableTitle)

if isempty(bodyCells)
   out='';
   if isempty(tableTitle)
      statString='Warning - table is empty';
   else
      statString=sprintf('Warning - table "%s" is empty',tableTitle );
   end
   
   status(c,statString,2);
   return
end

nHR=min(c.att.numHeaderRows,size(bodyCells,1)-1);
if nHR>0
   headerCells=bodyCells(1:nHR,:);
   bodyCells=bodyCells(nHR+1:end,:);
else
   headerCells={};
end

switch c.att.Footer
case 'LASTROWS'
   nFR=min(c.att.numFooterRows,size(bodyCells,1)-1);
   if nFR>0
      footerCells=bodyCells(end-nFR+1:end,:);
      bodyCells=bodyCells(1:end-nFR,:);
   else
      footerCells={};
   end
case 'COPY_HEADER'
   footerCells=headerCells;
otherwise
   %assume 'NONE'
   footerCells={};
end

%-----Create overall table tag ----------------

if isempty(tableTitle)
   out=set(sgmltag,'tag','InformalTable');
else
   out=set(sgmltag,'tag','Table',...
      'data',{set(sgmltag,'tag','Title',...
      'data',tableTitle)});
end

if c.att.isBorder
   out.att={'Frame','all';'Colsep',1,;'Rowsep',1};
else
   out.att={'Frame','none';'Colsep',0,;'Rowsep',0};
end

if c.att.isPgwide
   out=att(out,'pgwide','1');
else
   out=att(out,'pgwide','0');
end

%------Create table group ---------------
groupTag=set(sgmltag,...
   'tag','tgroup',...
   'att',{'cols' , size(bodyCells,2);...
   'align',LocUnTerse(c.att.allAlign)});

groupTag=[groupTag;...
      LocMakeColspecs(c, bodyCells);...
      LocMakeSection(headerCells,'thead',c.att.ShrinkEntries);...
      LocMakeSection(footerCells,'tfoot',c.att.ShrinkEntries);...
      LocMakeSection(bodyCells,'tbody',c.att.ShrinkEntries)];

out=[out;groupTag];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function specs=LocMakeColspecs(c,bodyCells)

numCols=size(bodyCells,2);

origWidth=c.att.ColumnWidths;
numOrigWidth=length(origWidth);

if length(numOrigWidth)>numCols
   colWid=origWidth(1:numCols);
elseif length(numOrigWidth)<numCols
   colWid=ones(1,numCols);
   colWid(1:numOrigWidth)=origWidth;
else
   colWid=origWidth;
end

colWid=round(100*colWid);
%DocBook requires integer colWid values

colspecTag=set(sgmltag,...
   'tag','colspec',...
   'endtag',logical(0));
specs={};
for i=length(colWid):-1:1
   specs{i}=set(colspecTag,'att',...
         {'colnum' i ; ...
          'colwidth' [num2str(colWid(i)) '*']});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myTag=LocMakeSection(myCells,tagName,shrinkEntries)

if ~isempty(myCells)
   entryTag=set(sgmltag,'tag','entry',...
       'expanded',false,'indent',false); %remove extra whitespace
   rowTag=set(sgmltag,'tag','row');
   
   myTag=set(sgmltag,'tag',tagName);
   
   
   for i=1:size(myCells,1)
      rowTag.data={};
      for j=1:size(myCells,2)

         rowTag=[rowTag;set(entryTag,...
               'data',LocProcessEntry(myCells(i,j).content,shrinkEntries),...
               'att',LocEntryAttributes(myCells(i,j)))];
      end
      myTag=[myTag;rowTag];
   end   
else
   myTag='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocProcessEntry(in,shrinkEntries)
%This function looks at a cell in the cell table and processes it before
%adding.  If the content is a multi-line string, the function will wrap
%the content in a LiteralLayout tag to preserve line breaks and spaces.

if iscell(in)
    if (length(in)>1 & min(size(in))==1)
        out=set(sgmltag,...
            'tag','para',...
            'data',set(sgmltag,...
            'tag','LiteralLayout',...
            'data',in,...
            'indent',0));
        return;
    elseif min(size(in))==1 & max(size(in))==1
        in=in{1};
    end
end

if shrinkEntries
    out=rendervariable(rptcomponent,in,logical(1),64);
    %note that this is twice as permissive as the usual inline limit of 32
else
    out=rendervariable(rptcomponent,in,logical(1),0);
end
    
if ischar(out) & ...
        (min(size(out))>1 | ...
        ~isempty(findstr(out,char(10))))
    out=set(sgmltag,...
        'tag','para',...
        'data',set(sgmltag,...
        'tag','LiteralLayout',...
        'data',out,...
        'indent',0));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellTables=LocGetCells(c);

if c.att.isArrayFromWorkspace
   cellContent={};
   if ~isempty(c.att.WorkspaceVariableName)
      try
         cellContent=evalin('base',c.att.WorkspaceVariableName);
      end
   end
else
   cellContent=c.att.TableCells;
end

if ~iscell(cellContent)
   cellContent=LocConvertToCellArray(cellContent);
end

emptyCells=find(cellfun('isempty',cellContent));
if ~isempty(emptyCells)
   [cellContent{emptyCells}]=deal('&nbsp;');
end


ccDims=size(cellContent);

cellBorders=LocReshape(c.att.cellBorders,ccDims(1:2));
cellAlign=LocReshape(c.att.cellAlign,ccDims(1:2));

if length(ccDims)<3
   ccDims(3)=1;
end


cellTables=LocMake2dCells(ccDims,[],...
   cellContent,cellBorders,cellAlign,...
   c.att.isInverted);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellTables=LocMake2dCells(ccDims,...
   history,...
   cellContent,...
   cellBorders,...
   cellAlign,...
   isInverted);

cellTables=struct('table',{},'index',{});

if ~isempty(cellContent)
   lHistory=length(history);
   lDims=length(ccDims);
   
   if lHistory+2+1<lDims
      for i=1:ccDims(lHistory+2+1)
         cellTables=[cellTables LocMake2dCells(ccDims,[history i],...
               cellContent,cellBorders,cellAlign,...
               isInverted)];
      end
   else
      for i=1:ccDims(lHistory+2+1)
         
         cellHistory=num2cell(history);
         cTable=struct('content',cellContent(:,:,cellHistory{:},i),...
            'border',cellBorders,...
            'align',cellAlign);
         
         if isInverted
            cTable=cTable';
         end
         
         cellTables(end+1)=struct('table',cTable,...
            'index',[history i]);
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function longAlign=LocUnTerse(shortAlign)

switch lower(shortAlign(1))
case 'l'
   longAlign='left';
case 'c'
   longAlign='center';
case 'r'
   longAlign='right';
case 'j'
   longAlign='justify';
otherwise
   longAlign='left';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocConvertToCellArray(in);

if isnumeric(in)
   out=num2cell(in);
elseif ischar(in)
   out=cellstr(in);
else
   out{3,3}='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function myCells=LocReshape(myCells,outDims);

if min(outDims)==0
   myCells={};
else
   inDims=size(myCells);
   
   %pare extra rows
   if inDims(1)>outDims(1)
      myCells=myCells(1:outDims(1),:);   
   end
   
   %pare extra columns
   if inDims(2)>outDims(2)
      myCells=myCells(:,1:outDims(2));   
   end
   
   %pad needed cells
   if inDims(1)<outDims(1) | ...
         inDims(2)<outDims(2) 
      myCells{outDims(1),outDims(2)}=[];
   end
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tagAttributes=LocEntryAttributes(entryStruct);

if isempty(entryStruct.border)
   tagAttributes={};
else
   switch entryStruct.border
   case 0 %no border
      rs=0;cs=0;
   case 1 %bottom only
      rs=1;cs=0;
   case 2 %right only
      rs=0;cs=1;
   case 3 %bottom and right
      rs=1;cs=1;
   end
   tagAttributes={'rowsep',rs;'colsep',cs};
end

if ~isempty(entryStruct.align)
   tagAttributes{end+1,1}='align';
   tagAttributes{end,2}=LocUnTerse(entryStruct.align);            
end         
