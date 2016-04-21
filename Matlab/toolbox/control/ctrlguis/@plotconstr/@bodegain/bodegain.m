function h = bodegain
%BODEGAIN  Constructor for the Bode Gain Constraint objects.

%   Authors: N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/04/10 05:07:41 $

% Create class instance
h = plotconstr.bodegain;

% Initialize properties 
h.Thickness = 0.08;
h.Frequency = [1 10];
h.Magnitude = [0 0];

% Install default BDF
h.defaultbdf;
