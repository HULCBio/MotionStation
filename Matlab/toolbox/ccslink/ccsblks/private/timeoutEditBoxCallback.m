function timeoutEditBoxCallback(hObject, eventdata, handles)

% Copyright 2001-2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2003/07/03 17:56:25 $

% Pass new choice into UserData

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');

val = str2num(get(hObject,'String'));
if ~(val>0),
    error('Timeout must be a positive number.')
end
UDATA.funcTimeout = val;

set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Put value into stored object 
PDATA = HilBlkPersistentData(blk,'get');
if isfield(PDATA,'tgtFcnObj')
    PDATA.tgtFcnObj.timeout = val;
    HilBlkPersistentData(blk,'set',PDATA);
end

