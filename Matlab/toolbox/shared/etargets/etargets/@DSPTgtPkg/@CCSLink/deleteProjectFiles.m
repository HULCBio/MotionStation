function deleteProjectFiles (h, modelInfo)

% $RCSfile: deleteProjectFiles.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:31 $
%% Copyright 2003-2004 The MathWorks, Inc.

ProjectDirExtension = '_c2000_rtw';

projectDir = fullfile (pwd, [modelInfo.name ProjectDirExtension]);

% check if the working folder exists, and if it does,  ...

if exist (projectDir,'dir'),    

    % delete older project file
    projectName = fullfile (projectDir,filesep,[modelInfo.name '.pjt']);
    if exist (projectName,'file'),
        delete (projectName);
    end
    
    % delete old <modelname>_data source file if exists
    csrcName = fullfile (projectDir,filesep,[modelInfo.name '_data.c']);
    if exist (csrcName),
        delete (csrcName);
    end 
    
end

% [EOF] deleteProjectFiles.m