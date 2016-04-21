function h = pzdamping
%PZDAMPING  Constructor for Damping/Overshoot Constraint object.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:10:41 $

% Create class instance
h = plotconstr.pzdamping;

% Initialize properties 
h.Thickness = 0.08;
h.Damping = 0.707;
h.Type = 'upper';

% Install default BDF
h.defaultbdf;
