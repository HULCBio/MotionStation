%% Introduction to Virtual Instrument Standard Architecture
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.6 $  $Date: 2004/03/24 20:40:30 $

%% Introduction
% Virtual Instrument Standard Architecture (VISA) is  
% a standard defined for communicating with instruments. 
% The standard provides a common language for communicating 
% with instruments, regardless of the interface.
%
% The Instrument Control Toolbox's VISA object supports 
% seven communication interface types: serial, GPIB, GPIB-VXI, 
% VXI, TCPIP, USB, and RSIB. Note, only National Instrument's VISA with 
% the Rohde & Schwarz VISA passport supports the RSIB interface 
% type.


%% Supported Vendors
% You create a VISA object using the VISA function.
%
%  >> v = visa('Vendor', 'ResourceName');
%
% The following list defines the supported vendors:
%
%    Vendor                 Description
%    ======                 ===========
%    agilent                Agilent Technologies VISA.
%    ni                     National Instruments VISA.
%    tek                    Tektronix VISA.

%% Supported Interfaces
% The following list defines how the different interfaces
% are defined at object creation:
%
%    Interface           ResourceName
%    =======             ============
%    serial              ASRL[port]::INSTR
%    gpib                GPIB[board]::primary_address::[secondary_address]::INSTR
%    gpib-vxi            GPIB-VXI[chassis]::vxi_logical_address::INSTR
%    vxi                 VXI[chassis]::vxi_logical_address::INSTR
%    tcpip               TCPIP[board]::remote_host::[lan_device_name]::INSTR
%    usb                 USB[board]::manid::model_code::serial_No::[interface_No]::INSTR
%    rsib                RSIB::remote_host::INSTR
%
% The following describes the parameters used in the list
% above:
%
%    port                The serial port.
%    board               Board index of the gpib board.
%    chassis             Index of the VXI system.
%    interface_No        USB interface.
%    lan_device_name     Local Area Network (LAN) device name. 
%    manid               Manufacturer ID of the USB instrument.
%    model_code          Model code for the USB instrument.
%    primary_address     Primary address of the gpib board.
%    remote_host         Host name or IP address of the instrument.
%    secondary_address   Secondary address of the gpib board.
%    serial_No           Index of the instrument on the USB hub.
%    vxi_logical_address Logical address of the vxi board.
%
% The parameters in brackets [] are optional. All parameters 
% that are optional default to 0, except port, which defaults to
% 1, and lan_device_name, which defaults to inst0.

%% The Serial Interface
% Serial communication is the simplest and most common low-level  
% protocol for communicating between two or more devices.  
% Normally, one device is a computer, while the other device 
% can be a modem, a printer, a data acquisition device, or 
% another computer.
%
% As the name suggests, the serial port sends and receives
% bytes of information in a serial fashion, one bit at a time.
% These bytes can be transmitted using either a binary format 
% or an ASCII format.  
%
% Communication is accomplished using three transmission
% lines: the Transmit Data line, the Receive Data line, 
% and the Ground. Other lines are available for handshaking, 
% but are not required.

%% Creating a VISA-Serial Object
% The following command creates a VISA-serial object.
%
%  >> vserial = visa('agilent', 'ASRL2::INSTR')
%
%    VISA-Serial Object Using AGILENT Adaptor : VISA-Serial-ASRL2
%
%    Communication Settings 
%       Port:               ASRL2
%       BaudRate:           9600
%       Terminator:         'LF'
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA-serial object, vserial, communicates with an  
% instrument connected to the ASRL2 (which is 
% defined as the COM2) port. The Agilent Technologies VISA
% DLL is installed on the computer and used to communicate
% with the instrument.

%% The GPIB Interface
% General Purpose Interface Bus (GPIB), also known as the
% IEEE 488 interface, is a standard interface for communicating
% between two or more devices. The bus supports one controller
% (usually a computer) and up to fourteen additional 
% instruments.
%
% Eight bits of data are transferred in parallel along the bus 
% using a three wire handshake: the Data Valid line, the Not 
% Data Accepted line, and the Not Ready for Data line. The 
% three wire handshake assures reliable data transfer at 
% the rate determined by the slowest device. Data transfer 
% rates can exceed 1 Mbyte/second.

%% Creating a VISA-GPIB Object
% The following command creates a VISA-GPIB object. 
%
%  >> vgpib = visa('ni', 'GPIB2::4::0::INSTR')
%
%    VISA-GPIB Object Using NI Adaptor : VISA-GPIB2-4
%
%    Communication Address 
%       BoardIndex:         2
%       PrimaryAddress:     4
%       SecondaryAddress:   0
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%      
% The VISA-GPIB object, vgpib, communicates with an 
% instrument through a GPIB board with board index 2. 
% The instrument has a primary address of 4 and no 
% secondary address. The National Instruments VISA DLL 
% is installed on the computer and is used to communicate 
% with the instrument.

%% The VXI Interface
% A VXI system consists of a chassis, VXI instruments,
% a slot 0 card, and a resource manager. The slot 0 card 
% controls the VXI backplane. The resource manager configures 
% the modules for proper operation whenever the system is 
% powered on or reset (the slot 0 card can also be the 
% resource manager). The chassis holds the VXI instruments, 
% the slot 0 card, and the resource manager, and contains the 
% VXI backplane. 
%
% VXI instruments can be either message-based or register-
% based. A message-based instrument is generally easier to 
% use than a register-based instrument. While a register- 
% based instrument is generally faster than a message-based 
% instrument.  
%
% The VXI interface uses an embedded VXI controller (in slot 0) 
% to access the VXI instruments over the VXI backplane.

