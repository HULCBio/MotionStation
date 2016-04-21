function h = pzsettling
%PZSETTLING  Constructor for Settling Time Constraint objects.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:08:19 $

% Create class instance
h = plotconstr.pzsettling;

% Initialize properties 
h.Thickness = 0.08;
h.SettlingTime = 1;
h.Type = 'upper';

% Install default BDF
h.defaultbdf;
