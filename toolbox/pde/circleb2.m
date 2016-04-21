function [q,g,h,r]=circleb2(p,e,u,time)
%CIRCLEB2       Boundary condition data
%
%
%

% Copyright 1994-2001 The MathWorks, Inc.
% $Revision: 1.8 $
bl=[
1 1 1 1
1 1 1 1
1 1 1 1
1 1 1 1
1 1 1 1
4 4 4 4
48 48 48 48
48 48 48 48
49 49 49 49
120 120 120 120
46 46 46 46
94 94 94 94
50 50 50 50
];

if any(size(u))
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
else
  [q,g,h,r]=pdeexpd(p,e,time,bl);
end


