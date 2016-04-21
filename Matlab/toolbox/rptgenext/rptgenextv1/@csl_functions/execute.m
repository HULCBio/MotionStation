function out=execute(c)
%EXECUTE generates the report content

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:50 $

fnList=c.zslmethods.WordFunctionList;

if isempty(fnList)
   out='';
   status(c,sprintf('Warning - no functions found in model.'),2);
else   
   varTable=[{'Function Name'}; fnList(:,1)];
   cWid=1;
   
   if c.att.isShowParentBlock
      varTable(:,end+1) = [{'Parent Blocks'};  fnList(:,2)];      
      cWid=[cWid,4];
   end
   
   if c.att.isShowCallingString
      varTable(:,end+1) = [{'Calling string'};  fnList(:,3)];      
      cWid=[cWid,2];
   end
   
   tableComp=c.rptcomponent.comps.cfrcelltable;
   att=tableComp.att;
   att.TableTitle=c.att.TableTitle;
   att.TableCells=varTable;
   att.ColumnWidths=cWid;
   att.isBorder=c.att.isBorder;
   att.numHeaderRows=1;
   att.Footer='NONE';
   tableComp.att=att;
   
   out=runcomponent(tableComp,5);   
end
