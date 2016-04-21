%STRINGS Character strings in MATLAB.
%   S = 'Any Characters' creates a character array, or string. The 
%   string is actually a vector whose components are the numeric codes 
%   for the characters (the first 127 codes are ASCII). The actual 
%   characters displayed depends on the character set encoding for a 
%   given font. The length of S is the number of characters. A quote 
%   within the string is indicated by two quotes.
%   
%   S = [S1 S2 ...] concatenates character arrays S1, S2, etc. into a
%   new character array, S.
%
%   S = strcat(S1, S2, ...) concatenates S1, S2, etc., which can be 
%   character arrays or cell arrays of strings. When the inputs are all 
%   character arrays, the output is also a character array. When any of 
%   the inputs is a cell array of strings, STRCAT returns a cell array 
%   of strings.  
%
%   Trailing spaces in STRCAT character array inputs are ignored and
%   do not appear in the output. This is not true for STRCAT inputs
%   that are cell arrays of strings. Use the S = [S1 S2 ...] concate-
%   nation syntax, shown above, to preserve trailing spaces.
%
%   S = CHAR(X) can be used to convert an array that contains positive 
%   integers representing character codes into a MATLAB character array. 
%
%   X = DOUBLE(S) converts the string to its equivalent double precision
%   numeric codes.
%
%   A collection of strings can be created in two ways: 1) as the rows of a
%   character array via STRVCAT or 2) as a cell array of strings via the
%   curly braces.  The two are different but can be converted back and
%   forth with CHAR and CELLSTR.  Most string functions support both
%   types.
%
%   ISCHAR(S) tells if S is a character array (string) and ISCELLSTR(S)
%   tells if S is a cell array of strings.
%
%   Examples
%       msg = 'You''re right!'
%       name = ['Thomas' ' R. ' 'Lee']
%       name = strcat('Thomas',' R.',' Lee')
%       C = strvcat('Hello','Yes','No','Goodbye')
%       S = {'Hello' 'Yes' 'No' 'Goodbye'}
%
%   See also TEXT, CHAR, CELLSTR, CELL, DOUBLE, ISCHAR, ISCELLSTR, STRVCAT,
%            STRFUN, SPRINTF, SSCANF, INPUT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.15 $  $Date: 2002/04/15 03:53:50 $

