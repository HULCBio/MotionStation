function path = xpcenvdata
% XPCENVDATA xPC Target private function.

%   XPCENVDATA returns the full path to the xPC Target environment MAT
%   file.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/04 20:09:53 $

d = fullfile(prefdir, 'xPCTargetPrefs');
if ~exist(d)
  [status, msg, msgId] = mkdir(d);
  if ~status
    error(msgId, msg);
  end
end
path = fullfile(d, 'xpcenv.mat');
