function [varargout] = eval(varargin)
%EVAL Execute string with MATLAB expression.
%   EVAL(s), where s is a string, causes MATLAB to execute
%   the string as an expression or statement.
%
%   EVAL(s1,s2) provides the ability to catch errors.  It
%   executes string s1 and returns if the operation was
%   successful. If the operation generates an error,
%   string s2 is evaluated before returning. Think of this
%   as EVAL('try','catch').  The error string produced by the
%   failed 'try' can be obtained with LASTERR.
%   
%   [X,Y,Z,...] = EVAL(s) returns output arguments from the
%   expression in string s.
%
%   The input strings to EVAL are often created by 
%   concatenating substrings and variables inside square
%   brackets. For example:
%
%   Generate a sequence of matrices named M1 through M12:
%
%       for n = 1:12
%          eval(['M' num2str(n) ' = magic(n)'])
%       end
%
%   Run a selected M-file script.  The strings making up 
%   the rows of matrix D must all have the same length.
%   
%       D = ['odedemo '
%            'quaddemo'
%            'fitdemo '];
%       n = input('Select a demo number: ');
%       eval(D(n,:))
%
%   See also FEVAL, EVALIN, ASSIGNIN, EVALC, LASTERR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:58:47 $
%   Built-in function.

if nargout == 0
  builtin('eval', varargin{:});
else
  [varargout{1:nargout}] = builtin('eval', varargin{:});
end
