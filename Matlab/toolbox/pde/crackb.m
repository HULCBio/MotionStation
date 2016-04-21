function [q,g,h,r]=crackb(p,e,u,time)
%CRACKB Boundary condition data
%
%
%

% Copyright 1994-2001 The MathWorks, Inc.
% $Revision: 1.8 $
bl=[
1 1 1 1 1 1 1 1
0 0 0 0 0 1 0 0
1 1 1 1 1 1 1 1
3 1 1 1 1 1 1 1
48 48 48 48 48 1 48 48
45 48 48 48 48 3 48 48
49 48 48 48 48 48 48 48
48 48 48 48 48 48 48 48
49 49 49 49 49 49 49 49
48 48 48 48 48 49 48 48
0 0 0 0 0 48 0 0
0 0 0 0 0 48 0 0
];

if any(size(u))
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
else
  [q,g,h,r]=pdeexpd(p,e,time,bl);
end

