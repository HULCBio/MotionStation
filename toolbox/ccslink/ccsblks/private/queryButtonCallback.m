function queryButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:11 $

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
if isempty(UDATA.funcName),
    set(handles.statusTextTag,'string','No function specified');
    %setVisOnAllQueryDependentParams(handles, 'off');
else
    set(handles.statusTextTag,'string','Querying target ... please wait');
    % Set up objects and add derived info to UserData
    PDATA = HilBlkPersistentData(blk,'get');
    % Invalidate current stored func object (if any);
    %    this is considered to be the user's intention in pressing
    %    the button.
    PDATA.tgtFcnObjStale = true;
    PDATA.tgtFcnObjFullyDeclared = false;
    HilBlkPersistentData(blk,'set',PDATA);
    try
        HilBlkSetUpLinkObjects(blk);
    catch
        uiwait(errordlg(lasterr, ...
            'Error in HIL Function Call Block','modal'));
        set(handles.statusTextTag,'string', ...
            'Error querying target. ');
    end
    set(handles.statusTextTag,'string','');
    % Handle Declaration-related gui tasks
    handleDeclaration(blk,handles);
    
end  % if isempty(UDATA.funcName)
