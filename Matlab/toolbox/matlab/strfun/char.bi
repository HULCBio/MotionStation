function s = char(c)
%CHAR Create character array (string).
%   S = CHAR(X) converts the array X that contains positive integers
%   representing character codes into a MATLAB character array (the first
%   127 codes are ASCII). The actual characters displayed depends on the
%   character set encoding for a given font.  The result for any elements
%   of X outside the range from 0 to 65535 is not defined (and may vary
%   from platform to platform).  Use DOUBLE to convert a character array
%   into its numeric codes.
%
%   S = CHAR(C), when C is a cell array of strings, places each 
%   element of C into the rows of the character array S.  Use CELLSTR to
%   convert back.
%
%   S = CHAR(T1,T2,T3,..) forms the character array S containing the text
%   strings T1,T2,T3,... as rows.  Automatically pads each string with
%   blanks in order to form a valid matrix.  Each text parameter, Ti,
%   can itself be a character array.  This allows the creation of
%   arbitrarily large character arrays.  Empty strings are significant.
%
%   See also STRINGS, DOUBLE, STRVCAT, CELLSTR, ISCELLSTR, ISCHAR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/15 03:53:05 $
%   Built-in function.
