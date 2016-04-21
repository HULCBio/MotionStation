function instrnotify(varargin)
%INSTRNOTIFY Define notification for instrument events.
%
%   INSTRNOTIFY('TYPE', CALLBACK) evaluates the MATLAB expression, CALLBACK,
%   in the MATLAB workspace when an event of type, TYPE, is generated. TYPE
%   can be ObjectCreated, ObjectDeleted or PropertyChangedPostSet. 
%   
%   If TYPE is ObjectCreated, CALLBACK is evaluated each time an instrument
%   object or a device group object is created. If TYPE is ObjectDeleted, 
%   CALLBACK is evaluated each time an instrument object or a device group
%   object is deleted. If TYPE is PropertyChangedPostSet, CALLBACK is 
%   evaluated each time an instrument object or device group object property 
%   is configured with SET. 
%   
%   CALLBACK can be:
%      - a function handle
%      - a string to be evaluated
%      - a cell array containing the function to evaluate in the first cell 
%        (function handle or name of function) and extra arguments to pass to 
%        the function in subsequent cells.
%
%   The CALLBACK function is invoked with:
%           function(obj, event, [arg1, arg2,...])
%
%   where obj is the instrument object or device group object generating 
%   the event. event is a structure containing information on the event
%   generated. If TYPE ObjectCreated or ObjectDeleted, event contains the
%   type of event. If TYPE is PropertyChangedPostSet, event contains the
%   type of event, the property being configured and the new property value.
%
%   INSTRNOTIFY({'Prop1', 'Prop2', ...}, 'TYPE', CALLBACK) evaluates the 
%   MATLAB expression, CALLBACK, in the MATLAB workspace when one of the
%   specified properties, Prop1, Prop2, are configured. TYPE can only be 
%   PropertyChangedPostSet.
%
%   INSTRNOTIFY(OBJ, 'TYPE', CALLBACK) evaluates the MATLAB expression, 
%   CALLBACK, in the MATLAB workspace when an event of type, TYPE, for 
%   object, OBJ, is generated. OBJ can be an array of instrument objects 
%   or an array of device group objects.
%
%   INSTRNOTIFY(OBJ, {'Prop1', 'Prop2', ...}, 'TYPE', CALLBACK) evaluates 
%   the MATLAB expression, CALLBACK, in the MATLAB workspace when one of the
%   specified properties, Prop1, Prop2 are configured on object, OBJ.
%
%   INSTRNOTIFY('TYPE', CALLBACK, '-remove') removes the specified CALLBACK
%   of type, TYPE.
%
%   INSTRNOTIFY(OBJ, 'TYPE', CALLBACK, '-remove') removes the specified 
%   CALLBACK of type, TYPE, for object, OBJ.
%
%   Note: PropertyChangedPostSet events are generated only when the property is 
%   configured to a different value than what the property is currently 
%   configured to. For example, if a GPIB object's Tag property is configured
%   to 'myobject', a PropertyChangedPostSet event will not be generated if the 
%   object's Tag property is set to 'myobject'. A PropertyChangedPostSet event 
%   will be generated if the object's Tag property is set to 'myGPIBObject'.
%
%   Note: If OBJ is specified and the callback TYPE is ObjectCreated, then
%   the callback will not be generated since OBJ has already been created.
%
%   Note, if Type is ObjectDeleted, the invalid object, OBJ, is not passed as
%   the first input argument to the CALLBACK function. An empty matrix is passed 
%   as the first input argument.
%
%   Example:
%       instrnotify('PropertyChangedPostSet', @instrcallback);
%       g = gpib('agilent', 0, 4);
%       set(g, 'Name', 'mygpib');
%       fopen(g);
%       fclose(g);
%       instrnotify('PropertyChangedPostSet', @instrcallback, '-remove');
%

%   MP 8-28-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 19:59:58 $

% Define error messages and error codes.
invalidTypeErrorMsg    = 'Invalid TYPE. TYPE must be ''PropertyChangedPostSet''.';
invalidTypeErrorCode   = 'icgroup:instrnotify:invalidArg';

invalidSyntaxErrorMsg  = 'Invalid syntax. Type ''instrhelp instrnotify'' for more information.';
invalidSyntaxErrorCode = 'icgroup:instrnotify:invalidSyntax'; 

switch nargin
case 0
    error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
case 1
    error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
case 2
    error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
case 3
    % Valid Syntax: instrnotify(obj, 'PropertyChangedPostSet', @instrcallback);
    if isa(varargin{1}, 'icgroup')
        % Ex. instrnotify(obj, 'PropertyChangedPostSet', @instrcallback);
        objects  = varargin{1};
        props    = {};
        type     = varargin{2};
        callback = varargin{3};
    else
        error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
    end
