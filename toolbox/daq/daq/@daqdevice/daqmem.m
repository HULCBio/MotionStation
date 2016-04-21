function varargout = daqmem(obj, value)
%DAQMEM Allocate or display memory for one or more device objects.
%
%    OUT = DAQMEM returns a structure, OUT, containing the fields:
%    MemoryLoad, TotalPhys, AvailPhys, TotalPageFile, AvailPageFile,
%    TotalVirtual, AvailVirtual and UsedDaq.  All the fields except
%    UsedDaq are identical to the fields returned by Windows'
%    MemoryStatus function.  UsedDaq returns the total memory used by
%    all data acquisition device objects.
%
%    OUT = DAQMEM(OBJ) returns a 1-by-N structure, OUT, containing two
%    fields: UsedBytes and MaxBytes for the specified device object,
%    OBJ where N is the length of OBJ.  The UsedBytes field returns
%    the amount of memory in bytes used by the specified device object.
%    The MaxBytes field returns the maximum memory in bytes that can be 
%    used by the specified device objects.
%
%    DAQMEM(OBJ, VALUE) sets the maximum memory that can be allocated  
%    for the specified device object, OBJ, to VALUE.  OBJ can be either  
%    a single device object or an array of device objects.  If an array 
%    of device objects is specified, VALUE can be either a single value 
%    which would apply to all device objects specified in OBJ or VALUE
%    can be a vector of values (the same length as OBJ) where each 
%    vector element corresponds to a different device object in OBJ.
%
%    Example:
%      ai1 = analoginput('winsound');
%      ai2 = analoginput('nidaq', 1);
%      out = daqmem;
%      out = daqmem(ai1);
%      daqmem([ai1 ai2], 320000);
%      daqmem([ai1 ai2], [640000 480000]);
%
%    See also DAQHELP.
%

%    MP 11-17-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:41:07 $

% The first input must be a daqdevice object otherwise error.
if ~isempty(obj) && ~isa(obj, 'daqdevice')
   error('daq:daqmem:argcheck', 'Invalid input argument.  Type ''daqhelp daqmem'' for additional information.');
end

% Call daqmex appropriately depending on the input arguments.
switch nargin
case 1
   % Ex. daqmex([ai1 ai2]);
   
   % Loop through each object and get the structure values.
   for i = 1:length(obj)
      % Get the BytesUsed and the BytesAvailable property values.
      handles = daqgetfield(obj, 'handle');
      try
         varargout{1}(i) = daqmex(handles(i), 'daqmem');
      catch
         error('daq:daqmem:unexpected', lasterr)
      end
   end
case 2
   % Ex. daqmex([ai1 ai2], 64000); 
   % Ex. daqmex([ai1 ai2], [64000 32000]);
      
   % VALUE must be a double.
   if isempty(value) || ~isa(value, 'double')
      error('daq:daqmem:argcheck', 'Invalid input argument.  VALUE must be a double.');
   end
   
   % The length of VALUE must be either 1 or the length of OBJ.
   if length(value) ~= 1 && length(value) ~= length(obj)
      error('daq:daqmem:invalidvalue', 'VALUE must have the same length as OBJ or have a length of one.');
   end
   
   % Loop through each object and set the maximum memory that
   % can be allocated for the object.
   handles = daqgetfield(obj, 'handle');
   index = 1;
   for i = 1:length(obj)
      try
         daqmex(handles(i), 'daqmem', value(index));
      catch
         error('daq:daqmem:unexpected', lasterr)
      end
      
      % Increment the index if VALUE is the same length as OBJ.
      if length(value) > 1
         index = index+1;
      end
   end
end