function [varargout] = warning(varargin)
%WARNING Display warning message; disable or enable warning messages.
%   WARNING('MESSAGE') displays the warning message MESSAGE, unless it has been
%   disabled (see the special identifier 'all' in "Controlling Warning Message
%   Display" below). When MESSAGE is the only input to WARNING, WARNING displays
%   it literally, without performing any substitutions (see below) on the
%   characters in MESSAGE.
%
%   WARNING('MESSAGE', A, B, ...) displays the formatted warning message
%   MESSAGE. The string MESSAGE may contain escape sequences (such as \t or \n)
%   as well as the C language conversion specifiers (e.g., %s or %d) that are
%   supported by the SPRINTF function. WARNING makes substitutions for the
%   escape sequences and conversion specifiers in the same way that SPRINTF
%   does. Additional arguments A, B, ... provide the values that correspond to
%   the format specifiers and are only required if conversion specifiers appear
%   in MESSAGE. Type HELP SPRINTF for more information on escape sequences and
%   format specifiers. WARNING performs these substitutions on MESSAGE in all
%   cases where more than one input is passed to WARNING.
%
%   WARNING('MSGID', 'MESSAGE', A, B, ...) displays the formatted warning
%   message MESSAGE as in the paragraph above, and tags the warning with the
%   message identifier MSGID. The identifier can be used to enable or disable
%   display of the identified warning (See "Controlling Warning Message Display"
%   below). A message identifier is a string of the form
%   <component>[:<component>]:<mnemonic>, where <component> and <mnemonic> are
%   alphanumeric strings (for example, 'MATLAB:divideByZero').
%
%   Controlling Warning Message Display
%   -----------------------------------
%   WARNING('OFF', 'MSGID') and WARNING('ON', 'MSGID') disable and enable the
%   display of any warning tagged with message identifier MSGID. (Use LASTWARN
%   to determine the identifier of a warning, or use the WARNING VERBOSE feature
%   described below.) WARNING is not case sensitive when matching message
%   identifiers.
%
%   S = WARNING('OFF', 'MSGID') and S = WARNING('ON', 'MSGID') additionally
%   return the previous warning state in a structure S with fields 'identifier'
%   and 'state'.
%
%   WARNING('QUERY', 'MSGID') displays the state ('on' or 'off') for warnings
%   with message identifier MSGID. S = WARNING('QUERY', 'MSGID') returns the
%   state in a structure S with fields 'identifier' and 'state'.
%
%   In the three cases above, MSGID can also be 'all', in which case all
%   warnings (including untagged ones) are disabled, enabled, or queried, as
%   well as 'last', in which case the last displayed warning is disabled,
%   enabled, or queried.
%
%   WARNING ON BACKTRACE and WARNING OFF BACKTRACE control the display of the
%   file and line number that produced a warning when the warning is displayed.
%
%   WARNING ON VERBOSE and WARNING OFF VERBOSE control the displaying of an
%   extra line of helpful text containing the warning identifier when a warning
%   is displayed.
% 
%   S = WARNING('QUERY', ARG) where ARG is either 'BACKTRACE' or 'VERBOSE'
%   returns a structure S with fields 'identifier' containing ARG and 'state'
%   containing the current state of ARG.
%
%   WARNING(S) where S is a structure with fields 'identifier' and 'state' is
%   equivalent to
%
%       for k = 1:length(S), warning(S(k).state, S(k).identifier); end
%       
%   In other words, WARNING accepts as an input the same structure it returns as
%   an output. This restores the states of warnings to their previous values.
%
%   See also SPRINTF, LASTWARN, DISP, ERROR, ERRORDLG, WARNDLG.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.4 $  $Date: 2004/04/06 01:10:25 $
%   Built-in function.

if nargout == 0
  builtin('warning', varargin{:});
else
  [varargout{1:nargout}] = builtin('warning', varargin{:});
end
