function obj2mfile(objects, filename, varargin)
%OBJ2MFILE Convert instrument object to MATLAB code.
%
%   OBJ2MFILE(OBJ,'FILENAME') converts the instrument object, OBJ, 
%   to the equivalent MATLAB code using the SET syntax and saves the
%   MATLAB code to the specified file, FILENAME. If an extension is 
%   not specified, the .m extension is used. By default, only those
%   properties that are not set to their default values are written 
%   to the file, FILENAME. OBJ can be a single instrument object or
%   an array of instrument objects.
%
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX') converts the instrument object, 
%   OBJ, to the equivalent MATLAB code using the specified SYNTAX and
%   saves the code to the file, FILENAME. The SYNTAX can be either 'set'
%   or 'dot'. By default, the 'set' SYNTAX is used.
%
%   OBJ2MFILE(OBJ,'FILENAME','MODE')
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX','MODE') saves the equivalent MATLAB 
%   code for all properties if MODE is 'all' and saves only the properties
%   that are not set to their default values if MODE is 'modified'. By
%   default, the 'modified' MODE is used.
%
%   OBJ2MFILE(OBJ,'FILENAME','REUSE')
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX','MODE','REUSE') checks for an 
%   existing instrument object, OBJ, before creating OBJ. If REUSE is
%   'reuse', the object is used if it exists otherwise the object is
%   created. If REUSE is 'create', the object is always created. By 
%   default, REUSE is 'reuse'.
%
%   An object will be re-used if the object had the same constructor 
%   arguments as the object about to be created and the Type and Tag 
%   property values are the same.
%
%   If OBJ's UserData is not empty or if any of the callback properties
%   are set to a cell array of values or to a function handle, then the
%   data stored in those properties are written to a MAT-file when the 
%   instrument object is converted and saved. The MAT-file has the same
%   name as the M-file containing the instrument object code.  
%
%   The values of read-only properties will not be restored. Therefore,
%   if an object is saved with a Status property value of open, the 
%   object will be recreated with a Status property value of closed 
%   (the default value). PROPINFO can be used to determine if a property
%   is read-only.
%
%   To recreate OBJ, type the name of the M-file.  
%
%   Example:
%       g = gpib('ni', 0, 2);
%       set(g, 'Tag', 'mygpib', 'EOSMode', 'read', 'EOSCharCode', 'CR');
%
%       % To save g:
%       obj2mfile(g, 'mygpib.m', 'dot', 'all');
%
%       % To recreate g:
%       copyOfG = mygpib;
%
%   See also INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.14.2.7 $  $Date: 2004/01/16 20:01:09 $

if nargin > 5
	error('instrument:obj2mfile:invalidSyntax', 'Too many input arguments.');
end

% Error checking.
if ~isa(objects, 'instrument')
    error('instrument:obj2mfile:invalidOBJ','OBJ must be an instrument object.');
end

if ~all(isvalid(objects))
   error('instrument:obj2mfile:invalidOBJ','Instrument object OBJ is an invalid object.');
end

% Initialize variables.
name = inputname(1);
time = datestr(now);
createmat = 0;
writemat = 0;

% Set up the filename and syntax variables from the provided input.
switch nargin
case 0
   error('instrument:obj2mfile:invalidSyntax','OBJ must be specified.');
case 1
   error('instrument:obj2mfile:invalidSyntax','FILENAME must be specified.');
case 2
   % Ex. obj2mfile(obj, 'sydney.m');
   syntax     = 'set';
   definelist = 'modified';
   reuse      = 'reuse';
