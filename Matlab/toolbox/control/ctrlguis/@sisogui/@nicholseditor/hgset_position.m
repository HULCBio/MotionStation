function hgset_position(Editor, NewPosition)
%HGSET_POSITION  HG rendering of editor's Position property.

%   Author(s): B. Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2001/08/15 12:31:00 $

% Get handle to Nichols plot axes
PlotAxes = Editor.hgget_axeshandle;

% Set editor position in host figure
set(PlotAxes, 'Position', NewPosition)
