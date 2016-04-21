function recorderStruct = audiorecorder(sampleRate,numBits,numChannels,deviceID)
%AUDIORECORDER Audio recorder object.
%   AUDIORECORDER creates an 8000 Hz, 8-bit, 1 channel AUDIORECORDER object.
%   A handle to the object is returned.
%
%   AUDIORECORDER(Fs, NBITS, NCHANS) creates an AUDIORECORDER object with 
%   sample rate Fs in Hertz, number of bits NBITS, and number of channels NCHANS. 
%   Common sample rates are 8000, 11025, 22050, and 44100 Hz. The number of bits
%   must be 8, 16, or 24 on Windows, 8 or 16 on UNIX.  The number of channels
%   must be 1 or 2 (mono or stereo).
%
%   AUDIORECORDER(Fs, NBITS, NCHANS, ID) creates an AUDIORECORDER object using 
%   audio device identifier ID for input.  If ID equals -1 the default input 
%   device will be used.  This option is only available on Windows.
%
%   Example:  Record your voice on-the-fly.  Use a sample rate of 22050 Hz,
%             16 bits, and one channel.  Speak into the microphone, then 
%             pause the recording.  Play back what you've recorded so far.
%             Record some more, then stop the recording. Finally, return
%             the recorded data to MATLAB as an int16 array.
%
%      r = audiorecorder(22050, 16, 1);
%      record(r);     % speak into microphone...
%      pause(r);
%      p = play(r);   % listen
%      resume(r);     % speak again
%      stop(r);
%      p = play(r);   % listen to complete recording
%      mySpeech = getaudiodata(r, 'int16'); % get data as int16 array
%
%   See also AUDIOPLAYER, AUDIODEVINFO, METHODS, AUDIORECORDER/GET, 
%            AUDIORECORDER/SET. 

%    Author(s): BJW
%    Copyright 1984-2004 The MathWorks, Inc. 
%    $Revision $  $Date: 2004/04/10 23:23:25 $ 

% If we're on UNIX, we need the JVM.  If we're on Windows, our system
% requirements will make sure that we're at least on a 32-bit machine.
if ~ispc && ~usejava('jvm')
      error('MATLAB:audiorecorder:needjvmonunix', ...
            audiorecordererror('matlab:audiorecorder:needjvmonunix'));
end

if nargin ~= 0 && nargin ~= 3 && nargin ~= 4,
	error('MATLAB:audiorecorder:incorrectnumberinputs', ...
            audiorecordererror('matlab:audiorecorder:incorrectnumberinputs'));
end

if nargin == 0,
	%defaults - 8kHz, 8-bit, mono
	sampleRate = 8000;
	numBits = 8;
	numChannels = 1;
	deviceID = -1;
elseif nargin == 3,
    deviceID = -1;
end

if ~ ispc && nargin == 4,
    warning('MATLAB:audiorecorder:deviceIDWindows', ...
            audiorecordererror('matlab:audiorecorder:deviceIDWindows'));
end

if sampleRate <= 0,
	error('MATLAB:audiorecorder:positivesamplerate', ...
            audiorecordererror('matlab:audiorecorder:positivesamplerate'));
end

if numBits ~= 8 && numBits ~= 16 && numBits ~= 24,
	error('MATLAB:audiorecorder:bitsupport', ...
            audiorecordererror('matlab:audiorecorder:bitsupport'));
end

if ~ ispc && numBits == 24,
    numBits = 16;
    warning('MATLAB:audiorecorder:Unix24bit', ...
            audiorecordererror('matlab:audiorecorder:unix24bit'));
end

if numChannels ~= 1 && numChannels ~= 2,
	error('MATLAB:audiorecorder:numchannelsupport', ...
            audiorecordererror('matlab:audiorecorder:numchannelsupport'));
end

if ispc,
    winaudiorecorder;
    try
        recorder = audiorecorders.winaudiorecorder(sampleRate, ...
            numBits, numChannels, deviceID);
    catch
        err = fixlasterr;
        error(err{:});
    end
else
    try
        recorder = ...
            handle(com.mathworks.toolbox.audio.JavaAudioRecorder(sampleRate, ...
            numBits, numChannels));
    catch
        err = fixlasterr;
        error(err{:});
    end
end

%% Set the class

% Set the opaque object as a private member of the M-object
recorderStruct.internalObj = recorder;

% Set the class
recorderStruct = class(recorderStruct, 'audiorecorder');
