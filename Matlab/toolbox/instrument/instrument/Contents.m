% Instrument Control Toolbox
% Version 2.0 (R14) 05-May-2004
%
% Interface object construction.
%   instrument/gpib     - Construct GPIB object.
%   instrument/tcpip    - Construct TCPIP object.
%   instrument/udp      - Construct UDP object.
%   instrument/visa     - Construct VISA object.
%   instrument/serial   - Construct serial port object.
%
% Instrument device object construction.
%   instrument/icdevice - Construct ICDEVICE (device) object.
%
% IVI configuration store object construction.
%   instrument/iviconfigurationstore - Construct IVICONFIGURATIONSTORE object.
%
% Getting and setting parameters.
%   get                 - Get value of instrument object property.
%   set                 - Set value of instrument object property.
%
% Interface object - state change.
%   fopen               - Connect object to instrument.
%   fclose              - Disconnect object from instrument. 
%   record              - Record data from instrument control session.
%
% Device object - state change.
%   connect             - Connect object to instrument.
%   disconnect          - Disconnect object from instrument. 
%
% INTERFACE functions.
%   binblockread        - Read binblock from instrument.
%   binblockwrite       - Write binblock to instrument.
%   fprintf             - Write text to instrument.
%   fgetl               - Read one line of text from instrument, discard 
%                         terminator.
%   fgets               - Read one line of text from instrument, keep terminator.
%   flushinput          - Remove data from input buffer.
%   flushoutput         - Remove data from output buffer.
%   fread               - Read binary data from instrument.
%   fscanf              - Read data from instrument and format as text.
%   fwrite              - Write binary data to instrument.
%   query               - Write and read formatted data from instrument.
%   readasync           - Read data asynchronously from instrument.
%   scanstr             - Parse formatted data from instrument.
%   stopasync           - Stop asynchronous read and write operation.
%
% ICDEVICE functions.
%   devicereset         - Reset the instrument.
%   geterror            - Check and return error message from instrument.
%   selftest            - Run the instrument self-test.
%   vxipnp2mid          - Convert VXIplug&play driver to MATLAB instrument
%                         driver.
%
% GPIB functions.
%   clrdevice           - Clear instrument buffer.
%   spoll               - Perform serial poll.
%   trigger             - Send trigger message to instrument.
%
% TCPIP functions.
%   echotcpip           - Create a TCP/IP echo server.
%   resolvehost         - Return IP address or name of network address.
%
% UDP functions.
%   echoudp             - Create a UDP echo server.
%   resolvehost         - Return IP address or name of network address.
%
% VISA-GPIB functions.
%   clrdevice           - Clear instrument buffer.
%   trigger             - Send Group Execute Trigger message to instrument.
%
% VISA-GPIB-VXI functions.
%   clrdevice           - Clear instrument buffer.
%   memmap              - Map memory for low-level memory read and write.
%   mempeek             - Low-level memory read from VXI register.
%   mempoke             - Low-level memory write to VXI register.
%   memread             - High-level memory read from VXI register.
%   memunmap            - Unmap memory for low-level memory read and write.
%   memwrite            - High-level memory write to VXI register.
%
% VISA-VXI functions.
%   clrdevice           - Clear instrument buffer.
%   memmap              - Map memory for low-level memory read and write.
%   mempeek             - Low-level memory read from VXI register.
%   mempoke             - Low-level memory write to VXI register.
%   memread             - High-level memory read from VXI register.
%   memunmap            - Unmap memory for low-level memory read and write.
%   memwrite            - High-level memory write to VXI register.
%   trigger             - Send a software or hardware trigger to VXI hardware.
%
% VISA-USB functions.
%   clrdevice           - Clear instrument buffer.
%   trigger             - Send Group Execute Trigger message to instrument.
%
% VISA-RSIB functions.
%   clrdevice           - Clear instrument buffer.
%   trigger             - Send Group Execute Trigger message to instrument.
%
% Serial port functions.
%   serialbreak         - Send break to device.
%
% IVI Configuration store functions.
%   add                 - Add a new entry.
%   commit              - Save changes to disk.
%   remove              - Remove and entry.
%   update              - Update an entry.
%
% General.
%   delete              - Remove instrument object from memory.
%   inspect             - Open inspector and inspect instrument object properties.
%   instrcallback       - Display event information for the event.
%   instrfind           - Find instrument objects with specified property values.
%   instrfindall        - Find all instrument objects regardless of ObjectVisibility.
%   instrid             - Define and retrieve commands used to identify instruments.
%   instrnotify         - Define notification for instrument events.
%   instrreset          - Disconnect and delete all instrument objects.
%   isvalid             - True for instrument objects that can be connected to 
%                         instrument.
%   obj2mfile           - Convert instrument object to MATLAB code.
%
% Information and Help.
%   propinfo            - Return instrument object property information.
%   instrhelp           - Display instrument object function and property help.
%   instrhwinfo         - Return information on available hardware.
%
% Instrument Control tools.
%   instrcomm           - Tool for ASCII communication with instrument.
%   instrcreate         - Tool for creating and configuring an instrument object.
%   makemid             - Make MATLAB instrument drivers for VXIplug&play 
%                         and IVI drivers. 
%   midedit             - Edit MATLAB instrument driver file.
%   midtest             - Launch GUI for testing MATLAB instrument driver.
%   tmtool              - Tool for browsing available instruments, configuring 
%                         instrument communication and communicating with
%                         instrument.
%
% See also GPIB, ICDEVICE, SERIAL, TCPIP, UDP, VISA, INSTRHELP, INSTRUMENT/PROPINFO.
%

%    MP 7-13-99
%    Copyright 1999-2004 The MathWorks, Inc. 
%    Generated from Contents.m_template revision 1.1.6.5  $Date: 2004/02/01 21:55:08 $
