function  deleteObjectFiles (h, modelInfo);
% remove object files

% $RCSfile: deleteObjectFiles.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:06:30 $
% Copyright 2003-2004 The MathWorks, Inc.

objectFiles = h.getProjectFileList (modelInfo.name, modelInfo.buildOpts.sysTargetFile, 'object');

for i=1:length (objectFiles),
    delete (objectFiles{i});
end

% [EOF] deleteObjectFiles.m
