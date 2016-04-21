function cvenable(model, testName, varargin)
%CVENABLE Turn on coverage instrumentation for a Simulink model
%
%   CVENABLE(MODEL, TESTNAME) Create a new test at the start of
%   the next simulation of MODEL with the name TESTNAME.
%
%   CVENABLE(MODEL, TESTNAME, Property, value, ...) Override the 
%   default value of test properties.
%
%   See also CVTEST, CVSIM.

%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.2 $  $Date: 2004/04/15 00:36:56 $


    if check_cv_license==0
        error(['Failed to check out Simulink Verification and Validation license,', ...
               ' required for model coverage']);
    end

	% Check if a cv object already exists
	modelH = get_param(bdroot(model),'Handle');
	cvModel = get_param(modelH,'CoverageId');
	if (cvModel > 0)
		% Check if a testSpec with the same name exists
		set_param(modelH,'RecordCoverage','on');
	else
		cvModel = cvmodel(modelH);
		set_param(modelH,'RecordCoverage','on');
	end
	
	
	% Create the testdata object
	test = cv('new', 	'testdata'  		...
			,'.type',				    'CMDLINE_TST' 	...
			,'.modelcov',				cvModel 	    ...
			,'.label',					testName 	    ...
			,'.settings.decision',		1   	        ...
			,'.settings.condition',		0	 	        ...
			);
	
	% Set additional properties if they exist
	if nargin > 2
		cv('set',test,varargin{:});
	end

	% Install the new testSpec as the activeTest
	cv('set',cvModel,'.activeTest',test);

	