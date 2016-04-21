function close(f)
%CLOSE Closes a Virtual Reality figure.
%   CLOSE(F) closes a Virtual Reality figure referenced by VRFIGURE handle F.
%   If F is a vector of VRFIGURE handles multiple figures are closed.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.2.2 $ $Date: 2003/01/12 22:41:28 $ $Author: batserve $

% do it
for i = 1:numel(f)
  vrsfunc('VRT3RemoveView', f(i).handle);
end
