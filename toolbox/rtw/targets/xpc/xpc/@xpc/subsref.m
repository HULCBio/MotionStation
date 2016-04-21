function [returnValue] = subsref(xpcObj, Subs)
% SUBSREF Reference into xPC objects.
%
%   The allowable syntax is:
%   XPCOBJ.METHOD(ARGS), which is equivalent to
%   METHOD(XPCOBJ, ARGS). Alternatively, XPCOBJ.PROPERTY returns the
%   value of the relevant property, and is equivalent to
%   GET(XPCOBJ, 'PROPERTY'). No other uses are permitted.
%
%   Unlike properties, for which partial (but unambiguous) names are
%   permitted, method names must be entered in full, and in lowercase.
%
%   This is a private function and is not to be called directly.
%
%   See also SUBSASGN.

%
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/03/25 04:17:30 $
%

try
  if ((Subs(1).type == '.') & ...
      length(Subs) <= 2)                  % something like a.b...
    methodprop = Subs(1).subs;            % extract b
    if (exist([class(xpcObj),'/',methodprop]) == 2)
      % is it a method or a property? (True = method)
      nout = nargout([class(xpcObj), '/', methodprop]);
      
      if (length(Subs) == 1)              % something like a.b
        if nout                         % *has* output args
          returnValue = feval(methodprop, xpcObj); % No input Args
        else
          feval(methodprop, xpcObj);    % no input or output args
          returnValue = [];
        end
      elseif strcmp(Subs(2).type, '()')   % a.b(args)
        args         = Subs(2).subs;
        if nout                         % *has* output arguments
          returnValue  = feval(methodprop, xpcObj, args{:});
          if (~isempty(inputname(1)) & ...
              isa(returnValue,'xpc'))
            assignin('caller', inputname(1), returnValue);
          end
        else
          feval(methodprop, xpcObj, args{:});
          returnValue = [];
        end
      else                                % length = 2, Subs(2) not ()
        error(sprintf('Incorrect argument type: %s', Subs(2).type));
      end % if (length(Subs) == 1)
    elseif (length(Subs) == 1)            % property, need length 1
      returnValue = get(xpcObj, methodprop);
    else                                  % Too many args
      error(sprintf('Invalid method %s', Subs(1).subs));
    end % if (exist([class(xpcObj),'/',methodprop]) == 2)
  else                                    % Wrong subs.type
    error('Wrong subscript type or too many args');
  end % if ((Subs(1).type == '.')
  
catch
  error(xpcgate('xpcerrorhandler'));
end % try

%% EOF subsref.m
