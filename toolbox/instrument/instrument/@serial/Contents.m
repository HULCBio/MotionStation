% Serial Functions and Properties.
%
% Serial port object construction.
%   serial         - Construct serial port object.
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
% Serial port functions.
%   serialbreak    - Send break to instrument.
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
% Serial port properties.
%   BaudRate                  - Specify rate at which data bits are transmitted.
%   BreakInterruptFcn         - Callback function executed when break interrupt
%                               occurs.
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
%   DataBits                  - Number of data bits that are transmitted.
%   DataTerminalReady         - State of the DataTerminalReady pin.
%   ErrorFcn                  - Callback function executed when an error occurs.
%   FlowControl               - Specify the data flow control method to use. 
%   InputBufferSize           - Total size of the input buffer.
%   Name                      - Descriptive name of the serial port object.
%   ObjectVisibility          - Control access to an object by command-line users and
%                               GUIs.
%   OutputBufferSize          - Total size of the output buffer.
%   OutputEmptyFcn            - Callback function executed when output buffer is
%                               empty.
%   Parity                    - Error detection mechanism.
%   PinStatus                 - State of hardware pins.
%   PinStatusFcn              - Callback function executed when pin in the 
%                               PinStatus structure changes value.
%   Port                      - Description of a hardware port.
%   ReadAsyncMode             - Specify whether an asynchronous read operation
%                               is continuous or manual.
%   RecordDetail              - Amount of information recorded to disk.
%   RecordMode                - Specify whether data is saved to one disk file 
%                               or to multiple disk files.
%   RecordName                - Name of disk file to which data sent and 
%                               received is recorded.
%   RecordStatus              - Indicates if data is being written to disk.
%   RequestToSend             - State of the RequestToSend pin.
%   Status                    - Indicates if the serial port object is connected 
%                               to serial port.
%   StopBits                  - Number of bits transmitted to indicate the end 
%                               of data transmission.
%   Tag                       - Label for object.
%   Terminator                - Character used to terminate commands sent to 
%                               serial port.
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
% See also SERIAL, INSTRHELP, INSTRUMENT/PROPINFO.
%

%    MP 7-13-99
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.16.4.4 $  $Date: 2004/01/16 20:01:27 $
