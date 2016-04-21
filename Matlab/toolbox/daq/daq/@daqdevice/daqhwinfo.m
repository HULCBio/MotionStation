function out = daqhwinfo(obj, prop)
%DAQHWINFO Return information on the available hardware.
%
%    OUT = DAQHWINFO returns a structure, OUT, which contains data acquisition
%    hardware information.  This information includes the toolbox version,
%    MATLAB version and installed adaptors.
%
%    OUT = DAQHWINFO('ADAPTOR') returns a structure, OUT, which contains 
%    information related to the specified adaptor, ADAPTOR.
%
%    OUT = DAQHWINFO('ADAPTOR','Property') returns the adaptor information for
%    the specified property, Property. Property must be a single string. OUT is
%    a cell array.
%
%    OUT = DAQHWINFO(OBJ) where OBJ is any data acquisition device object, 
%    returns a structure, OUT, containing hardware information such as adaptor, 
%    board information and subsystem type along with details on the hardware
%    configuration limits and number of channels/lines.  If OBJ is an array 
%    of device objects then OUT is a 1-by-N cell array of structures where 
%    N is the length of OBJ.   
%
%    OUT = DAQHWINFO(OBJ, 'Property') returns the hardware information for the 
%    specified property, Property.  Property can be a single string or a cell
%    array of strings.  OUT is a M-by-N cell array where M is the length of OBJ 
%    and N is the length of 'Property'.
%
%    Example:
%      out = daqhwinfo
%      out = daqhwinfo('winsound')
%      ai  = analoginput('winsound');
%      out = daqhwinfo(ai)
%      out = daqhwinfo(ai, 'SingleEndedIDs')
%      out = daqhwinfo(ai, {'SingleEndedIDs', 'TotalChannels'})
%
%    See also DAQHELP.
%


%    MP 4-16-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.14.2.4 $  $Date: 2003/08/29 04:41:06 $

ArgChkMsg = nargchk(1,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqhwinfo:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:daqhwinfo:argcheck', 'Too many output arguments.')
end

% Error if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:daqhwinfo:argcheck', 'Data acquisition object OBJ is an invalid object.');
end

% Initialize variables.
outputStr = 0;
handles = daqgetfield(obj, 'handle');


% Return either all the properties or just the specified property.
switch nargin 
case 1   % Obtain the hw info.
   try
      % Loop through the array.
      for i = 1:length(handles)
         if isa(get(obj, i), 'digitalio')
            out{i} = daqhwinfo(get(obj,i));
         else
            out{i} = daqmex(handles(i), 'daqhwinfo');
         end
      end
      
      % Return a non-cell if obj is 1-by-1.
      if length(handles) == 1
         out = out{:};
      end
   catch
      error('daq:daqhwinfo:unexpected', lasterr);
   end
case 2   % Find the properties specified.
   % If the property specified is a string make it a cell.
   if ischar(prop)
      outputStr = 1;
      prop = {prop};
   end
   
   % Error on wrong data type.
   if ~iscellstr(prop)
      error('daq:daqhwinfo:invalidproperty', 'Property must either be a string or a cell array of strings.');
   end
   
   % Initialize output.
   out = cell(length(handles), length(prop));
   
   % Get the property values.
   for i = 1:length(handles)
      for j = 1:length(prop)
         try
            out{i,j} = daqmex(handles(i), 'daqhwinfo', prop{j});
         catch
            error('daq:daqhwinfo:unexpected', lasterr)
         end
      end
   end
      
   % If the property was given as a string and obj is 1-by-1, output a string.
   if outputStr && length(handles) == 1
      out = out{:};
   end
end

   
   
   

