function [varargout] = evalin(varargin)
%EVALIN Evaluate expression in workspace.
%   EVALIN(WS,'expression') evaluates 'expression' in the context of
%   the workspace WS.  WS can be 'caller' or 'base'.  It is similar to EVAL
%   except that you can control which workspace the expression is
%   evaluated in.
%
%   [X,Y,Z,...] = EVALIN(WS,'expression') returns output arguments from
%   the expression.
%
%   EVALIN(WS,'try','catch') tries to evaluate the 'try' expression
%   and if that fails it evaluates the 'catch' expression (in the
%   current workspace).
%
%   See also EVAL, ASSIGNIN.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2003/06/09 05:58:49 $

%   Built-in function

if nargout == 0
  builtin('evalin', varargin{:});
else
  [varargout{1:nargout}] = builtin('evalin', varargin{:});
end
