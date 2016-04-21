function output=propinfo(varargin)
%PROPINFO Return property information for data acquisition objects.
%
%    OUT = PROPINFO(OBJ) returns a structure array, OUT, for all properties
%    of data acquisition object, OBJ.  OUT contains a field for each 
%    property of OBJ.  Each property field contains the following fields:
%
%         Type            - the property data type: 
%                           {'callback', 'double', 'string', 
%                            'Channel', 'Line', 'any' }
%         Constraint      - constraints on property values:
%                           {'Bounded', 'Enum', 'None', 'callback'}
%         ConstraintValue - enum list or range of valid values.
%         DefaultValue    - the default value for the property.
%         ReadOnly        - 1 if the property is read-only, 0 if not.
%         ReadOnlyRunning - 1 if the property cannot be set while 
%                           object is running, 0 if it can be set.
%         DeviceSpecific  - 1 if the property is device specific, 
%                           0 if the property is not device specific.
%
%    OUT = PROPINFO(OBJ, 'PROPERTY') returns a structure array, OUT, for
%    PROPERTY.
%
%    If PROPERTY is a cell array of strings, a cell array of structures
%    is returned for each property.
%
%    Example:
%      ai = analoginput('winsound');
%      out = propinfo(ai);
%      out1 = propinfo(ai, 'SampleRate');
%
%    See also DAQHELP.
%

%   GBL 7-16-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:31 $

if nargout > 1,
   error('daq:propinfo:argcheck', 'Too many output arguments.')
end

% Determine if an invalid object was passed.
if ~isvalid(varargin{1})
   error('daq:propinfo:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

switch nargin
case 0,
   error('daq:propinfo:invalidobject', 'A valid data acquisition object must be passed to PROPINFO.')
case 1,
   if ~( isa(varargin{1},'daqdevice') || isa(varargin{1},'daqchild') )
      error('daq:propinfo:argcheck', 'The first input argument OBJ must be a data acquisition object.')
   end   
   try
      output = daqmex(varargin{1},'propinfo');
   catch
      error('daq:propinfo:unexpected', lasterr)
   end   
case 2,
   if ~( isa(varargin{1},'daqdevice') || isa(varargin{1},'daqchild') )
      error('daq:propinfo:argcheck', 'The first input argument OBJ must be a data acquisition object.')
   end   
   try
      if iscellstr(varargin{2}),
         for i=1:length(varargin{2})
            output{i} = daqmex(varargin{1},'propinfo',varargin{2}{i});
         end
      elseif ischar(varargin{2}),
         output = daqmex(varargin{1},'propinfo',varargin{2});
      else
         error('daq:propinfo:invalidproperty','PROPERTY must be a single string or a cell array of strings.')
      end
   catch
      error('daq:propinfo:unexpected', lasterr)
   end  
otherwise,
   error('daq:propinfo:argcheck', 'Too many inputs passed to PROPINFO.')
end

   
   