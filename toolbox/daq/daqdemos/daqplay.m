function varargout = daqplay(varargin)
%DAQPLAY Output data to the specified adaptor.
%
%
%    FS = DAQPLAY(DATA) plays the specified DATA for one iteration
%    at 8000 Hz.  The sampling rate is returned in FS.
%    FS = DAQPLAY('ADAPTORNAME', ID, DATA) creates an analog output
%    object associated with adaptor, ADAPTORNAME, and device identification
%    ID.  DATA is output at the default sample rate of the specified adaptor
%    and is returned to FS.  The columns in DATA represent individual 
%    channels and the rows are the data to be output.
%
%    FS = DAQPLAY('ADAPTORNAME', ID, DATA, SAMPLERATE) outputs DATA at the 
%    specified sample rate, SAMPLERATE.  If the specified sampling rate 
%    does not match one of the valid device values, then the data acquisition
%    engine will choose the closest supported sampling rate that is greater 
%    than the specified value. If a higher value does not exist, then an 
%    error is returned.
%
%    FS = DAQPLAY('ADAPTORNAME', ID, DATA, SAMPLERATE, CHANID) outputs DATA
%    to the specified channels, CHANID.
%
%    FS = DAQPLAY('ADAPTORNAME', ID, DATA, SAMPLERATE, CHANID, TIMES) outputs 
%    for the specified number of iterations, TIMES.
%
%    If ADAPTORNAME and ID are not defined, the winsound adaptor and id 0 
%    are used.
%    
%    If CHANID is not specified then the first n channels of the device are used.
%    Where n is the number of columns in DATA 
%
%    FS = DAQPLAY(DATA, SAMPLERATE) plays the specified DATA at the specified 
%    sampling rate for one iteration.  If the specified sampling
%    rate does not match one of the valid device values, then the data acquisition
%    engine will choose the closest supported sampling rate that is greater 
%    than the specified value. If a higher value does not exist, then an 
%    error is returned.
%
%    FS = DAQPLAY(DATA, SAMPLERATE, CHANID) plays the specified DATA at the specified
%    sampling rate, SAMPLERATE, with the specified channels (either 1  or [1 2]).
%
%    FS = DAQPLAY(DATA, SAMPLERATE, CHANID, TIMES) plays the specified DATA for the 
%    specified number of iterations, TIMES.
%
%    Examples:
%      [data, fs] = daqrecord(5, 8192, 1);
%      daqplay(data, fs)
%      daqplay(data, fs, 1)
%      daqplay(data, fs*2, 1)
%      daqplay(data, fs, 1, 2)
%
%    See also DAQRECORD.
%

%    MP 11-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.5 $  $Date: 2003/08/29 04:45:06 $

% Initialize variables.
data = [];
adaptor = 'winsound';
id = 0;
chanID = [];
repeats = 1;

% Error if an input was not provided.
if nargin == 0
   error('DATA must be defined');
end

% Switch on the number of input arguments based on whether the
% first input is numeric (data) or is a string (adaptor).
if isnumeric(varargin{1})
   switch nargin
   case 1
      data = varargin{1};
   case 2
      [data,sampleRate] = deal(varargin{:});
   case 3
      [data,sampleRate,chanID] = deal(varargin{:});
   case 4
      [data,sampleRate,chanID,repeats] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
elseif ischar(varargin{1})
   switch nargin
   case 1
      error('ID and DATA must be defined.');
   case 2
      error('DATA must be defined');
   case 3
      [adaptor, id, data] = deal(varargin{:});
   case 4
      [adaptor, id, data, sampleRate] = deal(varargin{:});
   case 5
      [adaptor, id, data, sampleRate, chanID] = deal(varargin{:});
   case 6
      [adaptor, id, data, sampleRate, chanID, repeats] = deal(varargin{:});
   otherwise
      error('Too many input arguments.');
   end
else
   error('DATA must be numeric.');
end

% Error checking on the input arguments.
if ~isa(data, 'double')
   error('DATA must be a double.');
elseif ~(isa(id, 'double') || isa(id, 'char'))
   error('ID must be a double or string.');
elseif exist('sampleRate','var') && ~isa(sampleRate, 'double')
   error('SAMPLERATE must be a double.');
elseif ~isa(chanID, 'double');
   error('CHANID must be a double.');
elseif ~isa(repeats, 'double');
   error('TIMES must be a double.');
end

% Initialize chanID to contain the correct number of channels for 
% the data provided.
if isempty(chanID)
   numChans = size(data, 2);
   if strcmp(lower(adaptor), 'nidaq') || strcmp(lower(adaptor), 'mcc')
      chanID = 0:numChans-1;
   else
      chanID = 1:numChans;
   end
else
   if length(chanID) ~= size(data,2)
      error('The number of channels and the columns of DATA must match.');
   end
end

% Create and configure the analog output object.
try
   if exist('sampleRate','var'),
     [ao,Fs,errflag] = daqgate('privateDemoObj','analogoutput',adaptor,...
        id,chanID,sampleRate);
   else
     [ao,Fs,errflag] = daqgate('privateDemoObj','analogoutput',adaptor,...
        id,chanID);
   end

   set(ao, 'RepeatOutput', repeats-1);
   if nargout == 1
      varargout{1} = Fs;
   end
catch
   delete(ao);
   error(lasterr);
end

% Error if the object could not be created.
if errflag
   % if error is too many channels
   if (~isempty(findstr('Unable to set HwChannel above maximum',lasterr) ...
         & size(data,2)> daqhwinfo(ao,'TotalChannels')))
      lasterr('DATA has more columns than the device has channels.');
   end
   delete(ao);
   error(deblank(lasterr));
end
   
% Put the data for output.
try
   putdata(ao, data);
catch
   delete(ao);
   error('The number of channels and the columns of DATA must match.');
end

% Start the object while the object is running do nothing.  
set(ao, 'StopFcn', @localStop);
start(ao);

% *************************************************************
% StopFcn - deletes object.
function localStop(obj, event)

daqmex(obj, 'delete');

