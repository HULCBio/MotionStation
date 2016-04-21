function child = getChild(obj, tag )

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:34 $
% Copyright 1984-2003 The MathWorks, Inc.

for i = 1:length(obj.children)
    aChild = obj.children{i};
    if(strcmp(tag,aChild.tag))
        child = aChild;
        return
    end
end
child = [];