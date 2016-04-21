function h = importlti(TypesAllowed)

% h = importlti(TypesAllowed)
%
% importlti object constructor

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2004/04/10 23:37:34 $

h = mpcobjects.importlti;
h.TypesAllowed = TypesAllowed;
