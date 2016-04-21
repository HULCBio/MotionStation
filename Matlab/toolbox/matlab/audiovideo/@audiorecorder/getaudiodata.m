function data = getaudiodata(obj, varargin)
%GETAUDIODATA Gets recorded audio data in audiorecorder object.
%
%    GETAUDIODATA(OBJ) returns the recorded audio data as a double array
%
%    GETAUDIODATA(OBJ, DATATYPE) returns the recorded audio data in 
%    the data type as requested in string DATATYPE.  Valid data types
%    are 'double', 'single', 'int16', 'uint8', and 'int8'.
%
%    See also AUDIORECORDER, AUDIODEVINFO, AUDIORECORDER/RECORD.

%    JCS
%    Copyright 2003-2004 The MathWorks, Inc.

% Error checking.
if ~isa(obj, 'audiorecorder')
     error('MATLAB:audiorecorder:noAudiorecorderObj', ...
           audiorecordererror('MATLAB:audiorecorder:noAudiorecorderObj'));
end

error(nargchk(1, 2, nargin), 'struct');

if ispc
   data = getaudiodata(obj.internalObj, varargin{:});
else
   % Code to return uint8 from the Java (UNIX) implementation.
   if nargin == 1
       dataType = 'double';
   else
       dataType = varargin{1};
   end

   bits = get(obj, 'BitsPerSample');
   if bits == 16,
       getDataAs = 'int16';
   else
       getDataAs = 'int8';
   end
   
   floatingPointScaleFactor = 2 ^ (bits - 1);
   
   if strcmp(dataType, 'double'),
       data = GetAudioData(obj.internalObj, getDataAs);
       data = double(data);
       data = data / floatingPointScaleFactor;
   elseif strcmp(dataType, 'single'),
       data = GetAudioData(obj.internalObj, getDataAs);
       data = double(data);
       data = data / floatingPointScaleFactor;
       data = single(data);
   elseif strcmp(dataType, 'int16'),
       data = GetAudioData(obj.internalObj, getDataAs);
       if bits == 8,   % data is int8 now if getDataAs == 'int8'
           data = double(data);
           data = data * 256;
           data = int16(data);
       end
   elseif strcmp(dataType, 'int8'),
       data = GetAudioData(obj.internalObj, getDataAs);
       if bits == 16,  % data is int16 now if getDataAs == 'int16'
           data = double(data);
           data = data / 256;
           data = int8(data);
       end
   elseif strcmp(dataType, 'uint8'),
       % get audiodata as appropriate native type, then scale and change the type
       if get(obj, 'BitsPerSample') == 16,
           data = GetAudioData(obj.internalObj, 'int16');
           data = double(data);
           data = data / 256;
           data = data + 128;
           data = uint8(data);
       else
           data = GetAudioData(obj.internalObj, 'int8');
           data = double(data);
           data = data + 128;
           data = uint8(data);
       end
   else
       error('Unsupported data type');
   end
end
