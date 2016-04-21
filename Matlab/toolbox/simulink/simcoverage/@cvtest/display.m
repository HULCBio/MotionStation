function display( cvtest )

%	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/03/23 03:01:52 $

id = cvtest.id;

% Build the length structure
allMetrics = cv('Private','cv_metric_names');
metricCnt = length(allMetrics);

disp(' ');
disp([inputname(1),' = ... cvtest']);
disp(sprintf('            id: %g (READ ONLY)',id));
disp(sprintf('      modelcov: %g (READ ONLY)',cv('get',id,'testdata.modelcov')));
disp(sprintf('      rootPath: %s',cv('get',id,'testdata.rootPath')));
disp(sprintf('         label: %s',cv('get',id,'testdata.label')));
disp(sprintf('      setupCmd: %s',cv('get',id,'testdata.mlSetupCmd')));
disp(sprintf('      settings: [%dx1 struct]',metricCnt));
disp(' ');

