function interpy(Editor,MagData,PhaseData)
%INTERPY  Sets Y coordinate of objects overlayed on Bode plots.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $ $Date: 2002/04/10 04:55:59 $

HG = Editor.HG;

% Convert freq. data to current units
FreqData = unitconv(Editor.Frequency,'rad/sec',Editor.Axes.XUnits);

% Magnitude plot
Handles = [HG.Compensator.Magnitude ; HG.System.Magnitude];
X = get(Handles,{'Xdata'});
Y = interp1(FreqData,MagData,cat(1,X{:}));
for ct=1:length(Handles)
	set(Handles(ct),'Ydata',Y(ct))
end

if nargin==3
	% Phase plot (except when mag only requested)
	Handles = [HG.Compensator.Phase ; HG.System.Phase];
	X = get(Handles,{'Xdata'});
	Y = interp1(FreqData,PhaseData,cat(1,X{:}));
	for ct=1:length(Handles)
		set(Handles(ct),'Ydata',Y(ct))
	end
end