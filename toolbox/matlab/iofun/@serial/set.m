function outputStruct = set(obj, varargin)
%SET Configure or display serial port object properties.
%
%   SET(OBJ,'PropertyName',PropertyValue) sets the value, PropertyValue,
%   of the specified property, PropertyName, for serial port object OBJ.
%
%   OBJ can be a vector of serial port objects, in which case SET sets 
%   the property values for all the serial port objects specified.
%
%   SET(OBJ,S) where S is a structure whose field names are object property 
%   names, sets the properties named in each field name with the values 
%   contained in the structure.
%
%   SET(OBJ,PN,PV) sets the properties specified in the cell array of
%   strings, PN, to the corresponding values in the cell array PV for all
%   objects specified in OBJ. The cell array PN must be a vector, but the 
%   cell array PV can be M-by-N where M is equal to length(OBJ) and N is
%   equal to length(PN) so that each object will be updated with a different
%   set of values for the list of property names contained in PN.
%
%   SET(OBJ,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%   sets multiple property values with a single statement. Note that it
%   is permissible to use param-value string pairs, structures, and
%   param-value cell array pairs in the same call to SET.
%
%   SET(OBJ, 'PropertyName') 
%   PROP = SET(OBJ,'PropertyName') displays or returns the possible values
%   for the specified property, PropertyName, of serial port object OBJ. 
%   The returned array, PROP, is a cell array of possible value strings  
%   or an empty cell array if the property does not have a finite set of
%   possible string values.
%   
%   SET(OBJ) 
%   PROP = SET(OBJ) displays or returns all property names and their
%   possible values for serial port object OBJ. The return value, PROP, is
%   a structure whose field names are the property names of OBJ, and whose 
%   values are cell arrays of possible property values or empty cell arrays.
%
%   Example:
%       s = serial('COM1');
%       set(s, 'BaudRate', 9600, 'Parity', 'even');
%       set(s, {'StopBits', 'RecordName'}, {2, 'sydney.txt'});
%       set(s, 'Name', 'MySerialObject');
%       set(s, 'Parity')
%
%   See also SERIAL/GET.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.6 $  $Date: 2004/01/16 20:04:42 $

% Call builtin set if OBJ isn't an instrument object.
% Ex. set(s, 'UserData', s);
if ~isa(obj, 'instrument')
    try
	    builtin('set', obj, varargin{:});
    catch
        rethrow(lasterror);
    end
    return;
end

% Error if invalid.
if ~all(isvalid(obj))
   error('MATLAB:serial:set:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

if (nargout == 0)
   % Ex. set(obj)
   if nargin == 1
      if (length(obj) == 1)
         localCreateSetDisplay(obj);
         return;
      else
         error('MATLAB:serial:set:nolhswithvector', 'Vector of handles not permitted for set(OBJ).');
      end
   else
      % Ex. set(obj, 'BaudRate');
      % Ex. set(obj, 'BaudRate', 4800);
      try
         % Call the java set method.
         if (nargin == 2)
            if ischar(varargin{1}) 
                % Ex. set(obj, 'RecordMode')
				disp(char(createPropSetDisplay(java(igetfield(obj, 'jobject')), varargin(1))));
            else
                % Ex. set(obj, struct);
                tempObj = igetfield(obj, 'jobject');
            	set(tempObj, varargin{:});
            end
         else
            % Ex. set(obj, 'BaudRate', 4800); 
            tempObj = igetfield(obj, 'jobject');
            set(tempObj, varargin{:});
         end
      catch
         localFixError;
         rethrow(lasterror);
      end	
   end
else
   % Ex. out = set(obj);
   % Ex. out = set(obj, 'BaudRate');
   try
      % Call the java set method.
	  switch nargin 
	  case 1
          % Ex. out = set(obj);
          if (length(obj) > 1)
              error('MATLAB:serial:set:scalarHandle', 'Only one object may be passed to SET for information about possible property values.');
          end
       	  outputStruct = set(igetfield(obj, 'jobject'), varargin{:});
      case 2
		  % Ex. out = set(obj, 'BaudRate')
		  if ~ischar(varargin{1})
			  % Ex. out = set(obj, {'BaudRate', 'Parity'});
			  error('MATLAB:serial:set:invalidPVPair', 'Invalid parameter/value pair arguments.');
		  end
		  outputStruct = cell(createPropSetArray(java(igetfield(obj, 'jobject')), varargin{1}));
	  case 3
		  % Ex. out = set(obj, 'BaudRate', 9600)
          set(igetfield(obj, 'jobject'), varargin{:});
      end
   catch
      localFixError;
      rethrow(lasterror);
   end	
end	

% **********************************************************************
% Create the display for SET(OBJ)
function localCreateSetDisplay(obj)

fprintf(char(setDisplay(igetfield(obj, 'jobject'))));

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
elseif localfindstr('Gpib', out)
   index = localfindstr('Gpib', out);
   blanks = findstr(out, ' ');
   endloc = find(blanks > index);
   endloc = blanks(endloc(1));
   out = localstrrep(out, out(index:endloc), 'GPIB objects ');
   out = localstrrep(out, 'in the ''GPIB objects class', 'for GPIB objects');
elseif localfindstr('TCPIP', out)
   out = localstrrep(out, 'TCPIP', 'TCPIP objects');
   out = localstrrep(out, 'in the ''TCPIP objects'' class', 'for TCPIP objects');
elseif localfindstr('UDP', out)
   out = localstrrep(out, 'UDP', 'UDP objects');
   out = localstrrep(out, 'in the ''UDP objects'' class', 'for UDP objects');
end

% Remove the trailing carriage returns from errmsg.
while out(end) == sprintf('\n')
   out = out(1:end-1);
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
