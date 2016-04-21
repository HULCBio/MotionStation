function schema
%   SCHEMA  Defines properties for @pzdata class

%   Author(s): Bora Eryilmaz
%   Revised:   Kamesh Subbarao, 10-29-2001
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:04 $

% Find parent class (superclass)
supclass = findclass(findpackage('wrfc'), 'data');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'pzdata', supclass);

% Public attributes - Data
schema.prop(c, 'Poles',   'MATLAB array');       % Poles 
schema.prop(c, 'Zeros',   'MATLAB array');       % Zeros
schema.prop(c, 'Ts',      'MATLAB array');       % Sampling Time
