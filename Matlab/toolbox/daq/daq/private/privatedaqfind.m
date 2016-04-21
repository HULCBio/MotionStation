function output = privatedaqfind(varargin)
%PRIVATEDAQFIND Find data acquisition objects with specified property values.
%
%    OUT = PRIVATEDAQFIND returns an array, OUT, of any analog input, analog  
%    output or digital I/O objects currently existing in the data acquisition
%    engine.
%
%    OUT = PRIVATEDAQFIND('P1', V1, 'P2', V2,...) returns a cell array, OUT, of  
%    objects, channels or lines whose property values match those passed 
%    as PV pairs, P1, V1, P2, V2,... The PV pairs can be specified as a 
%    cell array. 
%
%    OUT = PRIVATEDAQFIND(S) returns a cell array, OUT, of objects, channels or
%    lines whose property values match those defined in structure S whose 
%    field names are object property names and the field values are the
%    requested property values.
%   
%    OUT = PRIVATEDAQFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%    matching PV pairs to the objects listed in OBJ and the channels or
%    lines contained by them.  OBJ can be an array or cell array of objects.
%
%    Note that it is permissible to use PV string pairs, structures, 
%    and PV cell array pairs in the same call to PRIVATEDAQFIND.
%
%    In any given call to PRIVATEDAQFIND, only device object properties or 
%    channel/line properties can be specified.
%
%    When a property value is specified, it must use the same format as
%    GET returns.  For example, if GET returns the ChannelName as 'Left',
%    PRIVATEDAQFIND will not find an object with a ChannelName property value of
%    'left'.  However, properties which have an enumerated list data type,
%    will not be case sensitive when searching for property values.  For
%    example, PRIVATEDAQFIND will find an object with a Running property value
%    of 'On' or 'on'.  The data type of a property can be determined with
%    PROPINFO's Constraint field.
%
%    Example:
%      ai = analoginput('winsound');
%      addchannel(ai, [1 2], {'Left', 'Right'});
%      out = daqfind('Units', 'Volts')
%      out = daqfind({'ChannelName', 'Units'}, {'Left', 'Volts'})
%
%    See also PROPINFO, DAQDEVICE/GET.
%

%   MP 4-10-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.4 $  $Date: 2003/08/29 04:42:27 $

if nargout > 1,
   error('daq:daqfind:argcheck', 'Too many output arguments.')
end

% Initialize variables.
output = {};

% Parse the input.
switch nargin
case 0
   % Find all existing DAQDEVICE objects in the DAQ engine.
   try
      obj = daqmex('find');
   catch
      error('daq:daqfind:unexpected', lasterr)
   end  
   if isempty(obj)
      output = [];
   else
      output = obj{1};
      for i = 2:length(obj)
         output = [output obj{i}];
      end
   end
   return;
case 1
   % This is valid only if input argument is a structure.
   if ~isstruct(varargin{1})
      error('daq:daqfind:argcheck', 'Invalid number of input arguments.');
   else
      try
      	obj = daqmex('find');
      catch
      	error('daq:daqfind:unexpected', lasterr)
      end
      pvpair = varargin;
   end
   % If obj is empty return.
   if isempty(obj)
      return;
   end
otherwise
   % Initialize the objects to search in and the PV pairs.
   obj = varargin{1};
   % A cell array of Data Acquisition objects is the first input argument.
   if iscell(obj) && ~iscellstr(obj)
      [obj, errflag] = localUniqueHandle(obj);
      if errflag
         error('daq:daqfind:unexpected', lasterr);
      end
      pvpair = varargin(2:end);
   elseif isempty(obj) 
      % daqfind(ai.Channel, 'Units', 'Volts')
      output = {};
      return;
   elseif ~(isa(obj, 'daqdevice') || isa(obj, 'daqchild'))
      % Only PV pairs were specified as input.  Find all existing DAQDEVICE  
      % objects in the DAQ engine.  
   	try
      	obj = daqmex('find');
   	catch
      	error('daq:daqfind:unexpected', lasterr)
      end
      pvpair = varargin;
      % If no Data Acquisition objects exist return.
      if isempty(obj)
         return;
      end
   end
end

% Loop through the objects and call daqfind with the objects and PV pairs.
for i = 1:length(obj)
   try
      validobj = [];
      validobj = daqfind(obj{i}, pvpair{:});
   catch
      if isempty(output) && i == length(obj)
         error('daq:daqfind:invalidproperty', 'Invalid property name(s) specified as input.');
      end
   end
   
   % If the object has the correct property value add the object to the
   % output variable, output.
   if ~isempty(validobj)
      output = [output; validobj];
   end
end

% If the output is a daqchild, it is possible that the same object will be
% returned more than once - if a cell array of parent and channel objects
% are passed as the input.
if ~isempty(output) && isa(output{1}, 'daqchild')
   output = localUniqueHandle(output);
end


% *******************************************************************
% Convert the cell array of objects to a unique cell of object.
function [new_obj, errflag] = localUniqueHandle(obj)

% Initialize variables.
errflag = 0;
new_obj = {};

% Determine if the first object is a daqdevice or daqchild object.
% If so, add it to the new_obj cell array otherwise error.
if (isa(obj{1}, 'daqdevice') || isa(obj{1}, 'daqchild'))
   temp = struct(obj{1});
   handle = [temp.handle];
   new_obj = obj(1);
   if ~all(isvalid(obj{1}))
      errflag = 1;
      lasterr('Data acquisition object OBJ is an invalid object.')
      return;
   end
else
   errflag = 1;
   lasterr('Invalid input argument passed to DAQFIND.');
   return;
end

% Loop through the remaining objects and determine if their handle
% is already in the handle array.  If it isn't add the object to the
% new_obj cell array and it's handle to the handle vector.
for i = 2:length(obj)
   temp_obj = obj{i};
   if isa(temp_obj, 'daqdevice')
      if ~all(isvalid(obj{i}))
         errflag = 1;
         lasterr('Data acquisition object OBJ is an invalid object.')
         return;
      end
      temp = struct(temp_obj);
      index = find(temp.handle == handle);
      if isempty(index) 
         new_obj = [new_obj; {temp_obj}];
         handle = [handle; temp.handle];
      end
   elseif isa(temp_obj, 'daqchild')
      if ~all(isvalid(obj{i}))
         errflag = 1;
         lasterr('Data acquisition object OBJ is an invalid object.')
         return;
      end
      keepindex = [];
      temp = struct(temp_obj);
      for j = 1:length(temp.handle)
         index = find(temp.handle(j) == handle);
         if isempty(index) 
            keepindex = [keepindex j];
            handle = [handle; temp.handle(j)];
         end
      end
      if ~isempty(keepindex)
         new_obj = [new_obj; {temp_obj(keepindex)}];
      end
   else
      errflag = 1;
      lasterr('Invalid input argument passed to DAQFIND.');
      return;
   end
end






  