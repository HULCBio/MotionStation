function hgset_plotvis(Editor,junk)
% Toggles visibility of mag/phase plots.

%   $Revision: 1.10 $  $Date: 2001/08/10 21:07:59 $
%   Copyright 1986-2001 The MathWorks, Inc.

if strcmp(Editor.Visible,'on') % not true during load session
    % Reposition axes 
    hgset_position(Editor,Editor.Position);
    
    % Adjust axes+dependencies visibility
    Editor.hgset_axisvis;
    
    % Adjust X tick visibility on Mag axis
    if strcmp(Editor.PhaseVisible,'on')
        set(Editor.hgget_axeshandle(1),'XtickLabel',[]);
    else
        set(Editor.hgget_axeshandle(1),'XtickLabelMode','auto')
    end
    
    % Adjust label visibility
    hgset_labels(Editor,Editor.Xlabel,'Xlabel');
    hgset_labels(Editor,Editor.Ylabel,'Ylabel');
    hgset_labels(Editor,Editor.Title,'Title');
    
    % Refresh limits (may be stale for invisible handles)
    if ~strcmp(Editor.EditMode,'off')
        Editor.updatelims;
    end
end

