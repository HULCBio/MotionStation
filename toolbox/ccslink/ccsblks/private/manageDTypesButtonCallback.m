function manageDTypesButtonCallback(hObject, eventdata, handles)

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
% Get CCS Obj

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/08 20:45:05 $
PDATA = HilBlkPersistentData(blk,'get');
if PDATA.ccsObjStale,
    set(handles.statusTextTag,'string', ...
        'Connecting to Code Composer Studio(R) ... ');
    HilBlkGetCcsHandle(blk);
    PDATA = HilBlkPersistentData(blk,'get');
    set(handles.statusTextTag,'string', ...
        '');
end

[PDATA.ccsObj, h] = DataTypeManager(PDATA.ccsObj);
% Changes made in the GUI will be reflected in PDATA.ccsObj

% Wait for DataTypeManager gui to be closed by user.
% This places this callback function in waiting, but 
% the user may use the Hil Block dialog (or any other
% MATLAB activity) while the Types gui is still open.  
waitfor(h);   
% The remaining code in this callback will execute after
% the gui is closed.

% Store types in UserData
UDATA = get_param(blk,'UserData');
if ~isfield(UDATA,'typedefList') || ...
        ~isequal(UDATA.typedefList, PDATA.ccsObj.type.typelist),
    UDATA.typedefList = PDATA.ccsObj.type.typelist;
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
end

% Re-declare?      xxx
