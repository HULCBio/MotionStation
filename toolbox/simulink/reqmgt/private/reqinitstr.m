function ca = reqinitstr(s)
%REQINITSTR initialize a requirement cell array with a string.
%   REQINITSTR returns cell array CA build from
%   string S. S must be an M-by-4 cell array initialization
%   enclosed by braces.  For example,
%     '{'DOORS' 'clutch' 'ID0045' 'false' ; 'DOORS' 'clutch' '' 'true'}'
%   No effort is made to validate the string here.  It is assumed
%   to be in the proper form (e.g., as saved in a model file).
%   
%   See also REQADD, REQDEL, REQGET, REQGETSTR, REQINIT.
%

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:26 $

if (nargin ~= 1)
   error('Insufficient number of arguments.');
end
if (~ischar(s))
   error('Input argument is not of type char.');
end
ca = {};
if (~length(s)), return; end
try
   ca = eval(s);
catch
   error('Input argument is not in the correct format.');
end
%end function ca = reqinitstr(s)
