function actual = setverify(obj, prop, value)
%SETVERIFY Set and return value of specified property.
%
%    SETVERIFY(OBJ, 'PropertyName', PropertyValue) sets the value, PropertyValue,
%    of the specified property, PropertyName, for data acquisition object, OBJ. 
%    OBJ can be a device object or a channel/line.
%
%    ACTUAL = SETVERIFY(OBJ, 'PropertyName', PropertyValue) sets the value,
%    PropertyValue, of the specified property, PropertyName, for data acquisition
%    object, OBJ and returns the actual value, ACTUAL, the property was set to.
%
%    This function is useful when setting the SampleRate, InputRange and
%    OutputRange properties since these properties can only be set to values 
%    accepted by the hardware.
%
%    See also DAQHELP, DAQDEVICE/SET, DAQDEVICE/GET, PROPINFO.
%

%    MP 8-03-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.7.2.4 $  $Date: 2003/08/29 04:40:35 $

ArgChkMsg = nargchk(3,3,nargin);
if ~isempty(ArgChkMsg)
    error('daq:setverify:argcheck', ArgChkMsg);
end

if nargout > 1,
   error('daq:setverify:argcheck', 'Too many output arguments.')
end

% Determine if an invalid object was passed.
if ~all(isvalid(obj))
   error('daq:setverify:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Set the property and return the actual property value.
try
   set(obj, prop, value);
   actual = get(obj, prop);
catch
   localCheckError;
   error('daq:setverify:unexpected', lasterr);
end

% *************************************************************************
% Remove any extra carriage returns.
function localCheckError

% Initialize variables.
errmsg = lasterr;

% Remove the trailing carriage returns from errmsg.
while errmsg(end) == sprintf('\n')
   errmsg = errmsg(1:end-1);
end

lasterr(errmsg);