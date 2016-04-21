function initialize(this,Axes)
%INITIALIZE  Initializes @timeview graphics.

%  Author(s): Bora Eryilmaz, John Glass
%  Revised  : Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:56 $

% Create empty curves (Axes = HG axes to which curves are plotted)
[Ny,Nu] = size(Axes);
Curves = [];
for ct = Ny*Nu:-1:1
  Curves(ct,1) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',  Axes(ct), 'Visible', 'off');
end
this.Curves = handle(reshape(Curves,[Ny Nu]));
