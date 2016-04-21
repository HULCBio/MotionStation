function curblock=gcb(sys)
%GCB Get the full block path name of the current Simulink block.
%   GCB returns the full block path name of the current block in the current
%   system.  During editing, the current block is the one most recently
%   clicked upon.  During simulation of a system containing S-function
%   blocks, the current block is the S-function block currently executing
%   its corresponding MATLAB function.  During callbacks, the current block
%   is the one whose callback is being executed.  During evaluation of the
%   MaskInitialization string, the current block is the one whose mask is
%   being evaluated.
%   
%   GCB('SYS') returns the full block path name of the current block in the
%   specified system.
%   
%   See also GCBH, GCS.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.19 $

cs = [];
cb = [];
if nargin < 1,
  %
  % get the current system, and if nonempty get its current block
  %
  cs = gcs;
  if ~isempty(cs),
    cb = get_param(cs,'CurrentBlock');
  end
else
  cs = sys;
  cb = get_param(cs,'CurrentBlock');
end

%
% construct the full path name for the current block
%
curblock = '';
if ~isempty(cb)
  curblock = [cs '/' cb];
end

% end gcb
