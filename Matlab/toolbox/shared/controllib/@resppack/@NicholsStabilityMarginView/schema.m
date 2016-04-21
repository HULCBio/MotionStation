function schema
%SCHEMA  Defines properties for @NicholsStabilityMarginView class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:06 $

% Register class
pkg = findpackage('resppack');
c = schema.class(pkg, 'NicholsStabilityMarginView', ...
   pkg.findclass('StabilityMarginView'));