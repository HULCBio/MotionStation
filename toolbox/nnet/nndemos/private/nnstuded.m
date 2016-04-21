function f=nnstuded
%NNSTUDED Neural Network Design utility function.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.6 $

% Returns 1 if Student Edition MATLAB is being used.

c = version;
f=0;
if length(c) >= 7
  if lower(c(1:7)) == 'student'
    f = 1;
  end
end
