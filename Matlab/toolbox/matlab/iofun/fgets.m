function [varargout] = fgets(varargin)
%FGETS Read line from file, keep newline character. 
%   TLINE = FGETS(FID) returns the next line of a file associated
%   with file identifier FID as a MATLAB string. The line
%   terminator is included. Use FGETL to get the next line
%   WITHOUT the line terminator. If just an end-of-file is
%   encountered then -1 is returned.
%
%   TLINE = FGETS(FID, NCHAR) returns at most NCHAR characters of
%   the next line. No additional characters are read after the
%   line terminator(s) or an end-of-file.
%
%   FGETS is intended for use with text files only.  Given a binary 
%   file with no newline characters, FGETS may take a long time to 
%   execute.
%
%   See also FGETL, FOPEN.

%   [TLINE, LTOUT] = FGETS(...) also returns the line terminator(s),
%   if any, in LTOUT.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/04/10 23:29:23 $
%   Built-in function.

if nargout == 0
  builtin('fgets', varargin{:});
else
  [varargout{1:nargout}] = builtin('fgets', varargin{:});
end
