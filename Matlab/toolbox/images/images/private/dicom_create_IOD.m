function [attrs, msg, status] = dicom_create_IOD(IOD_UID, X, map, metadata, options)
%DICOM_CREATE_IOD  Create the attributes for a given IOD.
%   [ATTRS, MSG, STATUS] = DICOM_CREATE_IOD(UID, X, MAP, METADATA, TXFR)
%   creates a structure array of DICOM attributes for the SOP Class
%   corresponding to UID.  The attributes' values are bassed on the image
%   X, colormap MAP, the METADATA struct (as given by DICOMINFO, for
%   example), and the transfer syntax UID (TXFR) used to encode the
%   file. 
%   
%   This is the principal function of DICOM information object creation.
%
%   See also DICOMWRITE, DICOM_PREP_METADATA, DICOM_IODS, DICOM_MODULES.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/01 16:12:01 $

attrs = [];
msg = '';
status = [];

% Find modules and other details.
iod_details = get_iod_details(IOD_UID);

if (isempty(iod_details))
    msg = sprintf('Unimplemented IOD (%s)', IOD_UID);
    return;
end

% Set necessary values for this IOD.
metadata = dicom_prep_metadata(IOD_UID, metadata, X, map, options.txfr);

% Look for all of the private metadata.
if (options.writeprivate)
    [private_tags, private_names] = find_private_metadata(metadata);
end

% A module definition function must be registered for unsupported or
% private modules.  Private IODs need only use a custom definition
% function for unimplemented modules, but they must have a definition
% function listed.  (Registration not yet supported.)
if (isempty(iod_details.Def_fcn))
    msg = sprintf('No module definition function for IOD "%s" (%s)', ...
                  iod_details.Name, IOD_UID);
    return;
end

attrs = [];
status = [];
for p = 1:numel(iod_details.Modules(:,1))

    % Determine whether to encode this module.
    if (test_module_condition(metadata, iod_details.Modules(p,:)))
        
        % Find the attributes in the module.
        module_details = dicom_modules(iod_details.Modules{p,1});
        
        if (isempty(module_details))
            msg = sprintf('Module "%s" is undefined', ...
                          iod_details.Modules{p,1});
            return;
        end
        
        % Process attributes.
        [new_attrs, new_status] = process_modules(module_details.Attrs, ...
                                                  metadata);
        attrs = add_to_IOD(attrs, new_attrs);
        status = add_to_status(status, new_status);
        
    end

end

% Process any private metadata.
if ((options.writeprivate) && (~isempty(private_tags)))
    
    new_attrs = process_private(private_tags, private_names, metadata);
    attrs = add_to_IOD(attrs, new_attrs);
    
end
    


function iod_details = get_iod_details(IOD_UID)
%GET_IOD_DETAILS  Find the details of a given IOD.

% Load IOD definitions.
iod_directory = dicom_iods;

% Look for a particular UID.
idx = strmatch(IOD_UID, {iod_directory.UID}, 'exact');

if (isempty(idx))
    iod_details = [];
else
    iod_details = iod_directory(idx);
end



function attrs = add_to_IOD(attrs, new_attrs)
%ADD_TO_IOD  Add attributes to an existing IOD.
attrs = cat(2, attrs, new_attrs);



function status = add_to_status(status, new_status)
%ADD_TO_STATUS  Add status values to an existing status struct.

fnames = fieldnames(new_status);
for p = 1:numel(fnames)
    if (isfield(status, fnames{p}))
        status(1).(fnames{p}) = [status(1).(fnames{p}) ...
                                 new_status(1).(fnames{p})];
    else
        status(1).(fnames{p}) = new_status(1).(fnames{p});
    end
end



function [attrs, status] = process_modules(attr_details, metadata)
%PROCESS_MODULES  Create attributes from a module definition.

attrs = [];
status.BadAttribute = {};
status.MissingCondition = {};
status.MissingData = {};
status.SuspectAttribute = {};

