function h = nicholsgain
%NICHOLSPHASE  Constructor for the Nichols Gain Margin Constraint objects.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:11:10 $

% Create class instance
h = plotconstr.nicholsgain;

% Initialize properties 
h.Thickness  = 0.04;
h.OriginPha  = -180; % phase origin location (in deg)
h.MarginGain =   20; % gain margin (in dB)

% Install default BDF
h.defaultbdf;
