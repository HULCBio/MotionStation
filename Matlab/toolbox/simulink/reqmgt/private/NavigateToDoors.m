function NavigateToDoors(obj, index)

% Copyright 2004 The MathWorks, Inc.

	% Get DOORS COM object
	hDOORS = resolve_com_doors();

	% Compute complete path to model
	modelH    = rmi('getModelH', obj);
	modelName = get_param(modelH, 'Name');

	% Validate index
	count = rmi('count', obj);
	index = max(index, 1);
	index = min(index, count);

	% Get requirements for object
	reqs = rmi('get', obj, index, 1);

	if isfield(reqs, 'ids') && (length(reqs.ids) > 0)
		% Start selection
		hDOORS.runStr(['dmiSelectObjectStart_("' modelName '");']);
		if ~isempty(hDOORS.Result)
			error(sprintf('%s \n Try synchronizing first.', hDOORS.Result));
		end;

		% Select
		hDOORS.runStr(['dmiSelectObject_("' reqs.ids{1} '");']);
		if ~isempty(hDOORS.Result)
			error(hDOORS.Result);
		end;

		% End selection
		hDOORS.runStr(['dmiSelectObjectEnd_();']);
		if ~isempty(hDOORS.Result)
			error(hDOORS.Result);
		end;
	else
		error('Model must be synchronized prior to navigating to DOORS');
	end;

