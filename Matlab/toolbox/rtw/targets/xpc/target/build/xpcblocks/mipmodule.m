% mipmodule - InitFcn for IP module blocks
% Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/25 04:10:15 $
%
% Checks that the module's carrier ID equals that of some carrier block in the model

function mipmodule

try
    carrierId = evalin('caller', get_param(gcb, 'carrierId'));
catch
    return
end

ipCarriers = find_system(bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskType', '^ipCarrier.*');

for i = 1:length(ipCarriers)
    try
        if carrierId == evalin('caller', get_param(ipCarriers{i}, 'carrierId'))
            return
        end
    catch
    end
end

error(['No IP carrier in the model has a carrier ID of ' get_param(gcb, 'carrierId')]);

