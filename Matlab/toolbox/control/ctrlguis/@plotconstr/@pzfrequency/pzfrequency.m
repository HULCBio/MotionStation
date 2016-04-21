function h = pzfrequency
%PZFREQUENCY  Constructor for Natural Frequency Constraint objects.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 05:10:11 $

% Create class instance
h = plotconstr.pzfrequency;

% Initialize properties 
h.Thickness = 0.08;
h.Frequency = 1;
h.Type = 'upper';

% Install default BDF
h.defaultbdf;
