function out = newconstr(Editor,keyword,CurrentConstr)
%NEWCONSTR  Interface with dialog for creating new constraints.
%
%   LIST = NEWCONSTR(Editor) returns the list of all available
%   constraint types for this editor.
%
%   CONSTR = NEWCONSTR(Editor,TYPE) creates a constraint of the 
%   specified type.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:56:46 $

ni = nargin;

if ni==1
    % All options
    out = {'Upper Gain Limit';'Lower Gain Limit'};
else
	if ni>2 & isa(CurrentConstr,'plotconstr.bodegain')
		% Recycle existing instance
		Constr = CurrentConstr;  
	else
		% Create new instance
		Constr = plotconstr.bodegain;
	end
    PlotAxes = getaxes(Editor.Axes);
    switch keyword
    case 'Upper Gain Limit'
        Constr.Type = 'upper';
        Constr.Parent = PlotAxes(1);
    case 'Lower Gain Limit'
        Constr.Type = 'lower';
        Constr.Parent = PlotAxes(1);
    end
    % Sample time and frequency units 
    Constr.Ts = Editor.LoopData.Ts;
    Constr.FrequencyUnits = Editor.Axes.XUnits;
    % Make sure constraint is below Nyquist freq.
    if Constr.Ts
       Constr.Frequency = (pi/Constr.Ts) * [0.01 0.1];
    end
	out = Constr;
end


