function success = HilBlkEnforceCodegenConstraints(blk)

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:21 $

% File called from TLC; needs special error handling

success = false;  % Only set to true if file completes

UDATA = get_param(blk,'UserData');

rtwOpts = get_param(gcs,'RtwOptions');
% Ensure that block's board matches Target board.  xxx


d = UDATA.funcDecl;
for k = 1:UDATA.numArgs,
    if strcmp(UDATA.args(k).portAssign,'Input port'),
        % Should have const qualifier
        % xxx  need to get qualifier reliably
    end
end

success = true;