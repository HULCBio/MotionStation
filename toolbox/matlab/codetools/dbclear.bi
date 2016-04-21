function [varargout] = dbclear(varargin)
%DBCLEAR Remove breakpoint.
%   The DBCLEAR command removes the breakpoint set by a corresponding DBSTOP
%   command. There are several forms to this command. They are:
%
%   (1)  DBCLEAR IN MFILE AT LINENO
%   (2)  DBCLEAR IN MFILE AT SUBFUN
%   (3)  DBCLEAR IN MFILE
%   (4)  DBCLEAR IF ERROR
%   (5)  DBCLEAR IF CAUGHT ERROR
%   (6)  DBCLEAR IF WARNING
%   (7)  DBCLEAR IF NANINF  or  DBCLEAR IF INFNAN
%   (8)  DBCLEAR IF ERROR IDENTIFIER
%   (9)  DBCLEAR IF CAUGHT ERROR IDENTIFIER
%   (10) DBCLEAR IF WARNING IDENTIFIER
%   (11) DBCLEAR ALL
%
%   MFILE must be the name of an M-file or a MATLABPATH-relative partial
%   pathname (see PARTIALPATH). LINENO is a line number within MFILE, and SUBFUN
%   is the name of a subfunction within MFILE. IDENTIFIER is a MATLAB Message
%   Identifier (see help for ERROR for a description of message
%   identifiers). The AT and IN keywords are optional.
% 
%   The several forms behave as follows:
%
%   (1)  Removes the breakpoint at line LINENO in MFILE. 
%   (2)  Removes the breakpoint at the first executable line in the specified
%        subfunction of MFILE.
%   (3)  Removes all breakpoints in MFILE.
%   (4)  Clears the DBSTOP IF ERROR statement and any DBSTOP IF ERROR
%        IDENTIFIER statements, if set.
%   (5)  Clears the DBSTOP IF CAUGHT ERROR statement, and any DBSTOP IF CAUGHT
%        ERROR IDENTIFIER statements, if set.
%   (6)  Clears the DBSTOP IF WARNING statement, and any DBSTOP IF WARNING
%        IDENTIFIER statements, if set.
%   (7)  Clears the DBSTOP on infinities and NaNs, if set.
%   (8)  Clears the DBSTOP IF ERROR IDENTIFIER statement for the specified
%        IDENTIFIER. It is an error to clear this setting on a specific
%        identifier if DBSTOP IF ERROR or DBSTOP IF ERROR ALL is set.
%   (9)  Clears the DBSTOP IF CAUGHT ERROR IDENTIFIER statement for the specified
%        IDENTIFIER. It is an error to clear this setting on a specific
%        identifier if DBSTOP IF CAUGHT ERROR or DBSTOP IF CAUGHT ERROR ALL
%        is set. 
%   (10) Clears the DBSTOP IF WARNING IDENTIFIER statement for the specified
%        IDENTIFIER. It is an error to clear this setting on a specific
%        identifier if DBSTOP IF WARNING or DBSTOP IF WARNING ALL is set.
%   (11) Removes all breakpoints in all M-files, as well as those mentioned in
%        (4)-(7) above.
%
%   See also DBSTEP, DBSTOP, DBCONT, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%            DBQUIT, ERROR, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2003/04/07 04:12:56 $
%   Built-in function.

if nargout == 0
  builtin('dbclear', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbclear', varargin{:});
end
