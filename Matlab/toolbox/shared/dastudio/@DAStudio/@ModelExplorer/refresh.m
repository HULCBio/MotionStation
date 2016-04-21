function refresh(h)
    % refreshes the ModelExplorer

    javaHandle = java(h.jModelExplorer);

    javaHandle.refresh;


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:04 $
