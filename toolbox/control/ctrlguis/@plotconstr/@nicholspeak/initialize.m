function initialize(Constr)
%INITIALIZE  Initializes Nichols Closed-Loop Peak Gain Constraint objects

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2001/08/17 14:01:24 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @nicholsphase specific listeners
p = [Constr.findprop('OriginPha') ; Constr.findprop('PeakGain')];
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);
