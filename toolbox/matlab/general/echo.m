function [varargout] = echo(varargin)
%ECHO Echo commands in M-files.
%   ECHO ON turns on echoing of commands inside Script-files. 
%   ECHO OFF turns off echoing.
%   ECHO file ON where 'file' is a function name causes the
%      named Function-file to be echoed when it is used.
%   ECHO file OFF turns it off.
%   ECHO file toggles it.
%   ECHO ON ALL turns on the echoing of commands inside any
%      Function-files that are currently in memory (i.e., the
%      functions returned by INMEM).
%   ECHO OFF ALL turns them all off.
%
%   See also FUNCTION, SCRIPT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:57:58 $
%   Built-in function.

if nargout == 0
  builtin('echo', varargin{:});
else
  [varargout{1:nargout}] = builtin('echo', varargin{:});
end
