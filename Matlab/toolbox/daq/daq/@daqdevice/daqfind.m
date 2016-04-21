function outobj = daqfind(varargin)
%DAQFIND Find data acquisition objects with specified property values.
%
%    OUT = DAQFIND returns an array, OUT, of any analog input, analog  
%    output or digital I/O objects currently existing in the data acquisition
%    engine.
%
%    OUT = DAQFIND('P1', V1, 'P2', V2,...) returns a cell array, OUT, of  
%    objects, channels or lines whose property values match those passed 
%    as PV pairs, P1, V1, P2, V2,... The PV pairs can be specified as a 
%    cell array. 
%
%    OUT = DAQFIND(S) returns a cell array, OUT, of objects, channels or
%    lines whose property values match those defined in structure S whose 
%    field names are object property names and the field values are the
%    requested property values.
%   
%    OUT = DAQFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%    matching PV pairs to the objects listed in OBJ and the channels or
%    lines contained by them.  OBJ can be an array or cell array of objects.
%
%    Note that it is permissible to use PV string pairs, structures, 
%    and PV cell array pairs in the same call to DAQFIND.
%
%    In any given call to DAQFIND, only device object properties or 
%    channel/line properties can be specified.  
%
%    When a property value is specified, it must use the same format as
%    GET returns.  For example, if GET returns the ChannelName as 'Left',
%    DAQFIND will not find an object with a ChannelName property value of
%    'left'.  However, properties which have an enumerated list data type,
%    will not be case sensitive when searching for property values.  For
%    example, DAQFIND will find an object with a Running property value
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

%    MP 4-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.13.2.4 $  $Date: 2003/08/29 04:41:05 $

% There must be at least two input arguments.
% daqfind(obj, 'Property', Value) or daqfind(obj, struct)
if nargin < 2
   error('daq:daqfind:argcheck', 'Not enough input arguments.');
end

% Only one output argument can be specified.
if nargout > 1,
   error('daq:daqfind:argcheck', 'Too many output arguments.')
end

% Parse the input.
obj = varargin{1};
pvpair = varargin(2:end);

% Handle the case: daqfind('Parent', ai) by calling daq\daqfind which
% will find all the objects in the engine and determine if any of the
% object's Parent is ai.
if (rem(nargin,2) == 0)
   if ischar(obj) && isa(pvpair{1}, 'daqdevice');
      outobj = daqgate('privatedaqfind', obj, pvpair{:});
      return
   end 
elseif (rem(nargin,2) == 1)
   % Handle the case: daqfind({chan1 chan2 chan3}, 'Parent', ai)
   % by calling daq\daqfind which will loop through {chan1 chan2 chan3}
   % and determine if their parent is ai.
   if iscell(obj)
      outobj = daqgate('privatedaqfind',obj, pvpair{:});
      return;
   end
end

