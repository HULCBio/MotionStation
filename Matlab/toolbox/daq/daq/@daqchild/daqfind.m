function out = daqfind(varargin)
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
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:40:10 $

% There must be at least two input arguments.
% daqfind(obj, 'Property', Value) or daqfind(obj, struct)
if nargin < 2
   error('daq:daqfind:argcheck', 'Not enough input arguments.');
end

% Only one output argument can be specified.
if nargout > 1,
   error('daq:daqfind:argcheck', 'Too many output arguments.')
end

% Initialize variables.
out = {};
obj = varargin(1);
pvpair = varargin(2:end);

% Handle the case: daqfind('Channel', chan) by calling daq\daqfind which
% will find all the objects in the engine and determine if any of the
% object's Channel is chan.
if (rem(nargin,2) == 0)
   if isstr(obj{1}) & isa(pvpair{1}, 'daqchild');
      out = daqgate('privatedaqfind', obj{:}, pvpair{:});
      return
   end
elseif (rem(nargin,2) == 1)
   % Handle the case: daqfind({ai1 ai2 ai3}, 'Channel', chan) by
   % calling daq\daqfind which will loop through {ai1 ai2 ai3} and
   % determine if their Channel is chan.
   if iscell(obj{1})
      out = daqgate('privatedaqfind',obj{1}, pvpair{:});
      return;
   end
end

% Determine if the correct pvpairs were passed to DAQFIND.  This also
% splits up the cell array of pvpairs.
[errflag, pvpair] = localCheckPVPair(pvpair);
if errflag
   error('daq:daqfind:invalidpvpair', lasterr);
end

% Determine if obj is valid.
for i = 1:length(obj)
   if ~isvalid(obj{i})
      error('daq:daqfind:invalidobject', 'Data acquisition object OBJ is an invalid object.');
   end
end

for i = 1:length(obj)
   [child, errflag] = localChildProp(obj{i}, pvpair{:});
   switch errflag
   case 0
      if ~isempty(child)
         out = [out; child];
      end
   case 1
      error('daq:daqfind:unexpected', lasterr);
   case 2
   end
end

% *****************************************************************
% Determine if the supplied property is a channel or line property. 
function [out, errflag] = localChildProp(child, varargin)

% Initialize variables.
errflag = 0;
out = [];
pvpair = varargin;

% Get the handles.
handles = struct(child);
handles = handles.handle;

% Loop through the child objects and check the specified properties.
for i = 1:length(child)
   for j = 1:2:length(pvpair)
      try
         % Get the property value.
         propvalue = daqmex(handles(i), 'get', pvpair{j});
         
         % Get property information for enumerated list check.
         daqPropInfo = daqmex(handles(i), 'propinfo', pvpair{j});
      catch
         errflag = 2;
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
            temp = {child(i)};
         else
            temp = [];
            break;
         end
      otherwise
         if isequal(propvalue, pvpair{j+1})
            temp =  {child(i)};
         else
            temp = [];
            break;
         end
      end
   end
   out = [out temp];
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
   elseif iscell(pvpair{i}) & iscell(pvpair{i+1}) 
      if ~isequal(size(pvpair{i}), size(pvpair{i+1})) | min(size(pvpair{i})) ~= 1
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
   elseif (iscell(pvpair{i}) & ~iscell(pvpair{i+1})) | ...
         (~iscell(pvpair{i}) & iscell(pvpair{i+1}))
      errflag = 1;
      lasterr('Invalid parameter/value pair arguments.');
      return;
      %elseif isstr(pvpair{i})
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
new_obj = {};

% Determine if the first object is a daqdevice or daqchild object.
% If so, add it to the new_obj cell array otherwise error.
if isa(obj{1}, 'daqchild')
   temp = struct(obj{1});
   handle = [temp.handle];
   new_obj = obj(1);
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
   if isa(temp_obj, 'daqchild')
      temp = struct(temp_obj);
      for j = 1:length(temp.handle)
         index = find(temp.handle(j) == handle);
         if isempty(index) 
            new_obj = [new_obj; {temp_obj(j)}];
            handle = [handle; temp.handle(j)];
         end
      end
   else
      errflag = 1;
      lasterr('Invalid input argument passed to DAQFIND.');
      return;
   end
end
     
     
   
   
   