%% Creating a VISA-VXI Object
% The following command creates a VISA-VXI object.
%
%  >> vvxi = visa('agilent', 'VXI0::8::INSTR')
%
%    VISA-VXI Object Using AGILENT Adaptor : VISA-VXI0-8
%
%    Communication Address 
%       ChassisIndex:       0
%       LogicalAddress:     8
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA object, vvxi, communicates with a VXI instrument 
% located at logical address 8 in the first VXI chassis. The
% Agilent Technologies VISA DLL is installed on the computer
% and is used to communicate with the instrument.

%% The GPIB-VXI Interface
% The GPIB-VXI interface is similar to the VXI interface, 
% however, there is a GPIB controller in slot 0. The GPIB 
% controller contains a GPIB connector that is connected 
% to a GPIB board in your computer. The GPIB controller can
% communicate to instruments in the chassis over the VXI 
% backplane.

%% Creating a VISA-GPIB-VXI Object
% The following command creates a VISA-GPIB-VXI object.
%
%  >> vgpibvxi = visa('agilent', 'GPIB-VXI0::16::INSTR')
%
%    VISA-GPIB-VXI Object Using AGILENT Adaptor : VISA-GPIB-VXI0-16
%
%    Communication Address 
%       ChassisIndex:       0
%       LogicalAddress:     16
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA object, vgpibvxi, communicates with a VXI instrument 
% located at logical address 16 in the first VXI system. The 
% Agilent Technologies VISA DLL is installed on the computer
% and is used to communicate with the instrument.

%% The TCPIP Interface
% The TCPIP interface allows you to communicate with an 
% instrument using the VXI-11 interface. It allows you
% to communicate with a networked instrument.

%% Creating a VISA-TCPIP Object
% The following command creates a VISA-TCPIP object.
%
%  >> vtcpip = visa('tek', 'TCPIP::216.148.60.170::INSTR')
%
%    VISA-TCPIP Object Using TEK Adaptor : VISA-TCPIP-216.148.60.170
%
%    Communication Address 
%       RemoteHost:         216.148.60.170
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA object, vtcpip, communicates with an instrument
% configured with IP address 216.148.60.170. The Tektronix
% VISA DLL is installed on the computer and is used to
% communicate with the instrument.

%% The USB Interface
% The USB interface allows you to communicate with an 
% instrument that has a USB interface. 

%% Creating a VISA-USB Object
% The following command creates a VISA-USB object.
%
%  >> vusb = visa('agilent', 'USB::0x1234::125::A22-5::INSTR')
%
%    VISA-USB Object Using AGILENT Adaptor : VISA-USB-0-0x1234-125-A22-5-0
%
%    Communication Address 
%       ManufacturerID:     0x1234
%       ModelCode:          125
%       SerialNumber:       A22-5
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA object, vusb, communicates with a USB instrument
% with manufacturer ID 0x1234, model code 125 and serial
% number A22-5. The instrument is using the first available
% USBTMC interface. The Agilent VISA DLL is installed on the
% computer and is used to communicate with the instrument.


%% The RSIB Interface
% The RSIB interface is supported by National Instruments 
% VISA only. It also requires the Rohde & Schwarz VISA 
% passport. The RSIB interface allows you to communicate  
% with Rohde & Schwarz spectrum analyzers, network analyzers,
% and test receivers.

%% Creating a VISA-RSIB Object
% The following command creates a VISA-RSIB object.
%
%  >> vrsib = visa('ni', 'RSIB::192.168.1.33::INSTR')
%
%    VISA-RSIB Object Using NI Adaptor : VISA-RSIB-192.168.1.33
%
%    Communication Address 
%       RemoteHost:         192.168.1.33
%
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
%
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
%
% The VISA object, vrsib, communicates with an Rohde & Schwarz 
% spectrum analyzer configured with IP address 192.168.1.33.  
% The NI VISA DLL and the Rohde & Schwarz VISA passport are 
% installed on the computer and are used to communicate with the 
% instrument.

%% Obtaining Hardware Information for Your Computer
% You can use the INSTRHWINFO function to obtain information 
% about the hardware installed in your computer. For example,
% the following command lists the available serial ports, 
% GPIB boards, and VXI chassis.
%
%  >> info = instrhwinfo('visa', 'ni')
%
%  info = 
%
%                AdaptorDllName: [1x72 char]
%             AdaptorDllVersion: 'Version 1.0 (R12)'
%                   AdaptorName: 'NI'
%              AvailableChassis: 0
%          AvailableSerialPorts: {2x1 cell}
%             InstalledBoardIds: 2
%         ObjectConstructorName: {4x1 cell}
%                   SerialPorts: {2x1 cell}
%                 VendorDllName: 'visa32.dll'
%       VendorDriverDescription: 'National Instruments VISA Driver'
%           VendorDriverVersion: 2
%
%  >> info.ObjectConstructorName
%
%  ans = 
%
%     'visa('ni', 'ASRL1::INSTR');'
%     'visa('ni', 'ASRL2::INSTR');'
%     'visa('ni', 'GPIB2::4::INSTR');'
%     'visa('ni', 'VXI0::8::INSTR');'
