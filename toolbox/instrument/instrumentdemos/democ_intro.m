%% Getting Started With the Instrument Control Toolbox
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.10.2.6 $  $Date: 2004/03/24 20:40:11 $

%% Introduction
% This tutorial uses INSTRHWINFO, PROPINFO, and INSTRHELP
% to help you learn about the functionality provided by the Instrument
% Control Toolbox.
% 
% INSTRHWINFO is used to determine 
%
% * What instrument interfaces are available 
% * What interface objects can be created
% * What GPIB and VISA vendors are supported 
% * What instrument drivers are available
% 
% PROPINFO is used to determine a property's characteristics 
% such as its
%
% * Default value
% * Constraint value
% * Data type
% 
% INSTRHELP is used to obtain online help on toolbox functions
% and properties.

%% Using INSTRHWINFO
% You can use INSTRHWINFO to display information relating to 
% the toolbox and supported instrument interfaces.
% 
%  >> instrinfo = instrhwinfo
% 
%  instrinfo = 
% 
%           MatlabVersion: '7.0.0.3979 (R14)' 
%     SupportedInterfaces: {'gpib' 'serial' 'visa' 'tcpip' 'udp'}
%        SupportedDrivers: {'matlab'  'vxipnp'  'ivi'}
%             ToolboxName: 'Instrument Control Toolbox' 
%          ToolboxVersion: [1x39 char]

%% Serial Port Information
% With the Instrument Control Toolbox, you can communicate
% with serial ports on the Windows, Solaris, and Linux platforms.
% To obtain serial-specific information, the string 'serial'
% is passed to the INSTRHWINFO function.
% 
%  >> serialinfo = instrhwinfo('serial')
% 
%  serialinfo = 
% 
%      AvailableSerialPorts: {2x1 cell}
%            JarFileVersion: 'Version 2.0 (R14)' 
%     ObjectConstructorName: {2x1 cell}
%               SerialPorts: {2x1 cell}
% 
% All serial ports on your machine are listed in the 
% SerialPorts field.
% 
%  >> serialinfo.SerialPorts
% 
%  ans = 
% 
%     'COM1' 
%     'COM2' 
% 
% The serial ports currently not in use are listed in the
% AvailableSerialPorts field.
% 
%  >> serialinfo.AvailableSerialPorts
% 
%  ans = 
% 
%     'COM1' 
%     'COM2' 
% 
% The commands for creating serial port objects
% are listed in the ObjectConstructorName field.
% 
%  >> serialinfo.ObjectConstructorName
% 
%  ans = 
% 
%     'serial('COM1');' 
%     'serial('COM2');'

%% GPIB Information
% The Instrument Control Toolbox provides access to GPIB 
% hardware from supported vendors. To obtain GPIB-specific
% information, the string 'gpib' is passed to the INSTRHWINFO
% function.
% 
%  >> gpibinfo = instrhwinfo('gpib')
% 
%  gpibinfo = 
% 
%     InstalledAdaptors: {'agilent'  'cec'  'contec'  'ics'  'iotech'  'keithley'  'mcc'  'ni'}
%        JarFileVersion: 'Version 2.0 (R14)'
 
%% GPIB Adaptor
% A GPIB adaptor is the toolbox component that passes 
% information between MATLAB and the GPIB hardware. The 
% supported adaptors are listed in the InstalledAdaptors 
% field.
% 
% Note, the adaptors listed are dependent on which vendor
% drivers you have installed on your computer. Only those
% adaptors that can be loaded (because the necessary drivers
% are installed on your computer) are listed.
% 
%  >> gpibinfo.InstalledAdaptors
% 
%  ans = 
% 
%      'agilent'    'cec'    'contec'    'ics'    'iotech'    'keithley'    'mcc'    'ni' 
% 
% Specific information relating to an adaptor can be displayed
% by passing the adaptor name to INSTRHWINFO. This information
% includes
%
% * The GPIB adaptor DLL filename and version
% * The vendor's driver name and description
% * The MATLAB command for creating a GPIB object 
% 
% To return information about National Instruments GPIB adaptors,
% use the following command
% 
%  >> vendorinfo = instrhwinfo('gpib','ni')
% 
%  vendorinfo = 
% 
%              AdaptorDllName: [1x72 char]
%           AdaptorDllVersion: 'Version 2.0 (R14)' 
%                 AdaptorName: 'ni' 
%           InstalledBoardIds: 0
%       ObjectConstructorName: 'gpib('ni', 0, 4)' 
%               VendorDllName: 'gpib-32.dll' 
%     VendorDriverDescription: 'NI-488'\n'
%
% The commands necessary for creating a GPIB object are listed
% in the ObjectConstructorName field. 
% 
%  >> vendorinfo.ObjectConstructorName
% 
%  ans =
% 
%      gpib('ni', 0, 4)

