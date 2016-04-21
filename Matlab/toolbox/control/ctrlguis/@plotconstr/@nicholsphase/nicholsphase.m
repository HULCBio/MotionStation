function h = nicholsphase
%NICHOLSPHASE  Constructor for the Nichols Phase Margin Constraint objects.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:09:39 $

% Create class instance
h = plotconstr.nicholsphase;

% Initialize properties 
h.Thickness = 0.04;
h.OriginPha = -180; % phase margin location (in deg)
h.MarginPha =   30; % phase margin (in deg)

% Install default BDF
h.defaultbdf;
