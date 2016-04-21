function [q,g,h,r]=cirsb(p,e,u,time)
%CIRSB  Boundary condition data
%
%
%

% Copyright 1994-2001 The MathWorks, Inc.
% $Revision: 1.8 $
bl=[
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1
1 1 1 1 1
1 1 19 19 19
48 48 48 48 48
48 48 48 48 48
49 49 49 49 49
48 48 99 99 99
0 0 111 111 111
0 0 115 115 115
0 0 40 40 40
0 0 50 50 50
0 0 47 47 47
0 0 51 51 51
0 0 42 42 42
0 0 97 97 97
0 0 116 116 116
0 0 97 97 97
0 0 110 110 110
0 0 50 50 50
0 0 40 40 40
0 0 121 121 121
0 0 44 44 44
0 0 120 120 120
0 0 41 41 41
0 0 41 41 41
];

if any(size(u))
  [q,g,h,r]=pdeexpd(p,e,u,time,bl);
else
  [q,g,h,r]=pdeexpd(p,e,time,bl);
end

