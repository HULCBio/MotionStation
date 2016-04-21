function [q,g,h,r]=squareb2(p,e,u,time) 
%SQUAREB2   Boundary condition data 

% Copyright 1994-2001 The MathWorks, Inc. 
% $Revision: 1.9 $ 
bl=[ 
1 1 1 1 
0 0 0 1 
1 5 1 1 
1 1 3 1 
48 45 48 1 
48 48 53 1 
48 46 42 48 
48 55 120 48 
49 53 49 49 
48 48 48 48 
]; 

if any(size(u)) 
  [q,g,h,r]=pdeexpd(p,e,u,time,bl); 
else 
  [q,g,h,r]=pdeexpd(p,e,time,bl); 
end 