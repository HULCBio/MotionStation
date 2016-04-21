function initialize(Constr)
%INITIALIZE   Initializes settling-time constraint.

%   Author(s): N. Hickey
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2001/08/15 10:43:24 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzsettling-specific listeners
p = [Constr.findprop('Ts'); Constr.findprop('SettlingTime')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