case 3  
  if ~ischar(varargin{1})
	  error('instrument:obj2mfile:invalidArg','The third input argument must be a string.');
  end
  if strcmp(lower(varargin{1}), 'all')
      % Ex. obj2mfile(obj, 'sydney.m', 'all')
      syntax     = 'set';
      definelist = 'all';
      reuse      = 'reuse';
  elseif strcmp(lower(varargin{1}), 'modified')
      % Ex. obj2mfile(obj, 'sydney.m', 'modified');
      syntax     = 'set';
      definelist = 'modified';
      reuse      = 'reuse';
  elseif strcmp(lower(varargin{1}), 'set')
      % Ex. obj2mfile(obj, 'sydney.m', 'set');
      syntax     = 'set';
      definelist = 'modified';
      reuse      = 'reuse';
  elseif strcmp(lower(varargin{1}), 'dot')
      % Ex. obj2mfile(obj, 'sydney.m', 'dot');
      syntax     = 'dot';
      definelist = 'modified';
      reuse      = 'reuse';
  else
      % Ex. obj2mfile(obj, 'sydney.m', 'reuse');
      reuse      = varargin{1};
      syntax     = 'set';
      definelist = 'modified';
  end
case 4
   % Ex. obj2mfile(obj, 'sydney.m', 'dot', 'all');
   syntax     = lower(varargin{1});
   definelist = lower(varargin{2});
   reuse      = 'reuse';
case 5
   % Ex. obj2mfile(obj, 'sydney.m', 'dot', 'all', 'reuse');
   syntax     = lower(varargin{1});
   definelist = lower(varargin{2});
   reuse      = lower(varargin{3});
end

% Error checking.
if ~isa(objects, 'instrument')
   error('instrument:obj2mfile:invalidOBJ','OBJ must be an instrument object.');
end

if ~ischar(filename)
	error('instrument:obj2mfile:invalidFILENAME','FILENAME must be a string.');
end
   
% Setup the filename variables from the provided input.
% filename    - contains the path with the extension.
% file        - filename no path or extension
% matfilename - name of the mat file - if one is to be created.
[filename file matfilename] = localBreakName(filename);

% Determine if correct parameters were passed.
if ~ischar(definelist)
   error('instrument:obj2mfile:invalidMODE','Invalid MODE specified. Valid MODE are ''modified'' and ''all''.');
end

if isempty(strmatch(syntax, {'set','dot'}))
   error('instrument:obj2mfile:invalidSYNTAX','Invalid SYNTAX specified. Valid SYNTAX are ''dot'' and ''set''.');
end

if isempty(strmatch(definelist, {'modified', 'all'}))
   error('instrument:obj2mfile:invalidMODE','Invalid MODE specified. Valid MODE are ''modified'' and ''all''.');
end

if isempty(strmatch(reuse, {'reuse', 'create'}))
   error('instrument:obj2mfile:invalidREUSE','Invalid REUSE specified. Valid REUSE are ''reuse'' and ''create''.');
end

% Convert the array of objects to a cell array.
[allObjects, okToOutput] = localExtractObjects(objects);

% Determine if a MAT-File needs to be created.
for i = 1:length(allObjects)
    % Get the next object.
    obj = allObjects{i};
	allvalue = get(obj);

	% Determine if UserData is set.
	if ~isempty(allvalue.UserData)
	    createmat = 1;
    end

    % Loop through the properties and determine if the fcn property
    % is set to a cell array.
	if createmat == 0
        fcnVals = get(obj, localFindFcnProp(obj));
    	for j = 1:length(fcnVals)
          	if (iscell(fcnVals{j}) || isa(fcnVals{j}, 'function_handle'))
               	createmat = 1;
               	break;
            end
        end
    end
    
    % Break out of outer FOR loop if MAT-file needs to be created.
    if createmat == 1
        break;
    end
end

% Open the file.
fid = fopen(filename, 'w');

% Check if the file was opened successfully.
if (fid < 3)
   error('instrument:obj2mfile:invalidFile', [filename ' could not be opened.']);
end

% Write function line and comments to the file.
fprintf(fid, 'function out = %s\n', file);
localSetComment(fid, file, 'instrument', name);

% Write a comment indicating when the file was created.
fprintf(fid, '\n');
fprintf(fid, '%%   Creation time: %s\n\n', time);

% Write command regarding MAT-file.
if createmat
   fprintf(fid, '%% Load the MAT-file which contains UserData and callback property values.\n');
   fprintf(fid, 'load %s\n\n', matfilename);
end

% Initialize object name. Used to initialize lastObjName. Need to store
% the last object name for device object constructor creation.
objName = '';

