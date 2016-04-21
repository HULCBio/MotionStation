function display( cvdata )

%	Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/03/30 16:08:52 $

% Use subsref to get the id.  This allows for error checking.
ref.type = '.';
ref.subs = 'id';
id       = subsref(cvdata,ref);

% Build the length structure
allMetrics = cv('Private','cv_metric_names');
metricCnt = length(allMetrics);

if id > 0    
    rootId = cv('get',id,'.linkNode.parent');
    

    % Print the display
    disp(' ');
    disp([inputname(1),' = ... cvdata']);
    disp(sprintf('           id: %g',id));
    if isDerived(cvdata)
        disp(sprintf('         type: DERIVED_DATA'));
    else
        disp(sprintf('         type: TEST_DATA'));
    end
    disp(sprintf('         test: cvtest object'));
    disp(sprintf('       rootID: %g',rootId));
    disp(sprintf('     checksum: [4x1 struct]'));
    disp(sprintf('    startTime: %s',cv('get',id,'testdata.startTime')));
    disp(sprintf('     stopTime: %s',cv('get',id,'testdata.stopTime')));
    disp(sprintf('      metrics: [%dx1 struct]',metricCnt));
    disp(' ');
else

    
    % Print the display
    disp(' ');
    disp([inputname(1),' = ... cvdata']);
    disp(sprintf('           id: 0'));
    disp(sprintf('         type: DERIVED_DATA'));
    disp(sprintf('         test: []'));
    disp(sprintf('       rootID: %g',cvdata.localData.rootId));
    disp(sprintf('     checksum: [4x1 struct]'));
    disp(sprintf('    startTime: %s',cvdata.localData.startTime));
    disp(sprintf('     stopTime: %s',cvdata.localData.stopTime));
    disp(sprintf('      metrics: [%dx1 struct]',metricCnt));
    disp(' ');
end