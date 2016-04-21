function Range = xyextent(Editor, type)
%XYEXTENT  Finds X or Y extent of visible data.

%   Author(s): P. Gahinet, Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2002/04/10 05:05:16 $

PlotAxes = getaxes(Editor.Axes);

% Get comp. gain (zpk gain magnitude)
Gain = getzpkgain(Editor.EditedObject,'mag'); 

switch type
case 'mag'
   Lims = 10.^(get(PlotAxes, 'Ylim')/20);  % abs limits
   Lims = Lims/Gain;
   VisData = Editor.Magnitude(Editor.Magnitude >= Lims(1) & Editor.Magnitude <= Lims(2));
case 'phase'
   Lims = unitconv(get(PlotAxes, 'Xlim'), Editor.Axes.XUnits, 'deg');
   VisData = Editor.Phase(Editor.Phase >= Lims(1) & Editor.Phase <= Lims(2));
end

if length(VisData)>1
   Range = [min(VisData),max(VisData)]; % in abs or deg units !
else
   % Plot jumps over X or Y band
   Range = Lims;
end