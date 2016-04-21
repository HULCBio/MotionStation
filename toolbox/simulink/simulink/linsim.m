function [t,x,y] = linsim(sys, time, X0, V1_Options, ut, varargin)
%LINSIM Simulink 1.x LINSIM integration algorithm.
%   LINSIM is obsolete and will be eliminated in future versions.  Use SIM
%   instead.  LINSIM is mapped to the Simulink 3 'ode45' algorithm.
%
%   See also SIM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.29 $

%==============================================================================
% Post obsolete message and do some error checking
%==============================================================================

warning([upper(mfilename) ' is obsolete and will be eliminated in future ' ...
         'versions.  Use SIM instead.']);

msg = nargchk(2,inf,nargin);
if (~isempty(msg)),
  error(msg);
end

%==============================================================================
% Try to load the block diagram, it may be an M-file (1.3 style), in which
% case sim will treat it as an S-function.  A simple call here will force it
% into memory if it's a block diagram.
%==============================================================================

if exist(sys)==2,
  eval(sys,'');
end

%==============================================================================
% Initialize any missing input parameters (besides varargin)
%==============================================================================

if exist('X0') == 0,
  X0 = [];
end
if exist('V1_Options') == 0,
  V1_Options = zeros(1,6);
end
if exist('ut') == 0,
  ut = [];
end


%==============================================================================
% Map V1.3 options to V1.2 options
%==============================================================================

simOptions = compat13('ode45',X0,V1_Options);

%================================================================
% Call the SIM command
%================================================================

% The code before and after the call to sim copies the ToWorkspace
% variables to the caller workspace.
% Note: we must use unique variables names at this point to be
%       distinct from ToWorkspace variable names.
sys_cp2wksp = sys;
[t_cp2wksp,x_cp2wksp,y_cp2wksp] = sim(sys, time, simOptions, ut, varargin{:});

% Copy ToWorkspace variables to the caller workspace.
names_cp2wksp = find_system(sys_cp2wksp,'LookUnderMasks','all', ...
                            'BlockType', 'ToWorkspace');
for i_cp2wksp = 1:length(names_cp2wksp)
  varname_cp2wksp = get_param(names_cp2wksp{i_cp2wksp}, ...
                              'VariableName');
  assignin('caller', varname_cp2wksp, eval(varname_cp2wksp));
end

% Now safe to use t, x, and y
t = t_cp2wksp;
x = x_cp2wksp;
y = y_cp2wksp;
