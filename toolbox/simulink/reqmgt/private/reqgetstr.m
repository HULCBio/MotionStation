function s = reqgetstr(ca)
%REQGETSTR get entire requirements entry as a string.
%   S = REQGETSTR(CA) returns the entire contents of CA as a
%   formatted string for storage and reloading.
%
%   See also REQADD, REQDEL, REQGET, REQINIT, REQINITSTR.
%   

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:24 $

if (nargin ~= 1)
   error('Insufficient number of arguments.');
end
if (~iscell(ca))
   error('Input argument is not of type cell array.');
end

s = '{ ';
[r,c] = size(ca);
for i = 1:r
   for j = 1:c
      s = [s '''' ca{i, j} '''' ' '];
   end % for j = 1:c
   if (i < r), s = [s, '; '];, end
end % for i = 1:r

s = [s '}'];

% end function s = reqgetstr(ca)

