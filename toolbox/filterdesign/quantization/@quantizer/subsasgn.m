function q=subsasgn(q,s,value)
%SUBSASGN  Subscripted assignment for quantizer objects.
%   Q.PROPERTY = VALUE where Q is a quantizer object is equivalent to
%   SET(Q,'PROPERTY',VALUE).
%
%   Example:
%     q = quantizer;
%     q.mode = 'double'
%
%   See also QUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:33:52 $

% The try/catch is to report errors at the top level
try
  switch s.type
    case '.'
      set(q,s.subs,value);
    otherwise
      error('This type of subscripting not allowed for quantizer objects.');
  end
catch
  error(lasterr);
end
