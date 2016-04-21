%LIGHT  Create light.
%   LIGHT adds a LIGHT object to the current axes, with all properties
%         set to their default values.
%   LIGHT(Param1, Value1, ..., ParamN, ValueN) adds a light object
%         to the current axes, with properties Param1-ParamN set
%         to the values specified in Value1-ValueN.
%   L=LIGHT(...) returns a handle to the LIGHT object.
%
%   LIGHT objects are children of AXES objects. LIGHT objects do not
%   draw, but can affect the look of SURFACE and PATCH objects. The
%   effect of LIGHT objects can be controlled through the LIGHT
%   properties including Color, Style, Position, and Visible. The 
%   light position is in data units.
%
%   The effect of LIGHT objects upon SURFACE and PATCH objects is
%   also affected by the AXES property AmbientLightColor, and the
%   SURFACE and PATCH properties of AmbientStrength, DiffuseStrength,
%   SpecularColorReflectance, SpecularExponent, SpecularStrength,
%   VertexNormals, EdgeLighting, and FaceLighting.
%
%   The figure Renderer must be set to 'zbuffer' or 'OpenGL' (or
%   the figure RendererMode must be set to 'auto') in order for
%   LIGHT objects to be effective - lighting calculations will not be
%   performed when Renderer is set to 'painters'.
%
%   Execute GET(H), where H is a LIGHT handle, to see a list of LIGHT
%   object properties and their current values. Execute SET(H) to see a
%   list of LIGHT object properties and legal property values.
%
%   See also LIGHTING, MATERIAL, CAMLIGHT, LIGHTANGLE, SURF, PATCH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 17:06:59 $
%   Built-in function.




