function [success, errorMessage] = sf_mk_dir(parentDirName,childDirName)
% A temporary (???) fix for the slowdown introduced by G187919
% We use a simple system call to do a mkdir which is cutting down
% our testing times by 3 times.

% Copyright 2003 The MathWorks, Inc.

if(1)
    wd = cd(parentDirName);
    dos(['mkdir ',childDirName]);
    cd(wd);
    success = 1;
    errorMessage = '';
else
    [success, errorMessage] = mkdir(parentDirName,childDirName);
end