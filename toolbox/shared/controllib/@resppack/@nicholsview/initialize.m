function initialize(this,Axes)
%  INITIALIZE  Initializes @nicholsview objects.

%  Author(s): Bora Eryilmaz
%  Revised :
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:32 $

% Create Nichols curves (Axes = HG axes to which curves are plotted)
[Ny,Nu] = size(Axes);
Curves = zeros(Ny,Nu);
for ct = Ny*Nu:-1:1
  Curves(ct) = line('XData', NaN, 'YData', NaN, ...
		    'Parent',  Axes(ct), 'Visible', 'off');
end

this.Curves = handle(reshape(Curves,[Ny Nu]));