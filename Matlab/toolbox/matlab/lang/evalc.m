function [varargout] = evalc(varargin)
%EVALC Evaluate MATLAB expression with capture.
%    T = EVALC(S) is the same as EVAL(S) except that anything that would
%    normally be written to the command window is captured and returned in
%    the character array T (lines in T are separated by '\n' characters).  
%
%    T = EVALC(s1,s2) is the same as EVAL(s1,s2) except that any output
%    is captured into T.
%
%    [T,X,Y,Z,...] = EVALC(S) is the same as [X,Y,Z,...] = EVAL(S) except
%    that any output is captured into T.
%
%    Note: While in evalc, DIARY, MORE and INPUT are disabled.
%
%    See also EVAL, EVALIN, DIARY, MORE, INPUT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/06/09 05:58:48 $


if nargout == 0
  builtin('evalc', varargin{:});
else
  [varargout{1:nargout}] = builtin('evalc', varargin{:});
end
