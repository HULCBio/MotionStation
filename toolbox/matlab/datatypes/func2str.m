function [varargout] = func2str(varargin)
%FUNC2STR Construct a string from a function handle.
%    S = FUNC2STR(FUNHANDLE) returns a string S that represents FUNHANDLE.
%    If FUNHANDLE is a function handle to an anonymous function, S contains
%    the text that defines that function.  If FUNHANDLE is a function
%    handle to a named function, S contains the name of that function.
% 
%    When you need to perform a string operation, such as compare or display,
%    on a function handle, you can use FUNC2STR to construct a string
%    representing the function.
%
%    Examples:
%
%      To create a function name string from the function handle, @humps:
%
%        funname = func2str(@humps)
%        funname =
%        humps
%
%      To create a string from an anonymous function:
%
%        anontext = func2str(@(x)x/3)
%        anontext =
%        @(x)x/3
%
%    See also FUNCTION_HANDLE, STR2FUNC, FUNCTIONS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $ $Date: 2004/04/10 23:25:17 $

[varargout{1:nargout}] = builtin('func2str', varargin{:});
