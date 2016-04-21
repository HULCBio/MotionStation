function out=execute(c)
%EXECUTE returns a report element during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:45 $

if strcmpi(computer,'sgi')
	%SF OOPS API not compiled for SGI
	out = [];
	return;
end

adSF = zsfmethods;

currContext=getparentloop(c);
if ~isempty(currContext)
	slParent = subsref(c.zslmethods,substruct('.',currContext));
else
	slParent = '';
end

allTables = rptgen_sf.csf_truthtable.findTruthTables(adSF.currentObject.id,slParent);

if isempty(allTables)
    out = [];
    return;
end

out={};

tableComp = c.rptcomponent.comps.cfrcelltable;

att = c.att;
for i=length(allTables):-1:1
	att.RuntimeTruthTable = allTables(i);
    out{i} = locMakeTable(att, tableComp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = locMakeTable(att, tableComp)

cInfo = rptgen_sf.csf_truthtable.makeConditionCells(att);
aInfo = rptgen_sf.csf_truthtable.makeActionCells(att);

switch att.TitleMode
    case 'none'
        tTitle = '';
    case 'auto'
        tTitle = att.RuntimeTruthTable.Name;
    otherwise %case 'manual'
        tTitle = att.Title; %Note that cfrcelltable will %<varname> the title
end

%First, create the conditional table
tatt=tableComp.att;
tatt.isPgwide=logical(1);
tatt.TableCells=cInfo{1};
tatt.numHeaderRows=0+att.ShowConditionHeader;
tatt.ColumnWidths=cInfo{2};
tatt.TableTitle=tTitle;
tatt.isBorder=logical(1);
tableComp.att=tatt;

out=runcomponent(tableComp,5);

tatt.TableTitle='';

for i=3:2:size(cInfo,2)
	tatt.TableCells=cInfo{i};
	tatt.ColumnWidths=cInfo{i+1};
	tableComp.att=tatt;
	
	outA=runcomponent(tableComp,5);

	out.data = [out.data,outA.data];
end


%Next, create the actions table and extract the <tgroup>, then drop it into
%the original table
if ~isempty(aInfo{1})
	tatt.TableCells=aInfo{1};
	tatt.numHeaderRows=0+att.ShowActionHeader;
	tatt.ColumnWidths=aInfo{2};
	tableComp.att=tatt;
	
	outA=runcomponent(tableComp,5);

	out.data = [out.data,outA.data];
end