function outputs = mpt_get_data_types(objectType)
%MPT_GET_DATA_TYPES - Returns the enumerated list of data types.
%
%    [OUTPUTS]=MPT_GET_DATA_TYPES(OBJECTTYPE)
%    This function returns the enumerated list of data types 
%    avaialble in the Simulink Data Object.
%
%    Inputs:
%              objectType : Corrsponds to ('Signal' or 'Parameter')
%    Outputs:
%              outputs    : enumerated list of data types to view and
%              select in the data object popup menu
%

%   Linghui Zhang
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:46:32 $
%

outputs = '';
specialOutputs = '';
ver = version('-release');
vernum = str2num(ver);
if vernum >= 14
    mptDataTypes = {'double','single','int8','uint8','int16',...
                    'uint16','int32','uint32', 'boolean'};
else
    mptDataTypes = {'double','single','int8','uint8','int16',...
                    'uint16','int32','uint32', 'boolean', 'fixpt'};
end
if exist('custom_user_type_registration') == 2
    custom_user_type_registration;
    userTypes = rtwprivate('rtwattic', 'AtticData', 'userTypes');
    if isempty(userTypes) == 1
        % default mpt data types
        outputs = mptDataTypes;
    else
        % user registered data types
        for i = 1:length(userTypes)
            if strcmp(userTypes{i}.type,objectType) | strcmp(userTypes{i}.type,'Both')
                outputs{end+1} = userTypes{i}.userName;
            end
        end
    end
end
%Get special user data types
if  exist('get_special_user_data_types','file') == 2
    specialOutputs = get_special_user_data_types(objectType);
    len = length(outputs);
    for i = 1:length(specialOutputs)
        outputs{i+len} = specialOutputs{i};
    end
end

%% Add TMW data types that are not the duplicate (case insensitive) of any user
%  data types in the Enumeration list
temp = lower(outputs);
for i = 1:length(mptDataTypes)
    comm = intersect(temp,mptDataTypes{i});
    if isempty(comm) == 1
        outputs{end+1} = mptDataTypes{i};
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputs = outputs';
return
