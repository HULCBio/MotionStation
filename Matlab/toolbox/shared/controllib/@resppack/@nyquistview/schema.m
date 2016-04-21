function schema
%SCHEMA  Defines properties for @nyquistview class.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:59 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'nyquistview', superclass);

% Class attributes
schema.prop(c, 'PosCurves', 'MATLAB array');  % HG lines for positive freqs
schema.prop(c, 'NegCurves', 'MATLAB array');  % HG lines for negative freqs
schema.prop(c, 'PosArrows', 'MATLAB array');  % Arrows for positive freqs
schema.prop(c, 'NegArrows', 'MATLAB array');  % Arrows for negative freqs
p = schema.prop(c, 'ShowFullContour', 'bool');% 1 -> show branch for w<0
p.FactoryValue = 1;
