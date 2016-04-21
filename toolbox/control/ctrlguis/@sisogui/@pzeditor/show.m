function show(Editor,Target)
%SHOW  Bring up and targets PZ editor.

%   Author: P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 04:55:10 $

% RE: Updating process is
%        show -> importdata -> update (includes initialize)

if ~strcmp(Editor.EditMode,'off')
    % Target editor (trigger update)
    Editor.EditedObject = Target;  
    
    % Update figure title
    Fig = Editor.HG.Figure;
    set(Fig,'Name',sprintf('Edit Compensator %s',Target.Identifier))

    % Make figure visible & bring to front
    Editor.Visible = 'on';
    figure(Fig);
end

