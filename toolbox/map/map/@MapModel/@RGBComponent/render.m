function h = render(this,layerName,legend,ax,visibility)
%RENDER Renders an RGBComponent
%
%   H = RENDER(LAYERNAME,LEGEND,AX,VISIBILITY) Renders as an RGB Image, 
%   into the axes AX, the RGBComponent contained in the LAYERNAME.
%   The RGBComponent visibility is defined by VISIBILITY.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:49:16 $

R = this.ReferenceMatrix;
I = this.ImageData;
h = size(I,1);
w = size(I,2);
cc = pix2map(R,[1  1;...
                h  w]);

h = MapGraphics.Image(layerName,...
                      'Parent',ax,'CData',I,...
                      'XData',cc(:,1),'YData',cc(:,2));

set(h,'Visible',visibility);
