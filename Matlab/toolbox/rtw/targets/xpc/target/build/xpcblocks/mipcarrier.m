% mipcarrier - InitFcn for IP carrier blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/25 04:10:06 $
%
%   - checks that no carrier blocks in the model have the same carrier ID
%   - checks that no carrier blocks refer to the same physical carrier
%   - checks for resource conflicts among the IP modules of the model
%   - stores data about the carrier in each IP module's UserData
%
% IP carrier mask types must look like ipCarrier_sbs_flex140a_isa or 
% ipCarrier_sbs_pci40a_pci, i.e. the fourth segment is the bus type of the
% carrier. We also assume that IP module mask types are of the form 
% ipModule_sbs_digital24_resources, where resources is a string of resources 
% p1_p2_p3_... Here p1, p2,... are parameter names representing hardware 
% resources (e.g. port, channel). In this list each resource is treated as a
% subresource of the resource that precedes it. Values p and q of a given 
% parameter are conflicting if they are equal strings (e.g. two ports are both
% set to 'A') or if they are vectors sharing a common element (e.g. two channel
% vectors with a common channel). Two resources strings p1_p2_... and q1_q2_...
% conflict if all of the pairs (p1,q1), (p2,q2)... do. 

% In addition we assume that all carrier blocks and IP module blocks, have a 
% 'carrierId'  parameter and that all IP module blocks have a 'carrierSlot' 
% parameter. We assume that PCI carriers have a 'pciSlot' parameter which is
% either a numeric scalar representing the PCI slot, with an assumed bus 0, 
% or a numeric vector representing the bus and slot. The pciSlot value -1 means
% 'first occupied slot'. We assume that ISA carriers have an 'isaBase'
% parameters taking values of the form '0xhhh', where 'hhh' are hex digits.

function mipcarrier

ipCarriers = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskType', '^ipCarrier.*');
ipModules = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskType', '^ipModule.*');

% Compute the carrier data. 
% Check that no two carrier blocks use the same carrier ID.
% Check that no two carrier blocks refer to the same physical carrier.
% Compute the busType-dependent userData structure for later insertion into IP blocks.
cRec = {}; 
carrierIds = [];
physCarriers = {};
for i = 1:length(ipCarriers)
    try
        carrierId = evalin('caller', get_param(ipCarriers{i}, 'carrierId'));
    catch
        return
    end
    
    if ismember(carrierId, carrierIds)
        error(['Carrier ID ' num2str(carrierId) ' is used by more than one carrier block']);
    else
        carrierIds = union(carrierIds, carrierId);
    end

    maskType = get_param(ipCarriers{i}, 'MaskType');
    segments = split(maskType, '_');
    busType = lower(segments{4});
    
    if busType == 'pci'
        try
            pciData = evalin('caller', get_param(ipCarriers{i},'pciSlot'));
        catch
            return
        end
        if size(pciData, 2) == 1
            pciData = [0 pciData];
        end
        if pciData(2) < 0
            slot = 'minus'; % struct field names can't contain a minus sign
        else 
            slot = num2str(pciData(2));
        end
        bus = num2str(pciData(1)); 
        
        physCarrier = [busType '_' bus '_' slot];
        
        userData.type = 1; 
        userData.isaBase = 0;
        userData.pciBus = pciData(1);
        userData.pciSlot = pciData(2);
        
    elseif busType == 'isa'
        isaBase = get_param(ipCarriers{i}, 'isaBase');
        physCarrier = [busType '_' isaBase];
        
        userData.type = 2; 
        userData.isaBase = hex2dec(isaBase(3:end));
        userData.pciBus = 0;
        userData.pciSlot = 0;
    else
        % unknown bus type
    end;

    % check that no other carrier block already refers to the same physical carrier
    if strmatch(physCarrier, physCarriers, 'exact')
        error(['Duplicate instance of same physical carrier: ' ipCarriers{i}]);
    else
        physCarriers = union(physCarrier, physCarriers);
    end
    
    switch(maskType)
    case 'ipCarrier_sbs_pci40a_pci'
        maxSlot = 4;
    case 'ipCarrier_sbs_flex104a_isa'
        maxSlot = 2;
    otherwise
        maxSlot = 99;
    end
    
    userData.maxSlot = maxSlot;
    userData.carrierMaskType = maskType;
    
    cRec.userData = userData;
    cRec.carrierId = carrierId;
    cRec.maskType = maskType;
    cRec.physCarrier = physCarrier;
    
    carrierData{i} = cRec;
