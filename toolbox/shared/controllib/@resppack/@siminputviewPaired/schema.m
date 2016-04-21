function schema
%SCHEMA  Defines properties for @siminputview class

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:41 $

% Parent class
pc = findclass(findpackage('wavepack'), 'timeview');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'siminputviewPaired',pc);
