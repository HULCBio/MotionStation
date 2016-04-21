function dng_aircraft_set_flap(hActx)
%DNG_AIRCRAFT_SET_FLAP Sets the flap control for the aircraft demo.
%   This is a helper function designed exclusively for use by
%   the aircraft Active X demo.

% Copyright 1998-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/06/17 11:59:16 $

% Sets the min and max for the bar.  Note that the reverse direction
% property doesn't seem to work on this control, so the orientation
% is reversed in the model.
hActx.min = 0;
hActx.value = 0;
hActx.max = 3;

% Sets up the snap'ing of the flap control to the 4 positions.
hActx.snap = 1;
hActx.snapincrement = 1;

% The rest of this m-file just sets up the graphics so that the control
% appears nicely.
hActx.BarInner = .7;
hActx.BarOuter = .9;

hActx.Tics = 1;
hActx.TicID = 0;
hActx.TicStart = 0;
hActx.TicStop = 3;
hActx.TicDelta = 1;
hActx.TicInner = .4;
hActx.TicOuter = .6;
hActx.TicWidth = .01;

hActx.Captions = 2;
hActx.CaptionID = 0;
hActx.Caption = 'Up';
hActx.CaptionX = .15;
hActx.CaptionY = .03;

hActx.CaptionID = 1;
hActx.Caption = 'Dn';
hActx.CaptionX = .15;
hActx.CaptionY = .95;

