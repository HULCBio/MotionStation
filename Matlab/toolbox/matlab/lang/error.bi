function [varargout] = error(varargin)
%ERROR  Display message and abort function.
%   ERROR('MSGID', 'MESSAGE') displays the error message in the string MESSAGE,
%   and causes an error exit from the currently executing M-file to the
%   keyboard. MSGID is a message identifier, that you can use to uniquely
%   identify the error. A message identifier is a string of the form
%   component>[:<component>]:<mnemonic>, where <component> and <mnemonic> are
%   alphanumeric strings. An example of a message identifier is
%   'myToolbox:myFunction:fileNotFound'. The identifier for an error that has
%   been issued can be obtained via the LASTERROR function (for example, within
%   a CATCH block to determine what kind of error occurred). MESSAGE is a string
%   that may contain escape sequences, such as \t or \n. ERROR translates these
%   sequences into the appropriate text characters, such as tab or newline.
%
%   ERROR('MSGID', 'MESSAGE', A, ...) displays a formatted error message and
%   exits the M-file. In addition to escape sequences, the string MESSAGE may
%   contain any of the C language conversion specifiers (e.g., %s or %d) that
%   are supported by the SPRINTF function. Additional arguments A, ... provide
%   the values that correspond to these specifiers. These arguments may hold
%   string or scalar numeric values. See HELP SPRINTF for more information on
%   valid conversion specifiers.
%
%   ERROR('MESSAGE', A, ...) displays a formatted error message and exits the
%   M-file. The string MESSAGE may contain any of the C language conversion
%   specifiers (e.g., %s or %d) that are supported by the SPRINTF
%   function. Since there is no MSGID argument, the message identifier for the
%   error defaults to the empty string.
%
%   ERROR('MESSAGE') displays an unformatted error message and exits the
%   M-file. Any escape sequences or conversion specifiers contained in the
%   string MESSAGE are not converted to the text that they represent. Since
%   there is no MSGID argument, the message identifier for the error defaults to
%   the empty string. As a special case, if MESSAGE is an empty string, no
%   action is taken and ERROR returns without exiting from the M-file.
%
%   Note: To use a message identifier and display a message without formatting,
%   use 
%
%       ERROR('MSGID', '%s', 'MESSAGE')
%
%   ERROR(MSGSTRUCT), where MSGSTRUCT is a scalar structure with fields
%   'message' and 'identifier', behaves exactly like
%
%       ERROR(MSGSTRUCT.identifier, '%s', MSGSTRUCT.message);
%
%   (Note: this means the message field is displayed unformatted). As a
%   special case, if MSGSTRUCT is an empty structure, no action is taken and
%   ERROR returns without exiting from the M-file.
%
%   See also RETHROW, LASTERROR, LASTERR, SPRINTF, TRY, CATCH, DBSTOP, ERRORDLG,
%            WARNING, DISP.
    
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2003/06/09 05:58:46 $
%   Built-in function.



if nargout == 0
  builtin('error', varargin{:});
else
  [varargout{1:nargout}] = builtin('error', varargin{:});
end
