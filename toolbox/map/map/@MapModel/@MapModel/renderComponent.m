function handles = renderComponent(this,ax,layer,component)
%RENDERCOMPONENT Render a component.
%
%   RENDERCOMPONENT(AX,LAYER,COMPONENT) Renders COMPONENT, belonging to
%   LAYER, into the axes AX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:30 $

handles = layer.renderComponent(ax,component);