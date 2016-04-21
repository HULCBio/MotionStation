function [xpcScopeObj] = subsasgn(xpcScopeObj, Subs, value)
% SUBSAGN Assign into xPC scope object
%
%   This assignment can be done only for the '.' syntax, i.e. the statement
%   SET(XPCSCOPEOBJ, 'TriggerMode', 'Signal) may be replaced by
%   XPCSCOPEOBJ.TriggerMode = 'Signal'. The assignment may also be done
%   for vectors of scope objects, for example XPCSCOPEOBJ([1, 3]).Grid = 'on'.
%
%   This is a private function and is not to be called directly.
%
%   See also SUBSREF.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2002/03/25 04:24:46 $

if (Subs(1).type == '()')
  if (length(Subs) > 2)
    error(sprintf('\tInvalid assignment to XPCSC object.'));
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

  if (length(Subs) == 1)
    eval(['xpcScopeObj(', indexString, ') = value;'], ...
         'error(xpcgate(''xpcerrorhandler''))');
    return
  else
    xpcSubVector = eval(['xpcScopeObj(', indexString, ')'], ...
                        'error(xpcgate(''xpcerrorhandler''))');
    eval(['xpcScopeObj(', indexString, ...
          ') = subsasgn(xpcSubVector, Subs(2),value);'], ...
         'error(xpcgate(''xpcerrorhandler''))');
    return
  end
end

if  (Subs.type == '.' )
  try
    xpcScopeObj = set(xpcScopeObj, Subs.subs, value);
  catch
    error(xpcgate('xpcerrorhandler'));
  end
else
  error('Invalid subscript type for xpcscope objects');
end

if (nargout == 0)
  if ~isempty(inputname(1))
    assignin('caller', inputname(1), xpcScopeObj);
  end
end

%% EOF subsasgn.m