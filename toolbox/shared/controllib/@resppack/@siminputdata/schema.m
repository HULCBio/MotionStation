function schema
%SCHEMA  Defines properties for @siminputdata class (input data)

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:36 $

% Parent class
pc = findclass(findpackage('wavepack'), 'timedata');

% Register class (subclass)
c = schema.class(findpackage('resppack'), 'siminputdata',pc);
