% VISA Functions and Properties.
%
% VISA object construction.
%   visa           - Construct VISA object.
%
% Getting and setting parameters.
%   get            - Get value of instrument object property.
%   set            - Set value of instrument object property.
%
% State change.
%   fopen          - Connect object to instrument.
%   fclose         - Disconnect object from instrument. 
%   record         - Record data from instrument control session.
%
% Read and write functions.
%   binblockread   - Read binblock from instrument.
%   binblockwrite  - Write binblock to instrument.
%   fprintf        - Write text to instrument.
%   fgetl          - Read one line of text from instrument, discard terminator.
%   fgets          - Read one line of text from instrument, keep terminator.
%   fread          - Read binary data from instrument.
%   fscanf         - Read data from instrument and format as text.
%   fwrite         - Write binary data to instrument.
%   query          - Write and read formatted data from instrument.
%   readasync      - Read data asynchronously from instrument.
%   scanstr        - Parse formatted data from instrument.
%
% VISA-GPIB functions.
%   clrdevice      - Clear instrument buffer.
%   trigger        - Send Group Execute Trigger message to instrument.
%
% VISA-GPIB-VXI functions.
%   clrdevice      - Clear instrument buffer.
%   memmap         - Map memory for low-level memory read and write.
%   mempeek        - Low-level memory read from VXI register.
%   mempoke        - Low-level memory write to VXI register.
%   memread        - High-level memory read from VXI register.
%   memunmap       - Unmap memory for low-level memory read and write.
%   memwrite       - High-level memory write to VXI register.
%
% VISA-VXI functions.
%   clrdevice      - Clear instrument buffer.
%   memmap         - Map memory for low-level memory read and write.
%   mempeek        - Low-level memory read from VXI register.
%   mempoke        - Low-level memory write to VXI register.
%   memread        - High-level memory read from VXI register.
%   memunmap       - Unmap memory for low-level memory read and write.
%   memwrite       - High-level memory write to VXI register.
%   trigger        - Send a software or hardware trigger to VXI hardware.
%
% VISA-USB functions.
%   clrdevice      - Clear instrument buffer.
%   trigger        - Send Group Execute Trigger message to instrument.
%
% VISA-RSIB functions.
%   clrdevice      - Clear instrument buffer.
%   trigger        - Send Group Execute Trigger message to instrument.
%
% General.
%   delete         - Remove instrument object from memory.
%   flushinput     - Remove data from input buffer.
%   flushoutput    - Remove data from output buffer.
%   inspect        - Open inspector and inspect instrument object properties.
%   instrcallback  - Display event information for the event.
%   instrfind      - Find instrument objects with specified property values.
%   instrfindall   - Find all instrument objects regardless of ObjectVisibility.
%   instrid        - Define and retrieve commands used to identify instruments.
%   instrnotify    - Define notification for instrument events.
%   instrreset     - Disconnect and delete all instrument objects.
%   isvalid        - True for instrument objects that can be connected to 
%                    instrument.
%   obj2mfile      - Convert instrument object to MATLAB code.
%   stopasync      - Stop asynchronous read and write operation.
%
% Information and Help.
%   propinfo       - Return instrument object property information.
%   instrhelp      - Display instrument object function and property help.
%   instrhwinfo    - Return information on available hardware.
%
% Instrument Control tools.
%   instrcomm      - Tool for ASCII communication with instrument.
%   instrcreate    - Tool for creating and configuring an instrument object.
%   tmtool         - Tool for browsing available instruments, configuring 
%                    instrument communication and and communicating with
%                    instrument.
%
% VISA properties.
%   Alias                     - Alias for the RsrcName.
%   ByteOrder                 - Byte order of the instrument.
%   BytesAvailable            - Specifies number of bytes available to be read.
%   BytesAvailableFcn         - Callback function executed when specified number
%                               of bytes are available.
%   BytesAvailableFcnCount    - Number of bytes to be available before 
%                               executing BytesAvailableFcn.
%   BytesAvailableFcnMode     - Specifies whether the BytesAvailableFcn is
%                               based on the number of bytes or terminator
%                               being reached.
%   BytesToOutput             - Number of bytes currently waiting to be sent.
%   ErrorFcn                  - Callback function executed when an error occurs.
%   InputBufferSize           - Total size of the input buffer.
%   Name                      - Descriptive name of the serial object.
%   ObjectVisibility          - Control access to an object by command-line users and
%                               GUIs.
%   OutputBufferSize          - Total size of the output buffer.
%   OutputEmptyFcn            - Callback function executed when output buffer is
%                               empty.
%   RecordDetail              - Amount of information recorded to disk.
%   RecordMode                - Specify whether data is saved to one disk file 
%                               or to multiple disk files.
%   RecordName                - Name of disk file to which data sent and 
%                               received is recorded.
%   RecordStatus              - Indicates if data is being written to disk.
%   RsrcName                  - Resource name.
%   Status                    - Indicates if the serial object is connected to
%                               serial port.
%   Tag                       - Label for object.
%   Timeout                   - Seconds to wait to receive data.
%   TimerFcn                  - Callback function executed when a timer event
%                               occurs.
%   TimerPeriod               - Time in seconds between timer events.
%   TransferStatus            - Indicate the asynchronous read or write
%                               operations that are in progress.
%   Type                      - Object type.
%   UserData                  - User data for object.
%   ValuesReceived            - Number of values read from the instrument.
%   ValuesSent                - Number of values written to instrument.
%
%
% VISA-Serial properties.
%   BaudRate                  - Specify rate at which data bits are transmitted.
%   DataBits                  - Number of data bits that are transmitted.
%   DataTerminalReady         - State of the DataTerminalReady pin.
%   FlowControl               - Specify the data flow control method to use. 
%   Parity                    - Error detection mechanism.
%   PinStatus                 - State of hardware pins.
%   Port                      - Description of a hardware port.
%   ReadAsyncMode             - Specify whether an asynchronous read operation
%                               is continuous or manual.
%   RequestToSend             - State of the RequestToSend pin.
%   StopBits                  - Number of bits transmitted to indicate the end 
%                               of data transmission.
%   Terminator                - Character used to terminate commands sent to 
%                               serial port.
%
% VISA-GPIB properties.
%   BoardIndex                - Index of the access board for the object.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   PrimaryAddress            - GPIB primary address.
%   SecondaryAddress          - GPIB secondary address.
%
% VISA-GPIB-VXI properties.
%   BoardIndex                - Board number of the GPIB board to which the GPIB
%	                            VXI is attached.
%   ChassisIndex              - Chassis index.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   LogicalAddress            - Logical address of the VXI instrument.
%   MappedMemoryBase          - Base address of mapped memory.
%   MappedMemorySize          - Size of mapped memory for low level memory functions.
%   MemoryBase                - Base address of the instrument in A24 or A32.
%   MemoryIncrement           - Specifies whether the memory registers are read as
%                               a block or FIFO.
%   MemorySize                - Size of the memory in A24 or A32 space.
%   MemorySpace               - Address space used by the instrument.
%   PrimaryAddress            - Primary address of the GPIB-VXI controller.
%   SecondaryAddress          - Secondary address of the GPIB-VXI controller.
%   Slot                      - Slot location of the VXI instrument.
%
% VISA-VXI properties.
%   ChassisIndex              - Chassis index.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   InterruptFcn              - Callback function executed when a VXI bus signal or 
%                               VXI bus interrupt is received.
%   LogicalAddress            - Logical address of the VXI instrument.
%   MappedMemoryBase          - Base address of mapped memory.
%   MappedMemorySize          - Size of mapped memory for low level memory functions.
%   MemoryBase                - Base address of the instrument in A24 or A32.
%   MemoryIncrement           - Specifies whether the memory registers are read as
%                               a block or FIFO.
%   MemorySize                - Size of the memory in A24 or A32 space.
%   MemorySpace               - Address space used by the instrument.
%   Slot                      - Slot location of the VXI instrument.
%   TriggerFcn                - Callback function executed when a hardware trigger
%                               is received.
%   TriggerLine               - VXI trigger line.
%   TriggerType               - VXI trigger type.
%
% VISA-TCPIP properties.
%   BoardIndex                - Index number of the network board associated with
%                               the instrument.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   LANName                   - Specifies the LAN (Local Area Network) device name.
%   RemoteHost                - Specifies the host name or IP dotted decimal address.
%
% VISA-USB properties.
%   BoardIndex                - Index number of the USB board associated with 
%                               the instrument.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   InterfaceIndex            - Specifies the USB interface number. 
%   ManufacturerID            - Specifies the manufacturer ID of the USB instrument.
%   ModelCode                 - Specifies the model code of the USB instrument. 
%   SerialNumber              - Specifies the index of the USB instrument on the
%                               USB hub.
%
% VISA-RSIB properties.
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   RemoteHost                - Specifies the local host name or IP dotted decimal 
%                               address.
%
% See also VISA, INSTRHELP, INSTRUMENT/PROPINFO.
%

%    MP 7-13-99
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.15.4.5 $  $Date: 2004/01/16 20:02:11 $