%% VISA Information
% The Instrument Control Toolbox provides access to the serial 
% port, GPIB hardware, VXI hardware, and GPIB-VXI hardware using
% the VISA standard. To obtain VISA-specific information, the  
% string 'visa' is passed to the INSTRHWINFO function.
% 
%  >> visainfo = instrhwinfo('visa')
% 
%  visainfo = 
% 
%     InstalledAdaptors: {'ni'}
%        JarFileVersion: 'Version 1.0 (R12)'

%% VISA Adaptor
% A VISA adaptor is the toolbox component that passes 
% information between MATLAB and your instrument using the
% VISA standard. The supported adaptors are listed in the 
% InstalledAdaptors field.
% 
% Note, the adaptors listed are dependent on which vendor
% drivers you have installed on your computer. Only those
% adaptors that can be loaded (because the necessary drivers
% are installed on your computer) are listed.
% 
%  >> visainfo.InstalledAdaptors
% 
%  ans = 
% 
%     'ni' 
% 
% Specific information relating to an adaptor can be displayed
% by passing the adaptor name to INSTRHWINFO. This information
% includes
%
% * The VISA adaptor DLL filename and version
% * The vendor's driver description and version
% * The available serial ports, installed GPIB board IDs, 
%   and the available VXI chassis
% * The MATLAB command for creating a VISA object 
% 
% To return information about a National Instruments VISA  
% adaptor the following command is used.
% 
%  >> vendorinfo = instrhwinfo('visa','ni')
% 
%  vendorinfo = 
% 
%              AdaptorDllName: [1x72 char]
%           AdaptorDllVersion: 'Version 2.0 (R14)' 
%                 AdaptorName: 'NI' 
%            AvailableChassis: 0
%        AvailableSerialPorts: {2x1 cell}
%           InstalledBoardIds: 0
%       ObjectConstructorName: {4x1 cell}
%                 SerialPorts: {2x1 cell}
%               VendorDllName: 'visa32.dll' 
%     VendorDriverDescription: 'National Instruments VISA Driver' 
%         VendorDriverVersion: 2
%
% The commands for creating a VISA-serial, VISA-GPIB, VISA-VXI, 
% or VISA-GPIB-VXI object are listed in the ObjectConstructorName field.
% 
%  >> vendorinfo.ObjectConstructorName
% 
%  ans = 
% 
%     'visa('ni', 'ASRL1::INSTR');' 
%     'visa('ni', 'ASRL2::INSTR');' 
%     'visa('ni', 'GPIB0::4::INSTR');' 
%     'visa('ni', 'VXI0::8::INSTR');'

%% TCPIP and UDP Information
% The Instrument Control Toolbox provides access to networked 
% instruments through the TCPIP and UDP objects. To obtain TCPIP 
% specific information, the string 'tcpip' is passed to the
% INSTRHWINFO function.
% 
%  >> tcpipinfo = instrhwinfo('tcpip')
% 
%  tcpipinfo = 
% 
%             LocalHost: {'wsydney/144.134.123.27'}
%        JarFileVersion: 'Version 2.0 (R14)' 
% 
% Passing the string 'udp' to the INSTRHWINFO function returns
% the same information.

%% Instrument Driver Information
% The Instrument Control Toolbox allows you to communicate with 
% instruments using MATLAB instrument drivers.  MATLAB instrument drivers
% communicate using three mechanisms
%
% * Instrument Control Toolbox interface objects
% * VXIplug&play drivers
% * IVI drivers
%

