function reframe(Editor,PlotAxes,varargin)
%REFRAME  Adapter to @axesgroup/reframe.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:05:54 $
Axes = Editor.Axes;

% Determine ruler values
if strcmp(Axes.XUnits,'deg')
   XRuler = 'deg';
else
   XRuler = 'lin';
end

% Reframe
Axes.reframe(getaxes(Axes),XRuler,'dB',varargin{:});
