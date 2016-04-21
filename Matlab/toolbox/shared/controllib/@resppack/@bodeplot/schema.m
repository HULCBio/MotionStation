function schema
%  SCHEMA  Defines properties for @bodeplot class

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:25 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'respplot');

% Register class (subclass)
c = schema.class(pkg, 'bodeplot', supclass);

% Public properties
p(1) = schema.prop(c, 'MagVisible',   'on/off');  % Visibility of mag plot
p(2) = schema.prop(c, 'PhaseVisible', 'on/off');  % Visibility of phase plot
set(p, 'FactoryValue', 'on')

% Private properties
% Global frequency focus (rad/sec, default = [])
% Controls frequency range shown in auto-X mode
p = schema.prop(c, 'FreqFocus', 'MATLAB array');  
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';