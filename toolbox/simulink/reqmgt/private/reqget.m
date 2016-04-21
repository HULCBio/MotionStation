function outca = reqget(ca, reqsys, module)
%REQGET retrieves information for a requirement.
%   OUTCA = REQGET(CA, REQSYS, MODULE) returns the ID and
%   LINKED status for all requirements identified by REQSYS
%   and MODULE.  Output OUTCA is a cell array of strings.
%   OUTCA = REQGET(CA, REQSYS) returns all items for REQSYS.
%   
%   See also REQADD, REQDEL, REQGETSTR, REQINIT, REQINITSTR.
%

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:23 $

if (nargin < 2)
   error('Insufficient number of arguments.');
end
if (~iscell(ca))
   error('First input argument is not of type cell array.');
end

outca = {};
[r,c] = size(ca);
l = 1;
for i = 1:r
   x = 0;
   if (exist('module') & ~isempty(module))
   	if (strcmp(ca{i, 1}, reqsys) & ...
         		strcmp(ca{i, 2}, module))
      	x = 1;      
      end
   else
      if (strcmp(ca{i, 1}, reqsys)), x = 1; end
   end
   
   if (x) % Got one.
   	outca{l, 1} = ca{i, 3};
      outca{l, 2} = ca{i, 4};
      l = l + 1;
   end
end % for i = 1:r

% end function outca = reqget(ca, reqsys, module)