p = 0;
numAttrs = numel(attr_details(:,1));
% For each attribute in the module...
while (p < numAttrs)
    
    p = p + 1;
    
    level = attr_details{p, 1};
    group = attr_details{p, 2};
    element = attr_details{p, 3};
    attr_type = attr_details{p, 4};
    vr_map = attr_details{p, 5};
    enum_values = attr_details{p, 6};
    condition = attr_details{p, 7};
    
    %
    % Look for the attribute from the module.
    %
    try
         name = dicom_name_lookup(group, element);
    catch
        status.BadAttribute{end + 1} = sprintf('(%s,%s)', ...
                                               group, element);
        continue;
    end
    
    if (isempty(name))
        status.BadAttribute{end + 1} = sprintf('(%s,%s)', ...
                                               group, element);
        continue;
    end
    
    %
    % Determine how to handle the attribute.
    %
    switch (attr_type)
    case {'1', '2', '3'}
        % Must process the attribute.  No special action.
        
    case {'1C', '2C'}
        % Conditionally process the attribute.
        if (isempty(condition))
            
            status.MissingCondition{end + 1} = sprintf('(%s,%s)', ...
                                                       group, element);
            continue;
            
        else
            
            if (~check_condition(condition, metadata))
                continue;
            end
            
        end
        
    otherwise
        status.BadAttribute{end + 1} = sprintf('(%s,%s)', group, element);
        continue;
        
    end
 
    % Process special VR mapping.
    if ((isequal(group, '7FE0')) && (isequal(element, '0010')))
        VR = get_pixelData_VR(metadata);
    else
        if (numel(vr_map) == 0)
            VR = '';
        else
            VR = remap_vr(group, element, vr_map, metadata);
        end
    end
    
    %
    % Add the attribute.
    %
    if (isfield(metadata, name))

        % Process acceptable values.
        if ((~isempty(enum_values)) && (~isempty(metadata.(name))))
            if (~check_values(metadata.(name), enum_values))
                status.SuspectAttribute{end + 1} = sprintf('(%s,%s)', ...
                                                           group, element);
            end
        end
        
        % Process sequences.
        %
        % NOTE: At this point, all sequences in supported modules are
        % type 3 (optional).  We can, and will, safely skip all
        % attributes in a sequence (including the top level attribute).
        if (p == numAttrs)
            sequence = false;
        else
            sequence = ~isequal(level, attr_details{p + 1, 1});
        end

        if (sequence)
            % Skip all attributes until level is the same as the level
            % for the current attribute: handles nested sequences.
            q = p + 1;
            while (~isequal(level, attr_details{q, 1}))
                q = q + 1;
            end
        
            p = q;
            continue;
        end
        
        if (isempty(VR))
            attrs = dicom_add_attr(attrs, group, element, ...
                                   metadata.(name));
        else
            attrs = dicom_add_attr(attrs, group, element, ...
                                   metadata.(name), VR);
        end
            
    else

        switch (attr_type)
        case {'1', '1C'}

        % The attribute should exist.
        status.MissingData{end + 1} = sprintf('(%s,%s)', ...
                                              group, element);
        continue;
        
        case {'2', '2C'}
    
            % Nonexistant attributes have empty data.
            attrs = dicom_add_attr(attrs, group, element);
       
        end
        
        % Nonexistent type 3 is ignored.
        
    end
    
end



function tf = check_condition(expr, metadata)
%CHECK_CONDITION  Dtermine whether a particular condition is true.
%
%   Conditions are LISP-style cell arrays.  The first element is a
%   conditional operator, remaining cells are arguments to the operator.
%
%   Conditions can be nested.  Each cell array in expr indicates a new
%   conditional expression.

%
% Error checking
%
if (~iscell(expr))
    eid = sprintf('Images:%s:conditionalsMustBeCellArrays',mfilename);    
    error(eid,'%s','Conditional expressions must be cell arrays.')
end

if (numel(expr) == 1)
    operator = expr{1};
    operands = {};
else
    operator = expr{1};
    operands = expr(2:end);
end


%
% Process conditional expressions recursively.
%
switch (lower(operator))
case 'and'
    
    % This AND short circuits.
    for p = 1:numel(operands)
        tf = check_condition(operands{p}, metadata);
        
        if (~tf)
            return
        end
    end
    
case 'equal'
    
    if (numel(operands) ~= 2)
        eid = sprintf('Images:%s:presentOpNeeds2Args',mfilename);
        error(eid,'%s','The ''present'' operator requires exactly two arguments.')
    end
    
    % Get the group and element from the first operand.
    group = operands{1}(2:5);
    element = operands{1}(7:10);
    
    % Look up the metadata value.
    name = dicom_name_lookup(group, element);

    if (isfield(metadata, name))
        tf = isequal(metadata.(name), operands{2});
    else
        tf = false;
    end

case 'false'
    
    tf = false;
    
case 'not'
    
    if (numel(operands) ~= 1)
        eid = sprintf('Images:%s:tooManyArgsToNot',mfilename); 
        error(eid,'%s','Too many arguments to ''not''.')
    else
        tf = ~check_condition(operands{1}, metadata);
    end
    
case 'or'
    
    % This OR short circuits.
    for p = 1:numel(operands)
        tf = check_condition(operands{p}, metadata);
        
        if (tf)
            return
        end
    end
        
case 'present'

    if (numel(operands) ~= 1)
        eid = sprintf('Images:%s:presentNeeds1Arg',mfilename);
        error(eid,'%s','The ''present'' operator requires exactly one argument.')
    end
    
    % Get the group and element from the first operand.
    group = operands{1}(2:5);
    element = operands{1}(7:10);
    
    % Look up the metadata value.
    name = dicom_name_lookup(group, element);
    
    tf = isfield(metadata, name);
    
case 'true'
    
    tf = true;
    
