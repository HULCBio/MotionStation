function aero_preload_atc
% AERO_PRELOAD_ATC Opens GUI interface to the Air Traffic Control
% model along with loading images to be displayed within the 
% model.

%   Stacey Gage
%	Copyright 1990-2004 The MathWorks, Inc.
%	$Revision: 1.5.2.2 $  $Date: 2004/04/15 00:39:02 $

aero_atcgui;
pathname = [fileparts(which('aero_atc')) filesep];
evalin('base',['radar=imread([''' pathname ''',''images/atc_radar.bmp''],''bmp'');']);
evalin('base',['plane=imread([''' pathname ''',''images/atc_737.bmp''],''bmp'');']);
evalin('base',['weather=imread([''' pathname ''',''images/atc_weather.bmp''],''bmp'');']);
