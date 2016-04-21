function varargout = dspblkwao2(action,varargin)
% DSPBLKWAO2 Wave Audio Output block helper function.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 20:57:34 $

if nargin<1, action='dynamic'; end

blk=gcb;

switch action
case 'dynamic'
   useDefault = strcmp(get_param(blk,'useDefaultDevice'),'on');
   orig_ena   = get_param(blk,'maskenables');
   new_ena    = orig_ena;
   
   % Enable or disable user device ID edit box:
   if useDefault,
      enaDeviceID = 'off';
   else
      enaDeviceID = 'on';
   end
   new_ena{4} = enaDeviceID;
   
   if ~isequal(orig_ena, new_ena),
      set_param(blk,'maskenables',new_ena);
   end
   
case 'init'
   
   useDefault   = strcmp(get_param(blk,'useDefaultDevice'),'on');
   userDeviceID = varargin{1};
   
   % Default device: send 0 to S-Fcn
   % Specific devices: send 1,2,...
   if useDefault,
      deviceID = 0;
   else
      deviceID = userDeviceID;
   end
   varargout = {deviceID};
   
case 'icon'
   % Icon drawing
   x1 = [.1 .1 .22 .42 .42 .22 .1];
   y1 = [.38 .62 .62 .9  .1  .38 .38];
   a=.6; s=10*pi/180; t = -s:pi/180:s; x = [  NaN a*cos(t)-.1]; y = [  NaN a*sin(t)+.5];
   a=.7; s=15*pi/180; t = -s:pi/180:s; x = [x NaN a*cos(t)-.1]; y = [y NaN a*sin(t)+.5];
   a=.8; s=25*pi/180; t = -s:pi/180:s; x = [x NaN a*cos(t)-.1]; y = [y NaN a*sin(t)+.5];
   x = [x NaN 0.05 NaN .75];
   y = [y NaN .08 NaN .92];
   x2 = [.18 .22 .22 .18];
   y2 = [.38 .38 .62 .62];
   varargout = {x,y,x1,y1,x2,y2};
   
otherwise,
   error('Unknown action specified');
end

% [EOF] dspblkwao2.m
