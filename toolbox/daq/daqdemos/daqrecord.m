function [data, Fs] = daqrecord(varargin)
%DAQRECORD Record data from the specified adaptor.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS) creates an analog input
%    object associated with adaptor, ADAPTORNAME, and device identification
%    ID.  Data is recorded from channel 1 for the specified number of seconds, 
%    SECONDS, and returned to Y.  The sample rate used is returned to FS.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS, SAMPLERATE) records data 
%    for the specified number of seconds, SECONDS, at the specified sample
%    rate, SAMPLERATE.  If the specified sampling rate does not match one of 
%    the valid device values, then the data acquisition engine will choose 
%    the closest supported sampling rate that is greater than the specified
%    value. If a higher value does not exist, then an error is returned.
%
%    [Y, FS] = DAQRECORD('ADAPTORNAME', ID, SECONDS, SAMPLERATE, CHANID) records 
%    the data from the specified channels, CHANID.
%
%    DAQRECORD('ADAPTORNAME', ID, SECONDS, SAMPLERATE, CHANID, 'FILENAME') saves
%    Y and FS to the MAT-file, 'FILENAME'.  When the 'FILENAME' is specified, 
%    DAQRECORD is a non-blocking function.
%
%    If ADAPTORNAME and ID are not defined, the winsound adaptor and id 0 are
%    used.
%
%    [Y, FS] = DAQRECORD(SECONDS) records a monophonic sound for SECONDS
%    number of seconds at 8000 Hz.  
%
%    [Y, FS] = DAQRECORD(SECONDS, SAMPLERATE) records a sound at the specified
%    sampling rate. If the specified sampling rate does not match one of 
%    the valid device values, then the data acquisition engine will choose 
%    the closest supported sampling rate that is greater than the specified
%    value. If a higher value does not exist, then an error is returned.
%
%    [Y, FS] = DAQRECORD(SECONDS, SAMPLERATE, CHANID) records a sound at the 
%    specified sampling rate and with the specified channel ids, CHANID,
%   (either 1 or [1 2]);
%
%    DAQRECORD(SECONDS, SAMPLERATE, CHANID, 'FILENAME') saves Y and FS to 
%    the MAT-file, 'FILENAME'.  When the 'FILENAME' is specified, DAQRECORD
%    is a non-blocking function.
%
%    Examples:
%       [y, Fs] = daqrecord('nidaq', 1, 10);
%       [y, Fs] = daqrecord(5, 22050);
%       [y, Fs] = daqrecord('winsound', 0, 5, 44100, [1 2]);
%       daqrecord(30, 8000, 'myfile');
%
%    See also DAQPLAY.
%

%    MP 11-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:07 $

% Initialize variables.
adaptor = 'winsound';
id = 0;
chanID = [];
sampleRate = 8000;
filename = '';

% Error if an input was not provided.
if nargin == 0
   error('SECONDS must be defined');
end

% Switch on the number of input arguments based on whether the
% first input is numeric (seconds) or is a string (adaptor).
if isnumeric(varargin{1})
   switch nargin
   case 1
      seconds = varargin{1};
   case 2
      [seconds,sampleRate] = deal(varargin{:});
      if ischar(sampleRate)
         filename = sampleRate;
         sampleRate = 8000;
      end
   case 3
      [seconds,sampleRate,chanID] = deal(varargin{:});
      if ischar(chanID)
         filename = chanID;
         chanID = [];
      end
   case 4
      [seconds,sampleRate,chanID,filename] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
elseif ischar(varargin{1})
   switch nargin
   case 1
      error('ID and SECONDS must be defined.');
   case 2
      error('SECONDS must be defined');
   case 3
      [adaptor, id, seconds] = deal(varargin{:});
   case 4
      [adaptor, id, seconds, sampleRate] = deal(varargin{:});
      if ischar(sampleRate)
         filename = sampleRate;
         sampleRate = 8000;
      end
   case 5
      [adaptor, id, seconds, sampleRate,chanID] = deal(varargin{:});
      if ischar(chanID)
         filename = chanID;
         chanID = [];
      end
   case 6
      [adaptor, id, seconds, sampleRate,chanID,filename] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
elseif isa(varargin{1}, 'daqdevice')
   % Stop Fcn.
   [obj, sampleRate, filename] = deal(varargin{:});
   localStop(obj, filename, sampleRate);
   return;
else
   error('SECONDS must be numeric.');
end

% Error checking on the input arguments.
if ~isa(seconds, 'double')
   error('SECONDS must be a double.');
elseif ~(isa(id, 'double') || isa(id, 'char'))
   error('ID must be a double or string.');
elseif ~isa(sampleRate, 'double')
   error('SAMPLERATE must be a double.');
elseif ~isa(chanID, 'double');
   error('CHANID must be a double.');
elseif ~ischar(filename)
   error('FILENAME must be a string.');
end

% Create and configure the analog input object.
try
   [ai,Fs,errflag] = daqgate('privateDemoObj','analoginput',adaptor,...
      id,chanID,sampleRate);
   % Error if the object could not be created.
   if errflag
      localCheckError;
      error(lasterr);
   end
   set(ai, 'SamplesPerTrigger', Fs*seconds);

catch
   delete(ai);
   error(lasterr);
end

if isempty(filename)
   % While the object is running do nothing.  
   start(ai);
   waittilstop(ai,seconds+2)
   
   % Get the data.
   data = getdata(ai, Fs*seconds);
   delete(ai);
else
   set(ai, 'StopFcn', {'daqrecord', Fs, filename});
   start(ai);
end
   
% ***************************************************************************
% Get the data, save to a file and stop the device.
function localStop(obj,filename,Fs)

y = getdata(obj);

save(filename, 'y', 'Fs');

daqmex(obj, 'delete');

% *************************************************************************
% Remove any extra carriage returns.
function localCheckError

% Initialize variables.
errmsg = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg);