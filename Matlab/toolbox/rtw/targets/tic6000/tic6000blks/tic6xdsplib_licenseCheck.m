function tic6xdsplib_licenseCheck(reset)
% tic6xdsplib_licenseCheck   Checks whether the user has accepted TI's 
%    license agreement, and if not, displays the agreement and
%    asks for acceptance.  This function executes during the
%    initialization callback for each block in tic64dsplib.mdl and tic62dsplib.mdl.
%    Optional parameter RESET = 1 allows you to trigger the license 
%    display again.

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/01 16:17:04 $

blk = gcb;
sys = bdroot;

% MATLAB Preference identifiers:
group = 'MathWorks_TIC6000';
item  = 'TI_C62DSPLIB_EndUserLicenseAccepted';

% If the pref val has already been obtained from the prefs area and cached
% in this persistent variable, then we use the cached value in memory for
% efficiency.  Otherwise, we must try to get the val from the prefs area.  
persistent P
if isempty(P) & ispref(group,item),
    P = getpref(group,item);
end

if nargin<1,
    reset=0;
end
if reset,
    % Reset the acceptance flag and get out
    %
    % Note: Never "set" the acceptance flag based on the input parameter
    % Doing so would allow a "sneak path" for circumventing the license
    % text
    P = [];
    setpref(group,item,P);
    disp('TI License Agreement acceptance flag has been re-initialized.')
    return;
end

% We only do the license test on the LAST TI block in the model.
if ~is_last_TI_block(sys),
    return;
end

% If we haven't verified acceptance yet, then we ask (or ask again).
if ( isempty(P) | (~P) ) & ~strcmp(getenv('logname'),'batserve'),

    x = TiC6xLicenseGui;
    P = strcmp(x, 'Accept');

    if ~P,
        error(['You have not accepted the terms of the Texas Instruments  ' ...
               'End User License Agreement.  You cannot use any blocks ' ...
               'from the C62 or C64 DSP Library.']);
    end
    
    % Record acceptance of the license agreement:
    setpref(group,item,P);
    
end


% ----------------------------------------------
function y = is_last_TI_block(sys)

% At this point, we know we're going to fire off an error,
% so we can take some time to search the model so that we
% only fire the error for the FIRST guy.
persistent total_ti_blks seen_ti_blks

if isempty(seen_ti_blks),  % not zero, empty!
    % Reset the list, and setup to zero seen:
    
    blks_c62 = find_system(sys, ...
        'followlinks','on', ...
        'lookundermasks','on', ...
        'Regexp','on', ...
        'ReferenceBlock','^tic62dsplib');
    blks_c64 = find_system(sys, ...
        'followlinks','on', ...
        'lookundermasks','on', ...
        'Regexp','on', ...
        'ReferenceBlock','^tic64dsplib');
    total_ti_blks = length(blks_c62) + length(blks_c64);
    seen_ti_blks = 0;
end

% Now, increment seen count;
seen_ti_blks = seen_ti_blks + 1;

if (seen_ti_blks == total_ti_blks),
    % We've now seen them all
    % Reset
    total_ti_blks = [];
    seen_ti_blks = [];
    y = 1;  % alert caller to issue error --- on LAST block
else
    y = 0;  % caller should not emit error yet
end

% [EOF] tic6xdsplib_licenseCheck.m
