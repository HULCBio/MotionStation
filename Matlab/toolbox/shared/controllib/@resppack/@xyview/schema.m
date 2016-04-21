function schema
%SCHEMA  Defines properties for @xyview class

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:16 $

% Register class
superclass = findclass(findpackage('wrfc'), 'view');
c = schema.class(findpackage('resppack'), 'xyview', superclass);

% Class attributes
schema.prop(c, 'Curves', 'MATLAB array');  % Handles of HG lines (matrix)
