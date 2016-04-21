function isChartInputData = is_chart_input_data(data)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.16.1 $  $Date: 2004/04/13 03:12:39 $


	if(~isempty(sf('get',sf('get',data,'data.linkNode.parent'),'chart.id')) & ~isempty(sf('find',data,'data.scope','INPUT_DATA')))
		isChartInputData = 1;
	else
		isChartInputData = 0;
	end
