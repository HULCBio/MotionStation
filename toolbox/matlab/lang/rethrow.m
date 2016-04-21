function [varargout] = rethrow(varargin)
%RETHROW  Reissue error.
%   RETHROW(ERR) reissues an error as stored in the variable ERR. The currently
%   running M-file terminates and control is returned to the keyboard (or any
%   enclosing CATCH block). ERR must be a structure containing at least the
%   following two fields:
%
%       message    : the text of the error message
%       identifier : the message identifier of the error message 
%
%   (See help for ERROR for more information about error message identifiers.)
%   A convenient way to get a valid ERR structure for the last error issued is
%   via the LASTERROR function.
%
%   RETHROW is usually used in conjunction with TRY-CATCH statements to reissue
%   an error from a CATCH block after performing catch-related operations. For
%   example:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
%   See also ERROR, LASTERROR, LASTERR, TRY, CATCH, DBSTOP.
    
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2003/06/09 05:59:20 $
%   Built-in function.

if nargout == 0
  builtin('rethrow', varargin{:});
else
  [varargout{1:nargout}] = builtin('rethrow', varargin{:});
end
