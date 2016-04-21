function varargout = cvtest( varargin )
%CVTEST  Test Specification
%
%   CLASS_ID = CVTEST( ROOT ) Create a test specification for the Simulink
%   model containing ROOT.  ROOT can be the name of the Simulink model or the 
%   handle to a Simulink model.  ROOT can also be a name or handle to a 
%   subsystem within the model, in which case only this subsystem and its 
%   descendents are instrumented for analysis.
%
%   CLASS_ID = CVTEST( ROOT, LABEL) creates a test with the given label. The
%   label is used when reporting results. 
%
%   CLASS_ID = CVTEST( ROOT, LABEL, SETUPCMD) creates a test with a setup
%   command that is executed in the base MATLAB workspace just prior to running
%   the instrumented simulation.  The setup command is useful for loading data
%   just prior to a test.
%
%   See also CVSIM, CVSAVE, CVLOAD.

% 	Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.14.2.2 $  $Date: 2004/04/15 00:37:08 $

if check_cv_license==0
    error(['Failed to check out Simulink Verification and Validation license,', ...
           ' required for model coverage']);
end

switch nargin
case 0 % display help message
	if nargout==0, help('cvtest');
	else, varargout{1} = help('cvtest');
	end
case 1 % could be create, or id conversion
	switch class(varargin{1})
	case 'double' % create a new test object for the
        if ishandle(varargin{1})
    		[modelId,path] = resolve_model_and_path(varargin{1});
    		cvtest.id = create_new_test(modelId,path);
        elseif cv('ishandle',varargin{1})
            if cv('get',varargin{1},'.isa')==cv('get','default','testdata.isa'),
           		cvtest.id = varargin{1};
            else
                error(sprintf('CV object #%s should be a testdata object',varargin{1}));
            end
        else
            error('Bad input');
        end
	case 'char' % create a new test object for the
		[modelId,path] = resolve_model_and_path(varargin{1});
		cvtest.id = create_new_test(modelId,path);
	case 'cvtest'
		varargout{1} = varargin{1};
	otherwise
	end
	varargout{1} = class(cvtest,'cvtest');
case 2 
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
	varargout{1} = class(cvtest,'cvtest');
case 3 
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
	install_setup_cmd(cvtest.id,varargin{3})
	varargout{1} = class(cvtest,'cvtest');
otherwise
	[modelId,path] = resolve_model_and_path(varargin{1});
	cvtest.id = create_new_test(modelId,path);
	install_test_label(cvtest.id,varargin{2})
	install_setup_cmd(cvtest.id,varargin{3})
	varargout{1} = class(cvtest,'cvtest');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLVE_MODEL_AND_PATH - Find the Simulink model and
% its associated coverage object and resolve the path
% to the coverage root.
function [modelId,path] = resolve_model_and_path(block)

	try,
		if ischar(block)
			block = get_param(block,'Handle');
		end
		model = bdroot(block);
	catch,
		error(sprintf('Invalid test object. Simulink error:\n%s',lasterr));
	end
		
	path = '';
	if (block ~= model)
		path = get_param(block,'Parent');
		path = [path '/' get_param(block,'Name')];
        bdName = get_param(model,'Name');
		bdlength = length(bdName);
		path = path((bdlength+2):end);	
	end

	modelId = get_param(model,'CoverageId');
	if ~cv('ishandle',modelId)
		modelId = cv('Private','cvmodel',model);
	end	
					

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE_NEW_TEST - Find the Simulink model and
% its associated coverage object and resolve the path
% to the coverage root.
function testId = create_new_test(modelId,path);

	% Create the testdata object
	testId = cv('new', 	'testdata'  					...
			,'.type',				    'CMDLINE_TST' 	...
			,'.modelcov',				modelId 		...
			,'.rootPath',				path	 		...
			);

	%Create metrics that match models
	%NOTE: New default behavior is to match metric settings of model
	settingStr  = get_param(cv('get', modelId, '.name'), 'CovMetricSettings');
	metricNames = cv('Private', 'cv_metric_names', [], settingStr);
	for i = 1:length(metricNames)
		cv('set', testId, ['testdata.settings.' metricNames{i}], 1);
	end; %for

	% Add this test to the link-list of pending tests
	cv('PendingTestAdd',modelId,testId);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTALL_TEST_NAME - Set the setupcmd string.
function install_test_label(testId,label)

	if ~ischar(label)
		error('Bad argument type for the test name')
	end

	cv('set',testId,'.label',label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INSTALL_SETUP_CMD - Set the setupcmd string.
function install_setup_cmd(testId,cmd)

	if ~ischar(cmd)
		error('Bad argument type for the MATLAB setup command string')
	end

	cv('set',testId,'.mlSetupCmd',cmd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK_CV_LICENSE 
function status = check_cv_license

[wState] = warning;
warning('off');
try,
    a = cv('get','default','slsfobj.isa');
    if isempty(a)
        status = 0;
    else
    	status = 1;
    end
catch
    status = 0;
end
warning(wState);

