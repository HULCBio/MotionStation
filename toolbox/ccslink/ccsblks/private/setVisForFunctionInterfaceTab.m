function setVisForFunctionInterfaceTab(handles,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:19 $

set(handles.functionInterfaceTabPatchTextTag,'visible',val);
set(handles.funcDeclEditBoxTag,'visible',val);
set(handles.funcNameEditBoxTag,'visible',val);
set(handles.funcDeclTextTag,'visible',val);
set(handles.funcNameTextTag,'visible',val);
set(handles.specifyPrototypeCheckboxTag,'visible',val);
set(handles.manageDTypesButtonTag,'visible',val);
set(handles.queryButtonTag,'visible',val);
set(handles.argParamsFrameTag,'visible',val);
set(handles.functionBrowseButtonTag,'visible',val);
set(handles.argChooserTextTag,'visible',val);
set(handles.argChooserListboxTag,'visible',val);
set(handles.argParamsTextTag,'visible',val);
set(handles.argNameTextTag,'visible',val);
set(handles.argLabelTextTag,'visible',val);
set(handles.cTypeLabelTextTag,'Visible',val);
set(handles.cTypeTextTag,'Visible',val);
set(handles.equivTypeLabelTag,'visible',val);
set(handles.equivTypeTextTag,'visible',val);
set(handles.portAssignPopupTag,'visible',val);
set(handles.portAssignTextTag,'visible',val);
set(handles.timeoutEditBoxTag,'visible',val);
set(handles.timeoutLabelTag,'visible',val);

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
if UDATA.numArgs>0 || UDATA.hasReturnValue,
    selectedArgNum = get(handles.argChooserListboxTag,'value');
    if selectedArgNum <= UDATA.numArgs,
        arg = UDATA.args(selectedArgNum);
    else
        arg = UDATA.retval;
    end
    setVisOnAllArgSpecificParams(handles,arg,val);
else
    setVisOnAllArgSpecificParams(handles,[],val)
end
