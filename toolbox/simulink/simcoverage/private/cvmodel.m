function id = cvmodel(slHandle)
%CVMODEL Create a coverage object for the Simulink model
%
%  id = cvmodel(slHandle) Create the coverage object 
%  for the given Simulink model.

% 	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/03/23 02:59:12 $

	% Safety check
	if get_param(slHandle,'CoverageId')~=0
		error('Model has non-zero coverage Id');
	end

    % Check if an existing modelcov object has the same name
    modelName = get_param(slHandle,'Name');
    modelIds = cv('find','all','modelcov.name',modelName);

    if length(modelIds)>1
        error('Internal coverage tool error, more than one id for same model');
    end

    if isempty(modelIds)
    	id  = cv('new', 'modelcov' ...
    				,'.name',		modelName ...
    				,'.handle',		slHandle ...
    			 );
	else
        id = modelIds;
        cv('set',id,'modelcov.handle',slHandle);
    end
	set_param(slHandle,'CoverageId',id);
