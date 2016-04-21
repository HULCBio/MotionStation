function schema
%SCHEMA  schema for the Property Editor.

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:42 $

%---Register class
c = schema.class(findpackage('cstprefs'),'propeditor');

%---Define properties
schema.prop(c,'Target','handle');       %---Handle of edited object
schema.prop(c,'Tabs','MATLAB array');   %---Editor tabs

%---Private
schema.prop(c,'Java','MATLAB array');               %---Structure to store java handles
schema.prop(c,'TargetListeners','handle vector');   %---Target-dependent listeners (clf will do this)

%---Events
schema.event(c,'PropEditBeingClosed');   %---Issued when PropEdit's Frame's WindowClosingCallback 
                                         %   is executed.