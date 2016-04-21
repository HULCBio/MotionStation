function addComponent(this,component)
%ADDCOMPONENT Add a component to the layer
%
%   ADDCOMPONENT(COMPONENT) adds a COMPONENT to the layer.  The layer is
%   homogeneous, so the component must be the same type as the layer.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:14:12 $

if isempty(strmatch(regexprep(class(component),'^\w*\.','','once'),...
                    this.ComponentType))
  error('Layers must be homogeneous');
%  error('Only a %s can be added to this layer.',this.ComponentType);
end

this.Components = [this.Components; component];
