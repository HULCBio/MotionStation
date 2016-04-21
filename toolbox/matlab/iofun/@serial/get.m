function output = get(obj, varargin)
%GET Get serial port object properties.
%
%   V = GET(OBJ,'Property') returns the value, V, of the specified 
%   property, Property, for serial port object OBJ. 
%
%   If Property is replaced by a 1-by-N or N-by-1 cell array of strings 
%   containing property names, then GET will return a 1-by-N cell array
%   of values. If OBJ is a vector of serial port objects, then V will be 
%   a M-by-N cell array of property values where M is equal to the length
%   of OBJ and N is equal to the number of properties specified.
%
%   GET(OBJ) displays all property names and their current values for
%   serial port object OBJ.
%
%   V = GET(OBJ) returns a structure, V, where each field name is the
%   name of a property of OBJ and each field contains the value of that 
%   property.
%
%   Example:
%       s = serial('COM1');
%       get(s, {'BaudRate','DataBits'})
%       out = get(s, 'Parity')
%       get(s)
%
%   See also SERIAL/SET.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.5 $  $Date: 2004/01/16 20:04:20 $

% Call builtin get if OBJ isn't an instrument object.
% Ex. get(s, s);
if ~isa(obj, 'instrument')
    try
	    builtin('get', obj, varargin{:});
    catch
        rethrow(lasterror);
    end
    return;
end

% Error if invalid.
if ~all(isvalid(obj))
   error('MATLAB:serial:get:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

if  ((nargout == 0) && (nargin == 1))
   % Ex. get(obj)
   if (length(obj) > 1)
      error('MATLAB:serial:get:nolhswithvector', 'Vector of handles not permitted for get(OBJ) with no left hand side.')
   else
      localCreateGetDisplay(obj);
      return;
   end
elseif ((nargout == 1) && (nargin == 1))
   % Ex. out = get(obj);
   try
      % Call the java get method.
      output = get(igetfield(obj, 'jobject'));
  catch
      rethrow(lasterror);
   end
else
   % Ex. get(obj, 'BaudRate')
   try
      % Capture the output - call the java get method.
      output = get(igetfield(obj, 'jobject'), varargin{:});
  catch
      localFixError;
      rethrow(lasterror)
   end	
end

% ***************************************************************
% Create the GET display.
function localCreateGetDisplay(obj)

% Get the java object.
jobject = igetfield(obj, 'jobject');

% Get an array indicating if the properties are interface specific.
interfaceSpecific = isInterfaceSpecific(java(jobject));

% Get the property names (names).
names = cell(getPropertyNames(java(jobject)));
vals = get(obj, names);

% Store interface specific properties in DEVICEPROPS.
deviceprops = {};

% Loop through each property and determine the display (dependent
% upon the class of val).
for i = 1:length(names)
   val = vals{i};
   if isnumeric(val)
      [m,n] = size(val);
      if isempty(val)
         % Print the property name only.
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = []\n', names{i})};
         else
            fprintf('    %s = []\n', names{i})
         end         
      elseif (m*n == 1)
         % SamplesPerTrigger = 1024
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %g\n', names{i}, val)};
         else
            fprintf('    %s = %g\n', names{i}, val);
         end
      elseif ((m == 1) || (n == 1)) && (m*n <= 10)
         % The property value is a vector with a max of 10 values.
         % UserData = [1 2 3 4]
         numd = repmat('%g ',1,length(val));
         numd = numd(1:end-1);
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf(['    %s = [' numd ']\n'], names{i}, val)};
         else
            fprintf(['    %s = [' numd ']\n'], names{i}, val);
         end
      else
         % The property value is a matrix or a vector with more than 10 values.
         % UserData = [10x10 double]
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
         else
            fprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
         end
      end
   elseif ischar(val)
      % The property value is a string.
      % RecordMode = Append
      if isjava(val)
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [1x1 struct]\n', names{i})};
         else
            fprintf('    %s = [1x1 struct]\n', names{i});
         end
      else
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %s\n', names{i}, val)};
         else
            fprintf('    %s = %s\n', names{i}, val);
         end
      end
   else
      % The property value is an object, etc object.
      % UserData = [2x1 serial] 
      [m,n]=size(val);
      if interfaceSpecific(i)
         deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
      else
         fprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
      end
   end
