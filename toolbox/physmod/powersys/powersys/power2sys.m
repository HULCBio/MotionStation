function varargout = power2sys(varargin)
% POWER2SYS is renamed POWER_ANALYZE. Please see the help for POWER_ANALYZE.
%   The command name is kept for backwards compatibility

%   Copyright 1997-2003 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.2.2.4 $

% add-on by P.Brunelle
if nargin==2
    % The 'options' argument is probably defined.
    % Add 'V2' in the option string. This will tell power_analyse
    % that power2sys is used to analyze an old SPS or PSB model.
    varargin{2} = ['V2',varargin{2}];
end % end of add-on.
       
if nargout == 0,
  power_analyze_pr(varargin{:});
else
  [varargout{1:nargout}] = power_analyze_pr(varargin{:});
end
  
% [EOF] power2sys.m
