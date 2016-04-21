function cvclean(varargin)
%CVCLEAN Deallocate coverage data associated with model.
%
%   CVCLEAN() Deallocates coverage data associated with closed models.
%
%   CVCLEAN('ALL') Same as CVCLEAN().
%
%   CVCLEAN(MODEL) Deallocates coverage data associated with a closed model.
%
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/26 18:37:24 $

if length(varargin) == 0
	do_clean_all
else
	for this_arg = varargin'
		if strcmp(upper(this_arg), 'ALL')
			do_clean_all;
		else
			modelcov_id = cv('find', 'all', 'modelcov.name', this_arg{1});
			if ~isempty(modelcov_id)
				do_clean_model(modelcov_id, 1);
			end;
		end;
	end;
end;

function do_clean_all

modelcov_ids = cv('get', 'all', 'modelcov.id');

for this_id = modelcov_ids'
	do_clean_model(this_id, 0)
end;

function do_clean_model(modelcov_id, warn)

modelname = cv('get', modelcov_id, '.name');

if isempty(find_system('name', modelname))
	cleanmodel(modelcov_id);
elseif warn
	warning(sprintf('Model %s is open and could not be cleared.  Close %s and try again.', modelname, modelname));
end;


function cleanmodel(modelcov_id)

cv('ClearModel', modelcov_id);

