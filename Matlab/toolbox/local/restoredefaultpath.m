%RESTOREDEFAULTPATH Restores the MATLAB search path to installed products.
%   RESTOREDEFAULTPATH restores the MATLAB search path to the paths of all
%   the installed MathWorks products.  The restoration is for the current
%   session of MATLAB only.
%
%   If being used to recover from a faulty path during startup, this
%   function is not guaranteed to recover the full functionality of MATLAB.
%   However, it will recover access to the functions on the installed
%   MATLAB search path for the current MATLAB session.  You should consult
%   the documentation on PATHDEF for a more robust solution.
%
%   See also PATH, PATHTOOL, SAVEPATH, PATHDEF.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/25 21:35:31 $

% Temporarily allow builtins.
% The following feature is not supported outside of this context, and may 
% cause undesired effects if used elsewhere.
RESTOREDEFAULTPATH_bistat = feature('allowbuiltins','on');

% Get system path to Perl (MATLAB installs Perl on Windows)
if strncmp(computer,'PC',2)
    RESTOREDEFAULTPATH_perlPath = [matlabroot '\sys\perl\win32\bin\perl.exe'];
    RESTOREDEFAULTPATH_perlPathExists = exist(RESTOREDEFAULTPATH_perlPath,'file')==2;
else
    [RESTOREDEFAULTPATH_status, RESTOREDEFAULTPATH_perlPath] = unix('which perl');
    RESTOREDEFAULTPATH_perlPathExists = RESTOREDEFAULTPATH_status==0;
    RESTOREDEFAULTPATH_perlPath = (regexprep(RESTOREDEFAULTPATH_perlPath,{'^\s*','\s*$'},'')); % deblank lead and trail
end

% If Perl exists, execute "getphlpaths.pl"
if RESTOREDEFAULTPATH_perlPathExists
    RESTOREDEFAULTPATH_cmdString = sprintf('%s "%s" "%s"', ...
        RESTOREDEFAULTPATH_perlPath, which('getphlpaths.pl'), matlabroot);
    [RESTOREDEFAULTPATH_perlStat, RESTOREDEFAULTPATH_result] = system(RESTOREDEFAULTPATH_cmdString);
else
    feature('allowbuiltins',RESTOREDEFAULTPATH_bistat);
    error('MATLAB:restoredefaultpath:PerlNotFound','Unable to find Perl executable.');
end

% Check for errors in shell command
if (RESTOREDEFAULTPATH_perlStat ~= 0)
    feature('allowbuiltins',RESTOREDEFAULTPATH_bistat);
    error('MATLAB:restoredefaultpath:PerlError','System error: %s\nCommand executed: %s', ...
        RESTOREDEFAULTPATH_result,RESTOREDEFAULTPATH_cmdString);
end

% Set the path
matlabpath(RESTOREDEFAULTPATH_result);

% Reset allowbuiltins state
feature('allowbuiltins',RESTOREDEFAULTPATH_bistat);

clear('RESTOREDEFAULTPATH_*');

% Create this variable so that if MATLABRC is run again, it won't try to
% use pathdef.m
RESTOREDEFAULTPATH_EXECUTED = true;