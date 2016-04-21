function PrepareBuildArgs(h, tlcArgs, gensettings,rtwVerbose)
%   PREPAREBUILDARGS - prepare build arguments
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2004/04/15 00:23:58 $

if isfield(gensettings,'BuildDirSuffix')
    h.StartDirToRestore = pwd;
    rtwprivate('rtwattic','setStartDir', h.StartDirToRestore);
    rtwprivate('rtwattic','setBuildDir', h.BuildDirectory);
    if rtwVerbose
      msg = ['### Generating code into build directory: ',h.BuildDirectory];
      feval(h.DispHook{:}, msg);
    end
else
    error(['Unable to locate rtwgensettings.BuildDirSuffix '...
            'within system target file']);
end

% Now handle build arguments from various source.
rtwBuildArgs = get_param(h.ModelHandle, 'RTWBuildArgs');

currentDirtyFlag = get_param(h.ModelHandle,'Dirty');

% Get build arguments from current active configuration set
configset = getActiveConfigSet(h.ModelHandle);
build_args = getStringRepresentation(configset, 'make_options');
if ~isempty(rtwBuildArgs)
 % build_args = [rtwBuildArgs ' ' build_args];
end

set_param(h.ModelHandle,'RTWBuildArgs',build_args);
CleanupDirtyFlag(h, h.ModelHandle,currentDirtyFlag);

% Get RTW root directory
GetRTWRoot(h, rtwVerbose);

%
% Get the template makefile - this must be done before invoking tlc_c or
% tlc_ada because these files cd into the build directory
LocGetTMF(h, h.ModelHandle,h.RTWRoot);

%endfunction PrepareBuildArgs


