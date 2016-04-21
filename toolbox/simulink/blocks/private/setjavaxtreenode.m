function treenode = setjavaxtreenode( varargin )
% SETJAVAXTREENODE
% Abstract:
%   This function creates the Java Swing style tree structure for
%   given blocks in a Simulink model. Input "blks" must be a sorted
%   cell-array that list block's name with full parent path.
%
% 

%  Jun Wu, Oct. 2002
%  Copyright 1990-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $

err = javachk('Swing', 'SIMULINK');
if ~isempty(err)
  error(err);
end


if nargin == 1
  model = varargin{1};
  blks = find_system(model);
elseif nargin == 2
  model = varargin{1};
  blks  = varargin{2};
else
  treenode = javax.swing.tree.DefaultMutableTreeNode;
  return;
end
treenode = javax.swing.tree.DefaultMutableTreeNode(model);

prevBlkParent = '';
lastNode      = [];

for i = 1 : length(blks)
  lvl = 0;                      % start with the root level
  blk = blks{i};

  % store the parent of this block
  thisBlkParent = get_param(blk, 'Parent');
  
  % Simulink will convert block's name that contains '/' into a '//', 
  % we need to find them and replace them with '~|' so the strtok '/' below
  % can work properly.
  blk = regexprep(blk, '//', '~|'); 
  
  % create the TreeNode for this block 
  [tmp, blk] = strtok(blk, '/');% first must be the model name
  
  if ~isempty( findstr(thisBlkParent, '/') ) && ... % not root block
	~isempty( lastNode )
    % the depth number of previous block
    prevNodeDepth = length( findstr(prevBlkParent, '/') ) + 1;
    
    thisBlk = thisBlkParent;
    prevBlk = prevBlkParent;
    % compare the same depth's node on previous and current block
    % the last same one is the junction node
    while prevNodeDepth ~= 0 && ~isempty(thisBlkParent)
      [thisNode, thisBlk] = strtok(thisBlk, '/');
      [prevNode, prevBlk] = strtok(prevBlk, '/');
      if strcmp( thisNode, prevNode )
	lvl = lvl + 1;
      end
      prevNodeDepth = prevNodeDepth - 1;
    end
    
    % skip the same upper level nodes
    for j = 1 : lvl-1
      [tmp, blk] = strtok(blk, '/');
    end
    
    % set the junction node to be the last node
    for j = 1 : length( findstr(prevBlkParent, '/') ) + 2 - lvl
      lastNode = lastNode.getParent;
      if isempty(lastNode)
	error('Assertion: Dialog structure has been corrupted.');
      end
    end
  end
  
  while ~isempty(blk)
    [nodeStr, blk] = strtok(blk, '/');
    
    % work around with sprintf('\n') on swing
    sp = find((nodeStr==10) == 1);
    if ~isempty(sp) 
      nodeStr(sp) = ' '; 
    end
    
    % restore '~|' inside block name to '/'
    nodeStr = strrep(nodeStr, '~|', '/');
    
    % create the node object for tree model
    node = javax.swing.tree.DefaultMutableTreeNode(nodeStr);
    
    if lvl == 0
      treenode.add(node);
      lvl = lvl + 1;
    else
      lastNode.add(node);
    end
    lastNode = node;
    
  end
  
  prevBlkParent = get_param(blks{i}, 'Parent');
end

% end setjavaxtreenode
