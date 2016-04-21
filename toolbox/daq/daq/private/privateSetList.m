function [errflag,setStruct] = privateSetList(obj, varg1)
%PRIVATESETLIST Create the SET display.
%
%    PRIVATESETLIST(OBJ) creates the SET display for SET(OBJ).
%
%    PRIVATESETLIST(OBJ, PROP) creates the SET display for
%    SET(OBJ, PROP).
%

%    MP 4-19-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.5 $  $Date: 2003/12/04 18:38:39 $

%    PRIVATESETLIST is a helper function for @daqdevice\set and
%    @daqchild\set.

% Initialize variables
nout = nargout;
errflag = 0;
setStruct = '';

switch nargin
case 1 % SET( OBJ )
   
   if nargout == 1 && (length(obj)>1)
      errflag = 1;
      lasterr(['Vector of objects not permitted for SET(OBJ) with no',...
            ' left hand side.']);
      return;
   end
   
   % Create the cell array of structures of object PV pairs.
   x = struct(obj);
   output = cell(length(obj),1);
   for i = 1:length(obj)
      try
         output{i} = daqmex(x.handle(i), 'set');
      catch
         errflag = 1;
         return;
      end
   end
   
   if nout == 2 
      % Return structure of settable properties.
      if length(obj) == 1
         setStruct = output{:};
      else
         setStruct = output;
      end
   elseif nout == 1
      % Create display of settable properties.
      localSetDisplay(obj,output{:});
   end
   return;
case 2 % SET( OBJ, [Cell | Structure | 'Property'] )
   % set(obj, {'Property'}) - should error.
   if iscell(varg1)
      lasterr('Invalid parameter/value pair arguments.');
      errflag = 1;
      return;
   elseif ischar(varg1) 
      % set(obj, 'Property')
      % obj must be 1-by-1 otherwise produce an error.
      if length(obj) ~= 1
         lasterr(['Object array must be a scalar when using SET to ',...
               'retrieve information.']);
         errflag = 1;
         return;
      end
      % Obtain the list of settable values.
      try
         output = daqmex(obj,'set',varg1);
      catch
         errflag = 1;
         return;
      end
      
      % Create appropriate display. Display is dependent upon if an output
      % variable was specified and if the property has a list of values.
      
      % Determine if the property (varg1) is read-only.  This is needed so that
      % a different message can be returned indicating that it is a read-only 
      % property.
      [readonly,prop] = daqgate('privatereadonly', obj, varg1);
      
      % Error if readonly.
      if readonly
         lasterr(['Attempt to modify read-only property: ''' prop '''.']);
         errflag = 1;
         return;
      end
      
      % Either return an empty cell array or a message indicating that
      % the property does not have a fixed set of values depending on the
      % number of output variables.
      if isempty(output)
         if nout == 2
            % Return empty cell array
            setStruct = output;
         elseif nout == 1  
            if ~isempty(strfind([prop ' '], 'Fcn ')) % ends in 'Fcn'
                fprintf('string -or- function handle -or- cell array\n');                  
            else
                fprintf(['The ''' prop ''' property does not have a fixed ',...
                         'set of property values.\n']);
            end
         end
      else
         if nout == 2 
            % Return cell array of possible values for specified property.
            setStruct = output;
         elseif nout == 1  
            % Create the bracketed list: [ {Off} | On ]
            str = localCreateList(obj, output, varg1);
            fprintf(['[' str ']\n']);
         end
      end
      return;
   end
end

% **********************************************************************
% Create the display for SET(OBJ)
function localSetDisplay(obj,output)

% Obtain a list of object fields.
fields = fieldnames(output);
values = struct2cell(output);

% Store device specific properties in DEVICEPROPS.
% Only check the property names that are associated with set
propinfovalues = propinfo(obj,fields);
deviceprops = {};

% Loop through the fields to determine the string that will be
% displayed.  If the property does not have a list of settable
% values display the property name only.  If the property does 
% have a list of settable values create the bracketed expression
% with localCreateList and display it.  If the proeprty is device
% specific add the correct display to the deviceprops cell array.
for i = 1:length(fields)
   if isempty(values{i})
      if propinfovalues{i}.DeviceSpecific,
         deviceprops = {deviceprops{:} sprintf('        %s\n', fields{i})};
      elseif ~isempty(strfind( [fields{i} ' '], 'Fcn ' )) % ends in 'Fcn'
         fprintf('        %s: string -or- function handle -or- cell array\n', fields{i} );
      else
         fprintf('        %s\n', fields{i});
      end
   else
      str = localCreateList(obj, values{i}, fields{i});
      if propinfovalues{i}.DeviceSpecific,
         deviceprops = {deviceprops{:} sprintf('        %s: [%s]\n',fields{i},str)};
      else
         fprintf('        %s: [%s]\n', fields{i}, str);
      end
   end
end

% Create a blank line after the property value listing.
fprintf('\n');

% Device specific properties are displayed if they exist.
if ~isempty(deviceprops)
   % Determine adaptor.
   if isa(obj,'daqchild'),
      parent = get(obj,'Parent');
   else
      parent = obj;
   end
   objinfo = daqhwinfo(parent);
   
   % Create device specific heading.
   fprintf(['        ' upper(objinfo.AdaptorName) ' specific properties:\n']);
   
   % Display device specific properties.
   for i=1:length(deviceprops),
      fprintf(deviceprops{i})
   end
   
   % Create a blank line after the device specific property value listing.
   fprintf('\n');
end

% *************************************************************************
% Create the list of property values for the SET(OBJ, PROP) display.
function str = localCreateList(obj,output,prop)

% Convert the output cell array {'Off';'On'} to a list that can
% be bracketed: Off | On
str = '';
for i = 1:length(output)
   str = [str ' ' output{i} ' |'];
end
% Remove the trailing pipe (|).
str = str(1:end-1);

% Obtain the default value.
[oldvalue, defaultvalue] = localGetDefault(obj,prop);

% Place braces around the default value.
str = strrep(str, oldvalue, defaultvalue);


% *******************************************************************
% Obtain the defualt value for the property.
function [old, new] = localGetDefault(obj,prop)

% Get the property information for the specified property.
propinfovalue = propinfo(obj,prop);

% Determine the default value and add braces to the defaultvalue string.
old = propinfovalue.DefaultValue;
if ~isempty(old)
   new = ['{' old '}'];
else
   new = '';
   old = '';
end	

% Special case for LoggingMode since it has a Memory and Disk&Memory option.
% Otherwise both 'Memory''s will have braces around them.
if findstr(lower(prop), 'loggingm')
   old = ' Memory ';
   new = ' {Memory} ';
end

