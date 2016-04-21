function initialize(this, Axes)
%  INITIALIZE  Initializes @pzview objects.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:18 $

% Create empty curves
[Ny,Nu] = size(Axes);

% Create empty curves
PoleCurves = zeros(Ny*Nu,1); 
ZeroCurves = zeros(Ny*Nu,1);
for ct = 1:Ny*Nu
   PoleCurves(ct,1) = line('XData', [], 'YData', [], ...
      'Parent',  Axes(ct), 'Visible', 'off','Tag','PZ_Pole',...
      'Marker','x','MarkerSize',7,'LineStyle','none');
   ZeroCurves(ct,1) = line('XData', [], 'YData', [], ...
      'Parent',  Axes(ct), 'Visible', 'off','Tag','PZ_Zero',...
      'Marker','o','LineStyle','none');
end
this.PoleCurves = reshape(handle(PoleCurves),[Ny Nu]);
this.ZeroCurves = reshape(handle(ZeroCurves),[Ny Nu]);