for i = 1:length(allObjects)
    % Get the next object.
    obj = allObjects{i};
    jobject = igetfield(obj, 'jobject');
    
    % If the object was assigned a variable name use it, otherwise use
    % the default name of obj<index>.
    lastObjName = objName;
    objName     = char(getVariableName(jobject));
    if isempty(objName)
        objName = ['obj' num2str(i)];
    end
    
    % Determine if the next object has already been created.
    for j = 1:i
        if (isequal(allObjects{j}, obj))
            break;
        end
    end

    if (j ~= i)
        % Don't need to create the object. It has already been created.        
       	% Write the command for creating the object.
    	if (i ~= 1)
            fprintf(fid, '\n'); 
        end
		fprintf(fid, '%% Create the instrument object.\n');
        fprintf(fid, '%s = obj%d;\n', objName, j);
    else	
        % Determine the properties to save based on the definelist -
        % whether the user is saving all values or just those that
        % are not set to their default values.
        [prop, allvalue] = localGetPropertiesToSave(obj, definelist);
        
      	% Write the command for creating the object.
    	if (i ~= 1)
            fprintf(fid, '\n'); 
        end
        
        % Write the constructor - varies based on if the object is an interface
        % object or a device object.
        if isa(java(jobject), 'com.mathworks.toolbox.instrument.Instrument')
            % icinterface object, e.g. serial, gpib, visa.
            if strcmp(reuse, 'reuse')
                fprintf(fid, '%% Determine if the object has been created.\n');
                fprintf(fid, '%s = instrfind%s\n\n', objName, char(jobject.getInstrfindArgs));
                fprintf(fid, '%% If the object has not been created, create it otherwise use\n');
                fprintf(fid, '%% the object that was found.\n');
                fprintf(fid, 'if isempty(%s)\n', objName);
     	        fprintf(fid, '    %s = %s\n', objName, char(jobject.getConstructor));                  
                fprintf(fid, 'else\n');
                fprintf(fid, '    fclose(%s);\n', objName);
                fprintf(fid, '    %s = %s(1);\n', objName, objName);
                fprintf(fid, 'end\n');
            else
          		fprintf(fid, '%% Create the instrument object.\n');    
    	        fprintf(fid, '%s = %s\n', objName, char(jobject.getConstructor));  
            end
            isDevice = false;
        else
            % Device object.
            command = char(jobject.getConstructor);
            command = strrep(command, 'HWOBJ', lastObjName);
            
            if strcmp(reuse, 'reuse')                
                fprintf(fid, '%% Determine if the object has been created.\n');
                fprintf(fid, '%s = instrfind%s\n\n', objName, char(jobject.getInstrfindArgs));
                fprintf(fid, '%% If the object has not been created, create it otherwise use\n');
                fprintf(fid, '%% the object that was found.\n');
                fprintf(fid, 'if isempty(%s)\n', objName);
     	        fprintf(fid, '    %s = %s\n', objName, command);                  
                fprintf(fid, 'else\n');
                fprintf(fid, '    disconnect(%s);\n', objName);
                fprintf(fid, '    %s = %s(1);\n', objName, objName);
                fprintf(fid, 'end\n');
            else
          		fprintf(fid, '%% Create the instrument object.\n');    
    	        fprintf(fid, '%s = %s\n', objName, command);  
            end
            isDevice = true;
        end
        
		% Write the property configure commands to file.
        localWriteConfigurePropsComment(fid, prop);
        writemat = localWriteObjectToFile(fid, objName, i, syntax, prop, allvalue, matfilename, writemat);
        
        % If a device object, determine if there are device input and 
        % output objects to save.
        if (isDevice)
            allgroups = jobject.getPropertyGroups;
            
		    for k=0:allgroups.size-1
                groupname = allgroups.elementAt(k);
	            group     = allvalue.(groupname);       
	                      
                % Write the comment for extracting the group objects.
                fprintf(fid, '\n');
                fprintf(fid, '%% Configure the %s object(s).\n', groupname);
                switch (syntax)
                case 'set'
                    fprintf(fid, '%s = get(%s, ''%s'');\n', groupname, objName, groupname);
                case 'dot'
                    fprintf(fid, '%s = %s.%s;\n', groupname, objName, groupname);
                end

                % Loop through each input object and write out it's properties.    
                for x=1:length(group)
                    % Get the properties to configure.
                    [prop, groupallvalue] = localGetPropertiesToSave(group(x), definelist);  
                    name = [lower(groupname) num2str(x)];
                    
                    % Write comment for getting the input object being configured.
                    localWriteConfigurePropsComment(fid, prop);
                    fprintf(fid, '%s = %s(%d);\n', name, groupname, x);    
                    
                    % Configure properites.
                    writemat = localWriteObjectToFile(fid, name, i, syntax, prop, groupallvalue, matfilename, writemat);
                end
            end
        end
    end    
