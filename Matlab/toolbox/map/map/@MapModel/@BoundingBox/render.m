function h = render(this,name,textstring,ax)
%RENDER Render bounding box
%
%   H = RENDER(NAME,AX) Renders a bounding box with the name NAME into the axes
%   AX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:13:09 $

box = this.getClosedBox;
h = MapGraphics.BoundingBox([name '_BoundingBox'],textstring,box,ax);
