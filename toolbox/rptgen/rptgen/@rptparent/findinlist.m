function index=findinlist(obj,list,string)
%FINDINLIST - locates an item in a 1xn cell array
%   FINDINLIST(anobj,list,item) if "item" exists in the
%   1xn cell array "list", FINDINLIST will return the index
%   of the item.  If it is not in the list, FINDINLIST will
%   return 0.
%
%   anobj is any object in the rptparent heirarchy.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:15 $



i=1;
while i<=length(list) & ~issame(list{i},string)
   i=i+1;
end

if i>length(list)
   index=0;
else
   index=i;
end

function same=issame(item1,item2)

if ischar(item1) & ischar(item2)
   same=strcmp(item1,item2);
elseif isnumeric(item1) & isnumeric (item2)
   if item1==item2
      same=1;
   else
      same=0;
   end
else
   same=0;
end

