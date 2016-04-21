function result = udd_property_help(object)

result = get(get(object.classhandle, 'Properties'), {'Name', 'Description'});

% Copyright 2001 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/15 01:01:19 $