otherwise
    eid = sprintf('Images:%s:badConditionalOp',mfilename);                    
    error(eid,'Bad conditional operator "%s".', operator)
end



function tf = test_module_condition(metadata, module)
%TEST_MODULE_CONDITIONS   Test whether a module should be created.

moduleType = module{2};
moduleCondition = module{3};

switch (moduleType)
case {'M'}

    tf = true;

case {'U', 'C'}

    if (isempty(moduleCondition))
        tf = false;
        return
    end
    
    switch (moduleCondition{1})
    case 'HAS_FILEMETADATA'
        tf = true;
        
    case 'HAS_BOLUS'
        tf = isfield(metadata, dicom_name_lookup('0018', '0010'));
        
    case 'HAS_OVERLAY'
        tf = isfield(metadata, dicom_name_lookup('6000', '0010'));
        
    case 'HAS_VOILUT'
        tf = ((isfield(metadata, dicom_name_lookup('0028', '3010'))) || ...
              (isfield(metadata, dicom_name_lookup('0028', '1050'))));
        
    case 'TRUE'
        tf = true;
        
    case 'FALSE'
        tf = false;
        
    otherwise
        tf = false;
        
    end
    
otherwise
    eid = sprintf('Images:%s:unknownModuleType',mfilename);
    error(eid,'Unknown module type "%s".', moduleType)
    
end



function VR = remap_vr(group, element, vr_map, metadata)
%REMAP_VR   Translate a VR mapping into a VR value.

% Default behavior is an empty VR.
VR = '';

if (numel(vr_map) > 1)
    
    % First item in VR map is an attribute tag.
    cond_name = dicom_name_lookup(vr_map{1}(2:5), vr_map{1}(7:10));
    
    % Remaining items map the conditional attribute's value to a VR.
    if (isfield(metadata, cond_name))

        for p = 2:numel(vr_map)
            
            if (isequal(metadata.(cond_name), vr_map{p}{1}))
                
                VR = vr_map{p}{2};
                return
                
            end
            
        end
        
    end
       
    % If the condition isn't met (or the attribute isn't present),
    % use the first entry in the attribute's VR list.
    if (isempty(VR))
        
        attr = dicom_dict_lookup(group, element);
        VR = attr.VR;
        
    end
    
elseif (numel(vr_map) == 1)
    
    % Only item in VR map is the VR.
    VR = vr_map{1};
    
end
    


function VR = get_pixelData_VR(metadata)
%GET_PIXELDATA_VR   Get the VR for (7FE0,0010).
%
%  PS 3.5 Sec. 8 contains the rules for picking the VR of (7FE0,0010).

uid_details = dicom_uid_decode(metadata.(dicom_name_lookup('0002','0010')));

if (uid_details.Compressed)
    
    % Compressed pixels are always stored OB.
    VR = 'OB';
    
elseif (isequal(uid_details.VR, 'Implicit'))
    
    % Implicit VR transfer syntaxes are always OW.
    VR = 'OW';
    
else
    
    % The VR of other Explicit VR transfter syntaxes depends on the bit
    % depth of the pixels.
    if (metadata.(dicom_name_lookup('0028','0100')) <= 8)
        VR = 'OB';
    else
        VR = 'OW';
    end
    
end



function tf = check_values(attr_data, enum_values)
%CHECK_VALUE  Verify an attribute's data against required values.

if (iscellstr(enum_values))
    
    tf = any(strcmp(attr_data, enum_values));
    
else
    
    tmp = 0;
    for p = 1:numel(enum_values)
        tmp = tmp + isequal(attr_data, enum_values{p});
    end
    
    tf = (tmp > 0);
    
end



function [private_attrs, private_names] = find_private_metadata(metadata)
%FIND_PRIVATE_METADATA  Find user-contributed private metadata.

% Private attributes have odd element values in their tag.
% 
% By default these values come back from DICOMINFO with field names like
% "Private_0029_1004" and "Private_0029_10xx_Creator".
%
% If a custom data dictionary is provided, the names will look like
% regular DICOM attributes.

private_attrs = {};
private_names = {};

% Look through metadata for private attributes.
fields = fieldnames(metadata);

for p = 1:numel(fields)
    
    tag = dicom_tag_lookup(fields{p});
    
    if ((~isempty(tag)) && (rem(tag(1), 2) ~= 0))
        private_attrs{end + 1} = tag;
        private_names{end + 1} = fields{p};
    end
    
end



function [attrs, status] = process_private(private_tags, private_names, metadata)
%PROCESS_PRIVATE  Create attributes from the private data list.

attrs = [];

status.BadAttribute = {};
status.MissingCondition = {};
status.MissingData = {};
status.SuspectAttribute = {};

for p = 1:numel(private_tags)
    new_attr = dicom_convert_meta_to_attr(private_names{p}, metadata);
    attrs = dicom_add_attr(attrs, private_tags{p}(1), private_tags{p}(2), ...
                           new_attr.Data);
end
