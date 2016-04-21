function schema
%  SCHEMA  Defines properties for @FreqStabilityMarginData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:18:55 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'AllStabilityMarginData');

% Register class
c = schema.class(pkg, 'MinStabilityMarginData', supclass);

% RE: data units are 
%     frequency: rad/sec 
%     magnitude: abs
%     phase: degrees