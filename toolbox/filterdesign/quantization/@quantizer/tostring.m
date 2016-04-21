function s = tostring(q)
%TOSTRING  QUANTIZER object to string.
%   S = TOSTRING(Q) converts QUANTIZER object Q to a string such that
%   EVAL(S) would create a quantizer object with the same properties
%   as Q.
%
%   Example:
%     q = quantizer;
%     s = tostring(q)
%
%   See also QUANTIZER.

%   Thomas A. Bryan, 6 May 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/14 15:33:46 $

s = ['quantizer(''',q.mode,''''];
switch q.mode
  case {'fixed','ufixed'}
    s = [s,', ''',q.roundmode,'''',...
          ', ',...
          '''',q.overflowmode,'''',...
          ', ', ...
          '[',num2str(q.format),']',...
          ')'];
  case 'float'
    s = [s,', ''',q.roundmode,''', [',num2str(q.format),'])'];
  case {'single','double'}
    s = [s,')'];
end
