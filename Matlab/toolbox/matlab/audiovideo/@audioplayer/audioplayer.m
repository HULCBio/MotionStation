function playerStruct = audioplayer(varargin)
%AUDIOPLAYER Audio player object.
%    AUDIOPLAYER(Y, Fs) creates an AUDIOPLAYER object for signal Y, using 
%    sample rate Fs.  A handle to the object is returned.
%    
%    AUDIOPLAYER(Y, Fs, NBITS) creates an AUDIOPLAYER object and uses NBITS 
%    bits per sample for floating point signal Y.  Valid values for NBITS
%    are 8, 16, and 24 on Windows, 8 and 16 on UNIX.  The default number of
%    bits per sample for floating point signals is 16.
% 
%    AUDIOPLAYER(Y, Fs, NBITS, ID) creates an AUDIOPLAYER object using 
%    audio device identifier ID for output.  If ID equals -1 the default 
%    output device will be used.  This option is only available on Windows.
% 
%    AUDIOPLAYER(R) creates an AUDIOPLAYER object from AUDIORECORDER object R.
% 
%    AUDIOPLAYER(R, ID) creates an AUDIOPLAYER object from AUDIORECORDER
%    object R using audio device identifier ID for output.  This option is
%    only available on Windows.
% 
%    Example:  Load snippet of Handel's Hallelujah Chorus and play back 
%              only the first three seconds.
% 
%       load handel;
%       p = audioplayer(y, Fs); 
%       play(p, [1 (get(p, 'SampleRate') * 3)]);
% 
%    See also AUDIORECORDER, AUDIODEVINFO, METHODS, AUDIOPLAYER/GET, 
%             AUDIOPLAYER/SET.

%    Author(s): BJW
%    Copyright 1984-2004 The MathWorks, Inc. 
%    $Revision $  $Date: 2004/04/10 23:23:23 $ 

%% Input parsing

% If we're on UNIX, we need the JVM.  If we're on Windows, our system
% requirements will make sure that we're at least on a 32-bit machine.
if ~ispc && ~usejava('jvm')
      error('MATLAB:audioplayer:needjvmonunix', ...
            audioplayererror('matlab:audioplayer:needjvmonunix'));
end

if (nargin == 0)
    error('MATLAB:audioplayer:wrongnumberinputs', ...
          audioplayererror('matlab:audioplayer:wrongnumberinputs'));
else
    signal = varargin{1};

    fromaudiorecorder = isa(signal, 'audiorecorder');
    if fromaudiorecorder
        recorder = varargin{1};
        numBits = get(recorder, 'BitsPerSample');
        switch numBits
            case 8
                signal = getaudiodata(recorder, 'int8');
            case 16
                signal = getaudiodata(recorder, 'int16');
            case 24
                signal = getaudiodata(recorder, 'double');
        end
        sampleRate = get(recorder, 'SampleRate');
    end
end

if (nargin == 3)
    if ~(isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
            isnumeric(varargin{3}))
        error('MATLAB:audioplayer:numericinputs', ...
          audioplayererror('matlab:audioplayer:numericinputs'));
    end
end
if (nargin == 4)
    if ~(isnumeric(varargin{1}) && isnumeric(varargin{2}) && ...
            isnumeric(varargin{3}) && isnumeric(varargin{4}))
        error('MATLAB:audioplayer:numericinputs', ...
            audioplayererror('matlab:audioplayer:numericinputs'));
    end
end

switch (nargin)
    case 1
        if ~fromaudiorecorder
            error('MATLAB:audioplayer:mustbeaudiorecorder', ...
                audioplayererror('matlab:audioplayer:mustbeaudiorecorder'));
        else
            deviceID = get(recorder,'deviceID');
        end
    case 2
        if ~fromaudiorecorder
            if ~isnumeric(signal)
                error('MATLAB:audioplayer:invalidsignal', ...
                    audioplayererror('matlab:audioplayer:invalidsignal'));
            else
                if ~isnumeric(varargin{2})
                    error('MATLAB:audioplayer:numericinputs', ...
                        audioplayererror('matlab:audioplayer:numericinputs'));
                end
                sampleRate = varargin{2};
            end
        else
            if isnumeric(varargin{2})
                deviceID = varargin{2};
            else
                error('MATLAB:audioplayer:invaliddeviceID', ...
                    audioplayererror('matlab:audioplayer:invaliddeviceID'));
            end
        end
    case 3
        sampleRate = varargin{2};
        numBits = varargin{3};
        deviceID = -1;
    case 4
        sampleRate = varargin{2};
        numBits = varargin{3};
        deviceID = varargin{4};
    otherwise
        error('MATLAB:audioplayer:wrongnumberinputs', ...
          audioplayererror('matlab:audioplayer:wrongnumberinputs'));        
end
        
if sampleRate <= 0,
    error('MATLAB:audioplayer:positivesamplerate', ...
        audioplayererror('matlab:audioplayer:positivesamplerate'));
end

if nargin < 3 & ~fromaudiorecorder,
	numBits = getnumbitsforthissignal(signal);
end

if numBits ~= 8 & numBits ~= 16 & numBits ~= 24,
	error('MATLAB:audioplayer:bitsupport', ...
        audioplayererror('matlab:audioplayer:bitsupport'));
end

if nargin < 4 && ~fromaudiorecorder,
    deviceID = -1;
end

%% Instantiate the correct audioplayer
if ispc,
    winaudioplayer;
   try
       player = audioplayers.winaudioplayer(signal, sampleRate, numBits, ...
           deviceID);
   catch
       err = fixlasterr;
       error(err{:});
   end
else
    if (nargin == 4) || (fromaudiorecorder && (nargin == 2))
        warning('MATLAB:audioplayer:deviceIDWindows', ...
            audioplayererror('matlab:audioplayer:deviceIDWindows'));
    end
    if (numBits == 24)
        numBits = 16;    
        warning('MATLAB:audioplayer:Unix24bit', ...
            audioplayererror('matlab:audioplayer:Unix24bit'));
    end
   
    try
       player = handle(com.mathworks.toolbox.audio.JavaAudioPlayer(signal, ...
           sampleRate, numBits));
    catch
       err = fixlasterr;
       error(err{:});    
    end
end

%% Set the class

% Set the opaque object as a private member of the M-object
playerStruct.internalObj = player;

% Store the signal as a private member for saving/loading
playerStruct.signal = signal;

% Set the class
playerStruct = class(playerStruct, 'audioplayer');

%-------------------------------------------------------------------
function bits = getnumbitsforthissignal(thesignal)
%% Subfunction GETNUMBITSFORTHISSIGNAL

switch class(thesignal)
case 'double',
   bits = 16;
case 'single',
   bits = 16;
case 'int16',
   bits = 16;
case 'int8',
   bits = 8;
case 'uint8',
   bits = 8;
otherwise
   error('MATLAB:audioplayer:unsupportedtype', ...
         audioplayererror('matlab:audioplayer:unsupportedtype'));
end
