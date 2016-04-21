function initialize(this, Axes)
%INITIALIZE  Initializes @sigmaview objects.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:27 $

% Create single curve (number varies with data)
this.Curves = handle(line('XData', NaN, 'YData', NaN, ...
   'Parent', Axes, 'Visible', 'off'));
this.NyquistLines = handle(line('XData', NaN, 'YData', NaN, ...
   'Parent', Axes, 'Visible', 'off', 'HandleVisibility', 'Off', ...
   'XlimInclude','off','YlimInclude','off'));