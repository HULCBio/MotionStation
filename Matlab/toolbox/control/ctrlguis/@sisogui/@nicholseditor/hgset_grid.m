function hgset_grid(Editor, NewState)
%HGSET_GRID  HG rendering of editor's Grid property.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/08/15 12:31:00 $

% Get handle to HG objects
HG = Editor.HG;

if strcmp(Editor.Grid, 'on')
  % Turn 0 dB Line off
  set(HG.AxisLine, 'Visible', 'off');
else
  % Turn 0 dB Line on
  set(HG.AxisLine, 'Visible', 'on');
  
  % Turn grid off
  % REVISIT: consolidate
  delete(HG.GridLines(ishandle(HG.GridLines)))
  HG.GridLines = [];
  Editor.HG = HG;
end

% Actual grid plotting deferred to UPDATELIMS to include M and N contours
% and position the labels appropriately.
Editor.updatelims;
