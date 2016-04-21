function obj2mfile(objs, varargin)
%OBJ2MFILE Convert data acquisition object to MATLAB code.
%
%    OBJ2MFILE(OBJ, 'FILENAME') converts the data acquisition object, OBJ
%    to the equivalent MATLAB code using the SET syntax and saves the 
%    MATLAB code to the specified FILENAME.  If an extension is not specified, 
%    the .m extension is used.  By default, only those properties that 
%    are not set to their default values are written to the file, FILENAME.
%    OBJ can be a single data acquisition object or an array of objects.
%
%    OBJ2MFILE(OBJ, 'FILENAME', SYNTAX) converts the data acquisition object,
%    OBJ, to the equivalent MATLAB code using the specified SYNTAX and saves
%    the code to FILENAME.  The SYNTAX can be 'set', 'dot' or 'named'.  If
%    SYNTAX is not specified, 'set' is used as the default.
%
%    OBJ2MFILE(OBJ, 'FILENAME', 'all')
%    OBJ2MFILE(OBJ, 'FILENAME', SYNTAX, 'all') saves the equivalent MATLAB 
%    code created with the specified SYNTAX to FILENAME.  If 'all' is 
%    included, all properties are written to FILENAME.  If 'all' is excluded, 
%    only those properties not set to their default values are written to 
%    FILENAME.
%
%    If OBJ's UserData is not empty, then the data stored in the UserData
%    property is written to a MAT-file when the object is converted and
%    saved.  The MAT-file has the same name as the M-file containing the 
%    object code.  
%
%    If any of OBJ's callback properties are set to a cell array, then the
%    data stored in that callback property is written to a MAT-file when
%    the object is converted and saved.  The MAT-file has the same name
%    as the M-file containing the object code.
%
%    To recreate OBJ, if OBJ is a device object, type the name of the
%    M-file.  To recreate OBJ, if OBJ is a channel or line object, type
%    the name of the M-file with a device object as the only input.
%
%    Example:
%       ai = analoginput('winsound');
%       chan = addchannel(ai, [1 2], {'Temp1';'Temp2'}); 
%       set(ai, 'Tag', 'myai', 'TriggerRepeat', 4);
%
%       % To save ai:
%         obj2mfile(ai, 'myai.m', 'dot');
%       % To recreate ai:
%         copyai = myai;
%
%       % To save chan:
%         obj2mfile(chan, 'mychan', 'all');
%       % To recreate chan:
%         newai = analoginput('winsound');
%         copychan = mychan(newai);
%
%    See also DAQHELP.
%

%    MP 5-12-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/10/15 18:27:59 $

ArgChkMsg = nargchk(1,4,nargin);
if ~isempty(ArgChkMsg)
    error('daq:obj2mfile:argcheck', ArgChkMsg);
end

