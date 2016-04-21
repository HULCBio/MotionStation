function initialize(Constr)
%INITIALIZE   Initializes root-locus damping constraint object

%   Author(s): P. Gahinet
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2001/08/15 10:46:55 $

% Add generic listeners and mouse event callbacks
Constr.addlisteners;

% Add @pzdamping-specific listeners
p = [Constr.findprop('Ts'); Constr.findprop('Damping')]; 
PropL = handle.listener(Constr,p,'PropertyPostSet',@update);
PropL.CallbackTarget = Constr;
Constr.addlisteners(PropL);
