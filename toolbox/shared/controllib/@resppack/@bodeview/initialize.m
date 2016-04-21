function initialize(this,Axes)
%  INITIALIZE  Initializes @bodeview objects.

%  Author(s): Bora Eryilmaz, John Glass
%  Revised : Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:35 $

% Get axes in which responses are plotted
[s1,s2,s3] = size(Axes);  % Ny-by-Nu-by-2
Axes = reshape(Axes,[s1*s2 s3]);

% Create mag & phase curves & nyquist lines
MagCurves = zeros([s1 s2]);
PhaseCurves = zeros([s1 s2]);
MagNyquistLines = zeros([s1 s2]);
PhaseNyquistLines = zeros([s1 s2]);
for ct=1:s1*s2
   MagCurves(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct,1), 'Visible', 'off');
   PhaseCurves(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct,2), 'Visible', 'off');
   MagNyquistLines(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct,1), 'Visible', 'off' , ...
      'XlimInclude','off', 'YlimInclude','off',...
      'HandleVisibility', 'off', 'HitTest', 'off', 'Color', [0 0 0]);
   PhaseNyquistLines(ct) = line('XData', NaN, 'YData', NaN, ...
      'Parent', Axes(ct,2), 'Visible', 'off' , ...
      'XlimInclude','off', 'YlimInclude','off',...
      'HandleVisibility', 'off', 'HitTest', 'off', 'Color', [0 0 0]);
end
this.MagCurves = handle(MagCurves);
this.PhaseCurves = handle(PhaseCurves);
this.MagNyquistLines = handle(MagNyquistLines);
this.PhaseNyquistLines = handle(PhaseNyquistLines);