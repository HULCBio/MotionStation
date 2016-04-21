function [varargout] = cv_autoscale_settings(method,modelH)
%CV_AUTOSCALE_SETTINGS - Cache and apply coverage settings for SF autoscaling

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:37:17 $

	persistent CovSettingsCache;

	switch(lower(method))
	case 'save'
		CovSettingsCache = save_autoscale(CovSettingsCache, modelH);
	case 'restore'
		CovSettingsCache = restore_autoscale(CovSettingsCache, modelH);
	case 'isforce'
		varargout{1} = is_force(CovSettingsCache, modelH);
	otherwise,
		error('Unkown Method');
	end

function CovSettingsCache = save_autoscale(CovSettingsCache, modelH)

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% Get relevant coverage params and check for conflict
	recordCoverage    = strcmp(get_param(modelH, 'RecordCoverage'), 'on');
	covPath           = get_param(modelH, 'CovPath');
	covMetricSettings = get_param(modelH, 'CovMetricSettings');
	rangeCovEnabled   = ~isempty(strfind(covMetricSettings, 'r'));
	forceCov          = ~(recordCoverage && rangeCovEnabled);

	% Push an error message to the Nag controller if conflicts
	
	if isempty(modelIndex)
		% Settings don't exist for this model, append record
		CovSettingsCache = [CovSettingsCache struct('handle',       modelH,...
													'forceCov',     forceCov,...
													'enable',       recordCoverage,...
													'metricString', covMetricSettings,...
													'path',         covPath)];
	else
		% Settings exist for this model, update the record
		CovSettingsCache(modelIndex).forceCov     = forceCov;
		CovSettingsCache(modelIndex).enable       = recordCoverage;
		CovSettingsCache(modelIndex).metricString = covMetricSettings;
		CovSettingsCache(modelIndex).path         = covPath;
	end;
	
	% As the last part of saving settings we force range coverage on
	if ~recordCoverage
	    % We are forcing the model to record coverage so we should
	    % only enable range coverage because the other metrics 
	    % require a license of Simulink Verification and Validation
		set_param(modelH, 'RecordCoverage', 'on');
		set_param(modelH, 'CovMetricSettings', 'r');
	else
	    % Coverage was already enabled for the model so we just need to
	    % insure that range coverage is enabled.
    	if ~rangeCovEnabled
    		set_param(modelH, 'CovMetricSettings', [covMetricSettings 'r']);
    	end
	end


function CovSettingsCache = restore_autoscale(CovSettingsCache, modelH)

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% If model not found return early
	if isempty(modelIndex)
		return;
	end;

	% Restore settings to model
	if CovSettingsCache(modelIndex).enable
		set_param(modelH, 'RecordCoverage', 'on');
	else
		set_param(modelH, 'RecordCoverage', 'off');
	end;
	set_param(modelH, 'CovPath',           CovSettingsCache(modelIndex).path);
	set_param(modelH, 'CovMetricSettings', CovSettingsCache(modelIndex).metricString);

function result = is_force(CovSettingsCache, modelH)

	% Assume not forced
	result = 0;

	% Get index of model in global model list
	modelIndex = model_find_index(CovSettingsCache, modelH);

	% If model not found return early
	if isempty(modelIndex)
		return;
	end;

	% Determine if coverage forced for this model
	result = CovSettingsCache(modelIndex).forceCov;


function index = model_find_index(CovSettingsCache, modelH)

	if isempty(CovSettingsCache)
		index = [];
		return;
	end;

	allModels = [CovSettingsCache.handle];
	index = find(allModels == modelH);
