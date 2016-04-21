function varargout = circ2ss(varargin)
% CIRC2SS is renamed POWER_STATESPACE. Please see the help for POWER_STATESPACE.
%         The command name is kept for backward compatibility.

%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.4 $

if nargout == 0,
  power_statespace_pr(varargin{:});
else
  [varargout{1:nargout}] = power_statespace_pr(varargin{:});
end

% [EOF] circ2ss.m

