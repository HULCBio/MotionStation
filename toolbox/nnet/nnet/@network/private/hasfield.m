function f=hasfield(s,n)
%HADFIELD Does structure have a field.
%
%   Syntax
% 
%     hasfield(S,N)
% 
%   Warning!!
% 
%     This function may be altered or removed in future
%     releases of the Neural Network Toolbox. We recommend
%     you do not write code which calls this function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

f = 0;
fn = fieldnames(s);
for i=1:length(fn)
  if strcmp(fn{i},n)
    f = 1;
  break;
  end
end
