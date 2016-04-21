function targetSelectionTabButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:27 $

setVisForTargetSelectionTab(handles,  'on');
setVisForFunctionInterfaceTab(handles,'off');
setVisForCodeGenerationTab(handles,   'off');

blk = getBlockName(handles.HilBlkFigureTag);
mdlName = HilBlkGetParentSystemName(blk);
if ~strcmp(get_param(mdlName,'blockdiagramtype'), 'library'),
    UDATA = get_param(blk,'UserData');
    UDATA.lastSelectedTab = 1;
    set_param(blk,'UserData',UDATA);
end
