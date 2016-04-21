function status = sqsave_if_dirty(hFig, action)
% SAVE_IF_DIRTY Query the user to save if GUI is dirty.
%
% Inputs:
%     hFig - handle to SQDTool
%     action - 'closing', or 'loading' file.
% Output:
%     status = 1 if Yes, No, or UIs not dirty.
%     status = 0 if Cancel.
%

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:19 $

% This should be a private method
FigTitle=get(hFig,'Name');
FigDirty =  FigTitle(end-1)=='*';
if ~FigDirty,
    status = 1;       % Proceed as normal
    return
end
ud = get(hFig,'UserData');
% Removes the path and any extension : file = Untitled (initially)
[path, file] = fileparts(ud.FileName); 

% If changes have not been saved, warn (prompt) user
ansBtn = questdlg({sprintf('Save %s session before %s?',file,action)},'SQ Design Tool','Cancel');

switch ansBtn,
case 'Yes',
    status = 1;
    sqsave(hFig);
case 'No'
    status = 1;
    % User didn't save, reset dirty flag so opened file is not dirty
case 'Cancel'        
    status = 0;
end

% [EOF]
