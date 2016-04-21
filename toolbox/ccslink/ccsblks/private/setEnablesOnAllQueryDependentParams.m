function setEnablesOnAllQueryDependentParams(handles,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:15 $

set(handles.argChooserTextTag,'Enable',val);
set(handles.argChooserListboxTag,'Enable',val);
set(handles.portAssignTextTag,'Enable',val);
set(handles.portAssignPopupTag,'Enable',val);
set(handles.storageOptionTextTag,'Enable',val);
set(handles.storageOptionPopupTag,'Enable',val);
set(handles.sizeTextTag,'Enable',val);
set(handles.sizeEditBoxTag,'Enable',val);
set(handles.argNameTextTag,'Enable',val);
set(handles.argLabelTextTag,'Enable',val);
set(handles.equivTypeLabelTag,'Enable',val);
set(handles.equivTypeTextTag,'Enable',val);
set(handles.cTypeLabelTextTag,'Enable',val);
set(handles.cTypeTextTag,'Enable',val);
set(handles.globVarNameTextTag,'Enable',val);
set(handles.globVarNameEditBoxTag,'Enable',val);
set(handles.addressTextTag,'Enable',val);
set(handles.addressEditBoxTag,'Enable',val);
%set(handles.argParamsFrameTag,'Enable',val);
%set(handles.argParamsTextTag,'Enable',val);
