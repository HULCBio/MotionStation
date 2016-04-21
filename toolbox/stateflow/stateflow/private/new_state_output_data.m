function id = new_state_output_data(stateId)
%NEW_STATE_OUTPUT_DATA( stateId )
%  **** This function is for internal use!
%  **** It should not be used directly from the command line.

%   E. Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:58:51 $

[chartId, stateName] = sf('get',stateId,'state.chart','state.name');

% If state name does not contain a significant word then creating a new state output data is pointless!
if isempty(regexp(stateName,'\w*'))
	id = 0;
	return;
end

id = sf('new','data'...
	,'.linkNode.parent', chartId...
	,'.name', stateName...
	,'.scope', 'OUTPUT_DATA'...
	,'.dataType','State'...
	,'.outputState',stateId...
);






