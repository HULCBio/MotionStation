function [q,g,h,r]=squareb1(p,e,u,time) 
%SQUAREB1   Boundary condition data 

% Copyright 1994-2001 The MathWorks, Inc. 
% $Revision: 1.9 $ 
bl=[ 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 1 1 1 
1 1 1 1 
48 48 48 48 
48 48 48 48 
49 49 49 49 
48 48 48 48 
]; 

if any(size(u)) 
  [q,g,h,r]=pdeexpd(p,e,u,time,bl); 
else 
  [q,g,h,r]=pdeexpd(p,e,time,bl); 
end 