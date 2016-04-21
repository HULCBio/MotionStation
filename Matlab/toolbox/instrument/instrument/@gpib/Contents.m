% GPIB Functions and Properties.
%
% GPIB object construction.
%   gpib           - Construct GPIB object.
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
% GPIB functions.
%   clrdevice      - Clear instrument buffer.
%   spoll          - Perform serial poll.
%   trigger        - Send trigger message to instrument.
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
% GPIB properties.
%   BoardIndex                - Index of the access board for the object.
%   BusManagementStatus       - State of bus management lines.
%   ByteOrder                 - Byte order of the instrument.
%   BytesAvailable            - Specifies number of bytes available to be read.
%   BytesAvailableFcn         - Callback function executed when specified number
%                               of bytes are available.
%   BytesAvailableFcnCount    - Number of bytes to be available before executing 
%                               BytesAvailableFcn.
%   BytesAvailableFcnMode     - Specifies whether the BytesAvailableFcn is
%                               based on the number of bytes or terminator
%                               being reached.
%   BytesToOutput             - Number of bytes currently waiting to be sent.
%   CompareBits               - Specifies the number of bits to compare the EOS.                             
%   EOIMode                   - Specifies whether the EOI line is asserted at the
%                               end of a write.
%   EOSCharCode               - Character to terminate on when EOSMode is enabled.
%   EOSMode                   - Configure the end-of-string (EOS) termination mode.
%   ErrorFcn                  - Callback function executed when an error occurs.
%   HandshakeStatus           - State of the handshake lines.
%   InputBufferSize           - Total size of the input buffer.
%   Name                      - Descriptive name of the GPIB object.
%   ObjectVisibility          - Control access to an object by command-line users and
%                               GUIs.
%   OutputBufferSize          - Total size of the output buffer.
%   OutputEmptyFcn            - Callback function executed when output buffer is
%                               empty.
%   PrimaryAddress            - GPIB primary address.
%   RecordDetail              - Amount of information recorded to disk.
%   RecordMode                - Specify whether data is saved to one disk file 
%                               or to multiple disk files.
%   RecordName                - Name of disk file to which data sent and 
%                               received is recorded.
%   RecordStatus              - Indicates if data is being written to disk.
%   SecondaryAddress          - GPIB secondary address.
%   Status                    - Indicates if the GPIB object is connected to
%                               GPIB instrument.
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
% See also GPIB, INSTRHELP, INSTRUMENT/PROPINFO.
%

%    MP 7-13-99
%    Copyright 1999-2004 The MathWorks, Inc. 
%    $Revision: 1.15.4.4 $  $Date: 2004/01/16 19:58:48 $