end

% Create a blank line after the property value listing.
fprintf('\n');

% Interface specific properties are displayed if they exist.
if ~isempty(deviceprops)
   
   % Create interface specific heading.
   fprintf(['    ' upper(get(obj, 'Type')) ' specific properties:\n']);
   
   % Display interface specific properties.
   for i=1:length(deviceprops),
      fprintf(deviceprops{i})
   end
   
   % Create a blank line after the interface specific property value listing.
   fprintf('\n');
end

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
[out, id] = lasterr;

if localfindstr('com.mathworks.toolbox.instrument.', out)
    out = strrep(out, sprintf('com.mathworks.toolbox.instrument.'), '');
end

if localfindstr('javahandle.', out)
	out = strrep(out, sprintf('javahandle.'), '');
end

if localfindstr('SerialComm', out)
   out = localstrrep(out, 'SerialComm', 'serial port objects');
   out = localstrrep(out, 'in the ''serial port objects'' class', 'for serial port objects');
elseif localfindstr('SerialVisa', out)
   out = localstrrep(out, 'SerialVisa', 'VISA-serial objects');
   out = localstrrep(out, 'in the ''VISA-serial objects'' class', 'for VISA-serial objects');
elseif localfindstr('GpibDll', out)
   out = localstrrep(out, 'GpibDll', 'GPIB objects');
   out = localstrrep(out, 'in the ''GPIB objects'' class', 'for GPIB objects');
elseif localfindstr('VxiGpibVisa', out)
    out = localstrrep(out, 'VxiGpibVisa', 'VISA-GPIB-VXI objects');
    out = localstrrep(out, 'in the ''VISA-GPIB-VXI objects'' class', 'for VISA-GPIB-VXI objects');
elseif localfindstr('GpibVisa', out)
   out = localstrrep(out, 'GpibVisa', 'VISA-GPIB objects');
   out = localstrrep(out, 'in the ''VISA-GPIB objects'' class', 'for VISA-GPIB objects');
elseif localfindstr('VxiVisa', out)
   out = localstrrep(out, 'VxiVisa', 'VISA-VXI objects');
   out = localstrrep(out, 'in the ''VISA-VXI objects'' class', 'for VISA-VXI objects');
elseif localfindstr('TcpipVisa', out)
   out = localstrrep(out, 'TcpipVisa', 'VISA-TCPIP objects');
   out = localstrrep(out, 'in the ''VISA-TCPIP objects'' class', 'for VISA-TCPIP objects');
elseif localfindstr('UsbVisa', out)
   out = localstrrep(out, 'UsbVisa', 'VISA-USB objects');
   out = localstrrep(out, 'in the ''VISA-USB objects'' class', 'for VISA-USB objects');
elseif localfindstr('RsibVisa', out)
   out = localstrrep(out, 'RsibVisa', 'VISA-RSIB objects');
   out = localstrrep(out, 'in the ''VISA-RSIB objects'' class', 'for VISA-RSIB objects');
elseif localfindstr('TCPIP', out)
   out = localstrrep(out, 'TCPIP', 'TCPIP objects');
   out = localstrrep(out, 'in the ''TCPIP objects'' class', 'for TCPIP objects');
elseif localfindstr('UDP', out)
   out = localstrrep(out, 'UDP', 'UDP objects');
   out = localstrrep(out, 'in the ''UDP objects'' class', 'for UDP objects');
elseif localfindstr('Gpib', out)
   index = localfindstr('Gpib', out);
   blanks = findstr(out, ' ');
   endloc = find(blanks > index);
   endloc = blanks(endloc(1));
   out = localstrrep(out, out(index:endloc), 'GPIB objects ');
   out = localstrrep(out, 'in the ''GPIB objects class', 'for GPIB objects');
end

% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
end

if isempty(id)
    id = 'MATLAB:serial:get:opfailed';
end

lasterr(out, id);

% *******************************************************************
% findstr which handles possible japanese translation.
function result = localfindstr(str1, out)

result = findstr(sprintf(str1), out);

% *******************************************************************
% strrep which handles possible japanese translation.
function out = localstrrep(out, str1, str2)

out = strrep(out, sprintf(str1), sprintf(str2));
