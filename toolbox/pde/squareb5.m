function [q,g,h,r]=squareb5(p,e,u,time)
%SQUAREB5       Boundary condition data
%

%   Copyright 1994-2001 The MathWorks, Inc.
%   $Revision: 1.7 $

bl=[
2 2 2 2
0 0 0 0
1 1 1 1
3 3 3 3
1 1 1 1
1 1 1 1
1 1 1 1
4 4 4 4
48 48 48 48
49 49 49 49
101 101 101 101
55 55 55 55
48 48 48 48
48 48 48 48
48 48 48 48
45 45 45 45
49 49 49 49
101 101 101 101
55 55 55 55
48 48 48 48
49 49 49 49
48 48 48 48
48 48 48 48
49 49 49 49
48 48 48 48
48 48 48 48
];

if any(size(u))
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
else
  [q,g,h,r]=pdeexpd(p,e,time,bl);
end


