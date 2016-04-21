%SURFACE Create surface.
%   SURFACE(X,Y,Z,C) adds the surface in X,Y,Z,C to the current axes.
%   SURFACE(X,Y,Z) uses C = Z, so color is proportional to surface height.
%   See SURF for a complete description of the various forms that X,Y,Z,C
%   can take.
%
%   SURFACE returns a handle to a SURFACE object. SURFACEs are children of
%   AXES objects.
%
%   The arguments to SURFACE can be followed by parameter/value pairs
%   to specify additional properties of the surface. The X,Y,Z,C arguments
%   to SURFACE can be omitted entirely, and all properties specified using
%   parameter/value pairs.
%
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING and VIEW set figure, axes, and
%   surface properties which affect the display of the SURFACE.
%
%   Execute GET(H), where H is a surface handle, to see a list of surface
%   object properties and their current values. Execute SET(H) to see a
%   list of surface object properties and legal property values.
%
%   See also SURF, LINE, PATCH, TEXT, SHADING.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/10 17:06:50 $
%   Built-in function.




