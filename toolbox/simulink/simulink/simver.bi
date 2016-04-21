function [varargout] = simver(varargin)
%SIMVER Indicates the version of the program with which the model was saved.
%   SIMVER(V) indicates that the Simulink model was saved with version V of 
%   the program. This function is used to allow old models to be translated to 
%   any new save format that is employed.
%
%   This function is only used within M-files containing saved Simulink models.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.18.2.2 $
%   Built-in function.

if nargout == 0
  builtin('simver', varargin{:});
else
  [varargout{1:nargout}] = builtin('simver', varargin{:});
end
