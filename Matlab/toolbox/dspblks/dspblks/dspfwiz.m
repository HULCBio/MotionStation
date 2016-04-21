function dspfwiz
%DSPFWIZ Filter Realization Wizard graphical user interface.
%   Automatically generates filter architecture models in a
%   Simulink subsystem block using individual sum, gain, and
%   delay blocks, according to user-defined specifications.
%
%   See also DSPLIB.


%    Copyright 1995-2003 The MathWorks, Inc.
%    $Revision: 1.34.4.2 $  $Date: 2004/04/12 23:05:17 $

% Launch FDATool
opts.visstate = 'off';
h = fdatool(opts);

% Set the sidebar to the dspfwiz panel
hsb  = find(h, '-class', 'siggui.sidebar');
indx = string2index(hsb, 'dspfwiz');

set(hsb, 'CurrentPanel', indx);

% Set up the Realize Model panel
load(h, 'fwizdef.mat', 'force');

% Make everything on FDATool visible
set(h, 'Visible', 'On');

% [EOF] dspfwiz.m
