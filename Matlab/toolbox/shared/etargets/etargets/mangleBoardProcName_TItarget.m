function newStr = mangleBoardProcName_TItarget(oldStr)
% Replace disallowed characters with "_" to enforce compatibility
% with RTW OPtions mechanism.  E.g., spaces and commas are not allowed.

% $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:08:09 $

% Copyright 2001-2003 The MathWorks, Inc.

% " " and "," are not supported by RTW options string
newStr = strrep(oldStr, ' ', '_');
newStr = strrep(newStr, ',', '_');

% "=" causes error: "Operands to the || and && operators 
%                   must be convertible to logical scalar values."
newStr = strrep(newStr, '=', '_');  

% "%" causes error: "File: execstring Line: 1 Column: 21  Unterminated string
%                    File: execstring Line: 1 Column: 30  syntax error"
newStr = strrep(newStr, '%', '_');

% "|"  is the popup string separator
newStr = strrep(newStr, '|', '_');

% "'"  is the string demarcator for matlab
newStr = strrep(newStr, sprintf(''''), '_');

% "|"  is the popup string separator for TLC
newStr = strrep(newStr, '"', '_');

% ":"  gives another error
newStr = strrep(newStr, ':', '_');

% ";"  gives another error, "missing variable or function"
newStr = strrep(newStr, ';', '_');

% Note:  "\" is disallowed in CCS Setup, and "/" causes a CCS
%        startup error dialog, so we do not have to account for them.

% EOF     mangleBoardProcName_TItarget.m
