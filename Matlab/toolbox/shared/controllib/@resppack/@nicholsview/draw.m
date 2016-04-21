function draw(this, Data,NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:30 $

AxGrid = this.AxesGrid;

% Sizes and unit conversions
[Ny, Nu] = size(this.Curves);
Mag   = unitconv(Data.Magnitude, Data.MagUnits,   'dB');
Phase = unitconv(Data.Phase,     Data.PhaseUnits, AxGrid.XUnits);

if strcmp(this.UnwrapPhase, 'off')
  Pi = unitconv(pi, 'rad', AxGrid.XUnits);
  Phase = mod(Phase+Pi,2*Pi) - Pi;
end

% Redraw curves

for ct = 1:Ny*Nu
    % REVISIT: remove conversion to double (UDD bug where XOR mode ignored)
    if ~isempty(Mag)
        set(double(this.Curves(ct)), 'XData', Phase(:,ct), 'YData', Mag(:,ct));
    else
        set(double(this.Curves(ct)), 'XData', [], 'YData', []);
    end
end
