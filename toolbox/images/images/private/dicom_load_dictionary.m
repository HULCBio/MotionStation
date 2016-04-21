function [tags, values] = dicom_load_dictionary(dictionary)
%DICOM_LOAD_DICTIONARY  Load the DICOM data dictionary into MATLAB

% Lines in the data dictionary file have the form:
%
% # Comment
% (ABCD,EFO1) \t VR1/VR2/... \t BlanklessName \t VM \n
%
% VM can be a scalar or range (e.g., 1, 3, 1-3, 3-n)

% The data dictionary in memory is stored as a structure array with one
% entry in the struct for each attribute in the data dictionary.
% Attributes in repeating classes are expanded into the 128 attributes for
% the class.
%
% The entries of the associated 65536-by-65536 sparse lookup table are
% nonzero if a group and element combination correspond to an attribute
% in the data dictionary.  The DICOM data dictionary is zero-based, so
% the indices for tag (0x0008,0x0010) are (9,17).  Thus, entry (9,17) in
% the sparse array contains the index for attribute (0008,0010) in the
% struct, or 0 if it isn't in the dictionary.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/01 16:12:04 $

if (findstr('.mat', dictionary))
    
    load(dictionary);
    return
    
end

MAX_GROUP = 65535;   % 0xFFFF
MAX_ELEMENT = 65535;  % 0xFFFF

values = struct([]);

count = 0;

%
% Read the dictionary.
%
fmt = '(%4c,%4c)\t%s%s%s';
[group, element, vr, name, vm] = textread(dictionary, fmt, ...
                                         'commentstyle', 'shell');

%
% Remove duplicate entries from the list.  Keep the last.
%

% Concatenate group and element to make the elements be sorted uniquely.
ge = [group element];

% UNIQUE has the property of sorting rows and keeping the last
% duplicate.  This is yields the desired behavior of removing entries
% from the data dictionary which have been superceded by later entries.
[ge_sorted, idx] = unique(ge, 'rows');

% Separate the sorted group and element values.
group = ge_sorted(:, 1:4);
element = ge_sorted(:, 5:8);

% Sort and remove duplicates from the value fields using the index from
% UNIQUE.
name = name(idx);
vr = vr(idx);
vm = vm(idx);

%
% Process VR, VM
%

for p = 1:length(vr)
    
    % VR.
    
    if (~isempty(findstr(vr{p}, '/')))
        % Multiple potential VR's.
        
        tmp_vr = tokenize(vr{p}, '/');
        
        for q = 1:length(tmp_vr)
            if (length(tmp_vr{q}) ~= 2)
                eid = sprintf('Images:%s:invalidVR', mfilename);
                msg = sprintf('Invalid VR "%s" for attribute (%04s,%04s).', ...
                              vr{p}, group(p,:), element(p,:));
                
                error(eid, '%s', msg);
            end
        end
        
        vr{p} = tmp_vr';
        
    else
        % Single VR value.
        
        if (length(vr{p}) ~= 2)
            eid = sprintf('Images:%s:invalidVR', mfilename);
            msg = sprintf('Invalid VR "%s" for attribute (%04s,%04s).', ...
                          vr{p}, group(p,:), element(p,:));
            
            error(eid, '%s', msg);
        end

    end

    %
    % VM.
    %
    
    % Look for range.
    h_pos = findstr(vm{p}, '-');

    if (~isempty(h_pos))
        % VM is a range.
        
        if ((length(h_pos) > 1) || ...
            (h_pos(1) == 1) || ...
            (h_pos(end) == length(vm{p})))
            
            eid = sprintf('Images:%s:invalidVM', mfilename);
            msg = sprintf('Invalid VM "%s" for attribute (%04s,%04s).', ...
                          vm{p}, group(p,:), element(p,:));
            
            error(eid, '%s', msg);
        end
    
        vm_low = vm{p}(1:(h_pos - 1));
        vm_low = sscanf(vm_low, '%d');
        
        vm_high = vm{p}((h_pos + 1):end);
        
        if (findstr(lower(vm_high), 'n'))
            vm_high = inf;
        else
            vm_high = sscanf(vm_high, '%d');
        end
        
        if (isempty(vm_low) || isempty(vm_high))
            
            eid = sprintf('Images:%s:invalidVM', mfilename);
            msg = sprintf('Invalid VM "%s" for attribute (%04s,%04s).', ...
                          vm{p}, group(p,:), element(p,:));
            
            error(eid, '%s', msg);
        end
        
        vm{p} = [vm_low vm_high];
        
    else
        % VM is scalar.
        tmp = sscanf(vm{p}, '%d');
    
        if (isnan(tmp))
            
            eid = sprintf('Images:%s:invalidVM', mfilename);
            msg = sprintf('Invalid VM "%s" for attribute (%04s,%04s).', ...
                          vm{p}, group(p,:), element(p,:));
            
            error(eid, '%s', msg);
        else
            vm{p} = [tmp tmp];
        end
        
    end
    
