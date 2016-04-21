function out=execute(c)
%EXECUTE generate report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:23 $


verStruct=evalin('base','ver');

%these strings broken out for i18n
switch c.rptcomponent.Language
%case 'dege'
%   nString='Name';
%   vString='Version';
%   rString='Release';
%   dString='Datum';
otherwise
   nString='Name';
   vString='Version';
   rString='Release';
   dString='Date';
end

tableCells={verStruct.Name}';
hRow={nString};
colWid=3;

if c.att.isVersion
   tableCells=[tableCells {verStruct.Version}'];
   colWid=[colWid 1];
   hRow{end+1}=vString;
end

if c.att.isRelease
   tableCells=[tableCells {verStruct.Release}'];
   colWid=[colWid 1];
   hRow{end+1}=rString;
end

if c.att.isDate
   tableCells=[tableCells {verStruct.Date}'];
   colWid=[colWid 2];
   hRow{end+1}=dString;
end

if c.att.isHeaderRow
   tableCells=[hRow;tableCells];
end

tableComp=c.rptcomponent.comps.cfrcelltable;
att=tableComp.att;

att.isPgwide=logical(1);
att.TableCells=tableCells;
att.numHeaderRows=c.att.isHeaderRow;
att.ColumnWidths=colWid;
att.TableTitle=c.att.TableTitle;
att.isBorder=c.att.isBorder;

tableComp.att=att;

out=runcomponent(tableComp,5);

%out=tableCells;