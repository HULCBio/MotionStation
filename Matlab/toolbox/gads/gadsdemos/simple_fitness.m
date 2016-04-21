function y = simple_fitness(x)
%SIMPLE_FITNESS fitness function for GA

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:07 $

  y = 100 * (x(1)^2 - x(2)) ^2 + (1 - x(1))^2;
