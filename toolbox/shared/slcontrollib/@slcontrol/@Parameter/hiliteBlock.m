function hiliteBlock(this)
% HILITEBLOCK Highlights the blocks referring to the parameter represented by
% this object.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:53 $

blocks = this.ReferencedBy;
for ct = 1:length(blocks)
  try
    parent = get_param(blocks{ct}, 'Parent');
    open_system( parent )
    set_param( blocks{ct}, 'HiliteAncestors', 'default' )
  catch
    error( 'Cannot locate Simulink block ''%s''.\n', blocks{ct} )
  end
end
