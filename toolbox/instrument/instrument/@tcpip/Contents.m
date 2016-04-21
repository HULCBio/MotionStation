% TCPIP Functions and Properties.
%
% TCPIP object construction.
%   tcpip          - Construct TCPIP object.
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
% TCPIP functions.
%   echotcpip      - Create a TCP/IP echo server.
%   resolvehost    - Return IP address or name of network address.
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
% TCPIP properties.
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
%   Name                      - Descriptive name of the tcpip object.
%   ObjectVisibility          - Control access to an object by command-line users and
%                               GUIs.
%   OutputBufferSize          - Total size of the output buffer.
%   OutputEmptyFcn            - Callback function executed when output buffer is
%                               empty.
%   LocalHost                 - Description of a socket local host.
%   LocalPort                 - Description of a socket local port.
%   LocalPortMode             - Specify automatic local port assignment.
%   ReadAsyncMode             - Specify whether an asynchronous read operation
%                               is continuous or manual.
%   RecordDetail              - Amount of information recorded to disk.
%   RecordMode                - Specify whether data is saved to one disk file 
%                               or to multiple disk files.
%   RecordName                - Name of disk file to which data sent and 
%                               received is recorded.
%   RecordStatus              - Indicates if data is being written to disk.
%   RemoteHost                - Description of a network host.
%   RemotePort                - Description of a network host port.
%   Status                    - Indicates if the tcpip object is connected 
%                               to a remote host.
%   Tag                       - Label for object.
%   Terminator                - Character used to terminate commands sent to 
%                               the remote host.
%   Timeout                   - Seconds to wait to receive data.
%   TimerFcn                  - Callback function executed when a timer event
%                               occurs.
%   TimerPeriod               - Time in seconds between timer events.
%   TransferDelay             - Specify use of Nagle's algorithm.
%   TransferStatus            - Indicate the asynchronous read or write
%                               operations that are in progress.
%   Type                      - Object type.
%   UserData                  - User data for object.
%   ValuesReceived            - Number of values read from the instrument.
%   ValuesSent                - Number of values written to instrument.
%
% See also TCPIP, INSTRHELP, INSTRUMENT/PROPINFO.
%

%    RGW 8-13-01
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.6.4.4 $  $Date: 2004/01/16 20:01:44 $
