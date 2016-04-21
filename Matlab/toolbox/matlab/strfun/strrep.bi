%STRREP Replace string with another.
%   S = STRREP(S1,S2,S3) replaces all occurrences of the string S2 in
%   string S1 with the string S3.  The new string is returned.
%
%   STRREP(S1,S2,S3), when any of S1, S2, or S3 is a cell array of
%   strings, returns a cell array the same size as S1,S2 and S3
%   obtained by performing a STRREP using corresponding elements of
%   the inputs.  The inputs must all be the same size (or any can
%   be a scalar cell). Any one of the strings can also be a character
%   array with the right number of rows.
%
%   Example:
%       s1='This is a good example';
%       strrep(s1,'good','great') returns 'This is a great example'
%       strrep(s1,'bad','great')  returns 'This is a good example'
%       strrep(s1,'','great')     returns 'This is a good example'
%
%   See also STRFIND, REGEXPREP.

%   M version contributor: Rick Spada  11-23-92
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.17.4.3 $  $Date: 2004/04/16 22:08:53 $
%   Built-in function.