case 4
    % Valid Syntax: instrnotify(obj, {'Name', 'Status'}, 'PropertyChangedPostSet', @instrcallback);
    % Valid Syntax: instrnotify(obj, 'PropertyChangedPostSet', @instrcallback, '-remove');
    if ischar(varargin{4}) && strcmp(varargin{4}, '-remove')
        type     = varargin{2};
        callback = varargin{3};
          
        if ~any(strcmpi(type, {'PropertyChangedPostSet'}))
            error(invalidTypeErrorCode, invalidTypeErrorMsg);
        end
        
        if ~isa(varargin{1}, 'icgroup')
            error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
        end
        
        localRemoveNotification(callback, type);  
        return;
    else
        objects  = varargin{1};
        props    = varargin{2};
        type     = varargin{3};
        callback = varargin{4};
        
       % Do a little checking in case the wrong flag was passed. This
       % allows a better error message to be returned.
       if ~ischar(type)
            error(invalidSyntaxErrorCode, invalidSyntaxErrorMsg);
        end          

    end
otherwise
    error('icgroup:instrnotify:invalidSyntax', 'Too many input arguments.');
end    

% Error checking.
if ~ischar(type)
    error(invalidTypeErrorCode, invalidTypeErrorMsg);
end        

if ~any(strcmpi(type, {'PropertyChangedPostSet'}))
    error(invalidTypeErrorCode, invalidTypeErrorMsg);
end

% If properties are specified, TYPE must be PropertyChangedPostSet.
if ~isempty(props) && ~strcmpi(type, 'PropertyChangedPostSet')
    error('icgroup:instrnotify:invalidSyntax', 'Invalid TYPE. TYPE must be PropertyChangedPostSet.');
end

% If objects are specified, they must all be valid.
if ~isempty(objects) && ~all(isvalid(objects))
    error('icgroup:instrnotify:invalidSyntax', 'OBJ is an invalid device group object.')
end

% Verify that valid properties were specified.
if ~isempty(props)
    if ischar(props)
        props = {props};
    end    

    if ~iscellstr(props)
        error('icgroup:instrnotify:invalidSyntax', 'The property cell array must contain only strings.');
    end

    % Verify properties specified for device group objects.
    jobjects = igetfield(objects, 'jobject');
    for j = 1:length(objects)
        for i = 1:length(props)
            s = com.mathworks.toolbox.testmeas.device.util.PropertyHelp.isValidPropertyName(java(jobjects(j)), props{i});
            if isempty(s)
                error('instrument:instrnotify:InvalidProp', ['An invalid property was specified: ' props{i} '.']);                    
            else
                props{i} = s;
            end
        end
    end
end

% Verify that the callback is configured to a string, cell array or a function 
% handle.
if ~(localIsValidCallback(callback))
    rethrow(lasterror);
end

% Store the warning state.
warning('');
s = warning('backtrace', 'off');

% Add notification.
com.mathworks.toolbox.instrument.device.ICDevice.addNotification(type, localObjects2Vector(objects), props, callback);

% Restore the warning state.
warning(s)

% ------------------------------------------------------------------------------------
% Convert an array of objects to a java vector.
function out = localObjects2Vector(objects)

out = java.util.Vector;
jobjects = java(igetfield(objects, 'jobject'));
for i = 1:length(jobjects)
    out.addElement(jobjects(i));
end

% ------------------------------------------------------------------------------------
function out = localIsValidCallback(callback)

out = true;

% If a string, it is a valid callback.
if ischar(callback)
    return;
end

% If a function handle, it is a valid callback.
if isa(callback, 'function_handle')
    return;
end

% If it is not a cell, string or a function handle, error.
if ~iscell(callback)
    out = false;
    lasterr('Invalid CALLBACK. CALLBACK must be a string, a 1-by-n cell array or a function handle.');
    return;
end

% Verify cell array has the correct dimensions.
[row, col] = size(callback);
if (row ~= 1)
   out = false;
   lasterr('Invalid CALLBACK. CALLBACK must be a string, a 1-by-n cell array or a function handle.');
   return;
end
   
% Verify first element of cell array.   
firstElement = callback{1};
if ~(ischar(firstElement) || isa(firstElement, 'function_handle')) || isempty(firstElement)
   out = false; 
   lasterr('Invalid CALLBACK. The first element of the cell array must be either a string or a function handle.');
   return;
end

% ------------------------------------------------------------------------------------
function localRemoveNotification(callback, type)

try
    cbs = com.mathworks.toolbox.testmeas.device.util.MLNotifier.getNotificationCallbacks(type);
    for i = cbs.size:-1:1;
        val = cbs.elementAt(i-1);
        if isa(val, 'com.mathworks.toolbox.testmeas.device.PropertyListenerObject') || ...
            isa(val, 'com.mathworks.toolbox.testmeas.device.DeleteListenerObject')                
            val = val.getCallback;
        end
        
        if isequal(val, callback)
            com.mathworks.toolbox.testmeas.device.util.MLNotifier.removeNotification(type, i-1);
        end
    end
catch    
end

