function dspsafe_set_param(varargin)
% DSPSAFE_SET_PARAM Signal Processing Blockset "Safe" set_param function

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:07:50 $

if nargin < 3
    error('Invalid number of arguments to dspsafe_set_param');
end

% The following try-catch statement will catch all errors except those
% caused by invalid initialization commands in the set_param.  So, if
% an error is caused by an 'Undefined function or variable' in a sub-
% block, this function will pass that error.  Be very careful when
% you use this function.  It is primarily intended to pass a Simulink
% error: Simulink does an eval_params immediately after a set_param, and
% if the eval_params fails on some other parameter, even if the set_param
% went through okay the Simulink process throws an error and reports it
% as a set_param error.  This function is *only* a *temporary*
% work-around until R12FCS, by which time Simulink has promised to fix
% the way they handle set_param.
%
% For further info, see:
%   Geck number G82015 (Signal Processing Blockset geck about using work-around)
%   Geck number G81872 (Simulink geck about mask initialization error)
%
% 04/05/01 - added 'S-function' option for the Random Source block mask
% helper function.  Since the error is in the S-function, if it is a real
% problem, it will be caught again at a later point (e.g, in
% mdlCheckParameters).
try 
    set_param(varargin{1}, varargin{2:length(varargin)});
catch
    ret_err = lasterr;
    if isempty(findstr(ret_err, xlate('Undefined function or variable'))) & ...
          isempty(findstr(ret_err, xlate('S-function')))
        error(ret_err);
    end
end

% [EOF] dspsafe_set_param.m
