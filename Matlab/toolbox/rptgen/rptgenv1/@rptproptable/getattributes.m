function att=getattributes(r,Title,numRows,numCols)
%GETATTRIBUTES constructs default attributes for rptproptable subclasses

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:27 $

if nargin<4
   numCols=2;
   if nargin<3
      numRows=2;
      if nargin<2
         Title='Report Generator Property Table';
      end
   else
      numRows=max(numRows,1);
   end
else
   numCols=max(numCols,1);
end

dcell.align='c';
dcell.text='';
dcell.render=1;
dcell.border=3;

%   case 0 %no border
%   case 1 %bottom only
%   case 2 %right only
%   case 3 %bottom and right


[mytable(1:numRows,1:numCols)]=deal(dcell);

CW=ones(1,numCols);

att=struct('TableTitle',Title,...
   'isBorder',logical(1),...
   'TitleRender',1,...
   'ColWidths',CW,...
   'TableContent',mytable,...
   'SingleValueMode',logical(0),...
   'isRemoveEmptyColumns',logical(0),...
   'isRemoveEmptyRows',logical(1));