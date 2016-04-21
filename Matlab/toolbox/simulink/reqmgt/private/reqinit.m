function newca = reqinit(carray)
%REQINITREQ requirement initialize as an empty cell array.
%   NEWCA = REQINIT returns a new, empty cell array in NEWCA.
%   NEWCA = REQINIT(carray) clears out carray and returns it as NEWCA.
%
%   See also REQADD, REQDEL, REQGET, REQGETSTR, REQINITSTR.
%

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:25 $

if (exist('carray') & ~iscell(carray))
   error('Input argument is not of type cell array.');
end
if (exist('carray'))
   carray = {};
   newca = carray;
else
   newca = {};
end
% end function newca = reqinit(carray)
