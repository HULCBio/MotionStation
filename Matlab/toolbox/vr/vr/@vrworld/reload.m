function reload(w)
%RELOAD Reload the world contents from associated file.
%   RELOAD(W) reloads the contents of the world referenced by
%   VRWORLD handle W from its associated file.
%
%   All unsaved changes made to the world are lost. If the contents
%   of the associated file was changed, these changes will propagate
%   to the world.
%
%   If W is an array of handles all the virtual worlds are reloaded.
%
%   See also VRWORLD/OPEN, VRWORLD/CLOSE.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.8.4.3 $ $Date: 2004/03/02 03:08:15 $ $Author: batserve $

% check for invalid worlds
if ~all(isvalid(w(:)))
  error('VR:invalidworld', 'Invalid world.');
end

% do it
for i=1:numel(w);
  vrsfunc('Reload', w(i).id);
end
