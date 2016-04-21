function varargout = slexplr(varargin)
%SLEXPLR Simulink Model Explorer for viewing and editing Simulink data objects.
%
%   This tool is obsolete - use the Design Automation Model Explorer.
%
%   See also DAEXPLR.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.24.2.2 $

if ((nargin == 1) && ...
    (strcmp(varargin{1}, 'Refresh')))
  % Redundant case - no action
else
  rt = Simulink.Root;
  ws = rt.getChildren;
  ws = ws(1);
  me = daexplr;
  me.view(ws);
end
