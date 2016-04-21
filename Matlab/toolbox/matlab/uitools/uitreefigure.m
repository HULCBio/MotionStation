function tree_h = uitreefigure(figure_h)

% Copyright 2003 The MathWorks, Inc.

figure_handle = handle(figure_h); 
tree_h = com.mathworks.hg.peer.UITreePeer;
root = tree_h.setRoot(figure_handle, 'figure');
% node = tree_h.add(root, figure_handle, 'figure');

expvf = figure('NumberTitle', 'off', 'Name', 'Object Browser v1.d');
fp = get(expvf, 'Position');

uipanel_h = javacomponent(tree_h.getScrollPane, [0 0 fp(3)/2 fp(4)], expvf);
set(expvf, 'ResizeFcn', {@resizeWindow, uipanel_h}, 'Visible', 'on');
set(tree_h, 'NodeSelectedCallback', {@nodeSelected});
set(tree_h, 'NodeExpandedCallback', {@nodeExpanded, tree_h});

% ----------------------------------------------------
function nodeExpanded(src, evd, tree_h)
parent = handle(get(evd.currentNode, 'value'));
children = get(parent, 'children');

for i = 1:length(children)
     next_gen_node = tree_h.add(evd.currentNode, handle(children(i)), get(children(i), 'tag'));
end

tree_h.nodeStructureChangeCompleted(evd.currentNode);
%-----------------------------------------------------
function nodeSelected(src, evd)
% f = handle(get(evd.currentNode, 'value'))
% get(f)
% a = current(1).fName
%-----------------------------------------------------
function resizeWindow(src, evd, uipanel_h)

dim = get(src, 'Position');
set(uipanel_h, 'Position', [0 0 dim(3) dim(4)]);
