function errflag = privatewritechild(varargin)
%PRIVATEWRITECHILD Convert the channel or line to M-Code.
%
%    PRIVATEWRITECHILD Converts the channel or line to MATLAB code.  
%

%    PRIVATEWRITECHILD is a helper function for @daqdevice\obj2mfile.m
%    and @daqchild\obj2mfile.m

%    MP 6-08-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.14.2.4 $  $Date: 2003/08/29 04:42:32 $

% Initialize variables.
errflag = 0;

% Define the variables from the input.
% fid        - file identifier.
% syntax     - either set, dot or named.
% definelist - either default or all.
% child      - Child object.
% parent     - parent object.
% name       - 'chan'.
% name2      - object's name passed to obj2mfile or 'test'.
% type_child - Child object's type: Channel/Line.
% cmd        - Method name for creating Child object (addchannel, addline).
[fid,syntax,definelist,child,parent,name,name2,type_child,cmd]=deal(varargin{:});

% Write the addchannel or addline command.
hwchan = get(child, {['Hw' type_child]});
fprintf(fid, '%% Create the %s array.\n', type_child);
if strcmp(syntax, 'named')
    % Determine the Channel or Line Names for the addchannel/addline line.
    childname = get(child, {[type_child 'Name']});
    % Error if any of the children objects do not have names.
    if sum(strcmp(childname,''))
        errflag = 1;
        lasterr(['Object''s ' type_child 's must have ' type_child 'Name property ',...
                'values for the ''named'' SYNTAX.']);
    else
        % Write out the addchannel or addline function call with ChannelNames.
        schan = repmat('''%s'' ',1,length(childname));
        schan = schan(1:end-1);
        if isequal(min([hwchan{:}]):max([hwchan{:}]), [hwchan{:}]) && length(hwchan) > 1
            % Write out 1:5 rather than [1 2 3 4 5]
            switch cmd
            case 'addchannel'
                fprintf(fid, ['%s = %s(%s, %g:%g, {' schan '});\n\n' ], name,cmd,name2,...
                    min([hwchan{:}]),max([hwchan{:}]),childname{:});
            case 'addline'
                localWriteAddLine(child,fid,name,cmd,name2,childname);
            end
        else
            hchan = repmat('%d ',1,length(hwchan));
            hchan = hchan(1:end-1);
            switch cmd
            case 'addchannel'
                fprintf(fid, ['%s = %s(%s, [' hchan '], {' schan '});\n\n'],...
                    name,cmd,name2,hwchan{:},childname{:});
            case 'addline'
                localWriteAddLine(child,fid,name,cmd,name2,childname);
            end   
        end
    end
else
    % Write out the addchannel or addline function call without ChannelNames.
    if isequal(min([hwchan{:}]):max([hwchan{:}]), [hwchan{:}]) && length(hwchan) > 1
        % Write out 1:5 rather than [1 2 3 4 5]
        switch cmd
        case 'addchannel'
            fprintf(fid, '%s = %s(%s, %g:%g);\n\n', name,cmd,name2,...
                min([hwchan{:}]), max([hwchan{:}]));
        case 'addline'
            localWriteAddLine(child,fid,name,cmd,name2,'');
        end
    else
        hchan = repmat('%d ',1,length(hwchan));
        hchan = hchan(1:end-1);
        switch cmd
        case 'addchannel'
            fprintf(fid, ['%s = %s(%s, [' hchan ']);\n\n'], name,cmd,name2,hwchan{:});
        case 'addline'
            localWriteAddLine(child,fid,name,cmd,name2,'');
        end
    end
end

% Loop through the children objects and write the necessary commands to file.
structchild = struct(child);
classname = class(child);
for i = 1:length(child)
    % Get access to the object's handle and reconstruct.
    i_child = feval(classname, structchild.handle(i));
    
    % Get the current settings of the object.
    allvalue = get(i_child);
    
    % Create a default child so that the properties not set to their default
    % values can be determined for the 'default' DEFINELIST.
    if i == 1
        switch cmd
        case 'addchannel'
            if isa(parent, 'analogoutput')
                channelID = daqhwinfo(parent, 'ChannelIDs');
            else
                channelID = daqhwinfo(parent, 'DifferentialIDs');
                if isempty(channelID)
                    channelID = daqhwinfo(parent, 'SingleEndedIDs');
                end
            end
            default_child = feval(cmd,parent,channelID(1));
        case 'addline'
            default_child = daqmex(parent, 'dioline',1,0);
        end
        default_child_prop = get(default_child);
               
    end
    
    % Determine the properties that must be written out. 
    switch definelist
    case 'default'
        % properties that need to be set.
        prop = localFindProp(i_child, default_child_prop);
    case 'all'
        temp = fieldnames(allvalue);
        % Convert the properties to a cell array of cells.
        prop = cell(1,length(temp));
        for j = 1:length(temp)
            prop{j} = temp(j);
        end
    end
    
    % Remove the read-only properties from the prop cell array.
    if ~isempty(prop)
        prop = localReadOnly(i_child, prop);
    end
    
    % Remove the HWChannel/HWLine property from the list of properties
    % in prop since HWChannel/HWLine has already been take care of.  
    if ~(isempty(prop))
        prop(strmatch({['hw' lower(type_child)]}, lower([prop{:}]))) = [];
    end
    
    % Remove the ChannelName/LineName property from the list of properties 
    % in prop if the named SYNTAX is used since the channels have been 
    % named in the addchannel/addline command.
    if ~(isempty(prop)) && strcmp(syntax, 'named')
        prop(strmatch({[lower(type_child) 'name']}, lower([prop{:}]))) = [];
    end
    
    % Add a comment indicating which channel is being set.
    if ~(isempty(prop))
        switch definelist
        case 'default'
            fprintf(fid, '%%Set %s %d''s non-default properties.\n', type_child, i);
        case 'all'
            fprintf(fid, '%%Set %s %d''s properties.\n', type_child, i);
        end
    end
    
    % Write MATLAB commands to file.
    switch syntax
    case 'set'  
        for j = 1:length(prop)
            value = getfield(allvalue, prop{j}{:});
            if isnumeric(value) && length(value) == 1
                % Property value is a single number.
                fprintf(fid, 'set(%s(%d), ''%s'', %g);\n',name, i, prop{j}{:}, value);
            elseif isnumeric(value) && length(value)>1
                % Property value is a numeric vector.
                % Create %g %g string and remove the trailing space.
                numd = repmat('%g ',1, length(value));
                numd = numd(1:end-1);
                fprintf(fid,['set(%s(%d), ''%s'', [' numd ']);\n'],name,i,prop{j}{:},value);
            else
                % Property value is a string.
                fprintf(fid, 'set(%s(%d), ''%s'', ''%s'');\n', name,i,prop{j}{:},value);
            end
        end
    case 'dot'
        for j = 1:length(prop)
            value = getfield(allvalue, prop{j}{:});
            if isnumeric(value) && length(value)==1
                % Property value is a single number.
                fprintf(fid, '%s(%d).%s = %d;\n', name,i, prop{j}{:}, value);
            elseif isnumeric(value) && length(value)>1
                % Property value is a numeric vector.
                % Create %g %g string and remove the trailing space.
                numd = repmat('%g ',1, length(value));
                numd = numd(1:end-1);
                fprintf(fid,['%s(%d).%s = [' numd '];\n'],name,i,prop{j}{:},value);
            else
                % Property value is a string.
                fprintf(fid, '%s(%d).%s = ''%s'';\n',name, i, prop{j}{:}, value);
            end
        end
    case 'named'
        % Get the name of the channel.
        objname = getfield(allvalue, [type_child 'Name']);
        
        for j = 1:length(prop)
            value = getfield(allvalue, prop{j}{:});
            if isnumeric(value) && length(value)==1
                % Property value is a single number.
                fprintf(fid, '%s.%s.%s = %d;\n', name2,objname,prop{j}{:},value);
            elseif isnumeric(value) && length(value)>1
                % Property value is a numeric vector.
                % Create %g %g string and remove the trailing space.
                numd = repmat('%g ',1, length(value));
                numd = numd(1:end-1);
                fprintf(fid,['%s.%s.%s = [' numd '];\n'],name2,objname,prop{j}{:},value);
            else
                % Property value is a string.
                fprintf(fid, '%s.%s.%s = ''%s'';\n',name2,objname,prop{j}{:},value);
            end
        end
    end
    fprintf(fid, '\n');
end

% *************************************************************
% Removes the read-only properties from cell array prop.
function prop = localReadOnly(obj, prop)

% Get the read-only properties for obj.
readonly_prop = daqgate('privatereadonly', obj);

% Remove them from the prop list.
for i = 1:length(readonly_prop)
    index = find(strcmp(readonly_prop{i}, [prop{:}]));
    if ~isempty(index)
        prop(index)=[];
        index = [];
    end
end

%*******************************************************************
% Determine the properties that are not set to their default values.
function list = localFindProp(obj, default)

% Obtain the all the property names for the given object.
fields = fieldnames(default);

% Obtain the current values for each field for each object.
default_prop = struct2cell(default);
obj_prop = struct2cell(get(obj));
list = {};

for i = 1:length(default_prop)
    x = (isequal(default_prop{i}, obj_prop{i}) | isequal(fields{i}, 'Direction'));
    if x == 0;
        list = {list{:} fields(i)};
    end
end

%*******************************************************************
% Write the addline commad to the file.
function localWriteAddLine(varargin)

% Parse out the input.
[child,fid,name,cmd,name2,childname] = deal(varargin{:});

% Initialize variables.
writtenLines = 0;
totalLines = length(child);
portId = 0;
validPorts = [];

% Need to write out the addline commands by port number.
while writtenLines < totalLines
    
    portId = child(1).Port;
    
    hLine = daqfind(child, 'Port', portId);
    if ~isempty(hLine)
        hLine = [hLine{:}];
        validPorts = [validPorts [name num2str(portId) ';']];
        
        % Get the HwLines for the specified port.
        hwline = get(hLine, {'HwLine'});

        % Get the directions of the lines.
        if length(hLine) > 1
            directions = hLine.Direction;
        else
            directions = {hLine.Direction};
        end
        
        % Write the command.
        if ~isempty(childname)
            % Get the new LineNames for the specified port.
            newName = get(hLine, {'LineName'});
            
            % Create the '%s %s' string for the LineNames.
            schan = repmat('''%s'' ',1,length(newName));
            schan = schan(1:end-1);
            
            % Write the command with the LineNames.
            if isequal(min([hwline{:}]):max([hwline{:}]), [hwline{:}]) && length(hwline) > 1
                % The HwLines are continuous and can be written as 1:4.
                d = repmat('''%s'', ',1,length(directions));
                d = d(1:end-2);            
                fprintf(fid, ['%s%g = %s(%s, %g:%g, %g, {' d '}, {' schan '});\n'],...
                    name,portId,cmd,name2,min([hwline{:}]),max([hwline{:}]),...
                    portId,directions{:}, newName{:});
            else
                % The HwLines contain gaps and must be written as a vector.
                
                % Create the '%d %d' string for the HwLines.
                h = repmat('%d ',1,length(hwline));
                h = h(1:end-1);
                d = repmat('''%s'', ',1,length(directions));
                d = d(1:end-2);
                
                fprintf(fid, ['%s%g = %s(%s, [' h '], %g, {' d '}, {' schan '});\n'],...
                    name,portId,cmd,name2,hwline{:},portId,directions{:},newName{:});
            end
        else
            % The LineNames are not specified in the addline command.
            if isequal(min([hwline{:}]):max([hwline{:}]), [hwline{:}]) && length(hwline) > 1
                d = repmat('''%s'', ',1,length(directions));
                d = d(1:end-2);
                % The HwLines are continuous and can be written as 1:4.
                fprintf(fid, ['%s%g = %s(%s, %g:%g, %g, {' d '});\n'],...
                    name, portId,cmd,name2, min([hwline{:}]),...
                    max([hwline{:}]), portId, directions{:});
            else
                % The HwLines contain gaps and must be written as a vector.
                h = repmat('%d ',1,length(hwline));
                h = h(1:end-1);
                d = repmat('''%s'', ',1,length(directions));
                d = d(1:end-2);
                fprintf(fid, ['%s%g = %s(%s, [' h '], %g, {' d '});\n'],...
                    name,portId,cmd,name2,hwline{:}, portId, directions{:});
            end
        end
    end
    % Update portId and number of lines written to file.
    writtenLines = writtenLines + length(hLine);
    deleteIndex = [];
    for i = 1:length(child)
        if child(i).Port == portId
            deleteIndex = [deleteIndex i];
        end
    end
    child(deleteIndex) = [];
end

% Concatenate the line arrays together.
validPorts = validPorts(1:end-1);
fprintf(fid, '%s = [%s];\n', name, validPorts);
fprintf(fid, '\n');