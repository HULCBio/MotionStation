function hgset_grid(Editor,NewState)
% HG rendering of editor's Grid property.

%   $Revision: 1.6 $  $Date: 2001/08/10 21:04:56 $
%   Copyright 1986-2001 The MathWorks, Inc.

if strcmp(Editor.Grid,'off')
    % Delete grid lines
    % REVISIT: consolidate
    HG = Editor.HG;
    delete(HG.GridLines(ishandle(HG.GridLines)))
    HG.GridLines = [];
    Editor.HG = HG;
end
    
% Leave it to UPDATELIMS to 
%   * plot grid (to include unit circle and position the labels appropriately)
%   * restore unit circle when Ts>0 and Grid=off
Editor.updatelims;

