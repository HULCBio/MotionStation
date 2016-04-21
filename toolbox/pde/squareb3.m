function [q,g,h,r]=squareb3(p,e,u,time) 
%SQUAREB3   Boundary condition data 

% Copyright 1994-2001 The MathWorks, Inc. 
% $Revision: 1.9 $ 
bl=[ 
1 1 1 1 
0 1 0 1 
1 1 1 1 
1 1 1 1 
48 1 48 1 
48 1 48 1 
48 48 42 48 
48 48 120 48 
49 49 49 49 
48 48 48 48 
]; 

if any(size(u)) 
  [q,g,h,r]=pdeexpd(p,e,u,time,bl); 
else 
  [q,g,h,r]=pdeexpd(p,e,time,bl); 
end 