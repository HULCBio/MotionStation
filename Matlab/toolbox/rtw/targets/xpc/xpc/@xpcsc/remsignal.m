function [xpcScopeObj] = remsignal(xpcScopeObj, signals)
% REMSIGNAL Removes signals from scopes represented by xpcsc objects
% 
% REMSIGNAL(XPCSCOPEOBJ, SIGNALS) removes the (vector of) signal(s) from
% the scope represented by XPCSCOPEOBJ. The signals must be specified by
% their index, which may be retrieved via XPC/GETSIGNALID. If
% XPCSCOPEOBJ is a vector, the same signals (which are to be removed) must
% exist in each scope. The argument SIGNALS is optional; if left out, all
% signals are removed.
% 
% See also ADDSIGNAL, XPC/GETSIGNALID.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2002/03/25 04:24:40 $

if ~isa(xpcScopeObj, 'xpcsc')
  error('First argument MUST be a xpcsc object');
end

% start taking care of the vector case.
if (prod(size(xpcScopeObj)) > 1)        % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      if (nargin == 1)
        remsignal(scopeElement);        % Assigned to scopeElement
      else
        remsignal(scopeElement, signals);% Assigned to scopeElement
      end
    catch
      error(xpcgate('xpcerrorhandler'));
    end
    % begin reassignment for the return value
    if (flag)                           % xpcScopeObj exists
      xpcTmpScopeObj = [xpcTmpScopeObj scopeElement];
    else                                % no elements assigned yet
      xpcTmpScopeObj = scopeElement;
      flag          = ~flag;
    end                                 % if (flag)
  end                                   % for scopeElement = ....
  xpcTmpScopeObj = reshape(xpcTmpScopeObj, size(xpcScopeObj));
  xpcScopeObj    = xpcTmpScopeObj;
  if (nargout == 0)
    if ~isempty(inputname(1))
      assignin('caller', inputname(1), xpcScopeObj);
    end
  end
  return
end                                     % if (prod(size(xpcScopeObj)) > 1)

% Whatever follows this point is for scalar xpcScopeObj
try
  if (nargin == 1)
    xpcgate('remsignal', str2num(xpcScopeObj.ScopeId));
  else
    xpcgate('remsignal', str2num(xpcScopeObj.ScopeId), signals);
  end
  xpcScopeObj = sync(xpcScopeObj);
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller',inputname(1),xpcScopeObj);
  end
end

%% EOF remsignal.m
