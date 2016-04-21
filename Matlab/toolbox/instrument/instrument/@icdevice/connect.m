function connect(varargin)
%CONNECT Connect device object to instrument.
%
%   CONNECT(OBJ) connects the device object, OBJ, to the instrument. OBJ
%   can be an array of device objects.
%
%   If OBJ was successfully connected to the instrument, OBJ's Status property 
%   is configured to open, otherwise the Status property remains configured to
%   closed. 
%
%   If OBJ is an array of device objects and one of the objects cannot be 
%   connected to the instrument, the remaining objects in the array will 
%   be connected to the instrument and a warning will be displayed.
%
%   CONNECT(OBJ, 'UPDATE') connects the device object, OBJ, to the instrument. 
%   UPDATE can be either 'object' or 'instrument'. If UPDATE is 'object', then
%   the object is updated to reflect the state of the instrument. If UPDATE 
%   is 'instrument' then the instrument is updated to reflect the state of 
%   the object, i.e. all property values defined by the object are sent to 
%   the instrument on open. By default, UPDATE is 'object'.
%
%   Example:
%       % Construct a device object that has specific information about a 
%       % Tektronix TDS 210 instrument.
%       g = gpib('ni', 0, 2);
%       d = icdevice('tektronix_tds210', g);      
%
%       % Connect to the instrument
%       connect(d);
%
%       % List the oscilloscope settings that can be configured.
%       props = set(d);
%
%       % Get the current configuration of the oscilloscope.
%       values = get(d);
%
%       % Disconnect from the instrument and cleanup.
%       disconnect(d);
%       delete([d g]);
%
%   See also ICDEVICE/DISCONNECT, INSTRUMENT/DELETE, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2004/03/24 20:39:56 $

% Parse the input.
switch (nargin)
case 0
    errorID = 'icdevice:connect:tooFewArgs';
    error(errorID, instrgate('privateMessageLookup', errorID));
case 1
    obj = varargin{1};
    type = 'object';
case 2
    obj = varargin{1};
    type = varargin{2};
otherwise
    errorID = 'icdevice:connect:tooManyArgs';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Error checking on OBJ.
if ~isa(obj, 'instrument')
    errorID = 'icdevice:connect:invalidOBJ';
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Error checking on Update flag.
errorID = 'icdevice:connect:invalidFlag';
if ~isa(type, 'char')
    error(errorID, instrgate('privateMessageLookup', errorID));
end

if ~any(strcmpi(type, {'object', 'instrument'}))
    error(errorID, instrgate('privateMessageLookup', errorID));
end

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call fopen on each java object.  Keep looping even 
% if one of the objects could not be opened.
for i=1:length(jobject)

    wasOpen = jobject(i).getStatus;
    
    try
        open(jobject(i), type);

        % Execute initialization code.
        try
            code = char(getConnectInitializationCode(jobject(i)));
            localEvaluateCode(code, jobject(i));
        catch
            close(jobject(i));
            errorOccurred = true;
            lasterr(sprintf('An error occurred while executing the driver connect code.\n%s', lasterr));
        end
    catch
        errorOccurred = true;
        if (jobject(i).getStatus == 1 && ~wasOpen)
            close(jobject(i));
        end
    end
end

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
		lasterr([lasterr sprintf('\n') 'If this error is not an instrument error, use MIDEDIT to inspect the driver.'], 'instrument:connect:opfailed');
        rethrow(lasterror);
    else
        warnState = warning('backtrace', 'off');
        warnID = 'icdevice:connect:invalid';
        warning(warnID, instrgate('privateMessageLookup', warnID));
        warning(warnState);
    end
end

% -----------------------------------------------------------------
% Evaluate the initialization code.
function localEvaluateCode(fcn, jobj)

obj = icdevice(jobj);

% Evaluate the code.
instrgate('privateEvaluateCode', obj, fcn);

