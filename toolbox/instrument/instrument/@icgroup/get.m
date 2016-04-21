function output = get(obj, varargin)
%GET Get instrument or device group object properties.
%
%   V = GET(OBJ,'Property') returns the value, V, of the specified 
%   property, Property, for instrument or device group object OBJ. 
%
%   If Property is replaced by a 1-by-N or N-by-1 cell array of strings 
%   containing property names, then GET will return a 1-by-N cell array
%   of values. If OBJ is a vector of instrument objects or device group
%   objects, then V will be a M-by-N cell array of property values where M
%   is equal to the length of OBJ and N is equal to the number of
%   properties specified.
%
%   GET(OBJ) displays all property names and their current values for
%   object, OBJ.
%
%   V = GET(OBJ) returns a structure, V, where each field name is the
%   name of a property of OBJ and each field contains the value of that 
%   property.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       get(g, {'PrimaryAddress','EOSCharCode'})
%       out = get(g, 'EOIMode')
%       get(g)
%
%   See also INSTRUMENT/SET, INSTRUMENT/PROPINFO, ICGROUP/SET,
%   ICGROUP/PROPINFO, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:50 $

% Call builtin get if OBJ isn't an instrument object.
% Ex. get(s, s);
if ~isa(obj, 'icgroup')
    try
	    builtin('get', obj, varargin{:});
    catch
        rethrow(lasterror);
    end
    return;
end

% Error if invalid.
if ~all(isvalid(obj))
   error('icgroup:get:invalidOBJ', 'An object in OBJ is an invalid object.');
end

if  ((nargout == 0) && (nargin == 1))
   % Ex. get(obj)
   if (length(obj) > 1)
      error('icgroup:get:nolhswithvector', 'Vector of handles not permitted for get(OBJ) with no left hand side.')
   else
      try
          localCreateGetDisplay(obj);
      catch
          error('icgroup:get:opfailed', lasterr);
      end
      return;
   end
elseif ((nargout == 1) && (nargin == 1))
   % Ex. out = get(obj);
   try
      % Call the java get method.
      output = localCreateOutputStruct(obj);
   catch
      error('icgroup:get:opfailed', lasterr);
   end
elseif (nargin > 2)
    error('icgroup:get:maxrhs', 'Too many input arguments.');
else
   % Ex. get(obj, 'BaudRate')
   try      
      % Capture the output - call the java get method.
      property = varargin{1};
      if ~(ischar(property) || iscellstr(property))
          error('icgroup:get:invalidArg', 'Second argument must be string or cell array.');
      end
      
      output = localGetProperty(obj, varargin{1});
   catch
      error('icgroup:get:opfailed', lasterr);
   end	
end

% ***************************************************************
function out = localGetProperty(obj, property)

% Construct the output argument.
if ischar(property)
    out = cell(length(obj), 1);
    property = {property};
    isOutCell = false;
else
    out = cell(length(obj), numel(property));
    isOutCell = true;
end

% Get the java objects.
jobj = igetfield(obj, 'jobject');

% Loop through the object and properties and get their values.
for i=1:length(jobj)
    for j = 1:numel(property)
        out{i,j} = localGetPropertyValue(jobj(i), property{j});
    end
end

% Convert to string if the object array is of length 1 and the 
% property was specified as a string (not a cell).
if ~isOutCell && (length(obj) == 1)
    out = out{:};
end

% ***************************************************************
% Get the property value for one property and one object.
function out = localGetPropertyValue(obj, property)

jobj = java(obj);

% Single property was specified.
if ischar(property)
    if jobj.isBaseProperty(property);
        out = get(obj, property);
    else
        out = jobj.getProperty(property);
    end
end

% ***************************************************************
% Create the structure for out = get(OBJ).
function out = localCreateOutputStruct(deviceObj)

obj = igetfield(deviceObj, 'jobject');

for i = 1:length(obj)
    [names, vals, interfaceSpecific] = localGetPropertyAndValues(obj(i));
    out(i, 1) = cell2struct(vals, names, 2);
end

% ***************************************************************
% Get the properties and their values.
function [names, vals, interfaceSpecific] = localGetPropertyAndValues(obj)

% Get the java object.
jobj = java(obj);

% Get an array indicating if the properties are interface specific.
interfaceSpecific = isInterfaceSpecific(jobj);

% Get the property names (names) and values.
names = cell(getPropertyNames(jobj));
vals = cell(1, length(names));

for i = 1:length(names)
    if interfaceSpecific(i)
        vals{i} = jobj.getProperty(names{i});
    else
        vals{i} = get(obj, names{i});
    end
end

% ***************************************************************
% Create the GET display.
function localCreateGetDisplay(deviceObj)

[names, vals, interfaceSpecific] = localGetPropertyAndValues(igetfield(deviceObj, 'jobject'));

% Store interface specific properties in DEVICEPROPS.
deviceprops = {};

% Loop through each property and determine the display (dependent
% upon the class of val).
for i = 1:length(names)
   val = vals{i};
   if isnumeric(val)
      [m,n] = size(val);
      if isempty(val)
         % Print the property name only.
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = []\n', names{i})};
         else
            h = sprintf('    %s = []\n', names{i});
            fprintf(h);
         end         
      elseif (m*n == 1)
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %g\n', names{i}, val)};
         else
            h = sprintf(['    %s = %g\n'], names{i}, val);
            fprintf(h);
         end
      elseif ((m == 1) || (n == 1)) && (m*n <= 10)
         % The property value is a vector with a max of 10 values.
         % UserData = [1 2 3 4]
         numd = repmat('%g ',1,length(val));
         numd = numd(1:end-1);
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf(['    %s = [' numd ']\n'], names{i}, val)};
         else
            h = sprintf(['    %s = [' numd ']\n'], names{i}, val);
            fprintf(h);
         end
      else
         % The property value is a matrix or a vector with more than 10 values.
         % UserData = [10x10 double]
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
         else
            h = sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
            fprintf(h);
         end
      end
   elseif ischar(val)
      % The property value is a string.
      % RecordMode = Append
      if isjava(val)
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = [1x1 struct]\n', names{i})};
         else
            h = sprintf('    %s = [1x1 struct]\n', names{i});
            fprintf(h);
         end
      else
         if interfaceSpecific(i)
            deviceprops = {deviceprops{:} sprintf('    %s = %s\n', names{i}, val)};
         else
            h = sprintf('    %s = %s\n', names{i}, val);
            fprintf(h);
         end
      end
   else
      % The property value is an object, etc object.
      % UserData = [2x1 serial] 
      [m,n]=size(val);
      if interfaceSpecific(i)
         deviceprops = {deviceprops{:} sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val))};
      else
         h = sprintf('    %s = [%dx%d %s]\n', names{i},m,n,class(val));
         fprintf(h);
      end
   end
end

% Create a blank line after the property value listing.
fprintf('\n');

% Interface specific properties are displayed if they exist.
if ~isempty(deviceprops)
   
   % Create interface specific heading.
   fprintf(['    ' upper(get(deviceObj, 'Type')) ' specific properties:\n']);
   
   % Display interface specific properties.
   for i=1:length(deviceprops),
      fprintf(deviceprops{i})
   end
   
   % Create a blank line after the interface specific property value listing.
   fprintf('\n');
end


