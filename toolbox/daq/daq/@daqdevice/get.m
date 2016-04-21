function output = get(obj, varargin)
%GET Get data acquisition object properties.
%
%    V = GET(OBJ,'Property') returns the value, V, of the specified property
%    for data acquisition object OBJ.  If Property is replaced by a 
%    1-by-N or N-by-1 cell array of strings containing property names, 
%    then GET will return a 1-by-N cell array of values.  If OBJ is a 
%    vector of data acquisition objects, then V will be a M-by-N cell array 
%    of property values where M is equal to the length of OBJ and N is equal 
%    to the number of properties specified.
%
%    GET(OBJ) displays all property names and their current values for
%    data acquisition object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the name
%    of a property of OBJ and each field contains the value of that property.
%
%    Example:
%       ai = analoginput('winsound');
%       addchannel(ai, [1 2]);
%       chan = get(ai,'Channel')
%       get(ai,{'SampleRate','TriggerDelayUnits'})
%       get(ai)
%       get(chan, 'Units')
%       get(chan(1), {'HwChannel';'ChannelName'})
%
%    See also DAQHELP, DAQDEVICE/SET, SETVERIFY, PROPINFO.
%

%    MP 2-25-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:41:13 $

ArgChkMsg = nargchk(1,3,nargin);
if ~isempty(ArgChkMsg)
    error('daq:get:argcheck', ArgChkMsg);
end

if nargout > 1
   error('daq:get:argcheck', 'Too many output arguments.')
end

% Error appropriately if a user calls get(1,ai);
if ~isa(obj, 'daqdevice')
   try
      builtin('get', obj, varargin{:});
   catch
      error('daq:get:unexpected', lasterr);
   end
   return;
end

%try for the trivial case res=get(obj,p) where all inputs are scailers
if ( nargin==2 && ischar(varargin{1}))
   try
      output=daqmex(obj,'get',varargin);
      return
   catch
      % just keep going when daqmex errors are compleate then-> error(lasterr)
   end
end

% Initialize variables.


switch nargin
case 1   % get(obj);
   if (~nargout) && (length(obj)>1)
      error('daq:get:invalidsize', 'Vector of objects not permitted for GET(OBJ) with no left hand side.');
   end
   
   % Build up the structure of property names and property values.  
   % Each column of the structure corresponds to a different object.
   x = struct(obj);
   out = cell(length(obj),1);
   for i = 1:length(obj)
      try
         out{i} = daqmex(x.handle(i), 'get');
      catch
         error('daq:get:unexpected', lasterr);
      end
   end

   % If there are no output arguments construct the GET display.
   if nargout == 0
      try
         daqgate('getdisplay', obj, out{:});
      catch
         error('daq:get:unexpected', lasterr);
      end
   else
      if length(obj) == 1
         output = out{:};
      else
		 % Create output that is a 1 x n struct with fields
		 try
			 output = [out{:}];
		 catch
			 if (findstr(lasterr, 'CAT arguments are not consistent in structure field number.'))
				 error('daq:get:properties', 'Unable to get values. Objects in the object array do not have identical properties.');
			 end
		 end		 
      end
   end
case 2   % get(obj, 'Property') | get(obj, {'Property'})
   prop = varargin{1};
   if ischar(prop)
      % Single property string passed - get(obj, 'Property');
      output = cell(length(obj),1);
      x = struct(obj);
      for i = 1:length(obj)
         try
            output{i} = daqmex(x.handle(i), 'get', prop);
         catch
            % Is this temp call correct?
            temp = localCreateParent(obj,i);
            localProduceError(temp, prop);
            error('daq:get:unexpected', lasterr)
         end
      end
      % If a string is passed and there is one object, need to 
      % output a string.
      if length(obj) == 1
         output = output{:};
      end
   elseif iscell(prop)  
      % Cell of properties passed.
      % get(obj, {'Property1';'Property2';'Property3'});
      
      output = cell(length(obj), length(prop));
      x = struct(obj);
      for j = 1:length(obj)
         for i = 1:numel(prop)
            try
               if ischar(prop{i}),
                  output{j,i} = daqmex(x.handle(j), 'get', prop{i});
               else
                  error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.');
               end            
            catch
               temp = localCreateParent(obj,j);
               localProduceError(temp, prop{i});
               error('daq:get:unexpected', lasterr)
            end
         end
      end
   elseif isa(prop, 'double')
      % Prop should only be a double when called from subsref or subsasgn.
      % Indexing into the array could not be handled by subsref or subsasgn
      % since '()' would call the default subsref which did not do the correct
      % thing.
      
      % Create the first object.
      try
         output = localCreateParent(obj,prop(1));
         
         % Append the device objects to the output array.
         for i = 2:length(prop)
            output = [output localCreateParent(obj,prop(i))];
         end
      catch
         error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.');
      end
   else
      error('daq:get:invalidargument', 'Second input argument of GET must contain a valid property\nname or a cell array containing valid property names.');
   end
case 3  
   % Getting Channel/Line info - get(ai, 'Channel', [1 3])
   prop = varargin{1};
   index = varargin{2};
   
   % Prop has to be 'Channel' or 'Line' otherwise too many property name
   % strings have been entered - get(ai, 'Type', 'UserData')
   % STRNCMP is used for property completion.
   if isempty(find(strncmp(lower(prop), {'channel', 'line'}, length(prop))))
      error('daq:get:argcheck', 'Too many input arguments.');
   end
      
   % Handle the colon operator.  If the colon operator is entered
   % as the index, the index contains all channels.
   output = cell(length(obj),1);
   for i = 1:length(obj)
      parent = localCreateParent(obj, i);
      if strcmp(index,':')
         try
            index = 1:length(daqmex(parent, 'get', prop));
         catch
            error('daq:get:unexpected', lasterr);
         end
      end
   
      % Obtain the first channel object in the children list.
      try
         result = daqmex(parent, 'get', prop, index(1));
      catch
         localProduceError(obj,prop);
         error('daq:get:unexpected', lasterr)
      end
   
      % Concatenate the remaining channels to the output.
      for j = 2:length(index)
         try
            result = [result; daqmex(parent,'get',prop, index(j))];
         catch
            localProduceError(parent,prop);
            error('daq:get:unexpected', lasterr);
         end
      end
      output{i} = result;
   end
   
   if length(obj) == 1
	   output = output{:};
   else
	   % Create output that is a 1 x n struct with fields
	   try
		   output = [output{:}];
	   catch
		   if (findstr(lasterr, 'CAT arguments are not consistent in structure field number.'))
			   error('daq:get:properties', 'Unable to get values. Objects in the object array do not have identical properties.');
		   end
	   end		 
   end
end
% *************************************************************************
% Create the parent object.
function parent = localCreateParent(Obj, index1)

% Recreate the device object.  Ex. obj(1)
% Get the object's Type - Analog Input, Analog Output, Digital IO.
structinfo = struct(Obj);
objType = structinfo.info(index1).objtype;
objType(find(isspace(objType))) = [];

% Recreate the object.
parent = feval(lower(objType), structinfo.handle(index1));

% *******************************************************************
% Produce an error message for ambiguous get.
function localProduceError(obj, prop)

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

if findstr('Invalid property:', lasterr)
   lasterr(sprintf(['Invalid property: ''' prop '''.']));
   return;
end