end

% compute the module data
mRec = {};
for i = 1:length(ipModules)
    try
        mRec.carrierId = evalin('caller', get_param(ipModules{i}, 'carrierId'));
    catch
        return
    end
    mRec.carrierSlot = get_param(ipModules{i}, 'carrierSlot');
    mRec.maskType = get_param(ipModules{i}, 'MaskType');
    segments = split(mRec.maskType, '_');
    mRec.resources = {};
    for j = 1:length(segments)-3
        try
            param = get_param(ipModules{i}, segments{j+3}); 
        catch
            error([ipModules{i} ' has no parameter named ' segments{j+3}]);
        end
        try
            mRec.resources{j} = evalin('caller', param);
        catch
            mRec.resources{j} = param;
        end
    end
    
    moduleData{i} = mRec;
end

% Check for resource conflicts: two modules of different mask types cannot be 
% plugged into the same physical slot; two modules of the same mask type which
% are plugged into the same physical slot cannot have conflicting parameters
clear info;
info.dummy = []; % initialize info as a structure
for i = 1:length(ipModules)
    for j = 1:length(ipCarriers)
        if carrierData{j}.carrierId == moduleData{i}.carrierId
            iRec.name = ipModules{i};
            iRec.maskType = moduleData{i}.maskType;
            iRec.resources = moduleData{i}.resources;
            physCarrierSlot = [carrierData{j}.physCarrier '_' moduleData{i}.carrierSlot];
            if ~isfield(info, physCarrierSlot) 
                pluggedIn = {iRec}; % first iRec for current physCarrierSlot
                info = setfield(info, physCarrierSlot, pluggedIn);
            else % check for resource conflicts
                pluggedIn = getfield(info, physCarrierSlot);
                for k = 1:length(pluggedIn)
                    if strcmp(pluggedIn{k}.maskType, moduleData{i}.maskType)
                        if conflicting(pluggedIn{k}.resources, moduleData{i}.resources)
                            error(['Resource conflict: ' ipModules{i} ' and ' pluggedIn{k}.name]);
                        else % no conflict - add iRec to pluggedIn array of current physCarrierSlot 
                            new = length(pluggedIn) + 1;
                            pluggedIn{new} = iRec;
                            info = setfield(info, physCarrierSlot, pluggedIn);
                        end
                    else % slot already occupied by a different mask type
                        error(['Carrier slot conflict:  ' ipModules{i} ' and ' pluggedIn{k}.name]);
                    end
                end
            end
        end
    end
end

% Store the carrier-specific data in each IP module's userData.
for i = 1:length(ipModules)
    carrier = 0;
    for j = 1:length(ipCarriers)
        if carrierData{j}.carrierId == moduleData{i}.carrierId
            if carrier > 0
                error(['IP carriers ' ipCarriers{carrier} ' and ' ipCarriers{j} ' use the same Carrier ID']);
            else
                carrier = j;
                set_param(ipModules{i}, 'UserData', carrierData{j}.userData);
            end
        end
    end
end
return; % mipcarrier


% Determine if two equal-length resource cell arrays are conflicting.
% (A pair of empty resource arrays are always conflicting.)
function boolean = conflicting(r1, r2)
for i = 1:length(r1)
    if isa(r1{i}, 'char')
        if ~strcmp(r1{i}, r2{i});
            boolean = 0;
            return;
        end
    elseif isa(r1{i}, 'numeric')
        if isempty(intersect(r1{i}, r2{i}))
            boolean = 0;
            return;
        end
    end
end
boolean = 1;
return;


% split a string at specified delimiters, returning a cell array of segments
function result = split(string, delimiter)
tail = string;
i = 1;
while (any(tail))
    [token, tail] = strtok(tail, delimiter);
    result{i} = token;
    i = i+1;
end
return;