% Determine if the input is valid.
if ~isvalid(obj)
   error('daq:daqfind:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Determine if the correct pvpairs were passed to DAQFIND.  This also
% splits up the cell array of pvpairs.
[errflag, pvpair] = localCheckPVPair(pvpair);
if errflag
   error('daq:daqfind:unexpected', lasterr);
end

% Determine that a unique list of objects was passed.
if length(obj) > 1
   [obj, errflag] = localUniqueHandle(obj);
   if errflag
      error('daq:daqfind:unexpected', lasterr);
   end
end

% Determine if the object has the specified property values.
% First assume that the property specified is a device object property.
% If that fails get the child object(s) - Channel or Line - and check
% the property against it.  
outobj = {};
out = {};

% Errflag = 0 - no error occurred - concatenate objects in cell array.
% Errflag = 1 - an error occurred while finding the child, etc.
% Errflag = 2 - an error occurred while getting property information.
%               is ignored because of the case:
%               daqfind([ai ao], 'RepeatOutput', 0)
% Errflag = 3 - device and child properties were mixed.

handles = daqgetfield(obj, 'handle');
for j = 1:length(obj)
   [parent, errflag, deviceprop] = localParentProp(handles(j), pvpair{:});
   switch errflag
   case 0
      if ~isempty(parent)
         parent = {get(obj, j)};
         out = [out; parent];
      end
   case 2
      % If one of the properties was a device property need to error.
      if deviceprop && j == length(obj) && isempty(out)
         outobj = {};
         return;
      elseif deviceprop && j == length(obj)
         outobj = out;
         return;
      end
         
      % Check if the properties are channel properties. 
      temp_obj = get(obj,j);
      [child, errflag] = localChildProp(temp_obj, pvpair{:});
      switch errflag
      case 0
         if ~isempty(child) 
            out = [out; {child}];
         end
      case 1
         error('daq:daqfind:unexpected', lasterr);
      case 2
      case 3
         outobj = {};
         return;
      end
   end
end

if ~isempty(out);
   outobj = out;
end

% *****************************************************************
% Determine if the supplied property is a parent property. 
function [out, errflag, deviceprop] = localParentProp(obj, varargin)

% Initialize variables.
errflag = 0;
out = [];
deviceprop = 0;
pvpair = varargin;

for i = 1:2:length(pvpair)
   try
      % Get the property value.
      value = daqmex(obj, 'get', pvpair{i});
      
      % Get property information for enumerated list check.
      daqPropInfo = daqmex(obj, 'propinfo', pvpair{i});
      
      % At least one device property is contained in pvpair.  
      deviceprop = 1;
      
      % If the property contains an enumerated list of property values,
      % the comparison between the specified value and the actual value
      % is case insensitive - Running, LoggingMode, etc.  If the property
      % does not contain an enumerated list of property values, the comparison
      % is case sensitive.
      switch daqPropInfo.Constraint
      case 'Enum'
         if isequal(lower(value), lower(pvpair{i+1})) && i == (length(pvpair)-1)
            out = [out; {obj}];
         elseif ~isequal(lower(value), lower(pvpair{i+1}))
            return;
         end
      otherwise
         if isequal(value, pvpair{i+1}) && i == (length(pvpair)-1)
            out = [out; {obj}];
         elseif ~isequal(value, pvpair{i+1})
            if strncmp(lower(pvpair{i}), 'type', length(pvpair{i}))
               deviceprop = 0;
               errflag = 2;
            end
            return;
         end
      end
   catch
      % Need to check if it is a channel property.
      errflag = 2;
      return;
   end
end
      
% *****************************************************************
% Determine if the supplied property is a channel or line property. 
function [out, errflag] = localChildProp(obj, varargin)

% Initialize variables.
errflag = 0;
out = [];
pvpair = varargin;

% Determine child type - either channel or line.
info = daqgetfield(obj, 'info');
childtype = info.child;

% Get the child object.
try
   child = daqmex(obj, 'get', childtype);
catch
   errflag = 1;
   return;
end

% Get the handles of the child.
if ~isempty(child)
   structchild = struct(child);
   handle = structchild.handle;
else
   return;
end

% Loop through the child objects and check the specified properties.
for i = 1:length(child)
   for j = 1:2:length(pvpair)
      try
         propvalue = daqmex(handle(i), 'get', pvpair{j});  
         
         % Get property information for enumerated list check.
         daqPropInfo = daqmex(handle(i), 'propinfo', pvpair{j});
      catch
         try
            % Property is a device property, need to error appropriately.
            propvalue = daqmex(obj, 'get', pvpair{j});
            errflag = 3;
         catch
            % Property is an invalid property, need to do nothing.
            errflag = 2;
         end
         return;
      end
      
      % If the property contains an enumerated list of property values,
      % the comparison between the specified value and the actual value
      % is case insensitive - Running, LoggingMode, etc.  If the property
      % does not contain an enumerated list of property values, the comparison
      % is case sensitive.
      switch daqPropInfo.Constraint
      case 'Enum'
         if isequal(lower(propvalue), lower(pvpair{j+1}))
            temp = daqmex(obj, 'get', childtype, i);
         else
            temp = [];
            break;
         end
      otherwise
         if isequal(propvalue, pvpair{j+1})
            temp =  daqmex(obj, 'get', childtype, i);
         else
            temp = [];
            break;
         end
      end
   end
   out = [out; temp];
end

% *************************************************************
% Determine if a valid PV pair was passed to DAQFIND
function [errflag, temp_pvpair] = localCheckPVPair(pvpair)

% Initialize variables
errflag = 0;
temp_pvpair = {};
i = 1;

% Loop through the pvpairs (could be cells, strings or structures) and 
% construct a cell of pv pairs.
while i <= length(pvpair)
   if isstruct(pvpair{i})
      % If the pvpair is a struct, pull out the fieldnames and values. 
      name = fieldnames(pvpair{i});
      value = struct2cell(pvpair{i});
      temp = [name value]';
      temp_pvpair = {temp_pvpair{:} temp{:}};
      i = i+1;
   elseif iscell(pvpair{i}) && iscell(pvpair{i+1}) 
      if ~isequal(size(pvpair{i}), size(pvpair{i+1})) || min(size(pvpair{i})) ~= 1
         errflag = 1;
         lasterr('Value cell array dimension must match name cell array dimension.');
         return;
      elseif length(pvpair{i}) == 1
         temp_pvpair = {temp_pvpair{:} pvpair{i}{:} pvpair{i+1}{:}};
      else
         temp = reshape([pvpair{i:i+1}],length(pvpair{i}),2)';
         temp_pvpair = {temp_pvpair{:} temp{:}};
      end
      i = i+2;
   elseif (iscell(pvpair{i}) && ~iscell(pvpair{i+1})) || ...
         (~iscell(pvpair{i}) && iscell(pvpair{i+1}))
      errflag = 1;
      lasterr('Invalid parameter/value pair arguments.');
      return;
   else
      % Add the PV pairs to the output list.   
      temp_pvpair = {temp_pvpair{:} pvpair{i} pvpair{i+1}};
      i = i+2;
   end
end

% *******************************************************************
% Convert the cell array of objects to a unique cell of object.
function [new_obj, errflag] = localUniqueHandle(obj)

% Initialize variables.
errflag = 0;
new_obj = [];

% Determine if the first object is a daqdevice object.
% If so, add it to the new_obj array otherwise error.
new_obj = get(obj, 1);
if isa(new_obj, 'daqdevice') 
   handle = daqgetfield(new_obj, 'handle');
else
   errflag = 1;
   lasterr('Invalid input argument passed to DAQFIND.');
   return;
end

% Loop through the remaining objects and determine if their handle
% is already in the handle array.  If it isn't add the object to the
% new_obj cell array and it's handle to the handle vector.
for i = 2:length(obj)
   temp_obj = get(obj, i);
   if isa(temp_obj, 'daqdevice')
      temp_handle = daqgetfield(temp_obj, 'handle');
      index = find(temp_handle == handle);
      if isempty(index) 
         new_obj = [new_obj; temp_obj];
         handle = [handle; temp_handle];
      end
   else
      errflag = 1;
      lasterr('Invalid input argument passed to DAQFIND.');
      return;
   end
end


