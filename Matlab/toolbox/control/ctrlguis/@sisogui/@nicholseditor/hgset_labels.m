function hgset_labels(Editor, NewSettings, LabelType)
%HGSET_LABELS  HG rendering of editor's Title, Xlabel, and Ylabel properties.

%   Author(s): B. Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2001/08/15 12:30:59 $

% Get handle to Nichols plot axes
PlotAxes = Editor.hgget_axeshandle;

% Update properties of the corresponding HG object
hLabel = get(PlotAxes, LabelType);
set(hLabel, NewSettings);

% Adjust visibility in figure (conditioned by editor visibility)
if strcmp(Editor.Visible, 'off')
  set(hLabel, 'Visible', 'off')
end
