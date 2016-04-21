function [bio, bioNames]=patchbiopt(modelname)

% PATCHBIOPT - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.13.4.1 $ $Date: 2004/04/08 21:04:34 $

disp('### Patch bio and pt M-file')
disp('### Create sorted BIO')
% create sorted BIO C-file
[bio, bioNames] = biotarget(modelname);
disp('### Create sorted PT')
% create sorted PT C-file
pttarget(modelname);