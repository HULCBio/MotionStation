function setVisOnAllArgSpecificParams(handles,arg,val);
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:21 $

set(handles.argNameTextTag,'Visible',val);
set(handles.argLabelTextTag,'Visible',val);
set(handles.portAssignTextTag,'Visible',val);
set(handles.portAssignPopupTag,'Visible',val);
set(handles.cTypeLabelTextTag,'Visible',val);
set(handles.cTypeTextTag,'Visible',val);
set(handles.equivTypeLabelTag,'Visible',val);
set(handles.equivTypeTextTag,'Visible',val);

setVisOnPointerSpecificItems(handles,arg,val);

% Do not change the following; it may be clearer to preserve them
% set(handles.argParamsFrameTag,'Visible',val);
% set(handles.argParamsTextTag,'Visible',val);