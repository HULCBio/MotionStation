function hide(h)
    % hides this model explorer

    javaHandle = java(h.jModelExplorer);

    javaHandle.setVisible(0);


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:03 $
