%MWSAMP Sample script to create ActiveX object.
%  Script to create the MATLAB sample ActiveX control. The script
%  sets the 'Label' and 'Radius' properties and invokes the 'Redraw'
%  method.
%
%  SAMPEV is the event handler for this control. The only event
%  fired by the control is 'Click', which is fired when the user
%  clicks on the control with the mouse. The event handler displays
%  a text message in the MATLAB command window when the event is fired.
%
%  See also SAMPEV, ACTXCONTROL.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.9.6.2 $ $Date: 2004/04/16 22:09:02 $

% Create a figure
f = figure('Position', [100 200 200 200]);

% create the control to fill the figure
h = actxcontrol('MWSAMP.MwsampCtrl.2', [0 0 200 200], f, 'sampev')

% Set the label of the control
set(h, 'Label', 'Click to fire event');

% Dot-name notation may be used in place of the SET command.
% set(h,'Radius',40);
h.Radius=40;

% Tell the control to redraw itself by invoking the Redraw method.
invoke(h, 'Redraw');

% Additional Sample code to invoke the Beep method, and release
% the interface.
% invoke(h, 'Beep');
% release(h)
