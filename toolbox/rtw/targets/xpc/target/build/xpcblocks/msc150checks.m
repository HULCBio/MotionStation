function msc150checks( dummy )
  
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2003/01/30 16:14:52 $

  slot = get_param( gcb, 'pci' );
  
  blocks = find_system( bdroot, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'MaskType', 'SC150 Init', 'pci', slot );
  
  if length(blocks) > 1
    error(['This shared memory board in slot ', slot, ' is also used by another init block'] );
  end
  