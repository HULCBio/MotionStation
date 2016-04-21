function y = vectorized_fitness(x,p1,p2)
%VECTORIZED_FITNESS fitness function for GA

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:09 $

y = zeros(size(x,1),1); %Pre-allocate y
for i = 1:size(x,1)
  x1 = x(i,1);
  x2 = x(i,2);
  y(i) = p1 * (x1^2 - x2) ^2 + (p2 - x1)^2;
end
