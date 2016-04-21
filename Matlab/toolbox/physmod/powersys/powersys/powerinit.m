function varargout = powerinit(varargin)
% POWERINIT is renamed POWER_INIT. Please see the help for POWER_INIT.
%   The command name is kept for backwards compatibility

%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.4 $
  
if nargout == 0,
  power_init_pr(varargin{:});
else
  [varargout{1:nargout}] = power_init_pr(varargin{:});
end

% [EOF] powerinit.m
