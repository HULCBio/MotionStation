function schema
%SCHEMA  schema for the Property Editor groupbox.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:37 $

%---Register class
c = schema.class(findpackage('cstprefs'),'editbox');

%---Define properties
schema.prop(c,'GroupBox','MATLAB array');           %---Handle of Java Groupbox 
schema.prop(c,'Panel','MATLAB array');              %---Groupbox Parent (Java Panel)
schema.prop(c,'Tag','string');                      %---Identifier tag
schema.prop(c,'Target','handle vector');            %---Handles of edited objects (targets)
schema.prop(c,'TargetListeners','handle vector');   %---Target-dependent listeners

schema.prop(c,'Data','MATLAB array');               %---Data filling the editbox

p = schema.prop(c,'DataListener','handle');         %---DataListener
set(p,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');
