function attr = getAttribute(obj, name )
% attr = getAttribute(xdoc,name) returns the value of the named attribute.
% If the xdoc does not have the attribute, empty is returned.

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:32 $
% Copyright 1984-2003 The MathWorks, Inc.

for i = 1:length(obj.attributes)
    anAttribute = obj.attributes{i};
    if(strcmp(name,anAttribute{1}))
        attr = anAttribute{2};
        return
    end
end
attr = [];