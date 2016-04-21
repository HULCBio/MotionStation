function [scobj] = addscope(xpcObj, scopeType, scopeId)
% ADDSCOPE Add a scope to the current simulation.
%
%   ADDSCOPE(XPCOBJ, SCOPETYPE, SCOPEID) adds a scope object of type SCOPETYPE
%   to the target represented by XPCOBJ, and assigns it the id
%   SCOPEID. SCOPETYPE and SCOPEID are optional, but if SCOPEID is specified,
%   so must SCOPETYPE. SCOPETYPE must be either 'host' or 'target'. If nothing
%   is specified, SCOPETYPE is set to 'host', and SCOPEID to the next
%   available index. It is an error to specify an existing SCOPEID.
%
%   ADDSCOPE returns a scope object if an explicit return value is
%   requested (i.e. SCOBJ = ADDSCOPE ...), or else it updates XPCOBJ.
%
%   See also REMSCOPE, GETSCOPE

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/03/25 04:16:55 $

try
  existingScopes = xpcgate('getscopes');
  modelName      = xpcgate('getname');
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargin == 1)
  try
    if (nargout == 1)
      id    = xpcgate('defscope');
      scobj = xpcsc(id, modelName);
    else
      xpcgate('defscope');
      scobj = xpcObj;
      if ~isempty(inputname(1))
        assignin('caller', inputname(1), xpcObj);
      end
    end
    return
  catch
    error(xpcgate('xpcerrorhandler'));
  end % try
end % if (nargin == 1)

% nargin >= 2
validTypes = {'host', 'target'};
if ~ischar(scopeType)
  error('Invalid value for ScopeType: must be either host or target');
end
index = strmatch(lower(scopeType), lower(validTypes));
if isempty(index)
  error(sprintf('Invalid type %s for scopeType', scopeType));
elseif (length(index) > 1)
  error(sprintf('Ambiguous type %s for scopeType', scopeType));
else
  scopeType = validTypes{index};
end

if (nargin == 2)
  try
    if (nargout == 1)
      id    = xpcgate('defscope', scopeType);
      scobj = xpcsc(id, modelName);
    else
      xpcgate('defscope', scopeType);
      scobj = xpcObj;
      if ~isempty(inputname(1))
        assignin('caller', inputname(1), xpcObj);
      end
    end
    return
  catch
    error(xpcgate('xpcerrorhandler'));
  end % try
end % if (nargin == 2)

if (nargin == 3)
  for tempScope = scopeId
    if ~all(tempScope - existingScopes) % tempScope - existingScopes = 0
      error(sprintf('Scope %d already exists', tempScope));
    end
  end
  try
    if (nargout == 1)
      flag = 0;
      for tempScope = scopeId
        id    = xpcgate('defscope', scopeType, tempScope);
        if (flag)                               % scobj nonempty
          scobj = [scobj xpcsc(id, modelName)];
        else                            % empty scobj
          scobj = xpcsc(id, modelName);
          flag = ~flag;
        end
      end
    else
      xpcgate('defscope', scopeType, scopeId);
      scobj  = xpcObj;
      if ~isempty(inputname(1))
        assignin('caller', inputname(1), xpcObj);
      end
    end % if (nargout == 1)
    return
  catch
    error(xpcgate('xpcerrorhandler'));
  end % try
end % if (nargin == 3)

%% EOF addscope.m