end   

% Create a list of all the objects created.
objName = '';
for i = 1:length(allObjects)
    % Use the user defined object name (from the Object Exporter)
    % otherwise use the default name of obj<index>.
    tempName = char(getVariableName(igetfield(allObjects{i}, 'jobject')));
    if isempty(tempName)
        tempName = ['obj' num2str(i)];
    end
    
    % Construct array of output arguments.
    if okToOutput(i) == true
        objName = [objName ' ' tempName];
    end
end
objName = objName(2:end);

% Output the Instrument Control object if an output variable is specified.
fprintf(fid, '\n');
fprintf(fid, 'if nargout > 0 \n');
fprintf(fid, '    out = [%s]; \n', objName);
fprintf(fid, 'end\n');

% Close the file.
fclose(fid);

% ------------------------------------------------------------------
% Extract the objects that need to be saved.
function [allObjects, okToOutput] = localExtractObjects(objects)

% Initialize variables.
structInfo = struct(objects);
allObjects = cell(1,length(objects));
count      = 1;

% Convert constructors to cell if need to.
constructors = structInfo.constructor;
if ~iscell(constructors)
    constructors = {constructors};
end

% Loop through the objects and determine if the object contains another object
% that needs to be saved.
for i=1:length(objects)
    nextObject = feval(constructors{i}, structInfo.jobject(i));
    if isa(nextObject, 'icdevice')
        % A device object that uses a MathWorks Instrument Driver has an
        % associated instrument object with it that needs to be saved.
        hwObject = get(nextObject, 'Interface');
        if isa(hwObject, 'instrument')
            allObjects{count} = hwObject;
            okToOutput(count) = false;
            count= count+1;
        end        
    end
    allObjects{count} = nextObject;
    okToOutput(count) = true;
    count = count+1;
end

% ------------------------------------------------------------------
% Determine the properties to save.
function [prop, allvalue] = localGetPropertiesToSave(obj, definelist)

% Determine the properties that must be written out. 
switch definelist
case 'modified'
    % Properties that need to be set.
    prop = localFindProp(obj);

case 'all'
    % Obtain all the property names for the given object.
    default = propinfo(obj);

    temp = fieldnames(default);

    % Convert the properties to a cell array of cells.
    prop = cell(1,length(temp));
    for j = 1:length(temp)
        prop{j} = temp(j);
    end
end

% Remove the read-only properties from the prop cell array.
if ~isempty(prop)
    prop = localReadOnly(obj, prop);
end

% Get the object's current state.
allvalue = get(obj);
 
% ------------------------------------------------------------------
% Determine the properties that are not set to their default values.
function list = localFindProp(obj)

list = {};
info = propinfo(obj);

% Obtain the all the property names for the given object.
fields = fieldnames(info);

for i = 1:length(fields)
    if ~isequal(get(obj, fields{i}), info.(fields{i}).DefaultValue)
        list = {list{:} fields(i)};
    end
end

% ------------------------------------------------------------------
% Removes the read-only properties from cell array prop.
function prop = localReadOnly(obj, prop)

% Get the read-only properties for obj.
readonly_prop = localFindReadOnlyProp(obj);