end  % for p ...

%
% Handle the repeating classes before storing the rest.
% - All of these classes will have a group or element ending in 'xx'.
% - The spec says that new repeating classes are not to be introduced.
%   Sequences will be used instead.
% - The range for these values is always 00 to ff (e.g., 5000 - 50ff).
% - Only even group values are part of the repeating group (odd ones are
%   private, of course).  Repeating elements, on the other hand, can be
%   either odd or even.
% - Technically these classes have the same name in the data dictionary,
%   but we need to uniquely identify them when placing them in the
%   structure.
% - See PS 3.5-2000 Sec. 7.6 for information on repeating groups.
% - Repeating elements are an evil construction present in ACR-NEMA only.
%

% Find repeating groups and elements.
rep_group = strmatch('xx', fliplr(group));
rep_element = strmatch('xx', fliplr(element));

% Number of all attributes is (regular + repeating).
count_rep_classes = length(rep_group) + length(rep_element);
count_expanded = 128*length(rep_group) + 256*length(rep_element);
total_attr = length(vr) + count_expanded - count_rep_classes;

% Preallocate variables.
values(total_attr).Name = 'TEMP PLACEHOLDER';
values(total_attr).VR = {''};
values(total_attr).VM = 0;

rows = repmat(0, total_attr, 1);
cols = repmat(0, total_attr, 1);

% Assign values for the Repeating groups.

for p = 1:length(rep_group)

    % Find the offset of the repeating group (e.g., 6000 or 5000).
    offset = sscanf([group(rep_group(p), 1:2) '00'], '%x');
    cur_element = sscanf(element(rep_group(p), 1:4), '%x');
    
    % Place the repeating values in the struct.
    for q = 1:128
        
        count = count + 1;
        
        values(count).Name = [name{rep_group(p)} '_' sprintf('%X', 2*(q-1))];
        values(count).VR = vr{rep_group(p)};
        values(count).VM = vm{rep_group(p)};
 
    end

    % Keep track of group and element values for the allocated attributes.
    rows((count - 127):(count)) = (offset + 1):2:(offset + 256);
    cols((count - 127):(count)) = cur_element + 1;

end

% Repeating elements.

for p = 1:length(rep_element)

    % Find the offset of the repeating element.
    offset = sscanf([element(rep_element(p), 1:2) '00'], '%x');
    cur_group = sscanf(group(rep_element(p), 1:4), '%x');
    
    % Place the repeating values in the struct.
    for q = 1:256
        
        count = count + 1;
        
        values(count).Name = [name{rep_element(p)} '_' sprintf('%X', (q-1))];
        values(count).VR = vr{rep_group(p)};
        values(count).VM = vm{rep_group(p)};
        
    end
    
    % Keep track of group and element values for the allocated attributes.
    rows((count - 255):(count)) = cur_group + 1;
    cols((count - 255):(count)) = (offset + 1):(offset + 256);
    
end

% Don't process the repeating values twice.
group([rep_group; rep_element],:) = [];
element([rep_group; rep_element],:) = [];

name([rep_group; rep_element]) = [];
vr([rep_group; rep_element]) = [];
vm([rep_group; rep_element]) = [];

%
% Store the remainder of the values.
%

group = hex2dec(group);
element = hex2dec(element);

count = count + 1;

rows(count:end) = group + 1;
cols(count:end) = element + 1;

tags = sparse(rows, cols, 1:total_attr, MAX_GROUP + 1, MAX_ELEMENT + 1);

[values(count:total_attr).Name] = deal(name{:});
[values(count:total_attr).VR] = deal(vr{:});
[values(count:total_attr).VM] = deal(vm{:});
