function [tgtprefs, errormsg] = getTargetPreferences_tic2000

% $RCSfile: getTargetPreferences_tic2000.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:04 $
%% Copyright 2003-2004 The MathWorks, Inc.

errormsg = [];
tgtprefs = [];

% for now, return data for first block found (assume top level)
tgtprefblocks = find_system (gcs,'FollowLinks','on','LookUnderMasks','on', 'MaskType','c2000 Target Preferences');
if ( length(tgtprefblocks)<1 )
    errormsg = 'This model does not contain any target preference blocks.'; 
    return;
end

userdata = get_param(tgtprefblocks{1},'userdata');
tgtprefs = userdata.tic2000TgtPrefs;             

% [EOF] getTargetPreferences_tic2000.m