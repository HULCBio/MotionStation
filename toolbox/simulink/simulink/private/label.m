function y = label(iLabel, iStr)
% Prefixes every line in iStr with iLabel, e.g.
%
%    label('### ', sprintf('Hello\nGoodbye'))
%
% gives output
%
%    ### Hello
%    ### Goodbye
  
% Copyright 2002 The MathWorks, Inc.
% $Revision: 1.1.6.2 $
  
  y = strrep([iLabel iStr], cr, [cr iLabel]);
