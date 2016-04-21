function result = rmchart(modelname, block)
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $   $Date: 2004/03/21 23:08:31 $

	result = {};
	
	% Get block handle
	blockH  = get_param(block, 'Handle');
	chartID = sf('Private', 'block2chart', blockH);
	
	% Get all the items hierarchly.
	result = rmchartrecur(result, chartID, 0);
