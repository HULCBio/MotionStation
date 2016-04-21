function deleteSelected(h)
    % deletes the selected UDD objects from the list display pane

    javaHandle = java(h.jModelExplorer);

    javaHandle.deleteSelected;


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:01 $
