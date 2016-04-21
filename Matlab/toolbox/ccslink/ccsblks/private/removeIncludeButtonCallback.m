function removeIncludeButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:13 $

listboxIdx = get(handles.includePathsListboxTag,'Value');

% Remove this item from UDATA.sourceFiles list
blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
if ~isfield(UDATA,'includePaths'),
    UDATA.includePaths = {};
end
for k = (listboxIdx) : (length(UDATA.includePaths)-1),
    UDATA.includePaths{k} = UDATA.includePaths{k+1};
end
UDATA.includePaths = UDATA.includePaths(1:end-1);
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Update listbox
if ~isempty(UDATA.includePaths),
    set(handles.includePathsListboxTag,'Value',length(UDATA.includePaths));
    set(handles.includePathsListboxTag,'String',UDATA.includePaths);
else
    set(handles.includePathsListboxTag,'Value',1);
    set(handles.includePathsListboxTag,'String','[none]')
end
