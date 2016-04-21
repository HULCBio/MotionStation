function t = isvarname(s)
%ISVARNAME True for valid variable name.
%   ISVARNAME(S) is true if S is a valid MATLAB variable name.
%   A valid variable name is a character string of letters, digits and
%   underscores, with length <= namelengthmax and the first character a letter.
%
%   See also ISKEYWORD, NAMELENGTHMAX, GENVARNAME.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/13 16:42:19 $

t = ischar(s) & size(s,1) == 1 & length(s) <= namelengthmax;
if t
   t = isletter(s(1)) & all(isletter(s) | s == '_' | ('0' <= s & s <= '9'));
   t = t & ~iskeyword(s); 
end
