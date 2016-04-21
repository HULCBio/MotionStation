function [varargout] = namelengthmax(varargin)
%NAMELENGTHMAX Maximum length of MATLAB function or variable name.
%
%   NAMELENGTHMAX returns the maximum length that a MATLAB
%   name can have.  MATLAB names include:
%      variable names
%      structure field names
%      function names
%      Simulink model names
%
%   See also GENVARNAME.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/03/17 20:05:26 $
%   Built-in function.

if nargout == 0
  builtin('namelengthmax', varargin{:});
else
  [varargout{1:nargout}] = builtin('namelengthmax', varargin{:});
end
