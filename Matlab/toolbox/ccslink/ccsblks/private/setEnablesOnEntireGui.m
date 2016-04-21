function setEnablesOnEntireGui(handles,val)
% When viewed from library, entire gui should be disabled.
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:16 $

set(handles.boardNamePopupTag,'enable',val);
set(handles.boardNameTextTag,'enable',val);
set(handles.funcDeclEditBoxTag,'enable',val);
set(handles.specifyPrototypeCheckboxTag,'enable',val);
set(handles.funcDeclTextTag,'enable',val);
set(handles.funcNameEditBoxTag,'enable',val);
set(handles.funcNameTextTag,'enable',val);
set(handles.procNamePopupTag,'enable',val);
set(handles.procNameTextTag,'enable',val);
set(handles.queryButtonTag,'enable',val);
set(handles.manageDTypesButtonTag,'enable',val);
set(handles.functionBrowseButtonTag,'enable',val);
set(handles.sourceFilesLabelTag,'enable',val);
set(handles.statusTextTag,'enable',val);
set(handles.projFilesListboxTag,'enable',val);
set(handles.includePathsListboxTag,'enable',val);
set(handles.addFileButtonTag,'enable',val);
set(handles.removeFileButtonTag,'enable',val);
set(handles.addIncludeButtonTag,'enable',val);
set(handles.removeIncludeButtonTag,'enable',val);
set(handles.timeoutEditBoxTag,'enable',val);

setEnablesOnAllQueryDependentParams(handles,val);
