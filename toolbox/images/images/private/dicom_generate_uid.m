function uid = dicom_generate_uid(uid_type)
%DICOM_GENERATE_UID  Create a globally unique ID.
%   UID = DICOM_GENERATE_UID(TYPE) creates a unique identifier (UID) of
%   the specified type.  TYPE must be one of the following:
%
%      'instance'      - A UID for any arbitrary DICOM object
%      'instance_part' - An instance UID minus the IPT root (not a UID)
%      'ipt_root'      - The root of the Image Processing Toolbox's UID
%      'series'        - A UID for an arbitrary series of DICOM images
%      'study'         - A UID for an arbitrary study of DICOM series
%
%   See also MWGUIDGEN.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2003/08/01 18:10:40 $

ipt_root = '1.3.6.1.4.1.9590.100.1';

switch (uid_type)
case {'ipt_root'}
    
    uid = ipt_root;
    
case {'instance', 'series', 'study'}

    if (isunix)
        
        matlab_instance = get_matlab_instance;
        object_instance = get_object_instance;
        
        uid = [ipt_root '.1.' matlab_instance '.' object_instance];
        
    elseif (ispc)

        guid = dicom_create_guid;
        guid(13) = '';

        while (guid(1) == '0')
            guid(1) = '';
        end
        
        uid = [ipt_root '.1.' guid];
        
    else
        
        error('Images:dicom_generate_uid:unsupportedPlatform', 'Unsupported platform for UID generation.')
        
    end
    
case 'instance_part'
    
    uid = get_object_instance;
    
otherwise
    
    error('Images:dicom_generate_uid:inputValue', 'Illegal argument "%s".', uid_type);
    
end



function uid_part = get_matlab_instance
%GET_MATLAB_INSTANCE   Find the MATLAB instance part of the UID.

persistent machine_part
global uid_root;

% Special section to short-circuit uncompilable code.
if (~isempty(uid_root))
    uid_part = uid_root;
    return
end

if (isempty(machine_part))

    % Create the matlab instance part of the UID.
    if (isunix)
        
        % Get the machine-specific values.
        perl_file = [matlabroot '/toolbox/images/images/private/dicom_get_machine_parts.pl'];
        [status, mach] = unix(['perl ' perl_file ' ' lower(computer)]);

        if (status ~= 0)
            % Print error from Perl script, minus line feeds.
            error('Images:dicom_generate_uid:perlError', mach(1:(end - 2)))
        end
        
        % Remove messages produced during shell initialization.
        pos = max([find(mach == 10) find(mach == 13)]);
        if (~isempty(pos))
            mach(1:pos) = '';
        end
            
        
        % Separate the address/ID and process numbers.
        idx = findstr(mach, ' ');
        
        address = mach(1:(idx - 1));
        process = mach((idx + 1):end);
        
        % Create instance value.
        machine_part = create_machine_part(address, process);
        
    else
        
        error('Images:dicom_generate_uid:unsupportedPlatform', 'UID instance part is supported for UNIX platforms only.')
        
    end

    % Prevent looking for this value multiple times.
    mlock
    
end

uid_part = machine_part;
    


function uid_part = get_object_instance
%GET_OBJECT_INSTANCE   Return the unique timestamp part of the UID.

% Create a timestamp value that repeats just under 274 years and has a
% minimum resolution of about 1/100 sec.
base = sprintf('%0.7f', now);
base(1) = [];
base = strrep(base, '.', '');

% Append a three digit value from a static circular counter.
uid_part = sprintf('%s%03d', base, get_counter_value);



function out = get_counter_value
%GET_COUNTER_VALUE   Increment and return the value of the instance counter.

persistent value

if (isempty(value))
    value = 0;
else
    value = rem((value + 1), 1000);
end

out = value;



function out = create_machine_part(address, process)
%CREATE_MACHINE_PART   Create a UID segment from components.

if (length(address) == 12)
    
    % Convert MAC address.  They are always 12 hex values.
    id_part = sprintf('%08.0f%08.0f', sscanf(address(1:6), '%x'), ...
                                       sscanf(address(7:12), '%x'));
    
else
    
    % Convert 32-bit host ID.
    os_id = address(1:2);
    
    id_part = sprintf('%010.0f', sscanf(address(3:end) , '%x'));
    id_part = [os_id id_part];
    
end

% Create a 6-digit process number.
process_pad = repmat('0', [1, (6 - length(process))]);
process_part = [process_pad process];

% Put it all together.
out = [id_part process_part];