%% MATLAB Instrument Driver Information
% To obtain information on the available MATLAB instrument drivers,
% pass the string 'matlab' to the INSTRHWINFO function.
%
%  >> mlinfo = instrhwinfo('matlab')
%
%  mlinfo = 
%
%    InstalledDrivers: {1x3 cell}
%
%  >> mlinfo.InstalledDrivers
%
%  ans = 
%
%    Columns 1 through 3
%
%    'Tktds8k'    'agilent_33120'    'agilent_34401a'
%  
% To obtain information on a specific MATLAB instrument driver, pass the
% string 'matlab' and the MATLAB instrument driver name to the INSTRHWINFO
% function. This information includes
%
% * Instrument manufacturer, model, and type
% * Driver type, name, and version
% * If driver type is VXIplug&play or IVI-C, the name of the dll that
%   is used to communicate with the hardware
%
% In this example, information is returned on a MATLAB instrument driver that
% uses an interface object to communicate with the hardware.
% 
%  >> info = instrhwinfo('matlab', 'agilent_33120')
%
%  info = 
%
%     Manufacturer: 'Agilent'
%            Model: '33120A'
%             Type: 'Function Generator'
%       DriverType: 'MATLAB interface object'
%       DriverName: [1x78 char]
%    DriverVersion: '1.0'
%    DriverDllName: ''
%
% In this example, information is returned on a MATLAB instrument driver that
% uses a VXIplug&play driver to communicate with the hardware.
%
%  >> info = instrhwinfo('matlab', 'Tktds8k')
%
%  info = 
%
%     Manufacturer: 'Tektronix, Inc.'
%            Model: 'TDS 8000 Series Oscilloscope'
%             Type: 'VXIPnPInstrument'
%       DriverType: 'MATLAB VXIplug&play'
%       DriverName: [1x78 char]
%    DriverVersion: '4.1'
%    DriverDllName: 'C:\VXIpnp\WINNT\bin\tktds8k_32.dll'
%

%% VXIplug&play Driver Information
% To obtain information on the available VXIplug&play drivers, pass the
% string 'vxipnp' to the INSTRHWINFO function. The MAKEMID function uses
% VXIplug&play drivers to create MATLAB VXIplug&play instrument drivers. 
%
%  >> vinfo = instrhwinfo('vxipnp')
%
%  vinfo = 
%
%    InstalledDrivers: {'HP33120A'  'HP34401'  'Tktds8k'}
%      VXIPnPRootPath: 'C:\VXIpnp\WINNT'
%
% To obtain information on a specific VXIplug&play driver, pass the string
% 'vxipnp' and the VXIplug&play driver name to the
% INSTRHWINFO function. This information includes
%
% * Instrument manufacturer and model
% * Driver version
% * Name of the dll that is used to communicate with the hardware
%
%  >> vinfo = instrhwinfo('vxipnp', 'HP33120a')
%
%  vinfo = 
%
%     Manufacturer: 'Hewlett-Packard Company'
%            Model: 'HP33120A'
%    DriverVersion: '4.1'
%    DriverDllName: 'C:\VXIpnp\WINNT\bin\hp33120a_32.dll'

%% IVI Driver Information
% To obtain information on the available IVI logical names and drivers,
% pass the string  'ivi' to the INSTRHWINFO function. The MAKEMID function
% uses IVI logical names and drivers drivers to create MATLAB IVI
% instrument drivers.
%
%  >> iinfo = instrhwinfo('ivi')
%
%  iinfo = 
%                  LogicalNames: {'MyScope'  'MyPower'}
%                    ProgramIDs: {'TekScope.TekScope'}
%                       Modules: {'ag3325b'}
%    ConfigurationServerVersion: '1.3.1.0'
%      MasterConfigurationStore: 'D:\Applications\IVI\Data\IviConfigurationStore.xml'
%                   IVIRootPath: 'D:\Applications\IVI'            
%
% To obtain information on a specific IVI logical name, pass the string 'ivi' and
% the IVI logical name to the INSTRHWINFO function. 
%
%  >> iinfo = instrhwinfo('ivi', 'MyScope')
%
%  iinfo = 
%
%                DriverSession: 'TekScope.DriverSession'
%                HardwareAsset: 'TekScope.Hardware'
%               SoftwareModule: 'TekScope.Software'
%         IOResourceDescriptor: 'GPIB0::13::INSTR'
%    SupportedInstrumentModels: 'TekScope 5000, 6000 and 7000 series oscilloscopes.'
%            ModuleDescription: 'TekScope software module description'
%               ModuleLocation: ''
%

