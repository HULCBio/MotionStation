function  loadCCSProject (h, ccsObj, modelName)

% $RCSfile: loadCCSProject.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:38 $
% Copyright 2003-2004 The MathWorks, Inc.

h.checkBuildLogForErrors;

coffFile = [modelName '.out'];

if ~exist(coffFile,'file'),
    error(sprintf(['COFF file could not be found.' ...
             '\nMake sure that the build was successful '...
             'and that the selected board is of the correct type.']));
end

try
    disp('### Downloading COFF file'); 
    ccsObj.load(coffFile,100);
catch
    error(sprintf(['There was a problem loading the COFF file.  ' ... 
            '\nMake sure that the build was successful '...
            'and that the selected board is of the correct type.']));
end

disp(['### Downloaded: ' coffFile]);

% [EOF] loadCCSProject.m
