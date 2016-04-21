function [varargout] = lasterr(varargin)
%LASTERR Last error message.
%   LASTERR, by itself, returns a string containing the last error message
%   issued by MATLAB.
%
%   [LASTMSG, LASTID] = LASTERR returns two strings, the first containing the
%   last error message issued by MATLAB and the second containing the message
%   identifier string corresponding to it (see HELP ERROR for more information
%   on message identifiers).
%
%   LASTERR('') resets the LASTERR function so that it will return an empty
%   string matrix for both LASTMSG and LASTID until the next error is
%   encountered.
%
%   LASTERR('MSG', 'MSGID') sets the last error message to MSG and the last
%   error message identifier to MSGID. MSGID must be a legal message
%   identifier (or an empty string).
%   
%   LASTERR is usually used in conjunction with the two argument form of EVAL:
%   EVAL('try','catch') or the TRY...CATCH...END statements. The catch action
%   can examine the LASTERR message identifier (or message string) to determine
%   the cause of the error and take appropriate action.
%
%   See also LASTERROR, ERROR, LASTWARN, EVAL, TRY, CATCH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:59:10 $
%   Built-in function.

if nargout == 0
  builtin('lasterr', varargin{:});
else
  [varargout{1:nargout}] = builtin('lasterr', varargin{:});
end
