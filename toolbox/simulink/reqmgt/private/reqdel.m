function ca = reqdel(ca, reqsys, module, id)
%REQDEL delete a requirement from cell array CA.
%   REQDEL(CA, REQSYS, MODULE, ID) removes a row from
%   CA, if there is a row that matches REQSYS, MODULE, and
%   ID fields.  Modified CA is returned.  If no match, original
%   CA is returned.
%
%   See also REQADD, REQGET, REQGETSTR, REQINIT, REQINITSTR.
%

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:22 $

if (nargin ~= 4)
   error('Insufficient number of arguments.');
end
if (~iscell(ca))
   error('First input argument is not of type cell array.');
end

% See if item exists.
j = 0;
[r,c] = size(ca);
for i = 1:r
   if ( strcmp(ca{i, 1}, reqsys) & ...
            strcmp(ca{i, 2}, module) & ...
            strcmp(ca{i, 3}, id) )
      j = i;
      break;
   end
end % for i = 1:r

if (~j), return; end

% Recreate the cell array without the deleted item.
temp = ca;
ca = {};
l = 1;
for i = 1:r
   if (i ~= j)
      for k = 1:4
         ca{l, k} = temp{i, k};
      end
      l = l + 1;
   end
end % for i = 1:r

%end function ca = reqdel(ca, reqsys, module, id)
