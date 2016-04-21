function record(obj, varargin)
%RECORD Record from audio device.
%
%    RECORD(OBJ) begins recording from the audio input device.
%
%    RECORD(OBJ, T) records for length of time, T, in seconds.
%
%    Use the RECORDBLOCKING method for synchronous recording.
%
%    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
%              16 bits, and one channel.  Speak into the microphone, then 
%              stop the recording.  Play back what you've recorded so far.
% 
%       r = audiorecorder(22050, 16, 1);
%       record(r);     % speak into microphone...
%       stop(r);
%       p = play(r);   % listen to complete recording
%
%    See also AUDIORECORDER, METHODS, AUDIORECORDER/PAUSE, 
%             AUDIORECORDER/STOP, AUDIORECORDER/RECORDBLOCKING.
%             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.

%    JCS
%    Copyright 2003 The MathWorks, Inc.

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin), 'struct');

record(obj.internalObj, varargin{:});

