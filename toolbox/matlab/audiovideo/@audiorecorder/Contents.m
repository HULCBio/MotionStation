% MATLAB Audiorecorder Object.
%
% Audiorecorder Functions and Properties.
%
% Audiorecorder object construction.
%   audiorecorder - Construct audiorecorder object.
%
% Getting and setting parameters.
%   get           - Get value of audiorecorder object property.
%   set           - Set value of audiorecorder object property.
%
% General.
%   clear         - Remove audiorecorder object from memory.
%   display       - Display method for audiorecorder objects.
%
% Audiorecorder methods.
%   getaudiodata   - Return recorded audio data.
%   getplayer      - Create and return associated audioplayer.
%   isrecording    - Returns true or false, indicating recording
%                    is or is not in progress.
%   pause          - Pause recording in progress.
%   play           - Play recorded audio samples.
%   record         - Record audio samples.
%   recordblocking - Record audio samples; returns when recording is complete.
%   resume         - Continue recording from paused location.
%   stop           - Stop recording in progress.
%
% Audiorecorder properties.
%
%   Type             - String containing object's class name (read-only)
%   SampleRate       - The current sample rate (samples per second)
%   BitsPerSample    - The number of bits per sample (read-only)
%   NumberOfChannels - The number of channels (read-only)
%   TotalSamples     - The length of the current recording, in samples
%                      (read-only)
%   Running          - String indicating recording status as 'on' or 'off'
%                      (read-only)
%   CurrentSample    - Current sample being recorded by audio output
%                      device - if recording is not in progress,
%                      CurrentSample gives the next sample to be recorded
%                      (read-only)
%   DeviceID         - ID of device to be used for playback.  -1 is default
%                      (read-only)
%   UserData         - User-defined data location
%   Tag              - User-defined string
%   TimerFcn         - A valid MATLAB expression, name of or handle to 
%                      function to be executed repeatedly during recording
%   TimerPeriod      - Time, in seconds, between executions of TimerFcn
%   StartFcn         - A valid MATLAB expression, name of or handle to 
%                      function to be executed once, when recording starts
%   StopFcn          - A valid MATLAB expression, name of or handle to 
%                      function to be executed once, when recording stops
%   NumberOfBuffers  - Number of audio input buffers to be used (only
%                      modify if recording imperfections are experienced)
%                      Only modifiable on Windows.
%   BufferLength     - Length, in seconds, of each audio input buffer (only
%                      modify if recording imperfections are experienced)
%                      Only modifiable on Windows. 
%
% See also AUDIOPLAYER.

%   JCS
%   Copyright 2003 The MathWorks, Inc.
%   $Revision $  $Date: 2003/12/04 19:00:24 $
