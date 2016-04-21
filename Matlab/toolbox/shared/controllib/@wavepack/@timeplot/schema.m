function schema
%SCHEMA  Definition of @timeplot class (time series plot).

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:49 $

% Register class 
pkg = findpackage('wavepack');
c = schema.class(pkg, 'timeplot', findclass(pkg, 'waveplot'));