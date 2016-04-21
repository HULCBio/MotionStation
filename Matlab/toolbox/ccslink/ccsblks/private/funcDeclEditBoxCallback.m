function funcDeclEditBoxCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:56 $

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
if UDATA.declAutoDetermined,
    error(['Unexpected program flow; func prototype edit box callback ' ...
        'should not be reached if UDATA.declAutoDetermined.'])
end

% Pass user's new string into UserData
userDecl = get(hObject,'string');
UDATA.funcDecl = userDecl;
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

PDATA = HilBlkPersistentData(blk,'get');

% Set tgtFcnObjFullyDeclared flag to "false".
% This is understood to be the user's intention
% by typing in this edit box.
% This also makes the function object stale, by new rules.
PDATA.tgtFcnObjFullyDeclared = false;
PDATA.tgtFcnObjStale = true;
HilBlkPersistentData(blk,'set',PDATA);

if isempty(userDecl),

    uiwait(errordlg( ...
        ['You must supply the function prototype string ' ...
            'or turn off "Specify function prototype."'], ...
        'Error in HIL Function Call Block','modal'));
    return;
    
else
    
    % Declare prototype and update dependent items 
    set(handles.statusTextTag,'string', ...
        'Registering function prototype ... please wait');
    
    try
        HilBlkSetUpLinkObjects(blk);
    catch
        uiwait(errordlg(lasterr, ...
            'Error in HIL Function Call Block','modal'));
        set(handles.statusTextTag,'string', ...
            'Error registering prototype.');
        return;
    end
    set(handles.statusTextTag,'string','');
    
end

% Do gui-specific tasks for new prototype.
handleDeclaration(blk,handles);
