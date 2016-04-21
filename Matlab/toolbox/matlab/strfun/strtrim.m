
%STRTRIM Remove insignificant whitespace.
%   S = STRTRIM(M) removes insignificant whitespace from string M.
%
%   Whitespace characters are the following: V = char([9 10 11 12 13 32]), which
%   return true from ISSPACE(V). Per definition, insignificant leading
%   whitespace leads the first non-whitespace character, and insignificant
%   trailing whitespace follows the last non-whitespace character in a string.
%
%   B = STRTRIM(A) removes insignificant whitespace from the char array. 
%
%   D = STRTRIM(C), when C is a cell array of strings, removes insignificant
%   whitespace from each element of C. 
%
%   INPUT PARAMETERS:
%       M: any one of a char row vector, 2D char array, or an N-D cell array of
%       strings. 
%
%   RETURN PARAMETERS:
%       M: any one of a char row vector, 2D char array or an N-D cell array of
%       strings. 
%
%   EXAMPLES:
%       M = STRTRIM(M) removes whitespace from the front and rear of M.
%       
%   See also ISSPACE, CELLSTR, DEBLANK.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/10 23:33:02 $
%==============================================================================
