function reframe(Editor,PlotAxes,varargin)
%REFRAME  Adapter to @axesgroup/reframe.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:56:57 $
Axes = Editor.Axes;
hgaxes = getaxes(Axes,'2d');

% Determine ruler values
if strcmp(Axes.XScale,'log')
   XRuler = 'log';
else
   XRuler = 'lin';
end
if PlotAxes==hgaxes(1)
   % Working in mag axes
   if strcmp(Axes.YUnits{1},'dB')
      YRuler = 'dB';
   elseif strcmp(Axes.YScale{1},'log')
      YRuler = 'log';
   else
      YRuler = 'abs';
   end
else
   % Working in phase axes
   if strcmp(Axes.YUnits{2},'deg')
      YRuler = 'deg';
   else
      YRuler = 'lin';
   end
end

% Reframe
Axes.reframe(PlotAxes,XRuler,YRuler,varargin{:});
