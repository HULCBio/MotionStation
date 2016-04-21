function schema
%SCHEMA  Defines properties for @SimInputPeakView class.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:33 $

% Register class
superclass = findclass(findpackage('wavepack'), 'TimePeakAmpView');
c = schema.class(findpackage('resppack'), 'SimInputPeakView', superclass);
