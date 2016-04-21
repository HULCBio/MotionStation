function obj = serial(varargin)
%SERIAL Construct serial port object.
%
%   S = SERIAL('PORT') constructs a serial port object associated with 
%   port, PORT. If PORT does not exist or is in use you will not be able 
%   to connect the serial port object to the instrument.
%
%   In order to communicate with the instrument, the object must be connected
%   to the serial port with the FOPEN function. 
%
%   When the serial port object is constructed, the object's Status property
%   is closed. Once the object is connected to the serial port with the
%   FOPEN function, the Status property is configured to open. Only one serial
%   port object may be connected to a serial port at a time.
%
%   S = SERIAL('PORT','P1',V1,'P2',V2,...) constructs a serial port object 
%   associated with port, PORT, and with the specified property values. If 
%   an invalid property name or property value is specified the object will
%   not be created.
%
%   Note that the property value pairs can be in any format supported by
%   the SET function, i.e., param-value string pairs, structures, and
%   param-value cell array pairs.  
%
%   At any time you can view a complete listing of serial port functions 
%   and properties with the INSTRHELP function, i.e., instrhelp serial.
%
%   Example:
%       % To construct a serial port object:
%         s1 = serial('COM1');
%         s2 = serial('COM2', 'BaudRate', 1200);
%
%       % To connect the serial port object to the serial port:
%         fopen(s1)
%         fopen(s2)	
%
%       % To query the device.
%         fprintf(s1, '*IDN?');
%         idn = fscanf(s1);
%
%       % To disconnect the serial port object from the serial port.
%         fclose(s1); 
%         fclose(s2);
%
%   See also ICINTERFACE/FOPEN, INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.4 $  $Date: 2004/01/16 20:01:28 $

% Create the parent class.
try
    instr = icinterface('serial');
catch
    error('instrument:serial:nojvm', 'Serial port objects require JAVA support.');
end

% Error if on the wrong platform.
if ~(strcmp(computer, 'PCWIN') || strcmp(computer, 'SOL2') || strcmp(computer, 'GLNX86'))
    error('instrument:serial:invalidPlatform', 'The serial port object is supported on the Windows, Solaris and Linux platforms only.');
end

try
    instrPackage = findpackage('instrument');
catch
end

if isempty(instrPackage)
    instrPackage = schema.package('instrument');
end

switch (nargin)
case 0
    error('instrument:serial:invalidSyntax', 'The PORT must be specified.');
case 1
    if (strcmp(class(varargin{1}), 'char'))
        % Ex. s = serial('COM1')
        % Call the java constructor and store the java object in the
        % serial object.
        if isempty(varargin{1})
            error('instrument:serial:invalidPORT', 'The PORT must be a non-empty string.');
        end
        try
            obj.jobject = handle(com.mathworks.toolbox.instrument.SerialComm(varargin{1}));
            connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
        catch
            error('instrument:serial:cannotCreate', lasterr);
        end
        obj.type = 'serial';
        obj.constructor = 'serial';
        
        % Assign the class tag.
        obj = class(obj, 'serial', instr);
    elseif strcmp(class(varargin{1}), 'serial')
        obj = varargin{1};
    elseif isa(varargin{1}, 'com.mathworks.toolbox.instrument.SerialComm')
        obj.jobject = handle(varargin{1});
        obj.type = 'serial';
        obj.constructor = 'serial';
        obj = class(obj, 'serial', instr);
    elseif isa(varargin{1}, 'javahandle.com.mathworks.toolbox.instrument.SerialComm')
        obj.jobject = varargin{1};
        obj.type = 'serial';
        obj.constructor = 'serial';
        obj = class(obj, 'serial', instr);
    elseif ishandle(varargin{1})
       % True if loading an array of objects and the first is a GPIB object. 
       if isa(varargin{1}(1), 'javahandle.com.mathworks.toolbox.instrument.SerialComm') 
           obj.jobject = varargin{1}; 
           obj.type = 'serial';
           obj.constructor = 'serial';
           obj = class(obj, 'serial', instr);
       else
           error('instrument:serial:invalidPORT', 'Invalid PORT specified.'); 
       end
    else      
        error('instrument:serial:invalidPORT', 'Invalid PORT specified.');         
    end	
otherwise
    % Ex. s = serial('COM1', 'BaudRate', 4800);
    try
        obj.jobject = handle(com.mathworks.toolbox.instrument.SerialComm(varargin{1}));
        connect(obj.jobject, instrPackage.DefaultDatabase, 'up');
    catch
        error('instrument:serial:cannotCreate', lasterr);
    end
    obj.type = 'serial';
    obj.constructor = 'serial';
    obj = class(obj, 'serial', instr);
    
    % Try setting the object properties.
    try
        set(obj, varargin{2:end});
    catch
        delete(obj); 
        localFixError	
        rethrow(lasterror);
    end
end	    

% Pass the OOPs object to java. Used for callbacks.
obj.jobject(1).setMATLABObject(obj);

% *******************************************************************
% Fix the error message.
function localFixError

% Initialize variables.
[errmsg, id] = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
    errmsg = errmsg(1:end-1);
end

lasterr(errmsg, id);

