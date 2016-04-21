function close(w)
%CLOSE Close a virtual world.
%   CLOSE(W) closes the virtual world referred to by VRWORLD handle W.
%   If the open count of a virtual world decreases to zero, its internal
%   representation is deleted from memory.
%
%   If W is an array of handles all the virtual worlds are closed.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.12.2.2 $ $Date: 2003/01/12 22:41:31 $ $Author: batserve $

% do it
for i = 1:numel(w);
  vrsfunc('VRT3SceneClose', w(i).id);
end
