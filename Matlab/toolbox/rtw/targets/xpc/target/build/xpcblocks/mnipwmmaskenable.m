function mnipwmmaskenable(blk)
% MNIPWMMASKENABLE xPC Target private function used to modify mask enables.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2002/10/30 22:45:57 $

mv = get_param(blk, 'MaskValues');
me = get_param(blk, 'MaskEnables');
if strncmp(mv{2}, 'Level', 4)
  me{3} = 'on';
else
  me{3} = 'off';
end
set_param(blk, 'MaskEnables', me);