function [q,g,h,r]=squareb4(p,e,u,time) 
%SQUAREB4   Boundary condition data 

% Copyright 1994-2001 The MathWorks, Inc. 
% $Revision: 1.9 $ 
bl=[ 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 15 1 1 
48 48 48 48 
48 48 48 48 
49 49 49 49 
48 48 48 48 
0 46 0 0 
0 50 0 0 
0 42 0 0 
0 99 0 0 
0 111 0 0 
0 115 0 0 
0 40 0 0 
0 112 0 0 
0 105 0 0 
0 47 0 0 
0 50 0 0 
0 42 0 0 
0 121 0 0 
0 41 0 0 
]; 

if any(size(u)) 
  [q,g,h,r]=pdeexpd(p,e,u,time,bl); 
else 
  [q,g,h,r]=pdeexpd(p,e,time,bl); 
end