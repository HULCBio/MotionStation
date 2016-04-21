function schema
%SCHEMA  Definition of @specplot class (frequency spectrum plot).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:39 $

% Register class 
pkg = findpackage('wavepack');
c = schema.class(pkg, 'specplot', findclass(pkg, 'waveplot'));