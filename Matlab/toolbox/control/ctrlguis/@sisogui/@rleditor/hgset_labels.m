function hgset_labels(Editor,NewSettings,LabelType)
% HG rendering of editor's Title, Xlabel, and Ylabel properties.

%   $Revision: 1.5 $  $Date: 2001/08/10 21:04:56 $
%   Copyright 1986-2001 The MathWorks, Inc.

% Update properties of corresponding HG object
hLabel = get(Editor.hgget_axeshandle,LabelType);
set(hLabel,NewSettings)

% Adjust visibility in figure (conditioned by editor visibility)
if strcmp(Editor.Visible,'off')
    set(hLabel,'Visible','off')
end
