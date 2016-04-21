function h = nicholspeak
%NICHOLSPEAK  Constructor for Nichols closed-loop peak gain constraint objects.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:11:44 $

% Create class instance
h = plotconstr.nicholspeak;

% Initialize properties 
h.Thickness = 0.04;
h.OriginPha  = -180; % phase margin location (in deg)
h.PeakGain   =    3;  % peak closed-loop gain (in dB)

% Install default BDF
h.defaultbdf;
