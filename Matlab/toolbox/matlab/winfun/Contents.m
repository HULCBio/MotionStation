% Windows Operating System Interface Files (COM/DDE)
%
% COM Automation Client Functions.
%   actxcontrol         - Create an ActiveX control.
%   actxserver          - Create an ActiveX server.
%   eventlisteners      - Lists all events that are registered.
%   isevent             - True if event of object.
%   registerevent       - Registers events for a specified control at runtime.
%   unregisterallevents - Unregister all events for a specified control at runtime.
%   unregisterevent     - Unregister events for a specified control at runtime.   
%   iscom               - True if input handle is a COM/ActiveX object.
%   isinterface         - True if input handle is a COM Interface.
%   COM/set             - Set a property value on a COM object.
%   COM/get             - Get COM object properties.
%   COM/invoke          - Invoke method on object or interface, or display methods.
%   COM/events          - Return list of events the COM object can trigger.
%   COM/interfaces      - List custom interfaces supported by a COM server.
%   COM/addproperty     - Add custom property to an object.
%   COM/deleteproperty  - Remove custom property from object.
%   COM/delete          - Delete a COM object.
%   COM/release         - Release a COM interface.
%   COM/move            - Move and/or resize an ActiveX control in its parent window.
%   COM/propedit        - Invoke the property page.
%   COM/save            - Serialize a COM object to a file.
%   COM/load            - Initialize a COM object from a file.
%
% COM Sample code.
%   mwsamp   - Sample Activex control creation.
%   sampev   - Sample event handler for ActiveX server.
%
% DDE Client Functions.
%   ddeadv   - Set up advisory link.
%   ddeexec  - Send string for execution.
%   ddeinit  - Initiate DDE conversation.
%   ddepoke  - Send data to application.
%   ddereq   - Request data from application.
%   ddeterm  - Terminate DDE conversation.
%   ddeunadv - Release advisory link.
%
% Other
%   winopen     - Open a file using the appropriate Windows command.
%   winqueryreg - Get information from the Windows registry.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14.4.3 $  $Date: 2004/01/02 18:06:12 $

