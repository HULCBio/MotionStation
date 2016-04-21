function node = uitreenode(value, string, icon, isLeaf)
% UITREENODE creates a node object in a uitree component
%     UITREENODE(Value, Description, Icon, Leaf)
%     creates a tree node object for the uitree with the specified
%     properties. All properties must be specified for the succesffful
%     creation of a node ubject.
%
%     Value can be a string or handle represented by this node.
%     Description is a string which is used to identify the node.
%     Icon can be a qualified pathname to an image to be used as an icon
%     for this node. It may be set to [] to use default icons.
%     Leaf can true or false to denote whether this node has children.
%
%     See also, UITREE, UITABLE, JAVACOMPONENT

% Copyright 2003 The MathWorks, Inc.

import com.mathworks.hg.peer.UITreeNode;
node = UITreeNode(value, string, icon, isLeaf);
