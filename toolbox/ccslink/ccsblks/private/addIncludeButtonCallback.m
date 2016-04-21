function addIncludeButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:51 $

if ~isfield(handles,'HilBlkFigureTag')
    warning(['Handles struct does not have field ' ... 
        '''HilBlkFigureTag''... can''t execute addFileButton callback.'])
    return;
end

% Remember where we were last located
wd = pwd;
cd(LastDir('get'));
% Display standard directory browse GUI
newDir = uigetdir('','Choose directory to be added to include path.');
cd(wd);
if newDir==0,
    % User clicked "cancel"
    return;  
end
LastDir('set',newDir);

if isempty(newDir) || ...
    ~isempty(findstr(newDir,' ')) || ...
    ~isempty(findstr(newDir,',')) || ...
    ~isempty(findstr(newDir,'|')) || ...
    strcmp(newDir(1:2),'\\'),
    uiwait(errordlg(...
    ['Include path entries must contain full path ' ...
        'name, e.g. "d:\proj1\src. ' ...
        'Enter one per line, with no spaces or commas.'], ...
    'Error in HIL Function Call Block','modal'));
    return;
end

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
if ~isfield(UDATA,'includePaths'),
    UDATA.includePaths = {};
end
UDATA.includePaths{end+1} = newDir;
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Update listbox
set(handles.includePathsListboxTag,'string',UDATA.includePaths);
% Select this item
set(handles.includePathsListboxTag,'Value',length(UDATA.includePaths));
