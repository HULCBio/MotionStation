function t=get_table(r,id)
%GET_TABLE gets index into table of object types
%   t=get_table(r,id)
%   t=get_table(r,c)
%
%   Returns an index into r's table of object types
%   based on an ID.  If "c" is supplied, uses 
%   c.att.ObjectType as the ID.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:43 $

if isa(id,'rptcomponent')
   id=subsref(id,substruct('.','att','.','ObjectType'));
end

tId={r.Table.id};

tIndex=find(strcmp(tId,id));
if isempty(tIndex)
   error(sprintf('ID "%s" not found in lookup table.',id));
else
   t=r.Table(tIndex(1));
end