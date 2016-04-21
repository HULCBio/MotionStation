function initialize(Constr)
%INITIALIZE   Initializes Bode gain constraint objects

%   Author(s): N. Hickey
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2001/08/15 10:43:24 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @bodegain-specific listeners
p = [Constr.findprop('Ts'); ...
      Constr.findprop('Frequency') ; ...
      Constr.findprop('Magnitude')]; 
Listener = handle.listener(Constr,p,'PropertyPostSet',@update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);
