function h = render(this,ax)
%RENDER Render all components in the layer.
%
%   RENDER(AX) renders all components in the layer into the axes AX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:23 $

h = handle([]);
if ~this.isempty
  for i=1:length(this.Components)
    h = this.Components(i).render(this.LayerName,this.Legend, ...
                                  ax,this.getVisible);
  end
end
