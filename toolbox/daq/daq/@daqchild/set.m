function outputStruct = set(obj, varargin)
%SET Set data acquisition object properties.
%
%    SET(OBJ, 'PropertyName', PropertyValue) sets the value, PropertyValue,
%    of the specified property, PropertyName, for data acquisition object OBJ.
%
%    OBJ can be a vector of data acquisition objects, in which case SET sets the
%    property values for all the data acquisition objects specified.
%
%    SET(OBJ,S) where S is a structure whose field names are object property 
%    names, sets the properties named in each field name with the values contained
%    in the structure.
%
%    SET(OBJ,PN,PV) sets the properties specified in the cell array of strings,
%    PN, to the corresponding values in the cell array PV for all objects 
%    specified in OBJ.  The cell array PN must be a vector, but the cell array 
%    PV can be M-by-N where M is equal to length(OBJ) and N is equal to length(PN) 
%    so that each object will be updated with a different set of values for the
%    list of property names contained in PN.
%
%    SET(OBJ,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
%    sets multiple property values with a single statement.  Note that it
%    is permissible to use property/value string pairs, structures, and
%    property/value cell array pairs in the same call to SET.
%
%    SET(OBJ, 'PropertyName') 
%    PROP = SET(OBJ,'PropertyName') displays or returns the possible values for
%    the specified property, PropertyName, of data acquisition object OBJ.  The
%    returned array, PROP, is a cell array of possible value strings or an empty 
%    cell array if the property does not have a finite set of possible string
%    values.
%   
%    SET(OBJ) 
%    PROP = SET(OBJ) displays or returns all property names and their possible
%    values for data acquisition object OBJ.  The return value, PROP, is a structure 
%    whose field names are the property names of OBJ, and whose values are cell 
%    arrays of possible property values or empty cell arrays.
%
%    Example:
%       ai = analoginput('winsound');
%       chan = addchannel(ai, [1 2]);
%       set(chan, {'ChannelName'}, {'One';'Two'});
%       set(chan, {'Units', 'UnitsRange'}, {'Degrees', [0 100]; 'Volts', [0 10]});
%       set(ai, 'SamplesPerTrigger', 2048)
%
%    See also DAQHELP, DAQDEVICE/GET, SETVERIFY, PROPINFO.
%

%    MP 3-26-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.5 $  $Date: 2003/08/29 04:40:34 $

if nargout > 1,
   error('daq:set:argcheck', 'Too many output arguments.')
end

% If obj is not a Data Acquisition object, call the builtin set.
% This is needed for:  set(gcf, 'UserData', chan);
if ~isa(obj, 'daqchild')
   try
      builtin('set', obj, varargin{:});
   catch
      error('daq:set:invalidobject', lasterr)
   end
   return;
end

% Error if one of the object's is a copy of a deleted object.
if ~all(isvalid(obj))
   error('daq:set:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Initialize variables.

all_prop = get(obj);
store_prop = {};


% Create the display
switch nargin
case 0
   error('daq:set:argcheck', 'Not enough input parameters.');
case 1   % SET(OBJ)
   switch nargout
   case 0
      % return the set display: set(obj)
      try
         errflag = daqgate('privateSetList', obj);
      catch
         error('daq:set:unexpected', lasterr)
      end
   case 1
      % return the set structure: h = set(obj)
      try
         [errflag, outputStruct] = daqgate('privateSetList', obj);
      catch
         error('daq:set:unexpected', lasterr)  
      end
   end
   % Error if an error occurred in privateSetList or return.
   if errflag
      error('daq:set:unexpected', lasterr);
   else
      return
   end
case 2   % SET(OBJ, PROP)
   % Check that prop is a valid property.
   errflag = daqgate('privateCheckSetInput', varargin{1});
   if errflag
      error('daq:set:unexpected', lasterr);
   end
   
   % Error if PROP is a cell.
   if iscell(varargin{1})
      error('daq:set:invalidpvpair', 'Invalid parameter/value pair arguments.');
   end
   
   % If prop is a structure break the structure into property names
   % and property values with the call to localStructSet and loop through
   % the PV pairs.  
   if isa(varargin{1}, 'struct')
      if nargout ~= 0
         error('daq:set:lhs', 'A LHS argument cannot be used when assigning values.');
      end
      [store_prop,bad_prop,bad_val,errflag] = localStructSet(obj,varargin{1},all_prop,store_prop);
      % Determine if an error occurred in localStructSet.
      if errflag
         localProduceError(obj,bad_prop,bad_val);
         error('daq:set:unexpected', lasterr);
      end
      return;
   end
   
   switch nargout
   case 0
      % return the possible property values display: set(obj, 'Units')
      try
         errflag = daqgate('privateSetList', obj, varargin{1});
      catch
         error('daq:set:unexpected', lasterr)
      end
   case 1
      % return the possible property values cell array: h = set(obj, 'Units')
      try
         [errflag, outputStruct] = daqgate('privateSetList', obj, varargin{1});
      catch
         error('daq:set:unexpected', lasterr)
      end
   end
   % Error if an error occurred in privateSetList or return.
   if errflag
      localProduceError(obj,varargin{1},'');
      error('daq:set:unexpected', lasterr);
   else
      return;
   end
end

% When assigning values an output argument cannot be supplied.
if nargout ~= 0
   error('daq:set:lhs', 'A LHS argument cannot be used when assigning values.');
end

% Set the property values.  Initialize the index and loop through
% varargin and set the properties.
index = 1;

while index <= length(varargin)
   prop = varargin{index};
   
   % Check that prop is a valid property.
   errflag = daqgate('privateCheckSetInput', varargin{1});
   if errflag
      error('daq:set:unexpected', lasterr);
   end

   % If prop is a structure break the structure into property names
   % and property values with the call to localStructset and set the
   % PV pairs.  The index should be incremented by 1.
   if isstruct(prop)
      [store_prop,bad_prop,bad_val,errflag] = localStructSet(obj,prop,all_prop,store_prop);
      if errflag
         localProduceError(obj, bad_prop, bad_val);
         error('daq:set:unexpected', lasterr);
      end
      index = index+1;
   % If prop is a string, the property value, val, should be the next
   % element in the list.  The index is incremented by 2.
   elseif ischar(prop)
      try
         val = varargin{index+1};
      catch
         localRestore(obj,all_prop,store_prop);
         error('daq:set:invalidpvpair', 'Incomplete parameter/value pair arguments.');
      end
      index = index + 2;
      % It is not valid to do: set(obj, 'ChannelName', {'sydney'})
      % Reset the old property values before erroring.
      if iscell(val) 
         localRestore(obj,all_prop,store_prop);
         lasterr('Type mismatch');
         localProduceError(obj, prop, val);
         error('daq:set:unexpected', lasterr);
      else
         % Set the property value, val for all objects in obj
         x = struct(obj);
         for i = 1:length(obj)
            try
               store_prop = {store_prop{:} prop};
               daqmex(x.handle(i), 'set', prop, val);
            catch
               % Reset the old property values before erroring.
               localRestore(obj,all_prop,store_prop);
               localProduceError(obj, prop, val);
               error('daq:set:unexpected', lasterr);
            end
         end
      end
   % If prop is a cell, the property value, val should be the next
   % element in the list.  The index is incremented by 2 and nprop
   % is decremented by 2.
   elseif iscell(prop)
      try
         val = varargin{index+1};
      catch
         localRestore(obj,all_prop,store_prop);
         error('daq:set:invalidpvpair', 'Incomplete parameter/value pair arguments.');
      end
      index = index+2;
      % If val is not a cell, an error occurs.
      % It is not valid to do: set(obj, {'ChannelName'}, 'sydney')
      if ~iscell(val)
         % Reset the old property values before erroring.
         localRestore(obj,all_prop,store_prop);
         error('daq:set:invalidpvpair', 'Invalid parameter/value pair arguments.');
      else
         % Check the size of the PV pair to determine if a row vector
         % of property values was passed and if the number of property
         % names specified equals the number of property values specified.
         errflag = localCheckSize(obj,prop,val);
         if errflag     
            % Reset the old property values before erroring.
            localRestore(obj,all_prop,store_prop);
            error('daq:set:unexpected', lasterr);
         end
         % Reshape the val matrix so that it can be passed to daqmex.
         % set(obj, {'HwChannel'}, {3}) where obj is 1-by-10.
         val = localGetValue(obj,prop,val);
         
         % Set the properties.  Need to loop through prop in case multiple
         % properties were given.  Need to loop through obj in case an array
         % of channels or lines were passed.
         x = struct(obj);
         for j = 1:length(obj)
            for i = 1:length(prop)
               if isempty(prop{i})
                  error('daq:set:invaliddata', 'Empty cells not allowed in cell array of parameter names.');
               end
               try
                  store_prop = {store_prop{:} prop{i}};
                  daqmex(x.handle(j), 'set', prop{i}, val{j,i});
               catch       
                  % Reset the old property values before erroring.
                  localRestore(obj,all_prop,store_prop);
                  localProduceError(obj, prop{i}, val{j,i});
                  error('daq:set:unexpected', lasterr)
               end
            end
         end
      end
   end
end

% ***********************************************************
% Break sructure input argument into P-V pairs and set values.
function [store_prop,bad_prop,bad_val,errflag] = localStructSet(obj,structure,all_prop,store_prop)

% Initialize variables.
errflag = 0;
bad_prop = '';
bad_val = '';

% Obtain the property names.
Pcell=fieldnames(structure);
store_prop = {store_prop{:} Pcell{:}};

% Obtain the property values.
Vcell=struct2cell(structure);

% Loop through the PV pairs and set them.
x = struct(obj);
for j = 1:length(obj)
   for i = 1:length(Pcell)
      try
          if (~errflag)
             daqmex(x.handle(j), 'set', Pcell{i}, Vcell{i});
         end
      catch
         % Get the bad property and value.
         bad_prop = Pcell{i};
         bad_val = Vcell{i};
         % Restore the property values before erroring.
         localRestore(obj, all_prop,store_prop);
         errflag = 1;
      end
   end
end

% *****************************************************
% Determine if the correct size arguments were passed to set.
function errflag = localCheckSize(obj, prop, val)

errflag = 0;

[r1,c1]=size(prop);
[r2,c2]=size(val);

% Check that the properties specified is either a row vector or a column
% vector.  A user cannot pass a matrix of property names to set.
if ~((r1 == 1) || (c1 == 1))
   lasterr('A matrix of property names cannot be passed to SET.');
   errflag = 1;
   return;
end

% First check: If one property name is specified, then a column vector 
% of property values needs to be passed.  A user cannot pass a row 
% vector of property values when one property name is specified.  
% Second check: There should be a column of property values for each
% property name specified.  The property names can be either a row vector
% or a column vector.
if (c2 == 1 && (r1*c1 ~= 1)) || ~(c2==r1 || c2==c1)
   lasterr('Size mismatch in Param Cell / Value Cell pair.')
   errflag = 1;
   return;
end

% Check that either one property value was passed for each object or that
% one property value was passed that will be used for each object.
% set(chan, {'Gain'}, {2;3}) where chan is 1-by-3 should fail.
if (length(obj)~=r2 && r2~=1)
   lasterr('Value cell array dimension must match object vector length.');
   errflag = 1;
   return;
end

% ****************************************************
% Determine how to reshape the val matrix.
function val = localGetValue(obj, prop, val)   

nval = prod(size(val));
nprop = length(prop);

% Determine how to reshape the Val matrix.  Dependent upon whether a
% specific value is passed for each channel object or if the same value
% is passed to each channel.  
if isequal(size(prop), size(val)) || isequal(size(val), size(prop'))
   tranflag = 1;
else
   tranflag = 0;
end
   
% If a there are multiple objects and a single value, repeat the value.
if (nval/nprop ~= length(obj))
   val = repmat(val, [1 length(obj)]);
end
   
%Reshape the Val matrix.
if tranflag
   val = reshape(val,nprop,length(obj))';
else
   val = reshape(val,length(obj),nprop);
end

%**********************************************************
% Reset the original property values since an error occurred
% while setting some PV pair.
function localRestore(obj, all_prop,store_prop)

% Obtain a unique list of properties that have been set.
store_prop = unique(store_prop);

% Only restore if more than one property is set.  If the first property
% is being set to an invalid value it does not get set by the engine and
% therefore does not need to be restored.
if length(store_prop) > 1
   
   % Obtain the property names.
   Pcell=fieldnames(all_prop);
   
   % Find the properties that have been set in the Pcell cell array.
   index =[];
   for i = 1:length(store_prop)
      index = [index find(strcmp(lower(store_prop{i}), lower(Pcell)))];
   end
   
   % Index out only the properties that have been set.
   Pcell = Pcell(index);
   
   % Set the PV pairs.
   x = struct(obj);
   for j = 1:length(obj)
      % Obtain the property values from the jth structure array.
      Vcell=struct2cell(all_prop(j));
      Vcell = Vcell(index);
      
      % Loop through the PV pairs and set them.
      for i = 1:length(Pcell)
         try
            daqmex(x.handle(j), 'set', Pcell{i}, Vcell{i});
         catch
            %return;
         end
      end
   end
end

% *******************************************************************
% Produce an error message for bad set.
function localProduceError(obj, prop, val)

if findstr('Ambiguous', lasterr)
   all_names = daqmex(obj, 'get');
   all_names = fieldnames(all_names);
   i = strmatch(lower(prop), lower(all_names));
   list = all_names(i);
   str = repmat('''%s'', ',1, length(list));
   str = str(1:end-2);
   lasterr(sprintf(['Ambiguous ' class(obj) ' property: ''' prop '''.\n',...
         'Valid properties: ' str '.'], list{:}));
   return;
end
   
% Get the property information and error if the property does not exist.
try
   propstruct = propinfo(obj, prop);
catch
   if findstr('Ambiguous', lasterr)
      all_names = daqmex(obj, 'get');
      all_names = fieldnames(all_names);
      i = strmatch(lower(prop), lower(all_names));
      list = all_names(i);
      str = repmat('''%s'', ',1, length(list));
      str = str(1:end-2);
      lasterr(sprintf(['Ambiguous ' class(obj) ' property: ''' prop '''.\n',...
            'Valid properties: ' str '.'], list{:}));
      return;
   else
      lasterr(['Invalid property: ''' prop '''.']);
      return;
   end
end

% Find complete property name.
prop = findCompleteName(obj, prop);

% Get the object's parent.
parent = daqmex(obj, 'get', 'Parent');

if any(findstr('Type mismatch', lasterr)) || any(findstr('enum', lasterr)) || ...
      any(findstr('Enumerated', lasterr))
   % Error appropriately depending on if the property is read-only, read-only
   % while running and if the property has an enumerated list or constraint values.
   if propstruct.ReadOnly
      lasterr(['Attempt to modify read-only property: ''' prop '''.']);
      return;
   elseif propstruct.ReadOnlyRunning && strcmp(daqmex(parent, 'get', 'Running'), 'On')
      lasterr(['The property: ''' prop ''' is read-only while running.']);
      return
   else
      switch propstruct.Constraint
      case 'Enum'
         lasterr(['Bad value for ' class(obj) ' property: ''' prop '''.']);
         return;
      otherwise
         lasterr(['Property value for ''' prop ''' must be a ' propstruct.Type '.']);
         return;
      end
   end
end

if findstr('Invalid property:', lasterr)
   lasterr(sprintf(['Invalid property: ''' prop '''.']));
   return;
end

% ***********************************************************
% Find the complete property name.
function prop = findCompleteName(obj, prop)

 % Find complete property name.
 newprop = [];
 for i = 1:length(obj)
    allnames = fieldnames(get(obj));
    propIndex = find(strncmp(lower(prop), lower(allnames), length(prop)));
    if ~isempty(propIndex)
       newprop = allnames{propIndex(1)};
    end
    if ~isempty(newprop)
       break;
    end
 end
 
 % If a property was found - use it otherwise use the old value.
 if ~isempty(newprop)
    prop = newprop;
 end