% Error if an invalid object was passed.
if ~all(isvalid(objs))
   error('daq:obj2mfile:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Initialize variables.
name = inputname(1);
time = datestr(now);
fid = [];
numObjs = length(objs);
allvalue = cell(1,numObjs);
createmat = 0;

% Parse the input.
try
   [errflag,syntax,definelist,filename,file,path] = ...
      daqgate('getfileinfo',varargin{:});
  matfilename = [filename 'at'];
catch
   error('daq:obj2mfile:unexpected', lasterr)
end

% Error if an error occurred in getfileinfo.
if errflag
   error('daq:obj2mfile:unexpected', lasterr)
end

% Determine if a MAT-file needs to be created.
for i = 1:numObjs
   allvalue{i} = get(get(objs, i));
   if ~createmat
      % Determine if the UserData is empty.
      if ~isempty(allvalue{i}.UserData)
         createmat = 1;
      end
   
      % Determine if an Callback property is set to a cell array 
      callbacklist = localSaveCallback(allvalue{i});
      if ~isempty(callbacklist)
         createmat = 1;
      end
   end
end

try
   for objindex = 1:numObjs
      % Initialize variables.
      obj = get(objs, objindex);
      classname = class(obj);
      
      
      % Define the name variable in case obj.Parent is passed as the input.
      if isempty(name) || length(objs) > 1
         name = ['device' num2str(objindex)];
      end
      
      % Rename the classname so that it looks better in the comments of the
      % constructed M-file.  Define if addchannel or addline will be called.
      % Define the child type for the comments.
      hinfo = struct(obj);
      classrename = hinfo.info.objtype;  % Analog Input
      cmd = lower(hinfo.info.addchild);  % addchannel
      type_child = hinfo.info.child;     % Channel
      prefix = hinfo.info.prefix;        % a or an
      
      % Create a temp object and the property list.
      [prop, createtrigger, createchild, testobj,hwid,drivername,trigchanindex, FcnProps] =...
         localDetermineProp(obj, classname, definelist, allvalue{objindex},type_child);
      
      % Open the file.  At this point all the error checking should be completed.
      if objindex == 1
         fid = fopen(filename, 'w');
         
         % Check if the file was opened successfully.
         if (fid < 3)
            error('daq:obj2mfile:fileopen', '%s could not be opened.', filename);
         end
         
         % Write function line and comments to the file.
         fprintf(fid, 'function out = %s\n', file);
         localSetComment(fid,file,classrename,name, prefix);
         
         % Write a comment indicating when the file was created.
         fprintf(fid, '%%    Creation time: %s\n\n', time);
         
         % Write command regarding MAT-file.
         if (FcnProps || createmat)
                 fprintf(fid, '%% Load the MAT-file which contains UserData and *Callback property values.\n');
                 fprintf(fid, 'load %s\n\n', file);
                 createmat = 1;
         end
      end   
      
      if ~isempty(prop)
         % Remove the read-only properties from the prop cell array.
         prop = localReadOnly(obj, prop);
      end
      
      % Write the comment for the set commands to the file.
      if ~isempty(prop)
         switch definelist
         case 'default'
            fprintf(fid, '%% Set the %s non-default properties.\n', classrename);
         case 'all'
            fprintf(fid, '%% Set the %s properties.\n', classrename);
         end
      end
      
      % Determine if the object was already created.
      compareObjs = obj == objs;
      compareObjs = compareObjs(1:objindex-1);
      indexCompare = find(compareObjs);
      if isempty(indexCompare)
         % Write the commands which create the Data Acquisition object
         % (analoginput, analogoutput or digitalio) to the file with comments.
         fprintf(fid, '%% Create the %s object - object %d.\n', classrename, objindex);
         if isempty(hwid) 
            fprintf(fid, '%s = %s(''%s'');\n\n', name, classname, drivername);
         else
            fprintf(fid, '%s = %s(''%s'', ''%s'');\n\n', name, classname, drivername, hwid);
         end

         % Write the commands to the file for setting property values.
         createmat = localWriteDevice(fid, prop, allvalue, objindex, syntax, name, matfilename, createmat);
      
         % Write out the commands to reconstruct the channel/line objects.
         if createchild
            child = getfield(allvalue{objindex}, type_child);
            if ~isempty(child)
               % Write the commands to reconstruct the channel or line object(s).
               fprintf(fid, '\n');
               try
                  errflag = daqgate('privatewritechild',fid,syntax,definelist,child,...
                     testobj,'chan',name,type_child,cmd);
               catch
                  error('daq:obj2mfile:unexpected', lasterr)
               end
               % Error if privatewritechild errored expectedly.
               if errflag
                  error('daq:obj2mfile:unexpected', lasterr)
               end
            end
         end
      
         % Write out the call to set the Trigger Channel property.
         if createtrigger
            fprintf(fid, '%%Set the TriggerChannel property to the correct channels.\n');
            value = [trigchanindex{:}];
            numd = repmat('%g ',1, length(value));
            numd = numd(1:end-1);
            switch syntax
            case 'set'
               fprintf(fid, ['set(%s, ''TriggerChannel'', %s.Channel([' numd ']));\n\n'], name, name, value);
            case {'dot' 'named'}
               fprintf(fid, ['%s.TriggerChannel = %s.Channel([' numd ']);\n\n'],name, name, value);
            end
         end
      
      else
         % The object was already created and the new object should be
         % set equal to the previously created object.
         fprintf(fid, 'device%d = device%d;\n', objindex, indexCompare(1));
      end
      
      fprintf(fid, '\n');

      % Delete the dummy object, testobj.
      delete(testobj)
           
   end
   
   % Output the Data Acquisition object if an output variable is specified.
   fprintf(fid, 'if nargout > 0 \n');
   if length(objs) > 1
      name = makenames('device', 1:length(objs));
      nums = repmat('%s ',1, length(objs));
      nums = nums(1:end-1);
      fprintf(fid, ['   out = [' nums '];\n'], name{:});
   else
      fprintf(fid, ['   out = [ %s ];\n'], name);
   end
   fprintf(fid, 'end\n');
   
   % Close the file.
   fclose(fid);
   
   % Display message that the specified file was created.
   if isempty(path)
      filename = [pwd '\' filename];
   end
   disp(['Created: ' filename]);
   
   % If a MAT-file was created, display a message that it was created.
   if createmat
      disp(['Created: ' matfilename]);
   end
catch
   if ~isempty(fid)
      fclose(fid);
   end
   error('daq:obj2mfile:unexpected', lasterr);
end

% ******************************************************************
function [prop, createtrigger, createchild, testobj, hwid,drivername,trigchanindex, FcnProps] = ...
   localDetermineProp(obj, classname, definelist, allvalue, type_child)

% Initialize variables.
createtrigger = 0;
createchild = 0;
trigchanindex = {};
FcnProps = 0;

% Determine the object's DriverName and ID.
hwinfo = daqhwinfo(obj);
drivername = hwinfo.AdaptorName;
hwid = hwinfo.ID;

% Create a dummy object, testobj, to determine the default values.
if isempty(hwid) 
   testobj = feval(classname, drivername);
else
   testobj = feval(classname, drivername, hwid);
end

% Depending on the DEFINELIST input argument either create the cell array
% prop to contain the properties which are not set to their default values
% or to contain all the properties.
switch definelist
case 'default'
   % Need to GET the property values otherwise it will use the properties
   % defined in the constructor.
   testobj_struct = get(testobj);
   % Determine the properties that are not set to their default values.
   prop = localFindProp(obj, testobj_struct);
case 'all'
   temp = get(obj);
   temp = fieldnames(temp);
   % Convert the properties to a cell array of cells.
   prop = cell(1,length(temp));
   for i = 1:length(temp)
      prop{i} = temp(i);
   end
end

% Determine if a Channel object exists so that addchannel can be called.
if ~isempty(prop)
   childindex = find(strcmp({lower(type_child)}, lower([prop{:}])));
   if ~isempty(childindex)
      % Remove the Channel string from the prop cell array since it will be
      % created later.
      createchild = 1;
      prop(childindex) = [];
   end
end

% Reorder the prop list to set the TriggerType property before setting 
% the TriggerCondition property.
if ~isempty(prop) 
   triggerindex = find(strcmp('TriggerType', [prop{:}]));
   if ~isempty(triggerindex)
      if ~any(strmatch(get(obj, 'TriggerType'), {'Immediate'}))
         i_type = strmatch('TriggerType', cat(1,prop{:}), 'exact');
         i_condition = strmatch('Trigger', cat(1,prop{:}));
         if ~isempty(i_condition)
            i_condition = i_condition(1);
            x = 1:length(prop);
            y = [x(1:i_condition-1) i_type x(i_condition:i_type-1) x(i_type+1:end)];
            prop = prop(y);
         end
      end
   end
end

% If BufferingMode is set to Auto, then the BufferingMode property can
% be listed but the BufferingConfig property cannot since it may not be
% restored to the specified value.  If BufferingMode is set to Manual, then
% the BufferingConfig property is listed but not the BufferingMode property
% since setting this property can effect the BufferingConfig property values.
if ~isempty(prop) 
   configindex = find(strcmp('bufferingconfig', lower([prop{:}])));
   modeindex = find(strcmp('bufferingmode', lower([prop{:}])));
   if ~isempty(modeindex) || ~isempty(configindex)
      if strcmp(daqmex(obj, 'get', 'BufferingMode'), 'Auto')
         % Remove BufferingConfig and list BufferingMode.  
         if ~isempty(configindex)
            prop(configindex) = [];
         end
      elseif strcmp(daqmex(obj, 'get', 'BufferingMode'), 'Manual')
         % Remove BufferingMode and list BufferingConfig.
         if ~isempty(modeindex)
            prop(modeindex) = [];
         end
      end
   end
end

% Determine if the TriggerChannel property is set to a channel.
if ~isempty(prop)
   triggerindex = find(strcmp({'triggerchannel'}, lower([prop{:}])));
   if ~isempty(triggerindex)
      trigchan = get(obj, 'TriggerChannel');
      if ~isempty(trigchan)
         % Remove the TriggerChannel string from the prop cell array since 
         % it will be created later.
         createtrigger = 1;
         trigchanindex = get(trigchan, {'Index'});
         prop(triggerindex) = [];
      end
   end
end

% Determine if function handles exist
if ~isempty(prop)
    % loop through each property to be set and check to see
    % if a callback property is included
    for iLoop = 1:length(prop)
        if (findstr(lower(prop{iLoop}{1}), 'fcn'))
            % check to see if there is a function handle as the value
            if (isa(getfield(allvalue, prop{iLoop}{1}), 'function_handle'))
                % Set the flag to TRUE
                FcnProps = 1;
                break
            end
        end
    end
end

% ******************************************************************
% Write out the set, dot, named commands.
function createmat = localWriteDevice(fid, prop, allvalue, objindex, syntax, name, file, createmat)

% Write the set commands to the file.
switch syntax
case 'set'   
   for i = 1:length(prop)
      % Set the UserData property seperately since it is being set to 
      % a variable.
      if strcmp(lower(prop{i}), 'userdata')
         userdata = getfield(allvalue{objindex}, 'UserData');
         if ~isempty(userdata)
            eval(['userdata' num2str(objindex) ' = userdata;']);
            if createmat == 2
               save(file,['userdata' num2str(objindex)], '-append');
            else
               save(file,['userdata' num2str(objindex)]);
               createmat = 2;
            end
            fprintf(fid, 'set(%s, ''UserData'', userdata%d);\n',name,objindex);
            break;
         else
            fprintf(fid, 'set(%s, ''UserData'', []);\n', name);
            break;
         end
      else
         value = getfield(allvalue{objindex}, prop{i}{:});
      end
      
      if isnumeric(value)&&length(value)>1
         % Property value is a numeric array.
         % Create %g %g string and remove the trailing space.
         numd = repmat('%g ',1, length(value));
         numd = numd(1:end-1);
         fprintf(fid, ['set(%s, ''%s'', [' numd ']);\n'],name,prop{i}{:},value);
      elseif isnumeric(value)
         % Property value is a single number.
         if isempty(value)
            fprintf(fid, 'set(%s, ''%s'', []);\n', name, prop{i}{:});
         else         
            fprintf(fid, 'set(%s, ''%s'', %g);\n', name, prop{i}{:}, value);
         end
      % write cell array or function handles to MAT file
      elseif (iscell(value) || isa(value,'function_handle'))
         writtenname = [lower(prop{i}{:}) num2str(objindex)];
         fprintf(fid, 'set(%s, ''%s'', %s);\n',name, prop{i}{:}, writtenname);
         eval([writtenname ' = value;']);
         if createmat == 2
            save(file, writtenname, '-append');
         else
            save(file, writtenname);
            createmat = 2;
         end
         
      else %Property value is a string.
         fprintf(fid, 'set(%s, ''%s'', ''%s'');\n', name, prop{i}{:}, value);
      end
   end
case {'dot', 'named'}
   for i = 1:length(prop)
      % Set the UserData property seperately since it is being set to 
      % a variable.
      if strcmp(lower(prop{i}), 'userdata') 
         userdata = getfield(allvalue{objindex}, 'UserData');
         if ~isempty(userdata)
            eval(['userdata' num2str(objindex) ' = userdata;']);
            if createmat == 2
               save(file,['userdata' num2str(objindex)], '-append');
            else
               save(file,['userdata' num2str(objindex)]);
               createmat = 2;
            end
            fprintf(fid, '%s.UserData = userdata%d;\n', name, objindex);
            break;
         else
            fprintf(fid, '%s.UserData = [];\n', name);
            break;
         end
      else
         value = getfield(allvalue{objindex}, prop{i}{:});
      end
      
      if isnumeric(value)&&length(value)>1 
         % Property value is a numeric array.
         % Create %g %g string and remove the trailing space.
         numd = repmat('%g ',1, length(value));
         numd = numd(1:end-1);
         fprintf(fid, ['%s.%s = [' numd '];\n' ], name, prop{i}{:}, value);
      elseif isnumeric(value)
         if isempty(value)
            fprintf(fid, '%s.%s = [];\n', name, prop{i}{:});
         else
            fprintf(fid, '%s.%s = %g;\n', name, prop{i}{:}, value);
         end
      % write cell array or function handles to MAT file
      elseif (iscell(value) || isa(value,'function_handle'))
         writtenname = [lower(prop{i}{:}) num2str(objindex)];
         fprintf(fid, '%s.%s = %s;\n', name, prop{i}{:}, writtenname);
         eval([writtenname ' = value;']);
         if createmat == 2
            save(file, writtenname, '-append');
         else
            save(file, writtenname);
            createmat = 2;
         end
      else
         % Property value is a string.
         fprintf(fid, '%s.%s = ''%s'';\n', name, prop{i}{:}, value);    
      end
   end
end

% ******************************************************************
% Determine the properties that are not set to their default values.
function list = localFindProp(obj, default)

% Obtain all the property names for the given object.
fields = fieldnames(default);

% Obtain the current values for each field for each object.
default_prop = struct2cell(default);
obj_prop = struct2cell(get(obj));
list = {};

for i = 1:length(default_prop)
   x = isequal(default_prop{i}, obj_prop{i});
   if x == 0;
      list = {list{:} fields(i)};
   end
end

% For Nidaq with one channel, if the ChannelSkewMode is Minimum the 
% ChannelSkew is 0, for two channels the ChannelSkew is a small number 
% (not the default value of 0).  ChannelSkew is therefore written to 
% the file which causes errors since ChannelSkew is read-only with
% a ChannelSkewMode of Minimum.  The same applies for a ChannelSkewMode
% of Equisample.
index = find(strcmp('ChannelSkew', [list{:}]));

if ~isempty(index)
   if any(strcmp(get(obj, 'ChannelSkewMode'), {'Equisample', 'Minimum'}))
      list(index) = [];
   end
end   

% *******************************************************************
function callbacklist = localSaveCallback(objinfo)

% Initialize variables.
callbacklist = {};

% Get the property names and property values.
propname = fieldnames(objinfo);
propval  = struct2cell(objinfo);

% Determine which callback properties are set to a cell array 
for i = 1:length(propname)
    if findstr('fcn', lower(propname{i}))
        if iscell(propval{i})
            callbacklist = [callbacklist propname(i)];
        end
    end
end

% *************************************************************
% Removes the read-only properties from cell array prop.
function prop = localReadOnly(obj, prop)

% Get the read-only properties for obj.
readonly_prop = daqgate('privatereadonly', obj);

% Add the ChannelSkew property to the readonly_prop list if 
% ChannelSkewMode is not Manual.
skewindex = find(strcmp({'channelskewmode'}, lower([prop{:}])));
if ~isempty(skewindex)
   if ~strcmp(get(obj, 'ChannelSkewMode'), 'Manual')
      readonly_prop = {readonly_prop{:} 'ChannelSkew'};
   end
end


% Remove them from the prop list.
for i = 1:length(readonly_prop)
   index = find(strcmp(readonly_prop{i}, [prop{:}]));
   if ~isempty(index)
      prop(index)=[];
      index = [];
   end
end

% *************************************************************
% Create the comments for the beginning of the M-file.
function localSetComment(fid,file,class,name,prefix)

fprintf(fid, [ '%%' upper(file) ' M-Code for creating ' prefix ' ' class ' object.\n',...
   '%%    \n',...
   '%%    This is the machine generated representation of ' prefix ' ' class  ' object.\n',...
   '%%    This M-file, ' upper(file) '.M, was generated from the OBJ2MFILE function.\n',...
   '%%    A MAT-file is created if the object''s UserData property is not empty or\n',...
   '%%    if any of the *Callback properties are set to a cell array.  The MAT-file \n',...
   '%%    will have the same name as the M-file but with a .MAT extenstion.  To \n',...
   '%%    recreate this ' class ' object, type the name of the M-file, ' upper(file) ', \n',...
   '%%    at the MATLAB command prompt.\n',...
   '%%    \n',...
   '%%    The M-file, ' upper(file) '.M and its associated MAT-file, ',...
          upper(file) '.MAT (if it \n',...
   '%%    exists) must be on your MATLAB PATH.  For additional information\n',...
   '%%    on setting your MATLAB PATH, type ''help addpath'' at the MATLAB \n',...
   '%%    command prompt.\n',...
   '%%    \n',...
   '%%    Example: \n',...
   '%%       ' name ' = ' file ';\n',...
   '%%    \n',...
   '%%    See also ANALOGINPUT, ANALOGOUTPUT, DIGITALIO, ADDCHANNEL, ADDLINE, \n',...
   '%%    DAQHELP, PROPINFO.\n',...
   '%%    \n\n']);




