function addFileButtonCallback(hObject, eventdata, handles)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:44:50 $

if ~isfield(handles,'HilBlkFigureTag')
    warning(['Handles struct does not have field ' ... 
        '''HilBlkFigureTag''... can''t execute addFileButton callback.'])
    return;
end

% Remember where we were last located
wd = pwd;
cd(LastDir('get'));
% Display standard file-browse GUI
[file1, path1] = uigetfile({'*.c';'*.lib';'*.cpp';'*.*'},'Choose file to add');
cd(wd);
if file1==0,
    % User clicked "cancel"
    return;  
end
LastDir('set',path1);

newFile = fullfile(path1, file1);
if isempty(path1) || isempty(file1) || ...
    ~isempty(findstr(newFile,' ')) || ...
    ~isempty(findstr(newFile,',')) || ...
    ~isempty(findstr(newFile,'|')) || ...
    strcmp(path1(1:2),'\\'),
    uiwait(errordlg(...
    ['Source file entries must contain path and ' ...
        'file name, e.g. "d:\proj1\myFunc.c". ' ...
        'Enter one per line, with no spaces or commas.'], ...
    'Error in HIL Function Call Block','modal'));
    return;
end

blk = getBlockName(handles.HilBlkFigureTag);
UDATA = get_param(blk,'UserData');
UDATA.sourceFiles{end+1} = newFile;
set_param(blk,'UserData',UDATA);
mdlName = HilBlkGetParentSystemName(blk);
set_param(mdlName,'Dirty','on');

% Update listbox
set(handles.projFilesListboxTag,'string',UDATA.sourceFiles);
% Select this item
set(handles.projFilesListboxTag,'Value',length(UDATA.sourceFiles));
