function status = vqsave_if_dirty(hFig, action)
% SAVE_IF_DIRTY Query the user to save if GUI is dirty.
% Inputs:
%     hFig - handle to VQDtool
%     action - 'closing', or 'loading' file.
% Output:
%     status = 1 if Yes, No, or UIs not dirty.
%     status = 0 if Cancel.
%

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:05 $

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
ToolIDStr = 'VQ Design Tool';

% If changes have not been saved, warn (prompt) user
ansBtn = questdlg({sprintf('Save %s session before %s?',file,action)},ToolIDStr,'Cancel');

switch ansBtn,
case 'Yes',
    status = 1;
    vqsave(hFig);
case 'No'
    status = 1;
    % User didn't save, reset dirty flag so opened file is not dirty
case 'Cancel'        
    status = 0;
end

% [EOF]
