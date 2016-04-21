function deleteOldProjectFiles_TItarget (modelInfo)

% $RCSfile: deleteOldProjectFiles_TItarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:07:44 $
%% Copyright 2002-2003 The MathWorks, Inc.

dirExtension = '_c6000_rtw';

projectDir = fullfile(pwd,[modelInfo.name dirExtension]);

% check if the working folder exists, and if it does,  ...

if exist(projectDir,'dir'),    
    % delete older project file
    projectName = fullfile(projectDir,filesep,[modelInfo.name '.pjt']);
    if exist(projectName,'file'),
        delete(projectName);
    end
    % delete old C-lib source and header files
    clibFileName = fullfile(projectDir,filesep,'MW_c62xx_clib.c');
    if exist(clibFileName, 'file'),
        delete(clibFileName);
    end
    clibFileName = fullfile(projectDir,filesep,'MW_c62xx_clib.h');
    if exist(clibFileName,'file'),
        delete(clibFileName);
    end
    
    % delete old <modelname>_data source file if exists
    csrcName = fullfile(projectDir,filesep,[modelInfo.name '_data.c']);
    if exist(csrcName),
        delete(csrcName);
    end 
end


% [EOF] deleteOldProjectFiles_TItarget.m