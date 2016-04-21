function mapci1710(dummy)
  
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2003/01/29 19:35:51 $

  module = get_param( gcb, 'module' );
  slot = get_param( gcb, 'pci_dev' );
  
  blocks = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'RegExp', 'on', 'MaskDescription', '.*APCI-1710.*', 'module', module, 'pci_dev', slot );
  
  if length( blocks ) > 1
    error(['Module ', module, ' on the APCI-1710 in slot ', slot, ' is also used in another APCI-1710 block'] );
  end
  