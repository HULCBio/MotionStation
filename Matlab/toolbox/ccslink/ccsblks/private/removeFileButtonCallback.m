function removeFileButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2004/04/08 20:45:12 $

listboxIdx = get(handles.projFilesListboxTag,'Value');

% Remove this item from UDATA.sourceFiles list
blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
for k = (listboxIdx) : (length(UDATA.sourceFiles)-1),
    UDATA.sourceFiles{k} = UDATA.sourceFiles{k+1};
end
UDATA.sourceFiles = UDATA.sourceFiles(1:end-1);
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Update listbox
if ~isempty(UDATA.sourceFiles),
    set(handles.projFilesListboxTag,'Value',length(UDATA.sourceFiles));
    set(handles.projFilesListboxTag,'String',UDATA.sourceFiles);
else
    set(handles.projFilesListboxTag,'Value',1);
    set(handles.projFilesListboxTag,'String','[none]')
end
