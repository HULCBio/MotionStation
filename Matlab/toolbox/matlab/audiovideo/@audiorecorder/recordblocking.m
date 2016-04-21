function recordblocking(obj, varargin)
%RECORDBLOCKING Synchronous recording from audio device.
%
%    RECORDBLOCKING(OBJ) begins recording from the audio input device.
%
%    RECORDBLOCKING(OBJ, T) records for length of time, T, in seconds;
%                           does not return until recording is finished.
%
%    Use the RECORD method for asynchronous recording.
%
%    Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
%              16 bits, and one channel.  Speak into the microphone, then 
%              stop the recording.  Play back what you've recorded so far.
% 
%       r = audiorecorder(22050, 16, 1);
%       recordblocking(r);     % speak into microphone...
%       p = play(r);   % listen to complete recording
%
%    See also AUDIORECORDER, METHODS, AUDIORECORDER/PAUSE, 
%             AUDIORECORDER/STOP, AUDIORECORDER/RECORD.
%             AUDIORECORDER/PLAY, AUDIORECORDER/RESUME.

%    JCS
%    Copyright 2003 The MathWorks, Inc.

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin), 'struct');

recordblocking(obj.internalObj, varargin{:});

