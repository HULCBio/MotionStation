function sampev(varargin)
%SAMPEV Sample event handle for ActiveX control.
%  SAMPEV is a sample event handler function for the example sample 
%  control (version 2) that is shipped with MATLAB. The events 
%  fired from this control (progID: mwsamp.mwsampctrl.2) are 
%  Click, dblClick and MouseDown. The event handler displays 
%  a text message in the MATLAB command window when the event is fired.
%
%  See also MWSAMP, ACTXCONTROL.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.9.6.2 $ $Date: 

eventname = varargin{end};

if (strcmpi(eventname, 'Click'))
   	disp ('Click Event Fired')
elseif(strcmpi(eventname,'dblclick'))     
    disp ('dblclick Event Fired')   
elseif(strcmpi(eventname,'MouseDown'))
    sprintf('Mousedown event Fired. X pos: %d, Y pos: %d', double(varargin{5}), double(varargin{6}))
end