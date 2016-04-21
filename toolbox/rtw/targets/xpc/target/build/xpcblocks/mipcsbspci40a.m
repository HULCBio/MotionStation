
function [pciSlot, maskDisplay, maskDescription] = mipcsbspci40a(carrierId, pciSlot)

% mipcsbspci40a - Mask Initialization for SBS PCI-40A IP carrier board
% Works in conjunction with the InitFcn ipCrossCheck
% Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.3.6.1 $  $Date: 2004/04/08 21:03:04 $


    %%% board-specific variables

    vendorName   = 'SBS';
    deviceName   = 'PCI-40A';
    description  = 'PCI IP Carrier';


    %%% check Carrier ID parameter

    if ~isa(carrierId, 'double')
        error('Carrier ID parameter must be of class double');

    elseif size(carrierId) ~= [1 1]
        error('Carrier ID parameter must be a scalar');
    end


    %%% check PCI slot parameter

    if ~isa(pciSlot, 'double')
        error('PCI Slot parameter must be of class double');
  
    elseif size(pciSlot) == [1 1]
        pciSlot = [0 pciSlot];
    
    elseif size(pciSlot) ~= [1 2]
        error('PCI Slot parameter must be a scalar (bus 0 assumed) or a vector of the form [bus slot]');
    end


    % compute maskDisplay and maskDescription

    maskDisplay = sprintf('disp(''%s\\n%s\\n%s'');', deviceName, vendorName, description);
   
    maskDescription = [deviceName 10 vendorName 10 description];
    
