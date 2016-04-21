function setVisForTargetSelectionTab(handles,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:20 $

set(handles.targetSelectionTabPatchTextTag,'visible',val);
set(handles.procNamePopupTag,'visible',val);
set(handles.boardNamePopupTag,'visible',val);
set(handles.procNameTextTag,'visible',val);
set(handles.boardNameTextTag,'visible',val);
