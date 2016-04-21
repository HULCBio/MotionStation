function scores = rastriginsfcn(pop)
%RASTRIGINSFCN Compute the "Rastrigin" function.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2004/01/16 16:52:51 $


    % pop = max(-5.12,min(5.12,pop));
    scores = 10.0 * size(pop,2) + sum(pop .^2 - 10.0 * cos(2 * pi .* pop),2);
  


