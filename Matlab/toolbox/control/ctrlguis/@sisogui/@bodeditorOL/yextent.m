function Range = yextent(Editor,type)
%YEXTENT  Finds Y extent of visible data.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2003/01/07 19:34:12 $

% Current X limits (in rad/sec)
PlotAxes = getaxes(Editor.Axes);
Xlims = unitconv(get(PlotAxes(1),'Xlim'),Editor.Axes.XUnits,'rad/sec');
W = Editor.Frequency;

% Find minimal non-empty coverage of Xlims
idxs = max([1;find(W<Xlims(1))]);
idxe = min([find(W>Xlims(2));length(W)]);

switch type
case 'mag'
   VisData = Editor.Magnitude(idxs:idxe);
case 'phase'
   VisData = Editor.Phase(idxs:idxe);
%   if ~isempty(Editor.HG.PhaseMargin)
   phsMrgn = Editor.HG.PhaseMargin;
   if ~isempty(phsMrgn),
      % Include phase margin line
      VisData = [VisData ; reshape(get(Editor.HG.PhaseMargin.vLine,'YData'),[2 1])];
   end
end
Range = [min(VisData) , max(VisData)];
   
