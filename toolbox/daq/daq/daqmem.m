function out = daqmem(varargin)
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
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:40:48 $

% Parse the input.
switch nargin
case 0
   % Return structure with system memory information and total
   % memory used by daq.
   try
      out = daqmex('daqmem');
   catch
      error('daq:daqmem:unexpected', lasterr);
   end
otherwise
   error('daq:daqmem:argcheck', 'Invalid input argument.  Type ''daqhelp daqmem'' for additional information.');
end


