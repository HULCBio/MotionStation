function [fileOut,targetDirOut] = LocGetTMFFromRTWRoot(h, rtwroot,langDir, fileIn)
% LOCGETTMFFROMRTWROOT:
%     Search in <rtwroot>/<langDir>/<targetDirs> for template makefile
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:27:11 $


fileOut      = [];
targetDirOut = [];

targetDirs = dir(fullfile(rtwroot, langDir));
for i=1:length(targetDirs)
    if targetDirs(i).isdir
        targetDir = targetDirs(i).name;
        if ~strcmp(targetDir,'.') & ...
                ~strcmp(targetDir,'..') & ...
                ~strcmp(targetDir,'src') & ...
                ~strcmp(targetDir,'libsrc') & ...
                ~strcmp(targetDir,'lib') & ...
                ~strcmp(targetDir,'tlc')
            file = fullfile(rtwroot, langDir, targetDir, fileIn);
            if exist(file) == 2
                fileOut      = file;
                targetDirOut = targetDir;
                break;
            end
        end
    end
end
%endfunction LocGetTMFFromRTWRoot
