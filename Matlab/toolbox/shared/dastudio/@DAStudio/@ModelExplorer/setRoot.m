function setRoot(h, root)
    % lists the columnNames from the summary pane

    javaHandle = java(h.jModelExplorer);

    javaHandle.setRoot(com.mathworks.toolbox.dastudio.DATreeNode.create(java(root)));


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:07 $
