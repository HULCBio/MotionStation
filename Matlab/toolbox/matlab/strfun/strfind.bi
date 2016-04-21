%STRFIND Find one string within another.
%   K = STRFIND(TEXT,PATTERN) returns the starting indices of any 
%   occurrences of the string PATTERN in the string TEXT.
%
%   STRFIND will always return [] if PATTERN is longer than TEXT.
%   If you wish to search for inclusion of either TEXT in PATTERN
%   or PATTERN in TEXT, use FINDSTR instead.
%
%   Examples
%       s = 'How much wood would a woodchuck chuck?';
%       strfind(s,'a')    returns  21
%       strfind('a',s)    returns  []
%       strfind(s,'wood') returns  [10 23]
%       strfind(s,'Wood') returns  []
%       strfind(s,' ')    returns  [4 9 14 20 22 32]
%
%   See also FINDSTR, STRCMP, STRNCMP, STRMATCH, REGEXP.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.4.4.2 $  $Date: 2004/04/16 22:08:48 $
%   Built-in function.

