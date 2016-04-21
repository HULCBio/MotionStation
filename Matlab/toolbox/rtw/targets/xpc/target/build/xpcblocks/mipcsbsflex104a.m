
function [maskDisplay, maskDescription] = mipcsbsflex104a(carrierId, isaBase)

% MPCI40A - Mask Initialization for SBS Flex/104A IP carrier board
% Works in conjunction with the InitFcn ipCrossCheck
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/25 04:10:09 $


    %%% board-specific variables

    vendorName   = 'SBS';
    deviceName   = 'Flex/104A';
    description  = 'PC/104 IP Carrier';
    carrierType  = 2; % Flex/104A

 
    %%% check Carrier ID parameter

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end


    %%% check isaBase parameter

    if ~isa(isaBase, 'char')
        error('Base address parameter must be of class char');
    end

    baseMsg = 'Base address parameter must be of the form ''0xddd'', where ddd is one of the hex addresses 300, 320, 340';

    if length(isaBase) ~= 5 | isaBase(1:2) ~= '0x'
        error(baseMsg);
    end
    
    try
        baseDec = hex2dec(isaBase(3:end));
    catch
        error(baseMsg);
    end

    minBase = hex2dec('300');
    maxBase = hex2dec('340');
    incBase = hex2dec('020');

    if baseDec < minBase | baseDec > maxBase | mod(baseDec, incBase) ~= 0
        error(baseMsg);
    end
    
    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
   
    maskDescription = [deviceName 10 vendorName 10 description];
