function checkBuildLogForErrors (h)

% $RCSfile: checkBuildLogForErrors.m,v $
% $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:28 $
% Copyright 2003-2004 The MathWorks, Inc.

logName = 'cc_build_Custom_MW.log';
if ~exist(logName,'file')
    error(['CCS build log file does not exist!']);
end
fid = fopen(logName);
[logText,count] = fscanf(fid,'%c');
fclose(fid);

% 'Build Complete' must happen within 60 chars from end
% '0 Errors' must happen after 'Build Complete'
found1 = findstr(logText,'Build Complete');
found2 = findstr(logText,'0 Errors');
if isempty(found1) | ((found1-count)>60) | isempty(found2)
    error(['CCS build log file does not indicate' ...
            ' completed build.  Please investigate.']);
end

% EOF  checkBuildLogForErrors.m