% Remove them from the prop list.
for i = 1:length(readonly_prop)
   index = find(strcmp(readonly_prop{i}, [prop{:}]));
   if ~isempty(index)
      prop(index)=[];
      index = [];
  end
end

% ------------------------------------------------------------------
% Determine the properties that are read-only.
function out = localFindReadOnlyProp(obj)

% Determine the read-only properties.
value = propinfo(obj);
names = fieldnames(value);

% Convert 1-by-1 struct to a number_of_prop-by-1 cell array.
value1 = struct2cell(value);

% Convert the number_of_prop-by-1 cell array to a 1-by-number_of_prop
% structure.
h=[value1{:}];

% Find the read-only properties.
out = names(find(strcmp({h.ReadOnly}, 'always')));

% TCPIP and UDP LocalPort is not configured to [].
if any(strcmp(get(obj, 'Type'), {'tcpip', 'udp'}))
    if isempty(get(obj, 'LocalPort'))
        out{end+1} = 'LocalPort';
    end
end

% ------------------------------------------------------------------
% Determine the properties that are callback properties.
function out = localFindFcnProp(obj)

% Determine the read-only properties.
value = propinfo(obj);
names = fieldnames(value);

% Convert 1-by-1 struct to a number_of_prop-by-1 cell array.
value1 = struct2cell(value);

% Convert the number_of_prop-by-1 cell array to a 1-by-number_of_prop
% structure.
h=[value1{:}];

% Find the read-only properties.
out = names(find(strcmp({h.Constraint}, 'callback')));

% ------------------------------------------------------------------
% Determine the filename with and without the extension
% and path to be used when saving the M-file and when 
% writing the function line
function [filename, file, matfilename] = localBreakName(filename)

[path, file, ext] = fileparts(filename);

% If an extension was not given add '.m' to the filename.
if isempty(ext)
   filename = [file '.m'];   
else
   filename = [file ext];
end

% Create the matfilename.
matfilename = [file '.mat'];

% If a path was given add it to the filename.
if ~(isempty(path))
   filename    = [path filesep filename];
   matfilename = [path filesep matfilename];
end

% ------------------------------------------------------------------
% Write a comment to the file indicating properties will be configured.
function localWriteConfigurePropsComment(fid, prop)

fprintf(fid, '\n');
if length(prop) > 0
   fprintf(fid, '%% Set the property values.\n');
end

% ------------------------------------------------------------------
% Write the property configuration commands to the file.
function writemat = localWriteObjectToFile(fid, objName, count, syntax, prop, allvalue, file, writemat)

switch syntax
case 'set'  
    for j = 1:length(prop)
        value = allvalue.(prop{j}{:});
        if strcmp(lower(prop{j}), 'userdata')
            if ~isempty(value)
                % UserData property is set to a value.
             	% Create a variable (same name as the property) equal to 
             	% the property value. Save to a MAT-file.
                varname = ['userdata' num2str(count)];
                writemat = localSaveToMATFile(file, writemat, varname, value);
                
                fprintf(fid, 'set(%s, ''UserData'', %s);\n', objName,varname);
            else
                fprintf(fid, 'set(%s, ''UserData'', []);\n', objName);
            end
            continue;
        end
        
        if isnumeric(value)&&isempty(value)
            % Property value is empty.
            fprintf(fid, 'set(%s, ''%s'', []);\n',objName,prop{j}{:});
        elseif isnumeric(value)&& length(value) == 1
            % Property value is a single number.
            fprintf(fid, 'set(%s, ''%s'', %g);\n',objName,prop{j}{:}, value);
        elseif isnumeric(value)&&length(value)>1
            % Property value is a numeric vector.
            % Create %g %g string and remove the trailing space.
            numd = repmat('%g ',1, length(value));
            numd = numd(1:end-1);
            fprintf(fid,['set(%s, ''%s'', [' numd ']);\n'],objName,prop{j}{:},value);
        elseif (iscell(value) || isa(value, 'function_handle'))
            % Fcn property is set to a cell.
            % Create a variable (same name as the property) equal to 
            % the property value.
            varname = [lower(prop{j}{:}) num2str(count)];
            writemat = localSaveToMATFile(file, writemat, varname, value);
	
            % Write command to file.
            fprintf(fid, 'set(%s, ''%s'', %s);\n',objName,prop{j}{:},varname);
        else
            % Property value is a string.
            fprintf(fid, 'set(%s, ''%s'', ''%s'');\n', objName,prop{j}{:},value);
        end
    end
