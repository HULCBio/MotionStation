function reframe(Editor,PlotAxes,varargin)
%REFRAME  Adapter to @axesgroup/reframe.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:58:38 $
Editor.Axes.reframe(PlotAxes,'lin','lin',varargin{:});