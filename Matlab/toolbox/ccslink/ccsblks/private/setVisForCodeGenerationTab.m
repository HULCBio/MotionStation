function setVisForCodeGenerationTab(handles,val)
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:18 $

set(handles.codeGenerationTabPatchTextTag,'visible',val);
set(handles.sourceFilesLabelTag,'visible',val);
set(handles.includeLabelTag,'visible',val);
set(handles.projFilesListboxTag,'visible',val);
set(handles.includePathsListboxTag,'visible',val);
set(handles.addFileButtonTag,'visible',val);
set(handles.removeFileButtonTag,'visible',val);
set(handles.addIncludeButtonTag,'visible',val);
set(handles.removeIncludeButtonTag,'visible',val);
