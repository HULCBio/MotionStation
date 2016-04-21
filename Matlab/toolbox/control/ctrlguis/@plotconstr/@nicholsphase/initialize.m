function initialize(Constr)
%INITIALIZE  Initializes Nichols Phase Margin Constraint objects

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2001/08/17 14:01:54 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @nicholsphase specific listeners
p = [Constr.findprop('OriginPha') ; Constr.findprop('MarginPha')]; 
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);


