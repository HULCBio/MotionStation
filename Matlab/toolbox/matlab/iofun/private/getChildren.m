function  children  = getChildren( obj ,tag)
% children = getChildren(xdoc) returns a cell array of all children.
% children = getChildren(xdoc,NAME) returns a cell array of all children
% whose tag is NAME

% $Revision: 1.1.6.1 $  $Date: 2003/08/05 19:22:35 $
% Copyright 1984-2003 The MathWorks, Inc.

if(nargin == 1)
    children = obj.children;
else
    children = {};
    for i = 1:length(obj.children)
        child = obj.children{i};
        if(strcmp(tag,child.tag))
            children = [children {child}];
        end
    end
end