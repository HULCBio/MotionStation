function sizeEditBoxCallback(hObject, eventdata, handles)
% Pass new choice into UserData
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:24 $


blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

selectedArgNum = get(handles.argChooserListboxTag,'value');
% Size param in UserData must be 2 elements long, type uint32.
userStr = get(hObject,'string');
% xxx    For now, require literal expression.  For variables,
%         need to evaluate in parent mask workspace and base workspace.
%         But then need to save user's string in UDATA and only resolve
%         the value at Ctrl-D time.
[val success] = str2num(userStr); 
if ~success,
    uiwait(errordlg('Size must be a literal expression, e.g.  [64 2].', ...
        'Error in HIL Function Call Block','modal'));
    return;
end
val = uint32(val);
if length(val)~=2,
    val = [val(1) uint32(1)];
end
if selectedArgNum > UDATA.numArgs,
    UDATA.retval.size = val;
else
    UDATA.args(selectedArgNum).size = val;
end

set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');
