function out=execute(c)
%EXECUTE returns a string during generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:01 $

%generate the vector of object ids to be reported


out=sgmltag;

if ~rgsf( 'is_parent_valid', c )
		[validity, errMsg] = rgsf( 'is_parent_valid', c );
		compInfo = getinfo( c );
		status(c, sprintf('%s error: this component %s',compInfo.Name, errMsg) ,1);
	return;
end

rptgenSF = c.zsfmethods;
% if we have sl parent or manual list, then getobjects, else report on all charts
if strcmp( c.att.LoopType, '$auto' ) & isempty( rgsf('get_slsf_parent', c ) )
   chartIds = sf('get','all','chart.id');
   badList = [];
else
	[chartIds, badList] = getobjects( c );
end

if ~isempty( badList )
   warn_bad_blocks( c, badList );
end

if isempty( chartIds )
	compInfo = getinfo( c );
	status(c, sprintf('Warning (%s): report list is empty',compInfo.Name ) ,2);
	return;
end

% remove from the report list objects that are already on the full report list
% because they are already reported.
if ~isempty( rptgenSF.reportList)
	commonObjs = ismember( chartIds, rptgenSF.reportList );
	chartIds( commonObjs ) = [];
end
rptgenSF.chartLoop.charts = chartIds;
chartList = chartIds;
chartList(:,2) = 1;

myChildren=children(c);

for i = 1:length( chartIds )
   if c.rptcomponent.HaltGenerate
      status(c,'Chart Loop execution halted',2);
      break
   end
   rptgenSF.chartLoop.id = chartIds(i);
   chartName=strrep(sf('get', chartIds(i), 'chart.name'),sprintf('\n'),' ');
   status(c,sprintf('Looping on Stateflow chart %s', chartName),3);
   % assign rgtag to the chart if it hasnt't been done already
   rgsf('assign_rg_tag', chartIds(i), 'chart' );
   out=[out;runcomponent(myChildren)];
   rptgenSF.reportList = [ chartIds(i); rptgenSF.reportList ];
end

%cleanup
rptgenSF.chartLoop.charts = [];


