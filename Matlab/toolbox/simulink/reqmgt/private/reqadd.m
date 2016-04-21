function ca = reqadd(ca, reqsys, module, id, linked, forceUpdateID)
%REQADD adds a requirement into the cell array CA.
%   REQADD(CA, REQSYS, MODULE, ID) adds a new item
%   with linked status of "false".  If the item exists, no
%   changes are made.
%   REQADD(CA, REQSYS, MODULE, ID, LINKED) adds a new item
%   with linked status of LINKED.  If the item exists, the linked
%   status is updated with LINKED.
%   Cell array CA is returned in all cases.
%
%   See also REQDEL, REQGET, REQGETSTR, REQINIT, REQINITSTR.
%

%  Author(s): M. Greenstein, 10/26/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:21 $

if (nargin < 4)
   error('Insufficient number of arguments.');
end
if (~iscell(ca))
   error('First input argument is not of type cell array.');
end

% See if item exists.  Update if it does.
[r,c] = size(ca);
for i = 1:r
   if (strcmp(ca{i, 1}, reqsys) && strcmp(ca{i, 2}, module) && strcmp(ca{i, 3}, id))
      if (exist('linked'))
         ca{i, 4} = linked;
      end
      return;
	  
   % Fix bug where deleting an item from the DOORS formal module
   % result in that item and everything below it being deleted
   elseif strcmp(ca{i, 1}, reqsys) && strcmp(ca{i, 2}, module) && forceUpdateID
	   ca{i, 3} = id;
	   return;
   end 
end % for i = 1:r

% Add a new item.
r = r + 1;
ca{r, 1} = reqsys;
ca{r, 2} = module;
ca{r, 3} = id;
ca{r, 4} = 'false';
if (exist('linked')) ca{r, 4} = linked; end

% end function ca = reqadd(ca, reqsys, module, id, linked)
