% Serial Port Functions and Properties.
%
% Serial Functions and Properties.
%
% Serial port object construction.
%   serial        - Construct serial port object.
%
% Getting and setting parameters.
%   get           - Get value of serial port object property.
%   set           - Set value of serial port object property.
%
% State change.
%   fopen         - Connect object to device.
%   fclose        - Disconnect object from device. 
%   record        - Record data from serial port session.
%
% Read and write functions.
%   fprintf       - Write text to device.
%   fgetl         - Read one line of text from device, discard terminator.
%   fgets         - Read one line of text from device, keep terminator.
%   fread         - Read binary data from device.
%   fscanf        - Read data from device and format as text.
%   fwrite        - Write binary data to device.
%   readasync     - Read data asynchronously from device.
%
% Serial port functions.
%   serialbreak   - Send break to device.
%
% General.
%   delete        - Remove serial port object from memory.
%   inspect       - Open inspector and inspect instrument object properties.
%   instrcallback - Display event information for the event.
%   instrfind     - Find serial port objects with specified property values.
%   instrfindall  - Find all instrument objects regardless of ObjectVisibility.
%   isvalid       - True for serial port objects that can be connected to 
%                   device.
%   stopasync     - Stop asynchronous read and write operation.
%
% Serial port properties.
%   BaudRate                  - Specify rate at which data bits are transmitted.
%   BreakInterruptFcn         - Callback function executed when break interrupt
%                               occurs.
%   ByteOrder                 - Byte order of the device.
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
%   ValuesReceived            - Number of values read from the device.
%   ValuesSent                - Number of values written to device.
%
% See also SERIAL.
%

%    MP 7-13-99
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.7.4.3 $  $Date: 2004/01/16 20:04:01 $
