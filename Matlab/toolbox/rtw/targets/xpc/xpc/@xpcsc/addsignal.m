function [xpcScopeObj] = addsignal(xpcScopeObj, signals)
% ADDSIGNAL Adds a signal (or a vector of signals) to the scope
%
%   ADDSIGNAL(XPCSCOPEOBJ, SIGNALS) adds the (vector of) signal(s) to the
%   scope represented by XPCSCOPEOBJ. The signals must be specified by their
%   index, which may be retrieved via XPC/GETSIGNALID. If XPCSCOPEOBJ
%   is a vector, the same signals are assigned to each scope.
%
%   See also REMSIGNAL, XPC/GETSIGNALID.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/25 04:24:30 $

if ~isa(xpcScopeObj, 'xpcsc')
  error('First argument MUST be a xpcsc object');
end

% start taking care of the vector case.
if (prod(size(xpcScopeObj)) > 1)                % Vector of scope objects
  flag = 0;
  for scopeElement = reshape(xpcScopeObj, 1, prod(size(xpcScopeObj)))
    try
      addsignal(scopeElement, signals); % Assigned to scopeElement
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
end % if (prod(size(varargin{1})) > 1)

% Whatever follows this point is for scalar xpcScopeObj
try
  maxSignal   = xpcgate('getnsig', xpcgate('getname')) - 1;
  % highest possible signal number
  if any(signals > maxSignal)
    error(sprintf('Signal %d invalid!\n', signals(signals > maxSignal)));
  end
  xpcScopeObj = set(xpcScopeObj, 'Signals', signals);
catch
  error(xpcgate('xpcerrorhandler'));
end

if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end
end

%% EOF addsignal.m
