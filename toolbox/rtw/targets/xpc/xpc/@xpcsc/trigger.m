function [xpcScopeObj] = trigger(xpcScopeObj)
% TRIGGER Triggers one or more xPC scopes
%
%   TRIGGER(XPCSCOPEOBJ) triggers the scope(s) pointed to by XPCSCOPEOBJ
%   if property TriggerMode has value 'software' (software triggering).
%   If XPCSCOPEOBJ is a vector, all the scopes are triggered.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/03/25 04:24:52 $

% start taking care of the vector case.
if (prod(size(xpcScopeObj)) > 1)                % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      trigger(scopeElement);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
    % begin reassignment for the return value
    if (flag)                           % xpcScopeObj exists
      xpcTmpScopeObj = [xpcTmpScopeObj scopeElement];
    else                                % no elements assigned yet
      xpcTmpScopeObj = scopeElement;
      flag          = ~flag;
    end % if (flag)
  end % for scopeElement = ....
  xpcTmpScopeObj = reshape(xpcTmpScopeObj, size(xpcScopeObj));
  xpcScopeObj    = xpcTmpScopeObj;
  if (nargout == 0)
    if ~isempty(inputname(1))
      assignin('caller', inputname(1), xpcScopeObj);
    end
  end
  return
end % if (prod(size(xpcScopeObj)) > 1)

% Whatever follows is for the scalar case
try
  xpcScopeObj = set(xpcScopeObj, 'Command', 'Trigger');
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end
end

% EOF trigger.m
