function codeGenerationTabButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:55 $

setVisForTargetSelectionTab(handles,  'off');
setVisForFunctionInterfaceTab(handles,'off');
setVisForCodeGenerationTab(handles,   'on');

blk = getBlockName(handles.HilBlkFigureTag);
mdlName = HilBlkGetParentSystemName(blk);
if ~strcmp(get_param(mdlName,'blockdiagramtype'), 'library'),
    UDATA = get_param(blk,'UserData');
    UDATA.lastSelectedTab = 3;
    set_param(blk,'UserData',UDATA);
end

if strcmp(get(handles.statusTextTag,'string'), ...
        ['Choose target board and click "Function ' ...
            'Interface" tab to continue.']),
    set(handles.statusTextTag,'string', '');
end
