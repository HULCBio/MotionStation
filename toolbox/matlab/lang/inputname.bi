function [varargout] = inputname(varargin)
%INPUTNAME Input argument name.
%   Inside the body of a user-defined function, INPUTNAME(ARGNO)
%   returns the caller's workspace variable name corresponding to 
%   the argument number ARGNO.  If the input has no name, for example,
%   when it is the result of a calculation or an expression such as,
%   a(1), varargin{:}, eval(expr), etc, then INPUTNAME returns an
%   empty string.
%
%   Example: Suppose the function myfun is defined as:
%     function y = myfun(a,b)
%     disp(sprintf('My first input is "%s".' ,inputname(1)))
%     disp(sprintf('My second input is "%s".',inputname(2)))
%     y = a+b;
%   then
%     x = 5; myfun(x,5)
%   produces
%     My first input is "x".
%     My second input is "".
%
%   See also NARGIN, NARGOUT, NARGCHK, MFILENAME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2003/06/09 05:58:53 $
%   Built-in function.

if nargout == 0
  builtin('inputname', varargin{:});
else
  [varargout{1:nargout}] = builtin('inputname', varargin{:});
end
