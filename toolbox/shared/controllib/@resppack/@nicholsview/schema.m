function schema
%SCHEMA  Defines properties for @nicholsview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:36 $

% Register class (subclass)
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'nicholsview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');  % Handles of HG lines
schema.prop(c, 'UnwrapPhase', 'on/off');   % Phase wrapping
