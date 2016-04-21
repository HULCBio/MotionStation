function [varargout] = str2func(varargin)
%STR2FUNC Construct a function_handle from a function name string.
%    FUNHANDLE = STR2FUNC(S) constructs a function_handle FUNHANDLE to the
%    function named in the string S.
%
%    You can create a function handle using either the @function syntax or the
%    STR2FUNC command. You can also perform this operation on a cell array of
%    strings. In this case, an array of function handles is returned.
%
%    Examples:
%
%      To create a function handle from the function name, 'humps':
%
%        fhandle = str2func('humps')
%        fhandle = 
%            @humps
%
%      To create an array of function handles from a cell array of function
%      names:
%
%        fh_array = str2func({'sin' 'cos' 'tan'})
%        fh_array = 
%            @sin    @cos    @tan
%
%    See also FUNCTION_HANDLE, FUNC2STR, FUNCTIONS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2004/04/10 23:25:33 $

if nargout == 0
  builtin('str2func', varargin{:});
else
  [varargout{1:nargout}] = builtin('str2func', varargin{:});
end
