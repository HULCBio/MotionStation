function initialize(Constr)
%INITIALIZE   Initializes root-locus natural frequency constraint object

%   Author(s): N. Hickey
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2001/08/15 10:46:56 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzfrequency-specific listeners
p = [Constr.findprop('Ts');...
        Constr.findprop('Frequency');...
        Constr.findprop('Type')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
