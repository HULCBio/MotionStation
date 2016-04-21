function  deleteObjectFiles_TItarget(modelInfo);
% remove object files

% $RCSfile: deleteObjectFiles_TItarget.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:37:02 $
% Copyright 2001-2003 The MathWorks, Inc.

useDSPBIOS = isUsingDSPBIOS_TItarget(modelInfo);

objectFiles =  getProjectFiles_TItarget(modelInfo.name,'object',useDSPBIOS);

w = warning; 
warning off;
for i=1:length(objectFiles),
    delete(objectFiles{i});
end
warning(w);

% [EOF] deleteObjectFiles_TItarget.m
