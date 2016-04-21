function schema
%  SCHEMA  Defines properties for @StepSettleTimeData class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:56 $

% Find parent package
pkg = findpackage('resppack');

% Find parent class (superclass)
supclass = findclass(pkg, 'SettleTimeData');

% Register class (subclass)
c = schema.class(pkg, 'StepSettleTimeData', supclass);