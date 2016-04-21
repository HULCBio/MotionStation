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
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:41:38 $

ArgChkMsg = nargchk(0,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqhwinfo:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:daqhwinfo:argcheck', 'Too many output arguments.')
end

% Error if an invalid handle was passed.
if ~all(isvalid(obj))
   error('daq:daqhwinfo:invalidobject', 'Data acquisition object OBJ is an invalid object.');
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
         currentObj = get(obj,i);
         if isa(currentObj, 'digitalio')
            out{i} = daqmex(handles(i), 'daqhwinfo');
            [out{i}.Port, errflag] = localCreatePortStructure(currentObj);
         else
            out{i} = daqhwinfo(currentObj);
         end
         % Clean up the error if one occurred.
         if errflag
            localCheckError;
            error('daq:daqhwinfo:unexpected', lasterr);
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
            % If the Port property is specified, need to construct
            % the portStructure.
            if ~strncmp(lower(prop{j}), 'port', length(prop{j}))
               out{i,j} = daqmex(handles(i), 'daqhwinfo', prop{j});
            else
               out{i,j} = localCreatePortStructure(obj);
            end
         catch
            error('daq:daqhwinfo:unexpected', lasterr);
         end
      end
   end
      
   % If the property was given as a string and obj is 1-by-1, output
   % a string.
   if outputStr && length(handles) == 1
      out = out{:};
   end
end

% **********************************************************************
% Create the Port Structure.
function [portStruct, errflag] = localCreatePortStructure(obj)

% Initialize variables.
errflag = 0;

try
   portIDs = daqmex(obj, 'daqhwinfo', 'PortIDs');
   portMasks = daqmex(obj, 'daqhwinfo', 'PortLineMasks');
   portDir = daqmex(obj, 'daqhwinfo', 'PortDirections');
   config = daqmex(obj, 'daqhwinfo', 'PortLineConfig');
   
   % Create the portStruct.
   for i = 1:length(portIDs)
      portStruct(i).ID = portIDs(i);
      portStruct(i).LineIDs = [];
      portStruct(i).Direction = '';
      portStruct(i).Config = '';
      
      % Determine which lines are supported.
      
      % masks = 0 - Line is not supported.
      % masks = 1 - Line is supported.
      % Ex. masks = 43 = [1 1 0 1 0 1 0 0]
      % Supported lines = [0 1 3 5].
      masks = dec2binvec(portMasks(i));
      zeroIndex = find(masks == 0);
      
      % Convert the 0's and 1's to the line numbers.
      lineMasks = [0:length(masks)-1] .* masks;
      
      % Remove the lines that are not supported.
      lineMasks(zeroIndex) = [];
      
      % Add lineIDs to the portStruct.
      portStruct(i).LineIDs = lineMasks;
      
      % Determine the port direction.
      switch (portDir(i))
      case 0
         portStruct(i).Direction = 'in';
      case 1
         portStruct(i).Direction = 'out';
      case 2
         portStruct(i).Direction = 'in/out';
      end
      
      % Determine if line configurable or port configurable.
      switch (config(i))
      case 0
         portStruct(i).Config = 'port';
      case 1
         portStruct(i).Config = 'line';
      end
   end
catch
   errflag = 1;
   return;
end
   
% **********************************************************************
% Remove any extra carriage returns.
function localCheckError

% Initialize variables.
errmsg = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg);