% MATLAB Audioplayer Object.
%
% Audioplayer Functions and Properties.
%
% Audioplayer object construction.
%   audioplayer   - Construct audioplayer object.
%
% Getting and setting parameters.
%   get           - Get value of audioplayer object property.
%   set           - Set value of audioplayer object property.
%
% General.
%   clear         - Remove audioplayer object from memory.
%   display       - Display method for audioplayer objects.
%   isequal       - Compares multiple audioplayer objects.
%
% Audioplayer methods.
%   play          - Play audio samples.
%   playblocking  - Play audio samples; returns when playback is complete.
%   stop          - Stop playback in progress.
%   pause         - Pause playback in progress.
%   resume        - Continue playback from paused location.
%   isplaying     - Returns true or false, indicating playback is or is not
%                   in progress
%
% Audioplayer properties.
%
%   Type             - String containing object's class name (read-only)
%   SampleRate       - The current sample rate (samples per second)
%   BitsPerSample    - The number of bits per sample (read-only)
%   NumberOfChannels - The number of channels (read-only)
%   TotalSamples     - The length of the loaded audio signal, in samples
%                      (read-only)
%   Running          - String indicating playback status as 'on' or 'off'
%                      (read-only)
%   CurrentSample    - Current sample being played by audio output device - 
%                      if playback is not in progress, CurrentSample is 
%                      the next sample to be played (read-only)
%   DeviceID         - ID of device to be used for playback.  -1 is default
%                      (read-only)
%   UserData         - User-defined data location
%   Tag              - User-defined string
%   TimerFcn         - A valid MATLAB expression, name of or handle to 
%                      function to be executed repeatedly during playback
%   TimerPeriod      - time, in seconds, between executions of TimerFcn
%   StartFcn         - A valid MATLAB expression, name of or handle to 
%                      function to be executed once, when playback starts
%   StopFcn          - A valid MATLAB expression, name of or handle to 
%                      function to be executed once, when playback stops
%
% See also AUDIORECORDER.

%   JCS
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:06 $
