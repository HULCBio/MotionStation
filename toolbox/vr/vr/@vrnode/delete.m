function delete(n)
%DELETE Delete a VRNODE object.
%   DELETE(N) deletes a virtual world node referenced by the VRNODE handle N.
%   If N is a vector of VRNODE handles, multiple nodes are deleted.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2002/11/17 14:13:43 $ $Author: batserve $


for i = 1:numel(n)
  vrsfunc('RemoveNode', getparentid(n(i)), n(i).Name);
end

