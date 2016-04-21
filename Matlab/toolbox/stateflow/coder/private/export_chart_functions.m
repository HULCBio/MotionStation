function mustExportChartFunctions = export_chart_functions(chart)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.16.1 $  $Date: 2004/04/13 03:12:39 $

	mustExportChartFunctions = 0;
	if sf('get',chart,'chart.exportChartFunctions')
		mustExportChartFunctions = 1;
	end
