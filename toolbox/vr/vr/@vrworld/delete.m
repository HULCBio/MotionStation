function delete(w)
%DELETE Delete a virtual world.
%   DELETE(W) deletes the virtual world referred to by VRWORLD handle W.
%   If W is an array of handles all the virtual worlds are deleted.
%
%   Deleting an invalid world does nothing and is not an error.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.8.2.4 $ $Date: 2003/09/02 01:16:32 $ $Author: batserve $

% do it
for i = 1:numel(w);
  vrsfunc('VRT3RemoveScene', w(i).id);
end
