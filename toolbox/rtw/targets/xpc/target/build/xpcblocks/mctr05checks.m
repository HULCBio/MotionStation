
function mctr05checks(dummy)
  
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2003/01/29 18:50:23 $

  counter = get_param( gcb, 'counterin' );
  ln = length( counter );
  if ln == 3
    % construct a regular expresion that matches either counter for PWM capture.
    counter = ['[',counter(1),',',counter(3),']'];
  end
  
  slot = get_param( gcb, 'pciSlot' );

  blocks1 = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '^PCI-CTR05.*PWM & ARM$', 'counterin', counter, 'pciSlot', slot );
  blocks2 = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '^PCI-CTR05.*FM$', 'counterin', counter, 'pciSlot', slot );
  blocks3 = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '^PCI-CTR05.*FM & ARM$', 'counterin', counter, 'pciSlot', slot );

  % NOTE: PWM capture uses 2 counters with idents like '2&3'
  blocks4 = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '^PCI-CTR05.*PWM capture$', 'counterin', ['.*',counter,'.*'], 'pciSlot', slot );

  blocks5 = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '^PCI-CTR05.*Frequency capture$', 'counterin', counter, 'pciSlot', slot );
 
  nblocks = length(blocks1) + length(blocks2) + length(blocks3) + length(blocks4) + length(blocks5);
  
  if nblocks > 1
    error(['Counter ',counter, ' on the board in slot ', slot, ' is also in use in another PCI-CTR05 block']);
  end
  
