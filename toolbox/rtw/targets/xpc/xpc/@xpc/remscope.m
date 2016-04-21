function remscope(xpcObj, scopeId)
% REMSCOPE Remove a scope from the target
%   REMSCOPE(XPCOBJ, SCOPEID) removes the scope SCOPEID from the target
%   represented by XPCOBJ. SCOPEID has to point to an existing scope. If
%   SCOPEID is unspecified, remscope deletes all scope objects.
%
%   REMSCOPE has no return value.
%
%   See also ADDSCOPE, GETSCOPE.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:17:21 $

try
  if (nargin == 1)
    xpcgate('delscope');
  else
    existingScopes = xpcgate('getscopes');
    for tempScope = scopeId
      if all(tempScope - existingScopes)        % None match: all nonzero
        error(sprintf('Scope %d undefined', tempScope));
      end
    end
    xpcgate('delscope', scopeId);
  end % if (nargin == 1)
catch
  error(xpcgate('xpcerrorhandler'));
end

%% EOF remscope.m