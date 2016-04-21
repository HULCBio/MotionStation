function [xpcScopeObj] = start(xpcScopeObj)
% START Start xPC scope
%
%   START(XPCSCOPEOBJ) starts the scope represented by XPCSCOPEOBJ.
%   XPCSCOPEOBJ may possibly be a vector of xpcsc objects, in which
%   case all the scopes will be started.
%
%   See also STOP.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/03/25 04:24:43 $

if (prod(size(xpcScopeObj)) > 1)
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      scopeElement = start(scopeElement);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
    if (flag)                           % xpcTmpScopeObj exists
      xpcTmpScopeObj = [xpcTmpScopeObj scopeElement];
    else                                % No elements assigned yet
      xpcTmpScopeObj = scopeElement;
      flag = ~flag;
    end % if (flag)
  end % for scopeElement = ....
  xpcScopeObj = reshape(xpcTmpScopeObj, size(xpcScopeObj));
  if (nargout == 0)
    if ~isempty(inputname(1))
      assignin('caller', inputname(1), xpcScopeObj);
    end
  end
  return
end

% Whatever follows this point is for scalar xpcScopeObj
try
  xpcScopeObj = set(xpcScopeObj, 'Command', 'Start');
catch
  error(xpcgate('xpcerrorhandler'));
end


if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end
end

%% EOF start.m
