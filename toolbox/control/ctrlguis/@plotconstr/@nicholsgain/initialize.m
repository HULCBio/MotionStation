function initialize(Constr)
%INITIALIZE  Initializes Nichols Gain Margin Constraint objects

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2001/08/15 12:32:53 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @nicholsgain specific listeners
p = [Constr.findprop('OriginPha') ; Constr.findprop('MarginGain')]; 
Listener = handle.listener(Constr, p, 'PropertyPostSet', @update);
Listener.CallbackTarget = Constr;
Constr.addlisteners(Listener);
