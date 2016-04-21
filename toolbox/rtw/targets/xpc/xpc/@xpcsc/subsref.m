function [returnValue] = subsref(xpcScopeObj, Subs)
% SUBSREF Reference into xPC scope objects.
%
%   The allowable syntax is:
%   XPCSCOPEOBJ.METHOD(ARGS), which is equivalent to
%   METHOD(XPCSCOPEOBJ, ARGS). Alternatively, XPCSCOPEOBJ.PROPERTY
%   returns the value of the relevant property, and is equivalent to
%   GET(XPCSCOPEOBJ, 'PROPERTY'). Also, XPCSCOPEOBJ(INDICES).METHOD(ARGS)
%   and XPCSCOPEOBJ(INDICES).PROPERTY may be used.
%   No other uses are permitted.
%
%   This is a private function and is not to be called directly.
%
%   See also SUBSASGN.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/03/25 04:24:49 $

if (Subs(1).type == '()')
  if (length(Subs) > 3)
    error(sprintf([ ...
        '\tInvalid reference to subscripted XPCSC object.']));
  end
  flag = 0;
  indices = Subs(1).subs;
  for dimIndex = 1 : length(indices)
    if (indices{dimIndex} == ':')
      indices{dimIndex} = [1 : size(xpcScopeObj, dimIndex)];
    end
    if (flag)
      indexString = [indexString, ', [', num2str(indices{dimIndex}), ']'];
    else
      indexString = ['[', num2str(indices{dimIndex}), ']'];
      flag        = ~flag;
    end
  end
  xpcSubVector = eval(['xpcScopeObj(', indexString, ')'], ...
                      'error(xpcgate(''xpcerrorhandler''))');
  if (length(Subs) == 1)
    returnValue = xpcSubVector;
    return
  end
  if (length(Subs) == 3)
    if (Subs(3).type ~= '()')
      error('Incorrect Subscript type');
    end
  end
  if (length(Subs) >= 2)
    if (Subs(2).type ~= '.')
      error('Incorrect Subscript type');
    end
  end
  try
    returnValue = subsref(xpcSubVector, Subs(2 : end));
  catch
    error(xpcgate('xpcerrorhandler'));
  end
  return
end

if ((Subs(1).type == '.') & ...
    length(Subs) <= 2)                  % something like a.b...
  methodprop = Subs(1).subs;            % extract b
  if (exist([class(xpcScopeObj), '/', methodprop]) == 2)
    % is it a method or a property? (True = method)
    if (length(Subs) == 1)              % something like a.b
      returnValue = feval(methodprop, xpcScopeObj); % No Args
    elseif strcmp(Subs(2).type, '()')   % a.b(args)
      args         = Subs(2).subs;
      returnValue = feval(methodprop, xpcScopeObj, args{:});
      % eval(['returnValue  = ',methodprop,'(xpcScopeObj, args{:});']);
    else                                % length = 2, Subs(2) not ()
      error(sprintf('Incorrect argument type: %s', Subs(2).type));
    end
  elseif (length(Subs) == 1)            % property, need length 1
    try
      returnValue = get(xpcScopeObj, methodprop);
    catch
      error(xpcgate('xpcerrorhandler'));
    end
  else                                  % Too many args
	 error(sprintf('Invalid method %s', Subs(1).subs));
  end % if (exist([class(xpcScopeObj), '/' .....
else                                    % Wrong subs.type
  error('Wrong subscript type or too many args');
end

%% EOF subsref.m
