function varargout=subsref(q,s)
%SUBSREF  Subscripted reference for quantizer objects.
%   VALUE = Q.PROPERTY where Q is a quantizer object is equivalent to 
%   VALUE = GET(Q,'PROPERTY'). 
%
%   Y = Q.METHODNAME(X) where METHODNAME is the name of a method of
%   quantizer object Q is equivalent to Y = METHODNAME(Q,X).
%
%   Example: 
%     q = quantizer;
%     r = q.roundmode
%
%     y = q.quantize(-1.2:.1:1.2)
%
%   See also QUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:33:49 $

% The try/catch is to report errors at the top level
c = class(q);
try
  switch s(1).type
    case '.'
      mthds = methods(c);
      switch s(1).subs
        case mthds
          if length(s)==1
            [varargout{1:max(1,nargout)}] = feval(s.subs,q);
          else
            [varargout{1:max(1,nargout)}] = feval(s(1).subs,q,s(2).subs{:});
          end
        otherwise
          [varargout{1:max(1,nargout)}] = get(q,s.subs);
      end
    otherwise
      error(['This type of subscripting not allowed for ',c,' objects.']);
  end
catch
  error(lasterr);
end
