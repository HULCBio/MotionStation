function schema
%  SCHEMA  Defines properties for @NyquistStabilityMarginView class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:16 $

% Register class
pkg = findpackage('resppack');
c = schema.class(pkg, 'NyquistStabilityMarginView', ...
   pkg.findclass('StabilityMarginView'));