function schema
% Schema for interp object.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:10 $

pk = findpackage('curvefit');

% Create a new class called interpoptions

c = schema.class(pk, 'interpoptions', pk.findclass('basefitoptions'));



