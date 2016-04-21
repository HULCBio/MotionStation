% ICDevice Functions and Properties.
%
% ICDevice object construction.
%   icdevice       - Construct ICDevice (device) object.
%
% Getting and setting parameters.
%   get            - Get value of instrument object property.
%   set            - Set value of instrument object property.
%
% State change.
%   connect        - Connect object to instrument.
%   disconnect     - Disconnect object from instrument. 
%
% Instrument functions.
%   devicereset    - Reset the instrument.
%   geterror       - Check and return error message from instrument.
%   selftest       - Run the instrument self-test.
%   vxipnp2mid     - Convert VXIplug&play driver to MATLAB instrument driver.
%
% General.
%   delete         - Remove instrument object from memory.
%   inspect        - Open inspector and inspect instrument object properties.
%   instrfind      - Find instrument objects with specified property values.
%   instrfindall   - Find all instrument objects regardless of ObjectVisibility.
%   instrid        - Define and retrieve commands used to identify instruments.
%   instrnotify    - Define notification for instrument events.
%   instrreset     - Disconnect and delete all instrument objects.
%   invoke         - Execute function on device object.
%   isvalid        - True for instrument objects that can be connected to 
%                    instrument.
%   obj2mfile      - Convert instrument object to MATLAB code.
%
% Information and Help.
%   propinfo       - Return instrument object property information.
%   instrhelp      - Display instrument object function and property help.
%
% Instrument Control tools.
%   midedit        - Edit MATLAB instrument driver file.
%   midtest        - Launch GUI for testing MATLAB instrument driver.
%   tmtool         - Tool for browsing available instruments, configuring 
%                    instrument communication and communicating with 
%                    instrument.
%
% ICDevice properties.
%   ConfirmationFcn    - Callback function executed when the command written
%                        to instrument results in instrument being configured
%                        to different value.
%   DriverName         - Specifies the name of driver used to communicate 
%                        with instrument.
%   DriverType         - Specifies the type of driver used to communicate 
%                        with instrument.
%   InstrumentModel    - Model of the instrument.
%   Interface          - Specifies the interface used to communicate with instrument.
%   LogicalName        - Specifies an alias for the driver and interface used
%                        to communicate with an instrument.
%   Name               - Descriptive name of the device object.
%   ObjectVisibility   - Control access to an object by command-line users and
%                        GUIs.
%   RsrcName           - Specifies a description of the interface used to communicate
%                        with the instrument.
%   Status             - Indicates if the device object is connected to the
%                        instrument.
%   Tag                - Label for object.
%   Timeout            - Seconds to wait to receive data.
%   Type               - Object type.
%   UserData           - User data for object.
%
% See also ICDEVICE, INSTRHELP, INSTRUMENT/PROPINFO.
%

% MP 09-05-02
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.6 $  $Date: 2004/01/16 19:59:02 $