case 'dot'
    for j = 1:length(prop)
        value = allvalue.(prop{j}{:});
        if strcmp(lower(prop{j}), 'userdata')
            if ~isempty(value)
                % UserData property is set to a value.
             	% Create a variable (same name as the property) equal to 
             	% the property value.
                varname = ['userdata' num2str(count)];
                writemat = localSaveToMATFile(file, writemat, varname, value);
		
                fprintf(fid, '%s.UserData = %s;\n', objName, varname);
            else
                fprintf(fid, '%s.UserData = [];\n', objName);
            end
            break;
        end
    
        if isnumeric(value)&&isempty(value)
            % Property value is empty.
            fprintf(fid, '%s.%s = [];\n', objName, prop{j}{:});
        elseif isnumeric(value)&&length(value)==1
            % Property value is a single number.
            fprintf(fid, '%s.%s = %d;\n', objName,prop{j}{:}, value);
        elseif isnumeric(value)&&length(value)>1
            % Property value is a numeric vector.
            % Create %g %g string and remove the trailing space.
            numd = repmat('%g ', 1, length(value));
            numd = numd(1:end-1);
            fprintf(fid,['%s.%s = [' numd '];\n'],objName,prop{j}{:},value);
        elseif (iscell(value) || isa(value, 'function_handle'))
            % Fcn property is set to a cell.
            % Create a variable (same name as the property) equal to 
            % the property value.
            varname = [lower(prop{j}{:}) num2str(count)];
            writemat = localSaveToMATFile(file, writemat, varname, value);
               
            % Write command to file.
            fprintf(fid, '%s.%s = %s;\n',objName,prop{j}{:}, varname);
        else
            % Property value is a string.
            fprintf(fid, '%s.%s = ''%s'';\n',objName,prop{j}{:}, value);
        end
    end
end

% ------------------------------------------------------------------
% Save value to MAT-file.
function writemat = localSaveToMATFile(file, writemat, varname, value)

eval([varname ' = value;'])
  
% Save to a new MAT-file or append to an existing MAT-file.
if writemat
    % MAT-File exists.
    save(file, varname, '-append');
else
    % Create new MAT-file.
    save(file, varname);
    writemat = 1;
end

% ------------------------------------------------------------------
% Create the comments for the beginning of the M-file.
function localSetComment(fid, file, type, name)

fprintf(fid,['%%' upper(file) ' M-Code for creating an ' type ' object.\n',...
   '%%   \n',...
   '%%   This is the machine generated representation of an ' type ' object.\n',...
   '%%   This M-file, ' upper(file) '.M, was generated from the OBJ2MFILE function.\n',...
   '%%   A MAT-file is created if the object''s UserData property is not \n',...
   '%%   empty or if any of the callback properties are set to a cell array  \n',...
   '%%   or to a function handle. The MAT-file will have the same name as the \n',...
   '%%   M-file but with a .MAT extension. To recreate this ', type, ' object,\n',...
   '%%   type the name of the M-file, ' file ', at the MATLAB command prompt.\n',...
   '%%   \n',...
   '%%   The M-file, ' upper(file) '.M and its associated MAT-file, ',...
         upper(file) '.MAT (if \n',...
   '%%   it exists) must be on your MATLAB PATH. For additional information\n',...
   '%%   on setting your MATLAB PATH, type ''help addpath'' at the MATLAB \n',...
   '%%   command prompt.\n',...
   '%%   \n',...
   '%%   Example: \n',...
   '%%       ' name ' = ' file ';\n',...
   '%%   \n',...
   '%%   See also SERIAL, GPIB, VISA, TCPIP, UDP, INSTRHELP, INSTRUMENT/PROPINFO.\n',...
   '%%   \n']);
