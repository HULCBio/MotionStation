function cv_pause_dialog_test(testId),
%CV_PAUSE_DIALOG_TEST - Terminate coverage sim based on dialog
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2003/09/29 15:39:46 $


	modelId = cv('get',testId,'.modelcov');
	modelH  = cv('get',modelId,'.handle');

    if strcmp(get_param(modelH, 'CovReportOnPause'), 'on')
        generate_results('pause', testId);
    end

