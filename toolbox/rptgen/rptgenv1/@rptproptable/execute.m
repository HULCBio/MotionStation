function out=execute(r,c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:26 $

try
   continueError=tableref(c,'CheckContinue');
catch
   continueError='';
end

if length(continueError)>0
   out='';
   status(c,continueError,2);
   return
end

tc=c.att.TableContent;
[numrows,numcols]=size(tc);
removeEmpties=[c.att.isRemoveEmptyColumns,...
      c.att.isRemoveEmptyRows];

if c.att.SingleValueMode
   contentCells{numrows,numcols*2}='';
else
   contentCells{numrows,numcols}='';
end

%-------parse cells-----------
for i=numrows:-1:1
   for j=numcols:-1:1
      if c.att.SingleValueMode
         [nameCell,valueCell]=parseproptext(c,tc(i,j),logical(0));
         contentCells(i,2*j-1:2*j)={nameCell,valueCell};
      else
         contentCells{i,j}=parseproptext(c,tc(i,j),logical(0));
      end      
   end
end

%------parse title-----------
titleEntry=struct('align','c',...
   'text',c.att.TableTitle,...
   'render',c.att.TitleRender,...
   'border',0);
prevMode=c.att.SingleValueMode;
c.att.SingleValueMode=logical(0);
titleText=parseproptext(c,titleEntry,logical(0));
c.att.SingleValueMode=prevMode;

%---------------------
colWid=validatecolumns(c);
if ~c.att.SingleValueMode
   [alignCells{1:numrows,1:numcols}]=deal(tc.align);
   [borderCells{1:numrows,1:numcols}]=deal(tc.border);
else
   [origAlign{1:numrows,1:numcols}]=deal(tc.align);
   
   alignCells={};
   %align value columns left
   alignCells(1:numrows,2:2:2*numcols)=strrep(strrep(origAlign,'c','l'),'j','r');
   %align name columns right
   alignCells(1:numrows,1:2:2*numcols-1)=strrep(strrep(origAlign,'c','r'),'j','l');
   
   %[leftBorder(1:numrows,1:numcols)]=deal(tc.border);
   %rightBorder=leftBorder;
   
   [borderCells{1:numrows,2:2:2*numcols}]=deal(tc.border);
   [borderCells{1:numrows,1:2:2*numcols-1}]=deal(tc.border);   
end   

%----Remove Empty Columns And Rows -----------
if c.att.isRemoveEmptyColumns |  c.att.isRemoveEmptyRows
   emptyCells=cellfun('isempty',contentCells);
   
   if c.att.isRemoveEmptyRows
      i=1;
      while i<=size(contentCells,1)
         if min(emptyCells(i,:)==1)
            %all cells in this row are empty
            contentCells=contentCells([1:i-1,i+1:end],:);
            alignCells=alignCells([1:i-1,i+1:end],:);
            borderCells=borderCells([1:i-1,i+1:end],:);
            
            emptyCells=emptyCells([1:i-1,i+1:end],:);
            %tc=tc([1:i-1,i+1:end],:);
            %numrows=numrows-1;
         else
            i=i+1;
         end      
      end
   end
   
   if c.att.isRemoveEmptyColumns
      j=1;
      while j<=size(contentCells,2)
         if min(emptyCells(:,j)==1)
            %all cells in this column are empty
            contentCells=contentCells(:,[1:j-1,j+1:end]);
            alignCells=alignCells(:,[1:j-1,j+1:end]);
            borderCells=borderCells(:,[1:j-1,j+1:end]);
            emptyCells=emptyCells(:,[1:j-1,j+1:end]);
            colWid=colWid(1:j-1,j+1:end);
            %tc=tc(:,[1:j-1,j+1:end]);
            %numcols=numcols-1;
         else
            j=j+1;
         end      
      end
   end %if remove empty columns
end %if removing empties

%----Create Table --------------
if ~isempty(contentCells);
   tComp=c.rptcomponent.comps.cfrcelltable;
   att=tComp.att;
   
   att.TableTitle=titleText;
   att.TableCells=contentCells;
   att.ColumnWidths=colWid;
   att.cellAlign=alignCells;
   att.isBorder=c.att.isBorder;
   att.cellBorders=borderCells;   
   att.isPgwide=logical(1);
   att.numHeaderRows=0;
   att.Footer='NONE';
   
   tComp.att=att;
   out=runcomponent(tComp,0);   
else
   out='';
   status(c,'Warning - property table empty.  Will not be rendered.',2);
end

   

