function ret = audiodevinfo(varargin)
%AUDIODEVINFO Audio device information.
%   DEVINFO = AUDIODEVINFO returns a structure DEVINFO containing two fields, 
%   input and output.  Each of these fields is an array of structures, each 
%   structure containing information about one of the audio input or output 
%   devices on the system.  The individual device structure fields are Name 
%   (name of the device, string), DriverVersion (version of the installed 
%   device driver, string), and ID (the device's ID).
%
%   AUDIODEVINFO(IO) returns the number of input or output audio devices on 
%   the system.  Set IO = 1 for input, IO = 0 for output.
%
%   AUDIODEVINFO(IO, ID) returns the name of the input or output audio device 
%   with the given device ID.
%
%   AUDIODEVINFO(IO, NAME) returns the device ID of the input or output audio 
%   device with the given name (partial matching, case sensitive).  If no 
%   audio device is found with the given name, -1 is returned.
%
%   AUDIODEVINFO(IO, ID, 'DriverVersion') returns the driver version string of 
%   the specified audio input or output device.
%
%   AUDIODEVINFO(IO, RATE, BITS, CHANS) returns the device ID of the first 
%   input or output device that supports the sample rate, number of bits, 
%   and number of channels specified in RATE, BITS, and CHANS, respectively.
%   If no supportive device is found, -1 is returned.
%
%   AUDIODEVINFO(IO, ID, RATE, BITS, CHANS) returns 1 or 0 for whether or not 
%   the input or output audio device specified in ID can support the given 
%   sample rate, number of bits, and number of channels.
%
%   This function is only for use with 32-bit Windows machines.
%
%   See also AUDIOPLAYER, AUDIORECORDER. 

%    Author(s): Brian Wherry 
%    Copyright 1984-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:38 $ 

if ~strcmp(computer,'PCWIN'),
   error('AUDIODEVINFO is only for use with 32-bit Windows machines.');
end

error(nargchk(0,5,nargin));

if nargin ~= 0,
% specific request
    ret = audiodevicechooser(varargin{:});
else
% give back all information about devices
    numInputDevices = audiodevicechooser(1);
    numOutputDevices = audiodevicechooser(0);
    
    inputDevices = [];
    outputDevices = [];
    
    for i=1:numInputDevices,
        inputDevices(i).Name = audiodevicechooser(1, i - 1);
        inputDevices(i).DriverVersion = audiodevicechooser(1, i - 1, 'DriverVersion');
        inputDevices(i).ID = i - 1;
    end
    
    for i=1:numOutputDevices,
        outputDevices(i).Name = audiodevicechooser(0, i - 1);
        outputDevices(i).DriverVersion = audiodevicechooser(0, i - 1, 'DriverVersion');
        outputDevices(i).ID = i - 1;
    end
    
    audiodevices.input = inputDevices;
    audiodevices.output = outputDevices;
    
    ret = audiodevices;
end

% [EOF] audiodevs.m