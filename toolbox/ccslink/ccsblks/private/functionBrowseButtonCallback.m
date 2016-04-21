function functionBrowseButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:58 $

blk = getBlockName(handles.HilBlkFigureTag);

% Bring up browse gui
s.blk = blk;
set(handles.statusTextTag,'string', 'Getting function list ... ');
funcName = HilBlkFuncBrowseGui('UserData',s);
set(handles.statusTextTag,'string','');

% Update func name edit box and simulate edit box callback
% (If user closes dialog via "X", gui output will be [], so we 
%  do nothing.)
if ~isempty(funcName),
    set(handles.funcNameEditBoxTag,'String',funcName);
    % Don't update UserData; func name callback will do this.
    % (it needs to be stale)
    funcNameEditBoxCallback(...
        handles.funcNameEditBoxTag, eventdata, handles);
end
