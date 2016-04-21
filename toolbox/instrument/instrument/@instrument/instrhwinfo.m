function out = instrhwinfo(obj, prop)
%INSTRHWINFO Return information on available hardware.
%
%   OUT = INSTRHWINFO returns a structure, OUT, which contains instrument
%   control hardware information. This information includes the toolbox
%   version, MATLAB version, supported interfaces and supported driver 
%   types.
%
%   OUT = INSTRHWINFO('INTERFACE') returns a structure, OUT, which 
%   contains information related to the specified interface, INTERFACE.
%   INTERFACE can be 'gpib', 'visa', 'serial', 'tcpip' or 'udp'. For the
%   GPIB and VISA interfaces, this information includes installed adaptors.
%   For the serial port interface, this information includes available
%   hardware. For the TCPIP and UDP interfaces, this information includes
%   the local host address.
%
%   OUT = INSTRHWINFO('DRIVERTYPE') returns a structure, OUT, which contains
%   information related to the specified driver type, DRIVERTYPE.
%   DRIVERTYPE can be 'matlab', 'vxipnp', or 'ivi'. If DRIVERTYPE is
%   MATLAB, this information includes the MATLAB instrument drivers found
%   on the MATLAB path. If DRIVERTYPE is vxipnp, this information includes
%   the found VXIplug&play drivers. IF DRIVERTYPE is ivi, this information
%   includes the avialable logical names and information on the IVI
%   configuration store.
%
%   OUT = INSTRHWINFO('INTERFACE', 'ADAPTOR') returns a structure, OUT,
%   which contains information related to the specified adaptor, ADAPTOR,
%   for the specified INTERFACE. This information includes adaptor version
%   and available hardware. INTERFACE can be set to either 'gpib' or 'visa'.  
%   Supported adaptors include:
% 
%             Interface:      Adaptor:
%             ==========      ======== 
%             gpib            agilent, cec, contec, ics, iotech, keithley, 
%                             mcc, ni
%             visa            agilent, ni, tek
%
%   OUT = INSTRHWINFO('DRIVERTYPE', 'DRIVERNAME') returns a structure, OUT,
%   which contains information related to the specified driver, DRIVERNAME
%   for the specified DRIVERTYPE. DRIVERTYPE can be set to 'matlab',
%   'vxipnp' or 'ivi'. The available DRIVERNAME values are returned by
%   INSTRHWINFO('DRIVERTYPE').
%
%   OUT = INSTRHWINFO('INTERFACE', 'ADAPTOR', 'TYPE') returns a structure,
%   OUT, which contains information on the specified type, TYPE. INTERFACE
%   can only be 'visa'. ADAPTOR can be 'agilent', 'ni' or 'tek'. TYPE can be 
%   'gpib', 'vxi', 'gpib-vxi', 'serial', 'tcpip', 'usb' or 'rsib'.
%    	
%   OUT = INSTRHWINFO(OBJ) where OBJ is any instrument object or a device 
%   group object, returns  a structure, OUT, containing information on OBJ. 
%   For GPIB and VISA objects, OUT contains adaptor and vendor supplied DLL 
%   information. For serial port, tcpip and udp objects, OUT contains JAR
%   file information. For device objects and device group objects, OUT 
%   contains driver and instrument information. If OBJ is an array of 
%   objects then OUT is a 1-by-N cell array of structures where N is the
%   length of OBJ.   
%
%   OUT = INSTRHWINFO(OBJ, 'FieldName') returns the hardware information 
%   for the specified fieldname, FieldName, to OUT. FieldName can be any of 
%   the fieldnames defined in the INSTRHWINFO(OBJ) structure. FieldName can 
%   be a single string or a cell array of strings. OUT is a M-by-N cell array
%   where M is the length of OBJ and N is the length of FieldName.
%
%   Example:
%       out1 = instrhwinfo
%       out2 = instrhwinfo('serial');
%       out3 = instrhwinfo('gpib', 'ni');
%       out4 = instrhwinfo('visa', 'ni');
%       out5 = instrhwinfo('visa', 'ni', 'gpib');
%       obj = visa('ni', 'ASRL1::INSTR');
%       out6 = instrhwinfo(obj);
%       out7 = instrhwinfo(obj, 'AdaptorName');
%
%   See also INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.5 $  $Date: 2004/01/16 20:01:02 $

% Error checking.
if ~isa(obj, 'instrument')
    error('instrument:instrhwinfo:invalidOBJ', 'The first input must be an instrument object.');
end

% Error if invalid.
if ~all(isvalid(obj))
   error('instrument:instrhwinfo:invalidOBJ', 'Instrument object OBJ is an invalid object.');
end

% Initialize the variables.
isString = 0;

switch nargin
case 1
   % Ex. out = instrhwinfo(obj);
   
   % Construct the output.
   out = cell(1, length(obj));
   
   % Extract information from array.
   jobject = igetfield(obj, 'jobject');
   types = igetfield(obj, 'constructor');
   if ~iscell(types)
       types = {types};
   end
   
   % Loop through and get the hardware information.
   for i = 1:length(out)
       tempObj = jobject(i);
       switch (types{i})
       case {'serial','tcpip','udp'}
          fields = {'JarFileVersion'};
       case 'gpib'
          fields = {'AdaptorDllName', 'AdaptorDllVersion', 'AdaptorName', ...
                    'VendorDllName', 'VendorDriverDescription'};
       case 'visa'
          fields = {'AdaptorDllName', 'AdaptorDllVersion', 'AdaptorName', ...
                    'VendorDllName', 'VendorDriverDescription', ...
                    'VendorDriverVersion'};
       case 'icdevice'
          fields = {'Manufacturer', 'Model', 'Type', 'DriverName'};
       end
	
       % Call the java method ObjectHwInfo.
       try
           tempOut = ObjectHardwareInfo(tempObj);
       catch
           rethrow(lasterror);
       end
       tempOut = cell(tempOut);
       out{i} = cell2struct(tempOut', fields, 2);
   end
   
   if length(out) == 1
       out = out{:};
   end
case 2
    % Ex. out = instrhwinfo(obj, 'RsrcName');
    if ~(ischar(prop) || iscellstr(prop))
        error('instrument:instrhwinfo:invalidFieldName', 'Fieldname must be a string or a cell array of strings.');
    end
    
    % Make the string a cell array.
    if ischar(prop)
        isString = 1;
        prop = {prop};
    end
    
    % Make the cell a 1-by-n array.
    prop = {prop{:}};
    
    % Initialize the output argument.
    out = cell(length(obj), length(prop));
    jobject = igetfield(obj, 'jobject');

    for i=1:length(obj)
        %Get the specified property information.
        try
            tempOut = ObjectHardwareInfo(jobject(i), prop);
        catch
            error('instrument:instrhwinfo:opfailed', lasterr);
        end
        out(i,:) = cell(tempOut)';
    end
    
    % Convert back to a string if necessary.
    if isString && (numel(out) == 1)
        out = out{:};
    end
end