%% Using PROPINFO
% PROPINFO is used to determine a property's characteristics.
% When PROPINFO is called with an instrument object as the 
% input argument, a structure is returned. The field names of 
% the structure are the object property names. The field values 
% are a structure containing the property's characteristics,
% such as
%
% * The property data type
% * Constraints on the property values
% * The default property value
% * The conditions in which the property is read-only
% * An indication of whether the property is interface-specific
% 
%  >> gInfo = propinfo(g)
% 
%  gInfo = 
% 
%                    BoardIndex: [1x1 struct]
%           BusManagementStatus: [1x1 struct]
%                     ByteOrder: [1x1 struct]
%                BytesAvailable: [1x1 struct]
%             BytesAvailableFcn: [1x1 struct]
%        BytesAvailableFcnCount: [1x1 struct]
%         BytesAvailableFcnMode: [1x1 struct]
%                 BytesToOutput: [1x1 struct]
%                   CompareBits: [1x1 struct]
%                       EOIMode: [1x1 struct]
%                   EOSCharCode: [1x1 struct]
%                       EOSMode: [1x1 struct]
%                      ErrorFcn: [1x1 struct]
%               HandshakeStatus: [1x1 struct]
%               InputBufferSize: [1x1 struct]
%                          Name: [1x1 struct]
%              ObjectVisibility: [1x1 struct]
%              OutputBufferSize: [1x1 struct]
%                OutputEmptyFcn: [1x1 struct]
%                PrimaryAddress: [1x1 struct]
%                  RecordDetail: [1x1 struct]
%                    RecordMode: [1x1 struct]
%                    RecordName: [1x1 struct]
%                  RecordStatus: [1x1 struct]
%              SecondaryAddress: [1x1 struct]
%                        Status: [1x1 struct]
%                           Tag: [1x1 struct]
%                       Timeout: [1x1 struct]
%                      TimerFcn: [1x1 struct]  
%                   TimerPeriod: [1x1 struct]  
%                TransferStatus: [1x1 struct]
%                          Type: [1x1 struct]
%                      UserData: [1x1 struct]
%                ValuesReceived: [1x1 struct]
%                    ValuesSent: [1x1 struct]'

%% Property Information
% Information on the RecordMode property is listed below.
% 
%  >> modeInfo = gInfo.RecordMode 
% 
%  modeInfo = 
% 
%                  Type: 'string' 
%            Constraint: 'enum' 
%       ConstraintValue: {3x1 cell}
%          DefaultValue: 'overwrite' 
%              ReadOnly: 'whileRecording' 
%     InterfaceSpecific: 0
%  
% The information returned indicates that the RecordMode 
% property
%
% * Has a default value of 'overwrite'
% * Cannot be configured while the object is recording
% * Is a property available to all objects
% * Must be set to one of the following values:
% 
%  >> modeInfo.ConstraintValue
% 
%  ans = 
% 
%    'overwrite' 
%    'append' 
%    'index'

%% Property Information on a Specific Property
% Alternatively, you can pass a property name to the PROPINFO
% function. In this example, information on the CompareBits
% property is returned.
% 
%  >> compareInfo = propinfo(g, 'CompareBits')
% 
%  compareInfo = 
% 
%                  Type: 'double' 
%            Constraint: 'bounded' 
%       ConstraintValue: [7 8]
%          DefaultValue: 8
%              ReadOnly: 'never' 
%     InterfaceSpecific: 1
% 
% The information returned indicates that the CompareBits
% property
%
% * Can be a double ranging between 7 and 8
% * Has a default value of 8
% * Is specific to GPIB objects

%% Using INSTRHELP
% You can use INSTRHELP to display property and function help.
% The "See Also" section that follows the display contains 
% related properties and functions. The related properties 
% are displayed using mixed case. The related functions are
% displayed using upper case.
% 
%  >> instrhelp RecordStatus
% 
%    RECORDSTATUS   [ {off} | on ]  (read only)
% 
%    Indicate if data and event information are saved to a record file.
%    
%    You can configure RecordStatus to be on or off with the RECORD function.
%    If RecordStatus is on, then data and event information are saved to the
%    record file specified by RecordName. If RecordStatus is off, then data 
%    and event information are not saved to a record file.
%    
%    Use the RECORD function to initiate or complete recording. RecordStatus
%    is automatically configured to reflect the recording state.
%    
%    See also RECORD, RecordDetail, RecordMode, RecordName.
%    
%  >> instrhelp get
% 
%  GET Get instrument object properties.
% 
%     V = GET(OBJ,'Property') returns the value, V, of the specified 
%     property for instrument object OBJ. 
% 
%     If Property is replaced by a 1-by-N or N-by-1 cell array of strings 
%     containing property names, then GET will return a 1-by-N cell array
%     of values. If OBJ is a vector of instrument objects, then V will be 
%     a M-by-N cell array of property values where M is equal to the length
%     of OBJ and N is equal to the number of properties specified.
% 
%     GET(OBJ) displays all property names and their current values for
%     instrument object OBJ.
% 
%     V = GET(OBJ) returns a structure, V, where each field name is the
%     name of a property of OBJ and each field contains the value of that 
%     property.
% 
%     Example:
%        g = gpib('ni', 0, 2);
%        get(g, {'PrimaryAddress','EOSCharCode'})
%        out = get(g, 'EOIMode')
%        get(g)
% 
%     See also INSTRUMENT/SET, INSTRUMENT/PROPINFO, INSTRHELP.

