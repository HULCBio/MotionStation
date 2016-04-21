function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:57 $

out='';

mdlName=c.zslmethods.Model;

if ~isempty(mdlName)
   try
      mdlHistory=get_param(mdlName,'ModifiedHistory');
   catch
      mdlHistory='';
      status(c,sprintf('Warning - could not get model history'),2);
   end
   
   if ~isempty(mdlHistory)
      if c.att.isLimitRevisions
         numLimit=c.att.numRevisions;
      else
         numLimit=inf;
      end
      
      histInfo=parsehistory(c,mdlHistory,numLimit);
      
      if ~isempty(histInfo)
         tableComp=c.rptcomponent.comps.cfrcelltable;
         
         [hCells,colWid]=LocProcessStructure(c,histInfo);
         att=tableComp.att;
         att.isPgwide     = logical(1);
         att.TableTitle   = c.att.TableTitle;
         att.isBorder     = c.att.isBorder;
         att.TableCells   = hCells;
         att.ColumnWidths = colWid;
         att.ShrinkEntries = logical(0);
         tableComp.att=att;
         
         out=runcomponent(tableComp,0);
      else
         status(c,sprintf('Warning - Could not parse model history. Change log not created.'),2);
      end
   else
      status(c,sprintf('Warning - Model history is empty. Change log not created.'),2);
   end
else
   status(c,sprintf('Warning - No model found for change log'),2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hCells,colWid]=LocProcessStructure(c,histInfo)


colWid=[1 2 3 5];

headerCells={xlate('Ver') xlate('Name') xlate('Date') xlate('Description')};
%headerCells={'Version' 'Bearbeiter' 'Datum' 'Aenderung'};
   
hCells=[headerCells;histInfo];

whichCol=find([c.att.isVersion c.att.isAuthor c.att.isDate c.att.isComment]);

colWid=colWid(whichCol);
hCells=hCells(:,whichCol);


