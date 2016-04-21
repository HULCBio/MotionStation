function varargout = dspblkwai(action,varargin)
% DSPBLKWAI Wave Audio Input block helper function.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10 $ $Date: 2002/04/14 20:56:36 $

blk = gcb;
if nargin==0, action='dynamic'; end


switch action
case 'init'
   % nChans: number of channels
   isStereo        = strcmp(get_param(blk,'Stereo'),'on');
   if isStereo, nChans=2; else nChans=1; end
   
   % sRate: sample rate in Hz
   SampleRatePopup = get_param(blk,'SampleRate');
   if strcmp(SampleRatePopup,'User-defined'),
      sRate = varargin{1};
   else
      sRate = str2num(SampleRatePopup);
   end
   
   % bps: bits per sample
   bps = str2num(get_param(blk,'SampleWidth'));
   
   % fSize: samples per frame
   fSize = varargin{2};
   
   % qSize: Queue duration, in seconds
   qSize = varargin{3};
   
   % device ID:
   useDefault   = strcmp(get_param(blk,'useDefaultDevice'),'on');
   userDeviceID = varargin{4};
   % Default device: send 0 to S-Fcn
   % Specific devices: send 1,2,...
   if useDefault,
      deviceID = 0;
   else
      deviceID = userDeviceID;
   end
   
   varargout = {nChans, sRate, bps, fSize, qSize, deviceID};
   
   
case 'icon'
   % Icon drawing
   xrbase = [.65 .65 .575 .525 .525, .65   .725  .8   .875 .9   .9,    .975  .975 .84  .84,    .83  .8   .725 .65 .525];
   xlbase = 1-fliplr(xrbase);
   yrbase = [.02 .17 .245 .245 .47,  .49   .525  .59 .695 .845 .995,  .995  1.35   1.35   .995, .845 .695 .61  .56 .54];
   ylbase = fliplr(yrbase);
   xrmic = [.575 .65 .725 .75 .785 .785 .75 .725 .65 .575];
   xlmic = 1-fliplr(xrmic);
   yrmic = [.59 .62  .695 .77 .845 [1.445 1.52 1.595 1.67 1.7]+.25] + .06;
   ylmic = fliplr(yrmic);
   x1 = [xrbase xlbase];
   y1 = [yrbase ylbase];
   x = [xrmic xlmic];
   y = [yrmic ylmic];
   x2 = [.785 .785 1-.785 1-.785];
   y2 = [.995 1.2 1.2 .995 ]+.1;
   varargout = {x,y,x1,y1,x2,y2};
   
case 'dynamic'
   ena_orig = get_param(blk,'maskenables');
   ena = ena_orig;
   
   % Update enabling of user-defined rate:
   SampleRatePopup = get_param(blk,'SampleRate');
   if strcmp(SampleRatePopup,'User-defined'),
      ena{2}='on';
   else
      ena{2}='off';
   end
   
   % Enable or disable user device ID edit box:
   useDefault = strcmp(get_param(blk,'useDefaultDevice'),'on');
   if useDefault,
      enaDeviceID = 'off';
   else
      enaDeviceID = 'on';
   end
   ena{8} = enaDeviceID;
   
   if ~isequal(ena,ena_orig),
      set_param(blk,'maskenables',ena);
   end
   
   
otherwise,
   error('Unknown action specified');
end

% [EOF] dspblkwai.m
