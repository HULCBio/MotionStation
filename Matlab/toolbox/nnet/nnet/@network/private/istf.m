function f=istf(s)
%ISTF True of input is name of transfer function.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

f = 1;
if ~isa(s,'char') | ~any(exist(s) == [2 3 6])
  f = 0;
else
  % Check TF info
end
