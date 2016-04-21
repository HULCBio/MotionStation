function specifyPrototypeCheckboxCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:25 $

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
% The flag UDATA.declAutoDetermined is the opposite of the checkbox.  
% (This is due to a late change in spec.)
UDATA.declAutoDetermined = isequal(get(hObject,'value'),0);
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

if UDATA.declAutoDetermined,
    set(handles.funcDeclEditBoxTag,'enable','off');
    set(handles.funcDeclTextTag,'enable','off');
else
    set(handles.funcDeclEditBoxTag,'enable','on');
    set(handles.funcDeclTextTag,'enable','on');
end
