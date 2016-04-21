function [varargout] = functions(varargin)
%FUNCTIONS Return information about a function handle.
%    F = FUNCTIONS(FUNHANDLE) returns, in a MATLAB structure, the function
%    name, type, and other information about FUNHANDLE.  
%
%    The FUNCTIONS function is used for internal purposes, and is provided
%    for querying and debugging purposes.  Its behavior may change in
%    subsequent releases, so it should not be relied upon for programming
%    purposes.
%
%    Examples:
%
%      To obtain information on a function handle for the DEBLANK function:
%
%        f = functions(@deblank)
%        f = 
%            function: 'deblank'
%                type: 'overloaded'
%                file: 'matlabroot\toolbox\matlab\strfun\deblank.m'
%             methods: [1x1 struct]
%
%      The methods field is a substructure containing one fieldname for each
%      built-in class that overloads the function.  It exists only
%      for overloaded functions.  The value of each field is the
%      path and name of the file that defines the method.
%
%            
%    See also FUNCTION_HANDLE, FUNC2STR, STR2FUNC.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/10 23:25:19 $
%   Built-in functions.

if nargout == 0
  builtin('functions', varargin{:});
else
  [varargout{1:nargout}] = builtin('functions', varargin{:});
end
