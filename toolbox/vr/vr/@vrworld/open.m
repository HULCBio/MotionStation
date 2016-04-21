function open(w)
%OPEN Open a virtual world.
%   OPEN(W) opens the virtual world referred to by VRWORLD handle W.
%   When being opened for the first time, the virtual world internal
%   representation is created based on the associated VRML file.
%   If a world is opened more than once it must be also closed the
%   appropriate number of times.
%
%   If W is an array of handles all the virtual worlds are opened.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.9.2.2 $ $Date: 2003/01/12 22:41:33 $ $Author: batserve $

% do it
for i = 1:numel(w);
  vrsfunc('VRT3SceneOpen', w(i).id);
end
